module VgaTest
(
	input rst,
	input clk,

	output hsync,
	output vsync,
	output red,
	output green,
	output blue
);
	wire pixClk;
	pixclk _pixclk (
		.inclk0(clk),
		.c0(pixClk)
    );

	reg [11:0] hCounter;
	reg [11:0] vCounter;

/*parameter 	HOR_FRONT_PORCH 	= 40,
            HOR_SYNC_PULSE		= 128,
				HOR_BACK_PORCH		= 88,
				HOR_ACT_VIDEO 		= 800,
				VER_FRONT_PORCH 	= 1,
				VER_SYNC_PULSE		= 4,
				VER_BACK_PORCH		= 23,
				VER_ACT_VIDEO 		= 600;	*/
	parameter 	HOR_SYNC_PULSE	= 112,
					HOR_BACK_PORCH	= 248,
					HOR_ACT_VIDEO 	= 1280,
					HOR_FRONT_PORCH = 48,
					VER_SYNC_PULSE	= 3,
					VER_BACK_PORCH	= 38,
					VER_ACT_VIDEO 	= 1024,
					VER_FRONT_PORCH = 1;

	parameter	HOR_WHOLE = HOR_SYNC_PULSE + HOR_BACK_PORCH + HOR_ACT_VIDEO + HOR_FRONT_PORCH,
					VER_WHOLE = VER_SYNC_PULSE + VER_BACK_PORCH + VER_ACT_VIDEO + VER_FRONT_PORCH;

	always @ (posedge pixClk)
		if (!rst) begin
			hCounter <= 0;
			vCounter <= 0;
		end else begin
			if (hCounter == HOR_WHOLE) begin
				hCounter <= 0;
				if (vCounter == VER_WHOLE)
					vCounter <= 0;
				else
					vCounter <= vCounter + 1;
			end else
				hCounter <= hCounter + 1;
		end
	
	assign hsync = (hCounter < HOR_SYNC_PULSE);
	assign vsync = (vCounter < VER_SYNC_PULSE);
	assign ena   = (hCounter >= HOR_SYNC_PULSE + HOR_BACK_PORCH) && (hCounter < HOR_SYNC_PULSE + HOR_BACK_PORCH + HOR_ACT_VIDEO) && (vCounter >= VER_SYNC_PULSE + VER_BACK_PORCH) && (vCounter < VER_SYNC_PULSE + VER_BACK_PORCH + VER_ACT_VIDEO);
	assign red   = r & ena;
	assign green = g & ena;
	assign blue  = b & ena;

	wire r, g, b;
	blinkpattern #(HOR_ACT_VIDEO, VER_ACT_VIDEO) _blinkpattern
	(
		.clk(pixClk),
		.rst(rst),

		.xPosition(hCounter - HOR_SYNC_PULSE - HOR_BACK_PORCH),
		.yPosition(vCounter - VER_SYNC_PULSE - VER_BACK_PORCH),
		.ena(ena),

		.r(r),
		.g(g),
		.b(b),
	);

endmodule


module blinkpattern
#(
	WIDTH, HEIGHT
)
(
	input clk,
	input rst,

	input [10:0] xPosition,
	input [10:0] yPosition,
	input ena,

	output reg r,
	output reg g,
	output reg b
);
	reg [25:0] flickerTimer;
	// Flicker
	always @ (posedge clk) 
		flickerTimer = flickerTimer + 1;

	always @*
		if ((yPosition < 200))
			if (xPosition > WIDTH/8*7) begin
				r = 1;
				g = 1;
				b = 1;
			end else if (xPosition > WIDTH/8*6) begin
				r = 0;
				g = 0;
				b = 1;
			end else if (xPosition > WIDTH/8*5) begin
				r = 1;
				g = 0;
				b = 0;
			end else if (xPosition > WIDTH/8*4) begin
				r = 1;
				g = 0;
				b = 1;
			end else if (xPosition > WIDTH/8*3) begin
				r = 0;
				g = 1;
				b = 0;
			end else if (xPosition > WIDTH/8*2) begin
				r = 0;
				g = 1;
				b = 1;
			end else if (xPosition > WIDTH/8*1) begin
				r = 1;
				g = 1;
				b = 0;
			end else begin
				if (flickerTimer[25]) begin
					r = 0;
					g = 0;
					b = 0;
				end else begin 
					r = 1;
					g = 1;
					b = 1;
				end		
			end
		else begin
			r = 0;
			g = 1;
			b = 0;
		end

endmodule
