module mnist_pool_fc #(
    parameter DATA_WIDTH  = 22,
    parameter IMG_WIDTH   = 26,
    parameter NUM_KERNELS = 8,
    parameter NUM_DIGITS  = 10,
    parameter NUM_FEATURES = 169,
    parameter ACC_W       = 42
)(
    input i_clk,
    input i_rst,

    input i_kernel_data_valid,

    input [DATA_WIDTH-1:0] i_kernel_data [0:NUM_KERNELS-1],

    output [ACC_W-1:0] o_score [0:NUM_DIGITS-1],
    output [NUM_DIGITS-1:0] o_done
);



// Max Pool Outputs


wire [DATA_WIDTH-1:0] pooled_data [0:NUM_KERNELS-1];
wire pooled_valid[0:NUM_KERNELS-1];

genvar k;

generate
    for(k=0; k<NUM_KERNELS; k=k+1)
    begin : MAX_POOL_GEN
        max_pool_2x2 #(
            .DATA_WIDTH(DATA_WIDTH),
            .IMG_WIDTH (IMG_WIDTH)
        )
        u_max_pool (
            .i_clk(i_clk),
            .i_rst(i_rst),
            .i_kernel_data(i_kernel_data[k]),
            .i_kernel_data_valid(i_kernel_data_valid),

            .o_max_data(pooled_data[k]),
            .o_max_data_valid(pooled_valid[k])
        );

    end
endgenerate


// Use pooled_valid from kernel 0
// All pools should be synchronized


wire neuron_valid;

assign neuron_valid = pooled_valid[0];



// Digit Neurons (0-9)


digit_neuron_0 #(
    .DATA_W(DATA_WIDTH),
    .WEIGHT_W(8),
    .NUM_KERNELS(NUM_KERNELS),
    .NUM_FEATURES(NUM_FEATURES),
    .ACC_W(ACC_W)
) u_digit0 (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_feature_data_valid(neuron_valid),
    .i_feature_data(pooled_data),
    .o_done(o_done[0]),
    .o_score(o_score[0])
);

digit_neuron_1 #(
    .DATA_W(DATA_WIDTH),
    .WEIGHT_W(8),
    .NUM_KERNELS(NUM_KERNELS),
    .NUM_FEATURES(NUM_FEATURES),
    .ACC_W(ACC_W)
) u_digit1 (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_feature_data_valid(neuron_valid),
    .i_feature_data(pooled_data),
    .o_done(o_done[1]),
    .o_score(o_score[1])
);

digit_neuron_2 #(
    .DATA_W(DATA_WIDTH),
    .WEIGHT_W(8),
    .NUM_KERNELS(NUM_KERNELS),
    .NUM_FEATURES(NUM_FEATURES),
    .ACC_W(ACC_W)
) u_digit2 (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_feature_data_valid(neuron_valid),
    .i_feature_data(pooled_data),
    .o_done(o_done[2]),
    .o_score(o_score[2])
);
digit_neuron_3#(
    .DATA_W(DATA_WIDTH),
    .WEIGHT_W(8),
    .NUM_KERNELS(NUM_KERNELS),
    .NUM_FEATURES(NUM_FEATURES),
    .ACC_W(ACC_W)
) u_digit3 (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_feature_data_valid(neuron_valid),
    .i_feature_data(pooled_data),
    .o_done(o_done[3]),
    .o_score(o_score[3])
);

digit_neuron_4 #(
    .DATA_W(DATA_WIDTH),
    .WEIGHT_W(8),
    .NUM_KERNELS(NUM_KERNELS),
    .NUM_FEATURES(NUM_FEATURES),
    .ACC_W(ACC_W)
) u_digit4 (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_feature_data_valid(neuron_valid),
    .i_feature_data(pooled_data),
    .o_done(o_done[4]),
    .o_score(o_score[4])
);

digit_neuron_5 #(
    .DATA_W(DATA_WIDTH),
    .WEIGHT_W(8),
    .NUM_KERNELS(NUM_KERNELS),
    .NUM_FEATURES(NUM_FEATURES),
    .ACC_W(ACC_W)
) u_digit5 (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_feature_data_valid(neuron_valid),
    .i_feature_data(pooled_data),
    .o_done(o_done[5]),
    .o_score(o_score[5])
);

digit_neuron_6 #(
    .DATA_W(DATA_WIDTH),
    .WEIGHT_W(8),
    .NUM_KERNELS(NUM_KERNELS),
    .NUM_FEATURES(NUM_FEATURES),
    .ACC_W(ACC_W)
) u_digit6 (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_feature_data_valid(neuron_valid),
    .i_feature_data(pooled_data),
    .o_done(o_done[6]),
    .o_score(o_score[6])
);

digit_neuron_7 #(
    .DATA_W(DATA_WIDTH),
    .WEIGHT_W(8),
    .NUM_KERNELS(NUM_KERNELS),
    .NUM_FEATURES(NUM_FEATURES),
    .ACC_W(ACC_W)
) u_digit7 (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_feature_data_valid(neuron_valid),
    .i_feature_data(pooled_data),
    .o_done(o_done[7]),
    .o_score(o_score[7])
);

digit_neuron_8 #(
    .DATA_W(DATA_WIDTH),
    .WEIGHT_W(8),
    .NUM_KERNELS(NUM_KERNELS),
    .NUM_FEATURES(NUM_FEATURES),
    .ACC_W(ACC_W)
) u_digit8 (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_feature_data_valid(neuron_valid),
    .i_feature_data(pooled_data),
    .o_done(o_done[8]),
    .o_score(o_score[8])
);

digit_neuron_9 #(
    .DATA_W(DATA_WIDTH),
    .WEIGHT_W(8),
    .NUM_KERNELS(NUM_KERNELS),
    .NUM_FEATURES(NUM_FEATURES),
    .ACC_W(ACC_W)
) u_digit9 (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_feature_data_valid(neuron_valid),
    .i_feature_data(pooled_data),
    .o_done(o_done[9]),
    .o_score(o_score[9])
);

endmodule