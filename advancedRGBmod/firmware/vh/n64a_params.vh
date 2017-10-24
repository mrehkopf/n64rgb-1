/////////////////////////////////////////////////////////////////////////////////
// Company: Circuit-Board.de
// Engineer: borti4938
//
// VH-file Name:   n64a_params
// Project Name:   N64 Advanced RGB Mod
// Target Devices: several devices
// Tool versions:  Altera Quartus Prime
// Description:
//
// Revision: 1.0
//
///////////////////////////////////////////////////////////////////////////////////////////


parameter color_width_i = 7;
parameter color_width_o = 8;

parameter vdata_width_i = 4 + 3*color_width_i;
parameter vdata_width_o = 4 + 3*color_width_o;


`ifndef _n64a_params_vh_
`define _n64a_params_vh_

  `define vdata_i_full    vdata_width_i-1:0
  `define vdata_i_s     3*color_width_i+3:3*color_width_i // just sync area
  `define vdata_i_c     3*color_width_i-1:0               // color area
  `define vdata_i_r     3*color_width_i-1:2*color_width_i // red area
  `define vdata_i_g     2*color_width_i-1:  color_width_i // green area
  `define vdata_i_b       color_width_i-1:0               // blue area

  `define vdata_o_full    vdata_width_o-1:0
  `define vdata_o_s     3*color_width_o+3:3*color_width_o 
  `define vdata_o_c     3*color_width_o-1:0
  `define vdata_o_r     3*color_width_o-1:2*color_width_o
  `define vdata_o_g     2*color_width_o-1:  color_width_o
  `define vdata_o_b       color_width_o-1:0

`endif