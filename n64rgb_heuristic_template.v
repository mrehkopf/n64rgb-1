//////////////////////////////////////////////////////////////////////////////////
// Company: Circuit-Board.de
// Engineer: borti4938
// (initial design file by Ikari_01)
//
// Module Name:    n64rgb
// Project Name:   n64rgb
// Target Devices: MaxII
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies:
//
// Revision: 5 alpha
// Additional Comments: BUFFERED version (no color shifting around edges)
//                      deactivation of de-blur if wanted
//                      heuristic guess of N64 blur (template)
///////////////////////////////////////////////////////////////////////////////////////////


module n64rgb (
  input nCLK,
  input nDSYNC,
  input [6:0] D_i,
  input nDBF_AUTO,   // pin to enable the estimation whether blur is used or not
                     // (0 = estimation on, 1 = estimation off)
  input nDBF_MANUAL, // pin to enable the dither filter (0 = feature on, 1 = feature off)
                     // (pin can be left unconnected; weak pull-up assigned)  output nVSYNC,

  input [4:0] dummy, // some pins are tied to Vcc/GND according to viletims design

  output nVSYNC,
  output nCLAMP,
  output nHSYNC,
  output nCSYNC,

  output [6:0] R_o,     // red data vector
  output [6:0] G_o,     // green data vector
  output [6:0] B_o      // blue data vector
);


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


integer idx;

reg [3:0] S_DBr[0:1]; // sync data vector buffer: {nVSYNC, nCLAMP, nHSYNC, nCSYNC}
reg [6:0] R_DBr[0:2]; // red data vector buffer
reg [6:0] G_DBr[0:2]; // green data vector buffer
reg [6:0] B_DBr[0:2]; // blue data vector buffer


initial begin
  for (idx=0; idx<2; idx=idx+1) begin
    S_DBr[idx] = 4'b1111;
  end
  for (idx=0; idx<3; idx=idx+1) begin
    R_DBr[idx] = 7'b0000000;
    G_DBr[idx] = 7'b0000000;
    B_DBr[idx] = 7'b0000000;
  end
end


// Part 1: blanking management
// ===========================

reg [1:0] line_cnt;      // PAL: line_cnt[1:0] == 01 ; NTSC: line_cnt[1:0] = 11
reg       vmode;         // PAL: vmode == 1          ; NTSC: vmode == 0
reg       nblured_pixel; // potential blurred pixel

always @(negedge nCLK) begin
  if (~nDSYNC) begin
    if(~S_DBr[0][3] & D_i[3]) begin // posedge at nVSYNC detected - reset line_cnt and set vmode
      line_cnt <= 2'b00;
      vmode    <= ~line_cnt[1];
    end

    if(~S_DBr[0][1] & D_i[1]) // posedge nHSYNC -> increase line_cnt
      line_cnt <= line_cnt + 1'b1;

    if(~S_DBr[0][0] & D_i[0])// posedge nCSYNC -> reset blanking
      nblured_pixel <= vmode;
    else
      nblured_pixel <= ~nblured_pixel;
  end
end


// Part 2a: estimation of 240p/288p
// ===============================

reg [2:0] serr_cnt = 3'b000; // 240p: 3 hsync pulses during vsync pulse ; 480i: 6 serrated hsync per vsync
reg       n64_480i = 1'b1;

always @(negedge nCLK) begin // estimation of blur effect
  if (~nDSYNC) begin
    if(&{~S_DBr[0][3],~S_DBr[0][0],D_i[0]}) // nVSYNC low and posedge at nCSYNC
      serr_cnt <= serr_cnt + 1'b1;          // count up hsync pulses during vsync pulse
                                            // serr_cnt[2]==1 means a value >=4 -> 480i mode detected

    if(~S_DBr[0][3] & D_i[3]) begin // posedge at nVSYNC detected - set n64_480i and reset serr_cnt
      n64_480i <= serr_cnt[2];
      serr_cnt  <= 3'b000;
    end
  end
end

// Part 2b: heuristic guess in 240p/288p if blur is used by the N64
// ================================================================

// A simple 4-state ripple carry counter is shown. Insert your own code here.
// Use the signal nblur_n64 to show if the N64 uses blur or not (0 = blur on, 1 = blur off)
// according to your estimation.
// This part runs independent of the 240p/288p estimation and does not have to be switched
// off in 480i/576i.

localparam EST_CNT_SIZE = 16;

localparam EST_CMP_VAL  = 4'h5;

