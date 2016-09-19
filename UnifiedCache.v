
`include "proj2.v"



module UnifiedCache(clock, addr, din, rd, dout, complete,
	rrqst, rrdy, rdrdy, rdacpt, offdata, wrqst, wacpt, reset, macc);
  input clock, reset;

  // Processor interface
  input rd, macc;
  input [15:0] addr, din;
  output [15:0] dout;
  output complete;

  // Off-chip Memory Interface
  input rrdy, rdrdy, wacpt;
  output rrqst, rdacpt, wrqst;
  inout [15:0] offdata;

  // Internal Signals
  wire [3:0] state;
  wire [1:0] count;
  wire valid, miss;
  wire [63:0] blockdata;   


  CacheController ctrl(clock, reset, state, count, miss, rd, macc, 
                       rrdy, rdrdy, wacpt);
  ProcInterface procif(clock, rd, addr, dout, complete, state, miss, 
                       blockdata);
  MemInterface memif(state, addr, din, offdata, miss, rrqst, rdacpt, wrqst);
  ValidArray valarr(clock, reset, valid, addr[5:2], state);
  CacheData cdata(clock, state, count, valid, miss, rd, addr, din, 
                  blockdata, offdata);

endmodule


// CacheRAM is the non-synthesizable SRAM for
// the Cache.  It is used to store tags and
// data.  The size is 16x74
// tag is 10-bit
// data includes 4 words i.e., 64 bits
// 
module CacheRAM(din, dout, addr, rd);
  input [3:0] addr;
  input [73:0] din;
  output [73:0] dout;
  reg [73:0] dout;
  input rd;

  reg [73:0] memarray[15:0];

  always @(din or addr or rd)
    begin
    if(rd==0)
      memarray[addr]=din;
    dout=memarray[addr];
    end
    
endmodule
