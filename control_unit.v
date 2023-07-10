module cu(
   input clk_ctrl,
    input rst_ctrl,
    output [1:0] muxsel_ctrl,
    output [7:0] imm_ctrl,
    output accwr_ctrl,
    output [2:0] rfaddr_ctrl,
     output [3:0] mmadr_ctrl,
    output rfwr_ctrl,
    output mmwr_ctrl,
    output [2:0] alusel_ctrl,
    output [1:0] shiftsel_ctrl,
    output outen_ctrl,
    input zero_ctrl,
    input positive_ctrl,
    input [7:0] INSTRUCTION,
    output [4:0] PC
    

);
reg[7:0] input_ctrl;
wire [7:0] output_ctrl; 
reg zero_flag;
reg positive_flag;


parameter S0 = 5'b00000;
  parameter S1 = 5'b00001;
  parameter S2 = 5'b00010;
  parameter S10 = 5'b00011;
  parameter S11 = 5'b00100;
  parameter S12 = 5'b00101;
  parameter S13 = 5'b00110;
  parameter S14 = 5'b00111;
  parameter S21 = 5'b01000;
  parameter S22 = 5'b01001;
  parameter S23 = 5'b01010;
  parameter S24 = 5'b01011;
  parameter S30 = 5'b01100;
  parameter S31 = 5'b01101;
  parameter S32 = 5'b01110;
  parameter S33 = 5'b01111;
  parameter S41 = 5'b10000;
  parameter S42 = 5'b10001;
  parameter S43 = 5'b10010;
  parameter S44 = 5'b10011;
  parameter S45 = 5'b10100;
  parameter S46 = 5'b10101;
  parameter S99 = 5'b10110;
  parameter S51 = 5'b10111;
  parameter S52 = 5'b11000;
  parameter S8 = 5'b11001;
  parameter S9 = 5'b11010;

  reg[4:0] state;

  always @(posedge rst_ctrl or posedge clk_ctrl) begin
    if (rst_ctrl) begin
        PC = 0;
        muxsel_ctrl <= 2'b00;
        imm_ctrl <= 8'b0;
        accwr_ctrl <= 1'b0;
        rfaddr_ctrl <= 3'b000;
        rfwr_ctrl <= 1'b0;
        alusel_ctrl <= 3'b000;
        shiftsel_ctrl <= 2'b00;
        outen_ctrl <= 1'b0;
        mmadr_ctrl<= 4'b0000;
        mmwr_ctrl<= 1'b0;
        state <= S1;
    end
     else if (clk_ctrl) 
      begin
        case (state)
  //fetch instruction
            S1: begin
                IR <= PM[PC];
                OPCODE <= IR[7:4];
                PC = PC + 1;
                muxsel_ctrl <= 2'b00;
                imm_ctrl <= 8'b0;
                accwr_ctrl <= 1'b0;
                rfaddr_ctrl <= 3'b000;
                rfwr_ctrl <= 1'b0;
                alusel_ctrl <= 3'b000;
                shiftsel_ctrl <= 2'b00;
                outen_ctrl <= 1'b0;
                mmadr_ctrl<= 4'b0000;
                mmwr_ctrl<= 1'b0;
                state<= s2;
            end


            //decode instruction
            S2:
                begin 
               case(OPCODE)
                  4'b0000: state <=  S1; // NOP
            4'b0001: state <=  S10; // LDA
            4'b0010: state <=  S11; // STA
            4'b0011: state <=  S12; // LDM
            4'b0100: state <= S13; // STM
            4'b0101: state <=  S14; // LDI
            4'b0110: state <= S210; // JMP
            4'b0111: state <=  S220; // JZ
            4'b1000: state <= S230; // JNZ
            4'b1001: state <= S240; // JP
            4'b1010: state <=  S30; // ANDA
            4'b1011: state <= S31; // ORA
            4'b1100: state <=  S32; // ADD
            4'b1101: state <=  S33; // SUB
            4'b1110: begin // SOI
 		case (IR[2:0])
                3'b000: state <= S41; // NOTA
                3'b001: state <= S42; // INC
                3'b010: state <= S43; // DEC
                3'b011: state <= S44; // SHFL
                3'b100: state <= S45; // SHFR
                3'b101: state <= S46; // ROTR
                default: state <= S99;
              endcase
            end
              4'b1111: begin // MISC
              case (IR[1:0])
                2'b00: state <= S51; // INA
                2'b01: state <=  S52; // OUTA
                2'b10: state <=  S99; // HALT
                default: state <= S99;  
              endcase  
            end
            default: state <= S99;

            endcase
          muxsel_ctrl <= 2'b00;
          imm_ctrl <= 8'b00000000;
          accwr_ctrl <= 1'b0;
          rfaddr_ctrl <= 3'b000;
          rfwr_ctrl <= 1'b0;
          alusel_ctrl <= 3'b000;
          shiftsel_ctrl <= 2'b00;
          outen_ctrl <= 1'b0;
          mmadr_ctrl<= 4'b0000;
          mmwr_ctrl<= 1'b0;
        end

        //set zero and positive flags and then goto next instruction
       S8:
       begin
         muxsel_ctrl <= 2'b00;
         IN= 8'b0;
         imm_ctrl <= 8'b00000000;
         accwr_ctrl <= 1'b0;
          rfaddr_ctrl <= 3'b000;
          rfwr_ctrl <= 1'b0;
          alusel_ctrl <= 3'b000;
          shiftsel_ctrl <= 2'b00;
          outen_ctrl <= 1'b0;
           mmadr_ctrl<= 4'b0000;
          mmwr_ctrl<= 1'b0;
          state <= S1;
     
          zero_flag <= zero_ctrl;
          positive_flag <= positive_ctrl;
       end
      S9:   //next instruction
      begin
         muxsel_ctrl <= 2'b00;
         imm_ctrl <= 8'b00000000;
         accwr_ctrl <= 1'b0;
          rfaddr_ctrl <= 3'b000;
          rfwr_ctrl <= 1'b0;
          alusel_ctrl <= 3'b000;
          shiftsel_ctrl <= 2'b00;
          outen_ctrl <= 1'b0;
           mmadr_ctrl<= 4'b0000;
          mmwr_ctrl<= 1'b0;
          state <=S1;
      end
          S10:  //LDA 
          begin
    	muxsel_ctrl <= 2'b01;
          imm_ctrl <= 8'b00000000;
	accwr_ctr <= 1'b1;
        rfaddr_ctrl <= IR[2:0];
	rfwr_ctrl <= 1'b0;
       alusel_ctrl <= 3'b000;
          shiftsel_ctrl <= 2'b00;
          outen_ctrl <= 1'b0;
           mmadr_ctrl<= 4'b0000;
          mmwr_ctrl<= 1'b0;
         state <= S8;
          end
     S11: //STA
     begin
        muxsel_ctrl <= 2'b00;
         imm_ctrl <= 8'b00000000;
         accwr_ctrl <= 1'b0;
          rfaddr_ctrl <=IR[2:0] ;
          rfwr_ctrl <= 1'b1;
          alusel_ctrl <= 3'b000;
          shiftsel_ctrl <= 2'b00;
          outen_ctrl <= 1'b0;
          mmadr_ctrl<= 4'b0000;
          mmwr_ctrl<= 1'b0;
          state <=S1;
     end
    
    S12: //LDM
    begin
        muxsel_ctrl <= 2'b11;
         accwr_ctrl <= 1'b1;
          rfaddr_ctrl <=3'b000 ;
          rfwr_ctrl <= 1'b1;
          alusel_ctrl <= 3'b000;
          shiftsel_ctrl <= 2'b00;
          outen_ctrl <= 1'b0;
           mmadr_ctrl<= IR[3:0];
          mmwr_ctrl<= 1'b0;
          state <=S9;
    end


     S13: //STM
     begin
         imm_ctrl <= 8'b00000000;
         accwr_ctrl <= 1'b1;
          rfaddr_ctrl <=3'b000 ;
          rfwr_ctrl <= 1'b1;
          alusel_ctrl <= 3'b000;
          shiftsel_ctrl <= 2'b00;
          outen_ctrl <= 1'b0;
           mmadr_ctrl<= IR[3:0];
          mmwr_ctrl<= 1'b1;
          state <=S9;
     end

     S14: //LDI
     begin
         muxsel_ctrl <= 2'b10;
         input_ctrl <= {4'b0000,IR[3:0]};
         accwr_ctrl <= 1'b1;
          rfaddr_ctrl <=3'b000;
          rfwr_ctrl <= 1'b0;
          alusel_ctrl <= 3'b000;
          shiftsel_ctrl <= 2'b00;
          outen_ctrl <= 1'b0;
           mmadr_ctrl<= 4'b0000;
          mmwr_ctrl<= 1'b0;
          state <=S8;
     end
  
  S210: //JMP
     begin
       if(IR[3:0]==4'b0000)
         begin
         //absolute
        IR <= PM[PC];  //get next byte for absolute address
        PC = IR[3:0];
         end
        else if(IR[3] == 1'b0)
        begin  
	//relative positive
         //minus 1 because PC has already incremented
          PC = PC + {1'b0, IR[2:0]} - 1;
         end  
	else 
          begin
        //relative negative
	  PC = PC - {1'b0, IR[2:0]} - 1;
          end
        muxsel_ctrl <= 2'b00;
        imm_ctrl <= 8'b00000000;
        rfaddr_ctrl <=3'b000 ;
          rfwr_ctrl <= 1'b0;
          alusel_ctrl <= 3'b000;
          shiftsel_ctrl <= 2'b00;
          outen_ctrl <= 1'b0;
           mmadr_ctrl<= 4'b0000;
          mmwr_ctrl<= 1'b0;
          state <=S1;
     end
  
   S220: //JZ
   
     if(zero_flag==1'b1) begin
            if (zero_flag)
            begin
                if (IR[3:0] == 4'b0000)
                begin
                    IR <= PM[PC];
                    PC <= IR[3:0];
                end
                else if (IR[3] == 1'b0)
                begin
                    PC <= PC + {1'b0, IR[2:0]} - 1;
                end
                else
                begin
                    PC <= PC - {1'b0, IR[2:0]} - 1;
                end
            end
     
        
	
	muxsel_ctrl <= 2'b00;
	imm_ctrl <= 8'b00000000;
	accwr_ctrl <= 1'b0;
	rfaddr_ctrl <= 3'b000;
	rfwr_ctrl <= 1'b0;
	alusel_ctrl <= 3'b000;
	shiftsel_ctrl <= 2'b00;	
	outen_ctrl <= 1'b0;
     mmadr_ctrl<= 4'b0000;
          mmwr_ctrl<= 1'b0;
	state <= S1; 
     end
       
    S230: //JNZ
    begin
      if (zero_flag == 1'b0)
        begin                       
          if (IR[3:0] == 4'b0000)
            begin                 //absolute
              IR <= PM[PC];  //get next byte for absolute address
              PC <= IR[3:0];
            end
          else if (IR[3] == 1'b0) //relative positive 
            begin      //minus 1 because PC has already incremented
              PC <= PC + {1'b0, IR[2:0]} - 1;
            end
          else         //relative negative
            begin
              PC <= PC - {1'b0, IR[2:0]} - 1;
            end
        end

	muxsel_ctrl <= 2'b00;
	imm_ctrl <= 6'b000000;
	accwr_ctrl <= 1'b0;
	rfaddr_ctrl <= 3'b000;
	rfwr_ctrl <= 1'b0;
	alusel_ctrl <= 3'b000;
	shiftsel_ctrl <= 2'b00;
	outen_ctrl <= 1'b0;
     mmadr_ctrl<= 4'b0000;
          mmwr_ctrl<= 1'b0;
	state <= S1;
   end

   S240:  //JP
    begin
      if (positive_flag)  
        begin
          if (IR[3:0] == 4'b0000)
            begin                //absolute
              IR <= PM[PC];	 //get next byte for absolute address
              PC <= IR[4:0];
            end
          else if (IR[3] == 1'b0)  //relative positive
            begin //minus 1 because PC has already increamented
              PC <= PC + {1'b0, IR[2:0]} - 1;
            end
          else //relative negative
            begin
              PC <= PC - {1'b0, IR[2:0]} - 1;
            end
        end
    
	muxsel_ctrl <= 2'b00;
	imm_ctrl <= 8'b0;
	accwr_ctrl <= 1'b0;
	rfaddr_ctrl <= 3'b000;
	rfwr_ctrl <= 1'b0;
	alusel_ctrl <= 3'b000;
	shiftsel_ctrl <= 2'b00;
	outen_ctrl <= 1'b0;
     mmadr_ctrl<= 4'b0000;
          mmwr_ctrl<= 1'b0;
	state <= S1;
   
  end
  
   S30:		//ANDA
        begin
            muxsel_ctrl <= 2'b00;
            imm_ctrl <= 8'b0;
            rfaddr_ctrl <= IR[2:0];
            rfwr_ctrl <= 1'b0;
            alusel_ctrl <= 3'b011;
            shiftsel_ctrl <= 2'b00;
            outen_ctrl <= 1'b0;
            accwr_ctrl <= 1'b1;		//write occurs IN the next cycle	
            mmadr_ctrl<= 4'b0000;
            mmwr_ctrl<= 1'b0;
            state <= S8;
        end 
    
    S31:
    begin		//ORA
      muxsel_ctrl <= 2'b00;
      imm_ctrl <= 8'b0;
      rfaddr_ctrl <= IR[2:0];
      rfwr_ctrl <= 1'b0;
      alusel_ctrl <= 3'b100;
      shiftsel_ctrl <= 2'b00;
      outen_ctrl <= 1'b0;
      accwr_ctrl <= 1'b1;
      mmadr_ctrl<= 4'b0000;
      mmwr_ctrl<= 1'b0;
      state <= S8;
      // state <= S9;
    end

     S32: begin   // ADD
      muxsel_ctrl <= 2'b00;
      imm_ctrl <= 8'b0;
      rfaddr_ctrl <= IR[2:0];
      rfwr_ctrl <= 1'b0;
      alusel_ctrl <= 3'b001;
      shiftsel_ctrl <= 2'b00;
      outen_ctrl <= 1'b0;
      accwr_ctrl <= 1'b1;
      mmadr_ctrl<= 4'b0000;
      mmwr_ctrl<= 1'b0;
      state <= S8;
     end
     S33: begin   // SUB
      muxsel_ctrl <= 2'b00;
      imm_ctrl <= 8'b0;
      rfaddr_ctrl <= IR[2:0];
      rfwr_ctrl <= 1'b0;
      alusel_ctrl <= 3'b010;
      shiftsel_ctrl <= 2'b00;
      outen_ctrl <= 1'b0;
      accwr_ctrl <= 1'b1;
      mmadr_ctrl<= 4'b0000;
      mmwr_ctrl<= 1'b0;
      state <= S8;
     end
      S41: begin  // NOTA 
      muxsel_ctrl <= 2'b00;
      imm_ctrl <= 8'b0;
      rfaddr_ctrl <= 3'b000;
      rfwr_ctrl <= 1'b0;
      alusel_ctrl <= 3'b101;
      shiftsel_ctrl <= 2'b00;
      outen_ctrl <= 1'b0;
      accwr_ctrl <= 1'b1;
      mmadr_ctrl<= 4'b0000;
      mmwr_ctrl<= 1'b0;
      state <= S8;
     end
     S42: begin  //INC
      muxsel_ctrl <= 2'b00;
      imm_ctrl <= 8'b0;
      rfaddr_ctrl <= 3'b000;
      rfwr_ctrl <= 1'b0;
      alusel_ctrl <= 3'b110;
      shiftsel_ctrl <= 2'b00;
      outen_ctrl <= 1'b0;
      accwr_ctrl <= 1'b1;
      mmadr_ctrl<= 4'b0000;
      mmwr_ctrl<= 1'b0;
      state <= S8;
    end
 
     S43: begin // DEC - OK
      muxsel_ctrl <= 2'b00;
      imm_ctrl <= 8'b0;
      rfaddr_ctrl <= 3'b000;
      rfwr_ctrl <= 1'b0;
      alusel_ctrl <= 3'b111;
      shiftsel_ctrl <= 2'b00;
      outen_ctrl <= 1'b0;
      accwr_ctrl <= 1'b1;
      mmadr_ctrl<= 4'b0000;
      mmwr_ctrl<= 1'b0;
    state <= S8;
    end

     S44: begin // SHFL
      muxsel_ctrl <= 2'b00;
      imm_ctrl <= 8'b0;
      rfaddr_ctrl <= 3'b000;
      rfwr_ctrl <= 1'b0;
      alusel_ctrl <= 3'b000;
      shiftsel_ctrl <= 2'b01;
      outen_ctrl <= 1'b0;
      accwr_ctrl <= 1'b1;
      mmadr_ctrl<= 4'b0000;
      mmwr_ctrl<= 1'b0;
      state <= S8;
  end
     S45: begin // SHFR - OK
      muxsel_ctrl <= 2'b00;
      imm_ctrl <= 8'b0;
      rfaddr_ctrl <= 3'b000;
      rfwr_ctrl <= 1'b0;
      alusel_ctrl <= 3'b000;
      shiftsel_ctrl <= 2'b10;
      outen_ctrl <= 1'b0;
      accwr_ctrl <= 1'b1;
      mmadr_ctrl<= 4'b0000;
      mmwr_ctrl<= 1'b0;
      state <= S8;
  end
     S46: begin // ROTR - ??
      muxsel_ctrl <= 2'b00;
      imm_ctrl <= 8'b0;
      rfaddr_ctrl <= 3'b000;
      rfwr_ctrl <= 1'b0;
      alusel_ctrl <= 3'b000;
      shiftsel_ctrl <= 2'b11;
      outen_ctrl <= 1'b0;
      accwr_ctrl <= 1'b1;
      mmadr_ctrl<= 4'b0000;
      mmwr_ctrl<= 1'b0;
      state <= S8;
  end
     S51: begin // INA
      muxsel_ctrl <= 2'b10;
      imm_ctrl <= 8'b0;
      rfaddr_ctrl <= 3'b000;
      rfwr_ctrl <= 1'b0;
      alusel_ctrl <= 3'b000;
      shiftsel_ctrl <= 2'b00;
      outen_ctrl <= 1'b0;
      accwr_ctrl <= 1'b1;
      mmadr_ctrl<= 4'b0000;
      mmwr_ctrl<= 1'b0;
      state <= S8;
  end
  
     S52: begin
      // OUTA
      muxsel_ctrl <= 2'b00;
      imm_ctrl <= 32'b0;
      accwr_ctrl <= 1'b0;
      rfaddr_ctrl <= 3'b000;
      rfwr_ctrl <= 1'b0;
      alusel_ctrl <= 3'b000;
      shiftsel_ctrl <= 2'b00;
      outen_ctrl <= 1'b1;
      mmadr_ctrl<= 4'b0000;
      mmwr_ctrl<= 1'b0;
      state <= S1;
    end

     S99: begin
      // HALT
      muxsel_ctrl <= 2'b00;
      imm_ctrl <= 32'b0;
      accwr_ctrl <= 1'b0;
      rfaddr_ctrl <= 3'b000;
      rfwr_ctrl <= 1'b0;
      alusel_ctrl <= 3'b000;
      shiftsel_ctrl <= 2'b00;
      outen_ctrl <= 1'b0;
      mmadr_ctrl<= 4'b0000;
      mmwr_ctrl<= 1'b0;
      state <= S99;
    end

    default: begin
      // OTHERS
      muxsel_ctrl <= 2'b00;
      imm_ctrl <= 32'b0;
      accwr_ctrl <= 1'b0;
      rfaddr_ctrl <= 3'b000;
      rfwr_ctrl <= 1'b0;
      alusel_ctrl <= 3'b000;
      shiftsel_ctrl <= 2'b00;
      outen_ctrl <= 1'b0;
      state <= S99;
    end
  endcase
end
  end
datapath mydata_cpu(
    .clk_dp(clk_ctrl) ,   
    .rst_dp(rst_ctrl) ,   
    .muxsel_dp(muxsel_ctrl) , 
    .imm_dp(imm_ctrl),  
    .input_dp(input_ctrl),  
    .accwr_dp (accwr_ctrl) ,
    .rfaddr_dp(rfaddr_ctrl),
    .mmadr_dp(mmadr_ctrl),
    .mmwr_dp(mmwr_ctrl),
    .rfwr_dp(rfwr_ctrl)  , 
    .alusel_dp(alusel_ctrl), 
    .shiftsel_dp(shiftsel_ctrl), 
    .outen_dp(outen_ctrl), 
    .zero_dp(zero_ctrl), 
    .positive_dp(positive_ctrl),
    .output_dp(output_ctrl)
 );
  
endmodule
