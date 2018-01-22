//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2016-2018 by Peter Bartmann <borti4938@gmx.de>
//
// N64 RGB/YPbPr DAC is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//////////////////////////////////////////////////////////////////////////////////
//
// Company: Circuit-Board.de
// Engineer: borti4938
// (initial design file by Ikari_01)
//
// Module Name:    n64rgb_viletim_igr_top
// Project Name:   N64 RGB DAC Mod
// Target Devices: MaxII: EPM240T100C5
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies: rtl/n64_igr.v        (Rev. 2.5)
//               rtl/n64_vinfo_ext.v  (Rev. 1.0)
//               rtl/n64_deblur.v     (Rev. 1.1)
//               rtl/n64_vdemux.v     (Rev. 1.0)
//               vh/n64rgb_params.vh
//
// Revision: 2.5
// Features: BUFFERED version (no color shifting around edges)
//           deblur (with heuristic) and 15bit mode (5bit for each color)
//             - heuristic deblur:   on (default)                               | off (set pin 61 to GND / short pin 61 & 60)
//             - deblur default:     on (default)                               | off (set pin 91 to GND / short pin 91 & 90)
//               (deblur deafult only comes into account if heuristic is switched off)
//             - 15bit mode default: on (set pin 36 to GND / short pin 36 & 37) | off (default)
//           controller input detection for switching de-blur and 15bit mode
//           resetting N64 using the controller
//           defaults of de-blur and 15bit mode are set on power cycle
//           if de-blur heuristic is overridden by user, it is reset on each power cycle and on each reset
//
//////////////////////////////////////////////////////////////////////////////////


module n64rgb_viletim_igr_top (
  // N64 Video Input
  nCLK,
  nDSYNC,
  D_i,

  // Controller and Reset
  CTRL_nAutoDB, // just used as CTRL_i; renaming to use common sdc file
  nRST_o1,
  nRST_o99,

  // Jumper
  Default_nForceDeBlur,
  Default_DeBlur,
  Default_n15bit_mode,

  // dummies (some pins are tied to Vcc/GND according to viletims design)
  dummy,

  // Video output
  nHSYNC,
  nVSYNC,
  nCSYNC,
  nCLAMP,

  R_o,     // red data vector
  G_o,     // green data vector
  B_o      // blue data vector

);

`include "vh/n64rgb_params.vh"

input                   nCLK;
input                   nDSYNC;
input [color_width-1:0] D_i;

input CTRL_nAutoDB;
inout nRST_o1;
inout nRST_o99;

input Default_nForceDeBlur;
input Default_DeBlur;
input Default_n15bit_mode;

input [4:0] dummy; // some pins are tied to Vcc/GND according to viletims design

output nHSYNC;
output nVSYNC;
output nCSYNC;
output nCLAMP;

output [color_width-1:0] R_o;     // red data vector
output [color_width-1:0] G_o;     // green data vector
output [color_width-1:0] B_o;     // blue data vector


// start of rtl

// Part 1: connect IGR module
// ==========================

wire nForceDeBlur, nDeBlurMan, n15bit_mode;
wire nRST_IGR = nRST_o1 & nRST_o99;
wire DRV_RST;
wire CTRL_IGR = CTRL_nAutoDB;

n64_igr igr(
  .nCLK(nCLK),
  .nRST_IGR(nRST_IGR),
  .DRV_RST(DRV_RST),
  .CTRL(CTRL_IGR),
  .Default_nForceDeBlur(Default_nForceDeBlur),
  .Default_DeBlur(Default_DeBlur),
  .Default_n15bit_mode(Default_n15bit_mode),
  .nForceDeBlur(nForceDeBlur),
  .nDeBlur(nDeBlurMan),
  .n15bit_mode(n15bit_mode)
);

assign nRST_o1  = DRV_RST ? 1'b0 : 1'bz;
assign nRST_o99 = DRV_RST ? 1'b0 : 1'bz;


// Part 2 - 4: RGB Demux with De-Blur Add-On
// =========================================
//
// short description of N64s RGB and sync data demux
// -------------------------------------------------
//
// pulse shapes and their realtion to each other:
// nCLK (~50MHz, Numbers representing negedge count)
// ---. 3 .---. 0 .---. 1 .---. 2 .---. 3 .---
//    |___|   |___|   |___|   |___|   |___|
// nDSYNC (~12.5MHz)                           .....
// -------.       .-------------------.
//        |_______|                   |_______
//
// more info: http://members.optusnet.com.au/eviltim/n64rgb/n64rgb.html
//

// Part 2: get all of the vinfo needed for further processing
// ==========================================================

wire [1:0] data_cnt;
wire       n64_480i;
wire       vmode;             // PAL: vmode == 1          ; NTSC: vmode == 0
wire       blurry_pixel_pos;  // indicates position of a potential blurry pixel

n64_vinfo_ext get_vinfo(
  .nCLK(nCLK),
  .nDSYNC(nDSYNC),
  .Sync_pre(vdata_r[0][`VDATA_SY_SLICE]),
  .D_i(D_i),
  .vinfo_o({data_cnt,n64_480i,vmode,blurry_pixel_pos})
);


// Part 3: DeBlur Management (incl. heuristic)
// ===========================================

wire nrst_deblur = nRST_o1 & nRST_o99;
wire ndo_deblur, nblank_rgb;
wire [1:0] deblurparams_pass;

n64_deblur deblur_management(
  .nCLK(nCLK),
  .nDSYNC(nDSYNC),
  .nRST(nrst_deblur),
  .vdata_pre(vdata_r[0]),
  .vdata_cur(D_i),
  .deblurparams_i({data_cnt,n64_480i,vmode,blurry_pixel_pos,nForceDeBlur,nDeBlurMan}),
  .deblurparams_o(deblurparams_pass)
);


// Part 4: data demux
// ==================

wire [`VDATA_FU_SLICE] vdata_r[0:1];

n64_vdemux video_demux(
  .nCLK(nCLK),
  .nDSYNC(nDSYNC),
  .D_i(D_i),
  .demuxparams_i({data_cnt,deblurparams_pass,n15bit_mode}),
  .vdata_r_0(vdata_r[0]),
  .vdata_r_1(vdata_r[1])
);


assign {nVSYNC,nCLAMP,nHSYNC,nCSYNC} = vdata_r[1][`VDATA_SY_SLICE];
assign {R_o,G_o,B_o}                 = vdata_r[1][`VDATA_CO_SLICE];

endmodule
