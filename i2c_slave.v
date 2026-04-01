`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.02.2026 15:12:10
// Design Name: 
// Module Name: i2c_slave
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

/*
module i2c_slave #(parameter ADDRESS =7'b0101010)
                  (inout sda,
                  input scl);

parameter READ_ADDR =0,
          SEND_ACK =1,
          READ_DATA =2,
          WRITE_DATA =3,
          SEND_ACK2 =4;
          
reg[7:0] addr;
reg [2:0] counter;
reg [2:0] state;
reg [7:0] data_recived =0; //data_recived from master
reg [7:0] data_out = 8'b10101010; //data send to master
reg sda_out =0;
reg start =0;
reg write_enable =0;                          

assign sda = (write_enable ==1) ?sda_out:1'bz;

//DETECH START CONDITION
always @(negedge sda)begin
if(!start && scl ==1) begin
start <=1;
counter <=7;
end
end

//DETECT STOP CONDITION
always @(posedge sda) begin
if(start && scl) begin
start <=0;
state <= READ_ADDR;
write_enable <=0;
end
end


// FSM READ
always @(posedge scl) begin
if(start)begin
case(state)
READ_ADDR:begin
addr[counter] <=sda;
if(counter ==0)
state <= SEND_ACK;
else
counter <= counter-1;
end
SEND_ACK:begin
if(addr[7:1] == ADDRESS) begin
state <= (addr[0]==0)? READ_DATA: WRITE_DATA;
end
end
READ_DATA:begin
data_recived[counter] <= sda;
if(counter ==0)
state <= SEND_ACK2;
else
counter <= counter-1;
end
SEND_ACK2:begin
state <= READ_ADDR;
end
WRITE_DATA:begin
if(counter ==0)
state <= READ_ADDR;
else
counter <=counter-1;
end
endcase
end
end  

always @(negedge scl) begin
case(state)
READ_ADDR:write_enable <=0;
SEND_ACK:begin
sda_out <=0;
write_enable <=1;
end
READ_DATA:write_enable <=0;
WRITE_DATA:begin
sda_out <=data_out[counter];
write_enable <=1;
end
SEND_ACK2:begin
sda_out <=0;
write_enable <=1;
end
endcase
end       
endmodule
*/



module i2c_slave #(parameter ADDRESS =7'b0101010)
                  (inout sda,
                  inout scl);

parameter READ_ADDR=0,
          SEND_ACK=1,
          READ_DATA=2,
          WRITE_DATA=3,
          SEND_ACK2=4;

reg[7:0] addr;
reg[2:0] counter;
reg[2:0] state=READ_ADDR;
reg[7:0] data_recived=0; // data recived from master
reg[7:0] data_out=8'b10101010; //data send to master
reg sda_out=0;
reg start =0;
reg write_enable=0;

assign sda=(write_enable==1)?sda_out:1'bz;
//detect start condition
always @(negedge sda) begin
if(!start && scl==1) begin
start <=1;
counter <=7;
end
end

//DETECT STOP CONDITION
always @(posedge sda) begin
if(start && scl) begin
start <=0;
state <=READ_ADDR;
write_enable <=0;
end
end

//FSM READ
always @(posedge scl) begin
if(start) begin
case(state)
READ_ADDR: begin
addr[counter] <=sda;
if(counter==0)
state <=SEND_ACK;
else
counter <= counter -1;
end
SEND_ACK: begin
if(addr[7:1] ==ADDRESS) begin
counter <=7;
state <= (addr[0] ==0 )? READ_DATA:WRITE_DATA;
end
end
READ_DATA: begin
data_recived[counter] <= sda;
if(counter==0)
state <=SEND_ACK2;
else
counter <= counter-1;
end
SEND_ACK2: begin
state <= READ_ADDR;
end
WRITE_DATA: begin
if(counter==0)
state <= READ_ADDR;
else
counter <=counter-1;
end
endcase
end
end

always @(negedge scl) begin
case(state)
READ_ADDR: write_enable <=0;
SEND_ACK: begin
sda_out <=0;
write_enable <=1;
end
READ_DATA: write_enable <=0;
WRITE_DATA: begin
sda_out <=data_out[counter];
write_enable<=1;
end
SEND_ACK2: begin
sda_out <=0;
write_enable <=1;
end
endcase
end    
endmodule