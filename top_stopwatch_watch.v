`timescale 1ns / 1ps

module top_stopwatch_watch (
    input clk,
    input rst,
    input btnR,
    input btnL,
    input btnU,
    input btnD,
    input [1:0] sw,  //sw[1]=1: stopwatch, sw[1]=0: watch
    input [1:0] led,
    output [7:0] fnd_data,
    output [3:0] fnd_com
    //   output [1:0] led
);

    parameter MSEC_WIDTH = 7, SEC_WIDTH = 6, MIN_WIDTH = 6, HOUR_WIDTH = 5;

    wire [MSEC_WIDTH-1:0] sw_msec, w_msec;  // 스톱워치 msec, 워치 msec
    wire [SEC_WIDTH-1:0] sw_sec, w_sec;
    wire [MIN_WIDTH-1:0] sw_min, w_min;
    wire [HOUR_WIDTH-1:0] sw_hour, w_hour;

    wire [MSEC_WIDTH-1:0] final_msec;  // from 2x1 먹스 to fnd_controller
    wire [ SEC_WIDTH-1:0] final_sec;
    wire [ MIN_WIDTH-1:0] final_min;
    wire [HOUR_WIDTH-1:0] final_hour;

    wire w_runstop, w_clear, w_mode;
    wire w_btnR, w_btnL, w_btnD, w_btnU;
    wire b_hour_up, b_hour_down, b_min_up, b_min_down;

    wire btnR_watch = (!sw[1]) ? w_btnR : 1'b0;
    wire btnL_watch = (!sw[1]) ? w_btnL : 1'b0;
    wire btnU_watch = (!sw[1]) ? w_btnU : 1'b0;
    wire btnD_watch = (!sw[1]) ? w_btnD : 1'b0;
    wire btnR_stopwatch = (sw[1]) ? w_btnR : 1'b0;
    wire btnL_stopwatch = (sw[1]) ? w_btnL : 1'b0;
    wire btnD_stopwatch = (sw[1]) ? w_btnD : 1'b0;

    button_debounce U_BTNR (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR),
        .o_btn(w_btnR)
    );

    button_debounce U_BTNL (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnL),
        .o_btn(w_btnL)
    );

    button_debounce U_BTNU (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnU),
        .o_btn(w_btnU)
    );

    button_debounce U_BTND (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnD),
        .o_btn(w_btnD)
    );

    stopwatch_control_unit U_STOPWATCH_CONTROL_UNIT (
        .clk(clk),
        .rst(rst),
        .sw1(sw[1]),
        .i_mode(btnD_stopwatch),
        .i_clear(btnL_stopwatch),
        .i_run_stop(btnR_stopwatch),
        .led1(led[1]),
        .o_run_stop(w_runstop),
        .o_clear(w_clear),
        .o_mode(w_mode)
    );

    stopwatch_datapath U_STOPWATCH_DATAPATH (
        .clk(clk),
        .rst(rst),
        .i_runstop(w_runstop),
        .i_clear(w_clear),
        .i_mode(w_mode),
        .msec(sw_msec),
        .sec(sw_sec),
        .min(sw_min),
        .hour(sw_hour)
    );

    watch_control_unit U_WATCH_CONTROL_UNIT (
        .clk(clk),
        .rst(rst),
        .sw1(sw[1]),
        .i_btnR(btnR_watch),
        .i_btnL(btnL_watch),
        .i_btnD(btnD_watch),
        .i_btnU(btnU_watch),
        .led1(led[1]),
        .o_btn_hour_up(b_hour_up),
        .o_btn_hour_down(b_hour_down),
        .o_btn_min_up(b_min_up),
        .o_btn_min_down(b_min_down)
    );

    watch_datapath U_WATCH_DATAPATH (
        .clk(clk),
        .rst(rst),
        .b_hour_up(b_hour_up),  //button hour up tick from control unit
        .b_hour_down(b_hour_down),  //button hour down tick
        .b_min_up(b_min_up),  //button min up tick
        .b_min_down(b_min_down),  //button min down tick
        .msec(w_msec),  // 0~99
        .sec(w_sec),  // 0~59
        .min(w_min),  // 0~59
        .hour(w_hour)  // 0~23
    );

    assign final_msec = (sw[1]) ? sw_msec : w_msec;  //sw1이면 stopwatch
    assign final_sec  = (sw[1]) ? sw_sec : w_sec;
    assign final_min  = (sw[1]) ? sw_min : w_min;
    assign final_hour = (sw[1]) ? sw_hour : w_hour;

    fnd_controller U_FND_CNTL (
        .clk(clk),
        .rst(rst),
        .sw(sw[0]),  // sw[0]: msec_sec, sw[1] : min_hour
        .msec(final_msec),
        .sec(final_sec),
        .min(final_min),
        .hour(final_hour),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

endmodule


