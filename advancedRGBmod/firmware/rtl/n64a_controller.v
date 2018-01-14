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
//           OSD menu (NIOSII driven)
//
//////////////////////////////////////////////////////////////////////////////////


module n64a_controller (
  SYS_CLK,
  nRST,

  CTRL,

  InfoSet,
  DefaultConfigSet,
  ConfigSet,

  nCLK,
  nDSYNC,

  video_data_i,
  video_data_o
);

`include "vh/n64a_params.vh"


input SYS_CLK;
inout nRST;

input CTRL;

input      [ 4:0] InfoSet;
input      [ 5:0] DefaultConfigSet;
output reg [11:0] ConfigSet;

input nCLK;
input nDSYNC;

input      [`VDATA_I_FU_SLICE] video_data_i;
output reg [`VDATA_I_FU_SLICE] video_data_o;


// start of rtl


// Part 1: Connect PLL
// ===================

wire CLK_4M, CLK_16k, CLK_100M, PLL_LOCKED;

altpll_1 sys_pll(
  .inclk0(SYS_CLK),
  .c0(CLK_4M),
  .c1(CLK_16k),
  .c2(CLK_100M),
  .locked(PLL_LOCKED)
);

wire nRST_pll = nRST & PLL_LOCKED;


// Part 2: Instantiate NIOS II
// ===========================


reg newpowercycle = 1'b1;
reg FallbackMode  = 1'b0;

always @(posedge CLK_16k) begin
  if (PLL_LOCKED) begin
    if (nRST)
      newpowercycle <= 1'b0;
    else
      FallbackMode <= newpowercycle;  // reset pressed during new power cycle
                                      // -> activate fallback mode
  end
end

wire [ 9:0] vd_wraddr;
wire [ 1:0] vd_wrctrl;
wire [12:0] vd_wrdata;

wire [15:0] SysConfigSet;

system system_u(
  .clk_clk(CLK_100M),
  .reset_reset_n(nRST_pll),
  .vd_wraddr_export(vd_wraddr),
  .vd_wrctrl_export(vd_wrctrl),
  .vd_wrdata_export(vd_wrdata),
  .ctrl_data_in_export({ctrl_analog_data,ctrl_digital_data[1]}),
  .default_cfg_set_in_export(DefaultConfigSet),
  .cfg_set_out_export(SysConfigSet),
  .info_set_in_export({InfoSet,FallbackMode})
);

wire show_osd = SysConfigSet[13];
wire use_igr  = SysConfigSet[12];

always @(negedge nCLK) begin
  if (&{~nDSYNC,nVSYNC_pre,~nVSYNC_cur} | ~nRST)
    ConfigSet <= SysConfigSet[11:0];
//    ConfigSet <= {cfg_nDeBlurMan,cfg_nForceDeBlur,cfg_n15bit_mode,cfg_gamma,cfg_nEN_RGsB,cfg_nEN_YPbPr,cfg_SL_str,cfg_n240p,cfg_n480i_bob};
end


// Part 3: Controller Sniffing
// ===========================

reg [1:0]      rd_state  = 2'b0; // state machine
reg [1:0] next_rd_state  = 2'b0; // next state

parameter ST_WAIT4N64 = 2'b00; // wait for N64 sending request to controller
parameter ST_N64_RD   = 2'b01; // N64 request sniffing
parameter ST_CTRL_RD  = 2'b10; // controller response

reg [9:0] sampling_point_cnt  = 10'h0;  // used to estimated new sampling point
reg [3:0] sampling_point_n64  =  4'h8;  // wait_cnt increased a few times since neg. edge -> sample data
reg [3:0] sampling_point_ctrl =  4'h8;  // (9 by default -> delay somewhere around 2.25us)

reg        prev_ctrl    =  1'b1;
reg [11:0] wait_cnt     = 12'b0; // counter for wait state (needs appr. 1.0ms at CLK_4M clock to fill up from 0 to 4095)

reg [31:0] serial_data      = 32'h0;
reg [ 5:0] ctrl_data_cnt    =  6'h0;
reg        new_ctrl_data    =  1'b0;
reg [15:0] ctrl_analog_data = 16'h0;
reg [15:0] ctrl_digital_data[0:1];

initial begin
  ctrl_digital_data[0] = 16'h0;
  ctrl_digital_data[1] = 16'h0;
end

wire [15:0] ctrl_digital_data_deglitched = ((ctrl_digital_data[1] & ctrl_digital_data[0]) |
                                            (ctrl_digital_data[1] & serial_data[15:0]   ) |
                                            (ctrl_digital_data[0] & serial_data[15:0]   ));

reg initiate_nrst = 1'b0;


// controller data bits:
//  0: 7 - A, B, Z, St, Du, Dd, Dl, Dr
//  8:15 - 'Joystick reset', (0), L, R, Cu, Cd, Cl, Cr
// 16:23 - X axis
// 24:31 - Y axis
// 32    - Stop bit

always @(posedge CLK_4M) begin
  case (rd_state)
    ST_WAIT4N64:
      if (&wait_cnt) begin // waiting duration ends (exit wait state only if CTRL was high for a certain duration)
        next_rd_state <= ST_N64_RD;
        serial_data   <= 32'h0;
        ctrl_data_cnt <=  6'h0;
      end
    ST_N64_RD: begin
      if (wait_cnt[7:0] == {4'h0,sampling_point_n64}) begin // sample data
        if (ctrl_data_cnt[3]) // eight bits read
          if (CTRL & (serial_data[29:22] == 8'b10000000)) begin // check command and stop bit
          // trick: the 2 LSB command bits lies where controller produces unused constant values
          //         -> (hopefully) no exchange with controller response
            next_rd_state <= ST_CTRL_RD;
            serial_data   <= 32'h0;
            ctrl_data_cnt <=  6'h0;
          end else
            next_rd_state <= ST_WAIT4N64;
        else begin
          serial_data[29:22] <= {CTRL,serial_data[29:23]};
          ctrl_data_cnt      <= ctrl_data_cnt + 1'b1;
        end
      end
    end
    ST_CTRL_RD: begin
      if (wait_cnt[7:0] == {4'h0,sampling_point_ctrl}) begin // sample data
        if (ctrl_data_cnt[5]) begin // thirtytwo bits read
          next_rd_state <= ST_WAIT4N64;
          new_ctrl_data <= CTRL; // stop bit must be '1'
        end else begin
          serial_data   <= {CTRL,serial_data[31:1]};
          ctrl_data_cnt <= ctrl_data_cnt + 1'b1;
        end
      end
    end
    default: next_rd_state <= ST_WAIT4N64;
  endcase

  if (prev_ctrl & ~CTRL) begin    // counter resets on neg. edge
    rd_state <= next_rd_state;
    wait_cnt <= 12'h000;
    if (|next_rd_state) begin     // following statements not applied to ST_WAIT4N64
      if (~|ctrl_data_cnt)
        sampling_point_cnt <= 10'h0;
      else if (ctrl_data_cnt[3] & (rd_state == ST_N64_RD))
        sampling_point_n64 <= sampling_point_cnt[7:4];
      else if (ctrl_data_cnt[5] & (rd_state == ST_CTRL_RD))
        sampling_point_ctrl <= sampling_point_cnt[9:6];
    end
  end else begin
    if (~&wait_cnt) begin  // saturate counter if needed
      wait_cnt <= wait_cnt + 1'b1;
    end else begin                  // counter saturated
      rd_state <= ST_WAIT4N64;
      wait_cnt <= 12'h000;
    end
    
    if (~&sampling_point_cnt)
      sampling_point_cnt <= sampling_point_cnt + 1'b1;
  end

  prev_ctrl <= CTRL;

  if (new_ctrl_data) begin
    new_ctrl_data <= 1'b0;

    ctrl_analog_data     <= serial_data[31:16];
    ctrl_digital_data[1] <= ctrl_digital_data_deglitched;
    ctrl_digital_data[0] <= serial_data[15: 0];
    
    if (use_igr & (ctrl_digital_data[1][15:0] == `IGR_RESET))
      initiate_nrst <= 1'b1;
  end

  if (!nRST_pll) begin
    rd_state      <= ST_WAIT4N64;
    wait_cnt      <= 12'h000;
    prev_ctrl     <=  1'b1;
    initiate_nrst <=  1'b0;

    new_ctrl_data <=  1'b0;

    ctrl_analog_data     <= 16'h0;
    ctrl_digital_data[0] <= 16'h0;
    ctrl_digital_data[1] <= 16'h0;
  end
