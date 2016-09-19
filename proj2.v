/*
*	Soumil Verma
*	ECE 310-001
*	Dr. Kamal Sandersan
*	Project 2 - Cache Design For Microcontroller
*/

module ValidArray(clock, reset, valid, index, state);
  	input clock;
	input reset;
	input [3:0] index;
  	input [3:0] state;
   output valid;

  	wire [15:0] update;
  	reg [15:0] validarr;

	always @(posedge clock)
		if(reset)
        
		 validarr <= 16'b0;
		else
			if(state == 4'd8)
			
			validarr <= update; 
			else
				validarr <= validarr;
		assign update = validarr | 1'b1 << index;

 	 
	 assign valid = validarr[index];
 
endmodule



module CacheController(clock, reset, state, count, miss, rd, macc, rrdy, rdrdy, wacpt);
	input clock;
	input reset;
  	input rd;
	input miss;
	input rrdy;
	input rdrdy;
	input wacpt;
	input macc;
  	output [1:0] count;
  	output [3:0] state;
	

  	reg [3:0] state;
  	reg [1:0] count;

  	always @(posedge clock)
		if(reset || macc == 0)
      	begin
      		state <= 0;
        	 	count <= 0;
      	end
    	else
			case(state)
			
				0 : if (rd == 1)
				begin 
					if (miss == 1)
						state <= 1;
					else
						state <= 0;
		  		end
		  	 	else
					state <= 4;
				1 : if (rrdy == 1)
					state <= 2;
		  		else
					state <= 1;
				2 : if (rdrdy == 1)
						state <= 3;
		  		 	else
						state <= 2;
				3 : if (rdrdy == 1)
						state <= 3;
		  			else 
						begin
							if (count == 3)
								state <= 8;
							else 
								begin
									state <= 2;
									count <= count+1;
								end
		  				end
				4 : if (wacpt == 1)
						state <= 5;
		  			 else
					 	state <= 4;
				5 : if (wacpt == 1)
						state <= 5;
		  			 else
					 	state <= 6;
				6 : if (wacpt == 1)
						state <= 7;
		  			 else
					 	state <= 6;
				7 : if (wacpt == 1)
						state <= 7;
		  			 else 
					 	begin
							if (miss == 1)
								state <= 2;
							else
								state <= 8;
		  				 end
				8 : begin
					state <= 0;
					count <= 0;
				end
			default : begin
			state <= 0;
			count <= 0;
		end
	endcase
endmodule


module ProcInterface(clock, rd, addr, dout, complete, state, miss, blockdata);
	input clock;
	input rd;
	input miss;
	input [15:0] addr;
	input [63:0] blockdata;
	input [3:0] state;
	output complete;
	output [15:0] dout;

	reg complete;
	reg [15:0] dout;

  	always @(posedge clock)
		if(rd && complete)begin
 	  	
			case(addr[1:0])
			0 : dout <= blockdata[15:0];
			1 : dout <= blockdata[31:16];
			2 : dout <= blockdata[47:32];
			3 : dout <= blockdata[63:48];
			endcase
		end
  	 always @(rd or miss or state) 
  		begin
  	 	
		if((state == 0 && miss == 0 && rd == 1) || (state == 8))
			complete <= 1;
		else
			complete <= 0;
  		end
endmodule


module MemInterface(state, addr, din, offdata, miss, rrqst, rdacpt, wrqst);
	input miss;
	input [3:0] state;
	input [15:0] addr;
	input [15:0] din;
	output rrqst;
	output rdacpt;
	output wrqst;
	output [15:0] offdata;

	reg rrqst;
	reg rdacpt;
	reg wrqst;
	reg [15:0] offdata;

	always @(state or miss)
	
		case(state)
		
		0 : begin
			rrqst <= 0;
			rdacpt <= 0;
			wrqst <= 0;
		end
		
		1 : begin
			rrqst <= 1;
			rdacpt <= 0;
			wrqst <= 0;
		end
		
		2  :begin
			rrqst <= 0;
			rdacpt <= 0;
			wrqst <= 0;
		end
		
		3 : begin
			rrqst <= 0;
			rdacpt <= 1;
			wrqst <= 0;
		end
		
		4 : begin
			if (miss == 1)
				rrqst <= 1;
			else
				rrqst <= 0;
				rdacpt <= 0;
				wrqst <= 1;
			end
	
			5 : begin
				rrqst <= 0;
				rdacpt <= 0;
				wrqst <= 0;
			end
			
			6 : begin
				rrqst <= 0;
				rdacpt <= 0;
				wrqst <= 1;
			end
			
			7 : begin
				rrqst <= 0;
				rdacpt <= 0;
				wrqst <= 0;
			end
			
			8 : begin
				rrqst <= 0;
				rdacpt <= 0;
				wrqst <= 0;
			end
			default : begin
			rrqst <= 0;
			rdacpt <= 0;
			wrqst <= 0;
			end
		endcase

		always @(wrqst or rrqst or addr or din or state)
		case({rrqst,wrqst})
			0 : offdata <= 16'bz;
			1 : begin
				case (state)
			4 : offdata <= addr;
			6 : offdata <= din;
			default : offdata <= 16'bz;
		endcase
	end
	2 : offdata <= addr;
	3 : offdata <= addr;
	default : offdata <= 16'bz;
	endcase

endmodule



module CacheData(clock, state, count, valid, miss, rd, addr, din, blockdata, offdata);
	input clock;
	input valid;
	input rd;
	input [3:0] state; 
	input [1:0] count;
	input [15:0] addr;
	input [15:0] din;
	input [15:0] offdata;
	output miss;
	output [63:0] blockdata;

	wire ramrd;
	wire [73:0] cramin;
	wire [73:0] cramout;

	reg [63:0] blockreg;

	wire [9:0] tag;
	reg [1:0] blocksel0;
	reg [1:0] blocksel1;
	reg [1:0] blocksel2;
	reg [1:0] blocksel3;

	assign miss=(valid == 0 || (valid == 1 && tag != addr[15:6]))?1:0;
	assign ramrd=(state == 3 || (state == 5 && miss == 0))?0:1;
	assign {tag,blockdata} = cramout;
	assign cramin = {addr[15:6],blockreg};
	
	CacheRAM cram(cramin, cramout, addr[5:2], ramrd);
	
	always @(*)
		case(state)
			4 : case(addr[1:0])
			0 : begin
				blocksel0 <= 1;
				blocksel1 <= 0;
				blocksel2 <= 0;
				blocksel3 <= 0;
			end
			
			1 : begin
				blocksel0 <= 0;
				blocksel1 <= 1;
				blocksel2 <= 0;
				blocksel3 <= 0;
			end
			
			2 : begin
				blocksel0 <= 0;
				blocksel1 <= 0;
				blocksel2 <= 1;
				blocksel3 <= 0;
			end
			
			3 : begin
				blocksel0 <= 0;
				blocksel1 <= 0;
				blocksel2 <= 0;
				blocksel3 <= 1;
			end
        endcase
		
			2 : case(count)
				0 : begin
					blocksel0 <= 2;
					blocksel1 <= 0;
					blocksel2 <= 0;
					blocksel3 <= 0;
				end
				1 : begin
					blocksel0 <= 0;
					blocksel1 <= 2;
					blocksel2 <= 0;
					blocksel3 <= 0;
				end
				2 : begin
					blocksel0 <= 0;
					blocksel1 <= 0;
					blocksel2 <= 2;
					blocksel3 <= 0;
				end
				3 : begin
					blocksel0 <= 0;
					blocksel1 <= 0;
					blocksel2 <= 0;
					blocksel3 <= 2;
				end
        	 endcase 
			 default : begin
				blocksel0 <= 0;
				blocksel1 <= 0;
				blocksel2 <= 0;
				blocksel3 <= 0;
			end
		endcase

	always @(posedge clock)begin
		
		case(blocksel0)
			1 : blockreg[15:0] <=  din[15:0];
			2 : blockreg[15:0] <=  offdata[15:0];
				default: blockreg[15:0] <=  blockdata[15:0];
			endcase
    	
		case(blocksel1)
			1 : blockreg[31:16] <=  din[15:0];
			2 : blockreg[31:16] <=  offdata[15:0];
				default: blockreg[31:16] <=  blockdata[31:16];
			endcase
		
		case(blocksel2)
			1 : blockreg[47:32] <=  din[15:0];
			2 : blockreg[47:32] <=  offdata[15:0];
				default: blockreg[47:32] <=  blockdata[47:32];
    		endcase
		
		case(blocksel3)
			1 : blockreg[63:48] <=  din[15:0];
			2 : blockreg[63:48] <=  offdata[15:0];
				default: blockreg[63:48] <=  blockdata[63:48];
			endcase
		end
endmodule