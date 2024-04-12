
module Vector_RELU#(
parameter BITWIDTH = 8,
parameter LENGTH = 1,
parameter THRESSHOLD = 0
)
(
    input clk,
    input rstn,
    input ena,
    
    input signed [BITWIDTH-1:0] in_data [LENGTH-1:0],
    
    output unsigned [BITWIDTH-1:0] out_data [LENGTH-1:0]
 );

reg unsigned [BITWIDTH - 1:0] c_reg [LENGTH - 1:0];
integer i;

always@( posedge clk or negedge rstn ) begin

if ( !rstn ) begin
    for ( i = 0; i < LENGTH; i = i + 1 ) begin
        c_reg[i] <= '0;
    end
end

else if ( ena ) begin
	for ( i = 0; i < LENGTH; i = i + 1 ) begin
		if ( in_data[i] > THRESSHOLD ) begin
		  c_reg[i] <= in_data[i];
		end
		
		else begin
		  c_reg[i] <= 0;
		end
	end
end
end

assign out_data = c_reg;

endmodule