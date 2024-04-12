
function integer     log2;
    input integer     depth ;
    for(log2=0; depth>1; log2=log2+1) begin
        depth = depth >> 1 ;
    end
endfunction
//////////////////////////////////////////


module Conv2_test 
( clk_x1, rstn, SW5, SW6, SW7, clk_x5,
 led0, led1, led2, led3, led4, led5);
input 			  clk_x1, rstn, SW5, SW6, SW7, clk_x5;  //rstn -- SW1
output reg         led0, led1, led2, led3, led4, led5;
   
parameter BRAM_BITWIDTH = 8;
parameter BRAM_DEPTH_PIC = 1024;
parameter ADDRESS_LENGTH_PIC = log2( BRAM_DEPTH_PIC );

parameter BRAM_DEPTH_W = 512;
parameter ADDRESS_LENGTH_W = log2( BRAM_DEPTH_W );
   
//system
reg [31:0] counter = '0;
reg start_reg0 = 0;
reg start_reg1 = 0;
reg start = 0;
   
//BROM  -- picture, bias, weight X 6
wire ena_max1;
wire [ADDRESS_LENGTH_PIC - 1:0] address_max1;
wire [48-1:0] douta_max1;
     
BRAM_MAX1 bram_max1 (
.addra( address_max1 ),
.clka( clk_x5 ),
.douta( douta_max1 ),
.ena( ena_max1 ),
.rsta( !rstn )
);

wire ena_conv2_bias;
wire [4 - 1:0] addra_conv2_bias;
wire [BRAM_BITWIDTH-1:0] douta_conv2_bias;

CONV2_BIAS conv2_bias(
.addra( addra_conv2_bias ),
.clka( clk_x5 ),
.douta( douta_conv2_bias ),
.ena( ena_conv2_bias ),
.rsta( !rstn )
);

parameter CHANNEL = 6;
genvar channel;

wire ena_w [CHANNEL-1:0];
wire [ADDRESS_LENGTH_W - 1:0] addra_w [CHANNEL-1:0];
wire [BRAM_BITWIDTH-1:0] douta_w [CHANNEL-1:0];

BROM_CONV_WEIGHT1 brom_conv_weight1 (
.addra( addra_w[0] ),
.clka( clk_x5 ),
.douta( douta_w[0] ),
.ena( ena_w[0] ),
.rsta( !rstn )
);
BROM_CONV_WEIGHT2 brom_conv_weight2 (
.addra( addra_w[1] ),
.clka( clk_x5 ),
.douta( douta_w[1] ),
.ena( ena_w[1] ),
.rsta( !rstn )
);
BROM_CONV_WEIGHT3 brom_conv_weight3 (
.addra( addra_w[2] ),
.clka( clk_x5 ),
.douta( douta_w[2] ),
.ena( ena_w[2] ),
.rsta( !rstn )
);
BROM_CONV_WEIGHT4 brom_conv_weight4 (
.addra( addra_w[3] ),
.clka( clk_x5 ),
.douta( douta_w[3] ),
.ena( ena_w[3] ),
.rsta( !rstn )
);
BROM_CONV_WEIGHT5 brom_conv_weight5 (
.addra( addra_w[4] ),
.clka( clk_x5 ),
.douta( douta_w[4] ),
.ena( ena_w[4] ),
.rsta( !rstn )
);
BROM_CONV_WEIGHT6 brom_conv_weight6 (
.addra( addra_w[5] ),
.clka( clk_x5 ),
.douta( douta_w[5] ),
.ena( ena_w[5] ),
.rsta( !rstn )
);

wire ena_adder;
wire ena_conv;

wire unsigned [ 8-1 : 0 ] in_max1 [ CHANNEL - 1 : 0 ];
Unpacked2Packed unpack2pack
(
.unpacked_in( douta_max1 ),
.packed_out( in_max1 )
);

wire unsigned [ 8-1 : 0] conv2_result;

Conv_Layer #( .BITWIDTH( BRAM_BITWIDTH ), .WIDTH(5), .HEIGHT(5), .CHANNEL( CHANNEL ) ) conv_layer2
(
.clk( clk_x5 ),
.rstn( rstn ),

.ena_adder( ena_adder ),
.ena_conv( ena_conv ),

.in_data( in_max1 ),
.in_factor( douta_w ),

.bias_conv2( douta_conv2_bias ),

.result_conv2( conv2_result )
);

parameter BRAM_DEPTH_CONV2 = 1024;
parameter ADDRESS_LENGTH_CONV2 = log2( BRAM_DEPTH_CONV2 );

wire ena_conv2 ;
wire [ADDRESS_LENGTH_CONV2 - 1:0] addra_conv2;
wire [BRAM_BITWIDTH-1:0] douta_conv2;

BRAM_CONV2 bram_conv2
(
.addra( addra_conv2 ),
.clka( clk_x5 ),
.douta( douta_conv2 ),
.ena( ena_conv2 ),
.rsta( !rstn )
);

wire ena_max1_;
wire [ADDRESS_LENGTH_PIC - 1:0] address_max1_;

assign ena_max1 = ena_max1_;
assign address_max1 = address_max1_;

wire ena_w_;
wire [ADDRESS_LENGTH_W - 1:0] addra_w_;

for ( channel = 0; channel < CHANNEL;  channel = channel + 1 ) begin
    assign ena_w[channel] = ena_w_;
    assign addra_w[channel] = addra_w_;
end

wire ena_conv2_;
wire [ADDRESS_LENGTH_CONV2 - 1:0] addra_conv2_;
assign ena_conv2 = ena_conv2_;
assign addra_conv2 = addra_conv2_;

Memory_Controller_Conv2 memory_contrller_conv2
(
.clk( clk_x5 ),
.rstn( rstn ),
.start( start ),

.ena_adder( ena_adder ),
.ena_conv2( ena_conv ),

.ena_pic( ena_pic_ ),
.address_pic( address_pic_ ),

.ena_w( ena_w_ ),
.addra_w( addra_w_ ),

.ena_conv1( ena_conv2_ ),
.addra_conv1( addra_conv2_ )
);

integer i;

reg [31:0] counter_25;
reg [31:0] counter_25_24;

always@ ( posedge clk_x5 or negedge rstn ) begin

if ( !rstn ) begin

//system
counter <= '1;
counter_25 <= 0;
start_reg0 <= 0;
start_reg1 <= 0;
start <= 0;

end

else if ( !start ) begin
//system
start_reg0 <= SW6;
start_reg1 <= start_reg0;
start <= ( ( start_reg0 == 1 ) && ( start_reg1 == 0 ) );
end

else if ( start ) begin

//system
start <= 1;
counter <= counter >= 32'd99999 ? 0 : ( counter + 1 );
counter_25 = counter/25;
counter_25_24 = counter/(25*24);

//OUT
led0 <= conv2_result >= 1;
led1 <= conv2_result >= 1;
led2 <= conv2_result >= 1;
led3 <= conv2_result >= 1;
led4 <= conv2_result >= 1;
led5 <= conv2_result >= 1;

end

end

endmodule