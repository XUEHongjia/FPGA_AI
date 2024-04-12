`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Conv_Layer#(
parameter BITWIDTH = 8,
parameter WIDTH = 5,
parameter HEIGHT = 5,
parameter CHANNEL = 6  
)
(
//input clk_x5,
input clk,
input rstn,

input ena_adder,
input ena_conv,

input unsigned [BITWIDTH-1:0] in_data[CHANNEL-1:0], // data should be unsigned because of RELU
input unsigned [BITWIDTH-1:0] in_factor[CHANNEL-1:0], // weights can be signed

input signed [BITWIDTH-1:0] bias_conv2,

output unsigned [BITWIDTH - 1 : 0] result_conv2
);

wire signed [BITWIDTH - 1 : 0] in_weight[CHANNEL-1:0];
genvar c;
for ( c = 0; c < CHANNEL; c = c + 1 ) begin
assign in_weight[c] = {in_factor[c][ BITWIDTH - 1 : 0]};
end
//convolutional kernel
// this part is going to take 24*28 clock cycles for the first round and 8*12 cycles for the second round
wire signed [2*BITWIDTH - 1 : 0] product[CHANNEL-1:0];
Vector_Mult #( .BITWIDTH(BITWIDTH), .LENGTH(CHANNEL) ) vector_mult
( .clk(clk), .rstn(rstn), .ena( ena_conv ), .in_data( in_data ), .in_weight( in_weight ), .out_data( product ) );


wire signed [2*BITWIDTH + 5 - 1 : 0] sum[CHANNEL-1:0];
Vector_Adder#( .BITWIDTH_IN( 2*BITWIDTH ), .BITWIDTH_OUT( 2*BITWIDTH + 5 ), .LENGTH( CHANNEL ) ) vector_adder
( .clk(clk), .rstn(rstn), .ena( ena_adder ), .in_data( product ), .out_data( sum ) );

//------ conv2 begins

//pipeline addition 
wire signed [2*BITWIDTH + 5 - 1 : 0] sum_conv2[CHANNEL-1:0];
for ( c = 0; c < CHANNEL; c = c + 1 ) begin
    assign sum_conv2[c] = sum[c];
end

wire signed [ 2*BITWIDTH+6-1:0 ] pipe0 [ 3 - 1 : 0 ];
wire signed [ 2*BITWIDTH+7-1:0 ] pipe1 [ 2 - 1 : 0 ];
wire signed [ 2*BITWIDTH+8-1:0 ] pipe2 [ 0 : 0 ];
Vector_Add_half #( .BITWIDTH( 2*BITWIDTH+5 ), .IN_LENGTH( 6 ) ) 
add_half0( .clk(clk), .rstn(rstn), .ena(ena_conv), .in_data( sum_conv2 ), .out_data( pipe0 ) );

Vector_Add_half #( .BITWIDTH( 2*BITWIDTH+6 ), .IN_LENGTH( 3 ) ) 
add_half1( .clk(clk), .rstn(rstn), .ena(ena_conv), .in_data( pipe0 ), .out_data( pipe1 ) );

Vector_Add_half #( .BITWIDTH( 2*BITWIDTH+7 ), .IN_LENGTH( 2 ) ) 
add_half2( .clk(clk), .rstn(rstn), .ena(ena_conv), .in_data( pipe1 ), .out_data( pipe2 ) );

// add bias
wire signed [ 2*BITWIDTH + 8 - 1 : 0 ] result_bias_conv2;
ADD_BIAS #( .BITWIDTH_BIAS(8), .BITWIDTH_DATA( 2*BITWIDTH + 8 ) ) add_bias_conv2
( .clk(clk), .rstn(rstn), .ena(ena_conv), .data_in( pipe2[0]), .bias( bias_conv2 ), .result( result_bias_conv2 ) );

//relu layer
wire unsigned [ 2*BITWIDTH + 8 - 1 : 0] result_relu_conv2;
RELU # ( .BITWIDTH_IN(24), .BITWIDTH_OUT(24), .THRESSHOLD(0) ) relu_conv2
( .clk(clk), .rstn(rstn), .ena(ena_conv), .in_data( result_bias_conv2 ), .out_data( result_relu_conv2 ) );

wire unsigned [ 2*BITWIDTH + 8 - 1 : 0] result_rescale_conv2;
Rescale_Conv2 #( .BITWIDTH_IN(24), .BITWIDTH_OUT(8), .SCALE(181), .BITWIDTH_SCALE(8), .BITWIDTH_RIGHT_SHIFT(16) ) rescale_conv2
( .clk(clk), .rstn(rstn), .ena(ena_conv), .in_data( result_relu_conv2 ), .result( result_rescale_conv2 ) );

assign result_conv2 = result_rescale_conv2;

//------ conv2 ends

endmodule
