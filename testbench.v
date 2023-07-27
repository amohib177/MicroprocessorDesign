

`timescale 1ns/1ps
`include "cu4.v"
module cpu_tb;
reg CLk, reset;
wire [3:0] PC;
reg [7:0] INSTRUCTION;
wire [1:0] muxsel_tb;
wire [7:0] imm_tb;
wire accwr_tb;
wire [2:0] rfaddr_tb;
wire [3:0] mmadr_tb;
wire rfwr_tb;
wire mmwr_tb;
wire [2:0] alusel_tb;
wire [1:0] shiftsel_tb;
wire outen_tb;
  reg zero_tb;
reg positive_tb;
wire  [7:0] input_tb = 8'b00111101;
wire [7:0] output_tb; 
wire[7:0] in;

// memory for 16 8 bit instructions.
reg[7:0] PM[15:0];

always@(PC)
begin
    #5
    
    INSTRUCTION <= PM[PC];
   
end

initial
begin
     PM[0] <= 8'b01010000; //LDI A,0
        PM[1] <= 8'b00000000;
        PM[2] <= 8'b00100000; //STA R[0]
        PM[3] <= 8'b01010000;
        PM[4] <= 8'b00001101;
        PM[5] <= 8'b00100001;
        PM[6] <= 8'b11110000;
        PM[7] <= 8'b00100010;
        PM[8] <= 8'b01110000;
        PM[9] <= 8'b00010001;
        PM[10] <= 8'b00010000;
        PM[11] <= 8'b11000001;
        PM[12] <= 8'b00100000;
        PM[13] <= 8'b00010010;
        PM[14] <= 8'b11100010;
        PM[15] <= 8'b00100010;
end

 cu cu_tb (
    .clk_ctrl(CLk),
    .rst_ctrl(reset),
    .muxsel_ctrl(muxsel_tb),
    .imm_ctrl(imm_tb),
    .accwr_ctrl(accwr_tb),
    .rfaddr_ctrl(rfaddr_tb),
    .mmadr_ctrl(mmadr_tb),
    .rfwr_ctrl(rfwr_tb),
    .mmwr_ctrl(mmwr_tb),
    .alusel_ctrl(alusel_tb),
    .shiftsel_ctrl(shiftsel_tb),
    .outen_ctrl(outen_tb),
    .zero_ctrl(zero_tb),
    .positive_ctrl(positive_tb),
    .INSTRUCTION(INSTRUCTION),

    .input_ctrl(input_tb),
    .output_ctrl(output_tb),
    .PC(PC)
  );
   
   initial
   begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, cpu_tb);

CLk= 1'b1;

reset= 1'b0;

#5
reset= 1'b1;

#10
reset= 1'b0;

#500


$finish;
   end


   always@(mmadr_tb,mmwr_tb)
   begin
   PM[mmadr_tb]= imm_tb;

   if (mmwr_tb) begin
    PM[mmadr_tb] = output_tb;

   end
   end

   always
   begin
    #5
   CLk = ~ CLk;
   end
endmodule
