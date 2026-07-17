module line_buffer(
    input i_clk,
    input i_rst, 
    input [7:0]i_data,
    input i_data_valid,
    input i_rd_data,
    
    output [7:0]o_data[0:2]
);

reg [7:0] line [0:27];
reg [4:0] wrPtr, rdPtr;


//Write Logic
always @(posedge i_clk) begin
    if(i_rst) begin
        wrPtr <= 0;
    end
    else if(i_data_valid) begin
        line[wrPtr] <= i_data;
        if(wrPtr == 27)
            wrPtr <= 0;
        else
            wrPtr <= wrPtr + 1;
    end
end

//Read-Logic
always @(posedge i_clk) begin
    if(i_rst) begin
        rdPtr <= 0;
    end
    else if(i_rd_data) begin
        if(rdPtr == 25)
            rdPtr <= 0;
        else
            rdPtr <= rdPtr + 1;
    end
end

assign {o_data[0], o_data[1], o_data[2]} = {line[rdPtr], line[rdPtr+1], line[rdPtr+2]};

endmodule