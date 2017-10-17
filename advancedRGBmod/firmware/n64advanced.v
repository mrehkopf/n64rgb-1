//////////////////////////////////////////////////////////////////////////////////
// Company:  Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    n64advanced
// Project Name:   Advanced RGB Mod
// Target Devices: Cyclone IV:    EP4CE6E22, EP4CE10E22
//                 Cyclone 10 LP: 10CL006YE144, 10CL010YE144
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies: n64igr.v     (Rev. 3.0)
//               n64linedbl.v (Rev. 1.0)
//               n64video.v   (Rev. 1.0)
//
// Revision: 1.0
// Features: based on n64rgb version 2.5
//           selectable RGB, RGsB or YPbPr
//           linebuffer for - NTSC 240p (480i optional) -> 480p rate conversion
//                          - PAL  288p (576i optional) -> 576p rate conversion
//
///////////////////////////////////////////////////////////////////////////////////////////

//`define OPTION_INVLPF

module n64advanced (
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
  UseVGA_HVSync, // (J1)

  // Jumper Video Output Type and Scanlines
  nEN_RGsB,   // (J2) generate RGsB if '0'
  nEN_YPbPr,  // (J2) generate RGsB if '0' (no RGB, no RGsB (overrides nEN_RGsB))
  SL_str,     // (J3) Scanline strength    (only for line multiplication and not for 480i bob-deint.)
  n240p,      // (J4) no linemultiplication for 240p if '0' (beats n480i_bob)
  n480i_bob   // (J4) bob de-interlacing of 480i material if '0'

);

parameter color_width_i = 7;
parameter color_width_o = 8;

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

input  UseVGA_HVSync;

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

wire nForceDeBlur, nDeBlur, n15bit_mode;

