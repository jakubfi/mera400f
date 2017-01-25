// SM-PK / a-1 : 2 ms = 500 Hz
// SM-PK / a-2 : 4 ms = 250 Hz
// SM-PK / a-3 : 8 ms = 125 Hz
// SM-PK / a-4 : 10 ms = 100 Hz
// SM-PK / a-5 : 20 ms = 50 Hz
`define TIMER_FREQ_HZ 100

// P-X / E-F: no AWP
// P-R / C-D: no AWP
`define AWP_PRESENT

// P-X / K-L, M-N : more than one interface unit
// P-X / K-N, N-M : one interface unit
`define SINGLE_INTERFACE

// P-X / A-C : 0-256 write deny
// P-X / B-A, A-C : no write deny
`define LOW_MEM_WRITE_DENY

// P-D / a: 1-3 : IN/OU illegal for user
// P-D / a: 2-3 : IN/OU legal for user
`define INOU_USER_ILLEGAL

// P-R / 7-8 : CPU 0
// P-R / 8-9 : CPU 1
`define CPU_NUMBER_1

// P-X / S-R : stop on segfault in mem block 0
`define STOP_ON_NOMEM
