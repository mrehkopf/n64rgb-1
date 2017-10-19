//////////////////////////////////////////////////////////////////////////////////
// Company:  Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    n64a_top
// Project Name:   N64 Advanced RGB Mod
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
///////////////////////////////////////////////////////////////////////////////////////////


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
//  nBLANK_ADV712x,
  V3_o,     // video component data vector 3 (B or Pr)
  V2_o,     // video component data vector 2 (G or Y)
  V1_o,     // video component data vector 1 (R or Pb)

  // Sync / Debug / Filter AddOn Output
  nCSYNC,
  nVSYNC_or_F2,
  nHSYNC_or_F1,

  // Jumper VGA Sync / Filter AddOn
  UseVGA_HVSync, // (J1) use Filter out if '0'; use /HS and /VS if '1'

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
//output                     nBLANK_ADV712x;
output [color_width_o-1:0] V3_o;
output [color_width_o-1:0] V2_o;
output [color_width_o-1:0] V1_o;

output nCSYNC;
output nVSYNC_or_F2;
output nHSYNC_or_F1;

input UseVGA_HVSync;

input       nEN_RGsB;
input       nEN_YPbPr;
input [1:0] SL_str;
input       n240p;
input       n480i_bob;


// start of rtl

// Part 0: Debug probes and sources
// ================================

wire [2:0] SL_debug;

source_3bit_0 scanline_debug_src(
  .source(SL_debug)
);

wire [1:0] SL_active = SL_debug[2] ? SL_debug[1:0] : SL_str;


wire [2:0] gamma_debug;

source_3bit_0 gamma_debug_src(
  .source(gamma_debug)
);


// Part 1: connect IGR module
// ==========================

assign SYS_CLKen = 1'b1;

wire nForceDeBlur, nDeBlurMan, n15bit_mode;

