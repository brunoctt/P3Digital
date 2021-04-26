module	buzz(clk,beep);					
input	clk;							
output	beep;											
reg beep_r;								
reg[27:0]count;

assign beep = beep_r;					
always@(posedge clk)
begin
	count <= count + 1'b1;
end
always @(count[9])
begin
	beep_r = !(count[13]&count[23]&!count[27]);
end
endmodule