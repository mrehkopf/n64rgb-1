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

  `define VDATA_I_FU_SLICE    vdata_width_i-1:0               // full slice
  `define VDATA_I_SY_SLICE  3*color_width_i+3:3*color_width_i // slice sync
  `define VDATA_I_CO_SLICE  3*color_width_i-1:0               // slice color
  `define VDATA_I_RE_SLICE  3*color_width_i-1:2*color_width_i // slice red
  `define VDATA_I_GR_SLICE  2*color_width_i-1:  color_width_i // slice green
  `define VDATA_I_BL_SLICE    color_width_i-1:0               // slice blue

  `define VDATA_O_FU_SLICE    vdata_width_o-1:0
  `define VDATA_O_SY_SLICE  3*color_width_o+3:3*color_width_o 
  `define VDATA_O_CO_SLICE  3*color_width_o-1:0
  `define VDATA_O_RE_SLICE  3*color_width_o-1:2*color_width_o
  `define VDATA_O_GR_SLICE  2*color_width_o-1:  color_width_o
  `define VDATA_O_BL_SLICE    color_width_o-1:0


  `define HSTART_NTSC_240P  11'd240
  `define HSTART_NTSC_480I  11'd230
  `define HSTOP_NTSC        11'd1496

  `define HSTART_PAL_288P   11'd284
  `define HSTART_PAL_576I   11'd278
  `define HSTOP_PAL         11'd1536

  `define HS_WIDTH_NTSC_240P  7'd115
  `define HS_WIDTH_NTSC_480I  7'd111
  `define HS_WIDTH_PAL_288P   7'd124
  `define HS_WIDTH_PAL_576I   7'd121

  `define VS_WIDTH  2'd2

`endif