`timescale 1ns / 1ps
`define PERIOD 10

module tb_faulty_fifo_behav();

logic wr_clk = 1'b1;
logic rd_clk = 1'b1;
logic reset_i;
logic rd_en_i;
logic [63:0] dout_o;
logic empty_o;
logic [63:0] din_i;
logic wr_en_i;
logic wr_rst_busy;
logic rd_rst_busy;

faulty_fifo_behav dut(
    .wr_clk(wr_clk),
    .rd_clk(rd_clk),
    .reset_i(reset_i),
    .rd_en_i(rd_en_i),
    .dout_o(dout_o),
    .empty_o(empty_o),
    .din_i(din_i),
    .wr_en_i(wr_en_i),
    .wr_rst_busy(wr_rst_busy),
    .rd_rst_busy(rd_rst_busy)
);

always
    #(`PERIOD/4) wr_clk = ~wr_clk;

always
    #(`PERIOD/2) rd_clk = ~rd_clk;

initial begin
    reset_i <= 1'b1;
    din_i   <= '0;
    wr_en_i <= '0;
    rd_en_i <= 1'b0;
    #(`PERIOD*10);
    reset_i <= 1'b0;
    wait(wr_rst_busy == 1'b0 && rd_rst_busy == 1'b0);

    @(negedge wr_clk)
    din_i   <= 64'hABABABABABABABAB;
    wr_en_i <= 1'b1;

    @(negedge wr_clk)
    wr_en_i <= 1'b0;

    wait(empty_o == 1'b0);
    #(`PERIOD*10);
    $finish;
end
endmodule