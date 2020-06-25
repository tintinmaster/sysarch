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
	input  [31:0] readdata
);
	wire [31:0] pc;
	wire [31:0] signimm;
	wire [31:0] srca, srcb, srcbimm;
	wire [31:0] result;

	// Fetch: Reiche PC an Instruktionsspeicher weiter und update PC
	ProgramCounter pcenv(clk, reset, dobranch, signimm, jump, instr[25:0], pc);

	// Execute:
	// (a) Wähle Operanden aus
	SignExtension se(instr[15:0], signimm);
	assign srcbimm = alusrcbimm ? signimm : srcb;
	// (b) Führe Berechnung in der ALU durch
	ArithmeticLogicUnit alu(srca, srcbimm, alucontrol, aluout, zero);
	// (c) Wähle richtiges Ergebnis aus
	assign result = memtoreg ? readdata : aluout;

	// Memory: Datenwort das zur (möglichen) Speicherung an den Datenspeicher übertragen wird
	assign writedata = srcb;

	// Write-Back: Stelle Operanden bereit und schreibe das jeweilige Resultat zurück
	RegisterFile gpr(clk, regwrite, instr[25:21], instr[20:16],
				   destreg, result, srca, srcb);
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

module Adder(
	input  [31:0] a, b,
	input         cin,
	output [31:0] y,
	output        cout
);
	assign {cout, y} = a + b + cin;
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
	wire [31:0] w1;
	wire w2;
	// TODO Implementierung der ALU
	case (alucontrol)
		3'b000:
			begin
				//0^31 (a < b?1:0)
				if (a < b)
					begin
						assign result = {31{1'b0}, 1b'1};
						assign zero = 1'b0;
					end 
				else
					begin
						assign result = {32{1b'0}};
						assign zero = 1'b1;
					end
			end
		3'b001:
			begin
				//a - b
				assign {w2, w1} = a - b;
				//signed beachten????
				//result an w2 anpassen?
				assign result = w1;
				if (result == {32{1'b0}})
					assign zero = 1'b1;
				else 
					assign zero = 1'b0;
			end
		3'b101:
			begin
				assign {w2, w1} = a + b;
				//result an w2 anpassen???????
				assign result = w1;
				if (result == {32{1'b0}})
					assign zero = 1'b1;
				else 
					assign zero = 1'b0;
			end
		3'b110:
			begin
				//a|b
				assign result = a|b;
				if (result == {32{1'b0}})
					assign zero = 1'b1;
				else 
					assign zero = 1'b0;
			end
		3'111:
			begin
				//a&b
				assign result = a&b;
				if (result == {32{1'b0}})
					assign zero = 1'b1;
				else 
					assign zero = 1'b0;
			end
	endcase

endmodule

//ALU teilweise implementiert / verhalten bei overflow? / signed für subtraktion?
//ALU anhand der alucontrol codes implementiert, das Verhalten für andere codes ist wie in der Aufgabe gesagt undefiniert. 
//Bei der Addition und subtraktion kann es zu einem overflow kommen, dieser bit ist zwar abgefangen, aber es ist noch nicht implementiert, wie mit ihm umgegangen wird, da result eine Länge von 32bit hat.
//Subtraktion momentan noch unsigned