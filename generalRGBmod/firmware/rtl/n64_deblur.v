//////////////////////////////////////////////////////////////////////////////////
// Company:  Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    n64_deblur
// Project Name:   N64 RGB DAC Mod
// Target Devices: universial
// Tool versions:  Altera Quartus Prime
// Description:    estimates whether N64 uses blur or not
//
// Dependencies: vh/n64rgb_params.vh
//
// Revision: 1.0
//
///////////////////////////////////////////////////////////////////////////////////////////


module n64_deblur (
  nCLK,
  nDSYNC,

  DRV_RST,

  vdata_sync_2pre,
  vdata_pre,
  vdata_cur,

  deblurparams_i,
  deblurparams_o
);

`include "vh/n64rgb_params.vh"

input nCLK;
input nDSYNC;

input DRV_RST;


input             [3:0] vdata_sync_2pre;  // need just sync bits in common order
input [`VDATA_FU_SLICE] vdata_pre;        // whole vector
input [color_width-1:0] vdata_cur;        // current D_i input

input  [6:0] deblurparams_i;  // order: data_cnt,n64_480i,vmode,blurry_pixel_pos,nForceDeBlur,nDeBlurMan
output [1:0] deblurparams_o;  // order: nblank_rgb,ndo_deblur


// some pre-assignments and definitions

wire   [1:0] data_cnt = deblurparams_i[6:5];
wire         n64_480i = deblurparams_i[  4];
wire            vmode = deblurparams_i[  3];
wire blurry_pixel_pos = deblurparams_i[  2];
wire     nForceDeBlur = deblurparams_i[  1];
wire       nDeBlurMan = deblurparams_i[  0];

wire nVSYNC_2pre = vdata_sync_2pre[3];
wire nHSYNC_2pre = vdata_sync_2pre[1];
wire nVSYNC_pre  = vdata_pre[3*color_width+3];
wire nHSYNC_pre  = vdata_pre[3*color_width+1];
wire nCSYNC_pre  = vdata_pre[3*color_width];

wire act_window = &{nVSYNC_2pre,nHSYNC_2pre,nVSYNC_pre,nHSYNC_pre};

