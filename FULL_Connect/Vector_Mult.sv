`timescale 1ns / 1ps

module Vector_Mult#(
parameter BITWIDTH = 8,
parameter LENGTH = 16
    )
    (
    input clk,
    input rstn,
    input ena,
    
    input unsigned [BITWIDTH-1:0] in_data [LENGTH-1:0],
    input signed [BITWIDTH-1:0] in_weight [LENGTH-1:0],
    
    output reg signed  [BITWIDTH * 2 - 1:0] out_data [LENGTH-1:0]
    );


wire signed [BITWIDTH:0] in_data_signed[LENGTH-1:0];
genvar l;
for ( l = 0; l < LENGTH; l = l + 1 ) begin
assign in_data_signed[l] = { 0, in_data[l][BITWIDTH-1:0] };
end

integer i;

always@( posedge clk or negedge rstn ) begin

if ( !rstn || !ena ) begin
	for ( i = 0; i < LENGTH; i = i + 1 ) begin
		out_data[i] <= '0;
	end
end

else if ( ena ) begin
	for ( i = 0; i < LENGTH; i = i + 1 ) begin
		out_data[i] <= in_data_signed[i] * in_weight[i];
	end
end
end
    
endmodule
