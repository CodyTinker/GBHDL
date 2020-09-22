// alu_tb.v

module alu_tb;

    reg clk, vz, vn, vh, vc;
    reg [7:0] a, b;
    reg [7:0] va, vb;
    reg [2:0] control;
    reg [2:0] vcontrol;
    reg [3:0] in_flags;
    wire [3:0] flags;
    reg [3:0] vflags;
    wire [7:0] out;
    reg [7:0] vout;

    // duration for each bit = 20 * timescale = 20 * 1 ns  = 20ns
    localparam period = 20;  

    alu #(
     .OPCODE_WIDTH(3),
     .DATA_WIDTH(8)
    ) UUT (
     .i_clk(clk),
     .i_data_A(a),
     .i_data_B(b),
     .i_flags(in_flags),
     .i_control(control),
     .o_data(out),
     .o_flags(flags)
    );
    
  initial begin// initial block executes only once
    // values for a, b, and control
    a = 8'hFF;
    b = 8'hFF;
    control = 3'b111;
    in_flags = 4'h1;
  end

  // clock period = 20 ns
  always begin
      clk = 1'b1; 
      #period; // high for 20 * timescale = 20 ns

      clk = 1'b0;
      #period; // low for 20 * timescale = 20 ns
  end

  always @(posedge clk) begin
    
    if (a == 8'hFF && b == 8'hFF) begin
      control <= control + 1;
    end
    
    // values for a and b
    if (a == 8'hFF) begin
      b <= b + 1;
    end
    a <= a + 1;
    
    va = a;
    vb = b;
    vflags = in_flags;
    vcontrol = control;
    
    case (vcontrol)
      3'b000 : begin
        vn = 1'b0;
        vh = (((va & 8'h0F) + (vb & 8'h0F)) & 8'h10) == 8'h10;
        {vc,vout} = va + vb;
      end
      3'b001 : begin
        vn = 1'b0;
        vh = ((((va & 8'h0F) + (vb & 8'h0F)) + vflags[0]) & 8'h10) == 8'h10;
        {vc,vout} = va + vb + vflags[0];
      end
      3'b010 : begin
        vn = 1'b1;
        vh = (va & 8'h0F) < (vb & 8'h0F);
        vc = va < vb;
        vout = va - vb;
      end
      3'b011 : begin
        vn = 1'b1;
        vout = va - vb - vflags[0];
        vh = (va & 8'h0F) < ((vb & 8'h0F) + {3'h0,vflags[0]});
        vc = {1'b0,va} < ({1'b0,vb} + {8'h00,vflags[0]});
      end
      3'b100 : begin
        vn = 1'b0;
        vh = 1'b0;
        {vc,vout} = va & vb;
      end
      3'b101 : begin
        vn = 1'b0;
        vh = 1'b0;
        {vc,vout} = va ^ vb;
      end
      3'b110 : begin
        vn = 1'b0;
        vh = 1'b0;
        {vc,vout} = va | vb;
      end
      3'b111 : begin
        vn = 1'b1;
        vh = (va & 8'h0F) < (vb & 8'h0F);
        vc = va < vb;
        vout = va - vb;
      end
    endcase
    
    // Wait for a period...
    #period;
    
    // Check output
    if (out != vout) begin
      $display("Test FAILED on output!!");
      $stop;
    end
    
    vz = (out == 8'h00);
    if (vz != flags[3]) begin
      $display("Test FAILED on Z flag!!");
      $stop;
    end
    
    if (vn != flags[2]) begin
      $display("Test FAILED on N flag!!");
      $stop;
    end
    
    if (vh != flags[1]) begin
      $display("Test FAILED on H flag!!");
      $stop;
    end
    
    if (vc != flags[0]) begin
      $display("Test FAILED on C flag!!");
      $stop;
    end
    
    if (a == 8'hFF && b == 8'hFF && control == 3'b111) begin
      $display("Test PASSED!!");
      $finish;
    end
  end
  
endmodule