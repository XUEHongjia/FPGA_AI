
module Rescale #(
parameter BITWIDTH_IN = 24,
parameter BITWIDTH_OUT =  8,
parameter SCALE1 = 199,
parameter SCALE2 = 156,
parameter SCALE3 = 164,
parameter BITWIDTH_SCALE = 8,
parameter BITWIDTH_RIGHT_SHIFT = 16
)
(

input clk,
input rstn,
input ena,
input [ 2-1 : 0 ] select,

input unsigned [ BITWIDTH_IN - 1 : 0 ] in_data,

output unsigned [ BITWIDTH_OUT - 1 : 0 ] result

);

reg unsigned [ BITWIDTH_IN+BITWIDTH_SCALE - 1 : 0 ] product;
reg unsigned [ BITWIDTH_IN+BITWIDTH_SCALE - 1 : 0 ] product_round;
reg unsigned [ BITWIDTH_IN+BITWIDTH_SCALE - 1 : 0 ] product_right_shift;

reg unsigned [ BITWIDTH_SCALE - 1 : 0 ] scale1 = SCALE1;
reg unsigned [ BITWIDTH_SCALE - 1 : 0 ] scale2 = SCALE2;
reg unsigned [ BITWIDTH_SCALE - 1 : 0 ] scale3 = SCALE3;

reg unsigned [ BITWIDTH_RIGHT_SHIFT - 1 : 0 ] point5 = 16'h8000;

always@( posedge clk or negedge rstn ) begin

if ( !rstn ) begin
    product <= '0;
    product_right_shift <= '0;
end

else if ( ena ) begin
    case ( select )
        2'b00: begin
            product <= in_data*scale1; 
        end
        2'b01: begin
            product <= in_data*scale2; 
        end
        2'b10: begin
            product <= in_data*scale3; 
        end
    endcase
    product_round <= product + point5;
    product_right_shift <= product_round >> BITWIDTH_RIGHT_SHIFT;
end

end

assign result = {product_right_shift[ BITWIDTH_OUT - 1 : 0 ]};

endmodule
