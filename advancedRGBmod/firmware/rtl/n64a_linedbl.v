//////////////////////////////////////////////////////////////////////////////////
// Company:  Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    n64a_linedbl
// Project Name:   N64 Advanced RGB Mod
// Target Devices: Max10, Cyclone IV and Cyclone 10 LP devices
// Tool versions:  Altera Quartus Prime
// Description:    simple line-multiplying
//
// Dependencies: vh/n64a_params.vh
//               ip/ram2port_0.qip
//
// Revision: 1.1
// Features: linebuffer for - NTSC 240p -> 480p rate conversion
//                          - PAL  288p -> 576p rate conversion
//           injection of scanlines on demand in three selectable intensities
//
///////////////////////////////////////////////////////////////////////////////////////////


module n64a_linedbl(
  nCLK_4x,

  vinfo_dbl,

  vdata_i,
  vdata_o
);

`include "vh/n64a_params.vh"

localparam ram_depth = 11; // plus 1 due to oversampling

input nCLK_4x;

input [4:0] vinfo_dbl; // [nLinedbl,SL_str (2bits),PAL,interlaced]

input  [`VDATA_I_FU_SLICE] vdata_i;
output [`VDATA_O_FU_SLICE] vdata_o;


// pre-assignments

wire nVS_i = vdata_i[3*color_width_i+3];
wire nHS_i = vdata_i[3*color_width_i+1];

wire [color_width_i-1:0] R_i = vdata_i[`VDATA_I_RE_SLICE];
wire [color_width_i-1:0] G_i = vdata_i[`VDATA_I_GR_SLICE];
wire [color_width_i-1:0] B_i = vdata_i[`VDATA_I_BL_SLICE];


wire nENABLE_linedbl = vinfo_dbl[4] | ~rdrun[1];
wire [1:0] SL_str = vinfo_dbl[3:2];

wire pal_mode = vinfo_dbl[1];
wire n64_480i = vinfo_dbl[0];

// start of rtl


reg div_2x = 1'b0;

always @(negedge nCLK_4x) begin
  div_2x <= ~div_2x;
end


reg [ram_depth-1:0] hstart = `HSTART_NTSC_480I;
reg [ram_depth-1:0] hstop  = `HSTOP_NTSC;

