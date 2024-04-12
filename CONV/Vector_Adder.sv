/*
function integer half_ceiling;
	input	integer	val;

	begin
	   half_ceiling = ( val % 2 == 0 ) ? val/2 : (val+1)/2;
	end
endfunction
*/
module Vector_Adder#(
parameter BITWIDTH_IN = 16,
parameter BITWIDTH_OUT = 24,
parameter LENGTH = 4
    )
    (
    input clk,
    input rstn,
    input ena,
    
    input signed [BITWIDTH_IN-1:0] in_data [ LENGTH - 1:0 ],
    
    output signed  [BITWIDTH_OUT-1:0] out_data [ LENGTH-1:0 ]
    );
    
reg signed [BITWIDTH_OUT-1:0] c_reg [LENGTH-1:0];
integer i;
always@( posedge clk or negedge rstn ) begin

if ( !rstn ) begin
    for ( i = 0; i < LENGTH; i = i + 1 ) begin
        c_reg[i] <= '0;
    end
end

else if ( ena ) begin
    for ( i = 0; i < LENGTH; i = i + 1 ) begin
        c_reg[i] <= in_data[i] + c_reg[i];
    end
end

else if ( !ena ) begin
    for ( i = 0; i < LENGTH; i = i + 1 ) begin
        c_reg[i] <= in_data[i];
    end
end

end

assign out_data = c_reg;

endmodule
