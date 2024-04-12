
module Rescale_Conv2 #(
parameter BITWIDTH_IN = 24,
parameter BITWIDTH_OUT =  8,
parameter SCALE = 181,
parameter BITWIDTH_SCALE = 8,
parameter BITWIDTH_RIGHT_SHIFT = 16
)
(

input clk,
input rstn,
input ena,

input unsigned [ BITWIDTH_IN - 1 : 0 ] in_data,

output unsigned [ BITWIDTH_OUT - 1 : 0 ] result

);

reg unsigned [ BITWIDTH_IN+BITWIDTH_SCALE - 1 : 0 ] product;
reg unsigned [ BITWIDTH_IN+BITWIDTH_SCALE - 1 : 0 ] product_round;
reg unsigned [ BITWIDTH_IN+BITWIDTH_SCALE - 1 : 0 ] product_right_shift;

reg unsigned [ BITWIDTH_SCALE - 1 : 0 ] scale = SCALE;

reg unsigned [ BITWIDTH_RIGHT_SHIFT - 1 : 0 ] point5 = 16'h8000;

always@( posedge clk or negedge rstn ) begin

if ( !rstn ) begin
    product <= '0;
    product_right_shift <= '0;
end

else if ( ena ) begin
    product <= in_data*scale; 
    product_round <= product + point5;
    product_right_shift <= product_round >> BITWIDTH_RIGHT_SHIFT;
end

end

assign result = {product_right_shift[ BITWIDTH_OUT - 1 : 0 ]};

endmodule
