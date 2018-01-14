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
// VH-file Name:   n64a_params
// Project Name:   N64 Advanced RGB Mod
// Target Devices: several devices
// Tool versions:  Altera Quartus Prime
// Description:
//
// Revision: 2.0
//
//////////////////////////////////////////////////////////////////////////////////


parameter color_width_i = 7;
parameter color_width_o = 8;

parameter vdata_width_i = 4 + 3*color_width_i;
parameter vdata_width_o = 4 + 3*color_width_o;


`ifndef _n64a_params_vh_
`define _n64a_params_vh_

  // video vector slices and frame definitions
  // =========================================

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


  // N64 controller sniffing
  // =======================

  // controller serial data bits:
  //  0: 7 - A, B, Z, St, Du, Dd, Dl, Dr
  //  8:15 - 'Joystick reset', (0), L, R, Cu, Cd, Cl, Cr
  // 16:23 - X axis
  // 24:31 - Y axis
  // 32    - Stop bit

  // define constants
  // don't edit these constants

  `define A  16'h0001 // button A
  `define B  16'h0002 // button B
  `define Z  16'h0004 // trigger Z
  `define St 16'h0008 // Start button

  `define Du 16'h0010 // D-pad up
  `define Dd 16'h0020 // D-pad down
  `define Dl 16'h0040 // D-pad left
  `define Dr 16'h0080 // D-pad right

  `define L  16'h0400 // shoulder button L
  `define R  16'h0800 // shoulder button R

  `define Cu 16'h1000 // C-button up
  `define Cd 16'h2000 // C-button down
  `define Cl 16'h4000 // C-button left
  `define Cr 16'h8000 // C-button right


  // OSD menu window sizing
  // ======================

  // define font size (every value - 1)
  `define OSD_FONT_WIDTH 3'd7
  `define OSD_FONT_HIGHT 4'd11

  // define text window size (every value - 1)
  `define MAX_CHARS_PER_ROW 6'd47
  `define MAX_TEXT_ROWS     4'd11

  // positioning of OSD window (not linedoubled)
  `define OSD_WINDOW_H_START 10'd128
  `define OSD_WINDOW_H_STOP  10'd527  // 7 pixels left margin + 384 (8x48) pixels free text + 7 pixel right margin + 2 unequality comparision
//  `define OSD_WINDOW_V_START  8'd32
//  `define OSD_WINDOW_V_STOP   8'd227  // 25 lines header + 144 (12x12) lines free text + 25 line footer + 2 unequality comparision
  `define OSD_WINDOW_V_START  8'd50
  `define OSD_WINDOW_V_STOP   8'd209  // 7 lines header + 144 (12x12) lines free text + 7 line footer + 2 unequality comparision


  // define some areas in the OSD windows
  `define OSD_TXT_H_START    10'd135
  `define OSD_TXT_H_STOP     10'd520
  `define OSD_HEADER_V_STOP   8'd57
  `define OSD_FOOTER_V_START  8'd202

  // define OSD background window color
  `define OSD_WINDOW_BG_COLOR 6'b000001

  // define text color
  `define FONTCOLOR_NON          4'h0
  `define FONTCOLOR_WHITE        4'h1
  `define FONTCOLOR_RED          4'h2
  `define FONTCOLOR_GREEN        4'h3
  `define FONTCOLOR_BLUE         4'h4
  `define FONTCOLOR_YELLOW       4'h5
  `define FONTCOLOR_CYAN         4'h6
  `define FONTCOLOR_MAGENTA      4'h7

  `define OSD_TXT_COLOR_WHITE   21'h1FFFFF
  `define OSD_TXT_COLOR_RED     21'h1FC000
  `define OSD_TXT_COLOR_GREEN   21'h003F80
  `define OSD_TXT_COLOR_BLUE    21'h00007F
  `define OSD_TXT_COLOR_YELLOW  21'h1FFF80
  `define OSD_TXT_COLOR_CYAN    21'h003FFF
  `define OSD_TXT_COLOR_MAGENTA 21'h1FC07F


  // In-game reset command
  // =====================

  `define IGR_RESET           (`A + `B + `Z + `St + `R)

`endif