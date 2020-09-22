// gb80_tb.v

module gb80_tb;

  reg  clk, reset;
  reg [7:0] nxt_inst [0:7];
  reg [7:0] inst;
  wire memory_rd, memory_wr;
  wire [15:0] memory_addr;
  
  wire [1:0]  nxt_cycle_cnt;
  reg  [1:0]  cycle_cnt;
  reg  [3:0]  inst_addr;

  // duration for each bit = 20 * timescale = 20 * 1 ns  = 20ns
  localparam period = 20;  

  gb80_processor UUT (
    .i_clk         (clk),
    .i_reset       (reset),
    .i_memory_data (inst),
    
    //FIXME: Not yet implemented...
    .o_memory_rd   (memory_rd),
    .o_memory_wr   (memory_wr),
    .o_memory_addr (memory_addr)
  );
    
  initial begin // initial block executes only once
    reset     = 1'b1;
    
    #120
    
    reset = 1'b0;
    
    cycle_cnt = 2'b00;
    inst_addr = 3'b000;
    
    nxt_inst[0] = 8'b00000000;
    // Load immediate into reg A
    nxt_inst[1] = 8'b00111110;
    nxt_inst[2] = 8'b10101010;
    //Store reg A to B
    nxt_inst[3] = 8'b01000111;
    //Store reg A to C
    nxt_inst[4] = 8'b01001111;
    //Store reg A to D
    nxt_inst[5] = 8'b01010111;
    //Store reg A to E
    nxt_inst[6] = 8'b01011111;
    //Store reg A to H
    nxt_inst[7] = 8'b01100111;
    //Store reg A to L
    nxt_inst[8] = 8'b01101111;
  end

  // clock period = 20 ns
  always begin
      clk = 1'b1; 
      #period; // high for 20 * timescale = 20 ns

      clk = 1'b0;
      #period; // low for 20 * timescale = 20 ns
  end

  assign nxt_cycle_cnt = cycle_cnt + 1'b1;
  always @(posedge clk) begin
    cycle_cnt <= nxt_cycle_cnt;
    
    // Select register
    if (cycle_cnt == 2'b11) begin
      inst_addr <= inst_addr + 1'b1;
    end
    
    inst <= nxt_inst[inst_addr];
  end
  
endmodule