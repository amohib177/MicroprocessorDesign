module datapath(
  //ports
  input clk_dp ,   //clock
  input rst_dp ,   //reset
  input [1:0] muxsel_dp ,  //2isto1 Multiplexer
  input [7:0] imm_dp,  //internal memory data
  input [7:0] input_dp,  //direct input
  input accwr_dp  , //accumulator writeport sel
  input [2:0] rfaddr_dp,  //registerfileaddress sel(for 8 register files)
  input rfwr_dp  , //registerfile write port 
  input [2:0] alusel_dp, //ALU operation selector
  input [1:0] shiftsel_dp, //Shifter operation sel
  input outen_dp, //enable o/p
  output zero_dp, //check if input is zero
  output positive_dp, // check if input is positive
  output [7:0] output_dp // output port 
);
  wire [7:0] C_muxout; //Multiplexer output
  wire [7:0] C_accout;  //Accumulator output
  wire [7:0] C_aluout;  //ALU output
  wire [7:0] C_rfout;  //registerfile output
  wire [7:0] C_shiftout; // Shifter output
  wire C_outen;
 
 mux4 mux_dp ( //Multiplexer instantiation
    .sel_mux(muxsel_dp),
    .in3_mux(imm_dp),
    .in2_mux(input_dp),
    .in1_mux(C_rfout),
    .in0_mux(C_shiftout),
    .out_mux(C_muxout)
  );

 
  acc acc_dp ( //Accumulator instantiation
    .clk_acc(clk_dp),
    .rst_acc(rst_dp),
    .wr_acc(accwr_dp),
    .input_acc(C_muxout),
    .output_acc(C_accout)
  );

  
  reg_file reg_file_dp ( //RegisterFile instantiation
    .clk_rf(clk_dp),
    .wr_rf(rfwr_dp),
    .addr_rf(rfaddr_dp),
    .input_rf(C_accout),
    .output_rf(C_rfout)
  );

  
  alu alu_dp ( //ALU instantiation
    .sel_alu(alusel_dp),
    .inA_alu(C_accout),
    .inB_alu(C_rfout),
    .OUT_alu(C_aluout)
  );

 shifter shifter_dp ( //Shifter Instantiation
    .sel_shift(shiftsel_dp),
    .input_shift(C_aluout),
    .output_shift(C_shiftout)
  );
  
 assign C_outen = outen_dp | rst_dp; //

  tristatebuffer tristatebuffer_inst_dp (
    .E(C_outen),
    .D(C_accout),
    .Y(output_dp)
  );

  assign zero_dp = (C_muxout == 8'b00000000) ? 1'b1 : 1'b0;
  assign positive_dp = ~C_muxout[7];

endmodule

module mux4 (
  input [1:0] sel_mux,
  input [7:0] in3_mux,
  input [7:0] in2_mux,
  input [7:0] in1_mux,
  input [7:0] in0_mux,
  output reg [7:0] out_mux
);
  always @* begin
    case (sel_mux)
      2'b00: out_mux = in0_mux;
      2'b01: out_mux = in1_mux;
      2'b10: out_mux = in2_mux;
      2'b11: out_mux = in3_mux;
      default: out_mux = 8'b0;
    endcase
  end
endmodule

module acc (
  input clk_acc,
  input rst_acc,
  input wr_acc,
  input [7:0] input_acc,
  output reg [7:0] output_acc
);
  always @(posedge clk_acc or posedge rst_acc) begin
    if (rst_acc) begin
      output_acc <= 8'b0;
    end
    else begin
      if (wr_acc) begin
        output_acc <= input_acc;
      end
    end
  end
endmodule

module reg_file (
  input clk_rf,
  input wr_rf,
  input [2:0] addr_rf,
  input [7:0] input_rf,
  output reg [7:0] output_rf
);
  reg [7:0] regs_rf [0:7];

  always @(posedge clk_rf) begin
    if (wr_rf) begin
      regs_rf[addr_rf] <= input_rf;
    end
  end

  always @* begin
    output_rf = regs_rf[addr_rf];
  end
endmodule

module alu (
  input [2:0] sel_alu,
  input [7:0] inA_alu,
  input [7:0] inB_alu,
  output reg [7:0] OUT_alu
);
  always @* begin
    case (sel_alu)
      3'b000: OUT_alu = inA_alu;
      3'b001: OUT_alu = inA_alu + inB_alu;
      3'b010: OUT_alu = inA_alu - inB_alu;
      3'b011: OUT_alu = inA_alu & inB_alu;
      3'b100: OUT_alu = inA_alu | inB_alu;
      3'b101: OUT_alu = ~inA_alu;
      3'b110: OUT_alu = inA_alu + 1;
      3'b111: OUT_alu = inA_alu - 1;
      default: OUT_alu = 8'b0;
    endcase
  end
endmodule

module shifter (
  input [1:0] sel_shift,
  input [7:0] input_shift,
  output reg [7:0] output_shift
);
  always @* begin
    case (sel_shift)
      2'b00: output_shift = input_shift ;
      2'b01: output_shift = input_shift << 1;
      2'b10: output_shift = input_shift >> 1;
      2'b11: output_shift = {input_shift[0],input_shift[7:1]};
      default: output_shift = 8'b0;
    endcase
  end
endmodule

module tristatebuffer (
  input E,
  input [7:0] D,
  output [7:0] Y
);
  assign Y = (E == 1'b1) ? D : 8'bz;
endmodule
