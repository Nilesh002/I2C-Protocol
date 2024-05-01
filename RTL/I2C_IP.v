`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nilesh Poojari 
// 
// Create Date: 12.03.2024 15:16:44
// Design Name: 
// Module Name: i2c_ip
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



module i2c_ip(
	input wire CLK,                   
	input wire rstn,                  
	input wire chip_sel,              
	input wire chip_write,            
	input wire [15:0] chip_addr,       
	input wire [15:0] wdata,
	input wire A0,
    input wire A1,
    input wire A2,
    input wire WP,
	output [15:0]rdata,
	inout i2c_scl,
	inout i2c_sda,
	output [15:0] status
    );
    
    
    
    
wire [15:0] I2CMDR;
wire [15:0] I2CSAR;
wire [15:0] I2COAR;
wire [15:0] I2CCNT;
wire [15:0] I2CDXR;
wire [15:0] I2CPSC;         
wire [15:0] I2CCLKH;        
wire [15:0] I2CCLKL;  


wire din_write;
wire dout_read;

wire [15:0] I2CDRR;
wire [15:0] I2CSTR;
    
    
assign status=I2CSTR; 
    
    
i2c_controller controller(
CLK,                   // from processor
rstn,                  // from processor
chip_sel,              // from processor  
chip_write,            // from processor	
chip_addr,      // from processor
wdata,          // from processor
I2CDRR,         // from i2c_master  DATA OUT / DATA RECEIVE
I2CSTR,         // from i2c master  STATUS	
din_write,           // to i2c master
dout_read,         // to i2c master	
rdata,      // to processor
I2CMDR,         // to i2c master  MODE
I2CSAR,         // to i2c master  SLAVE ADDR
I2COAR,         // to i2c master  OWN ADDRESS
I2CCNT,         // to i2c master  DATA COUNT
I2CDXR,         // to i2c master  DATA IN / DATA TRANSFER
I2CPSC,         // to i2c master  PRESCALAR 
I2CCLKH,        // to i2c master  CLK HIGH
I2CCLKL         // to i2c master  CLK LOW
);
    
i2c_master master(
CLK,
I2CMDR,
I2CSAR,
I2COAR,
I2CCNT,
I2CDXR,
I2CPSC,         
I2CCLKH,        
I2CCLKL,  
din_write,
dout_read,
I2CDRR,
I2CSTR,
i2c_sda,
i2c_scl
);


// M24AA64 i2c_slave(
//     .A0(A0), 
//     .A1(A1), 
//     .A2(A2),
//     .WP(WP),
//     .SDA(i2c_sda), 
//     .SCL(i2c_scl), 
//     .RESET(~rstn)
//     );






endmodule
