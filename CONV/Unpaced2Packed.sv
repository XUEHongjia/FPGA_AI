
module Unpacked2Packed #( 
BITWIDTH = 8,
LENGTH = 6
)
(
input [ LENGTH*BITWIDTH - 1 : 0 ] unpacked_in,

output [ BITWIDTH - 1 : 0 ] packed_out [ LENGTH - 1 : 0 ]
);
genvar l;

generate 

for ( l = 0; l < LENGTH; l = l + 1 ) begin
    assign packed_out[l] = { unpacked_in[ BITWIDTH*l + BITWIDTH - 1 : BITWIDTH*l ] };
end

endgenerate

endmodule
