
module Memory_Control_Pool
#(
parameter ADDRESS_LENGTH_CONV2 = 10,
parameter ADDRESS_LENGTH_FLATTEN = 8
)
(
input clk,
input rstn,
input start,

output reg ena_pool,

output reg ena_conv2,
output reg wea_conv2,
output reg addren_conv2,
output reg [ADDRESS_LENGTH_CONV2 - 1:0] addra_conv2
//,

//output reg ena_flatten,
//output reg wea_flatten,
//output reg addren_flatten,
//output reg [ADDRESS_LENGTH_FLATTEN - 1:0] addra_flatten
);

localparam INPUT_WIDTH = 8;

integer i;
reg [31:0] counter = '0;
reg [ ADDRESS_LENGTH_CONV2 - 1 : 0 ] anchor = '0;
reg pool2_end = 0;
reg [ 2-1 : 0 ] conv2_addra_count;

always @ ( posedge clk or negedge rstn ) begin

if ( !rstn ) begin

counter <= '1;
anchor <= 0;
pool2_end <= 0;
conv2_addra_count <= 0;

ena_pool <= 0;

ena_conv2 <= 0;
wea_conv2 <= 0;
addra_conv2 <= 0;
addren_conv2 <= 0;

//ena_flatten <= 0;
//wea_flatten <= 0;
//addra_flatten <= 0;
//addren_flatten <= 0;

end

else if ( start ) begin

counter <= counter >= 32'd99999 ? 0 : ( counter + 1 );

ena_pool <= 1;

anchor <=  addra_conv2 == 1 ? anchor + 2 : anchor;
conv2_addra_count <= conv2_addra_count == 3 ? 0 : conv2_addra_count + 1;
ena_conv2 = 1;
wea_conv2 <= 0;
addren_conv2 <= 1;
addra_conv2 <= conv2_addra_count == 3 ? anchor : (conv2_addra_count == 1) ? addra_conv2 + (INPUT_WIDTH - 1) : addra_conv2 + 1;

//ena_flatten <= 1;
//wea_flatten <= conv2_addra_count == 1 ? 1 : 0;
//addren_flatten <= 1;
//addra_flatten <= ( conv2_addra_count == 1 && counter >= 8 ) ? addra_flatten + 1 : addra_flatten;

end

else if ( pool2_end ) begin

counter <= '1;

ena_pool <= 0;

ena_conv2 <= 0;
wea_conv2 <= 0;
addra_conv2 <= 0;
addren_conv2 <= 0;

end

end

endmodule
