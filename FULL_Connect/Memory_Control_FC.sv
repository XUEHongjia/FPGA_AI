

module Memory_Control_FC #(
parameter IN_LENGTH = 256,
parameter FC1_LENGTH = 120,
parameter FC2_LENGTH = 84,
parameter FC3_LENGTH = 10
)
(
input clk,
input rstn,
input start,

output in_data_select,
output out_data_select,
output out_buffer_ena,

output fc_bias_re,
output fc_bias_address,
output fc_bias_addressen,

output fc_weight_re,
output fc_weight_address,
output fc_weight_addressen,

output fc_in_data_re,
output fc_in_data_address,
output fc_in_data_addressen,

output fc_out_data_re,
output fc_out_data_we,
output fc_out_data_wclke,
output fc_out_data_address,
output fc_out_data_addressen,

output fc_ena,
output fc_ena_add

);

localparam COUNT_WID = 10;
localparam NUM_STATE = 4;

reg [ COUNT_WID - 1 : 0 ] fc1_row_count = '0;
reg [ COUNT_WID - 1 : 0 ] fc1_col_count = '0;
reg [ COUNT_WID - 1 : 0 ] fc2_row_count = '0;
reg [ COUNT_WID - 1 : 0 ] fc2_col_count = '0;
reg [ COUNT_WID - 1 : 0 ] fc3_row_count = '0;
reg [ COUNT_WID - 1 : 0 ] fc3_col_count = '0;

reg [ 4-1 : 0 ] cstate = '0;
localparam IDLE = 4'b0000;
localparam FC1 = 4'b0001;
localparam FC2 = 4'b0010;
localparam FC3 = 4'b0011;

always@( posedge clk or negedge rstn ) begin

if ( !rstn ) begin
    cstate <= IDLE;
end

else begin

    case( cstate )
    
    IDLE:
    begin
        
    end
    
end

end

endmodule