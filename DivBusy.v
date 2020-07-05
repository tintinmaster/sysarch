module Division(
	input         clock,
	input         start,
	input  [31:0] a,
	input  [31:0] b,
	output [31:0] q,
	output [31:0] r,
	output busy
);

	reg [31:0] forR, forA, forB;
	reg bizzy;
	integer rStrich, count;

	// TODO Implementierung
	always @(posedge clock)
	begin
		if (start == 1) 
		begin
			//$display("start");
			forR <= 32'b0;
			forB <= b;
			forA <= a;
			count <= 31;
			bizzy = 1;
		end
		else begin
			//$display("count: %d, forA: %b, forB: %b, forR: %b", count, forA, forB, forR);
			if (count == 0)
				bizzy = 0;
			if (count > 0)
			begin
				count = count - 1;
				rStrich = (r << 1) + a[count];
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
	assign busy = bizzy;
	assign q = forA;
	assign r = forR;
endmodule
