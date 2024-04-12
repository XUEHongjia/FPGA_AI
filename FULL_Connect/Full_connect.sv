module Full_Connect #
(
parameter BITWIDTH = 8,
parameter BITWIDTH_CAL = 24,
//parameter LENGTH1 = 256,
//parameter LENGTH2 = 100,
//parameter LENGTH3 = 64,
parameter NUM_PARA = 1
)

(
input clk,
input rstn,

input ena,
input ena_add,
input unsigned [1:0] select,

input unsigned [ BITWIDTH - 1 : 0 ] in_data[ NUM_PARA - 1 : 0 ],
input signed [ BITWIDTH - 1 : 0 ] weight[ NUM_PARA - 1 : 0 ],
input signed [ BITWIDTH - 1 : 0 ] bias[ NUM_PARA - 1 : 0 ],

output unsigned [ BITWIDTH - 1 : 0 ] result[ NUM_PARA - 1 : 0 ]
);
genvar i;

//multiplier
wire signed [ 2*BITWIDTH - 1 : 0 ] product [ NUM_PARA - 1 : 0 ];
Vector_Mult #( .BITWIDTH(BITWIDTH), .LENGTH( NUM_PARA ) ) vector_mult
( .clk(clk), .rstn(rstn), .ena(ena), .in_data(in_data), .in_weight(weight), .out_data(product) );

//adder
wire signed [ BITWIDTH_CAL - 1 : 0 ] sum [ NUM_PARA - 1 : 0 ];
Vector_Adder #( .BITWIDTH_IN( 16 ), .BITWIDTH_OUT( 24 ), .LENGTH( NUM_PARA ) ) vector_adder
( .clk(clk), .rstn(rstn), .ena( ena_add ), .in_data( product ), .out_data( sum ) );

//add bias
wire signed [ BITWIDTH_CAL - 1 : 0 ] sum_bias [ NUM_PARA - 1 : 0 ];
Vector_ADD_BIAS #( .BITWIDTH_BIAS(8), .BITWIDTH_DATA( 24 ), .LENGTH( NUM_PARA ) ) vector_add_bias
( .clk(clk), .rstn(rstn), .ena(ena), .data_in( sum ), .bias( bias ), .result( sum_bias ) );

//relu
wire unsigned [ BITWIDTH_CAL - 1 : 0 ] sum_relu [ NUM_PARA - 1 : 0 ];
Vector_RELU # ( .BITWIDTH( BITWIDTH_CAL ), .LENGTH( NUM_PARA ), .THRESSHOLD(0) ) vector_relu
( .clk(clk), .rstn(rstn), .ena(ena), .in_data( sum_bias ), .out_data( sum_relu ) );

//Rescale
wire unsigned [ BITWIDTH - 1 : 0 ] sum_rescale [ NUM_PARA - 1 : 0 ];
generate
for ( i = 0; i < NUM_PARA; i = i + 1 ) begin
Rescale #( .BITWIDTH_IN( 24 ), .BITWIDTH_OUT( 8 ), .SCALE1( 199 ), .SCALE2( 156 ), .SCALE3( 164 ), .BITWIDTH_SCALE( 8 ), .BITWIDTH_RIGHT_SHIFT(16) ) rescale
( .clk(clk), .rstn(rstn), .ena(ena), .select(select), .in_data( sum_relu[i] ), .result( sum_rescale[i] ) );
end
endgenerate
//OUT
for ( i = 0; i < NUM_PARA; i = i + 1 ) begin
    assign result[i] = {sum_rescale[i][ BITWIDTH - 1 : 0 ]};
end

endmodule