
function integer     log2;
    input integer     depth ;
    for(log2=0; depth>1; log2=log2+1) begin
        depth = depth >> 1 ;
    end
endfunction

module Max_Pool_test 
( clk_x1, rstn, SW5, SW6, SW7, clk_x5,
 led0, led1, led2, led3, led4, led5);
input 			  clk_x1, rstn, SW5, SW6, SW7, clk_x5;  //rstn -- SW1
output reg         led0, led1, led2, led3, led4, led5;
   
   parameter BRAM_BITWIDTH = 8;
   parameter BRAM_DEPTH_CONV2 = 1024;
   parameter BRAM_DEPTH_FLATTEN = 256;
   parameter ADDRESS_LENGTH_CONV2 = log2( BRAM_DEPTH_CONV2 );
   parameter ADDRESS_LENGTH_FLATTEN = log2( BRAM_DEPTH_FLATTEN );
   
   reg [31:0] counter = '0;
   reg start_reg0;
   reg start_reg1;
   reg start;
   
   wire [ ADDRESS_LENGTH_CONV2 - 1 : 0 ] addra_conv2;
   wire [BRAM_BITWIDTH-1:0] dina_conv2;
   wire [BRAM_BITWIDTH-1:0] douta_conv2;
   wire ena_conv2;
   wire wea_conv2;
   wire addren_conv2;
   
   wire [ ADDRESS_LENGTH_FLATTEN - 1 : 0 ] addra_flatten;
   wire [BRAM_BITWIDTH-1:0] dina_flatten;
   wire [BRAM_BITWIDTH-1:0] douta_flatten;
   wire ena_flatten;
   wire wea_flatten;
   wire addren_flatten;
   
BRAM_CONV2_ bram_conv2
(
.re( ena_conv2 ),
//.we( wea_conv2 ),
.addren( addren_conv2 ),

.reset( !rstn ),
.addr( addra_conv2 ),

//.wdata_a( douta_conv2 ),
.rdata_a( dina_conv2 ),

.clk( clk_x5 )
//,
//.wclke( 1 )
);

wire ena_pool;
Memory_Control_Pool memory_control_pool
(
.clk(clk_x5),
.rstn( rstn ),
.start( start ),

.ena_pool( ena_pool ),

.ena_conv2( ena_conv2 ),
.wea_conv2( wea_conv2 ),
.addra_conv2( addra_conv2 )
//,
//.ena_flatten( ena_flatten ),
//.wea_flatten( wea_flatten ),
//.addra_flatten( addra_flatten ),
//.addren_flatten( addren_flatten )
);

wire unsigned [ 8 - 1 : 0 ] max_pool_out;
//assign dina_flatten = max_pool_out;
Pool_Layer #( .BITWIDTH( BRAM_BITWIDTH ), .LENGTH( 4 ) ) pool_layer
(
.clk( clk_x5 ),
.rstn( rstn ),
.ena( ena_pool ),

.in_data( douta_conv2 ),
.out_max_pool( max_pool_out )
);

always@ ( posedge clk_x5 or negedge rstn ) begin

if ( !rstn ) begin

//system
counter <= '1;
start_reg0 <= 0;
start_reg1 <= 0;
start <= 0;

//BRAM

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
counter <= counter >= 32'd999 ? 0 : ( counter + 1 );

//BRAM


//OUT
led0 <= 0;
led1 <= 0;
led2 <= 0;
led3 <= max_pool_out >= 1;
led4 <= 0;
led5 <= 0;

end

end
  

endmodule