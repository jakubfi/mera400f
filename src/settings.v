// SM-PK / a-1 : 2
// SM-PK / a-2 : 4
// SM-PK / a-3 : 8
// SM-PK / a-4 : 10
// SM-PK / a-5 : 20
TIMER_FREQ_MS 10

// P-X / E-F: no AWP
// P-R / C-D: no AWP
AWP_PRESENT 1

// P-X / K-L, M-N : more than one interface unit
// P-X / K-N, N-M : one interface unit
SINGLE_INTERFACE 1

// P-X / A-C : 0-256 write deny
// P-X / B-A, A-C : no write deny
LOW_MEM_WRITE_DENY 0

// P-D / a: 1-3 : IN/OU illegal for user
// P-D / a: 2-3 : IN/OU legal for user
INOU_USER_ILLEGAL 0

// P-R / 7-8 : CPU 0
// P-R / 8-9 : CPU 1
CPU_NUMBER 0

// P-X / S-R : stop on segfault in mem block 0
STOP_ON_NOMEM 1
