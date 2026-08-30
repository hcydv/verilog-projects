`timescale 1ns/1ns

module tb_sync_fifo();

reg clk;
reg rst_n;

reg [7:0] wr_data;
reg wr_en;
reg rd_en;

wire [7:0] rd_data;
wire full;
wire empty;

reg [7:0] ref_fifo [0:15];
integer ref_wr_ptr;
integer ref_rd_ptr;
integer ref_count;
reg [7:0] expected;
reg expected_valid;

integer i;
always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        begin
            ref_wr_ptr <= 0;
            for(i=0;i<=15;i=i+1)
                ref_fifo[i] <= 0;
        end 
    else if(wr_en == 1 && ref_count != 16)
        begin
            ref_fifo[ref_wr_ptr] <= wr_data;
            $display("write %0d",wr_data);
            if(ref_wr_ptr == 4'd15)
                ref_wr_ptr <= 0;
            else 
                ref_wr_ptr <= ref_wr_ptr + 1;
        end

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        ref_count <= 0;
    else if(ref_count == 0 && wr_en == 1 && rd_en == 1)
        ref_count <= ref_count + 1;
    else if(ref_count == 5'd16 && wr_en == 1 && rd_en == 1)
        ref_count <= ref_count - 1;
    else if(wr_en == 1 && rd_en == 1)
        ref_count <= ref_count;
    else if(wr_en == 1 && rd_en == 0 && ref_count <= 4'd15)
        ref_count <= ref_count + 1;
    else if(wr_en == 0 && rd_en == 1 && ref_count >= 1)
        ref_count <= ref_count - 1;
    else if(wr_en == 0 && rd_en == 1 && ref_count == 0)
        ref_count <= 0;
    else if(wr_en == 0 && rd_en == 0)
        ref_count <= ref_count;


always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        begin
            ref_rd_ptr <= 0;
            expected <=0;
            expected_valid <= 0;
        end
    else if(rd_en == 1 && ref_count != 0)
        begin
            expected <= ref_fifo[ref_rd_ptr];
            expected_valid <= 1;
            if(ref_rd_ptr == 4'd15)
                ref_rd_ptr <= 0;
            else 
                ref_rd_ptr <= ref_rd_ptr + 1;
        end
    else if(rd_en == 1 && ref_count == 0)
        expected <= expected;
    else
        begin 
            expected <= 0;
            expected_valid <= 0;
        end

always @(posedge clk or negedge rst_n)
    if(expected_valid == 1)
        begin
            if(expected == rd_data)
                $display("CORRECT,actual=%0d,expected=%0d",rd_data,expected);
            else
                $display("ERROR,actual=%0d,expected=%0d",rd_data,expected);
        end

initial begin
    clk <= 1;
    wr_en   = 0;
    wr_data = 0;
    rd_en   = 0;
    rst_n = 0;
    #20;
    rst_n = 1;
    // Test 1：写入 4 个数据
    @(negedge clk);
    wr_en   = 1;
    wr_data = 8'h11;

    @(negedge clk);
    wr_data = 8'h22;

    @(negedge clk);
    wr_data = 8'h33;

    @(negedge clk);
    wr_data = 8'h44;

    @(negedge clk);
    wr_en = 0;

    // Test 2：连续读出 4 个数据
    @(negedge clk);
    rd_en = 1;

    repeat(4)
        @(negedge clk);

    rd_en = 0;

    // Test 3：连续写满 FIFO
    @(negedge clk);
    wr_en = 1;

    repeat(16) begin
        wr_data = wr_data + 1;
        @(negedge clk);
    end

    wr_en = 0;

    // Test 4：满状态下继续尝试写
    @(negedge clk);
    wr_en   = 1;
    wr_data = 8'hAA;

    @(negedge clk);
    wr_en = 0;

    // Test 5：读几个数据
    @(negedge clk);
    rd_en = 1;

    repeat(5)
        @(negedge clk);

    rd_en = 0;

    // Test 6：同时读写
    @(negedge clk);
    wr_en   = 1;
    rd_en   = 1;
    wr_data = 8'hA1;

    @(negedge clk);
    wr_data = 8'hA2;

    @(negedge clk);
    wr_data = 8'hA3;

    @(negedge clk);
    wr_data = 8'hA4;

    @(negedge clk);
    wr_en = 0;
    rd_en = 0;


    // Test 7：继续读，直到 FIFO 空
    @(negedge clk);
    rd_en = 1;

    repeat(20)
        @(negedge clk);

    rd_en = 0;

    // Test 8：空状态下继续尝试读
    @(negedge clk);
    rd_en = 1;

    @(negedge clk);
    rd_en = 0;

    //Text 9:空状态下读写
    @(negedge clk);
    rd_en = 1;
    wr_en = 1;
    wr_data = wr_data + 1;

    //Text 10:写满后同时读写
    @(negedge clk)
    rd_en = 0;
    repeat(16)begin
        wr_data = wr_data + 1;
        @(negedge clk);
    end
    rd_en = 1;

    //结束
    @(negedge clk);
    wr_en = 0;
    rd_en = 0;
end

always #10 clk =~clk;

sync_fifo sync_fifo_inst(
    .clk(clk),
    .rst_n(rst_n),

    .wr_data(wr_data),
    .wr_en(wr_en),
    .rd_en(rd_en),

    .rd_data(rd_data),
    .full(full),
    .empty(empty)
);


endmodule