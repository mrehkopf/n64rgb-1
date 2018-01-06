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
// Company:  Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    n64a_controller
// Project Name:   N64 Advanced RGB/YPbPr DAC Mod
// Target Devices: universial (PLL and 50MHz clock required)
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies: vh/n64a_params.vh
//               vh/n64a_controller_params.vh
//               ip/altpll_1.qip
//
// Revision: 1.0
// Features: console reset
//           override heuristic for deblur (resets on each reset and power cycle)
//           activate / deactivate de-blur in 240p (a change overrides heuristic for de-blur)
//           activate / deactivate 15bit mode (no selectable default since 2.6)
//           selectable defaults
//           defaults set on each power cycle and on each reset
//
//////////////////////////////////////////////////////////////////////////////////


module n64a_controller (
  SYS_CLK,
  nRST,

  CTRL,

  DefaultSet,
  ConfigSet,

  nCLK,
  nDSYNC,

  video_data_i,
  video_data_o
);

`include "vh/n64a_params.vh"
`include "vh/n64a_controller_params.vh"


input SYS_CLK;
inout nRST;

input CTRL;

//input  [ 7:0] DefaultSet;
input  [ 5:0] DefaultSet;
output [11:0] ConfigSet;

input nCLK;
input nDSYNC;

input      [`VDATA_I_FU_SLICE] video_data_i;
output reg [`VDATA_I_FU_SLICE] video_data_o;


// some pre-assignments

//wire       UseVGA_HVSync = DefaultSet[7];
//wire       nFilterBypass = DefaultSet[6];
wire       nEN_RGsB      = DefaultSet[5];
wire       nEN_YPbPr     = DefaultSet[4];
wire [1:0] SL_str        = DefaultSet[3:2];
wire       n240p         = DefaultSet[1];
wire       n480i_bob     = DefaultSet[0];


// start of rtl


// Part 0: Debug probes and sources
// ================================

wire [2:0] Linedoubler_debug;
source_3bit_0 Linedoubler_debug_src(
  .source(Linedoubler_debug)
);

// bit assignment for Linedoubler_debug[2:0]:
// 2 - 0 = use J4 setting         | 1 = use debug setting
// 1 - 0 = disable lineX2         | 1 = enable lineX2
// 0 - 0 = enable 480i bob-deint. | 1 = output 480i


wire [2:0] SL_debug;
source_3bit_0 scanline_debug_src(
  .source(SL_debug)
);

// bit assignment for SL_debug[2:0]:
// 2   - 0 = use J3 setting | 1 = use debug setting
// 1:0 - Scanline strength (00, 01, 10, 11 = 100%, 50%, 25%, 0%)


wire [2:0] Vidout_debug;
source_3bit_0 Vidout_debug_src(
  .source(Vidout_debug)
);

// bit assignment for Vidout_debug[2:0]:
// 2 - 0 = use J2 setting | 1 = use debug setting
// 1 - 0 = enable RGsB    | 1 = disable RGsB
// 0 - 0 = enable YPbPr   | 1 = disable YPbPr (beats RGsB)



wire [2:0] gamma_debug;
source_3bit_0 gamma_debug_src(
  .source(gamma_debug)
);

// bit assignment for gamma_debug[2:0]:
// 2   - use gamma table (don't use gamma table means gamma = 1.0)
// 1:0 - 00 = 0.8
//       01 = 0.9
//       10 = 1.1
//       11 = 1.2



wire [2:0] DeBlur_15bitmode_debug;
source_3bit_0 DeBlur_15bitmode_debug_src(
  .source(DeBlur_15bitmode_debug)
);

// bit assignment for DeBlur_15bitmode_debug[2:0]:
// 2 - 0 = use IGR setting | 1 = use debug setting
// 1 - 0 = force de-blur   | 1 = don't use de-blur (replaces nDeBlurMan)
// 0 - 0 = 15bit mode      | 1 = 21bit mode        (replaces n15bit_mode)

// Part 1: Connect PLL
// ===================

wire CLK_4M, CLK_16k;

altpll_1 sys_pll(
  .inclk0(SYS_CLK),
  .c0(CLK_4M),
  .c1(CLK_16k)
);


// Part 2: Controller Sniffing
// ===========================

reg [1:0] read_state  = 2'b0; // state machine

parameter ST_WAIT4N64 = 2'b00; // wait for N64 sending request to controller
parameter ST_N64_RD   = 2'b01; // N64 request sniffing
parameter ST_CTRL_RD  = 2'b10; // controller response

