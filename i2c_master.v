`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.02.2026 13:11:05
// Design Name: 
// Module Name: i2c_master
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



module I2C_master(input clk,input rst,
                  input [6:0] addr,
                  input [7:0] data_in,
                  input enable,
                  input rw,
                  output reg [7:0] data_recived,
                  output ready,
                  inout i2c_sda,
                  inout i2c_scl);

parameter IDLE=0,
          START=1,
          ADDRESS=2,
          READ_ACK=3,  //SLAVE TO MASTER
          WRITE_DATA=4,
          READ_DATA=5,
          WRITE_ACK=6,  //MASTER TO SLAVE
          READ_ACK2=7,  //SLAVE TO MASTER
          STOP=8;
          
parameter CLK_DIV=4; //clk divider ckt 

reg[3:0] state=IDLE;
reg[7:0] saved_addr;
reg[7:0] saved_data;
reg[2:0] counter,counter2=0;
reg write_enable=1;
reg sda_out=1;
reg i2c_scl_enable=0;
reg i2c_clk=1;  //clk divider output,external clk given to master

assign ready=((rst==0) && (state==IDLE))?1:0;
assign i2c_scl=(i2c_scl_enable==0)?1:i2c_clk;
assign i2c_sda=(write_enable==1)?sda_out:1'bz;

//clock divider for I2C MASTER
always @(posedge clk) begin
if(counter2 ==(CLK_DIV/2)-1) begin
i2c_clk <= ~i2c_clk;
counter2 <=0;
end
else
counter2 <= counter2+1;
end
//control scl enable
always @(negedge i2c_clk or posedge rst) begin
if(rst)
i2c_scl_enable <=0;
else if((state==IDLE)||(state==START)||(state==STOP))
i2c_scl_enable <=0;
else
i2c_scl_enable <=1;
end 

//READ FSM
always @(posedge i2c_clk or posedge rst) begin
if(rst) begin
state <=IDLE;
end
else begin
case(state)
IDLE: begin
if(enable) begin
state <= START;
saved_addr <={addr,rw};
saved_data <=data_in;
end
else begin
state <= IDLE;
saved_addr <=0;
saved_data <=0;
end
end
START: begin
counter <=7;  //8BIT COUNT
state <=ADDRESS;
end
ADDRESS: begin
if(counter==0)
state <=READ_ACK;
else begin
counter <=counter-1;
state <=ADDRESS;
end
end
READ_ACK: begin
if(i2c_sda==0) begin
counter<=7;
state <=(saved_addr[0] ==0)?WRITE_DATA:READ_DATA;
end
else begin
state <=STOP;
end
end
WRITE_DATA:begin
if(counter==0)
state <= READ_ACK2;
else
counter <=counter-1;
end
READ_ACK2: begin
state <=(i2c_sda ==0 && enable==1)?IDLE:STOP;
end
READ_DATA: begin
data_recived[counter] <= i2c_sda;  //sampling--> reading
if(counter==0)
state <=WRITE_ACK;
else
counter <=counter-1;
end
WRITE_ACK: begin
state <=STOP;
end
STOP: begin
state <=IDLE;
end
endcase
end
end

//SDA CONTROL WRITING OPERATION
always @(negedge i2c_clk or posedge rst) begin
if(rst) begin
write_enable <=1;
sda_out <=1;
end
else begin
case(state)
START: begin
write_enable <=1;
sda_out <=0;
end
ADDRESS: begin
sda_out <=saved_addr[counter];
end
READ_ACK: begin
write_enable<=0;
end
WRITE_DATA: begin
write_enable <=1;
sda_out <=saved_data[counter];
end
WRITE_ACK: begin
write_enable <=1;
sda_out <=0;
end
READ_DATA: begin
write_enable<=0;
end
READ_ACK: begin
write_enable <=0;
end
STOP: begin
write_enable <=1;
sda_out <=1;
end
endcase
end
end
endmodule