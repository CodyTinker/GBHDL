//--------------------------------------------------------------------------------//
//  Project Name : GB80                                                           //
//  Module Name  : decoder.v                                                      //
//  Create Date  : August, 2016                                                   //
//  Author       : Kevin Millar                                                   //
//                 Cody Tinker                                                    //
//                                                                                //
//  Description:   Processor Decoder module.                                      //
//                                                                                //
//  Dependencies:  None                                                           //
//                                                                                //
//--------------------------------------------------------------------------------//
//  Revision 0.02 - Initial decoder/control logic block                           //
//--------------------------------------------------------------------------------//
module decoder #(
  parameter                 DATA_WIDTH = 8,
  parameter                 ADDR_WIDTH = 3
  //parameter                 OPCODE_TYPE_LENGTH=4
)(
  input                     i_clk,
  input                     i_reset,
  //Dara bus
  input [DATA_WIDTH-1:0]    i_data,
  //Control
  output                    o_mem_rd_en,
  output                    o_reg_rd_en,
  output                    o_reg_wr_en,
  output [ADDR_WIDTH-1:0]   o_reg_rd_addr,
  output [ADDR_WIDTH-1:0]   o_reg_wr_addr,
  output                    o_alu_rd_en,
  output [ADDR_WIDTH-1:0]   o_alu_addr
);

  // FIXME: Values are currently arbitrary
  // Opcode Type
  localparam OP_NOP        = 0;
  localparam OP_HALT       = 1;
  localparam OP_LD_REG_IMM = 2;
  localparam OP_LD_REG_REG = 3;
  localparam OP_LD_REG_MEM = 4;
  localparam OP_LD_MEM_REG = 5;
  localparam OP_ALU_REG    = 6;
  localparam OP_ALU_MEM    = 7;
  //localparam OP_CB_PREFIX  = 8'hCB;
  
  // Instruction States
  localparam S_RESET         = 0;
  localparam S_IDLE          = 1;
  localparam S_DECODE        = 2;
  localparam S_WAIT          = 3;
  localparam S_LOAD_REG_A    = 4;
  localparam S_LOAD_REG_Z    = 5;
  localparam S_STORE_REG_A   = 6;
  localparam S_STORE_REG_REG = 7;
  localparam S_STORE_IMM     = 8;

  wire [1:0]           opcode_x;
  wire [2:0]           opcode_y;
  wire [2:0]           opcode_z;
  
  wire [2:0]           opcode_p;
  wire                 opcode_q;
  
  reg [7:0]            nxt_opcode_type;
  reg [7:0]            opcode_type;
  reg [7:0]            nxt_state;
  reg [7:0]            state;
  
  reg [DATA_WIDTH-1:0] opcode;
  
  wire [1:0]           nxt_cycle_cnt;
  reg  [1:0]           cycle_cnt;
  
  reg                  mem_rd_en;
  reg                  reg_rd_en;
  reg                  reg_wr_en;
  reg [ADDR_WIDTH-1:0] reg_rd_addr;
  reg [ADDR_WIDTH-1:0] reg_wr_addr;
  reg                  alu_rd_en;
  reg [ADDR_WIDTH-1:0] alu_addr; 
  reg                  opcode_en;
  
  assign opcode_x = i_data[7:6];
  assign opcode_y = i_data[5:3];
  assign opcode_z = i_data[2:0];
  assign opcode_p = i_data[5:4];
  assign opcode_q = i_data[3];

  always @(*) begin : decodeProcess
    case (opcode_x)
      2'b00 : begin
        if (opcode_z == 3'b110) begin
          nxt_opcode_type = OP_LD_REG_IMM;
        end else begin
          nxt_opcode_type = OP_NOP; //FIXME: Others ignored for now
        end
      end
      2'b01 : begin
        if (opcode_y == 3'b110) begin
          if (opcode_z == 3'b110) begin
            nxt_opcode_type = OP_HALT;
          end else begin
            nxt_opcode_type = OP_LD_MEM_REG;
          end
        end else begin
          if (opcode_z == 3'b110) begin
            nxt_opcode_type = OP_LD_REG_MEM;
          end else begin
            nxt_opcode_type = OP_LD_REG_REG;
          end
        end
      end
      2'b10 : begin
        if (opcode_z == 3'b110) begin
            nxt_opcode_type = OP_ALU_MEM;
          end else begin
            nxt_opcode_type = OP_ALU_REG;
          end
      end
      default : nxt_opcode_type = OP_NOP; //FIXME: Edit as more implemented
    endcase
  end
  
  // Count clock cycles for each machine cycle( cycles)
  assign nxt_cycle_cnt = cycle_cnt + 1'b1;
  always @(posedge i_clk) begin : clkProcess
    if (i_reset) begin
      state     <= S_RESET;
      cycle_cnt <= 2'b11;
    end else begin
      state     <= nxt_state;
      cycle_cnt <= nxt_cycle_cnt;
    end
    
    if (opcode_en) begin
      opcode      <= i_data;
      opcode_type <= nxt_opcode_type;
    end
  end
  
  always @(*) begin : nxtStateProcess
    case (state)
      S_RESET : begin
        if (i_reset) begin
          nxt_state = S_RESET;
        end else begin
          nxt_state = S_IDLE;
        end
      end
      S_IDLE : begin
        if (cycle_cnt == 2'b11) begin
          nxt_state = S_DECODE; 
        end else begin
          nxt_state = S_IDLE;
        end
      end
      S_DECODE : begin
        case (nxt_opcode_type) // FIXME: nxt_opcode_type ?
          OP_LD_REG_REG : nxt_state = S_STORE_REG_REG;
          OP_ALU_REG    : nxt_state = S_LOAD_REG_Z;
          OP_LD_REG_IMM : nxt_state = S_WAIT;
          default : nxt_state = S_IDLE;
        endcase
      end
      S_LOAD_REG_Z : begin
        case (opcode_type)
          OP_ALU_REG : nxt_state = S_LOAD_REG_A;
          default : nxt_state = S_IDLE;
        endcase
      end
      S_WAIT : begin
        if (cycle_cnt == 2'b11) begin
          case (opcode_type)
            OP_LD_REG_IMM : nxt_state = S_STORE_IMM;
            default : nxt_state = S_IDLE;
          endcase
        end else begin
          nxt_state = S_WAIT;
        end
      end
      S_LOAD_REG_A : begin
        case (opcode_type)
          OP_ALU_REG : nxt_state = S_STORE_REG_A;
          default : nxt_state = S_IDLE;
        endcase
      end
      S_STORE_REG_REG : begin
        case (opcode_type)
          OP_LD_REG_REG : nxt_state = S_IDLE;
          default : nxt_state = S_IDLE;
        endcase
      end
      S_STORE_REG_A : begin
        case (opcode_type)
          OP_ALU_REG : nxt_state = S_IDLE;
          default : nxt_state = S_IDLE;
        endcase
      end
      S_STORE_IMM : begin
        case (opcode_type)
          OP_LD_REG_IMM : nxt_state = S_IDLE;
          default : nxt_state = S_IDLE;
        endcase
      end
      default : nxt_state = S_IDLE;
    endcase
  end
  
  always @(posedge i_clk) begin : outputProcess
    mem_rd_en   = 1'b0;
    reg_rd_en   = 1'b0;
    reg_wr_en   = 1'b0;
    reg_rd_addr = 3'b000;
    reg_wr_addr = 3'b000;
    alu_rd_en   = 1'b0;
    alu_addr    = 3'b000;
    opcode_en   = 1'b0;
    case (nxt_state)
      S_DECODE : begin
        mem_rd_en    = 1'b1;
        opcode_en    = 1'b1;
      end
      S_LOAD_REG_Z : begin
        reg_rd_en   = 1'b1;
        reg_rd_addr = i_data[2:0]; //FIXME: need t-state in state description?
      end
      S_STORE_REG_REG : begin
        reg_rd_en   = 1'b1;
        reg_wr_en   = 1'b1;
        reg_rd_addr = i_data[2:0];
        reg_wr_addr = i_data[5:3];
      end
      S_LOAD_REG_A : begin
        reg_rd_en   = 1'b1;
        reg_rd_addr = 3'b111; // A
        alu_addr    = opcode[5:3];
      end
      S_STORE_REG_A : begin
        reg_wr_en   = 1'b1;
        reg_wr_addr = 3'b111; // A
        alu_rd_en   = 1'b1;
      end
      S_STORE_IMM : begin
        mem_rd_en   = 1'b1; // n
        reg_wr_en   = 1'b1;
        reg_wr_addr = opcode[5:3];
      end
    endcase
  end
  
  assign o_mem_rd_en   = mem_rd_en;
  assign o_reg_rd_en   = reg_rd_en;
  assign o_reg_wr_en   = reg_wr_en;
  assign o_reg_rd_addr = reg_rd_addr;
  assign o_reg_wr_addr = reg_wr_addr;
  assign o_alu_rd_en   = alu_rd_en;
  assign o_alu_addr    = alu_addr; 
  
endmodule