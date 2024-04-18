
module Max_Pool_Accu #(
parameter BITWIDTH = 8
)
(
input clk,
input rstn,
input ena,

input unsigned [ BITWIDTH - 1 : 0 ] in_data,
output reg unsigned [ BITWIDTH - 1 : 0 ] max_out
);

always@( posedge clk or negedge rstn ) begin

if ( ! rstn ) begin
    max_out <= '0;
end

else if ( ena ) begin
    max_out <= max_out > in_data ? max_out : in_data;
end

else if ( !ena ) begin
	max_out <= in_data;
end

end

endmodule
