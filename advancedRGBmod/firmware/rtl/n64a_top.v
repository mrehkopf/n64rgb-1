//////////////////////////////////////////////////////////////////////////////////
// Company:  Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    n64a_top
// Project Name:   N64 Advanced RGB/YPbPr DAC Mod
// Target Devices: Cyclone IV:    EP4CE6E22   , EP4CE10E22
//                 Cyclone 10 LP: 10CL006YE144, 10CL010YE144
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies: vh/n64a_params.vh
//               rtl/n64_igr.v        (Rev. 3.0)
//               rtl/n64_vinfo_ext.v  (Rev. 1.0)
//               rtl/n64_deblur.v     (Rev. 1.0)
//               rtl/n64a_linedbl.v   (Rev. 1.1)
//               rtl/n64a_video.v     (Rev. 1.0)
// (more dependencies may appear in other files)
//
// Revision: 1.1
// Features: based on n64rgb version 2.5
//           selectable RGB, RGsB or YPbPr
//           linebuffer for - NTSC 240p (480i optional) -> 480p rate conversion
//                          - PAL  288p (576i optional) -> 576p rate conversion
//
//////////////////////////////////////////////////////////////////////////////////


module n64a_top (
  // N64 Video Input
  nCLK,
  nDSYNC,
  D_i,

  // System CLK, Controller and Reset
  SYS_CLK,
  SYS_CLKen,
  CTRL_i,
  nRST,

  // Video Output to ADV712x
     CLK_ADV712x,
  nCSYNC_ADV712x,
//   nBLANK_ADV712x,
  V3_o,     // video component data vector 3 (B or Pr)
  V2_o,     // video component data vector 2 (G or Y)
  V1_o,     // video component data vector 1 (R or Pb)

  // Sync / Debug / Filter AddOn Output
  nCSYNC,
  nVSYNC_or_F2,
  nHSYNC_or_F1,

  // Jumper VGA Sync / Filter AddOn
  UseVGA_HVSync, // (J1) use Filter out if '0'; use /HS and /VS if '1'
  nFilterBypass, // (J1) bypass filter if '0'; set filter as output if '1'
                 //      (only applicable if UseVGA_HVSync is '0')

  // Jumper Video Output Type and Scanlines
  nEN_RGsB,   // (J2) generate RGsB if '0'
  nEN_YPbPr,  // (J2) generate RGsB if '0' (no RGB, no RGsB (overrides nEN_RGsB))
  SL_str,     // (J3) Scanline strength    (only for line multiplication and not for 480i bob-deint.)
  n240p,      // (J4) no linemultiplication for 240p if '0' (beats n480i_bob)
  n480i_bob   // (J4) bob de-interlacing of 480i material if '0'

);