reg [2:0] blur_est_cnt_co;
reg [EST_CNT_SIZE/4-1:0] blur_est_cnt[3:0]; // register to estimate whether blur is used or not by the N64

wire nblur_n64_tmp = blur_est_cnt[3] < EST_CMP_VAL; // estimation counter stop (logic might be changed later depending on heuristic)
reg  nblur_n64; // blur effect is estimated to be off within the N64 if value is 1'b1
                // (blur estimation counter does not exceed predefined constant)

reg  [1:0] leading_unequal_flag;
wire [1:0] inequality_score = line_cnt[0] ? {G_DBr[1][6:3] > G_DBr[0][6:3], G_DBr[1][6:3] < G_DBr[0][6:3]} :
                              line_cnt[1] ? {R_DBr[1][6:3] > R_DBr[0][6:3], R_DBr[1][6:3] < R_DBr[0][6:3]} :
                                            {B_DBr[1][6:3] > B_DBr[0][6:3], B_DBr[1][6:3] < B_DBr[0][6:3]};

always @(negedge nCLK) begin // estimation of blur effect
  if (~nDSYNC) begin
    if(S_DBr[0][3] & ~D_i[3]) begin // negedge at nVSYNC detected - blur_est_cnt and set nblur_n64
      nblur_n64 <= nblur_n64_tmp;
      for (idx=0; idx<4; idx=idx+1)
        blur_est_cnt[idx] <= 0;
    end

    if(~S_DBr[0][0] & D_i[0]) begin// posedge nCSYNC -> reset leading_unequal_flag and blur_cnt_co
      leading_unequal_flag <= 2'b11;
      blur_est_cnt_co <= 3'b000;
    end

    if (nblured_pixel & nblur_n64_tmp) begin
      // compare middle value (potentially blurred) with the both around them
      // and add violations to the counter
      {blur_est_cnt_co[0], blur_est_cnt[0]} <= blur_est_cnt[0] + ^(leading_unequal_flag ~^ inequality_score);
      blur_est_cnt_co[2:1] <=2'b00;
    end else begin
      leading_unequal_flag <= inequality_score;
      blur_est_cnt_co <= 3'b000;
    end
  end else if (^blur_est_cnt_co) begin // if there exist a carry, ripple it.
    case(data_cnt)
      2'b01: begin
               {blur_est_cnt_co[1], blur_est_cnt[1]} <= blur_est_cnt[1] + blur_est_cnt_co[0];
               {blur_est_cnt_co[2],blur_est_cnt_co[0]} <= 2'b00;
             end
      2'b10: begin
               {blur_est_cnt_co[2], blur_est_cnt[2]} <= blur_est_cnt[2] + blur_est_cnt_co[1];
               blur_est_cnt_co[1:0] <= 2'b00;
             end
      2'b11: begin
               blur_est_cnt[3] <= blur_est_cnt[3] + blur_est_cnt_co[2];
               blur_est_cnt_co <= 3'b000;
             end
    endcase
  end
end


// Part 3: data demux
// ==================

reg [1:0] data_cnt = 2'b00;


always @(negedge nCLK) begin // data register management
  if (~nDSYNC) begin
    // shift data to the left
    S_DBr[1] <= S_DBr[0];
    for (idx=2; idx>0; idx=idx-1) begin
      R_DBr[idx] <= R_DBr[idx-1];
      G_DBr[idx] <= G_DBr[idx-1];
      B_DBr[idx] <= B_DBr[idx-1];
    end

    // get new data
    S_DBr[0] <= D_i[3:0];

    // reset data counter
    data_cnt <= 2'b01;
  end else begin
    case(data_cnt)
      2'b01: R_DBr[0] <= D_i;
      2'b10: G_DBr[0] <= D_i;
      2'b11: B_DBr[0] <= D_i;
    endcase

    // increment data counter
    data_cnt <= data_cnt + 1'b1;
  end
end


wire ndeblur        = n64_480i | (nDBF_MANUAL & (nDBF_AUTO | nblur_n64));
wire rgb_val_choice = ndeblur | ~nblured_pixel;

assign {nVSYNC, nCLAMP, nHSYNC, nCSYNC} = S_DBr[1];
assign R_o = rgb_val_choice ? R_DBr[1] : R_DBr[2];
assign G_o = rgb_val_choice ? G_DBr[1] : G_DBr[2];
assign B_o = rgb_val_choice ? B_DBr[1] : B_DBr[2];

endmodule
