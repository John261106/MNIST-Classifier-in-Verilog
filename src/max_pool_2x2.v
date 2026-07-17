module max_pool_2x2 #(
    parameter DATA_WIDTH = 22,
    parameter IMG_WIDTH  = 26
)(
    input i_clk,
    input i_rst,
    input  [DATA_WIDTH-1:0] i_kernel_data,
    input i_kernel_data_valid,

    output reg [DATA_WIDTH-1:0] o_max_data,
    output reg o_max_data_valid
);

localparam COUNTER_WIDTH = $clog2(IMG_WIDTH);


reg [DATA_WIDTH-1:0] first_row [0:IMG_WIDTH-1];
reg [DATA_WIDTH-1:0] d;
reg [COUNTER_WIDTH-1:0] pixel_counter;
reg row_select;

integer i;


always @(posedge i_clk) begin
    if(i_rst) begin
        pixel_counter <= 0;
        row_select    <= 1'b0;
    end
    else if(i_kernel_data_valid) begin

        if(pixel_counter == IMG_WIDTH-1) begin
            pixel_counter <= 0;
            row_select    <= ~row_select;
        end
        else begin
            pixel_counter <= pixel_counter + 1'b1;
        end

    end
end


always @(posedge i_clk) begin
    if(i_rst) begin
        d <= 0;
        for(i=0; i<IMG_WIDTH; i=i+1)
            first_row[i] <= 0;
    end
    else if(i_kernel_data_valid) begin
        if(row_select == 1'b0) begin
            first_row[pixel_counter] <= i_kernel_data;
        end
        else begin
            d <= i_kernel_data;

        end

    end

end

always @(posedge i_clk) begin

    if(i_rst) begin
        o_max_data     <= 0;
        o_max_data_valid <= 1'b0;
    end
    else begin

        o_max_data_valid <= 1'b0;

        if(i_kernel_data_valid &&
           row_select &&
           pixel_counter[0] &&
           (pixel_counter > 0))
        begin
            o_max_data <=(((first_row[pixel_counter-1] >first_row[pixel_counter])?first_row[pixel_counter-1]:first_row[pixel_counter])>((d > i_kernel_data)?d:i_kernel_data))?((first_row[pixel_counter-1] >first_row[pixel_counter])?first_row[pixel_counter-1]:first_row[pixel_counter]):((d > i_kernel_data)?d:i_kernel_data);

            o_max_data_valid <= 1'b1;

        end

    end

end

endmodule