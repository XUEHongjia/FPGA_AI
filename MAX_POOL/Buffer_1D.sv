
module Buffer_1D#
(
parameter BITWIDTH = 8,
parameter LENGTH = 4
)
(
input clk,
input rstn,
input ena,

input  [ BITWIDTH-1 : 0 ] data_in,

output reg [ BITWIDTH-1 : 0 ] data_out[ LENGTH-1 : 0 ]
);

integer i;
integer l;

always@( posedge clk or negedge rstn ) begin

if ( !rstn ) begin

    for ( l = 0; l < LENGTH; l = l + 1 ) begin
            data_out[ l ] <= '0;
    end
end

else if ( ena ) begin
    data_out[0] <= data_in;
    for ( i = 0; i < LENGTH - 1; i = i + 1 ) begin
        data_out[ i + 1 ] <= data_out[i];
    end
end

end
endmodule
