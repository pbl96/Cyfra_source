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
module GeneratorZobmbie
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
	localparam STATE_BITS = 4; // number of bits used for state register
	localparam
        POZIOM_1 = 4'b0000, 
        POZIOM_2 = 4'b0001,
        POZIOM_3 = 4'b0010,
        POZIOM_4 = 4'b0011,
        POZIOM_5 = 4'b0100,
        POZIOM_6 = 4'b0101,
        POZIOM_7 = 4'b0110,
        POZIOM_8 = 4'b0111,
        POZIOM_9 = 4'b1000;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
	reg [ STATE_BITS-1 : 0 ] state = POZIOM_1;
	reg [ STATE_BITS-1 : 0 ] state_nxt;
	
	reg [10:0] hcount_nxt;
    reg [10:0] vcount_nxt;        
    reg h_blank_nxt;
    reg v_blank_nxt;
    reg h_sync_nxt;
    reg v_sync_nxt;
    reg [11:0] rgb_nxt;
    
//------------------------------------------------------------------------------
// tasks
//------------------------------------------------------------------------------  
    
//------------------------------------------------------------------------------
// state sequential with synchronous reset
//------------------------------------------------------------------------------
	always @(posedge clk) begin : state_seq
        if(rst)begin : state_seq_rst
            state <= POZIOM_1;
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
			POZIOM_1: state_nxt = (level == 1)  ? POZIOM_1 : POZIOM_2;
			POZIOM_2: state_nxt = (level == 2)  ? POZIOM_2 : POZIOM_3;
			POZIOM_3: state_nxt = (level == 3)  ? POZIOM_3 : POZIOM_4;
			POZIOM_4: state_nxt = (level == 4)  ? POZIOM_4 : POZIOM_5;
            POZIOM_5: state_nxt = (level == 5)  ? POZIOM_5 : POZIOM_6;
            POZIOM_6: state_nxt = (level == 6)  ? POZIOM_6 : POZIOM_7;
            POZIOM_7: state_nxt = (level == 7)  ? POZIOM_7 : POZIOM_8;
            POZIOM_8: state_nxt = (level == 8)  ? POZIOM_8 : POZIOM_9;
            POZIOM_9: state_nxt = (level == 9)  ? POZIOM_9 : POZIOM_1;
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
			POZIOM_1: begin
			end
            POZIOM_2: begin
            end
            POZIOM_3: begin
            end
            POZIOM_4: begin
            end
            POZIOM_5: begin
            end
            POZIOM_6: begin
            end
            POZIOM_7: begin
            end
            POZIOM_8: begin
            end
            POZIOM_9: begin
            end
		endcase
	end

endmodule
