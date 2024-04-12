
module Vector_ADD_BIAS#(
parameter BITWIDTH_BIAS = 8,
parameter BITWIDTH_DATA = 24,
parameter LENGTH = 4
)
(
    input clk,
    input rstn,
    input ena,
    
    input signed [ BITWIDTH_DATA - 1 : 0 ] data_in [ LENGTH - 1 : 0 ] ,
    input signed [ BITWIDTH_BIAS - 1 : 0 ] bias [ LENGTH - 1 : 0 ] ,
    
    output reg signed [ BITWIDTH_DATA - 1 : 0 ] result [ LENGTH - 1 : 0 ]
);

integer i;
always@ ( posedge clk or negedge rstn ) begin

if ( !rstn ) begin
for ( i = 0; i < LENGTH; i = i + 1 ) begin
    result[i] <= '0;
end
end

else if ( ena ) begin
for ( i = 0; i < LENGTH; i = i + 1 ) begin
    result[i] <= bias[i] + data_in[i];
end
end

end

endmodule
