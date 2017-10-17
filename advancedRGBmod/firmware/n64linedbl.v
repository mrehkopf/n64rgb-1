//////////////////////////////////////////////////////////////////////////////////
// Company:  Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    n64linedbl
// Project Name:   Advanced RGB Mod
// Target Devices: Max10, Cyclone IV and Cyclone 10 LP devices
// Tool versions:  Altera Quartus Prime
// Description:    simple line-multiplying
//
// Dependencies: ip/ram2port_0.qip
//
// Revision: 1.1
// Features: linebuffer for - NTSC 240p -> 480p rate conversion
//                          - PAL  288p -> 576p rate conversion
//           injection of scanlines on demand in three selectable intensities
//
///////////////////////////////////////////////////////////////////////////////////////////


module n64linedbl(
  PX_CLK_4x,
  PX_CLK_2x,

  vinfo,

  Sync_i,
     R_i,
     G_i,
     B_i,

  Sync_o,
     R_o,
     G_o,
     B_o
);

parameter color_width_i = 7;
parameter color_width_o = 8;

localparam ram_depth = 11; // plus 1 due to oversampling

input PX_CLK_4x;
input PX_CLK_2x;

input [4:0] vinfo; // [nLinedbl,SL_str (2bits),PAL,interlaced]

input               [3:0] Sync_i;
input [color_width_i-1:0]    R_i;
input [color_width_i-1:0]    G_i;
input [color_width_i-1:0]    B_i;

output reg               [3:0] Sync_o;
output reg [color_width_o-1:0]    R_o;
output reg [color_width_o-1:0]    G_o;
output reg [color_width_o-1:0]    B_o;


