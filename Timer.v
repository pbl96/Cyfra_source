
//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   Timer
 Author:        Przemek Drwal
 Version:       1.0
 Last modified: 2017-04-24
 Coding style: safe, with FPGA sync reset
 Description:  Template for simple module with registered outputs
 */
//////////////////////////////////////////////////////////////////////////////
module Timer
	(
		input wire clk,  // posedge active clock
		input wire rst,  // high-level active synchronous reset
        output reg [10:0] vcount, //licznik synchronizacji pionowej VGA
        output reg vsync, //sygna³ synchronizacji poziomej VGA
        output reg vblnk, //sygna³ zaciemniania poziomego VGA
        output reg [10:0] hcount, // icznik synchronizacji poziomej VGA
        output reg hsync, //sygna³ synchronizacji pionowej VGA
        output reg hblnk // sygna³ zaciemniania pionowego VGA

	);

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
localparam VERTICAL_MAX=628;
localparam HORIZONTAL_MAX=1056;
localparam HORIZONTAL_SYNC_START=840;
localparam HORIZONTAL_SYNC_END=968;
localparam VERTICAL_SYNC_START=601;
localparam VERTICAL_SYNC_END=605;
localparam HORIZONTAL_BLANK_START=800;
localparam HORIZONTAL_BLANK_END=1056;
localparam VERTICAL_BLANK_START=600;
localparam VERTICAL_BLANK_END=628;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
	reg [10:0] hcountnxt=0;
    reg [10:0] vcountnxt=0;
    reg hsyncnxt=1'b0;
    reg vsyncnxt=1'b0;
    reg hblnknxt=1'b0;
    reg vblnknxt=1'b0;

//------------------------------------------------------------------------------
// output register with sync reset
//------------------------------------------------------------------------------
	always @(posedge clk) begin
		if(rst) begin 
              hcount <= 0;  
              vcount <= 0;  
              hsync <= 0;
              vsync <= 0;
              hblnk <= 0;
              vblnk <= 0;
          end
		
		else begin
            hcount <= hcountnxt;  
            vcount <= vcountnxt;  
            hsync <= hsyncnxt;
            vsync <= vsyncnxt;
            hblnk <= hblnknxt;
            vblnk <= vblnknxt;
		end
	end
//------------------------------------------------------------------------------
// logic
//------------------------------------------------------------------------------
 always @* begin
   if(hcountnxt<(HORIZONTAL_MAX-1))
       hcountnxt=hcountnxt+1;
    else begin
       hcountnxt=0;
    if(vcountnxt<(VERTICAL_MAX-1))
       vcountnxt=vcountnxt+1;
    else
       vcountnxt=0;
    end
   end
     
     always @* begin begin
     if((hcountnxt>HORIZONTAL_SYNC_START-1)&&(hcountnxt<HORIZONTAL_SYNC_END))
         hsyncnxt=1'b1;
      else
         hsyncnxt=1'b0;
      end   
      begin  
      if((vcountnxt>VERTICAL_SYNC_START-1)&&(vcountnxt<VERTICAL_SYNC_END)) //+
         vsyncnxt=1'b1;
      else
         vsyncnxt=1'b0;        
      end
     end    

 
     always @* begin begin
     if((hcountnxt>HORIZONTAL_BLANK_START-1)&&(hcountnxt<HORIZONTAL_BLANK_END))//+
         hblnknxt=1'b1;
      else
         hblnknxt=1'b0;
      end
      begin  
      if((vcountnxt>VERTICAL_BLANK_START-1)&&(vcountnxt<VERTICAL_BLANK_END)) //+
         vblnknxt=1'b1;
      else
         vblnknxt=1'b0;        
      end
     end    
endmodule
