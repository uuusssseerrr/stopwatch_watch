`timescale 1ns / 1ps

module watch_datapath #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
) (
    input clk,
    input rst,
    input b_hour_up, //button hour up tick from control unit
    input b_hour_down, //button hour down tick
    input b_min_up, //button min up tick
    input b_min_down, //button min down tick
    output [MSEC_WIDTH - 1:0] msec, // 0~99
    output [SEC_WIDTH - 1:0] sec, // 0~59
    output [MIN_WIDTH - 1:0] min, // 0~59
    output [HOUR_WIDTH - 1:0] hour // 0~23
);

    wire w_tick_100hz;
    wire t_msec_up; //time msec up tick from msec to sec
    wire t_sec_up; //time sec up tick from sec to min
    wire w_min_up; //time+btn min up tick from min to hour
    wire w_min_down; //time+btn min down tick from min to hour

    // instance

    //hour
    watch_tick_counter #(
        .TIMES(24),
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_HOUR_TICK_COUNTER_W (
        .clk(clk),
        .rst(rst),
        .i_btn_up_tick(b_hour_up),
        .i_btn_down_tick(b_hour_down),
        .i_time_tick_up(w_min_up),
        .i_time_tick_down(w_min_down),
        .time_counter(hour),
        .o_tick_up(1'b0),
        .o_tick_down(1'b0)
    );

    //min
    watch_tick_counter #(
        .TIMES(60),  //이름으로 parameter 연결
        .BIT_WIDTH(MIN_WIDTH)
    ) U_MIN_TICK_COUNTER_W (
        .clk(clk),
        .rst(rst),
        .i_btn_up_tick(b_min_up),
        .i_btn_down_tick(b_min_down),
        .i_time_tick_up(t_sec_up),
        .i_time_tick_down(1'b0),
        .time_counter(min),
        .o_tick_up(w_min_up),
        .o_tick_down(w_min_down)
    );

    //sec
    watch_tick_counter #(
        .TIMES(60),  //이름으로 parameter 연결
        .BIT_WIDTH(SEC_WIDTH)
    ) U_SEC_TICK_COUNTER_W (
        .clk(clk),
        .rst(rst),
        .i_btn_up_tick(1'b0),
        .i_btn_down_tick(1'b0),
        .i_time_tick_up(t_msec_up),
        .i_time_tick_down(1'b0),
        .time_counter(sec),
        .o_tick_up(t_sec_up),
        .o_tick_down(1'b0)
    );

    //msec
    watch_tick_counter #(
        .TIMES(100),  //이름으로 parameter 연결
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_MSEC_TICK_COUNTER_W (
        .clk(clk),
        .rst(rst),
        .i_btn_up_tick(1'b0),
        .i_btn_down_tick(1'b0),
        .i_time_tick_up(w_tick_100hz),
        .i_time_tick_down(1'b0),
        .time_counter(msec),
        .o_tick_up(t_msec_up),  //input 2가지 or 연산: time tick, btn tick
        .o_tick_down(1'b0)
    );

    watch_tick_gen_100hz U_TICK_GEN_100HZ_W (
        .clk(clk),
        .rst(rst),
        .o_tick_100hz(w_tick_100hz)
    );

endmodule
