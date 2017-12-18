//////////////////////////////////////////////////////////////////////////////////
// Company:  Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    n64_vdemux
// Project Name:   N64 Advanced RGB/YPbPr DAC Mod
// Target Devices: universial
// Tool versions:  Altera Quartus Prime
// Description:    demux the video data from the input data stream
//
// Dependencies: vh/n64a_params.vh
//
// Revision: 1.0
//
///////////////////////////////////////////////////////////////////////////////////////////


module n64_vdemux(
  nCLK,
  nDSYNC,

  D_i,
  demuxparams_i,

  vdata_r_0,
  vdata_r_1
);

`include "vh/n64a_params.vh"

input nCLK;
input nDSYNC;

input  [color_width_i-1:0] D_i;
input  [              4:0] demuxparams_i;

output reg [`VDATA_I_FU_SLICE] vdata_r_0 = {vdata_width_i{1'b0}}; // buffer for sync, red, green and blue
output reg [`VDATA_I_FU_SLICE] vdata_r_1 = {vdata_width_i{1'b0}}; // (unpacked array types in ports requires system verilog)


// unpack deblur info

wire [1:0] data_cnt = demuxparams_i[4:3];
wire ndo_deblur     = demuxparams_i[  2];
wire nblank_rgb     = demuxparams_i[  1];
wire n15bit_mode    = demuxparams_i[  0];

// start of rtl

always @(negedge nCLK) begin // data register management
  if (~nDSYNC) begin
    // shift data to output registers
    if(ndo_deblur)        // deblur inactive
      vdata_r_1[`VDATA_I_FU_SLICE] <= vdata_r_0[`VDATA_I_FU_SLICE];
    else if (nblank_rgb)  // deblur active: pass RGB only if not blanked
      vdata_r_1[`VDATA_I_CO_SLICE] <= vdata_r_0[`VDATA_I_CO_SLICE];

    // get new sync data
    vdata_r_0[`VDATA_I_SY_SLICE] <= D_i[3:0];
  end else begin
    // demux of RGB
    case(data_cnt)
      2'b01: vdata_r_0[`VDATA_I_RE_SLICE] <= n15bit_mode ? D_i : {D_i[6:2], 2'b00};
      2'b10: begin
        vdata_r_0[`VDATA_I_GR_SLICE] <= n15bit_mode ? D_i : {D_i[6:2], 2'b00};
        if(~ndo_deblur)
          vdata_r_1[`VDATA_I_SY_SLICE] <= vdata_r_0[`VDATA_I_SY_SLICE];
      end
      2'b11: vdata_r_0[`VDATA_I_BL_SLICE] <= n15bit_mode ? D_i : {D_i[6:2], 2'b00};
    endcase
  end
end

endmodule