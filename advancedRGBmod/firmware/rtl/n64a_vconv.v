//////////////////////////////////////////////////////////////////////////////////
// Company:  Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    n64a_vconv
// Project Name:   N64 Advanced RGB Mod
// Target Devices: Max10, Cyclone IV and Cyclone 10 LP devices
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies: vh/n64a_params.vh
//               ip/altmult_add3_0.qip
//               ip/altmult_add2_0.qip
//
// Revision: 1.0
// Features: conversion RGB to YPbPr on demand
//           outputs 8bit vectors for ADV7125 / ADV7123
//
///////////////////////////////////////////////////////////////////////////////////////////

module n64a_vconv(
  nCLK,

  nEN_YPbPr,    // enables color transformation on '0'

  vdata_i,
  vdata_o
);

`include "vh/n64a_params.vh"

localparam coeff_width = 20;


input nCLK;

input nEN_YPbPr;

input  [`vdata_o_full] vdata_i;
output [`vdata_o_full] vdata_o;


// pre-assignments

wire                        [3:0] S_i = vdata_i[`vdata_o_s];
wire unsigned [color_width_o-1:0] R_i = vdata_i[`vdata_o_r];
wire unsigned [color_width_o-1:0] G_i = vdata_i[`vdata_o_g];
wire unsigned [color_width_o-1:0] B_i = vdata_i[`vdata_o_b];

reg                        [3:0]  S_o = 4'h0;
reg unsigned [color_width_o-1:0] V1_o = {color_width_o{1'b0}};
reg unsigned [color_width_o-1:0] V2_o = {color_width_o{1'b0}};
reg unsigned [color_width_o-1:0] V3_o = {color_width_o{1'b0}};


// start of rtl

// delay Sync along with the pipeline stages of the video conversion

reg [3:0] S[0:2];
reg [color_width_o-1:0] R[0:2], B[0:2];

integer i;
initial begin
  for (i = 0; i < 3; i = i+1) begin
    S[i] = 4'h0;
    R[i] = {color_width_o{1'b0}};
    B[i] = {color_width_o{1'b0}};
  end
end

always @(negedge nCLK) begin
  for (i = 1; i < 3; i = i+1) begin
    S[i] <= S[i-1];
    R[i] <= R[i-1];
    B[i] <= B[i-1];
  end

  S[0] <= S_i;
  R[0] <= R_i;
  B[0] <= B_i;
end


// Transformation to YPbPr
// =======================

// Transformation Rec. 601:
// Y  =  0.299    R + 0.587    G + 0.114   B
// Pb = -0.168736 R - 0.331264 G + 0.5     B + 2^9
// Pr =       0.5 R - 0.418688 G - 0.08132 B + 2^9

localparam msb_vo = color_width_o+coeff_width-1;  // position of MSB after altmult_add (Pb and Pr neg. parts are shifted to that)
localparam lsb_vo = coeff_width;                // position of LSB after altmult_add (Pb and Pr neg. parts are shifted to that)


wire [color_width_o+coeff_width+1:0] Y_addmult;
localparam fyr = 20'd313524;
localparam fyg = 20'd615514;
localparam fyb = 20'd119538;

altmult_add3_0 calcY(
  .clock0(~nCLK),
  .dataa_0(R_i),
  .dataa_1(G_i),
  .dataa_2(B_i),
  .datab_0(fyr),
  .datab_1(fyg),
  .datab_2(fyb),
  .result(Y_addmult)
);



wire [color_width_o+coeff_width:0] Pb_nPart_addmult;
localparam fpbr = 20'd353865;
localparam fpbg = 20'd694711;

altmult_add2_0 calcPb_nPart(
  .clock0(~nCLK),
  .dataa_0(R_i),
  .dataa_1(G_i),
  .datab_0(fpbr),
  .datab_1(fpbg),
  .result(Pb_nPart_addmult)
);

wire [color_width_o+1:0] Pb_addmult = {1'b0,B[2],1'b0}- Pb_nPart_addmult[msb_vo+1:lsb_vo-1];

wire [color_width_o+coeff_width:0] Pr_nPart_addmult;
localparam fprg = 20'd878052;
localparam fprb = 20'd170524;

altmult_add2_0 calcPr_nPart(
  .clock0(~nCLK),
  .dataa_0(G_i),
  .dataa_1(B_i),
  .datab_0(fprg),
  .datab_1(fprb),
  .result(Pr_nPart_addmult)
);

wire [color_width_o+1:0] Pr_addmult = {1'b0,R[2],1'b0}- Pr_nPart_addmult[msb_vo+1:lsb_vo-1];


// get final results:

wire [color_width_o-1:0]  Y_tmp =  Y_addmult[msb_vo:lsb_vo] +  Y_addmult[lsb_vo-1];
wire [color_width_o  :0] Pb_tmp = Pb_addmult[color_width_o+1:1] + Pb_addmult[0];
wire [color_width_o  :0] Pr_tmp = Pr_addmult[color_width_o+1:1] + Pr_addmult[0];


always @(negedge nCLK) begin
  if (~nEN_YPbPr) begin
     S_o <= S[2];
    V1_o <= {~Pr_tmp[color_width_o],Pr_tmp[color_width_o-1:1]};
    V2_o <= Y_tmp;
    V3_o <= {~Pb_tmp[color_width_o],Pb_tmp[color_width_o-1:1]};
  end else begin
     S_o <= S_i;
    V1_o <= R_i;
    V2_o <= G_i;
    V3_o <= B_i;
  end
end


// post-assignment

assign vdata_o = {S_o,V1_o,V2_o,V3_o};

endmodule 