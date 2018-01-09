//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2016-2017 by Peter Bartmann <borti4938@gmx.de>
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
// VH-file Name:   n64a_controller_params
// Project Name:   n64rgb
// Target Devices: several devices
// Tool versions:  Altera Quartus Prime
// Description:
//
// Revision: 1.0
// Features: assign user button combinations for IGR feature
//           define OSD window
//
//////////////////////////////////////////////////////////////////////////////////

`ifndef _n64a_controller_params_vh_
`define _n64a_controller_params_vh_


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
  `define OSD_TXT_COLOR_WHITE   21'h1FFFFF
  `define OSD_TXT_COLOR_RED     21'h1FC000
  `define OSD_TXT_COLOR_GREEN   21'h003F80
  `define OSD_TXT_COLOR_BLUE    21'h00007F
  `define OSD_TXT_COLOR_YELLOW  21'h1FFF80
  `define OSD_TXT_COLOR_CYAN    21'h003FFF
  `define OSD_TXT_COLOR_MAGENTA 21'h1FC07F

`endif

// user definitions:
// - add your button combinations here

parameter igr_reset = `A + `B + `Z + `St + `R;

parameter igr_deblur_off = `Z + `St + `R + `Cl;
parameter igr_deblur_on  = `Z + `St + `R + `Cr;

parameter igr_15bitmode_off = `Z + `St + `R + `Cu;
parameter igr_15bitmode_on  = `Z + `St + `R + `Cd;

parameter cmd_open_osd = `L + `R + `Dr + `Cr;
parameter cmd_close_osd = `L + `R + `Dl + `Cl;