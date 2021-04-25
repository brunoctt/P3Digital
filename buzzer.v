module buzzer
(
input [1:0] sel,
input clk,
output buzz
);
reg ena250;
reg ena100;
integer clk250;
integer clk100;
integer cont;
initial
begin
	assign ena100 = 1'b0;
end
always @ (posedge clk)
begin
if (sel == 2'b11)
	if (clk250 == 32'd12500000)
		ena100 <= 1'b1;
	else
		clk250 <= clk250 + 1;
		ena100 <= 1'b0;
else
	clk250 <= 0;
if (sel == 2'b11 & ena100 == 1'b1)
	if (clk100 == 32'd5000000)
		buzz <= not buzz;
		if (cont == 32'd3)
			clk250 <= 0;
			cont <= 0;
		else
			cont <= cont + 1;
	else
		clk100 <= clk100 + 1;
else
	clk100 <= 0;
/*cem <= convert/100;
dez <= (convert/10) % 10;
uni <= convert % 10;
if(data[7]) 
	dec <= 4'd5;
else 
	dec <= 4'd0; */
end
/*assign tempdec = dec;
assign tempuni = uni;
assign tempdez = dez;
assign tempcem = cem;*/
endmodule
