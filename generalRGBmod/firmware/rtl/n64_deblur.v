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
// Revision: 1.1
//
//////////////////////////////////////////////////////////////////////////////////


module n64_deblur (
  nCLK,
  nDSYNC,

  nRST,

  vdata_pre,
  vdata_cur,

  deblurparams_i,
  deblurparams_o
);

`include "vh/n64rgb_params.vh"

input nCLK;
input nDSYNC;

input nRST;

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

wire nVSYNC_pre  = vdata_pre[3*color_width+3];
wire nHSYNC_pre  = vdata_pre[3*color_width+1];
wire nCSYNC_pre  = vdata_pre[3*color_width  ];

wire [color_width-1:0] R_pre = vdata_pre[`VDATA_RE_SLICE];
wire [color_width-1:0] G_pre = vdata_pre[`VDATA_GR_SLICE];
wire [color_width-1:0] B_pre = vdata_pre[`VDATA_BL_SLICE];


// some more definitions for the heuristics

`define CMP_RANGE 6:5 // evaluate gradients in this range (shall include the MSB)

`define TREND_RANGE    8:0  // width of the trend filter
`define NBLUR_TH_BIT   8    // MSB

localparam init_trend = 9'h100;  // initial value (shall have MSB set, zero else)


// start of rtl

reg [1:0] nblur_est_cnt     = 2'b00;  // register to estimate whether blur is used or not by the N64
reg [1:0] nblur_est_holdoff = 2'b00;  // Holf Off the nblur_est_cnt (removes ripples e.g. due to light effects)

reg run_estimation = 1'b0;  // do not use first frame after switching to 240p (e.g. from 480i)

reg [1:0] gradient[2:0];  // shows the (sharp) gradient direction between neighbored pixels
                          // gradient[x][1]   = 1 -> decreasing intensity
                          // gradient[x][0]   = 1 -> increasing intensity
                          // else                 -> constant
reg [1:0] gradient_changes = 2'b00;

reg [`TREND_RANGE] nblur_n64_trend = init_trend;  // trend shows if the algorithm tends to estimate more blur enabled rather than disabled
                                                  // this acts as like as a very simple mean filter
reg nblur_n64 = 1'b1;                             // blur effect is estimated to be off within the N64 if value is 1'b1

always @(negedge nCLK) begin // estimation of blur effect
  if (~n64_480i) begin
    if (~nDSYNC) begin
      if(~blurry_pixel_pos) begin  // incomming (potential) blurry pixel
                                 // (blur_pixel_pos changes on next @(negedge nCLK))

        if (|nblur_est_holdoff) // hold_off? if yes, increment it until overflow back to zero
          nblur_est_holdoff <= nblur_est_holdoff + 1'b1;


        if (&gradient_changes) begin  // evaluate gradients: &gradient_changes == all color components changed the gradient
          if (~nblur_est_cnt[1] & ~|nblur_est_holdoff)
            nblur_est_cnt <= nblur_est_cnt +1'b1;
          nblur_est_holdoff <= 2'b01;
        end

        gradient_changes    <= 2'b00; // reset
      end

      if(nHSYNC_pre & ~vdata_cur[1]) begin // negedge at CSYNC detected - new line
        nblur_est_holdoff <= 2'b00;
      end

      if(nVSYNC_pre & ~vdata_cur[3]) begin // negedge at nVSYNC detected - new frame
        if (run_estimation)
          if(nblur_est_cnt[1]) // add to weight
              nblur_n64_trend <= &nblur_n64_trend ? nblur_n64_trend :         // saturate if needed
                                                    nblur_n64_trend + 1'b1;
          else// subtract
              nblur_n64_trend <= |nblur_n64_trend ? nblur_n64_trend - 1'b1 :
                                                    nblur_n64_trend;          // saturate if needed

        nblur_n64     <= nblur_n64_trend[`NBLUR_TH_BIT];
        nblur_est_cnt <= 2'b00;

        run_estimation <= 1'b1;
      end
    end else begin
      if (blurry_pixel_pos) begin
        case(data_cnt)
            2'b01: gradient[2] <= {R_pre[`CMP_RANGE] < vdata_cur[`CMP_RANGE],
                                   R_pre[`CMP_RANGE] > vdata_cur[`CMP_RANGE]};
            2'b10: gradient[1] <= {G_pre[`CMP_RANGE] < vdata_cur[`CMP_RANGE],
                                   G_pre[`CMP_RANGE] > vdata_cur[`CMP_RANGE]};
            2'b11: gradient[0] <= {B_pre[`CMP_RANGE] < vdata_cur[`CMP_RANGE],
                                   B_pre[`CMP_RANGE] > vdata_cur[`CMP_RANGE]};
        endcase
      end else begin
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
    end
  end else begin
    run_estimation <= 1'b0;
  end
  if (~nRST) begin
    nblur_n64_trend <= init_trend;
    nblur_n64       <= 1'b1;
    run_estimation  <= 1'b0;
  end
end


// finally the blanking management

reg ndo_deblur = 1'b1; // force de-blur option for 240p? -> yes: enable it if user wants to | no: enable de-blur depending on estimation

reg nblank_rgb = 1'b1; // blanking of RGB pixels for de-blur

always @(negedge nCLK) begin
  if (~nDSYNC) begin
    if (nVSYNC_pre & ~vdata_cur[3]) begin // negedge at nVSYNC detected - new frame, new setting
      if (nForceDeBlur)
        ndo_deblur <= n64_480i | nblur_n64;
      else
        ndo_deblur <= n64_480i | nDeBlurMan;
    end
    if(ndo_deblur)
      nblank_rgb <= 1'b1;
    else begin 
      if(~nCSYNC_pre & vdata_cur[0]) // posedge nCSYNC -> reset blanking
        nblank_rgb <= vmode;
      else
        nblank_rgb <= ~nblank_rgb;
    end
  end
end


// post-assignment

assign deblurparams_o = {ndo_deblur,nblank_rgb};

endmodule