reg [3:0] sampling_point_n64  = 4'h8; // wait_cnt increased a few times since neg. edge -> sample data
reg [3:0] sampling_point_ctrl = 4'h8; // (9 by default -> delay somewhere around 2.25us)

reg        prev_ctrl    =  1'b1;
reg [11:0] wait_cnt     = 12'b0; // counter for wait state (needs appr. 1.0ms at CLK_4M clock to fill up from 0 to 4095)

reg [15:0] data_stream      = 16'b0;
reg  [3:0] data_cnt         =  4'h0;

reg initiate_nrst = 1'b0;

reg nfirstboot = 1'b0;

reg show_osd = 1'b0;

reg nDeBlurMan   = 1'b1;
reg nForceDeBlur = 1'b1;
reg n15bit_mode  = 1'b1;

reg UseJumperSet = 1'b1;


// controller data bits:
//  0: 7 - A, B, Z, St, Du, Dd, Dl, Dr
//  8:15 - 'Joystick reset', (0), L, R, Cu, Cd, Cl, Cr
// 16:23 - X axis
// 24:31 - Y axis
// 32    - Stop bit
// (bits[0:15] used here)

always @(posedge CLK_4M) begin
  case (read_state)
    ST_WAIT4N64:
      if (&wait_cnt) begin // waiting duration ends (exit wait state only if CTRL was high for a certain duration)
        read_state    <= ST_N64_RD;
        data_stream   <= 16'h0000;
        data_cnt      <=  4'h0;
        initiate_nrst <=  1'b0;
      end
    ST_N64_RD: begin
      if (wait_cnt[7:0] == {4'h0,sampling_point_n64}) begin // sample data
        if (data_cnt[3]) // eight bits read
          if (data_stream[13:6] == 8'b00000001 & CTRL) begin // check command and stop bit
          // trick: the 2 LSB command bits lies where controller produces unused constant values
          //         -> (hopefully) no exchange with controller response
            read_state  <= ST_CTRL_RD;
            data_stream <= 16'h0000;
            data_cnt    <=  4'h0;
          end else
            read_state  <= ST_WAIT4N64;
        else begin
          data_stream[13:7] <= data_stream[12:6];
          data_stream[6]    <= CTRL;
          data_cnt          <= data_cnt + 1'b1;
        end
      end
      if (&{prev_ctrl,~CTRL,|data_cnt})
        sampling_point_n64 <= wait_cnt[4:1];
    end
    ST_CTRL_RD: begin
      if (wait_cnt[7:0] == {4'h0,sampling_point_ctrl}) begin // sample data
        if (&data_cnt) begin // sixteen bits read (analog values of stick not point of interest)
          if ({data_stream[14:0], CTRL} == igr_deblur_off) begin // defined button combination pressed
            nForceDeBlur <= 1'b0;
            nDeBlurMan   <= 1'b1;
          end
          if ({data_stream[14:0], CTRL} == igr_deblur_on) begin // defined button combination pressed
            nForceDeBlur <= 1'b0;
            nDeBlurMan   <= 1'b0;
          end
          if ({data_stream[14:0], CTRL} == igr_15bitmode_off) begin // defined button combination pressed
            n15bit_mode  <= 1'b1;
          end
          if ({data_stream[14:0], CTRL} == igr_15bitmode_on) begin // defined button combination pressed
            n15bit_mode  <= 1'b0;
          end
          if ({data_stream[14:0], CTRL} == cmd_open_osd) begin // defined button combination pressed
            show_osd  <= 1'b1;
          end
          if ({data_stream[14:0], CTRL} == cmd_close_osd) begin // defined button combination pressed
            show_osd  <= 1'b0;
          end
          if ({data_stream[14:0], CTRL} == igr_reset) // defined button combination pressed
            initiate_nrst <= 1'b1;
          read_state  <= ST_WAIT4N64;
        end else begin
          data_stream[15:1] <= data_stream[14:0];
          data_stream[0]    <= CTRL;
          data_cnt          <= data_cnt + 1'b1;
        end
      end
      if (&{prev_ctrl,~CTRL,|data_cnt})
        sampling_point_ctrl <= wait_cnt[4:1];
    end
    default: read_state <= ST_WAIT4N64;
  endcase


  if (prev_ctrl & ~CTRL) // counter resets on neg. edge
    wait_cnt <= 12'h000;
  else if (~&wait_cnt) // saturate counter if needed
    wait_cnt <= wait_cnt + 1'b1;

  prev_ctrl <= CTRL;

  if (nRST == 1'b0) begin
    nForceDeBlur <= 1'b1;

    read_state    <= ST_WAIT4N64;
    wait_cnt      <= 12'h000;
    prev_ctrl     <=  1'b1;
    initiate_nrst <=  1'b0;
  end

  if (~nfirstboot) begin
    nfirstboot   <= 1'b1;
    nDeBlurMan   <= 1'b0;
    nForceDeBlur <= 1'b1;

    UseJumperSet <= nRST;  // fallback if reset pressed on power cycle
  end
end



// Part 3: Trigger Reset on Demand
// ===============================

reg        drv_rst =  1'b0;
reg [9:0] rst_cnt = 10'b0; // ~64ms are needed to count from max downto 0 with CLK_16k.

always @(posedge CLK_16k) begin
  if (initiate_nrst == 1'b1) begin
    drv_rst <= 1'b1;      // reset system
    rst_cnt <= 10'h3ff;
  end else if (|rst_cnt) // decrement as long as rst_cnt is not zero
    rst_cnt <= rst_cnt - 1'b1;
  else
    drv_rst <= 1'b0; // end of reset
end

assign nRST = drv_rst ? 1'b0 : 1'bz;wire nHSYNC_cur = video_data_i[3*color_width_i+1];


// Part 4: Display OSD Menu
// ========================

// concept:
// - OSD is virtual screen of size 128x384 pixel each 3bit to define off and seven colors.
// - content is mapped into memory; for simplicity each pixel element has 2 bits: '00' for not set and a color else
// - each pixel of virtual screen is written by NIOSII processor

wire [15:0] txt_wraddr;
wire [ 1:0] txt_wrctrl;
wire [ 2:0] txt_wrdata;


system system_u(
  .clk_clk(SYS_CLK),
  .reset_reset_n(nRST),
  .txt_wraddr_export(txt_wraddr),
  .txt_wrctrl_export(txt_wrctrl),
  .txt_wrdata_export(txt_wrdata)
);

wire nVSYNC_cur = video_data_i[3*color_width_i+3];

reg nHSYNC_pre = 1'b0;
reg nVSYNC_pre = 1'b0;

reg [9:0] h_cnt = 10'h0;
reg [7:0] v_cnt =  8'h0;

reg [2:0] draw_osd_window = 3'b000;
reg [2:0]        en_txtrd = 3'b000;

reg [9:0] txt_xrdaddr = 9'h0;
reg [6:0] txt_yrdaddr = 7'h0;

always @(negedge nCLK) begin
  if (~nDSYNC) begin
    h_cnt <= ~&h_cnt ? h_cnt + 1'b1 : h_cnt;

    if (nHSYNC_pre & ~nHSYNC_cur) begin
      h_cnt <= 10'h0;
      v_cnt <= ~&v_cnt ? v_cnt + 1'b1 : v_cnt;
      if (v_cnt <= `OSD_HEADER_V_STOP)
        txt_yrdaddr <= 7'h0;
      else
        txt_yrdaddr <= ~&txt_yrdaddr ? txt_yrdaddr + 1'b1 : txt_yrdaddr;
    end
    if (nVSYNC_pre & ~nVSYNC_cur)
      v_cnt <= 8'h0;

    if (en_txtrd[0])
      txt_xrdaddr <= ~&txt_xrdaddr ? txt_xrdaddr + 1'b1 : txt_xrdaddr;
    else
      txt_xrdaddr <= 9'h0;

    nHSYNC_pre <= nHSYNC_cur;
    nVSYNC_pre <= nVSYNC_cur;
  end

  draw_osd_window[2:1] <= draw_osd_window[1:0];
  draw_osd_window[  0] <= (h_cnt > `OSD_WINDOW_H_START) && (h_cnt < `OSD_WINDOW_H_STOP) &&
                          (v_cnt > `OSD_WINDOW_V_START) && (v_cnt < `OSD_WINDOW_V_STOP);

  en_txtrd[2:1] <= en_txtrd[1:0];
  en_txtrd[  0] <=(h_cnt > `OSD_TXT_H_START)   && (h_cnt < `OSD_TXT_H_STOP)     &&
                  (v_cnt > `OSD_HEADER_V_STOP) && (v_cnt < `OSD_FOOTER_V_START);
  if (~nRST) begin
    h_cnt <= 10'h0;
    v_cnt <=  8'h0;

    draw_osd_window <= 1'b0;

    en_txtrd    <= 3'b000;
    txt_xrdaddr <= 9'h0;
    txt_yrdaddr <= 7'h0;
  end
end

wire [1:0] txt_data;

ram2port_1 virt_display_u(
  .data(txt_wrdata),
  .rd_aclr(txt_wrctrl[1]),
  .rdaddress({txt_xrdaddr,txt_yrdaddr}),
  .rdclock(~nCLK),
  .rden(en_txtrd[0]),
  .wraddress(txt_wraddr),
  .wrclock(SYS_CLK),
  .wren(txt_wrctrl[0]),
  .q(txt_data));

wire [5:0] window_bg_color = `OSD_WINDOW_BG_COLOR;

wire [`VDATA_I_CO_SLICE] txt_color = (txt_data == 3'b001) ? `OSD_TXT_COLOR_WHITE  :
                                     (txt_data == 3'b010) ? `OSD_TXT_COLOR_RED    :
                                     (txt_data == 3'b011) ? `OSD_TXT_COLOR_GREEN  :
                                     (txt_data == 3'b100) ? `OSD_TXT_COLOR_BLUE   :
                                     (txt_data == 3'b101) ? `OSD_TXT_COLOR_YELLOW :
                                     (txt_data == 3'b110) ? `OSD_TXT_COLOR_CYAN   :
                                                            `OSD_TXT_COLOR_MAGENTA;

always @(negedge nCLK) begin
  // pass through sync
  video_data_o[`VDATA_I_SY_SLICE] <= video_data_i[`VDATA_I_SY_SLICE];

  // draw menu window if needed
  if (show_osd & draw_osd_window[2]) begin
    if (en_txtrd[2] & |txt_data) begin
      video_data_o[`VDATA_I_CO_SLICE] <= txt_color;
    end else begin
    // modify red
      video_data_o[3*color_width_i-1:3*color_width_i-2] <= window_bg_color[5:4];
      video_data_o[3*color_width_i-3:2*color_width_i]   <= video_data_i[3*color_width_i-1:2*color_width_i+2];
    // modify green
      video_data_o[2*color_width_i-1:2*color_width_i-2] <= window_bg_color[3:2];
      video_data_o[2*color_width_i-3:  color_width_i]   <= video_data_i[2*color_width_i-1:color_width_i+2];
    // modify blue
      video_data_o[color_width_i-1:color_width_i-2] <= window_bg_color[1:0];
      video_data_o[color_width_i-3:              0] <= video_data_i[color_width_i-1:2];
    end
  end else begin
    video_data_o[`VDATA_I_CO_SLICE] <= video_data_i[`VDATA_I_CO_SLICE];
  end
end




// some post-assignments

// fallback mode
// .............

wire n240p_active     = UseJumperSet ? n240p     : 1'b0;  // fallback only to 240p and RGB
wire nEN_YPbPr_active = UseJumperSet ? nEN_YPbPr : 1'b1;  // (sync output on G/Y in any case to see at least something even with a component cable)


// debug sources
// .............

wire     cfg_n240p = Linedoubler_debug[2] ? Linedoubler_debug[1] : n240p_active;
wire cfg_n480i_bob = Linedoubler_debug[2] ? Linedoubler_debug[0] : n480i_bob;

wire [1:0] cfg_SL_str = SL_debug[2] ? SL_debug[1:0] : SL_str;

wire cfg_nEN_RGsB  = Vidout_debug[2] ? Vidout_debug[1] : (nEN_RGsB & nEN_YPbPr);
wire cfg_nEN_YPbPr = Vidout_debug[2] ? Vidout_debug[0] : nEN_YPbPr_active;

wire [2:0] cfg_gamma = gamma_debug;

wire cfg_nForceDeBlur = DeBlur_15bitmode_debug[2] ? 1'b0 : nForceDeBlur;
wire cfg_nDeBlurMan   = DeBlur_15bitmode_debug[2] ? DeBlur_15bitmode_debug[1] : nDeBlurMan;
wire cfg_n15bit_mode  = DeBlur_15bitmode_debug[2] ? DeBlur_15bitmode_debug[0] : n15bit_mode;

// finally
// .......

assign ConfigSet = {cfg_nDeBlurMan,cfg_nForceDeBlur,cfg_n15bit_mode,cfg_gamma,cfg_nEN_RGsB,cfg_nEN_YPbPr,cfg_SL_str,cfg_n240p,cfg_n480i_bob};


endmodule
