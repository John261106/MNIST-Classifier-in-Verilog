module digit_neuron_8 #(
    parameter DATA_W       = 22, //q(16,6)
    parameter WEIGHT_W     = 8,
    parameter NUM_KERNELS  = 8,
    parameter NUM_FEATURES = 169,
    parameter ACC_W        = 42
)(
    input i_clk,
    input i_rst,
    input i_feature_data_valid,
    input signed [DATA_W-1:0] i_feature_data [0:NUM_KERNELS-1],
    output reg o_done,
    output reg signed [ACC_W-1:0] o_score
);

localparam ADDR_W = $clog2(NUM_FEATURES);

reg [ADDR_W-1:0] feature_idx;
reg signed [WEIGHT_W-1:0] weights [0:NUM_KERNELS-1][0:NUM_FEATURES-1];
reg signed [ACC_W-1:0] bias;


wire signed [DATA_W+WEIGHT_W-1:0] product [0:NUM_KERNELS-1];

initial begin
    `include "digit8_weights.vh"

end




genvar g;

generate
    for(g=0; g<NUM_KERNELS; g=g+1)
    begin : MULTS
        assign product[g] =i_feature_data[g] * weights[g][feature_idx];
    end
endgenerate



wire signed [ACC_W-1:0] s0;
wire signed [ACC_W-1:0] s1;
wire signed [ACC_W-1:0] s2;
wire signed [ACC_W-1:0] s3;

wire signed [ACC_W-1:0] s4;
wire signed [ACC_W-1:0] s5;

wire signed [ACC_W-1:0] cycle_sum;

assign s0 = product[0] + product[1];
assign s1 = product[2] + product[3];
assign s2 = product[4] + product[5];
assign s3 = product[6] + product[7];



assign s4 = s0 + s1;
assign s5 = s2 + s3;



assign cycle_sum = s4 + s5;


// --------------------------------------------------
// Accumulator
// --------------------------------------------------

always @(posedge i_clk)
begin

    if(i_rst)
    begin
        o_score     <= 0;
        feature_idx <= 0;
        o_done      <= 0;
    end

    else
    begin
        o_done <= 0;

        if(i_feature_data_valid)
        begin

            if(feature_idx == 0)
                o_score <= cycle_sum + bias;
            else
                o_score <= o_score + cycle_sum;

            if(feature_idx == NUM_FEATURES-1)
            begin
                o_done <= 1'b1;
                feature_idx <= 0;
            end
            else
            begin
                feature_idx <= feature_idx + 1'b1;
            end

        end
    end

end
endmodule