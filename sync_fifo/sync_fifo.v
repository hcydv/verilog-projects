module sync_fifo(
    input wire clk,
    input wire rst_n,

    input wire [7:0] wr_data,
    input wire wr_en,
    input wire rd_en,

    output reg [7:0] rd_data,
    output wire full,
    output wire empty
);

reg [7:0] mem [0:15];

reg [4:0] wr_ptr;
reg [4:0] rd_ptr;

assign full = (wr_ptr[4] != rd_ptr[4] && wr_ptr[3:0] == rd_ptr[3:0]);
assign empty = (wr_ptr[4] == rd_ptr[4] && wr_ptr[3:0] == rd_ptr[3:0]);

integer i;
always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        begin
            wr_ptr <= 0;
            for(i=0;i<=15;i=i+1)
            mem [i] <= 0;
        end
    else if(wr_en == 1 && full != 1)
        begin
            mem[wr_ptr[3:0]] <= wr_data;
            if(wr_ptr[3:0] == 4'd15)
                begin
                    wr_ptr[4] <= wr_ptr[4] + 1;
                    wr_ptr[3:0] <= 0;
                end
            else
                wr_ptr[3:0] <= wr_ptr[3:0] + 1;
        end
       
always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        begin
            rd_data <= 0;
            rd_ptr <= 0;
        end
    else if(rd_en == 1 && empty != 1)
        begin
            rd_data <= mem[rd_ptr[3:0]];
            if(rd_ptr[3:0] == 4'd15)
                begin
                    rd_ptr[3:0] <= 0;
                    rd_ptr[4] <= rd_ptr[4] + 1;
                end
            else 
                rd_ptr[3:0] <= rd_ptr[3:0] + 1;
        end
    else if(rd_en == 1 && empty == 1)
        rd_data <= rd_data;
    else
        rd_data <= 0;


endmodule