end



// Part 4: Trigger Reset on Demand
// ===============================

reg       drv_rst =  1'b0;
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

assign nRST = drv_rst ? 1'b0 : 1'bz;


// Part 5: Display OSD Menu
// ========================

// concept:
// - OSD is virtual screen of size 12x48 chars; each char stored in 2bit color + 8bit ASCCI-code.
//   (for simplicity atm. RAM has 48x16 words)
// - content is mapped into memory and written by NIOSII processor
// - Font is looked up in an extra ROM


wire nHSYNC_cur = video_data_i[3*color_width_i+1];
wire nVSYNC_cur = video_data_i[3*color_width_i+3];

reg nHSYNC_pre = 1'b0;
reg nVSYNC_pre = 1'b0;

reg [9:0] h_cnt = 10'h0;
reg [7:0] v_cnt =  8'h0;

reg [8:0] txt_h_cnt = 9'h0;
reg [7:0] txt_v_cnt = 8'h0;

reg [4:0] draw_osd_window = 5'b00000;
reg [4:0]        en_txtrd = 5'b00000;

always @(negedge nCLK) begin
  if (~nDSYNC) begin
    h_cnt <= ~&h_cnt ? h_cnt + 1'b1 : h_cnt;

    if (nHSYNC_pre & ~nHSYNC_cur) begin
      h_cnt <= 10'h0;
      v_cnt <= ~&v_cnt ? v_cnt + 1'b1 : v_cnt;
      if (v_cnt <= `OSD_HEADER_V_STOP | v_cnt >= `OSD_FOOTER_V_START) begin
        txt_v_cnt <= 7'h0;
      end else if (~&txt_v_cnt[7:4]) begin
        if (txt_v_cnt[3:0] == `OSD_FONT_HIGHT) begin
          txt_v_cnt[3:0] <= 4'h0;
          txt_v_cnt[7:4] <= txt_v_cnt[7:4] + 1'b1;
        end else
          txt_v_cnt <= txt_v_cnt + 1'b1;
      end
    end
    if (nVSYNC_pre & ~nVSYNC_cur)
      v_cnt <= 8'h0;

    if (en_txtrd[0]) begin
      if (txt_h_cnt[2:0] == `OSD_FONT_WIDTH) begin
        txt_h_cnt[2:0] <= 3'h0;
        txt_h_cnt[8:3] <= txt_h_cnt[8:3] + 1'b1;
      end else
        txt_h_cnt <= txt_h_cnt + 1'b1;
    end else begin
      txt_h_cnt <= 9'h0;
    end

    nHSYNC_pre <= nHSYNC_cur;
    nVSYNC_pre <= nVSYNC_cur;
  end

  draw_osd_window[4:1] <= draw_osd_window[3:0];
  draw_osd_window[  0] <= (h_cnt > `OSD_WINDOW_H_START) && (h_cnt < `OSD_WINDOW_H_STOP) &&
                          (v_cnt > `OSD_WINDOW_V_START) && (v_cnt < `OSD_WINDOW_V_STOP);

  en_txtrd[4:1] <= en_txtrd[3:0];
  en_txtrd[  0] <=(h_cnt > `OSD_TXT_H_START)   && (h_cnt < `OSD_TXT_H_STOP)     &&
                  (v_cnt > `OSD_HEADER_V_STOP) && (v_cnt < `OSD_FOOTER_V_START);
  if (~nRST) begin
    h_cnt <= 10'h0;
    v_cnt <=  8'h0;

    txt_h_cnt <= 9'h0;
    txt_v_cnt <= 8'h0;

    draw_osd_window <= 5'b00000;
    en_txtrd    <= 5'b00000;
  end
