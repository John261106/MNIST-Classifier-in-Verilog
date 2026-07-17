module controller(
    input  i_clk,
    input  i_rst,
    input  [7:0]i_pixel_data,
    input  i_pixel_data_valid,
    output reg [7:0]o_block_data[0:2][0:2],
    output o_block_data_valid,
    output reg o_intr
);

reg  [4:0]pixelCounter;
reg  [1:0]currentWrtLB, currentRdLB;
reg  [3:0]lBWrtValid, lBRdValid;
reg  [6:0]totalPixelCounter;
reg  present_state;
reg  [4:0]rd_counter;

localparam IDLE = 0, RD_BUFFER = 1;

reg rd_line_buffer;

assign o_block_data_valid = rd_line_buffer;

always @(posedge i_clk) begin
    if(i_rst)
        totalPixelCounter <= 0;
    else begin
        if(i_pixel_data_valid && !rd_line_buffer)
            totalPixelCounter <= totalPixelCounter + 1;
        else if(!i_pixel_data_valid && rd_line_buffer)
            totalPixelCounter <= totalPixelCounter - 1;
    end
end

always @(posedge i_clk) begin
    if(i_rst) begin
        present_state <= IDLE;
        rd_line_buffer <= 0;
        o_intr <= 0;
    end
    else begin
        case(present_state)
            IDLE : begin
                o_intr <= 0;
                if(totalPixelCounter >= 84) begin
                    rd_line_buffer <= 1;
                    present_state  <= RD_BUFFER;
                end
            end
            RD_BUFFER : begin
                if(rd_counter == 25) begin
                    present_state  <= IDLE;
                    rd_line_buffer <= 0;
                    o_intr <= 1;
                end
            end
        endcase
    end
end


//Write logic
always @(posedge i_clk) begin
    if(i_rst) begin
        pixelCounter <= 0;
        currentWrtLB <= 0;
    end
    else if(i_pixel_data_valid) begin
        if(pixelCounter == 27) begin
            pixelCounter <= 0;
            currentWrtLB <= currentWrtLB + 1;
        end
        else
            pixelCounter <= pixelCounter + 1;
    end
end

//Write Data Valid for all the Line Buffers
always @(*) begin
    lBWrtValid = 4'h0;
    lBWrtValid[currentWrtLB] = i_pixel_data_valid;
end

//Read Logic
always @(posedge i_clk) begin
    if(i_rst) begin
        rd_counter <= 0;
        currentRdLB <= 0;
    end
    else begin
        if(rd_line_buffer && (rd_counter == 25)) begin
            rd_counter <= 0;
            currentRdLB <= currentRdLB + 1;
        end
        else if(rd_line_buffer)
            rd_counter <= rd_counter + 1;
    end
end

//Read Data Valid for all Line buffers
always @(*) begin
    case(currentRdLB)
        2'd0: begin
            lBRdValid[0] = rd_line_buffer;
            lBRdValid[1] = rd_line_buffer;
            lBRdValid[2] = rd_line_buffer;
            lBRdValid[3] = 0;
        end
        2'd1: begin
            lBRdValid[0] = 0;
            lBRdValid[1] = rd_line_buffer;
            lBRdValid[2] = rd_line_buffer;
            lBRdValid[3] = rd_line_buffer;
        end
        2'd2: begin
            lBRdValid[0] = rd_line_buffer;
            lBRdValid[1] = 0;
            lBRdValid[2] = rd_line_buffer;
            lBRdValid[3] = rd_line_buffer;
        end
        2'd3: begin
            lBRdValid[0] = rd_line_buffer;
            lBRdValid[1] = rd_line_buffer;
            lBRdValid[2] = 0;
            lBRdValid[3] = rd_line_buffer;
        end
    endcase
end

wire [7:0]lB1_out[0:2];
wire [7:0]lB2_out[0:2];
wire [7:0]lB3_out[0:2];
wire [7:0]lB4_out[0:2];

integer j;

//Pixel Data Output Logic(Concatenation)
always @(*) begin
    case(currentRdLB)
        2'd0: begin
            for(j = 0; j < 3; j = j + 1) begin
                o_block_data[0][j] = lB1_out[j];
                o_block_data[1][j] = lB2_out[j];
                o_block_data[2][j] = lB3_out[j];
            end
        end
        2'd1: begin
            for(j = 0; j < 3; j = j + 1) begin
                o_block_data[0][j] = lB2_out[j];
                o_block_data[1][j] = lB3_out[j];
                o_block_data[2][j] = lB4_out[j];
            end
        end
        2'd2: begin
            for(j = 0; j < 3; j = j + 1) begin
                o_block_data[0][j] = lB3_out[j];
                o_block_data[1][j] = lB4_out[j];
                o_block_data[2][j] = lB1_out[j];
            end
        end
        2'd3: begin
            for(j = 0; j < 3; j = j + 1) begin
                o_block_data[0][j] = lB4_out[j];
                o_block_data[1][j] = lB1_out[j];
                o_block_data[2][j] = lB2_out[j];
            end
        end
    endcase
end

line_buffer lB1(
    .i_clk(i_clk),
    .i_rst(i_rst), 
    .i_data(i_pixel_data),
    .i_data_valid(lBWrtValid[0]),
    .i_rd_data(lBRdValid[0]),
    .o_data(lB1_out)
);

line_buffer lB2(
    .i_clk(i_clk),
    .i_rst(i_rst), 
    .i_data(i_pixel_data),
    .i_data_valid(lBWrtValid[1]),
    .i_rd_data(lBRdValid[1]),
    .o_data(lB2_out)
);

line_buffer lB3(
    .i_clk(i_clk),
    .i_rst(i_rst), 
    .i_data(i_pixel_data),
    .i_data_valid(lBWrtValid[2]),
    .i_rd_data(lBRdValid[2]),
    .o_data(lB3_out)
);

line_buffer lB4(
    .i_clk(i_clk),
    .i_rst(i_rst), 
    .i_data(i_pixel_data),
    .i_data_valid(lBWrtValid[3]),
    .i_rd_data(lBRdValid[3]),
    .o_data(lB4_out)
);

endmodule