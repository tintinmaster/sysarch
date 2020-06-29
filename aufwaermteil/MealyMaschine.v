module MealyPattern(
	input        clock,
	input        i,
	output [1:0] o
);

//HIER WAR DAS TODO, FALLS ES ZU FEHLERN KOMMT :)
reg ff1, ff2, ff3;

always @(posedge clock)
		begin
			ff1 <= i;
			ff2 <= ff1;
			ff3 <= ff2;
			$display("reg: %d%d%d", ff2, ff1, i);
		end

	assign o[1] = (i & !ff2 & !ff3);
	assign o[0] = (i & ff1 & ff3);

endmodule

module MealyPatternTestbench();
//HIER WAR DAS TODO, FALLS ES ZU FEHLERN KOMMT :)
reg clk;
reg [9:0] inp;
reg currInp;
reg [3:0] c;
wire [1:0] out;

//initialisieren	
initial 
	begin
		inp = 10'b1001100111;
		clk = 0;
		c = 0;
		$dumpfile("mealy.vcd");
		$dumpvars;
	end

	MealyPattern machine(.clock(clk), .i(currInp), .o(out));	

	//eigentlicher Tester (einfaches matchen)
	initial
	begin
		currInp = 1'b0;
		clk <= 1;
		clk <= 0;
		#5;
		clk <= 1;
		clk <= 0;
		#20
		$display("\n start \n");
		
		currInp = inp[0];
		clk <= 0;
		clk <= 1;
		#1;
		$display("out: %d%d", out[0],out[1]);
		if (out[1] != 1 | out[0] != 0)
			$display("fault on zero");

		currInp = inp[1];
		clk <= 0;
		clk <= 1;
		#1;
		$display("out: %d%d", out[0],out[1]);
		if (out[1] != 0 | out[0] != 0)
			$display("fault on one");

		currInp = inp[2];
		clk <= 0;
		clk <= 1;
		#1;
		$display("out: %d%d", out[0],out[1]);
		if (out[1] != 0 | out[0] != 1)
			$display("fault on two");

		currInp = inp[3];
		clk <= 0;
		clk <= 1;
		#1;
		$display("out: %d%d", out[0],out[1]);
		if (out[1] != 0 | out[0] != 0)
			$display("fault on three");

		currInp = inp[4];
		clk <= 0;
		clk <= 1;
		#1;
		$display("out: %d%d", out[0],out[1]);
		if (out[1] != 0 | out[0] != 0)
			$display("fault on four");

		currInp = inp[5];
		clk <= 0;
		clk <= 1;
		#1;
		$display("out: %d%d", out[0],out[1]);
		if (out[1] != 1 | out[0] != 0)
			$display("fault on five");
		
		currInp = inp[6];
		clk <= 0;
		clk <= 1;
		#1;
		$display("out: %d%d", out[0],out[1]);
		if (out[1] != 0 | out[0] != 0)
			$display("fault on six");

		currInp = inp[7];
		clk <= 0;
		clk <= 1;
		#1;
		$display("out: %d%d", out[0],out[1]);
		if (out[1] != 0 | out[0] != 0)
			$display("fault on seven");

		currInp = inp[8];
		clk <= 0;
		clk <= 1;
		#1;
		$display("out: %d%d", out[0],out[1]);
		if (out[1] != 0 | out[0] != 0)
			$display("fault on eight");

		currInp = inp[9];
		clk <= 0;
		clk <= 1;
		#1;
		$display("out: %d%d", out[0],out[1]);
		if (out[1] != 1 | out[0] != 0)
			$display("fault on nine");

	end


endmodule

