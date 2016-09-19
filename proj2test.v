
`include "UnifiedCache.v"
`include "cpu.v"

module test;

 reg clock; 
 reg reset;

 // Processor Interface
 wire [15:0] addr, din, dout;
 wire rd, macc, complete;

 // Off-chip Memory Interface
 wire rrqst, rrdy, rdrdy, rdacpt, wrqst, wacpt;
 wire [15:0] data;

 always 
   #5 clock=~clock;

 initial
   begin
    $readmemh("proj2.dat",mem.ram);
    //$shm_open("waves.db");  // save waveforms in this file
    //$shm_probe("AS");       // saves all waveforms
    clock=0;
    reset=1;
    #23 reset=0;
    #5000
    $display("MEM[3009]=%d (35 expected)",mem.ram[16'h3009]);
    $display("MEM[300a]=%d (36 expected)",mem.ram[16'h300a]);
    $display("MEM[300b]=%h (300c expected)",mem.ram[16'h300b]);
    $display("MEM[300c]=%h (0024 expected)",mem.ram[16'h300c]);
    $finish;
  end

  CPU proc(clock, reset, addr, din, dout, rd, macc, complete);
  UnifiedCache cache(clock, addr, din, rd, dout, complete,
	rrqst, rrdy, rdrdy, rdacpt, data, wrqst, wacpt, reset, macc);
  Memory mem(reset, rrqst, rrdy, rdrdy, rdacpt, data, wrqst, wacpt);
endmodule



// The Memory module is the offchip memory.
// The handshake2 delay represents 2 handshake times.
// The mem_latency delay represents the memory latency.
// You can assume handshake2 > 2*(clock period) and mem_latency > 3*handshake2.
// This memory do not use the system clock.

`define handshake2 30
`define mem_latency 100

module Memory(reset, rrqst, rrdy, rdrdy, rdacpt, data, wrqst, wacpt);
  input rrqst, rdacpt, wrqst;
  output rrdy, rdrdy, wacpt;
  inout [15:0] data;
  input reset;
  reg rrdy, rdrdy, wacpt;

  reg [15:0] ram[65535:0];
  reg [3:0] state;
  reg flag;
  reg [15:0] readaddr, storedata;
  reg [1:0] count;
  integer debug;

  // controller
  always @(reset or rrqst or rdacpt or wrqst or state)
    if(reset)
      begin 
	count<=0;
	state<=0;
      end
    else
      case(state)
        0: case({rrqst,wrqst})
	    3: // write miss
	      begin
 #`handshake2   readaddr<=data;
 		flag<=1;
 		state<=4;
	      end
	    2: // read miss
	      begin	
 #`handshake2	readaddr<=data;
 		flag<=0;
 		state<=1;
	      end
	   1: // write hit
	      begin
 #`handshake2	readaddr=data;
 		flag=0;
 		state<=4;
	      end
	   0: begin
		readaddr<=readaddr;
		flag=0;
		state<=0;
              end
           endcase
	1: if(rrqst==0)
 #`handshake2   state<=2;
	   else
	    	state<=1;
	2: 
 #(`mem_latency-`handshake2) state<=3;
	3: if(rdacpt)
	    begin
	     if(count!=3)
     	       begin
 #`handshake2	state<=7;
               end
	     else
               begin
 #`handshake2	state<=0;
		debug=5;
               end
             count<=count+1;
	    end
	   else
            begin
	      state<=3;
            end
	4: if(wrqst==0)
 #`handshake2    state<=5;
	  else state<=4;
	5: if(wrqst)
 	    begin
 #`handshake2	storedata<=data;
    		state<=6;
	    end
	   else
	     	state<=5;
	6: if(wrqst==0)
 	     if(flag)      
 #(`mem_latency-`handshake2-`handshake2-`handshake2) 	state<=3;
	     else
 #`handshake2 	state<=0;
           else
		state<=6;
	7: begin
             if(rdacpt==0)
 #`handshake2 	state<=3;
             else
		state<=7;
	   end
      endcase

 // behavior
 always @(state or storedata)
   case(state)
     0: begin
	  rrdy<=0;
	  rdrdy<=0;
	  wacpt<=0;
      	end
     1: begin
	  rrdy<=1;
	  rdrdy<=0;
	  wacpt<=0;
      	end
     3: begin
	  rdrdy<=1;
	  rrdy<=0;
	  wacpt<=0;
	end
     4: begin
	  rrdy<=0;
	  rdrdy<=0;
	  wacpt<=1;
        end
     6: begin
	  rrdy<=0;
	  rdrdy<=0;
	  wacpt<=1;
	  ram[readaddr]<=storedata;
	end
     default: begin
	  rrdy<=0;
	  rdrdy<=0;
	  wacpt<=0;
	end
   endcase

  assign data=(state==3)? ram[{readaddr[15:2],count}] : 16'hz;

endmodule


