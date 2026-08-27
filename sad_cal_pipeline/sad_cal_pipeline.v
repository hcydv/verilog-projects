module sad_cal_pipeline(
    input wire clk,
    input wire rst_n,

    input wire [63:0] a_data,
    input wire [63:0] b_data,
    input wire in_valid,

    output reg [10:0] sad_out,
    output reg out_valid
);

reg [3:0] pipeline_valid;
reg [7:0] pipeline_stage0 [0:7];
reg [8:0] pipeline_stage1 [0:3];
reg [9:0] pipeline_stage2 [0:1];
reg [10:0] pipeline_stage3;

reg [7:0] data_pipe0 [0:7];
reg [8:0] data_pipe1 [0:3];
reg [9:0] data_pipe2 [0:1];
reg [10:0] data_pipe3;

always @(*)
    begin
    pipeline_stage0[0] = a_data[7:0]   > b_data[7:0]   ? a_data[7:0]   - b_data[7:0]   : b_data[7:0]   - a_data[7:0];
    pipeline_stage0[1] = a_data[15:8]  > b_data[15:8]  ? a_data[15:8]  - b_data[15:8]  : b_data[15:8]  - a_data[15:8];
    pipeline_stage0[2] = a_data[23:16] > b_data[23:16] ? a_data[23:16] - b_data[23:16] : b_data[23:16] - a_data[23:16];
    pipeline_stage0[3] = a_data[31:24] > b_data[31:24] ? a_data[31:24] - b_data[31:24] : b_data[31:24] - a_data[31:24];
    pipeline_stage0[4] = a_data[39:32] > b_data[39:32] ? a_data[39:32] - b_data[39:32] : b_data[39:32] - a_data[39:32];
    pipeline_stage0[5] = a_data[47:40] > b_data[47:40] ? a_data[47:40] - b_data[47:40] : b_data[47:40] - a_data[47:40];
    pipeline_stage0[6] = a_data[55:48] > b_data[55:48] ? a_data[55:48] - b_data[55:48] : b_data[55:48] - a_data[55:48];
    pipeline_stage0[7] = a_data[63:56] > b_data[63:56] ? a_data[63:56] - b_data[63:56] : b_data[63:56] - a_data[63:56];
    end

always @(*)
    begin
    pipeline_stage1[0] = data_pipe0[0] + data_pipe0[1];
    pipeline_stage1[1] = data_pipe0[2] + data_pipe0[3];
    pipeline_stage1[2] = data_pipe0[4] + data_pipe0[5];
    pipeline_stage1[3] = data_pipe0[6] + data_pipe0[7];  
    end

always @(*)
    begin
    pipeline_stage2[0] = data_pipe1[0] + data_pipe1[1];
    pipeline_stage2[1] = data_pipe1[2] + data_pipe1[3];
    end

always @(*)
    pipeline_stage3 = data_pipe2[0] +data_pipe2[1];

integer i;
always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        begin
            data_pipe0[0] <= 0;
            data_pipe0[1] <= 0;
            data_pipe0[2] <= 0;
            data_pipe0[3] <= 0;
            data_pipe0[4] <= 0;
            data_pipe0[5] <= 0;
            data_pipe0[6] <= 0;
            data_pipe0[7] <= 0;
            data_pipe1[0] <= 0;
            data_pipe1[1] <= 0;
            data_pipe1[2] <= 0;
            data_pipe1[3] <= 0;
            data_pipe2[0] <= 0;
            data_pipe2[1] <= 0;
            data_pipe3 <= 0;
        end
    else
        begin 
            data_pipe0[0] <= in_valid ? pipeline_stage0[0] : 0;
            data_pipe0[1] <= in_valid ? pipeline_stage0[1] : 0;
            data_pipe0[2] <= in_valid ? pipeline_stage0[2] : 0;
            data_pipe0[3] <= in_valid ? pipeline_stage0[3] : 0;
            data_pipe0[4] <= in_valid ? pipeline_stage0[4] : 0;
            data_pipe0[5] <= in_valid ? pipeline_stage0[5] : 0;
            data_pipe0[6] <= in_valid ? pipeline_stage0[6] : 0;
            data_pipe0[7] <= in_valid ? pipeline_stage0[7] : 0;
            data_pipe1[0] <= pipeline_stage1[0];
            data_pipe1[1] <= pipeline_stage1[1];
            data_pipe1[2] <= pipeline_stage1[2];
            data_pipe1[3] <= pipeline_stage1[3];
            data_pipe2[0] <= pipeline_stage2[0];
            data_pipe2[1] <= pipeline_stage2[1];
            data_pipe3 <= pipeline_stage3;
        end
 
always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        pipeline_valid <= 0;
    else 
        begin
            pipeline_valid[0] <= in_valid;
            pipeline_valid[1] <= pipeline_valid[0];
            pipeline_valid[2] <= pipeline_valid[1];
            pipeline_valid[3] <= pipeline_valid[2];
        end

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        out_valid <= 0;
    else if(pipeline_valid[3] == 1)
        out_valid <= 1;
    else 
        out_valid <= 0;

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        sad_out <= 0;
    else if(pipeline_valid[3] == 1)
        sad_out <= data_pipe3;
    else 
        sad_out <= 0;

endmodule