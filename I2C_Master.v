`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nilesh Poojari
// 
// Create Date: 24.2.2024 22:02:27
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

module i2c_master(
input CLK,

inout wire [15:0] I2CMDR,    //Mode Register
input wire [15:0] I2CSAR,   // Slave Adress register
input wire [15:0] I2COAR,   //Own Adress Register
input wire [15:0] I2CCNT,   // Count Register
input wire [15:0] I2CDXR,   //Transmit register
input wire [15:0] I2CPSC,   // Clock divider type, not used. initialized to zero
input wire [15:0] I2CCLKH,        // clk divider higher bit
input wire [15:0] I2CCLKL,       // clk divider lower bit

input wire din_write,    // write control signal
input wire dout_read,    // read control signal

output reg [15:0] I2CDRR=0,   // data Receive register
output reg [15:0] I2CSTR=0,   // status register

inout i2c_sda,
inout i2c_scl
);

	localparam 
		IDLE = 0,
		START = 1,
		ADDR = 2,
		ACK = 3,
		WDATA = 4,
		RDATA = 5,
		WWACK = 6,
		RACK = 7,
		STOP = 8;
	
	
reg clk = 1;
reg [3:0] state,n_state;
reg sda,scl;
reg [7:0] TX_reg = 8'h00;  // transmit shift register
reg [7:0] RX_reg = 8'h00;  // recieve shift register
reg [7:0] s_addr = 8'h00;  // slave address + r/w bit
reg [7:0] d_count = 8'h00; // data_count is copied into this register
reg [3:0] count = 0;       // tx/rx bit count



// control signals
wire enable;
wire reset;
reg ena = 0;
reg en  = 0;


//status signals
wire xrdy;  // recieve ready status signal
wire Rrdy;
reg xrdy_temp = 1;
reg Rrdy_temp = 1;
reg  xrdy_set = 1;
reg  Rrdy_set = 0;

reg NackSent=0; // not used
reg NackRcvd = 0;


reg [31:0] counter = 0;

supply0 gnd;
wire rw;   // R/W status bit
wire NACKMOD; // control signal to send NACK bit 
wire AAS;  // adressed as slave
wire AD0;   // general call
reg ARDY;  // registers are ready to be acsessed
reg SCD;  // Stop Condition Detected
reg BB;         // Bus Busy
reg NACKSNT; // NACK Sent
wire STT;  // start
wire STP;  //STOP
wire REPEARED_START;
reg [15:0] HALF_DIVIDER=0;



////FPGA implementation////// 
	assign i2c_scl = (scl)?1'b1:1'b0;
	assign i2c_sda = (state == ACK || state == RDATA || state == WWACK || n_state == ACK || n_state == WWACK) ? 1'bz : ( (sda)? 1'b1 : gnd );
	/////FPGA implementation//////
	


////////////// SCL generation ///////////////
always@(posedge clk)
begin
    if (en) scl <= ~scl;
	else scl <= 1;
end

// Transmit ready(xrdy) and Receive ready(Rrdy) control signal generation

always@(negedge CLK)
begin
    if(!reset) begin
        xrdy_set <= 1'b0;
        Rrdy_set <= 1'b0;
        I2CDRR <= 8'h00;
                   
        Rrdy_temp <= 1'b0;
        TX_reg <= 8'h00;
        xrdy_temp <= 1'b0;
        end
    else begin
        if(din_write)
        begin
            xrdy_set <= 1'b0;
        end
        else if(dout_read)
        begin
            Rrdy_set <= 1'b0;
        end
        else if(state  == RACK && Rrdy_temp == 1'b1)
        begin
            I2CDRR[7:0] <= RX_reg;
            Rrdy_set  <=  1'b1;             ////
            Rrdy_temp <= 1'b0; 
        end
        else if(state == ACK || state == WWACK || state == START)
        begin
        if(xrdy_temp)
        begin        
            TX_reg <= I2CDXR[7:0];
            xrdy_set <= 1'b1;
            xrdy_temp <= 1'b0;
        end
        end
        else 
        begin
            Rrdy_temp <= 1'b1;
            xrdy_temp <= 1'b1;
        end
    end
end
    
assign xrdy = (din_write)?1'b0:xrdy_set;
assign Rrdy = (dout_read)?1'b0:Rrdy_set;


// reset logic and state transition
always@(posedge clk or negedge reset)
begin
    if(!reset)
    begin
        state <= IDLE;
    end
    else
    begin
        state <= n_state;
    end
end

/////////////////////////////////////////////////////////////////////////////////

// Clock divider calculation
always @(posedge CLK) HALF_DIVIDER = (I2CCLKL + I2CCLKH + 2)/4 ;




assign NACKMOD = I2CMDR[15]; 
assign reset = I2CMDR[5];
assign rw = ~(I2CMDR[9] & I2CMDR[10]);
assign AAS = ( (I2CSAR == I2COAR) || (I2CSAR[6:0] == 7'b0)) ? 1'b1 : 1'b0;
assign AD0 = (I2CSAR[6:0] == 7'b0) ? 1'b1 : 1'b0;
assign STT = I2CMDR[13];
assign STP = I2CMDR[9];
assign REPEATED_START = I2CMDR[12];


/////////////////////////////////FSM start/////////////////////////////////////
always@(negedge clk)
begin
    case(state)
        IDLE : begin
            sda <= 1'b1;
            en <= 0;
//            ARDY <= 1'b0;
//            SCD <= 1'b0;
//            BB <= 1'b0;
//            NACKSNT <= 1'b0;
//            NackRcvd <= 1'b0;
            count <= 4'b0000;                    
            if(STT && (~ena))
                n_state <= START;
            else
                n_state <= IDLE;
        end
        
        START: begin 
				sda <= 0;
				en <= 1;
//				BB <= 1'b1;
//              NackRcvd <= 1'b0;
				n_state <= ADDR;
				d_count <= I2CCNT - 1'b1;
				s_addr[7:1] <= I2CSAR[6:0]; //copying slave addr???????????
				s_addr[0] <= rw;  // rw bit         
				RX_reg <= 8'b00;				
        end
        
			ADDR: begin
				if (i2c_scl == 0) begin
					if (count < 8) begin
						sda <= s_addr[4'h7-count];
						count <= count + 1'b1;
						n_state <= ADDR;
					end
					else if (count == 8) begin
						n_state <= ACK;						
					end
				end
				else n_state <= ADDR;
			end
			
			ACK: begin
				sda <= i2c_sda;				
				if (i2c_sda == 1) n_state <= STOP;
				else 
				begin				    
					if (s_addr[0] == 0)
						n_state <= WDATA;
					else if (s_addr[0] == 1)
						n_state <= RDATA;
				end
				count <= 4'b0000;
			end			

			WDATA: begin			     
				if (scl == 0) begin
					if (count < 8) begin
						sda <= TX_reg[4'h7-count];
						count <= count + 1'b1;
						n_state <= WDATA;
						
					end
					else if (count == 8) begin
						n_state <= WWACK;										        
					end
				end
				else 
					n_state <= WDATA;
			end
			
			WWACK: begin			
				sda <= i2c_sda;
				if (i2c_sda == 1) begin
					n_state <= WDATA;
					count <= 1'b0;
					NackRcvd <= 1'b1;
				end
				else begin
					if (d_count > 0) begin
						n_state <= WDATA;
						d_count <= d_count - 1'b1;
						count <= 1'b0;
					end

					else if (d_count == 0 && REPEATED_START == 0)
						n_state <= STOP;
					else if (d_count == 0 && REPEATED_START == 1 && STT==1'b1) begin
						n_state <= START;
						d_count <= 0;
					end
				end
			end
            					
			RDATA: begin
				if (scl == 1) begin
					if (count < 7) begin
						RX_reg[4'h7-count] <= i2c_sda;
						count <= count + 1'b1;
						n_state <= RDATA;
					end
					else if (count == 7) begin
						n_state <= RACK;
						RX_reg[4'h7-count] <= i2c_sda;
						
					end
				end
				else n_state <= RDATA;
			end
			
			RACK: begin 
				if (scl == 0) begin					
					if (d_count != 8'h00) begin
					   if(NACKMOD == 1'b1) begin
					   sda<=1'b1; 
					   NACKSNT <= 1'b1;
					   end
					   
					   else begin
					    sda <= 0;
						n_state <= RDATA;
						d_count <= d_count -1'b1; 
						count <= 0;
					end
					end
					else
					   sda <= 1'b1;
					   n_state <= STOP;
					   d_count <= 0;
				end
				else 
					n_state <= RACK;
			end
					
			STOP: begin
				count <= 2'b0;
				en <= 0;
				ena <= 1;
				sda <= 0;
				SCD <= 1'b1;
				ARDY <= 1'b1;
				if (scl == 1) begin
					sda <= 1;
					n_state <= IDLE;
				end
				else n_state <= STOP;
			end
			
			default: begin
				n_state <= IDLE;
				sda <= 1;
//				SCD <= 1'b0;
//				ARDY <= 1'b0;
//				BB <= 1'b0;
				count <= 4'b0000;
				en <= 0;
			end
			
    endcase
end
/////////////////////////////////// FSM END//////////////////////////////////////////

// Status signals

always @(*)
begin
case(state)
IDLE : begin
            ARDY <= 1'b0;
            SCD <= 1'b0;
            BB <= 1'b0;
            NACKSNT <= 1'b0;
            NackRcvd <= 1'b0;
        end

START: begin 
            ARDY <= 1'b0;
            SCD <= 1'b0;
            BB <= 1'b1;
            NACKSNT <= 1'b0;
            NackRcvd <= 1'b0;					
       end
     
     
ADDR,ACK,WDATA,WWACK,RDATA:
        begin
            ARDY <= 1'b0;
            SCD <= 1'b0;
            BB <= 1'b1;
            NACKSNT <= 1'b0;
            NackRcvd <= 1'b0;
        end     

STOP: begin
            ARDY <= 1'b1;
            SCD <= 1'b1;
            BB <= 1'b1;
            NACKSNT <= 1'b0;
            NackRcvd <= 1'b0;
	  end

default: begin
            ARDY <= 1'b0;
            SCD <= 1'b0;
            BB <= 1'b0;
            NACKSNT <= 1'b0;
            NackRcvd <= 1'b0;
	     end
endcase
end







/////////////////////////// status register(I2CSTR) update////////////////////////////////////////////
//************************************
	 always @(negedge CLK) begin
	   if(!reset)
	   I2CSTR <= 16'd0;  
	   else 
	    begin
	   I2CSTR[15] <= 1'b0;
	   I2CSTR[14] <= (~( I2CMDR[10] & I2CMDR[9] )) ? 1'b1 : 1'b0; 
	   I2CSTR[13] <= NACKSNT;
	   I2CSTR[12] <= BB;
	   I2CSTR[11] <= 1'b0;
	   I2CSTR[10] <= 1'b0;
	   I2CSTR[9]  <= AAS;
	   I2CSTR[8]  <= AD0;
	   I2CSTR[7]  <= 1'b0;
	   I2CSTR[6]  <= 1'b0;
	   I2CSTR[5]  <= SCD;
	   I2CSTR[4]  <= xrdy;
	   I2CSTR[3]  <= Rrdy;
	   I2CSTR[2]  <= ARDY;
	   I2CSTR[1]  <= NackRcvd;
	   I2CSTR[0]  <= 1'b0;
		end
	 end

	
	
//*************************************************************************************
//  CLK GENERATION BLOCK
	
always @(posedge CLK) 
begin
     if (counter >= HALF_DIVIDER - 1) 
        begin
          counter <= 0;
          clk <= ~clk; 
         end 
     else
         begin
          counter <= counter + 1;
         end
end

	
endmodule