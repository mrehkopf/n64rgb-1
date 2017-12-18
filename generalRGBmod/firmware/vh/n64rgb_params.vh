/////////////////////////////////////////////////////////////////////////////////
// Company: Circuit-Board.de
// Engineer: borti4938
//
// VH-file Name:   n64rgb_params
// Project Name:   N64 RGB DAC Mod
// Target Devices: several devices
// Tool versions:  Altera Quartus Prime
// Description:
//
// Revision: 1.0
//
///////////////////////////////////////////////////////////////////////////////////////////


parameter color_width = 7;

parameter vdata_width = 4 + 3*color_width;


`ifndef _n64rgb_params_vh_
`define _n64rgb_params_vh_

  `define VDATA_FU_SLICE    vdata_width-1:0             // full slice
  `define VDATA_SY_SLICE  3*color_width+3:3*color_width // slice sync
  `define VDATA_CO_SLICE  3*color_width-1:0             // slice color
  `define VDATA_RE_SLICE  3*color_width-1:2*color_width // slice red
  `define VDATA_GR_SLICE  2*color_width-1:  color_width // slice green
  `define VDATA_BL_SLICE    color_width-1:0             // slice blue

`endif