end

wire [5:0] txt_xrdaddr = txt_h_cnt[8:3];
wire [3:0] txt_yrdaddr = txt_v_cnt[7:4];

wire [1:0] background_tmp;
wire [3:0] font_color_tmp;
wire [6:0] font_addr_lsb;

ram2port_1 vd_text_u(
  .data(vd_wrdata[6:0]),
  .rdaddress({txt_xrdaddr,txt_yrdaddr}),
  .rdclock(~nCLK),
  .rden(en_txtrd[0]),
  .wraddress(vd_wraddr),
  .wrclock(CLK_100M),
  .wren(vd_wrctrl[0]),
  .q(font_addr_lsb)
);

ram2port_2 vd_color_u(
  .data(vd_wrdata[12:7]),
  .rdaddress({txt_xrdaddr,txt_yrdaddr}),
  .rdclock(~nCLK),
  .rden(en_txtrd[0]),
  .wraddress(vd_wraddr),
  .wrclock(CLK_100M),
  .wren(vd_wrctrl[1]),
  .q({background_tmp,font_color_tmp})
);

reg [7:0] font_addr_msb  = 8'h0;
reg [7:0] font_color_del = 8'h0;

always @(negedge nCLK) begin
  font_addr_msb  <= {font_addr_msb [3:0],txt_v_cnt[3:0]};
  font_color_del <= {font_color_del[3:0],font_color_tmp};

  if (~nRST) begin
    font_addr_msb  <= 8'h0;
    font_color_del <= 8'h0;
  end
