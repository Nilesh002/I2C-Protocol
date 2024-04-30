`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nilesh Poojari
// 
// Create Date: 18.11.2023 22:02:27
// Design Name: 
// Module Name: i2c_controller
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


module i2c_controller(
	input wire CLK,                   // from processor
	input wire rstn,                  // from processor
	input wire chip_sel,              // from processor  
	input wire chip_write,            // from processor	
	input wire [15:0] chip_addr,      // from processor
	input wire [15:0] wdata,          // from processor
	
	input wire [15:0] I2CDRR,         // from i2c_master  DATA OUT / DATA RECEIVE
	input wire [15:0] I2CSTR,         // from i2c master  STATUS
	
	output reg din_write=0,           // to i2c master
	output reg dout_read = 0,         // to i2c master
		
	output reg [15:0] rdata = 0,      // to processor
    
    output reg [15:0] I2CMDR,         // to i2c master  MODE REGISTER
    output reg [15:0] I2CSAR,         // to i2c master  SLAVE ADDR REGISTER
    output reg [15:0] I2COAR,         // to i2c master  OWN ADRESS REGISTER
    output reg [15:0] I2CCNT,         // to i2c master  DATA COUNT REGISTER
    output reg [15:0] I2CDXR,         // to i2c master  DATA IN / DATA TRANSFER REGISTER
    output reg [15:0] I2CPSC,         // to i2c master  PRESCALAR REGISTER
    output reg [15:0] I2CCLKH,        // to i2c master  CLK HIGH REGISTER
    output reg [15:0] I2CCLKL         // to i2c master  CLK LOW REGISTER
    );


always @(posedge CLK) 
begin
    if(rstn)
    begin
       rdata      <= 16'h00; 
       I2CMDR     <= 16'h00;
       I2CSAR     <= 16'h00;
       I2COAR     <= 16'h00;
       I2CCNT     <= 16'h00;
       I2CDXR     <= 16'b00;
       I2CCLKL    <= 16'b00;
       I2CCLKH    <= 16'b00;
       I2CPSC     <= 16'b00;
       din_write  <= 1'b0;
       dout_read  <= 1'b0;
    end
			
	else if (chip_addr[15:0] == 16'h7909 && (chip_sel ==1'b1)) begin // Mode Register
			if (chip_write == 1) begin // write
                I2CMDR <= wdata[15:0];
                din_write <= 1'b0; 
                dout_read <= 1'b0;               
		    end					
		    else begin // read 
                rdata[15:0] <= I2CMDR;   
                din_write <= 1'b0;
                dout_read <= 1'b0;
			end
					
		end
		
		
	else if (chip_addr[15:0] == 16'h7902 && (chip_sel ==1'b1) && (chip_write == 0)) begin // status reg access
                rdata[15:0] <= I2CSTR;   // read	
                din_write <= 1'b0;
                dout_read <= 1'b0;            			
		end	
		
		
	else if (chip_addr[15:0] == 16'h7907 && (chip_sel ==1'b1)) begin // I2C Slave Adress Register
			if (chip_write == 1) begin // write
                I2CSAR <= wdata[15:0];
                din_write <= 1'b0; 
                dout_read <= 1'b0;               
		    end					
		    else begin // read 
                rdata[15:0] <= I2CSAR;   
                din_write <= 1'b0;
                dout_read <= 1'b0;
			end
					
		end
		
		
	else if (chip_addr[15:0] == 16'h7900 && (chip_sel ==1'b1)) begin // I2C Own Adress Register
			if (chip_write == 1) begin // write
                I2COAR <= wdata[15:0];
                din_write <= 1'b0; 
                dout_read <= 1'b0;               
		    end					
		    else begin // read 
                rdata[15:0] <= I2COAR;   
                din_write <= 1'b0;
                dout_read <= 1'b0;
			end
					
		end	
		
		
    else if (chip_addr[15:0] == 16'h7905 && (chip_sel ==1'b1)) begin // I2C Data Count Register
			if (chip_write == 1) begin // write
                I2CCNT <= wdata[15:0];
                din_write <= 1'b0; 
                dout_read <= 1'b0;               
		    end					
		    else begin // read 
                rdata[15:0] <= I2CCNT;   
                din_write <= 1'b0;
                dout_read <= 1'b0;
			end
					
		end
		
		
		
    else if (chip_addr[15:0] == 15'h7906 && (chip_sel ==1'b1) && (chip_write == 0)) begin // data receive reg 
                rdata[7:0] <= I2CDRR; // read
                din_write <= 1'b0;
                dout_read <= 1'b1;  			
		end
		
		
	else if (chip_addr[15:0] == 16'h7908 && (chip_sel ==1'b1) && (chip_write == 1)) begin // data in reg access
                I2CDXR <= wdata[15:0]; // write
                din_write <= 1'b1;  
                dout_read <= 1'b0;               			
		end
		
		
		
	else if (chip_addr[15:0] == 16'h790C && (chip_sel ==1'b1)) begin // I2C Prescalar Register
			if (chip_write == 1) begin // write
                I2CPSC <= wdata[15:0];
                din_write <= 1'b0; 
                dout_read <= 1'b0;               
		    end					
		    else begin // read 
                rdata[15:0] <= I2CPSC;   
                din_write <= 1'b0;
                dout_read <= 1'b0;
			end
					
		end
		
		
	else if (chip_addr[15:0] == 16'h7903 && (chip_sel ==1'b1)) begin // I2C Clock Low Divider Register
			if (chip_write == 1) begin // write
                I2CCLKL <= wdata[15:0];
                din_write <= 1'b0; 
                dout_read <= 1'b0;               
		    end					
		    else begin // read 
                rdata[15:0] <= I2CCLKL;   
                din_write <= 1'b0;
                dout_read <= 1'b0;
			end
					
		end
			
		
	else if (chip_addr[15:0] == 16'h7904 && (chip_sel ==1'b1)) begin // I2C Clock High Divider Register
			if (chip_write == 1) begin // write
                I2CCLKH <= wdata[15:0];
                din_write <= 1'b0; 
                dout_read <= 1'b0;               
		    end					
		    else begin // read 
                rdata[15:0] <= I2CCLKH;   
                din_write <= 1'b0;
                dout_read <= 1'b0;
			end
					
		end
		

	   else 
	   begin
	           rdata[15:0] <= 16'h00;
	           din_write <= 1'b0;
	           dout_read <= 1'b0;   
	   end
end 
endmodule
