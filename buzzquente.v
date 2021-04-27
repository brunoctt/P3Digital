module	buzzquente(					
input	clk,	
input [1:0] sel,						
output	beep	
);												
reg beep_r;								
reg[27:0]count;

assign beep = beep_r;					
always@(posedge clk)
begin
	if (sel == 2'b11)
		count <= count + 1'b1;
	else
		count <= 0;
end
always @(count)
begin
	beep_r = !(count[14]&count[24]&!count[27]);
	//count[14] = freq do beep; count[24] = qntd de beep; count[27] = intervalo dos beeps
end
endmodule