end

wire [3:0] font_color = font_color_del[7:4];
wire [7:0] font_word;

rom1port_1 font_mem_u(
  .address({font_addr_msb[7:4],font_addr_lsb}),
  .clock(~nCLK),
  .rden(en_txtrd[2]),
  .q(font_word)
);

reg [11:0] font_pixel_select = 12'h0;

always @(negedge nCLK) begin
  font_pixel_select  <= {font_pixel_select [8:0],txt_h_cnt[2:0]};

  if (~nRST)
    font_pixel_select  <= 12'h0;
end

wire pixel_is_set = font_word[font_pixel_select[11:9]];

wire [5:0] window_bg_color = `OSD_WINDOW_BG_COLOR;

wire [`VDATA_I_CO_SLICE] txt_color = (font_color == `FONTCOLOR_WHITE)  ? `OSD_TXT_COLOR_WHITE  :
                                     (font_color == `FONTCOLOR_RED)    ? `OSD_TXT_COLOR_RED    :
                                     (font_color == `FONTCOLOR_GREEN)  ? `OSD_TXT_COLOR_GREEN  :
                                     (font_color == `FONTCOLOR_BLUE)   ? `OSD_TXT_COLOR_BLUE   :
                                     (font_color == `FONTCOLOR_YELLOW) ? `OSD_TXT_COLOR_YELLOW :
                                     (font_color == `FONTCOLOR_CYAN)   ? `OSD_TXT_COLOR_CYAN   :
                                                                         `OSD_TXT_COLOR_MAGENTA;

always @(negedge nCLK) begin
  // pass through sync
  video_data_o[`VDATA_I_SY_SLICE] <= video_data_i[`VDATA_I_SY_SLICE];

  // draw menu window if needed
  if (show_osd & draw_osd_window[4]) begin
    if (&{en_txtrd[4],|font_color,pixel_is_set}) begin
      video_data_o[`VDATA_I_CO_SLICE] <= txt_color;
    end else begin
    // modify red
      video_data_o[3*color_width_i-1:3*color_width_i-2] <= window_bg_color[5:4];
      video_data_o[3*color_width_i-3                  ] <= 1'b0;
      video_data_o[3*color_width_i-4:2*color_width_i  ] <= video_data_i[3*color_width_i-1:2*color_width_i+3];
    // modify green
      video_data_o[2*color_width_i-1:2*color_width_i-2] <= window_bg_color[3:2];
      video_data_o[2*color_width_i-3                  ] <= 1'b0;
      video_data_o[2*color_width_i-4:  color_width_i  ] <= video_data_i[2*color_width_i-1:color_width_i+3];
    // modify blue
      video_data_o[color_width_i-1:color_width_i-2] <= window_bg_color[1:0];
      video_data_o[color_width_i-3                ] <= 1'b0;
      video_data_o[color_width_i-4:              0] <= video_data_i[color_width_i-1:3];
    end
  end else begin
    video_data_o[`VDATA_I_CO_SLICE] <= video_data_i[`VDATA_I_CO_SLICE];
  end
end

endmodule
