module MealyPattern(
	input        clock,
	input        i,
	output [1:0] o
);

//HIER WAR DAS TODO, FALLS ES ZU FEHLERN KOMMT :)
reg ff1, ff2;

always @(posedge clock)
		begin
			ff1 <= i;
			ff2 <= ff1;
			$display("cycle");
			$display(i);
			$display(ff1);
			$display(ff2);
			$display("generated output");
			$display(ff1 & ff2 & i);
			$display(!ff1 & !ff2 & i);
		end
	assign o[1] = i ? ((ff1 & ff2) ? 1'b1 : 1'b0) : 1'b0;
	assign o[0] = i ? ((!ff1 & !ff2) ? 1'b1 : 1'b0) : 1'b0;

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

	//die clock
always 
	begin
		#5;
		clk = !clk;
	end

	MealyPattern machine(.clock(clk), .i(currInp), .o(out));	

	//eigentlicher Tester (einfaches matchen)
	initial
	begin
		currInp = inp[0];
		#10;
		if (out[0] != 0 || out[1] != 0) 
			$display("fault on 0");
		currInp = inp[1];
		#10;
		if (out[0] != 0 || out[1] != 0)
			$display("fault on 1");
		currInp = inp[2];
		#10;
		if (out[0] != 0 || out[1] != 1)
			$display("fault on 2");
		currInp = inp[3];
		#10;
		if (out[0] != 0 || out[1] != 0)
         $display("fault on 3");
      currInp = inp[4];
		#10;
		if (out[0] != 0 || out[1] != 0)
			$display("fault on 4");
      currInp = inp[5];
		#10;
		if (out[0] != 1 || out[1] != 0)
         $display("fault on 5");
		currInp = inp[6];
		#10;
		if (out[0] != 0 || out[1] != 0)
         $display("fault on 6");
      currInp = inp[7];
		#10;
		if (out[0] != 0 || out[1] != 0)
         $display("fault on 7");
      currInp = inp[8];
		#10;
		if (out[0] != 0 || out[1] != 0)
         $display("fault on 8");
      currInp = inp[9];
		#10;
		if (out[0] != 1 || out[1] != 0)
         $display("fault on 9");
		$finish;
	end


endmodule

