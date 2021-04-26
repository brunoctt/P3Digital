module	buzzfrio(					
input	clk,	
input [1:0] sel,						
output	beep	
);										
reg beep_r;								
reg[27:0]count;

assign beep = beep_r;					
always@(posedge clk)
begin
	if (sel == 2'b10)
		count <= count + 1'b1;
	else
		count <= 0;
end
always @(count)
begin
	beep_r = !(count[13]&count[23]&!count[27]);
//count[13] = freq do beep; count[23] = qntd de beep; count[27] = intervalo dos beeps
end
endmodule
