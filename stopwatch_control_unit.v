`timescale 1ns / 1ps

module stopwatch_control_unit(
    input clk,
    input rst,
    input sw1,          // 모드 스위치 (1: 스톱워치 활성화)
    input i_mode,       // 카운트 모드 전환 버튼 (Up/Down 카운트 등)
    input i_clear,      // 초기화 버튼
    input i_run_stop,   // 시작/정지 버튼
    output led1,        // 스톱워치 활성화 표시 LED
    output reg o_run_stop, // Datapath로 보내는 동작 신호
    output reg o_clear,    // Datapath로 보내는 초기화 신호
    output o_mode          // 현재 카운트 모드 상태 (Up/Down)
);

    // --- [1. 상태 정의 (State Encoding)] ---
    // 2비트를 사용하여 4가지 상태를 정의합니다.
    parameter [1:0] STOP  = 2'b00, 
                    RUN   = 2'b01, 
                    CLEAR = 2'b10, 
                    MODE  = 2'b11;

    reg [1:0] c_state, n_state; // 현재 상태, 다음 상태 레지스터
    reg mode_reg, mode_next;    // 카운트 모드(Up/Down) 저장용 레지스터

    // --- [2. 출력 할당] ---
    assign o_mode = mode_reg;  // 현재 카운트 모드를 외부로 출력
    assign led1 = sw1;         // 스위치가 1(스톱워치 모드)이면 LED 점등

    // --- [3. State Register (동기 로직)] ---
    // 클럭의 상승 에지에서 상태를 갱신합니다.
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= STOP;
            mode_reg <= 1'b0;  // 초기값: Up-count
        end else begin
            c_state <= n_state;
            mode_reg <= mode_next;
        end
    end

    // --- [4. Next State & Output Logic (조합 로직)] ---
    // 현재 상태와 입력을 바탕으로 다음 상태와 제어 출력을 결정합니다.
    always @(*) begin
        // 기본값 설정 (Latch 방지 및 코드 간결화)
        n_state = c_state;
        mode_next = mode_reg;
        o_clear = 1'b0;
        o_run_stop = 1'b0;

        case (c_state)
            STOP : begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
                // 버튼 입력에 따른 상태 전이 우선순위
                if (i_run_stop)      n_state = RUN;
                else if (i_clear)    n_state = CLEAR;
                else if (i_mode)     n_state = MODE;
                else                 n_state = STOP;
            end

            RUN: begin
                o_run_stop = 1'b1; // 카운트 진행 신호 활성화
                if (i_run_stop) begin
                    n_state = STOP; // 다시 누르면 정지 상태로 이동
                end
            end

            CLEAR : begin
                o_clear = 1'b1;    // 데이터 초기화 신호 발생
                n_state = STOP;    // 초기화 후 정지 상태로 복귀
            end

            MODE : begin
                mode_next = ~mode_reg; // 카운트 모드 반전 (Up <-> Down)
                n_state = STOP;        // 설정 후 정지 상태로 복귀
            end

            default : n_state = STOP;
        endcase
    end

endmodule
