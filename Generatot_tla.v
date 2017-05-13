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
module GeneratorTla
	(

		input wire clk,  // posedge active clock
		input wire rst,  // high-level active synchronous reset
		input wire [10:0] hcount_in,
		input wire [10:0] vcount_in,
		input wire h_sync_in,
		input wire v_sync_in,
		input wire h_blank_in,
		input wire v_blank_in,
		output reg [10:0] hcount_out,
        output reg [10:0] vcount_out,		
		output reg h_blank_out,
		output reg v_blank_out,
		output reg h_sync_out,
		output reg v_sync_out,
		output reg [11:0] rgb_out,
		
		input wire [3:0] level
	);

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
	localparam STATE_BITS = 2; // number of bits used for state register
	localparam
	PLANSZA_1 = 2'b00, // idle state
	PLANSZA_2 = 2'b01,
	PLANSZA_3 = 2'b10;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
	reg [ STATE_BITS-1 : 0 ] state = PLANSZA_1;
	reg [ STATE_BITS-1 : 0 ] state_nxt;
	
	reg [10:0] hcount_nxt;
    reg [10:0] vcount_nxt;        
    reg h_blank_nxt;
    reg v_blank_nxt;
    reg h_sync_nxt;
    reg v_sync_nxt;
    reg [11:0] rgb_nxt;
//------------------------------------------------------------------------------
// state sequential with synchronous reset
//------------------------------------------------------------------------------
	always @(posedge clk) begin : state_seq
        if(rst)begin : state_seq_rst
            state <= PLANSZA_1;
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
			PLANSZA_1: state_nxt = (level >= 1 && level <= 3)  ? PLANSZA_1 : PLANSZA_2;
			PLANSZA_2: state_nxt = (level >= 4 && level <= 6)  ? PLANSZA_2 : PLANSZA_3;
			PLANSZA_3: state_nxt = (level >= 7 && level <= 9)  ? PLANSZA_3 : PLANSZA_1;
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
    
        end
        else begin : out_reg_run
            hcount_out <= hcount_nxt;
            vcount_out <= vcount_nxt;    
            h_blank_out <= h_blank_nxt;
            v_blank_out <= v_blank_nxt;
            h_sync_out <= h_sync_nxt;
            v_sync_out <= v_sync_nxt;
            rgb_out <= rgb_nxt;
    
        end
    end
//------------------------------------------------------------------------------
// output logic
//------------------------------------------------------------------------------
	always @* begin : out_comb
		case(state_nxt)
			PLANSZA_1: rgb_nxt = 12'h_8_8_8;
            PLANSZA_2: rgb_nxt = 12'h_0_0_f;
            PLANSZA_3: rgb_nxt = 12'h_f_0_f;
		endcase
	end

endmodule
