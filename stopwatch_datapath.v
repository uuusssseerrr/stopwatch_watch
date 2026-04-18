`timescale 1ns / 1ps

module stopwatch_datapath #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
) (
    input clk,
    input rst,
    input i_runstop,
    input i_clear,
    input i_mode,
    output [MSEC_WIDTH - 1:0] msec,
    output [SEC_WIDTH - 1:0] sec,
    output [MIN_WIDTH - 1:0] min,
    output [HOUR_WIDTH - 1:0] hour
);

    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick;

    // instance

    //hour
    stopwatch_tick_counter #(
        .TIMES(24),  //이름으로 parameter 연결
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_HOUR_TICK_COUNTER_SW (
        .clk(clk),
        .rst(rst),
        .i_tick(w_hour_tick),  // from sec o_tick
        .i_clear(i_clear),
        .i_mode(i_mode),
        .time_counter(hour),
        .o_tick()
    );

    //min
    stopwatch_tick_counter #(
        .TIMES(60),  //이름으로 parameter 연결
        .BIT_WIDTH(MIN_WIDTH)
    ) U_MIN_TICK_COUNTER_SW (
        .clk(clk),
        .rst(rst),
        .i_tick(w_min_tick),  // from sec o_tick
        .i_clear(i_clear),
        .i_mode(i_mode),
        .time_counter(min),
        .o_tick(w_hour_tick)  // to hour tick counter
    );

    //sec
    stopwatch_tick_counter #(
        .TIMES(60),  //이름으로 parameter 연결
        .BIT_WIDTH(SEC_WIDTH)
    ) U_SEC_TICK_COUNTER_SW (
        .clk(clk),
        .rst(rst),
        .i_tick(w_sec_tick),  // from msec o_tick
        .i_clear(i_clear),
        .i_mode(i_mode),
        .time_counter(sec),
        .o_tick(w_min_tick)
    );

    //msec
    stopwatch_tick_counter #(
        .TIMES(100),  //이름으로 parameter 연결
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_MSEC_TICK_COUNTER_SW (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_100hz),
        .i_clear(i_clear),
        .i_mode(i_mode),
        .time_counter(msec),
        .o_tick(w_sec_tick)
    );

    stopwatch_tick_gen_100hz U_TICK_GEN_100HZ_SW (
        .clk(clk),
        .rst(rst),
        .i_runstop(i_runstop),
        .i_clear(1'b0),
        .o_tick(w_tick_100hz)
    );

endmodule


