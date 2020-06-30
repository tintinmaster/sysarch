module Datapath(
	input         clk, reset,
	input         memtoreg,
	input         dobranch,
	input         alusrcbimm,
	input  [4:0]  destreg,
	input         regwrite,
	input         jump,
	input  [2:0]  alucontrol,
	output        zero,
	output [31:0] pc,
	input  [31:0] instr,
	output [31:0] aluout,
	output [31:0] writedata,
	input  [31:0] readdata,
	input 		  lui,
	input domul,
	input multoreg,
	input lohi,
  input jal
);
	wire [31:0] pc;
	wire [31:0] signimm;
	wire [31:0] srca, srcb, srcbimm;
	wire [31:0] result;
	wire [31:0] luiout;
	wire [63:0] mmout;
	wire [31:0] lo;
	wire [31:0] hi;

	// Fetch: Reiche PC an Instruktionsspeicher weiter und update PC
	ProgramCounter pcenv(clk, reset, dobranch, signimm, jump, instr[25:0], pc);

	// Execute:
	// (a1) Wähle Operanden aus
	SignExtension se(instr[15:0], signimm);   //--> immediate wird in signimm geladen
	// (a2) LUI möglichst simultan zu signext eigentlich...
	LUI lu(instr[15:0], luiout);
	assign srcbimm = alusrcbimm ? signimm : srcb;
	// (b1) Führe Berechnung in der ALU durch
	ArithmeticLogicUnit alu(srca, srcbimm, alucontrol, aluout, zero);
	// (b2) Führe MUL berechnung aus
	Multi m(srca, srcbimm, mmout);
	// (c) Wähle richtiges Ergebnis aus
	assign result = jal ? (pc+4) : (multoreg ? (lohi ? hi : lo) : (lui ? luiout : (memtoreg ? readdata : aluout)));
	// Memory: Datenwort das zur (möglichen) Speicherung an den Datenspeicher übertragen wird
	assign writedata = srcb;
	// Write-Back: Stelle Operanden bereit und schreibe das jeweilige Resultat zurück
	RegisterFile gpr(clk, regwrite, instr[25:21], instr[20:16],
				   destreg, result, srca, srcb); 
	SpecialRegisterFile specr(clk, domul, mmout, lo, hi);
endmodule

module ProgramCounter(
	input         clk,
	input         reset,
	input         dobranch,
	input  [31:0] branchoffset,
	input         dojump,
	input  [25:0] jumptarget,
	output [31:0] progcounter
);
	reg  [31:0] pc;
	wire [31:0] incpc, branchpc, nextpc;

	// Inkrementiere Befehlszähler um 4 (word-aligned)
	Adder pcinc(.a(pc), .b(32'b100), .cin(1'b0), .y(incpc));
	// Berechne mögliches (PC-relatives) Sprungziel
	Adder pcbranch(.a(incpc), .b({branchoffset[29:0], 2'b00}), .cin(1'b0), .y(branchpc));
	// Wähle den nächsten Wert des Befehlszählers aus
	assign nextpc = dojump   ? {incpc[31:28], jumptarget, 2'b00} :
					dobranch ? branchpc :
							   incpc;

	// Der Befehlszähler ist ein Speicherbaustein
	always @(posedge clk)
	begin
		if (reset) begin // Initialisierung mit Adresse 0x00400000
			pc <= 'h00400000;
		end else begin
			pc <= nextpc;
		end
	end

	// Ausgabe
	assign progcounter = pc;

endmodule

module RegisterFile(
	input         clk,
	input         we3,
	input  [4:0]  ra1, ra2, wa3,
	input  [31:0] wd3,
	output [31:0] rd1, rd2
);
	reg [31:0] registers[31:0];

	always @(posedge clk)
		if (we3) begin
			registers[wa3] <= wd3;
		end

	assign rd1 = (ra1 != 0) ? registers[ra1] : 0;
	assign rd2 = (ra2 != 0) ? registers[ra2] : 0;
endmodule

module SpecialRegisterFile(
	input clk,
	input mul_we,
	input [63:0]	mulres,
	output [31:0]	lo_r, hi_r
);
	reg [31:0] specialRegisters[1:0];

	always @(posedge clk)
		if (mul_we) begin
			specialRegisters[0] <= mulres[31:0];
			specialRegisters[1] <= mulres[63:32];
		end
		
	assign lo_r = specialRegisters[0];
	assign hi_r = specialRegisters[1];

endmodule

module Adder(
	input  [31:0] a, b,
	input         cin,
	output [31:0] y,
	output        cout
);
	assign {cout, y} = a + b + cin;
endmodule

module LUI(
	input [15:0] i,
	output [31:0] o
);
	assign o = i << 16;
endmodule

module Multi(
	input [31:0] a, b,
	output [63:0] out
);
	assign out = a*b;
endmodule

module SignExtension(
	input  [15:0] a,
	output [31:0] y
);
	assign y = {{16{a[15]}}, a};
endmodule

module ArithmeticLogicUnit(
	input  [31:0] a, b,
	input  [2:0]  alucontrol,
	output [31:0] result,
	output        zero
);
	reg [31:0] w1;
	reg w2;
	reg [31:0] resreg;
	reg z;
	assign result = resreg;
	assign zero = z;
	always @*
	begin
	case (alucontrol)
		3'b000:
			begin
				//0^31 (a < b?1:0) SLT
				if (a < b)
					begin
						resreg = 32'b00000000000000000000000000000001;
						z = 1'b0;
					end 
				else
					begin
						resreg = 32'b00000000000000000000000000000000;
						z = 1'b1;
					end
			end
		3'b001:
			begin
				//a - b
				{w2, w1} = a - b;
				//result an w2 anpassen?
				resreg = w1;
				if (resreg == 32'b00000000000000000000000000000000)
					z = 1'b1;
				else 
					z = 1'b0;
			end
		3'b101:
			begin
				//a+b
				{w2, w1} = a + b;
				//result an w2 anpassen???????
				resreg = w1;
				if (resreg == 32'b00000000000000000000000000000000)
					z = 1'b1;
				else 
					z = 1'b0;
			end
		3'b110:
			begin
				//a|b
				resreg = (a|b);
				if (resreg == 32'b00000000000000000000000000000000)
					z = 1'b1;
				else 
					z = 1'b0;
			end
		3'b111:
			begin
				//a&b
				resreg = (a&b);
				if (resreg == 32'b00000000000000000000000000000000)
					z = 1'b1;
				else 
					z = 1'b0;
			end
	endcase
	end
endmodule

//ALU größtenteils implementiert / verhalten bei overflow? 
//ALU anhand der alucontrol codes implementiert, das Verhalten für andere codes ist wie in der Aufgabe gesagt undefiniert. 
//Bei der Addition und subtraktion kann es zu einem overflow kommen, dieser bit ist zwar abgefangen, aber es ist noch nicht implementiert, wie mit ihm umgegangen wird, da result eine Länge von 32bit hat.

