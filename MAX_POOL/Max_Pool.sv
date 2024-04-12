
module Max_Pool #(
parameter BITWIDTH = 8,
parameter LENGTH = 4
)
(
input clk,
input rstn,
input ena,

input unsigned [ BITWIDTH - 1 : 0 ] in_data[ LENGTH - 1 : 0 ],
output reg unsigned [ BITWIDTH - 1 : 0 ] max_out
);

reg unsigned [ BITWIDTH - 1 : 0 ] inter0;
reg unsigned [ BITWIDTH - 1 : 0 ] inter1;

always@( posedge clk or negedge rstn ) begin

if ( ! rstn ) begin
    inter0 <= '0;
    inter1 <= '0;
    max_out <= '0;
end

else if ( ena ) begin
    inter0 <= in_data[0] > in_data[1] ? in_data[0]:in_data[1];
    inter1 <= in_data[2] > in_data[3] ? in_data[2]:in_data[3];
    max_out <= inter0 > inter1 ? inter0 : inter1;
end

end

endmodule