`include "vh/n64a_params.vh"

input                     nCLK;
input                     nDSYNC;
input [color_width_i-1:0] D_i;

input  SYS_CLK;
output SYS_CLKen;
input  CTRL_i;
inout  nRST;

output                        CLK_ADV712x;
output                     nCSYNC_ADV712x;
// output                     nBLANK_ADV712x;
output [color_width_o-1:0] V3_o;
output [color_width_o-1:0] V2_o;
output [color_width_o-1:0] V1_o;

output nCSYNC;
output nVSYNC_or_F2;
output nHSYNC_or_F1;

input UseVGA_HVSync;
input nFilterBypass;

input       nEN_RGsB;
input       nEN_YPbPr;
input [1:0] SL_str;
input       n240p;
input       n480i_bob;


// start of rtl


// Part 0: Debug probes and sources
// ================================

wire [2:0] Linedoubler_debug;
source_3bit_0 Linedoubler_debug_src(
  .source(Linedoubler_debug)
);

// bit assignment for Linedoubler_debug[2:0]:
// 2 - 0 = use J4 setting         | 1 = use debug setting
// 1 - 0 = disable lineX2         | 1 = enable lineX2
// 0 - 0 = enable 480i bob-deint. | 1 = output 480i


wire [2:0] SL_debug;
source_3bit_0 scanline_debug_src(
  .source(SL_debug)
);

// bit assignment for SL_debug[2:0]:
// 2   - 0 = use J3 setting | 1 = use debug setting
// 1:0 - Scanline strength (00, 01, 10, 11 = 100%, 50%, 25%, 0%)


wire [2:0] Vidout_debug;
source_3bit_0 Vidout_debug_src(
  .source(Vidout_debug)
);

// bit assignment for Vidout_debug[2:0]:
// 2 - 0 = use J2 setting | 1 = use debug setting
// 1 - 0 = enable RGsB    | 1 = disable RGsB
// 0 - 0 = enable YPbPr   | 1 = disable YPbPr (beats RGsB)



wire [2:0] gamma_debug;
source_3bit_0 gamma_debug_src(
  .source(gamma_debug)
);

// bit assignment for gamma_debug[2:0]:
// 2   - use gamma table (don't use gamma table means gamma = 1.0)
// 1:0 - 00 = 0.8
//       01 = 0.9
//       10 = 1.1
//       11 = 1.2



wire [2:0] DeBlur_15bitmode_debug;
source_3bit_0 DeBlur_15bitmode_debug_src(
  .source(DeBlur_15bitmode_debug)
);

// bit assignment for DeBlur_15bitmode_debug[2:0]:
// 2 - 0 = use IGR setting | 1 = use debug setting
// 1 - 0 = force de-blur   | 1 = don't use de-blur (replaces nDeBlurMan)
// 0 - 0 = 15bit mode      | 1 = 21bit mode        (replaces n15bit_mode)


// Part 0: determine jumper set
// ============================

reg nfirstboot = 1'b0;
reg UseJumperSet;

always @(negedge nCLK) begin
  if (~nfirstboot) begin
    UseJumperSet <= nRST;  // fallback if reset pressed on power cycle
    nfirstboot <= 1'b1;
  end
end

// fallback only to 240p and RGB
// (sync output on G/Y in any case to see at least something even with a component cable)

wire nEN_YPbPr_active = UseJumperSet ? nEN_YPbPr : 1'b1;
wire n240p_active     = UseJumperSet ? n240p     : 1'b0;

// Part 1: connect IGR module
// ==========================

assign SYS_CLKen = 1'b1;

wire nForceDeBlur_tmp, nDeBlurMan_tmp, n15bit_mode_tmp;

n64a_igr igr(
  .SYS_CLK(SYS_CLK),
  .nRST(nRST),
  .CTRL(CTRL_i),
  .Default_DeBlur(1'b1),
  .Default_nForceDeBlur(1'b1),
  .nForceDeBlur(nForceDeBlur_tmp),
  .nDeBlur(nDeBlurMan_tmp),
  .n15bit_mode(n15bit_mode_tmp)
);

wire nForceDeBlur = DeBlur_15bitmode_debug[2] ? 1'b0 : nForceDeBlur_tmp;
wire nDeBlurMan   = DeBlur_15bitmode_debug[2] ? DeBlur_15bitmode_debug[1] : nDeBlurMan_tmp;
wire n15bit_mode  = DeBlur_15bitmode_debug[2] ? DeBlur_15bitmode_debug[0] : n15bit_mode_tmp;


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
  .Sync_pre(vdata_r[0][`VDATA_I_SY_SLICE]),
  .D_i(D_i),
  .vinfo_o({data_cnt,n64_480i,vmode,blurry_pixel_pos})
);


// Part 3: DeBlur Management (incl. heuristic)
// ===========================================

wire [1:0] deblurparams_pass;

