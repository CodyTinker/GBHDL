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
//  Revision 0.02 - Implemented register read and write                           //
//                  NOTE: Not tested                                              //
//--------------------------------------------------------------------------------//
module register_file #(
  parameter                          DATA_WIDTH = 8,
  parameter                          ADDRESS_WIDTH = 3
)(
  input                              i_clk,
  input                              i_reset,
  input                              i_wr_en,
  input                              i_rd_en,
  input                              i_rd_addr_en,
  input  [ADDRESS_WIDTH-1:0]         i_addr,
  input  [DATA_WIDTH-1:0]            i_data,
  input  [DATA_WIDTH*2-1:0]          i_addr_data_in,
  output reg [DATA_WIDTH-1:0]        o_data,
  output [DATA_WIDTH*2-1:0]          o_addr_data
);

  wire [DATA_WIDTH-1:0] data_bus;
  reg [7:0]             register_sel;
  
  wire                  reigster_A_wr_en;
  reg  [DATA_WIDTH-1:0] register_A_i_data;
  wire [DATA_WIDTH-1:0] register_A_o_data;
  wire                  reigster_B_wr_en;
  reg  [DATA_WIDTH-1:0] register_B_i_data;
  wire [DATA_WIDTH-1:0] register_B_o_data;
  wire                  reigster_C_wr_en;
  reg  [DATA_WIDTH-1:0] register_C_i_data;
  wire [DATA_WIDTH-1:0] register_C_o_data;
  wire                  reigster_D_wr_en;
  reg  [DATA_WIDTH-1:0] register_D_i_data;
  wire [DATA_WIDTH-1:0] register_D_o_data;
  wire                  reigster_E_wr_en;
  reg  [DATA_WIDTH-1:0] register_E_i_data;
  wire [DATA_WIDTH-1:0] register_E_o_data;
  wire                  reigster_H_wr_en;
  reg  [DATA_WIDTH-1:0] register_H_i_data;
  wire [DATA_WIDTH-1:0] register_H_o_data;
  wire                  reigster_L_wr_en;
  reg  [DATA_WIDTH-1:0] register_L_i_data;
  wire [DATA_WIDTH-1:0] register_L_o_data;  
  
  wire                  reigster_PC_wr_en;
  reg  [DATA_WIDTH-1:0] register_PC_i_data;
  wire [DATA_WIDTH-1:0] register_PC_o_data;  
  
  //Register Mapping 
  //General Purpose Registers
  //From the Z80 Hardware Orginazation document 
  //CODE	REGISTER	CODE	REGISTER
  //0 0 0	   B	    1 0 0	   H
  //0 0 1	   C	    1 0 1	   L
  //0 1 0	   D	    1 1 0	-(MEMORY)
  //0 1 1	   E	    1 1 1	   A
  
  //Addressing Registers
  //Arbitrarily made up (Havn't seen standard)
  //Still need IX, IY, SP
  //CODE	REGISTER	CODE	REGISTER
  //0 0 0	   BC	    1 0 0	   -
  //0 0 1	   DE	    1 0 1	   -
  //0 1 0	   HL	    1 1 0	   -
  //0 1 1	   PC	    1 1 1	   -
  
  //NOTE: Still unsure if the accumulator register (A)
  //is stored in the register file alongside the other 
  //registers.
  
  //Register Select Decoder
  always@ (*) begin : registerSelect
    case (i_addr)
      3'h0 : register_sel = 8'h01; //B
      3'h1 : register_sel = 8'h02; //C
      3'h2 : register_sel = 8'h04; //D
      3'h3 : register_sel = 8'h08; //E
      3'h4 : register_sel = 8'h10; //H
      3'h5 : register_sel = 8'h20; //L
      3'h6 : register_sel = 8'h40; //MEMORY
      3'h7 : register_sel = 8'h80; //A
    endcase
  end 
  
  
  
  //Registers
  
  //8-bit registers  (General Purpose Registers)
  //NOTE: Consider generating registers with generate statement?
  register #(
    .DATA_WIDTH(8)
  ) Register_A(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_we(reigster_A_wr_en),
    .i_data(i_data),
    .o_data(register_A_o_data)
  ); //FIXME: Does this register belong here???
  
  register #(
    .DATA_WIDTH(8)
  ) Register_B(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_we(reigster_B_wr_en),
    .i_data(i_data),
    .o_data(register_B_o_data)
  );
  
  register #(
    .DATA_WIDTH(8)
  ) Register_C(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_we(reigster_C_wr_en),
    .i_data(i_data),
    .o_data(register_C_o_data)
  );
  
  register #(
    .DATA_WIDTH(8)
  ) Register_D(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_we(reigster_D_wr_en),
    .i_data(i_data),
    .o_data(register_D_o_data)
  );
  
  register #(
    .DATA_WIDTH(8)
  ) Register_E(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_we(reigster_E_wr_en),
    .i_data(i_data),
    .o_data(register_E_o_data)
  );
  
  register #(
    .DATA_WIDTH(8)
  ) Register_H(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_we(reigster_H_wr_en),
    .i_data(i_data),
    .o_data(register_H_o_data)
  );
  
  register #(
    .DATA_WIDTH(8)
  ) Register_L(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_we(reigster_L_wr_en),
    .i_data(i_data),
    .o_data(register_L_o_data)
  );
  
  //16-bit registers
  register #(
    .DATA_WIDTH(16)
  ) Register_PC(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_we(reigster_PC_wr_en),
    .i_data(i_addr_data_in),
    .o_data(register_PC_o_data)
  );
  
  //Register Read Mux
  always @(posedge i_clk) begin
    if (i_rd_en)
      case (i_addr)
        3'h0 : o_data <= register_B_o_data;
        3'h1 : o_data <= register_C_o_data;
        3'h2 : o_data <= register_D_o_data;
        3'h3 : o_data <= register_E_o_data;
        3'h4 : o_data <= register_H_o_data;
        3'h5 : o_data <= register_L_o_data;
        3'h6 : o_data <= {DATA_WIDTH{1'b0}};
        3'h7 : o_data <= register_A_o_data;
        default : o_data <= {DATA_WIDTH{1'b0}};
      endcase
  end
    
  
  //FIXME: Look into how reading onto the address bus should be implemented
  //Register Read Mux
  always @(posedge i_clk) begin
    if (i_rd_addr_en)
      case (i_addr)
      //Addr                  {         LSB     ,        MSB       }
        3'h0 : o_data_addr <= {register_B_o_data, register_C_o_data};
        3'h1 : o_data_addr <= {register_D_o_data, register_E_o_data};
        3'h2 : o_data_addr <= {register_H_o_data, register_L_o_data};
        3'h3 : o_data_addr <= register_PC_o_data;
        default : o_data_addr <= {(DATA_WIDTH*2){1'b0}};
      endcase
  end
    
  //Register Write Enables
  assign reigster_A_wr_en = register_sel[7] & i_wr_en;
  assign reigster_B_wr_en = register_sel[0] & i_wr_en;
  assign reigster_C_wr_en = register_sel[1] & i_wr_en;
  assign reigster_D_wr_en = register_sel[2] & i_wr_en;
  assign reigster_E_wr_en = register_sel[3] & i_wr_en;
  assign reigster_H_wr_en = register_sel[4] & i_wr_en;
  assign reigster_L_wr_en = register_sel[5] & i_wr_en;  
  
endmodule 