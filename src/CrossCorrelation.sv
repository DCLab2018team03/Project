// input possible_frames and predict_frame and
// output the index that maximize the correlation
`include "PitchDefine.sv"
module CrossCorrelation (
    input i_clk,
    input i_rst,
    input [10:0] i_counter,
    input [9:0] i_data_counter,
    input signed [15:0] possible_frame_data, // serial input
    input signed [15:0] predict_frame_data,  // serial input
    output [10:0] index
);
    logic signed [32:0] partial_sum, n_partial_sum;
    logic [10:0] max_index, n_max_index;
    logic signed [32:0] max_value, n_max_value;
    assign index = max_index;
    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            partial_sum <= 0;
            max_index <= 0;
            max_value <= 0;
        end else begin
            partial_sum <= n_partial_sum;
            max_index <= n_max_index;
            max_value <= n_max_value;
        end 
    end
    always_comb begin
        if (i_data_counter == 0) begin
            n_partial_sum = possible_frame_data * predict_frame_data;
        end
        else begin
            n_partial_sum = partial_sum + possible_frame_data * predict_frame_data;
        end
        n_max_value = max_value;
        n_max_index = max_index;
        if (i_data_counter == 3) begin
            if (n_partial_sum > max_value) begin
                n_max_value = n_partial_sum;
                n_max_index = i_counter;
            end
        end
    end
endmodule