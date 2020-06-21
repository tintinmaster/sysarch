module MealyPattern(
	input        clock,
	input        i,
	output [1:0] o
);

//HIER WAR DAS TODO, FALLS ES ZU FEHLERN KOMMT :)
reg p, q;
always @(posedge clock)
		begin
			p <= i;
			if (p == 'b1) 
				q <= 'b1;
			else
				q <= 'b0;
		end
	assign o[1] = i ? ((p & q) ? 1 : 0) : 0;
	assign o[0] = i ? ((p == 0) & (q == 0) ? 1 : 0) : 0;

endmodule

module MealyPatternTestbench();
//HIER WAR DAS TODO, FALLS ES ZU FEHLERN KOMMT :)
reg clk;
reg [9:0] inp;
reg currInp;
reg out;

//initialisieren	
initial 
	begin
		inp = 10'b1110011001;
		clk = 0;
		integer counter = 0;
	end

	//die clock
always 
	begin
		#2;
		clk = !clk;
	end

	//das inputten
	always @(posedge clk)
	begin
		#5;
		currInp = inp >> counter;
		counter = counter + 1;
	end

	MealyPattern machine(.clock(clk), .i(currInp), .o(out));

	//eigentlicher Tester (einfaches matchen)
	initial
	begin
		if (counter == 2)
			if (out[1] == 1 && out[0] == 0)
				$display("found first pattern correctly");
			else
				$display("didnt found first pattern");
		if (counter == 6)
			if (out[1] == 1 && out[0] == 0)
				$display("found second pattern correctly");
			else
				$display("didnt found second pattern");
		if (counter == 9) 
			if (out[0] == 0 && out[1] == 1)
				$display("found third pattern correctly");
			else
				$display("didnt third first pattern");
	end

	initial
	begin
		$dumpfile ("mealy.vcd");
		$dumpvars;
	end

	initial
	begin
		#100;
		$finish;
	end

endmodule

