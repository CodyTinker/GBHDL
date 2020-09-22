//--------------------------------------------------------------------------------//
//  Project Name : GB80                                                           //
//  Module Name  : register_file.v                                                //
//  Create Date  : August, 2016                                                   //
//  Author       : Kevin Millar                                                   //
//                 Cody Tinker                                                    //
//                                                                                //
//  Description:   Register File Module.                                          //
//                                                                                //
//  Dependencies:  None                                                           //
//                                                                                //
//--------------------------------------------------------------------------------//
//  Revision 0.04 - Updated register file                                         //
//--------------------------------------------------------------------------------//
module register_file #(
  parameter                          DATA_WIDTH = 8,
  parameter                          ADDR_WIDTH = 3
)(
  // Control Signals
  input                              i_clk,
  input                              i_reset,
  input                              i_pc_wr_en,
  input                              i_sp_wr_en,
  // Data Register Signals
  input                              i_reg_wr_en,
  input                              i_reg_rd_en,
  input  [DATA_WIDTH-1:0]            i_reg_data,
  input  [ADDR_WIDTH-1:0]            i_reg_rd_addr,
  input  [ADDR_WIDTH-1:0]            i_reg_wr_addr,
  output [DATA_WIDTH-1:0]            o_reg_data,
  // Flag Signals
  input  [3:0]                       i_flags,
  input                              i_flags_wr_en,
  output [3:0]                       o_flags,
  // Address Register Signals
  input                              i_addr_wr_en,
  input                              i_addr_rd_en,
  // FIXME: addr_addr not needed if address bus/data bus are not concurrent;
  //  Select for SP/PC also probably needs to be here
  input  [ADDR_WIDTH-1:0]            i_addr_addr,
  input  [DATA_WIDTH*2-1:0]          i_addr_data,
  output [DATA_WIDTH*2-1:0]          o_addr_data
);

  localparam NUM_REG = 8;

  wire [3:0]               flags;
  
  reg  [NUM_REG-1:0]       reg_wr_sel;
  wire [DATA_WIDTH-1:0]    reg_data [0:7];
  reg  [DATA_WIDTH*2-1:0]  addr_data;
  
  wire [DATA_WIDTH*2-1:0]  pc_data;
  wire [DATA_WIDTH*2-1:0]  sp_data;
  
  //General Purpose Registers
  //From the Z80 Hardware Organization document 
  //CODE	REGISTER	CODE	REGISTER
  //0 0 0	   B	    1 0 0	   H
  //0 0 1	   C	    1 0 1	   L
  //0 1 0	   D	    1 1 0	   - (MEMORY)
  //0 1 1	   E	    1 1 1	   A

  //Register Select Decoder
  always@ (*) begin : registerSelect
    case (i_reg_wr_addr)
      3'h0 : reg_wr_sel = 8'h01; //B
      3'h1 : reg_wr_sel = 8'h02; //C
      3'h2 : reg_wr_sel = 8'h04; //D
      3'h3 : reg_wr_sel = 8'h08; //E
      3'h4 : reg_wr_sel = 8'h10; //H
      3'h5 : reg_wr_sel = 8'h20; //L
      3'h6 : reg_wr_sel = 8'h40; //MEMORY
      3'h7 : reg_wr_sel = 8'h80; //A
    endcase
  end 
  
  //Data registers (General Purpose Registers)
  genvar i, j;
  generate
		for (i = 0; i < NUM_REG-2; i = i + 1) begin
      register #(
        .DATA_WIDTH(DATA_WIDTH)
      ) reg_inst(
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_we(i_reg_wr_en && reg_wr_sel[i]),
        .i_data(i_reg_data),
        .o_data(reg_data[i])
      );
		end
  endgenerate
  // FIXME: may not be necessary?
  assign reg_data[6] = {DATA_WIDTH{1'b0}};
  
  // Accumulator register
  register #(
    .DATA_WIDTH(DATA_WIDTH)
  ) A_reg_inst(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_we(i_reg_wr_en && reg_wr_sel[7]),
    .i_data(i_reg_data),
    .o_data(reg_data[7])
  );
  
  // Flag register
  // FIXME: may or may not be accessible on data bus
  register #(
    .DATA_WIDTH(DATA_WIDTH/2)
  ) F_reg_inst(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_we(i_flags_wr_en),
    .i_data(i_flags),
    .o_data(flags)
  );
  
  //Address registers
  register #(
    .DATA_WIDTH(DATA_WIDTH*2)
  ) PC_reg_inst (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_we(i_pc_wr_en),
    .i_data(i_addr_data),
    .o_data(pc_data)
  );
  
  register #(
    .DATA_WIDTH(DATA_WIDTH*2)
  ) SP_reg_inst (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_we(i_sp_wr_en),
    .i_data(i_addr_data),
    .o_data(sp_data)
  );
  
  //Address Registers
  //CODE	REGISTER        CODE	REGISTER
  //0 0 0   $FF00 + n	    1 0 0   BC
  //0 0 1   PC	          1 0 1   DE
  //0 1 0   $FF00 + C	    1 1 0   HL
  //0 1 1   SP	          1 1 1   AF
  
  // Address Register Read
  always @(*) begin
    //FIXME: Look into how reading onto the address bus should be implemented
    case (i_addr_addr)
      3'b000 : addr_data = {8'hFF,i_reg_data};            // $FF00 + n
      3'b001 : addr_data = pc_data;                       // PC
      3'b010 : addr_data = {8'hFF,reg_data[1]};           // $FF00 + C
      3'b011 : addr_data = sp_data;                       // SP
      3'b100 : addr_data = {reg_data[0], reg_data[1]};    // BC
      3'b101 : addr_data = {reg_data[2], reg_data[3]};    // DE
      3'b110 : addr_data = {reg_data[4], reg_data[5]};    // HL
      3'b111 : addr_data = {reg_data[7], {flags,{4'h0}}}; // AF
    endcase
  end
  
  assign o_reg_data  = {DATA_WIDTH{i_reg_rd_en}} & reg_data[i_reg_rd_addr];
  assign o_addr_data = {DATA_WIDTH*2{i_addr_rd_en}} & addr_data;
  assign o_flags = flags;
  
endmodule 