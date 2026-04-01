`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.02.2026 15:39:23
// Design Name: 
// Module Name: i2c_top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_tbi2c();
reg clk,rst;
reg [6:0] addr;
reg [7:0] master_data_in;
reg enable;
reg rw;
wire [7:0] master_data_recived;
wire ready;
wire i2c_sda, i2c_scl;
I2C_master master(.clk(clk),.rst(rst),.addr(addr),.data_in(master_data_in),.enable(enable),.rw(rw),.
                  data_recived(master_data_recived),.ready(ready),.i2c_sda(i2c_sda),.i2c_scl(i2c_scl));
i2c_slave slave(.sda(i2c_sda),.scl(i2c_scl));

always #1 clk=~clk;
initial begin
$monitor("SLAVE STATE:%d", slave.state);
$monitor("SLAVE RECIVED DATA:%b",slave.data_recived,slave.counter);
clk=0; rst=1; enable=0;
addr=7'b0101010;
master_data_in=8'h78;
rw=0; //write operation
#20;
rst=0;
$display("starting write operation");
enable=1;
#10 enable=0;
wait(ready==1);
$display("WRITE COMPLETED");
if(slave.data_recived==8'h78)
$display("SUCCESS:SLAVE RECIVED MASTER DATA");
else
$display("ERROR: slave recived different data: %h",slave.data_recived);
rw=1;  //read operation
enable=1;
#10 enable=0;
wait(ready==1);
$display("READ COMPLETED");
if(master_data_recived==8'haa)
$display("read:master recived same data from slave");
else
$display("ERROR:master recived different:%h",master_data_recived);
end

endmodule