n64igr igr(
  .SYS_CLK(SYS_CLK),
  .nRST(nRST),
  .CTRL(CTRL_i),
  .Default_DeBlur(1'b1),
  .Default_nForceDeBlur(1'b1),
  .nForceDeBlur(nForceDeBlur),
  .nDeBlur(nDeBlur),
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



// Part 2.1: data counter for heuristic and de-mux
// ===============================================

reg [1:0] data_cnt = 2'b00;

always @(negedge nCLK) begin // data register management
  if (~nDSYNC)
    data_cnt <= 2'b01;  // reset data counter
  else
    data_cnt <= data_cnt + 1'b1;  // increment data counter
end


// Part 2.2: estimation of 240p/288p
// =================================

reg FrameID  = 1'b0; // 0 = even frame, 1 = odd frame; 240p: only odd frames; 480i: even and odd frames
reg n64_480i = 1'b1;

always @(negedge nCLK) begin
  if (~nDSYNC) begin
    if (S_DBr[0][3] & ~D_i[3]) begin    // negedge at nVSYNC
      if (S_DBr[0][1] & ~D_i[1]) begin  // negedge at nHSYNC, too -> odd frame
        n64_480i <= ~FrameID;
        FrameID  <= 1'b1;
      end else begin                    // no negedge at nHSYNC -> even frame
        n64_480i <= 1'b1;
        FrameID  <= 1'b0;
      end
    end
  end
end


// Part 2.3: determine vmode
// =========================

reg [1:0] line_cnt;       // PAL: line_cnt[1:0] == 01 ; NTSC: line_cnt[1:0] = 11
reg       vmode;          // PAL: vmode == 1          ; NTSC: vmode == 0
reg       blur_pixel_pos; // indicates position of a potential blurry pixel
                          // blur_pixel_pos == 0 -> pixel at D_i
                          // blur_pixel_pos == 1 -> pixel at #_DBr

always @(negedge nCLK) begin
  if (~nDSYNC) begin
    if(~S_DBr[0][3] & D_i[3]) begin // posedge at nVSYNC detected - reset line_cnt and set vmode
      line_cnt <= 2'b00;
      vmode    <= ~line_cnt[1];
    end

    if(~S_DBr[0][1] & D_i[1]) // posedge nHSYNC -> increase line_cnt
      line_cnt <= line_cnt + 1'b1;

    if(~n64_480i) begin // 240p
      if(~S_DBr[0][0] & D_i[0]) // posedge nCSYNC -> reset blanking
        blur_pixel_pos <= ~vmode;
      else
        blur_pixel_pos <= ~blur_pixel_pos;
    end else
      blur_pixel_pos <= 1'b1;
  end
end


// Part 3.1: heuristic guess in 240p/288p if blur is used by the N64
// =================================================================

`define CMP_RANGE 6:5 // evaluate gradients in this range (shall include the MSB)

`define TREND_RANGE    8:0      // width of the trend filter
`define NBLUR_TH_BIT   8        // MSB
parameter init_trend = 9'h100;  // initial value (shall have MSB set, zero else)

reg [1:0] nblur_est_cnt     = 2'b00;  // register to estimate whether blur is used or not by the N64
reg [1:0] nblur_est_holdoff = 2'b00;  // Holf Off the nblur_est_cnt (removes ripples e.g. due to light effects)

reg [2:0] run_estimation = 3'b000;    // run counter or not (run_estimation[2] decides); do not use pixels at border

reg [1:0] gradient[2:0];  // shows the (sharp) gradient direction between neighbored pixels
                          // gradient[x][1]   = 1 -> decreasing intensity
                          // gradient[x][0]   = 1 -> increasing intensity
                          // else                 -> constant
reg [1:0] gradient_changes = 2'b00;

reg [`TREND_RANGE] nblur_n64_trend = init_trend;  // trend shows if the algorithm tends to estimate more blur enabled rather than disabled
                                                  // this acts as like as a very simple mean filter
reg nblur_n64 = 1'b1;                             // blur effect is estimated to be off within the N64 if value is 1'b1

always @(negedge nCLK) begin // estimation of blur effect
  if (~nDSYNC) begin

    if(~blur_pixel_pos) begin  // incomming (potential) blurry pixel
                               // (blur_pixel_pos changes on next @(posedge PX_CLK_4x))

      run_estimation[2:1] <= run_estimation[1:0]; // deblur estimation counter is
      run_estimation[0]   <= 1'b1;                // starts a bit delayed in each line

      if (|nblur_est_holdoff) // hold_off? if yes, increment it until overflow back to zero
        nblur_est_holdoff <= nblur_est_holdoff + 1'b1;


      if (&gradient_changes) begin  // evaluate gradients: &gradient_changes == all color components changed the gradient
        if (~nblur_est_cnt[1] & ~|nblur_est_holdoff)
          nblur_est_cnt <= nblur_est_cnt +1'b1;
        nblur_est_holdoff <= 2'b01;
      end

      gradient_changes    <= 2'b00; // reset
    end

    if(~S_DBr[0][0] & D_i[0]) begin // negedge at CSYNC detected - new line
      run_estimation    <= 3'b000;
      nblur_est_holdoff <= 2'b00;
    end

    if(S_DBr[0][3] & ~D_i[3]) begin // negedge at nVSYNC detected - new frame
      if(nblur_est_cnt[1]) begin // add to weight
        if(~&nblur_n64_trend)
          nblur_n64_trend <= nblur_n64_trend + 1'b1;
      end else begin// subtract
        if(|nblur_n64_trend)
          nblur_n64_trend <= nblur_n64_trend - 1'b1;
      end

      nblur_n64     <= nblur_n64_trend[`NBLUR_TH_BIT];
      nblur_est_cnt <= 2'b00;
    end

  end else if (&{S_DBr[1][3],S_DBr[1][1],S_DBr[0][3],S_DBr[0][1]}) begin
    if (blur_pixel_pos) begin
      case(data_cnt)
          2'b01: gradient[2] <= {R_DBr[0][`CMP_RANGE] < D_i[`CMP_RANGE],
                                 R_DBr[0][`CMP_RANGE] > D_i[`CMP_RANGE]};
          2'b10: gradient[1] <= {G_DBr[0][`CMP_RANGE] < D_i[`CMP_RANGE],
                                 G_DBr[0][`CMP_RANGE] > D_i[`CMP_RANGE]};
          2'b11: gradient[0] <= {B_DBr[0][`CMP_RANGE] < D_i[`CMP_RANGE],
                                 B_DBr[0][`CMP_RANGE] > D_i[`CMP_RANGE]};
      endcase
    end else if (run_estimation[2]) begin
      case(data_cnt)
          2'b01: if (&(gradient[2] ^ {R_DBr[0][`CMP_RANGE] < D_i[`CMP_RANGE],
                                      R_DBr[0][`CMP_RANGE] > D_i[`CMP_RANGE]}))
                   gradient_changes <= 2'b01;
          2'b10: if (&(gradient[1] ^ {G_DBr[0][`CMP_RANGE] < D_i[`CMP_RANGE],
                                      G_DBr[0][`CMP_RANGE] > D_i[`CMP_RANGE]}))
                   gradient_changes <= gradient_changes + 1'b1;
          2'b11: if (&(gradient[0] ^ {B_DBr[0][`CMP_RANGE] < D_i[`CMP_RANGE],
                                      B_DBr[0][`CMP_RANGE] > D_i[`CMP_RANGE]}))
                   gradient_changes <= gradient_changes + 1'b1;
      endcase
    end
  end else begin
    run_estimation  <= 3'b0;
    gradient[2]     <= 2'b0;
    gradient[1]     <= 2'b0;
    gradient[0]     <= 2'b0;
  end
  if (~nRST | n64_480i) begin
    nblur_n64_trend <= init_trend;
    nblur_n64       <= 1'b1;
  end
end


// Part 3.2: blanking management
// =============================

wire ndo_deblur = ~nForceDeBlur ?  (n64_480i | nDeBlur) : (n64_480i | nblur_n64); // force de-blur option for 240p? -> yes: enable it if user wants to | no: enable de-blur depending on estimation

reg  nblank_rgb;  // blanking of RGB pixels for de-blur

always @(negedge nCLK) begin
  if (~nDSYNC)
    if(ndo_deblur)
      nblank_rgb <= 1'b1;
    else begin 
      if(~S_DBr[0][0] & D_i[0]) // posedge nCSYNC -> reset blanking
        nblank_rgb <= vmode;
      else
        nblank_rgb <= ~nblank_rgb;
    end
end


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

wire [4:0] vinfo = {nENABLE_linedbl,SL_str_dbl,vmode,n64_480i};

wire PX_CLK_o;

wire             [3:0] Sync_tmp;
wire [color_width_i:0] R_tmp, G_tmp, B_tmp;

n64linedbl linedoubler(
  .nCLK_in(nCLK),
  .CLK_out(PX_CLK_4x),
  .vinfo(vinfo),
  .Sync_i(S_DBr[4]),
  .R_i(R_DBr[6]),
  .G_i(G_DBr[6]),
  .B_i(B_DBr[6]),
  .Sync_o(Sync_tmp),
  .R_o(R_tmp),
  .G_o(G_tmp),
  .B_o(B_tmp)
);


// Part 5.2: Color Transformation
// ==============================

wire [3:0] Sync_o;

n64video video_converter(
  .CLK(PX_CLK_4x),
  .nEN_YPbPr(nEN_YPbPr),    // enables color transformation on '0'
  .Sync_i(Sync_tmp),
  .R_i(R_tmp),
  .G_i(G_tmp),
  .B_i(B_tmp),
  .Sync_o(Sync_o),
  .V1_o(V1_o),
  .V2_o(V2_o),
  .V3_o(V3_o)
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
