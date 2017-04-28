//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   template_fsm
 Author:        Robert Szczygiel
 Version:       1.0
 Last modified: 2017-04-03
 Coding style: safe with FPGA sync reset
 Description:  Template for modified Moore FSM for UEC2 project
 */
//////////////////////////////////////////////////////////////////////////////
module template_fsm

	(

		input wire clk,  // posedge active clock
		input wire rst,  // high-level active synchronous reset
		input wire [10:0] hcount_in,
		input wire [10:0] vcount_in,
		input wire h_sync_in,
		input wire v_sync_in,
		input wire h_blank_in,
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

	localparam pocisk_start_x = 400;
	localparam pocisk_start_y = 0;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
	reg [ STATE_BITS-1 : 0 ] state = ODDAJ_STRZAL;
	reg [ STATE_BITS-1 : 0 ] state_nxt;
	
	reg  [11:0] pozycja_x_myszy;
	reg  [11:0] pozycja_y_myszy;
	reg  [11:0] pozycja_x;
    reg  [11:0] pozycja_y;	
	
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
//            pozycja_x_myszy = x_pos_in; //bedze_nizej
//            pozycja_y_myszy = y_pos_in;
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
	always @(posedge clk) begin : out_reg
		if(rst) begin : out_reg_rst
			myout = 1'b0;
		end
		else begin : out_reg_run
			myout = myout_nxt;
		end
	end
//------------------------------------------------------------------------------
// output logic
//------------------------------------------------------------------------------
	always @* begin : out_comb
		case(state_nxt)
			ST_3:    myout_nxt = 1'b1;
			default: myout_nxt = 1'b0;
		endcase
	end

endmodule
