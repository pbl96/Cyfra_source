//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   template_fsm
 Author:        Przemek Drwal && Tomek Wieclawek
 Version:       1.1
 Last modified: 2017-04-28
 Coding style: safe with FPGA sync reset
 Description:  Template for modified Moore FSM for UEC2 project
 */
//////////////////////////////////////////////////////////////////////////////
module Strzal

	(

		input wire clk,  // posedge active clock
		input wire rst,  // high-level active synchronous reset
		input wire [10:0] hcount_in,
		input wire [10:0] vcount_in,
		input wire h_sync_in,
		input wire v_sync_in,
		input wire h_blank_in,
		input wire v_blank_in,
		input wire rgb_in,
		output reg [10:0] hcount_out,
        output reg [10:0] vcount_out,		
		output reg h_blank_out,
		output reg v_blank_out,
		output reg h_sync_out,
		output reg v_sync_out,
		output reg [11:0] rgb_out,
		output reg [11:0] x_pos_out,
		output reg [11:0] y_pos_out,
		
		input wire shoot_enable,
		input wire [11:0] x_pos_in,
		input wire [11:0] y_pos_in,
		input wire left_click
		
	);

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
	localparam STATE_BITS = 2; // number of bits used for state register
	localparam
	ODDAJ_STRZAL = 2'b00, // idle state
	STRZAL = 2'b01,
	USUN_POCISK = 2'b11;

	localparam POCISK_START_X = 400;
	localparam POCISK_START_Y = 0;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
	reg [ STATE_BITS-1 : 0 ] state = ODDAJ_STRZAL;
	reg [ STATE_BITS-1 : 0 ] state_nxt;
	
	reg  [11:0] pozycja_x_myszy;
	reg  [11:0] pozycja_y_myszy;
	reg  [11:0] pozycja_x;
    reg  [11:0] pozycja_y;	
    reg  [11:0] pozycja_x_nxt;
    reg  [11:0] pozycja_y_nxt;    
    
    reg [10:0] hcount_nxt;
    reg [10:0] vcount_nxt;        
    reg h_blank_nxt;
    reg v_blank_nxt;
    reg h_sync_nxt;
    reg v_sync_nxt;
    reg [11:0] rgb_nxt;
    reg [11:0] x_pos_nxt;
    reg [11:0] y_pos_nxt;
	
//------------------------------------------------------------------------------
// state sequential with synchronous reset
//------------------------------------------------------------------------------
	always @(posedge clk) begin : state_seq
		if(rst)begin : state_seq_rst
			state <= ODDAJ_STRZAL;
		end
		else begin : state_seq_run
			state <= state_nxt;
		end
	end
//------------------------------------------------------------------------------
// next state logic
//------------------------------------------------------------------------------
	always @* begin : state_comb
		case(state)
            ODDAJ_STRZAL: begin
            state_nxt = left_click ? STRZAL : ODDAJ_STRZAL; 
            end
            STRZAL:
            state_nxt = ((pozycja_x<=0) || (pozycja_x >=799) || (pozycja_y >=599) || shoot_enable) ? USUN_POCISK : STRZAL;
            
            USUN_POCISK:
            state_nxt = ODDAJ_STRZAL;
            
		endcase
	end
//------------------------------------------------------------------------------
// output register
//------------------------------------------------------------------------------
    always @(posedge clk) begin : out_nxt
        hcount_nxt <= hcount_in;
        vcount_nxt <= vcount_in;    
        h_blank_nxt <= h_blank_in;
        v_blank_nxt <= v_blank_in;
        h_sync_nxt <= h_sync_in;
        v_sync_nxt <= v_sync_in;
        x_pos_nxt <= x_pos_in;
        y_pos_nxt <= y_pos_in;
    end
    
	always @(posedge clk) begin : out_reg
		if(rst) begin : out_reg_rst
            hcount_out <= 0;
            vcount_out <= 0;    
            h_blank_out <= 0;
            v_blank_out <= 0;
            h_sync_out <= 0;
            v_sync_out <= 0;
            rgb_out <= 0;
            x_pos_out <= 0;
            y_pos_out <= 0;
            pozycja_x_nxt <= 0;
            pozycja_y_nxt <= 0;
		end
		else begin : out_reg_run
            hcount_out <= hcount_nxt;
            vcount_out <= vcount_nxt;    
            h_blank_out <= h_blank_nxt;
            v_blank_out <= v_blank_nxt;
            h_sync_out <= h_sync_nxt;
            v_sync_out <= v_sync_nxt;
            rgb_out <= rgb_nxt;
            x_pos_out <= x_pos_nxt;
            y_pos_out <= y_pos_nxt;
		end
	end
	
//------------------------------------------------------------------------------
// output logic
//------------------------------------------------------------------------------
	always @* begin : out_comb
		case(state_nxt)
			ODDAJ_STRZAL: begin
            pozycja_x_myszy = x_pos_in;
            pozycja_y_myszy = y_pos_in;
			end
			
			STRZAL: begin
			pozycja_x_nxt = pozycja_x +1'b1;
			pozycja_y_nxt = ( (y_pos_in/(y_pos_in-POCISK_START_X)) * pozycja_x ) - ( 400 * (y_pos_in/(y_pos_in-POCISK_START_X)) );
			if((hcount_in >= pozycja_x) &&  (hcount_in <= pozycja_x + 3) && (vcount_in >= pozycja_y) &&  (vcount_in <= pozycja_y +3))
			     rgb_nxt = 12'hf_0_0_;
			else
			     rgb_nxt = rgb_in;			     
			end
			
			USUN_POCISK: begin
			if((hcount_in >= pozycja_x) &&  (hcount_in <= pozycja_x + 3) && (vcount_in >= pozycja_y) &&  (vcount_in <= pozycja_y +3)) begin
                 rgb_nxt = rgb_in;
                 pozycja_x_nxt = 0;
                 pozycja_y_nxt = 0;
                 pozycja_x_myszy = 0;
                 pozycja_y_myszy = 0;
                 end
            else
                 rgb_nxt = rgb_in;                 
            		
			end
			
		endcase
	end

endmodule
