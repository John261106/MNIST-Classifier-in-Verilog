module mnist_cnn_top (

    input               i_clk,
    input               i_rst,

    input [7:0]         i_pixel_data,
    input               i_pixel_data_valid,

    output [41:0]       o_score [0:9],
    output [9:0]        o_done ,
    output o_intr
);

// =====================================================
// Controller Outputs
// =====================================================

wire [7:0] block_data [0:2][0:2];
wire       block_data_valid;


controller u_controller(
    .i_clk(i_clk),
    .i_rst(i_rst),

    .i_pixel_data(i_pixel_data),
    .i_pixel_data_valid(i_pixel_data_valid),

    .o_block_data(block_data),
    .o_block_data_valid(block_data_valid),
    .o_intr(o_intr)
);

// =====================================================
// Convolution Outputs
// =====================================================

wire [21:0] kernel_data [0:7];
wire        kernel_valid[0:7];

genvar k;

generate
    for(k=0; k<8; k=k+1)
    begin : CONV_GEN

        conv_relu u_conv_relu(

            .i_clk(i_clk),
            .i_rst(i_rst),

            .i_block_data(block_data),
            .i_block_data_valid(block_data_valid),

            .i_kernel_id(k[2:0]),

            .o_kernel_data(kernel_data[k]),
            .o_kernel_data_valid(kernel_valid[k])

        );

    end

endgenerate

// =====================================================
// Pool + FC
// =====================================================

// Assuming all conv pipelines have identical latency

mnist_pool_fc 
u_mnist_pool_fc(

    .i_clk(i_clk),
    .i_rst(i_rst),

    .i_kernel_data_valid(kernel_valid[0]),

    .i_kernel_data(kernel_data),

    .o_score(o_score),
    .o_done(o_done)

);

endmodule