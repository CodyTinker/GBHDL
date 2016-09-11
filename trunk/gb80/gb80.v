//--------------------------------------------------------------------------------//
//  Project Name : GB80                                                           //
//  Module Name  : gb80_processor.v                                               //
//  Create Date  : August, 2016                                                   //
//  Author       : Cody Tinker                                                    //
//                 Kevin Millar                                                   //
//                                                                                //
//  Description  : Structural workspace for the gb80 processor.                   //
//                                                                                //
//  Dependencies : None                                                           //
//                                                                                //
//--------------------------------------------------------------------------------//
//  Revision 0.01 - File Created                                                  //
//--------------------------------------------------------------------------------//
module gb80_processor #(
  //parameter                         DATA_WIDTH = 8
)(
  input                             i_clk,
  input                             i_reset,
  input [7:0]                       i_memory_data,
  output [15:0]                     o_memory_addr
);

  //Global Signal and Bus definitons
  wire [7:0]                        g_data_bus;
  
  assign g_data_bus <= i_memory_data || reg_file_data_out || temporary_reg_data_mux_out || alu_data_mux_out;
  
  //Control Section ---------------------------------------
  wire [7:0] inst_reg_data;
  
  wire decoder_opcode_type;
  wire [7:0] decoder_literal_value;
  wire [2:0] decoder_addr_A;
  wire [2:0] decoder_addr_B;
  
  
  wire [2:0] sequencer_register_file_addr;   //[ADDR_LENGTH-1:0]
  wire sequencer_register_file_wr;
  wire sequencer_register_file_rd;
  wire sequencer_accumulator_reg_wr;
  wire sequencer_tmp_reg_wr;
  wire sequencer_tmp_reg_rd;
  wire [2:0] sequencer_alu_control;  //[ALU_OPCODE_WIDTH-1:0]
  wire sequencer_alu_rd;
  wire sequencer_flags_reg_rd;
  wire sequencer_wr_mem;
  wire sequencer_rd_mem;
  
  register #(
  .DATA_WIDTH(8)
  ) inst_instruction_reg (
  .i_clk(i_clk),
  .i_reset(i_reset),
  .i_we(1'b1),
  .i_data(g_data_bus),              //[DATA_WIDTH-1:0]
  .o_data(inst_reg_data)            //[DATA_WIDTH-1:0]
  );
  
  module decoder #(
  .DATA_WIDTH(8),
  .ADDR_WIDTH(3)
  ) inst_decoder (
  .i_clk(i_clk),
  .i_reset(i_reset),
  //Bus pins
  .i_data_in(inst_reg_data),        //[DATA_WIDTH-1:0]
  
  //Sequencer pins
  .o_opcode_type(decoder_opcode_type),
  .o_literal_value(decoder_literal_value),     //[DATA_WIDTH-1:0]
  .o_addr_A(decoder_addr_A),                      //[ADDR_WIDTH-1:0]
  .o_addr_B(decoder_addr_B)                       //[ADDR_WIDTH-1:0]
  )
  
  module controller_sequencer #(
  .OPCODE_TYPE_LENGTH(4),
  .ALU_OPCODE_WIDTH(3),
  .ADDR_LENGTH(3),
  .DATA_WIDTH(8)
  ) inst_controller_sequencer (
  .i_clk(i_clk),
  .i_reset(i_reset),
  
  //decoder pins
  .i_opcode_type(decoder_opcode_type),           //[OPCODE_TYPE_LENGTH-1:0] 
  .i_literal_value_in(decoder_literal_value),    //[DATA_WIDTH-1:0]         
  .i_addr_A(decoder_addr_A),                     //[ADDR_LENGTH-1:0]        
  .i_addr_B(decoder_addr_B),                     //[ADDR_LENGTH-1:0]        
  
  //control pins
  //register interface:
  .o_register_file_addr(sequencer_register_file_addr),   //[ADDR_LENGTH-1:0]
  .o_register_file_wr(sequencer_register_file_wr),
  .o_register_file_rd(sequencer_register_file_rd),
  
  //alu:
  .o_accumulator_reg_wr(sequencer_accumulator_reg_wr),
  .o_tmp_reg_wr(sequencer_tmp_reg_wr),
  .o_tmp_reg_rd(sequencer_tmp_reg_rd),
  .o_alu_control(sequencer_alu_control),  //[ALU_OPCODE_WIDTH-1:0]
  .o_alu_rd(sequencer_alu_rd),
  .o_flags_reg_rd(sequencer_flags_reg_rd),
  //output maybe flags_reg_wr
  
  //memory:
  .o_wr_mem(sequencer_wr_mem),
  .o_rd_mem(sequencer_rd_mem)
    
  )

  //end Control Section -----------------------------------
  
  //Registers Section -------------------------------------
  wire [15:0] reg_file_addr_data_in, reg_file_addr_data_out;
  wire [7:0] reg_file_data_out;
  register_file #(
  .DATA_WIDTH(8),
  .ADDRESS_WIDTH(3)
  ) inst_register_file (
  .i_clk(i_clk),
  .i_reset(i_reset),
  .i_wr_en(sequencer_register_file_wr),
  .i_rd_en(sequencer_register_file_rd),
  .i_addr(sequencer_register_file_addr),
  .i_data(g_data_bus),
  .i_addr_data_in(reg_file_addr_data_in),
  .o_data(reg_file_data_out),
  .o_addr_data(reg_file_addr_data_out)
  );
  
  module bit_adder #(
  .DATA_WIDTH(16)
)(
  .i_data_A(reg_file_addr_data_out),
  .i_data_B(16'h0001),
  .i_carry_in(1'b0),
  .o_sum(reg_file_addr_data_in),
  .o_carry_out(i_reset)
)

  assign o_memory_addr = reg_file_addr_data_out;
  
  //end Registers Section ---------------------------------
  
  //Alu Section -------------------------------------------
  wire [7:0] accumulator_data_out;
  wire [7:0] temporary_reg_data_out;
  wire [7:0] temporary_reg_data_mux_out;
  wire [7:0] accumulator_temp_data_out;
  wire [7:0] alu_flags_data_out;
  wire [7:0] alu_data_out;
  wire [7:0] alu_data_mux_out;
  wire [7:0] flags_reg_out;
  wire [7:0] flags_reg_mux_out;
  
  
  register #(
  .DATA_WIDTH(8)
  ) inst_accumulator_reg (
  .i_clk(i_clk),
  .i_reset(i_reset),
  .i_we(sequencer_accumulator_reg_wr),
  .i_data(g_data_bus),                        //[DATA_WIDTH-1:0]
  .o_data(accumulator_data_out)               //[DATA_WIDTH-1:0]
  );
  
  register #(
  .DATA_WIDTH(8)
  ) inst_accumulator_temp_reg (
  .i_clk(i_clk),
  .i_reset(i_reset),
  .i_we(1'b1),
  .i_data(accumulator_data_out),                        //[DATA_WIDTH-1:0]
  .o_data(accumulator_temp_data_out)                    //[DATA_WIDTH-1:0]
  );
  
  register #(
  .DATA_WIDTH(8)
  ) inst_temp_reg (
  .i_clk(i_clk),
  .i_reset(i_reset),
  .i_we(sequencer_tmp_reg_wr),
  .i_data(g_data_bus),                        //[DATA_WIDTH-1:0]
  .o_data(temporary_reg_data_out)                         //[DATA_WIDTH-1:0]
  );
  
  //mux register data out for read on the data bus
  always @(*) begin : temp_reg_read_mux
    if (sequencer_tmp_reg_rd)
      temporary_reg_data_mux_out <= temporary_reg_data_out;
    else
      temporary_reg_data_mux_out <= 8'h00;
    end
  end
  
  alu #(
  .OPCODE_WIDTH(3),
  .DATA_WIDTH(8)
  ) inst_alu (
  .i_data_A(accumulator_temp_data_out),               //[DATA_WIDTH-1:0]  
  .i_data_B(temporary_reg_data_out),                  //[DATA_WIDTH-1:0]  
  .i_control(sequencer_alu_control),                  //[OPCODE_WIDTH-1:0]
  .o_data(alu_data_out),                              //[DATA_WIDTH-1:0]  
  .o_flags(alu_flags_data_out)                        //[DATA_WIDTH-1:0]
  )
  
  //mux register data out for read on the data bus
  always @(*) begin : alu_read_mux
    if (sequencer_alu_rd)
      alu_data_mux_out <= alu_data_out;
    else
      alu_data_mux_out <= 8'h00;
    end
  end
  
  
  register #(
  .DATA_WIDTH(8)
  ) inst_flags_reg (
  .i_clk(i_clk),
  .i_reset(i_reset),
  .i_we(1'b1),
  .i_data(alu_flags_data_out),                        //[DATA_WIDTH-1:0]
  .o_data(flags_reg_out)                         //[DATA_WIDTH-1:0]
  );
  
  //mux register data out for read on the data bus
  always @(*) begin : flags_reg_read_mux
    if (sequencer_flags_reg_rd)
      flags_reg_mux_out <= flags_reg_out;
    else
      flags_reg_mux_out <= 8'h00;
    end
  end
  
  //end Alu Section ---------------------------------------
  end
endmodule