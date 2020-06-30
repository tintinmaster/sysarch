module MIPScore(
	input clk,
	input reset,
	// Kommunikation Instruktionsspeicher
	output [31:0] pc,
	input  [31:0] instr,
	// Kommunikation Datenspeicher
	output        memwrite,
	output [31:0] aluout, writedata,
	input  [31:0] readdata
);
	wire        alusrcbimm, regwrite, dojump, dobranch, zero;
	wire [4:0] destreg;
	wire [2:0] alucontrol;
	wire  memtoreg, lui;
	wire	domul, multoreg, lohi;
  wire jal;
	


	Decoder decoder(instr, zero, memtoreg, memwrite,
					dobranch, alusrcbimm, destreg,
					regwrite, dojump, alucontrol, lui, 
					domul, multoreg, lohi, jal);
	Datapath dp(clk, reset, memtoreg, dobranch,
				alusrcbimm, destreg, regwrite, dojump,
				alucontrol,
				zero, pc, instr,
				aluout, writedata, readdata, lui, 
				domul, multoreg, lohi, jal);
endmodule