wire [color_width-1:0] R_pre = vdata_pre[`VDATA_RE_SLICE];
wire [color_width-1:0] G_pre = vdata_pre[`VDATA_GR_SLICE];
wire [color_width-1:0] B_pre = vdata_pre[`VDATA_BL_SLICE];


// some more definitions for the heuristics

`define CMP_RANGE 6:5 // evaluate gradients in this range (shall include the MSB)

`define TREND_RANGE    8:0      // width of the trend filter
`define NBLUR_TH_BIT   8        // MSB
parameter init_trend = 9'h100;  // initial value (shall have MSB set, zero else)


// start of rtl

`ifdef DEBUG
  parameter init_cnt = 4'hd;            // initial counter value for nblur_est_cnt
  parameter hold_off = 4'h3;            // hold off estimation for x pairs of (non-blur,'blur') pixels
  reg [3:0] nblur_est_cnt  = init_cnt;  // register to estimate whether blur is used or not by the N64
                                        // (if counter saturates, a non-blurred picture is detected)
  reg [3:0] nblur_est_holdoff = 4'h0;   // Holf Off the nblur_est_cnt (removes ripples e.g. due to light effects)
`endif

`ifndef DEBUG
  reg [1:0] nblur_est_cnt     = 2'b00;  // register to estimate whether blur is used or not by the N64
  reg [1:0] nblur_est_holdoff = 2'b00;  // Holf Off the nblur_est_cnt (removes ripples e.g. due to light effects)
`endif

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

    if(~blurry_pixel_pos) begin  // incomming (potential) blurry pixel
                                 // (blurry_pixel_pos changes on next @(negedge nCLK))

      run_estimation[2:1] <= run_estimation[1:0]; // deblur estimation counter is
      run_estimation[0]   <= 1'b1;                // starts a bit delayed in each line

`ifdef DEBUG
      if (|nblur_est_holdoff) // hold_off? if yes, decrement it
        nblur_est_holdoff <= nblur_est_holdoff - 1'b1;
`else
      if (|nblur_est_holdoff) // hold_off? if yes, increment it until overflow back to zero
        nblur_est_holdoff <= nblur_est_holdoff + 1'b1;
`endif


      if (&gradient_changes) begin  // evaluate gradients: &gradient_changes == all color components changed the gradient
`ifdef DEBUG
        if (~|{&nblur_est_cnt,|nblur_est_holdoff})
          nblur_est_cnt <= nblur_est_cnt +1'b1;
        nblur_est_holdoff <= hold_off;
`else
        if (~nblur_est_cnt[1] & ~|nblur_est_holdoff)
          nblur_est_cnt <= nblur_est_cnt +1'b1;
        nblur_est_holdoff <= 2'b01;
`endif
      end

      gradient_changes    <= 2'b00; // reset
    end

    if(~nCSYNC_pre & vdata_cur[0]) begin // negedge at CSYNC detected - new line
      run_estimation    <= 3'b000;
`ifdef DEBUG
      nblur_est_holdoff <= 4'h0;
`else
      nblur_est_holdoff <= 2'b00;
`endif
    end

    if(nVSYNC_pre & ~vdata_cur[3]) begin // negedge at nVSYNC detected - new frame
`ifdef DEBUG
      if(&nblur_est_cnt) begin // add to weight
`else
      if(nblur_est_cnt[1]) begin // add to weight
`endif
        if(~&nblur_n64_trend)
          nblur_n64_trend <= nblur_n64_trend + 1'b1;
      end else begin// subtract
        if(|nblur_n64_trend)
          nblur_n64_trend <= nblur_n64_trend - 1'b1;
      end

      nblur_n64 <= nblur_n64_trend[`NBLUR_TH_BIT];
//      nblur_n64 <= &nblur_est_cnt;

`ifdef DEBUG
      nblur_est_cnt <= init_cnt;
`else
      nblur_est_cnt <= 2'b00;
`endif
    end

  end else if (act_window) begin
    if (blurry_pixel_pos) begin
      case(data_cnt)
          2'b01: gradient[2] <= {R_pre[`CMP_RANGE] < vdata_cur[`CMP_RANGE],
                                 R_pre[`CMP_RANGE] > vdata_cur[`CMP_RANGE]};
          2'b10: gradient[1] <= {G_pre[`CMP_RANGE] < vdata_cur[`CMP_RANGE],
                                 G_pre[`CMP_RANGE] > vdata_cur[`CMP_RANGE]};
          2'b11: gradient[0] <= {B_pre[`CMP_RANGE] < vdata_cur[`CMP_RANGE],
                                 B_pre[`CMP_RANGE] > vdata_cur[`CMP_RANGE]};
      endcase
    end else if (run_estimation[2]) begin
      case(data_cnt)
          2'b01: if (&(gradient[2] ^ {R_pre[`CMP_RANGE] < vdata_cur[`CMP_RANGE],
                                      R_pre[`CMP_RANGE] > vdata_cur[`CMP_RANGE]}))
                   gradient_changes <= 2'b01;
          2'b10: if (&(gradient[1] ^ {G_pre[`CMP_RANGE] < vdata_cur[`CMP_RANGE],
                                      G_pre[`CMP_RANGE] > vdata_cur[`CMP_RANGE]}))
                   gradient_changes <= gradient_changes + 1'b1;
          2'b11: if (&(gradient[0] ^ {B_pre[`CMP_RANGE] < vdata_cur[`CMP_RANGE],
                                      B_pre[`CMP_RANGE] > vdata_cur[`CMP_RANGE]}))
                   gradient_changes <= gradient_changes + 1'b1;
      endcase
    end
  end else begin
    run_estimation  <= 3'b0;
    gradient[2]     <= 2'b0;
    gradient[1]     <= 2'b0;
    gradient[0]     <= 2'b0;
  end
  if (DRV_RST | n64_480i) begin
    nblur_n64_trend <= init_trend;
    nblur_n64       <= 1'b1;
  end
end


// finally the blanking management

wire ndo_deblur = ~nForceDeBlur ?  (n64_480i | nDeBlurMan) :
                                   (n64_480i | nblur_n64);    // force de-blur option for 240p? -> yes: enable it if user wants to | no: enable de-blur depending on estimation

reg nblank_rgb = 1'b1; // blanking of RGB pixels for de-blur

always @(negedge nCLK) begin
  if (~nDSYNC)
    if(ndo_deblur)
      nblank_rgb <= 1'b1;
    else begin 
      if(~nCSYNC_pre & vdata_cur[0]) // posedge nCSYNC -> reset blanking
        nblank_rgb <= vmode;
      else
        nblank_rgb <= ~nblank_rgb;
    end
end


// post-assignment

assign deblurparams_o = {nblank_rgb,ndo_deblur};

endmodule
