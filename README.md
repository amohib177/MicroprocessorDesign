# MicroprocessorDesign
IITSoC'23 Electrical Project

This Design is consist of three parts:
1.Datapath
2.Control_Unit 
3.Testbenches

1.Datapath: 
     It execute all the instructions in the instruction set.This project has datapath at register-transfer level.It consist of following 
     things.
 
   1) Input multiplexer
      
  The 4-to-1 input mux at the top of the datapath drawing selects one of four different inputs to be written into the accumulator. These
four inputs, starting from the left, are: (1) imm_dp for getting the immediate value from the LDI instruction and storing it into the
accumulator; (2) input_dp for getting a user input value for the IN instruction; (3) the next input selection allows the content of the
register file to be written to the accumulator as used by the LDA instruction; (4) allows the result of the ALU and the shifter to be
 written to the accumulator as used by all the arithmetic and logical instructions. 
  
 2) Conditional Flags
    
   The two conditional flags, zero and positive, are set by two comparators that check the value at the output of the mux which is the 
   value that is to be written into the accumulator for these two conditions. To check for a value being zero, recall that just a NOR 
   gate will do. In our case, we need an eight-input NOR gate because of the 8-bit wide databus. To check for a positive number, we 
   simply need to look at the most significant sign bit. A 2’s complement positive number will have a zero sign bit, so a single inverter 
   connected to the most significant bit of the databus is all that is needed to generate this positive flag signal.
   
 3) Accumulator
    
   It is a standard 8-bit wide register with a write 'wr' and 'clear' clear control input signals. The write signal, connected to 
   accwr_dp, is asserted whenever we want to write a value into the accumulator. The clear signal is connected to the main computer reset
   signal rst_dp, so that the accumulator is always cleared on reset. The content of the accumulator is always available at the
   accumulator output. The value from the accumulator is sent to three different places: (1) it is sent to the output buffer for the OUT 
   instruction; (2) it is used as the first (A) operand for the ALU; and (3) it is sent to the input of the register file for the STA 
   instruction. 

4) Register File
    
    This register file has eight locations, each 8-bits wide. Three address lines, rfaddr_dp2, rfaddr_dp1, rfaddr_dp0, are used to
    address the eight locations for both reading and writing. There are one read port and one write port. The read port is always active
     which means that it always has the value from the currently selected address location. However, to write to the selected location,
    the write control line rfwr_dp must be asserted before a value is written to the currently selected address location. Note that a
   separate read and write address lines is not required because all the instructions either perform just a read from the register file
    or a write to the register file. There is no one instruction that performs both a read and a write to the register file. Hence, only
   one set of address lines is needed for determining both the read and write locations.
   
5)ALU
  This ALU has eight operations . PASS,AND,OR,NOT,ADDITION,SUBSTRACTION,INCREMENT,DECREMENT The operations are selected by the three 
  select lines alusel_dp2, alusel_dp1, and alusel_dp0.
  
6)Shifter
  This Shifter has four operations .SHIFT RIGHT,SHIFT LEFT,NO CHANGE,ROTATE RIGHT The operations are selected by the two select lines 
  shiftsel_dp1, and shiftsel_dp0.

7)Output buffer
   The output buffer is a register with an enable control signal connected to outen_dp. Whenever the enable line is asserted, the output
   from the accumulator is stored into the buffer. The value stored in the output buffer is used as the output for the computer and is 
   always available. The enable line is asserted either by the OUT A instruction or by the system reset signal. 


2.Control Unit:
   the control unit asserts the control signals to the datapath. This finite-state machine cycles through three main steps or states: 1) 
   fetch an instruction; 2) decode the instruction; and 3) execute the instruction. The control unit performs these steps by sending the 
   appropriate control signals to the datapath or to external devices. 

   step 1 (fetch an instruction) usually involves the control unit setting up a memory address on the address bus and telling the 
   external memory to output the instruction from that memory location onto the data bus. The control unit then reads the instruction
   from the data bus

   For step 2 (decode the instruction) the control unit extracts the opcode bits from the instruction and determines what the current
   instruction is by jumping to the state that has been assigned for executing that instruction. Once in that particular state, the 
   finite-state machine performs step 3 by simply asserting the appropriate control signals for controlling the datapath to execute that 
   instruction. 

   In Control unit used instructions are takes from standerd refrence

   Some Major Points of Insturction:

   1) Two Operand Instructions 
If the instruction requires two operands, it always uses the accumulator (A) for one operand. If the second operand is a register then 
the last three bits in the encoding specifies the register file number. An example of this is the LDA (load accumulator from register) 
instruction where it loads the accumulator with the content of the register file number specified in the last three bits of the encoding.
Another example is the ADD (add) instruction where it adds the content of the accumulator with the content of the specified register file
and put the result in the accumulator. The result of all arithmetic and logical operations is stored in the accumulator. The LDI (load 
accumulator with immediate value) is also a two-operand instruction. However, the second operand is an immediate value that is obtained 
from the second byte of the instruction itself (iiiiiiii). These eight bits are interpreted as a signed number and is loaded into the
accumulator. 

 2) One Operand Instructions 
One-operand instructions always use the accumulator and the result is stored back in the accumulator. In this case, the last four bits
in the encoding are used to further decode the instruction. An example of this is the INC (increment accumulator) instruction. The
opcode (1110) is used by all the one-operand arithmetic and logical instructions. The last four bits (0001) specify the INC instruction. 

 4) Instructions Using a Memory Address 
For instructions that have a memory address as one of its operand, an additional six bits are needed in order to access the 64 bytes of
memory space. These six bits (aaaaaa) are specified in the six least significant bits of the second byte of the instruction. An example
is the LDM (load accumulator from memory) instruction. The address of the memory location where the data is to be loaded from is
specified in the second byte. In this case, the last four bits of the first byte and the first two bits in the second byte are not used
and are always set to 0. All the absolute jump instructions follow this format.

4) Jump Instructions 
For jump instructions, the last four bits of the encoding also serves to differentiate between absolute and relative jumps. If the last
four bits are zeros, then it is an absolute jump, otherwise, they represent a sign and magnitude format relative displacement from the
current location as specified in the program counter (PC). 

   
3.TestBenches
   It is used to verify and implement the code   


 
