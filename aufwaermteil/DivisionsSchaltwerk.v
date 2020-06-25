module Division(
	input         clock,
	input         start,
	input  [31:0] a,
	input  [31:0] b,
	output [31:0] q,
	output [31:0] r
);

	reg [31:0] forR;
	reg [31:0] forB;
	reg [31:0] forA;
	integer rStrich;
	integer count;

	// TODO Implementierung
	always @(posedge clock)
	begin
		if (start == 1) begin
			forR <= 31'b0;
			forB <= b;
			forA <= a;
			count <= 0;
		end
		else begin
			if (count < 31)
				count = count + 1;
			if (count == 32)
				$display("over");
			else begin
				rStrich = (r << 2) + a[count];
				$display("R reg:");
				$display(forR);
				$display("B reg");
				$display(forB);
				if (rStrich < forB) begin
					forA[count] = 0;
					forR = rStrich;
				end else begin
					forA[count] = 1;
					forR = rStrich - forB;
				end
			end
		end
	end
	assign q = forA;
	assign r = forR;
endmodule
