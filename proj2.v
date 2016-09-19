
// table for valid bits
module ValidArray(clock, reset, valid, index, state);
  input [3:0] index;
  output valid;
  input clock, reset;
  input [3:0] state;

  wire [15:0] update;
  reg [15:0] validarr;

  // update valid bits
    always @(posedge clock)
    if(reset)
       //TODO RESET STATE
    else
       if(state==4'd8)
        // TODO

 //TODO assign valid=

endmodule



module CacheController(clock, reset, state, count, miss, rd, macc, 
                       rrdy, rdrdy, wacpt);
  input clock,reset;
  output [3:0] state;
  input rd, miss, rrdy, rdrdy, wacpt, macc;
  output [1:0] count;

  reg [3:0] state;
  reg [1:0] count;


  always @(posedge clock)
    if(reset || macc==0)
      begin
      	state<=0;
        count<=0;
      end
    else
      case(state)
// TODO: Main state machine.
      endcase
endmodule


module ProcInterface(clock, rd, addr, dout, complete, state, miss, blockdata);
input clock, rd, miss;
input [15:0] addr;
input [63:0] blockdata;
input [3:0] state;
output complete;
output [15:0] dout;

reg complete;
reg [15:0] dout;

  always @(posedge clock)
    if(rd && complete)
 //TODO: Finish case statements
      endcase

  always @(rd or miss or state)
  //TODO: Logic for complete signal


endmodule


module MemInterface(state, addr, din, offdata, miss, rrqst, rdacpt, wrqst);
input [3:0] state;
input [15:0] addr, din;
input miss;
output rrqst, rdacpt, wrqst;
output [15:0] offdata;

reg rrqst, rdacpt, wrqst;
reg [15:0] offdata;

  always @(state or miss)
    case(state)
//TODO: Fill the case statements
    endcase

  always @(wrqst or rrqst or addr or din or state)
    case({rrqst,wrqst})
//TODO: Fil the case statements
    endcase


endmodule



module CacheData(clock, state, count, valid, miss, rd, addr, din, blockdata, 
                 offdata);
input clock, valid, rd;
input [3:0] state; 
input [1:0] count;
input [15:0] addr, din, offdata;
output miss;
output [63:0] blockdata;

wire ramrd;
wire [73:0] cramin, cramout;

reg [63:0] blockreg;


// TODO: write code to for miss, ramrd, blockdata

  assign cramin = {addr[15:6],blockreg};
  CacheRAM cram(cramin, cramout, addr[5:2], ramrd);

// TODO: assign blockreg based on state



endmodule


       
