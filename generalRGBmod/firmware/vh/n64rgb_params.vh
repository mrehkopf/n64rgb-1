//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2016-2018 by Peter Bartmann <borti4938@gmx.de>
//
// N64 RGB/YPbPr DAC is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//////////////////////////////////////////////////////////////////////////////////
//
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
//////////////////////////////////////////////////////////////////////////////////


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