
module Pool_Layer #(
parameter BITWIDTH = 8,
parameter LENGTH = 4
)
(
input clk,
input rstn,
input ena,

input unsigned [ BITWIDTH - 1 : 0 ] in_data,

output wire unsigned [ BITWIDTH - 1 : 0 ] out_max_pool
);

//buffer
wire unsigned [ BITWIDTH - 1 : 0 ] buffer_out [ LENGTH - 1 : 0 ];
Buffer_1D #( .BITWIDTH(BITWIDTH), .LENGTH(LENGTH) ) buffer_1d
( .clk( clk ), .rstn( rstn ), .ena( ena ), .data_in( in_data ), .data_out( buffer_out ) );

//max_pool
wire unsigned [ BITWIDTH - 1 : 0 ] max_pool_out;
Max_Pool #( .BITWIDTH(BITWIDTH), .LENGTH(LENGTH) ) max_pool
( .clk( clk ), .rstn( rstn ), .ena( ena ), .in_data( buffer_out ), .max_out( max_pool_out ) );

assign out_max_pool = max_pool_out;
endmodule
