module MealyPattern(
	input        clock,
	input        i,
	output [1:0] o
);

//HIER WAR DAS TODO, FALLS ES ZU FEHLERN KOMMT :)
	reg p, q;
	always @(posedge clock)
	begin
		q = p;
		p = i;
	end
	assign o[0] = i ? ((p & q) ? 1 : 0) : 0;
	assign o[1] = i ? ((p == 0) & (q == 0) ? 1 : 0) : 0;
endmodule;

endmodule

module MealyPatternTestbench();
//HIER WAR DAS TODO, FALLS ES ZU FEHLERN KOMMT :)
	reg clk;
	reg counter;
	reg inp;

	assign inp = 10'b1110011001; 

	always 
	begin
		clk <= 1'b1; #2; clk 1'b0; #2;
	end

	always 
	begin
		(counter == 10) ? counter <= 0 : counter <= counter + 1; #4;
	end

	MealyPattern machine(.clock(clk), .i(inp[counter]), .o(2'b0));

	// TODO Überprüfe Ausgaben

endmodule

