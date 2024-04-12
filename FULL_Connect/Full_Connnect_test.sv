//////////////////////////////////////////
function integer     log2;
    input integer     depth ;
        //256为9bit，我们最终数据应该是8，所以需depth=2时提前停止循环
    for(log2=0; depth>1; log2=log2+1) begin
        depth = depth >> 1 ;
    end
endfunction
//////////////////////////////////////////


module Full_Connect_test 
( clk_x1, rstn, SW5, SW6, SW7, clk_x5,
 led0, led1, led2, led3, led4, led5);
   input 			  clk_x1, rstn, SW5, SW6, SW7, clk_x5;  //rstn -- SW1
   output reg         led0, led1, led2, led3, led4, led5;
   
   parameter BRAM_BITWIDTH = 8;
   parameter BIAS_DEPTH = 256;
   parameter FLATTEN_DEPTH = 256;
   parameter FC3_WEIGHT_DEPTH = 1024;
   parameter BIAS_LENGTH = log2( BIAS_DEPTH );
   parameter FLATTEN_LENGTH = log2( FLATTEN_DEPTH );
   parameter FC3_WEIGHT_LENGTH = log2( FC3_WEIGHT_DEPTH );
   
   //system
   reg [31:0] counter = '0;
   reg start_reg0 = 0;
   reg start_reg1 = 0;
   reg start = 0;
   
   //BRAM
   reg read_en = 0;
   reg addren  = 0;
   reg [FLATTEN_LENGTH-1:0] address = '0;
   reg [BRAM_BITWIDTH-1:0] wdata_a = '0;
   reg [BRAM_BITWIDTH-1:0] rdata_a = '0;
   
   reg read_en_b = 0;
   reg addren_b  = 0;
   reg [BIAS_LENGTH-1:0] address_b = '0;
   //reg [BRAM_BITWIDTH-1:0] wdata_a_b = '0;
   reg [BRAM_BITWIDTH-1:0] rdata_a_b = '0;

   reg read_en_w = 0;
   reg addren_w  = 0;
   reg [FC3_WEIGHT_LENGTH-1:0] address_w = '0;
   //reg [BRAM_BITWIDTH-1:0] wdata_a_w = '0;
   reg [BRAM_BITWIDTH-1:0] rdata_a_w = '0;
   
   
FLATTEN flatten (
.re( read_en ),
.we( 0 ),
.addren( addren ),

.addr( address ),
.wdata_a ( wdata_a ),
.rdata_a( rdata_a ),

.clk( clk_x5 ),
.wclke( 1 )
);

FC3_WEIGHT fc3_weight (
.re( read_en_w ),
.addren( addren_w ),
.addr( address_w ),
.reset( !rstn ),
.rdata_a( rdata_a_w ),
.clk( clk_x5 )
);

FC_BIAS fc_bias(
.re( read_en_b ),
.addren( addren_b ),
.reset( !rstn ),
.addr( address_b ),
.rdata_a( rdata_a_b ),
.clk( clk_x5 )
);

wire unsigned [ BRAM_BITWIDTH - 1 : 0 ] in_data[1-1:0];
assign in_data[0] = {rdata_a};
wire signed [ BRAM_BITWIDTH - 1 : 0 ] weight[1-1:0];
assign weight[0] = { rdata_a_w };
wire signed [ BRAM_BITWIDTH - 1 : 0 ] bias [1-1:0];
assign bias[0] = {rdata_a_b};
wire unsigned [ BRAM_BITWIDTH - 1 : 0 ] result[1-1:0];

reg ena_add;

Full_Connect #( .BITWIDTH(8), .BITWIDTH_CAL(24), .NUM_PARA(1) ) full_connect
(
.clk( clk_x5 ),
.rstn( rstn ),
.ena( 1 ),
.ena_add(ena_add),
.select( 2'b10 ),

.in_data( in_data ),
.weight( weight ),
.bias(  bias),
.result( result )
);

reg [32-1:0] rdata_check = '0;

always@ ( posedge clk_x5 or negedge rstn ) begin

if ( !rstn ) begin

//system
counter <= '1;
start_reg0 <= 0;
start_reg1 <= 0;
start <= 0;

//BRAM
read_en <= 0;
addren <= 0;
address <= '1;
//rdata_a <= 0;

read_en_b <= 0;
addren_b <= 0;
address_b <= 0;
//rdata_a_b <= 0;

read_en_w <= 0;
addren_w <= 0;
address_w <= '1;
//rdata_a_w <= 0;

ena_add <= 0;

end

else if ( !start ) begin
//system
start_reg0 <= SW6;
start_reg1 <= start_reg0;
start <= ( ( start_reg0 == 1 ) && ( start_reg1 == 0 ) );
end

else if ( start ) begin

ena_add <= counter % 84 == 1 ? 0 : 1;

//system
start <= 1;
counter <= counter >= 32'd999 ? 0 : ( counter + 1 );
rdata_check <= rdata_a;

//BRAM
read_en <= 1;
addren <= 1;
address <= address >= 83 ? 0 : (address + 1) ;

read_en_b <= 1;
addren_b <= 1;
address_b <= 120+84;

read_en_w <= 1;
addren_w <= 1;
address_w <= address_w >= 839 ? 0 : address_w + 1 ;

//OUT
led0 <= 0;
led1 <= 0;
led2 <= 0;
led3 <= ( result[0] >= 64 );
led4 <= 0;
led5 <= 0;

end

end
  

endmodule