reg                 wrline = 1'b0;
reg [ram_depth-1:0] wraddr = {ram_depth{1'b0}};

wire wren = ~&{wraddr[ram_depth-1],wraddr[ram_depth-2],wraddr[ram_depth-5]};

reg [ram_depth-1:0] line_width[0:1];
initial begin
   line_width[1] = {ram_depth{1'b0}};
   line_width[0] = {ram_depth{1'b0}};
end

wire valid_line = &wraddr[ram_depth-1:ram_depth-2]; // hopefully enough for evaluation

reg           [1:0] rdrun    = 2'b00;
reg                 rdcnt    = 1'b0;
reg                 rdline   = 1'b0;
reg [ram_depth-1:0] rdaddr   = {ram_depth{1'b0}};

wire nVSYNC_i     = Sync_i[3];
reg  nVSYNC_i_buf = 1'b0;
wire nHSYNC_i     = Sync_i[1];
reg  nHSYNC_i_buf = 1'b0;


reg [1:0] newFrame       = 2'b0;
reg [1:0] start_reading_proc = 2'b00;


always @(posedge PX_CLK_2x) begin
  if (nVSYNC_i_buf & ~nVSYNC_i) begin
    newFrame[0] <= ~newFrame[1];
    if (&{nHSYNC_i_buf,~nHSYNC_i,wren,valid_line})
      start_reading_proc[0] <= ~start_reading_proc[1];  // trigger start reading
  end

  if (nHSYNC_i_buf & ~nHSYNC_i) begin // negedge nHSYNC -> reset wraddr and toggle wrline
    line_width[wrline] <= wraddr[ram_depth-1:0];

    wraddr <= {ram_depth{1'b0}};
    wrline <= ~wrline;
  end else if (wren) begin
    wraddr <= wraddr + 1'b1;
  end

  nVSYNC_i_buf <= nVSYNC_i;
  nHSYNC_i_buf <= nHSYNC_i;
end

//wire pal_mode = vinfo[1];
//wire [ram_depth-1:0] line_width = pal_mode ? 11'd1588 : 11'd1546;

always @(posedge PX_CLK_4x) begin
  if (rdrun[1]) begin
    if (rdaddr == line_width[rdline]) begin
      rdaddr   <= {ram_depth{1'b0}};
      if (rdcnt)
//        rdline <= ~rdline;
        rdline <= ~wrline;
      rdcnt <= ~rdcnt;
    end else begin
      rdaddr <= rdaddr + 1'b1;
    end
    if (~wren || &{nHSYNC_i_buf,~nHSYNC_i,~valid_line}) begin
      rdrun <= 2'b00;
    end
  end else if (rdrun[0] && wraddr[3]) begin
    rdrun[1] <= 1'b1;
    rdcnt    <= 1'b0;
    rdline   <= ~wrline;
    rdaddr   <= {ram_depth{1'b0}};
  end else if (^start_reading_proc) begin
    rdrun[0] <= 1'b1;
  end

  start_reading_proc[1] <= start_reading_proc[0];
end

wire               [3:0] Sync_buf;
wire [color_width_i-1:0]    R_buf, G_buf, B_buf;

ram2port_0 videobuffer(
  .data({R_i,G_i,B_i}),
  .rdaddress({rdline,rdaddr}),
  .rdclock(PX_CLK_4x),
  .wraddress({wrline,wraddr}),
  .wrclock(PX_CLK_2x),
  .wren(wren),
  .q({R_buf,G_buf,B_buf})
);



localparam nHSYNC_WIDTH     = 8'd127;
localparam nVSYNC_WIDTH     = 3'd3;
localparam nVSYNC_HWIDTH_LL = 8'd191;

reg rdcnt_buf = 1'b0;

reg [2:0] nVSYNC_cnt = 3'b0;


wire [1:0] SL_str = vinfo[3:2];
wire nENABLE_linedbl = vinfo[4] | ~rdrun[1];

always @(posedge PX_CLK_4x) begin

  if (rdcnt_buf ^ rdcnt) begin
    Sync_o[0] <= 1'b0;
    Sync_o[1] <= 1'b0;
    Sync_o[2] <= 1'b1; // dummy

    if (|nVSYNC_cnt) begin
      nVSYNC_cnt <= nVSYNC_cnt - 1'b1;
      Sync_o[0]  <= 1'b1;
    end

    if (^newFrame) begin
      nVSYNC_cnt  <= nVSYNC_WIDTH;
      Sync_o[3]   <= 1'b0;
      newFrame[1] <= newFrame[0];
    end
  end else begin
//    if (rdaddr[7:0] > nHSYNC_WIDTH)
    if (rdaddr[7]) begin
      Sync_o[0] <= 1'b1;
      Sync_o[1] <= 1'b1;
      if (~Sync_o[3])
        Sync_o[0] <= 1'b0;
    end

//    if (~|nVSYNC_cnt && rdaddr[7:0] > nVSYNC_HWIDTH_LL)
    if ((~|nVSYNC_cnt) && (&rdaddr[7:6])) begin
      Sync_o[0] <= 1'b1;
      Sync_o[3] <= 1'b1;
    end
  end

    rdcnt_buf <= rdcnt;

    if (rdcnt) begin
      case (SL_str)
        2'b11: begin
          R_o <= {R_buf,1'b0};
          G_o <= {G_buf,1'b0};
          B_o <= {B_buf,1'b0};
        end
        2'b10: begin
          R_o <= {1'b0,R_buf[color_width_i-1:0]} + {2'b00,R_buf[color_width_i-1:1]};
          G_o <= {1'b0,G_buf[color_width_i-1:0]} + {2'b00,G_buf[color_width_i-1:1]};
          B_o <= {1'b0,B_buf[color_width_i-1:0]} + {2'b00,B_buf[color_width_i-1:1]};
        end
        2'b01: begin
          R_o <= {1'b0,R_buf[color_width_i-1:0]};
          G_o <= {1'b0,G_buf[color_width_i-1:0]};
          B_o <= {1'b0,B_buf[color_width_i-1:0]};
        end
        2'b00: begin
          R_o <= {color_width_o{1'b0}};
          G_o <= {color_width_o{1'b0}};
          B_o <= {color_width_o{1'b0}};
        end
      endcase
    end else begin
      R_o <= {R_buf,1'b0};
      G_o <= {G_buf,1'b0};
      B_o <= {B_buf,1'b0};
    end

  if (nENABLE_linedbl) begin
    Sync_o <= Sync_i;
       R_o <= {R_i,1'b0};
       G_o <= {G_i,1'b0};
       B_o <= {B_i,1'b0};
  end
end

endmodule 