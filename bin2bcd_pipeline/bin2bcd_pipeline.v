module bin2bcd_pipeline(
    input wire clk,
    input wire rst_n,
    
    input wire [15:0] bin_in,
    input wire in_valid,

    output reg [19:0] bcd_out,
    output reg out_valid
);

reg [35:0] data_pipe [0:15];
wire [35:0] stage_next [0:15];
reg [15:0] valid_pipe;

integer m;
integer n;
integer i;

shift_add3 shift_add3_inst0(
    .data({20'b0,bin_in}),
    .out(stage_next[0])
);

genvar j;
generate
    for(j=0;j<=14;j=j+1) begin:shift_add
        shift_add3 shift_add3_inst(
            .data(data_pipe[j]),
            .out(stage_next[j+1])
        );
    end
endgenerate

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        valid_pipe <= 0;
    else 
        begin
            valid_pipe[0] <= in_valid;
            valid_pipe[15:1] <= valid_pipe[14:0];
        end

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        begin
            for(m=0;m<=15;m=m+1)
                begin
                data_pipe[m] <= 0;
                end
        end
    else if(in_valid == 1)
        begin
        data_pipe[0] <= stage_next[0];
        for(i=1;i<=15;i=i+1)
            data_pipe[i] <= stage_next[i];
        end
    else if(in_valid == 0)
        begin
        data_pipe[0] <= 0;
        for(i=1;i<=15;i=i+1)
            data_pipe[i] <= stage_next[i];
        end

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        out_valid <= 0;
    else if(valid_pipe[15] == 1)
        out_valid <= 1;
    else
        out_valid <= 0;

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        bcd_out <= 0;
    else if(valid_pipe[15] == 1)
        bcd_out <= data_pipe[15][35:16];
    else 
        bcd_out <= 0;

endmodule

module shift_add3(
    input wire [35:0] data,

    output reg [35:0] out
);

reg [35:0] data_reg;

always @(*)
    begin
        data_reg = data;
    if(data_reg[35:32] >= 4'd5)
        data_reg[35:32] = data_reg[35:32] + 4'd3;

    if(data_reg[31:28] >= 4'd5)
        data_reg[31:28] = data_reg[31:28] + 4'd3;

    if(data_reg[27:24] >= 4'd5)
        data_reg[27:24] = data_reg[27:24] + 4'd3;

    if(data_reg[23:20] >= 4'd5)
        data_reg[23:20] = data_reg[23:20] + 4'd3;

    if(data_reg[19:16] >= 4'd5)
        data_reg[19:16] = data_reg[19:16] + 4'd3;

    out = data_reg << 1;
    end


endmodule