n64_deblur deblur_management(
  .nCLK(nCLK),
  .nDSYNC(nDSYNC),
  .nRST(nRST),
  .vdata_sync_2pre(vdata_r[1][`VDATA_I_SY_SLICE]),
  .vdata_pre(vdata_r[0]),
  .vdata_cur(D_i),
  .deblurparams_i({data_cnt,n64_480i,vmode,blurry_pixel_pos,nForceDeBlur,nDeBlurMan}),
  .deblurparams_o(deblurparams_pass)
);


// Part 4: data demux
// ==================

wire [`VDATA_I_FU_SLICE] vdata_r[0:2];

n64_vdemux video_demux(
  .nCLK(nCLK),
  .nDSYNC(nDSYNC),
  .nRST(nRST),
  .D_i(D_i),
  .demuxparams_i({data_cnt,deblurparams_pass,n15bit_mode}),
  .gammaparams_i(gamma_debug),
  .vdata_r_0(vdata_r[0]),
  .vdata_r_1(vdata_r[1]),
  .vdata_r_6(vdata_r[2])
);

// Part 5: Post-Processing
// =======================

// Part 5.1: Line Multiplier
// =========================

wire CLK_out;

wire     n240p_debug = Linedoubler_debug[2] ? Linedoubler_debug[1] : n240p_active;
wire n480i_bob_debug = Linedoubler_debug[2] ? Linedoubler_debug[0] : n480i_bob;

wire       nENABLE_linedbl = (n64_480i & n480i_bob_debug) | ~n240p_debug | ~nRST;
// wire       nENABLE_linedbl = (n64_480i & n480i_bob) | ~n240p_active | ~nRST;

wire [1:0] SL_active = SL_debug[2] ? SL_debug[1:0] : SL_str;
wire [1:0] SL_str_dbl      = n64_480i ? 2'b11 : SL_active;
// wire [1:0] SL_str_dbl      = n64_480i ? 2'b11 : SL_str;

wire [4:0] vinfo_dbl = {nENABLE_linedbl,SL_str_dbl,vmode,n64_480i};

wire [vdata_width_o-1:0] vdata_tmp;

n64a_linedbl linedoubler(
  .nCLK_in(nCLK),
  .CLK_out(CLK_out),
  .nRST(nRST),
  .vinfo_dbl(vinfo_dbl),
  .vdata_i(vdata_r[2]),
  .vdata_o(vdata_tmp)
);


// Part 5.2: Color Transformation
// ==============================

wire [3:0] Sync_o;

wire nEN_RGsB_debug  = Vidout_debug[2] ? Vidout_debug[1] : nEN_RGsB;
wire nEN_YPbPr_debug = Vidout_debug[2] ? Vidout_debug[0] : nEN_YPbPr_active;

n64a_vconv video_converter(
  .CLK(CLK_out),
  .nEN_YPbPr(nEN_YPbPr_debug),    // enables color transformation on '0'
  .vdata_i(vdata_tmp),
  .vdata_o({Sync_o,V1_o,V2_o,V3_o})
);

// Part 5.3: assign final outputs
// ===========================
assign    CLK_ADV712x = CLK_out;
assign nCSYNC_ADV712x = nEN_RGsB_debug & nEN_YPbPr_debug ? 1'b0  : Sync_o[0];
// assign nBLANK_ADV712x = Sync_o[2];

// Filter Add On:
// =============================
//
// FILTER 1 | FILTER 2 | DESCRIPTION
// ---------+----------+--------------------
//      0   |     0    |  SD filter ( 9.5MHz)
//      0   |     1    |  ED filter (18.0MHz)
//      1   |     0    |  HD filter (36.0MHz)
//      1   |     1    | FHD filter (72.0MHz)
//
// (Bypass SF is hard wired to 0)

assign nCSYNC       = Sync_o[0];

assign nVSYNC_or_F2 = UseVGA_HVSync                     ? Sync_o[3] :
                      (nFilterBypass & nENABLE_linedbl) ? 1'b0 : 1'b1;
assign nHSYNC_or_F1 = UseVGA_HVSync                     ? Sync_o[1] :
                      nFilterBypass                     ? 1'b0 : 1'b1;

endmodule
