//////////////////////////////////////////////////////////////////////////////////
// Company: Circuit-Board.de
// Engineer: borti4938
// (initial design file by Ikari_01)
//
// Module Name:    n64rgb_viletim_sw_top
// Project Name:   N64 RGB DAC Mod
// Target Devices: MaxII: EPM240T100C5
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies: rtl/n64_vinfo_ext.v  (Rev. 1.0)
//               rtl/n64_deblur.v     (Rev. 1.0)
//               rtl/n64_vdemux.v     (Rev. 1.0)
//               vh/n64rgb_params.vh
//
// Revision: 1.5
// Features: BUFFERED version (no color shifting around edges)
//           de-blur with heuristic estimation (auto)
//           15bit color mode (5bit for each color) if wanted
//
//////////////////////////////////////////////////////////////////////////////////

module n64rgb_viletim_sw_top (
  // N64 Video Input
  nCLK,
  nDSYNC,
  D_i,

  nAutoDeBlur,
  nForceDeBlur_i1,  // feature to enable de-blur (0 = feature on, 1 = feature off)
  nForceDeBlur_i99, // (pin can be left unconnected for always on; weak pull-up assigned)
  n15bit_mode,      // 15bit color mode if input set to GND (weak pull-up assigned)

  dummy,            // some pins are tied to Vcc/GND according to viletims design

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

input       nAutoDeBlur;
input       nForceDeBlur_i1;
input       nForceDeBlur_i99;
input       n15bit_mode;

input [4:0] dummy;

output nHSYNC;
output nVSYNC;
output nCSYNC;
output nCLAMP;

output [color_width-1:0] R_o;     // red data vector
output [color_width-1:0] G_o;     // green data vector
output [color_width-1:0] B_o;     // blue data vector


// start of rtl

// Part 1: connect switches
// ========================

wire nForceDeBlur = &{~nAutoDeBlur,nForceDeBlur_i1,nForceDeBlur_i99};
wire nDeBlurMan   = nForceDeBlur_i1 & nForceDeBlur_i99;


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

wire ndo_deblur, nblank_rgb;
wire [1:0] deblurparams_pass;

n64_deblur deblur_management(
  .nCLK(nCLK),
  .nDSYNC(nDSYNC),
  .DRV_RST(1'b0),
  .vdata_sync_2pre(vdata_r[1][`VDATA_SY_SLICE]),
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
