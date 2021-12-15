global _main

extern _printf

section .text

MACHO_EXIT  equ 0x2000001
MACHO_READ  equ 0x2000003
MACHO_WRITE equ 0x2000004

STDIN   equ 0
STDOUT  equ 1

DAYS    equ 256

num_format:         db  "%llu", 10, 0

read_error_msg:     db  "read() error", 10
.len:               equ $ - read_error_msg

invalid_timer_msg:  db  "invalid timer value", 10
.len:               equ $ - invalid_timer_msg

sep_expected_msg:   db  "',' or newline expected as timer value separator", 10
.len:               equ $ - sep_expected_msg

_main:
    ; align esp to 16 bytes. necessary on Mac to call other routines (such as printf)
    push    rbp
    mov     rbp, rsp

    mov     rax, MACHO_READ
    mov     rdi, STDIN
    mov     rsi, input
    mov     rdx, INPUT_BUF_SIZE
    syscall
    cmp     rax, -1
    je      _read_error

    xor     rbx, rbx
    xor     rcx, rcx
    mov     rdx, input
    mov     rsi, fish_counts        ; rsi <= fish_counts
_read_timer_values:
    cmp     rcx, rax
    je      _start_grow
    mov     bl, byte [rdx + rcx]    ; input[i], timer value
    inc     rcx
    sub     rbx, '0'
    cmp     rbx, 8  ; too large?
    jg      _invalid_timer_value
    inc     qword [rsi + rbx*8]     ; fish_counts[timer_value]++

    cmp     rcx, rax                ; all read?
    je      _start_grow
    mov     bl, byte [rdx + rcx]    ; must be ',' or \n
    inc     rcx
    cmp     rbx, ','
    je      _read_timer_values
    cmp     rbx, 10
    je      _read_timer_values
    jmp     _separator_expected

_start_grow:
    mov     rcx, DAYS

_next_day:
    mov     rax, qword [rsi + 0]    ; save fishes about to give births as it's being overwritten soon

    mov     rbx, qword [rsi + 1*8]  ; fishes of timer value 1...
    mov     qword [rsi + 0], rbx    ; go to 0
    mov     rbx, qword [rsi + 2*8]  ; fishes of timer value 2...
    mov     qword [rsi + 1*8], rbx  ; go to 1
    mov     rbx, qword [rsi + 3*8]  ; and a bit more manual loop unrolling ;)
    mov     qword [rsi + 2*8], rbx
    mov     rbx, qword [rsi + 4*8]
    mov     qword [rsi + 3*8], rbx
    mov     rbx, qword [rsi + 5*8]
    mov     qword [rsi + 4*8], rbx
    mov     rbx, qword [rsi + 6*8]
    mov     qword [rsi + 5*8], rbx

    mov     rbx, qword [rsi + 7*8]
    add     rbx, rax                ; fishes of timer value 7 and 0 both go to 6
    mov     qword [rsi + 6*8], rbx

    mov     rbx, qword [rsi + 8*8]
    mov     qword [rsi + 7*8], rbx

    mov     qword [rsi + 8*8], rax  ; and finally the new births
    loop    _next_day               ; next day

    ; the number fishes of timer value 8 is in rax already
    add     rax, qword [rsi]        ; some more manual unrolling ;)
    add     rax, qword [rsi + 1*8]
    add     rax, qword [rsi + 2*8]
    add     rax, qword [rsi + 3*8]
    add     rax, qword [rsi + 4*8]
    add     rax, qword [rsi + 5*8]
    add     rax, qword [rsi + 6*8]
    add     rax, qword [rsi + 7*8]

_done:
    mov     rdi, num_format
    mov     rsi, rax
    mov     rax, 0  ; no vector arg, see https://stackoverflow.com/questions/6212665/why-is-eax-zeroed-before-a-call-to-printf
    call    _printf

    mov     rax, MACHO_EXIT
    mov     rdi, 0
    syscall


_read_error:
    mov     rsi, read_error_msg
    mov     rdx, read_error_msg.len
    jmp _abort

_invalid_timer_value:
    mov     rsi, invalid_timer_msg
    mov     rdx, invalid_timer_msg.len
    jmp _abort

_separator_expected:
    mov     rsi, sep_expected_msg
    mov     rdx, sep_expected_msg.len
    jmp _abort

_abort:
    mov     rax, MACHO_WRITE
    mov     rdi, STDOUT
    syscall

    mov     rax, MACHO_EXIT
    mov     rdi, 1
    syscall

section .bss

INPUT_BUF_SIZE  equ     1024
input           resb    INPUT_BUF_SIZE

fish_counts     resq    9   ; int64, counts of fishes of timer value 0 - 8
