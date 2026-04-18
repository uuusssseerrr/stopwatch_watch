`timescale 1ns / 1ps

module watch_control_unit(
    input clk,
    input rst,
    input sw1,
    input i_btnR,
    input i_btnL,
    input i_btnD,
    input i_btnU,
    output led1,
    output reg o_btn_hour_up,
    output reg o_btn_hour_down,
    output reg o_btn_min_up,
    output reg o_btn_min_down
    );

    // state
    parameter [1:0] WATCH    = 0,
                    HOUR_SET = 1,
                    MIN_SET  = 2,
                    SEC_SET  = 3;

    reg [1:0] c_state, n_state;

    assign led1 = sw1;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= WATCH;
        end else begin
            c_state <= n_state;
        end
    end

    // output logic : 1-clock tick pulse
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            o_btn_hour_up   <= 1'b0;
            o_btn_hour_down <= 1'b0;
            o_btn_min_up    <= 1'b0;
            o_btn_min_down  <= 1'b0;
        end else begin
            // default : all outputs off
            o_btn_hour_up   <= 1'b0;
            o_btn_hour_down <= 1'b0;
            o_btn_min_up    <= 1'b0;
            o_btn_min_down  <= 1'b0;

            case (c_state)
                HOUR_SET: begin
                    if (i_btnU)
                        o_btn_hour_up <= 1'b1; //중복으로 인식되지 않는지... 엣지 디텍터가 필요한지. 는 나중에
                    else if (i_btnD)
                        o_btn_hour_down <= 1'b1;
                end

                MIN_SET: begin
                    if (i_btnU)
                        o_btn_min_up <= 1'b1;
                    else if (i_btnD)
                        o_btn_min_down <= 1'b1;
                end

                default: begin
                    // WATCH state : BtnU / BtnD ignored
                end
            endcase
        end
    end

    // next state logic
    always @(*) begin
        n_state = c_state;

        case (c_state)
            WATCH: begin
                if (i_btnR)
                    n_state = HOUR_SET;
                else if (i_btnL)
                    n_state = SEC_SET;
                else
                    n_state = WATCH;
            end

            HOUR_SET: begin
                if (i_btnR)
                    n_state = MIN_SET;
                else if (i_btnL)
                    n_state = WATCH;
                else
                    n_state = HOUR_SET;
            end

            MIN_SET: begin
                if (i_btnR)
                    n_state = SEC_SET;
                else if (i_btnL)
                    n_state = HOUR_SET;
                else
                    n_state = MIN_SET;
            end

            SEC_SET: begin
                if (i_btnR)
                    n_state = WATCH;
                else if (i_btnL)
                    n_state = MIN_SET;
                else
                    n_state = SEC_SET;
            end

            default: begin
                n_state = WATCH;
            end
        endcase
    end

endmodule
