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
//  Revision 0.02 - Created basic connections between blocks                      //
//--------------------------------------------------------------------------------//
module gb80_processor(
  input                             i_clk,
  input                             i_reset,
  input  [7:0]                      i_memory_data,
  output [7:0]                      o_memory_data,
  output                            o_memory_rd,
  output                            o_memory_wr,
  output [15:0]                     o_memory_addr
);

  localparam DATA_WIDTH   = 8;
  localparam ADDR_WIDTH   = 3;
  localparam OPCODE_WIDTH = 3;

  //Global Signal and Bus definitons
  wire [DATA_WIDTH-1:0]    data_bus;
  wire [DATA_WIDTH-1:0]    tmp_reg_data_out;
  wire                     pc_wr_en;
  wire                     sp_wr_en;
  wire                     memory_rd_en;
  
  // Register File Signals
  wire                    reg_wr_en;
  wire [ADDR_WIDTH-1:0]   reg_wr_addr;
  wire                    reg_rd_en;
  wire [ADDR_WIDTH-1:0]   reg_rd_addr;
  wire [DATA_WIDTH-1:0]   reg_data_out;
  wire                    reg_flags_wr_en;
  wire [3:0]              reg_flags_out;
  wire                    reg_addr_wr_en;
  wire                    reg_addr_rd_en;
  wire [ADDR_WIDTH-1:0]   reg_addr_addr_in;
  wire [DATA_WIDTH*2-1:0] reg_addr_data_in;
  wire [DATA_WIDTH*2-1:0] reg_addr_data_out;
  
  // ALU Signals
  wire                    alu_rd_en;
  wire [2:0]              alu_addr;
  wire [DATA_WIDTH-1:0]   alu_data_out;
  wire [3:0]              alu_flags_out;
  
  assign data_bus = (i_memory_data & {DATA_WIDTH{memory_rd_en}}) | reg_data_out | alu_data_out;

  // Temporary Register (always holds previous data bus value...)
  register #(
  .DATA_WIDTH(DATA_WIDTH)
  ) tmp_register_inst (
  .i_clk(i_clk),
  .i_reset(i_reset),
  .i_we(1'b1),
  .i_data(data_bus),
  .o_data(tmp_reg_data_out)
  );
  
  // Decoder
  decoder #(
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH)
  ) decoder_inst (
    .i_clk            (i_clk),
    .i_reset          (i_reset),
    .i_data           (data_bus),
    .o_mem_rd_en      (memory_rd_en),
    .o_reg_rd_en      (reg_rd_en),
    .o_reg_wr_en      (reg_wr_en),
    .o_reg_rd_addr    (reg_rd_addr), 
    .o_reg_wr_addr    (reg_wr_addr), 
    .o_alu_rd_en      (alu_rd_en),
    .o_alu_addr       (alu_addr)
  );
  
  // Register File
  register_file #(
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH)
  ) register_file_inst (
    // Control Signals
    .i_clk          (i_clk),
    .i_reset        (i_reset),
    .i_pc_wr_en     (pc_wr_en),
    .i_sp_wr_en     (sp_wr_en),
    // Data Register Signals
    .i_reg_wr_en    (reg_wr_en),
    .i_reg_rd_en    (reg_rd_en),
    .i_reg_data     (data_bus),
    .i_reg_rd_addr  (reg_rd_addr),
    .i_reg_wr_addr  (reg_wr_addr),
    .o_reg_data     (reg_data_out),
    // Flag Signals
    .i_flags        (alu_flags_out),
    .i_flags_wr_en  (reg_flags_wr_en),
    .o_flags        (reg_flags_out),
    // Address Register Signals
    .i_addr_wr_en   (reg_addr_wr_en),
    .i_addr_rd_en   (reg_addr_rd_en),
    .i_addr_addr    (reg_addr_addr_in),
    .i_addr_data    (reg_addr_data_in),
    .o_addr_data    (reg_addr_data_out)
  );
  
  // Address Increment
  // FIXME: Create dedicated b-bit increment/decrement block
  n_bit_adder #(
  .DATA_WIDTH(DATA_WIDTH*2)
  ) addr_inc_inst (
  .i_data_A(reg_addr_data_out),
  .i_data_B(16'h0001),
  .i_carry(1'b0),
  .o_sum(reg_addr_data_in),
  .o_half_carry(), // Unconnected
  .o_carry() //Unconnected
  );
  
  // ALU
  // Latency = 1 cycle
  // Assumption: Accumulator register (A) is always read in second
  // TODO: If latency is increased to 2, read of register A to be replaced by
  //  direct register input instead of data bus read
  alu #(
    .OPCODE_WIDTH (OPCODE_WIDTH),
    .DATA_WIDTH   (DATA_WIDTH)
  ) alu_inst (
    .i_clk        (i_clk),
    .i_data_A     (data_bus),
    .i_data_B     (tmp_reg_data_out),
    .i_data_rd_en (alu_rd_en),
    .i_control    (alu_addr),
    .i_flags      (reg_flags_out),
    .o_data       (alu_data_out),
    .o_flags      (alu_flags_out)
  );
  
  assign o_memory_addr = reg_addr_data_out;
  assign o_memory_data = data_bus;
  
endmodule