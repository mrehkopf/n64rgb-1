//////////////////////////////////////////////////////////////////////////////////
// Company: Circuit-Board.de
// Engineer: borti4938
//
// VH-file Name:   igr_params
// Project Name:   n64rgb
// Target Devices: several MaxII & MaxV devices
// Tool versions:  Altera Quartus Prime
// Description:
//
// Revision: 1.0
// Features: assign user button combinations for IGR feature
//           edit only lines from line 50 on
//
///////////////////////////////////////////////////////////////////////////////////////////

`ifndef _igr_params_vh_
`define _igr_params_vh_


// controller data bits:
//  0: 7 - A, B, Z, St, Du, Dd, Dl, Dr
//  8:15 - 'Joystick reset', (0), L, R, Cu, Cd, Cl, Cr
// 16:23 - X axis
// 24:31 - Y axis
// 32    - Stop bit
// (bits[0:15] used here)

// define constants
// don't edit these constants

`define A  16'h8000 // button A
`define B  16'h4000 // button B
`define Z  16'h2000 // trigger Z
`define St 16'h1000 // Start button

`define Du 16'h0800 // D-pad up
`define Dd 16'h0400 // D-pad down
`define Dl 16'h0200 // D-pad left
`define Dr 16'h0100 // D-pad right

`define L  16'h0020 // shoulder button L
`define R  16'h0010 // shoulder button R

`define Cu 16'h0008 // C-button up
`define Cd 16'h0004 // C-button down
`define Cl 16'h0002 // C-button left
`define Cr 16'h0001 // C-button right

// user definitions:
// - add your button combinations here

parameter igr_reset = `A + `B + `Dd + `Dr + `L + `R;

parameter igr_deblur_off = `Dl + `L + `R + `Cl;
parameter igr_deblur_on  = `Dr + `L + `R + `Cr;

parameter igr_15bitmode_off = `Du + `L + `R + `Cu;
parameter igr_15bitmode_on  = `Dd + `L + `R + `Cd;

`ifdef OPTION_INVLPF
  parameter igr_toggle_LPF = `Du + `Dl + `L + `R + `Cu + `Cr;
`endif

`endif