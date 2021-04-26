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
if ((convert >= 32'd31 & data[7] == 1'b1) | convert >= 32'd32) //para temp maior que 31.5, sel representa quente
	sel <= 2'b11;
else if ((convert <= 32'd31 & data[7] == 1'b0) & (convert >= 32'd27 & data[7] == 1'b1))
	sel <= 2'b10;					// para temp entre 27.5 e 31, sel representa normal
//if (convert >= 32'd32)
//	sel <= 2'b11;
//else if (convert == 32'd31)
//	sel <= 2'b01;
else		// para temps menores que 27.5, sel representa frio
	sel <= 2'b10;
// conversoes da temperatura para cada digito
cem <= convert/100;	
dez <= (convert/10) % 10;
uni <= convert % 10;
if(data[7]) // data[7] representa o decimal da temperatura
	dec <= 4'd5;
else 
	dec <= 4'd0;
end
assign tempdec = dec;
assign tempuni = uni;
assign tempdez = dez;
assign tempcem = cem;
endmodule
