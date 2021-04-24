module convtemp
(
input [15:0] data,
input clk,
output [3:0] tempdec,
output [3:0] tempuni,
output [3:0] tempdez,
output [3:0] tempcem,
output reg [1:0] sel
);
reg [3:0] dec;
reg [3:0] uni;
reg [3:0] dez;
reg [3:0] cem;
integer convert;

always @ (posedge clk)

begin
convert <= data[14:8];
if ((convert >= 32'd31 & data[7] == 1'b1) | convert >= 32'd32)
	sel <= 2'b11;
else if ((convert <= 32'd31 & data[7] == 1'b0) & (convert >= 32'd27 & data[7] == 1'b1))
	sel <= 2'b10;
else
	sel <= 2'b01;
cem <= convert/100;
dez <= (convert/10) % 10;
uni <= convert % 10;
if(data[7]) 
	dec <= 4'd5;
else 
	dec <= 4'd0;
end
assign tempdec = dec;
assign tempuni = uni;
assign tempdez = dez;
assign tempcem = cem;
endmodule
