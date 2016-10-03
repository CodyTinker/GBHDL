//--------------------------------------------------------------------------------//
//  Project Name : GB80                                                           //
//  Module Name  : controller_sequencer.v                                          //
//  Create Date  : August, 2016                                                   //
//  Author       : Kevin Millar                                                   //
//                 Cody Tinker                                                    //
//                                                                                //
//  Description:   Processor Controller Sequencer.                                //
//                                                                                //
//  Dependencies:  None                                                           //
//                                                                                //
//--------------------------------------------------------------------------------//
//  Revision 0.01 - File Created                                                  //
//--------------------------------------------------------------------------------//
module controller_sequencer #(
  parameter                             OPCODE_TYPE_LENGTH = 4,
  parameter                             ALU_OPCODE_WIDTH = 3,
  parameter                             ADDR_LENGTH = 3,
  parameter                             DATA_WIDTH = 8
)(
  input                                 i_clk,
  input                                 i_reset,
  
  //decoder pins
  input [OPCODE_TYPE_LENGTH-1:0]        i_opcode_type,
  input [DATA_WIDTH-1:0]                i_literal_value_in,
  input [ADDR_LENGTH-1:0]               i_addr_A,
  input [ADDR_LENGTH-1:0]               i_addr_B,
  
  //control pins
  //register interface:         
  output reg [ADDR_LENGTH-1:0]          o_register_file_addr,
  output reg                            o_register_file_wr,
  output reg                            o_register_file_addr_wr,
  output reg                            o_register_file_rd,
  output reg                            o_register_file_addr_rd,
  
  
  //alu:
  output reg                            o_accumulator_reg_wr,
  output reg                            o_tmp_reg_wr,
  output reg                            o_tmp_reg_rd,
  output reg [ALU_OPCODE_WIDTH-1:0]     o_alu_control,
  output reg                            o_alu_rd,
  output reg                            o_flags_reg_rd,
  //output maybe flags_reg_wr
  
  //memory:
  output reg                            o_wr_mem,
  output reg                            o_rd_mem
  
);

  //Define states
  //Primitive states
  localparam S_RESET = 0;
  localparam S_IDLE = 1;
  localparam S_NULL_CYCLE = 2;
  
  //Fetch sequence
  //T1 : PC OUT
  //T2 : PC = PC + 1
  //T3 : INST > INST_REG
  localparam S_FETCH_PC_OUT = 4;
  localparam S_FETCH_PC_INC = 5;
  localparam S_FETCH_STORE_INST_REG = 6;
  //localparam S_FETCH_NULL = 7;
  
  //8-bit Loads
  //LD r, n
  
  //LD r, r'
  localparam S_LD_REG_REG_STORE_TEMP = 8;
  localparam S_LD_REG_REG_LOAD_TEMP_REG = 9;
  
  
  
  //Define opcode types
  localparam OP_LD_REG_REG = 0;
  
  
  reg [7:0] state;
  
  reg [OPCODE_TYPE_LENGTH-1:0] opcode_reg;
  reg [DATA_WIDTH-1:0] literval_value_reg;
  reg [ADDR_LENGTH-1:0] addr_A_reg;
  reg [ADDR_LENGTH-1:0] addr_B_reg; 
  
  
  // States:
  //  S_RESET
  //  S_IDLE
  //  S_NULL_CYCLE
  // Fetch sequence
  //  S_FETCH_PC_OUT
  //  S_FETCH_PC_INC
  //  S_FETCH_STORE_INST_REG
  // 8-bit Loads
  //  S_LD_REG_REG_STORE_TEMP
  //  S_LD_REG_REG_LOAD_TEMP_REG
  
  //State machine transistion logic
  always@(posedge i_clk) begin
    if (i_reset) begin
      state <= S_RESET;
    end else begin
      case (state) 
        //Reset and Idle states
        S_RESET                     : state <= S_IDLE;
        S_IDLE                      : state <= S_FETCH_PC_OUT;
        S_NULL_CYCLE                : state <= S_IDLE; //Don't remember why I added this
        
        //Fetch new instruction
        S_FETCH_PC_OUT              : state <= S_FETCH_PC_INC;
        S_FETCH_PC_INC              : state <= S_FETCH_STORE_INST_REG;
        S_FETCH_STORE_INST_REG      : begin
                                      case (i_opcode_type) 
                                        OP_LD_REG_REG: state <= S_LD_REG_REG_STORE_TEMP;
                                        default : state <= S_IDLE;
                                      endcase
                                      end
        
        //LD r, r'
        S_LD_REG_REG_STORE_TEMP     : state <= S_LD_REG_REG_LOAD_TEMP_REG;
        S_LD_REG_REG_LOAD_TEMP_REG  : state <= S_FETCH_PC_INC;  
      endcase
    end
  end

  //Decoder data register storing
  always@(posedge i_clk) begin
    if (i_reset) begin
      opcode_reg <= {OPCODE_TYPE_LENGTH{1'b0}};
      literval_value_reg <= {DATA_WIDTH{1'b0}};
      addr_A_reg <= {ADDR_LENGTH{1'b0}};
      addr_B_reg <= {ADDR_LENGTH{1'b0}}; 
    end else begin
      case (state)
        S_FETCH_STORE_INST_REG      : begin
                                      opcode_reg <= i_opcode_type;
                                      literval_value_reg <= i_literal_value_in;
                                      addr_A_reg <= i_addr_A;
                                      addr_B_reg <= i_addr_B; 
                                      end
        default                     : begin
                                      opcode_reg <= opcode_reg;
                                      literval_value_reg <= literval_value_reg;
                                      addr_A_reg <= addr_A_reg;
                                      addr_B_reg <= addr_B_reg; 
                                      end
      endcase
    end
  end
  
  //State machine output logic-----------------------------
  
  //o_register_file_addr
  //o_register_file_wr
  //o_register_file_rd
  //o_tmp_reg_wr
  //o_tmp_reg_rd
  always@(*) begin 
    case (state)
      //Fetch sequence
      S_FETCH_PC_OUT                : begin
                                      //register interface outputs (8)
                                      o_register_file_addr <= {{(ADDR_LENGTH-3){1'b0}}, 3'h3};
                                      o_register_file_wr <= 1'b0;
                                      o_register_file_addr_wr <= 1'b0;
                                      o_register_file_rd <= 1'b0;
                                      o_register_file_addr_rd <= 1'b1;
                                      o_accumulator_reg_wr <= 1'b0;
                                      o_tmp_reg_wr <= 1'b0;
                                      o_tmp_reg_rd <= 1'b0;
                                      
                                      //alu outputs (3)
                                      o_alu_control <= {ALU_OPCODE_WIDTH{1'b0}};
                                      o_alu_rd <= 1'b0;
                                      o_flags_reg_rd <= 1'b0;
                                      
                                      //memory outputs (2)
                                      o_wr_mem <= 1'b0;
                                      o_rd_mem <= 1'b1;
                                      end
      S_FETCH_PC_INC                : begin
                                      //register interface outputs (8)
                                      o_register_file_addr <= {{(ADDR_LENGTH-3){1'b0}}, 3'h3};
                                      o_register_file_wr <= 1'b0;
                                      o_register_file_addr_wr <= 1'b1;
                                      o_register_file_rd <= 1'b0;
                                      o_register_file_addr_rd <= 1'b1;
                                      o_accumulator_reg_wr <= 1'b0;
                                      o_tmp_reg_wr <= 1'b0;
                                      o_tmp_reg_rd <= 1'b0;
                                      
                                      //alu outputs (3)
                                      o_alu_control <= {ALU_OPCODE_WIDTH{1'b0}};
                                      o_alu_rd <= 1'b0;
                                      o_flags_reg_rd <= 1'b0;
                                      
                                      //memory outputs (2)
                                      o_wr_mem <= 1'b0;
                                      o_rd_mem <= 1'b0;
                                      end
      S_FETCH_STORE_INST_REG        : begin //Do nothing since instruction register always writes (should probably change)
                                      //register interface outputs (8)
                                      o_register_file_addr <= {ADDR_LENGTH{1'b0}};
                                      o_register_file_wr <= 1'b0;
                                      o_register_file_addr_wr <= 1'b0;
                                      o_register_file_rd <= 1'b0;
                                      o_register_file_addr_rd <= 1'b0;
                                      o_accumulator_reg_wr <= 1'b0;
                                      o_tmp_reg_wr <= 1'b0;
                                      o_tmp_reg_rd <= 1'b0;
                                      
                                      //alu outputs (3)
                                      o_alu_control <= {ALU_OPCODE_WIDTH{1'b0}};
                                      o_alu_rd <= 1'b0;
                                      o_flags_reg_rd <= 1'b0;
                                      
                                      //memory outputs (2)
                                      o_wr_mem <= 1'b0;
                                      o_rd_mem <= 1'b0;
                                      end
                                      
      //Load reg-reg
      S_LD_REG_REG_STORE_TEMP       : begin
                                      //register interface outputs (8)
                                      o_register_file_addr <= i_addr_B;
                                      o_register_file_wr <= 1'b0;
                                      o_register_file_addr_wr <= 1'b0;
                                      o_register_file_rd <= 1'b1;
                                      o_register_file_addr_rd <= 1'b0;
                                      o_accumulator_reg_wr <= 1'b0;
                                      o_tmp_reg_wr <= 1'b1;
                                      o_tmp_reg_rd <= 1'b0;
                                      
                                      //alu outputs (3)
                                      o_alu_control <= {ALU_OPCODE_WIDTH{1'b0}};
                                      o_alu_rd <= 1'b0;
                                      o_flags_reg_rd <= 1'b0;
                                      
                                      //memory outputs (2)
                                      o_wr_mem <= 1'b0;
                                      o_rd_mem <= 1'b0;
                                      end
      S_LD_REG_REG_LOAD_TEMP_REG    : begin
                                      //register interface outputs (8)
                                      o_register_file_addr <= i_addr_A;
                                      o_register_file_wr <= 1'b1;
                                      o_register_file_addr_wr <= 1'b0;
                                      o_register_file_rd <= 1'b0;
                                      o_register_file_addr_rd <= 1'b0;
                                      o_accumulator_reg_wr <= 1'b0;
                                      o_tmp_reg_wr <= 1'b0;
                                      o_tmp_reg_rd <= 1'b1;
                                      
                                      //alu outputs (3)
                                      o_alu_control <=
                                      o_alu_rd <= 1'b0;
                                      o_flags_reg_rd <= 1'b0;
                                      
                                      //memory outputs (2)
                                      o_wr_mem <= 1'b0;
                                      o_rd_mem <= 1'b0;
                                      end
                                      
      default                       : begin
                                      //register interface outputs (8)
                                      o_register_file_addr <= {ADDR_LENGTH{1'b0}};
                                      o_register_file_wr <= 1'b0;
                                      o_register_file_addr_wr <= 1'b0;
                                      o_register_file_rd <= 1'b0;
                                      o_register_file_addr_rd <= 1'b0;
                                      o_accumulator_reg_wr <= 1'b0;
                                      o_tmp_reg_wr <= 1'b0;
                                      o_tmp_reg_rd <= 1'b0;
                                      
                                      //alu outputs (3)
                                      o_alu_control <= {ALU_OPCODE_WIDTH{1'b0}};
                                      o_alu_rd <= 1'b0;
                                      o_flags_reg_rd <= 1'b0;
                                      
                                      //memory outputs (2)
                                      o_wr_mem <= 1'b0;
                                      o_rd_mem <= 1'b0;
                                      end
    endcase
  end
 
  
  


endmodule