reg [6:0] nHS_width = `HS_WIDTH_NTSC_480I;


reg                 wren   = 1'b0;
reg                 wrline = 1'b0;
reg [ram_depth-1:0] wrhcnt = {ram_depth{1'b0}};
reg [ram_depth-1:0] wraddr = {ram_depth{1'b0}};

wire line_overflow = &{wrhcnt[ram_depth-1],wrhcnt[ram_depth-2],wrhcnt[ram_depth-5]};  // close approach for NTSC and PAL
wire valid_line    = wrhcnt > hstop;                                                  // for evaluation


reg [ram_depth-1:0] line_width[0:1];
initial begin
   line_width[1] = {ram_depth{1'b0}};
   line_width[0] = {ram_depth{1'b0}};
end

reg  nVS_i_buf = 1'b0;
reg  nHS_i_buf = 1'b0;


reg [1:0] newFrame       = 2'b0;
reg [1:0] start_reading_proc = 2'b00;


always @(negedge nCLK_4x) begin
  if (~div_2x) begin
    if (nVS_i_buf & ~nVS_i) begin
      // trigger new frame
      newFrame[0] <= ~newFrame[1];

      // trigger read start
      if (&{nHS_i_buf,~nHS_i,~line_overflow,valid_line})
        start_reading_proc[0] <= ~start_reading_proc[1];

      // set new info
      case({pal_mode,n64_480i})
        2'b00: begin
            hstart    <= `HSTART_NTSC_240P;
            hstop     <= `HSTOP_NTSC;
            nHS_width <= `HS_WIDTH_NTSC_240P;
          end
        2'b01: begin
            hstart    <= `HSTART_NTSC_480I;
            hstop     <= `HSTOP_NTSC;
            nHS_width <= `HS_WIDTH_NTSC_480I;
          end
        2'b10: begin
            hstart    <= `HSTART_PAL_288P;
            hstop     <= `HSTOP_PAL;
            nHS_width <= `HS_WIDTH_PAL_288P;
          end
        2'b11: begin
            hstart    <= `HSTART_PAL_576I;
            hstop     <= `HSTOP_PAL;
            nHS_width <= `HS_WIDTH_PAL_576I;
          end
      endcase
    end

    if (nHS_i_buf & ~nHS_i) begin // negedge nHSYNC -> reset wrhcnt and toggle wrline
      line_width[wrline] <= wrhcnt[ram_depth-1:0];

      wrhcnt <= {ram_depth{1'b0}};
      wrline <= ~wrline;
    end else if (~line_overflow) begin
      wrhcnt <= wrhcnt + 1'b1;
    end

    if (wrhcnt == hstart) begin
      wren   <= 1'b1;
      wraddr <= {ram_depth{1'b0}};
    end else if (wrhcnt > hstart && wrhcnt < hstop) begin
      wraddr <= wraddr + 1'b1;
    end else begin
      wren   <= 1'b0;
      wraddr <= {ram_depth{1'b0}};
    end

    nVS_i_buf <= nVS_i;
    nHS_i_buf <= nHS_i;
  end
end


reg           [2:0] rden     = 3'b0;
reg           [1:0] rdrun    = 2'b00;
reg                 rdcnt    = 1'b0;
reg                 rdline   = 1'b0;
reg [ram_depth-1:0] rdhcnt   = {ram_depth{1'b0}};
reg [ram_depth-1:0] rdaddr   = {ram_depth{1'b0}};

always @(negedge nCLK_4x) begin
  if (rdrun[1]) begin
    if (rdhcnt == line_width[rdline]) begin
      rdhcnt   <= {ram_depth{1'b0}};
      if (rdcnt)
        rdline <= ~wrline;
      rdcnt <= ~rdcnt;
    end else begin
      rdhcnt <= rdhcnt + 1'b1;
    end
    if (line_overflow || &{nHS_i_buf,~nHS_i,~valid_line}) begin
      rdrun <= 2'b00;
    end

    if (rdhcnt == hstart) begin
      rden[0] <= 1'b1;
      rdaddr  <= {ram_depth{1'b0}};
    end else if (rdhcnt > hstart && rdhcnt < hstop) begin
      rdaddr <= rdaddr + 1'b1;
    end else begin
      rden[0] <= 1'b0;
      rdaddr  <= {ram_depth{1'b0}};
    end
  end else if (rdrun[0] && wrhcnt[3]) begin
    rdrun[1] <= 1'b1;
    rdcnt    <= 1'b0;
    rdline   <= ~wrline;
    rdhcnt   <= {ram_depth{1'b0}};
  end else if (^start_reading_proc) begin
    rdrun[0] <= 1'b1;
  end

  rden[2:1] <= rden[1:0];
  start_reading_proc[1] <= start_reading_proc[0];
end


wire [color_width_i-1:0] R_buf[0:1], G_buf[0:1], B_buf[0:1];

ram2port_0 videobuffer_0(
  .clock(~nCLK_4x),
  .data({R_i,G_i,B_i}),
  .rdaddress(rdaddr),
  .rden(&{rden[0],~rdline}),
  .wraddress(wraddr),
  .wren(&{wren,~wrline,~line_overflow,~div_2x}),
  .q({R_buf[0],G_buf[0],B_buf[0]})
);

ram2port_0 videobuffer_1(
  .clock(~nCLK_4x),
  .data({R_i,G_i,B_i}),
  .rdaddress(rdaddr),
  .rden(&{rden[0],rdline}),
  .wraddress(wraddr),
  .wren(&{wren,wrline,~line_overflow,~div_2x}),
  .q({R_buf[1],G_buf[1],B_buf[1]})
);


reg     rdcnt_buf = 1'b0;
reg [7:0] nHS_cnt = 8'd0;
reg [1:0] nVS_cnt = 2'b0;

wire CSen_lineend = ((rdhcnt + 2'b11) > (line_width[rdline] - nHS_width));

reg               [3:0] S_o;
reg [color_width_o-1:0] R_o;
reg [color_width_o-1:0] G_o;
reg [color_width_o-1:0] B_o;

always @(negedge nCLK_4x) begin

  if (rdcnt_buf ^ rdcnt) begin
    S_o[0] <= 1'b0;
    S_o[1] <= 1'b0;
    S_o[2] <= 1'b1; // dummy

    nHS_cnt <= nHS_width;

    if (^newFrame) begin
      nVS_cnt  <= `VS_WIDTH;
      S_o[3]   <= 1'b0;
      newFrame[1] <= newFrame[0];
    end else if (|nVS_cnt) begin
      nVS_cnt <= nVS_cnt - 1'b1;
    end else begin
      S_o[3] <= 1'b1;
    end
  end else begin
    if (|nHS_cnt) begin
      nHS_cnt <= nHS_cnt - 1'b1;
    end else begin
      S_o[1] <= 1'b1;
      if (S_o[3])
        S_o[0] <= 1'b1;
    end
    
    if (CSen_lineend) begin
      S_o[0] <= 1'b1;
    end
  end

    rdcnt_buf <= rdcnt;

    if (rden[2]) begin
      if (rdcnt) begin
        case (SL_str)
          2'b11: begin
            R_o <= {R_buf[rdline],1'b0};
            G_o <= {G_buf[rdline],1'b0};
            B_o <= {B_buf[rdline],1'b0};
          end
          2'b10: begin
            R_o <= {1'b0 ,R_buf[rdline][color_width_i-1:0]} +
                   {2'b00,R_buf[rdline][color_width_i-1:1]};
            G_o <= {1'b0 ,G_buf[rdline][color_width_i-1:0]} +
                   {2'b00,G_buf[rdline][color_width_i-1:1]};
            B_o <= {1'b0 ,B_buf[rdline][color_width_i-1:0]} +
                   {2'b00,B_buf[rdline][color_width_i-1:1]};
          end
          2'b01: begin
            R_o <= {1'b0,R_buf[rdline][color_width_i-1:0]};
            G_o <= {1'b0,G_buf[rdline][color_width_i-1:0]};
            B_o <= {1'b0,B_buf[rdline][color_width_i-1:0]};
          end
          2'b00: begin
            R_o <= {color_width_o{1'b0}};
            G_o <= {color_width_o{1'b0}};
            B_o <= {color_width_o{1'b0}};
          end
        endcase
      end else begin
        R_o <= {R_buf[rdline],1'b0};
        G_o <= {G_buf[rdline],1'b0};
        B_o <= {B_buf[rdline],1'b0};
      end
    end else begin
      R_o <= {color_width_o{1'b0}};
      G_o <= {color_width_o{1'b0}};
      B_o <= {color_width_o{1'b0}};
    end

  if (nENABLE_linedbl) begin
    S_o <= vdata_i[`VDATA_I_SY_SLICE];
    R_o <= {R_i,1'b0};
    G_o <= {G_i,1'b0};
    B_o <= {B_i,1'b0};
  end
end


// post-assignment

assign vdata_o = {S_o,R_o,G_o,B_o};

endmodule 