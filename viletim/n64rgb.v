//////////////////////////////////////////////////////////////////////////////////
// Company: Circuit-Board.de
// Engineer: borti4938
// (initial design file by Ikari_01)
//
// Module Name:    n64rgb
// Project Name:   n64rgb
// Target Devices: MaxII: EPM240T100C5
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies: no
//
// Revision: 1.5
// Features: BUFFERED version (no color shifting around edges)
//           de-blur with heuristic estimation (auto)
//           15bit color mode (5bit for each color) if wanted
//
///////////////////////////////////////////////////////////////////////////////////////////

module n64rgb (
  input nCLK,
  input nDSYNC,
  input [6:0] D_i,

  input nAutoDeBlur,
  input nForceDeBlur,  // feature to enable de-blur (0 = feature on, 1 = feature off)
                       // (pin can be left unconnected for always on; weak pull-up assigned)
  input n15bit_mode, // 15bit color mode if input set to GND (weak pull-up assigned)
  input [4:0] dummy, // some pins are tied to Vcc/GND according to viletims design

  output reg nVSYNC,
  output reg nCLAMP,
  output reg nHSYNC,
  output reg nCSYNC,

  output reg [6:0] R_o,     // red data vector
  output reg [6:0] G_o,     // green data vector
  output reg [6:0] B_o      // blue data vector
);


reg [3:0] S_DBr[0:1];          // sync data vector buffer: {nVSYNC, nCLAMP, nHSYNC, nCSYNC}
reg [6:0] R_DBr, G_DBr, B_DBr; // red, green and blue data buffer

initial begin
  S_DBr[1] = 4'b1111;
  S_DBr[0] = 4'b1111;
  {nVSYNC, nCLAMP, nHSYNC, nCSYNC} = 4'b1111;
  R_DBr = 7'b0000000;
  G_DBr = 7'b0000000;
  B_DBr = 7'b0000000;
  R_o = 7'b0000000;
  G_o = 7'b0000000;
  B_o = 7'b0000000;
end


// short description of N64s RGB and sync data demux
// =================================================
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


// Part 1.1: data counter for heuristic and de-mux
// ===============================================

reg [1:0] data_cnt = 2'b00;

always @(negedge nCLK) begin // data register management
  if (~nDSYNC)
    data_cnt <= 2'b01;  // reset data counter
  else
    data_cnt <= data_cnt + 1'b1;  // increment data counter
end


// Part 1.2: estimation of 240p/288p
// =================================

reg [2:0] serr_cnt = 3'b000; // 240p: 3 hsync pulses during vsync pulse ; 480i: 6 serrated hsync per vsync
reg       n64_480i = 1'b1;

always @(negedge nCLK) begin // estimation of blur effect
  if (~nDSYNC) begin
    if(&{~S_DBr[0][3],~S_DBr[0][0],D_i[0]}) // nVSYNC low and posedge at nCSYNC
      serr_cnt <= serr_cnt + 1'b1;          // count up hsync pulses during vsync pulse
                                            // serr_cnt[2]==1 means a value >=4 -> 480i mode detected

    if(~S_DBr[0][3] & D_i[3]) begin // posedge at nVSYNC detected - set n64_480i and reset serr_cnt
      n64_480i <= serr_cnt[2];
      serr_cnt <= 3'b000;
    end
  end
end


// Part 1.3: determine vmode
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


// Part 2.1: heuristic guess in 240p/288p if blur is used by the N64
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
                               // (blur_pixel_pos changes on next @(negedge nCLK))

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

      nblur_n64 <= nblur_n64_trend[`NBLUR_TH_BIT];

      nblur_est_cnt <= 2'b00;
    end

  end else if (&{S_DBr[1][3],S_DBr[1][1],S_DBr[0][3],S_DBr[0][1]}) begin
    if (blur_pixel_pos) begin
      case(data_cnt)
          2'b01: gradient[2] <= {R_DBr[`CMP_RANGE] < D_i[`CMP_RANGE],
                                 R_DBr[`CMP_RANGE] > D_i[`CMP_RANGE]};
          2'b10: gradient[1] <= {G_DBr[`CMP_RANGE] < D_i[`CMP_RANGE],
                                 G_DBr[`CMP_RANGE] > D_i[`CMP_RANGE]};
          2'b11: gradient[0] <= {B_DBr[`CMP_RANGE] < D_i[`CMP_RANGE],
                                 B_DBr[`CMP_RANGE] > D_i[`CMP_RANGE]};
      endcase
    end else if (run_estimation[2]) begin
      case(data_cnt)
          2'b01: if (&(gradient[2] ^ {R_DBr[`CMP_RANGE] < D_i[`CMP_RANGE],
                                      R_DBr[`CMP_RANGE] > D_i[`CMP_RANGE]}))
                   gradient_changes <= 2'b01;
          2'b10: if (&(gradient[1] ^ {G_DBr[`CMP_RANGE] < D_i[`CMP_RANGE],
                                      G_DBr[`CMP_RANGE] > D_i[`CMP_RANGE]}))
                   gradient_changes <= gradient_changes + 1'b1;
          2'b11: if (&(gradient[0] ^ {B_DBr[`CMP_RANGE] < D_i[`CMP_RANGE],
                                      B_DBr[`CMP_RANGE] > D_i[`CMP_RANGE]}))
                   gradient_changes <= gradient_changes + 1'b1;
      endcase
    end
  end else begin
    run_estimation  <= 3'b0;
    gradient[2]     <= 2'b0;
    gradient[1]     <= 2'b0;
    gradient[0]     <= 2'b0;
  end
  if (n64_480i) begin // no reset input on this setup :(
    nblur_n64_trend <= init_trend;
    nblur_n64       <= 1'b1;
  end
end


// Part 2.2: blanking management
// =============================

wire ndo_deblur = ~nForceDeBlur ?  n64_480i              :        // force de-blur for 240p?    -> yes: enable it | no: next question
                  ~nAutoDeBlur  ? (n64_480i | nblur_n64) : 1'b1;  // use heuristic for de-blur? -> yes: enable de-blur depending on estimation | no: disable it240p and (de-blur forced or deblur estimated

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


// Part 3: data demux
// ==================

always @(negedge nCLK) begin // data register management
  if (~nDSYNC) begin
    // shift data to output registers
    if(ndo_deblur)
      {nVSYNC, nCLAMP, nHSYNC, nCSYNC} <= S_DBr[0];
    S_DBr[1] <= S_DBr[0];
    if (nblank_rgb) begin // pass RGB only if not blanked
      R_o <= R_DBr;
      G_o <= G_DBr;
      B_o <= B_DBr;
    end

    // get new sync data
    S_DBr[0] <= D_i[3:0];
  end else begin
    // demux of RGB
    case(data_cnt)
      2'b01: R_DBr <= n15bit_mode ? D_i : {D_i[6:2], 2'b00};
      2'b10: begin
        G_DBr <= n15bit_mode ? D_i : {D_i[6:2], 2'b00};
        if(~ndo_deblur)
          {nVSYNC, nCLAMP, nHSYNC, nCSYNC} <= S_DBr[0];
      end
      2'b11: B_DBr <= n15bit_mode ? D_i : {D_i[6:2], 2'b00};
    endcase
  end
end

endmodule
