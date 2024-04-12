
module Memory_Controller_Conv2 #(
parameter IN_CHANNEL = 1,
parameter OUT_CHANNEL = 6,

parameter ADDRESS_LENGTH_PIC = 10,
parameter ADDRESS_LENGTH_W = 9,
parameter ADDRESS_LENGTH_CONV1 = 10,

parameter CONV2_WIDTH = 5,
parameter CONV2_HEIGHT = 5,
parameter CONV2_STRIDE = 1,
parameter CONV2_PADDING = 0,

parameter IN_DATA_WIDTH = 28,
parameter IN_DATA_HEIGHT = 28
)
(
input clk,
input rstn,
input start,

output reg ena_adder,
output reg ena_conv,
output reg ena_conv2,

output reg ena_pic,
output reg [ADDRESS_LENGTH_PIC - 1:0] address_pic,

output reg ena_w,
output reg [ADDRESS_LENGTH_W - 1:0] addra_w,

output reg ena_conv2,
output reg [ADDRESS_LENGTH_CONV1 - 1:0] addra_conv2
);

integer i;
reg [31:0] counter = '0;
reg [ ADDRESS_LENGTH_PIC - 1 : 0 ] anchor = '0;
reg conv1_end = 0;

always @ ( posedge clk or negedge rstn ) begin

if ( !rstn ) begin

counter <= '1;

ena_adder <= 0;
ena_conv <= 0;
ena_conv2 <= 0;

ena_pic <= 0;
address_pic <= 0;

ena_w <= 0;
addra_w <= 0;

ena_conv2 <= 0;
addra_conv2 <= 0;
end

else if ( start ) begin

counter <= counter >= 32'd99999 ? 0 : ( counter + 1 );

ena_adder <= counter % ( CONV2_WIDTH*CONV2_HEIGHT ) == 1 ? 0 : 1;
ena_conv <= 1;
ena_conv2 <= 0;

anchor <= ( (anchor % IN_DATA_WIDTH == IN_DATA_WIDTH - CONV2_WIDTH ) && addra_w == 1  ) ? 
anchor + CONV2_WIDTH : addra_w == 1 
? anchor + 1 : anchor;

ena_pic = 1;
address_pic <= addra_w == ( CONV2_WIDTH*CONV2_HEIGHT - 1 ) ? 
anchor : (addra_w % CONV2_WIDTH == CONV2_WIDTH - 1) ? 
address_pic + ( CONV2_WIDTH*CONV2_HEIGHT - 1 ) : address_pic + 1;

ena_w <= 1;
addra_w <= addra_w == ( CONV2_WIDTH*CONV2_HEIGHT - 1 ) ? 0 : addra_w + 1;

ena_conv2 <= 0;
addra_conv2 <= 0;
end

else if ( conv1_end ) begin

counter <= '1;

ena_adder <= 0;
ena_conv <= 0;
ena_conv2 <= 0;

ena_pic <= 0;
address_pic <= 0;

ena_w <= 0;
addra_w <= ( CONV2_WIDTH*CONV2_HEIGHT - 1 );

ena_conv2 <= counter % 25 == 1 ? 0 : 1;
addra_conv2 <= (counter % 25 == 1 && counter >=25 ) ? addra_conv2 + 1 : addra_conv2;
end

end

endmodule
