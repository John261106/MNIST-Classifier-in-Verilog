module conv_relu(
    input  i_clk,
    input  i_rst,
    input  [7:0] i_block_data [0:2][0:2],
    input        i_block_data_valid,
    input  [2:0]i_kernel_id,

    output reg [21:0] o_kernel_data,
    output reg        o_kernel_data_valid
);

integer i;
// kernel[kernel_number][row][column]
reg signed [7:0] kernel [0:7][0:2][0:2];
// One bias per kernel
reg signed [20:0] bias [0:7];

/*
Fixed-point representation

Input pixel  : Q(9,0) (After adding 0 in start)
Kernel weight: Q(2,6)

Multiplication:
Q(9,0) × Q(2,6) = Q(11,6)

Adder tree:
Level 1 : Q(12,6)
Level 2 : Q(13,6)
Level 3 : Q(14,6)
Final Sum: Q(15,6)

Bias      : Q(15,6)
Bias Sum  : Q(16,6)

Output after ReLU:
Q(16,6)

Note:
Q(I,F) denotes a fixed-point number with
I integer bits (including the sign bit)
and F fractional bits.
Total width = I + F bits.
*/

initial begin

`include "kernel_init.vh"

end




//Stage-1 : Multiplication
reg signed [16:0] multData [0:8];
reg               multValid;

always @(posedge i_clk) begin
    if(i_rst) begin
        for(i = 0; i < 9; i = i + 1) begin
            multData[i] <= 0;
        end
        multValid <= 0;
    end
    else begin // here we are adding 1 bit of 0 since i_blockdata is unsigened
        multData[0] <= $signed({1'b0, i_block_data[0][0]}) * $signed(kernel[i_kernel_id][0][0]);
        multData[1] <= $signed({1'b0, i_block_data[0][1]}) * $signed(kernel[i_kernel_id][0][1]);
        multData[2] <= $signed({1'b0, i_block_data[0][2]}) * $signed(kernel[i_kernel_id][0][2]);

        multData[3] <= $signed({1'b0, i_block_data[1][0]}) * $signed(kernel[i_kernel_id][1][0]);
        multData[4] <= $signed({1'b0, i_block_data[1][1]}) * $signed(kernel[i_kernel_id][1][1]);
        multData[5] <= $signed({1'b0, i_block_data[1][2]}) * $signed(kernel[i_kernel_id][1][2]);

        multData[6] <= $signed({1'b0, i_block_data[2][0]}) * $signed(kernel[i_kernel_id][2][0]);
        multData[7] <= $signed({1'b0, i_block_data[2][1]}) * $signed(kernel[i_kernel_id][2][1]);
        multData[8] <= $signed({1'b0, i_block_data[2][2]}) * $signed(kernel[i_kernel_id][2][2]);

        multValid <= i_block_data_valid;
    end
end

// Stage-2 : Adder Tree Level-1

reg signed [17:0] add_l1 [0:4];
reg               addl1_valid;

always @(posedge i_clk) begin
    if(i_rst) begin
        for(i = 0; i < 5; i = i + 1) begin
            add_l1[i] <= 0;
        end
        addl1_valid <= 0;
    end
    else begin
        add_l1[0] <= multData[0] + multData[1];
        add_l1[1] <= multData[2] + multData[3];
        add_l1[2] <= multData[4] + multData[5];
        add_l1[3] <= multData[6] + multData[7];
        add_l1[4] <= multData[8];

        addl1_valid <= multValid;
    end
end

// Stage-3 : Adder Tree Level-2

reg signed [18:0] add_l2 [0:2];
reg               addl2_valid;

always @(posedge i_clk) begin
    if(i_rst) begin
        for(i = 0; i < 3; i = i + 1) begin
            add_l2[i] <= 0;
        end
        addl2_valid <= 0;
    end
    else begin
        add_l2[0] <= add_l1[0] + add_l1[1];
        add_l2[1] <= add_l1[2] + add_l1[3];
        add_l2[2] <= add_l1[4];

        addl2_valid <= addl1_valid;
    end
end

//Stage-4 : Adder Tree Level-3

reg signed [19:0] add_l3 [0:1];
reg               addl3_valid;

always @(posedge i_clk) begin
    if(i_rst) begin
        for(i = 0; i < 2; i = i + 1) begin
            add_l3[i] <= 0;
        end
        addl3_valid <= 0;
    end
    else begin
        add_l3[0] <= add_l2[0] + add_l2[1];
        add_l3[1] <= add_l2[2];

        addl3_valid <= addl2_valid;
    end
end

//Stage-5 : Final Adder

reg signed [20:0] conv_sum;
reg               conv_sum_valid;

always @(posedge i_clk) begin
    if(i_rst) begin
        conv_sum <= 0;
        conv_sum_valid <= 0;
    end
    else begin
        conv_sum <= add_l3[0] + add_l3[1];

        conv_sum_valid <= addl3_valid;
    end  
end

//Stage-6 Bias Addition

reg signed [21:0] biased_sum;
reg               bias_sum_valid;

always @(posedge i_clk) begin
    if(i_rst) begin
        biased_sum <= 0;
        bias_sum_valid <= 0;
    end
    else begin
        biased_sum <= conv_sum + bias[i_kernel_id];
        bias_sum_valid <= conv_sum_valid;    
    end
end

//Stage-7 ReLU Stage
always @(posedge i_clk) begin
    if(i_rst) begin
        o_kernel_data <= 0;
        o_kernel_data_valid <= 0;
    end
    else begin
    if(biased_sum < 0)
        o_kernel_data <= 22'd0;
    else
        o_kernel_data <= biased_sum;
        
    o_kernel_data_valid <= bias_sum_valid;
    end
end

endmodule