n64_igr igr(
  .SYS_CLK(SYS_CLK),
  .nRST(nRST),
  .CTRL(CTRL_i),
  .Default_DeBlur(1'b1),
  .Default_nForceDeBlur(1'b1),
  .nForceDeBlur(nForceDeBlur),
  .nDeBlur(nDeBlurMan),
  .n15bit_mode(n15bit_mode)
);


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

reg               [3:0] S_DBr[0:6];
reg [color_width_i-1:0] R_DBr[0:6], G_DBr[0:6], B_DBr[0:6]; // red, green and blue data buffer
reg [color_width_i-1:0] R_GaBo, G_GaBo, B_GaBo;             // red, green and blue (gamma boosted)

integer i;
initial begin
  for (i = 0; i < 7; i = i+1) begin
    S_DBr[i] = 4'b0000;
    R_DBr[i] = {color_width_i{1'b0}};
    G_DBr[i] = {color_width_i{1'b0}};
    B_DBr[i] = {color_width_i{1'b0}};
  end
  R_GaBo <= {color_width_i{1'b0}};
  G_GaBo <= {color_width_i{1'b0}};
  B_GaBo <= {color_width_i{1'b0}};
end


// Part 2: get all of the vinfo needed for further processing
// ==========================================================

wire [1:0] data_cnt;
wire       n64_480i;
wire       vmode;             // PAL: vmode == 1          ; NTSC: vmode == 0
wire       blurry_pixel_pos;  // indicates position of a potential blurry pixel

n64_vinfo_ext get_vinfo(
  .nCLK(nCLK),
  .nDSYNC(nDSYNC),
  .Sync_pre(S_DBr[0]),
  .D_i(D_i),
  .vinfo_o({data_cnt,n64_480i,vmode,blurry_pixel_pos})
);


// Part 3: DeBlur Management (incl. heuristic)
// ===========================================

wire nblank_rgb;

n64_deblur deblur_management(
  .nCLK(nCLK),
  .nDSYNC(nDSYNC),
  .nRST(nRST),
  .deblurparams({data_cnt,n64_480i,vmode,blurry_pixel_pos,nForceDeBlur,nDeBlurMan}),
  .vdata_sync_2pre(S_DBr[1]),
  .vdata_pre({S_DBr[0],R_DBr[0],G_DBr[0],B_DBr[0]}),
  .vdata_cur(D_i),
  .nblank_rgb(nblank_rgb)
);


// Part 4: data demux
// ==================

wire       en_gamma_boost = gamma_debug[2];
wire [1:0] gamma_rom_page = gamma_debug[1:0];

reg  [color_width_i-1:0] addr_gamma_rom = {color_width_i{1'b0}};
wire [color_width_i-1:0] data_gamma_rom;

always @(negedge nCLK) begin // data register management
  if (~nDSYNC) begin
    // shift data to output registers
    S_DBr[1] <= S_DBr[0];
    if (nblank_rgb) begin // pass RGB only if not blanked
      R_DBr[1] <= R_DBr[0];
      G_DBr[1] <= G_DBr[0];
      B_DBr[1] <= B_DBr[0];
    end

    // get new sync data
    S_DBr[0] <= D_i[3:0];
    
    // get gamma boosted red
    R_GaBo <= data_gamma_rom;
  end else begin
    // demux of RGB
    case(data_cnt)
      2'b01: begin
                G_GaBo <= data_gamma_rom;
        addr_gamma_rom <= R_DBr[1];
              R_DBr[0] <= n15bit_mode ? D_i : {D_i[6:2], 2'b00};
      end
      2'b10: begin
                B_GaBo <= data_gamma_rom;
        addr_gamma_rom <= G_DBr[1];
              G_DBr[0] <= n15bit_mode ? D_i : {D_i[6:2], 2'b00};
      end
      2'b11: begin
        addr_gamma_rom <= B_DBr[1];
              B_DBr[0] <= n15bit_mode ? D_i : {D_i[6:2], 2'b00};
      end
    endcase
  end

  for (i = 2; i < 6; i = i+1) begin
    S_DBr[i] <= S_DBr[i-1];
    R_DBr[i] <= R_DBr[i-1];
    G_DBr[i] <= G_DBr[i-1];
    B_DBr[i] <= B_DBr[i-1];
  end

  if (en_gamma_boost) begin
    R_DBr[6] <= R_GaBo;
    G_DBr[6] <= G_GaBo;
    B_DBr[6] <= B_GaBo;
  end else begin
    R_DBr[6] <= R_DBr[5];
    G_DBr[6] <= G_DBr[5];
    B_DBr[6] <= B_DBr[5];
  end

  if (~nRST) begin
    addr_gamma_rom <= {color_width_i{1'b0}};
    for (i = 0; i < 7; i = i+1) begin
      S_DBr[i] <= 4'b0000;
      R_DBr[i] <= {color_width_i{1'b0}};
      G_DBr[i] <= {color_width_i{1'b0}};
      B_DBr[i] <= {color_width_i{1'b0}};
    end
    R_GaBo <= {color_width_i{1'b0}};
    G_GaBo <= {color_width_i{1'b0}};
    B_GaBo <= {color_width_i{1'b0}};
  end
end

rom_1port_0 gamma_correction(
  .address({gamma_rom_page,addr_gamma_rom}),
  .clock(~nCLK),
  .rden(en_gamma_boost),
  .q(data_gamma_rom)
);

// Part 5: Post-Processing
// =======================

wire PX_CLK_4x;

altpll_0 vid_pll(
  .inclk0(nCLK),
  .areset(~nRST),
  .c0(PX_CLK_4x)
);


// Part 5.1: Line Multiplier
// =========================


wire       nENABLE_linedbl = (n64_480i & n480i_bob) | ~n240p | ~nRST;
wire [1:0] SL_str_dbl      = n64_480i ? 2'b11 : SL_active;

wire [4:0] vinfo_dbl = {nENABLE_linedbl,SL_str_dbl,vmode,n64_480i};

wire [vdata_width_o-1:0] vdata_tmp;

n64a_linedbl linedoubler(
  .nCLK_in(nCLK),
  .CLK_out(PX_CLK_4x),
  .vinfo_dbl(vinfo_dbl),
  .vdata_i({S_DBr[4],R_DBr[6],G_DBr[6],B_DBr[6]}),
  .vdata_o(vdata_tmp)
);


// Part 5.2: Color Transformation
// ==============================

wire [3:0] Sync_o;

n64a_vconv video_converter(
  .CLK(PX_CLK_4x),
  .nEN_YPbPr(nEN_YPbPr),    // enables color transformation on '0'
  .vdata_i(vdata_tmp),
  .vdata_o({Sync_o,V1_o,V2_o,V3_o})
);

// Part 5.3: assign final outputs
// ===========================
assign    CLK_ADV712x = PX_CLK_4x;
assign nCSYNC_ADV712x = nEN_RGsB & nEN_YPbPr ? 1'b0  : Sync_o[0];
//assign nBLANK_ADV712x = 1'b1;

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

assign nVSYNC_or_F2 = UseVGA_HVSync   ? Sync_o[3] :
                      nENABLE_linedbl ? 1'b0 : 1'b1;
assign nHSYNC_or_F1 = UseVGA_HVSync   ? Sync_o[1] :
                                        1'b0;

endmodule
