global _main

extern _printf

section .text

MACHO_EXIT  equ 0x2000001
MACHO_READ  equ 0x2000003
MACHO_WRITE equ 0x2000004

STDIN   equ 0
STDOUT  equ 1

DAYS    equ 80

num_format:         db  "%d", 10, 0

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
    inc     dword [rsi + rbx*4]     ; fish_counts[timer_value]++

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
    mov     eax, dword [rsi + 0]    ; save fishes about to give births as it's being overwritten soon

    mov     ebx, dword [rsi + 1*4]  ; fishes of timer value 1...
    mov     dword [rsi + 0], ebx    ; go to 0
    mov     ebx, dword [rsi + 2*4]  ; fishes of timer value 2...
    mov     dword [rsi + 1*4], ebx  ; go to 1
    mov     ebx, dword [rsi + 3*4]  ; and a bit more manual loop unrolling ;)
    mov     dword [rsi + 2*4], ebx
    mov     ebx, dword [rsi + 4*4]
    mov     dword [rsi + 3*4], ebx
    mov     ebx, dword [rsi + 5*4]
    mov     dword [rsi + 4*4], ebx
    mov     ebx, dword [rsi + 6*4]
    mov     dword [rsi + 5*4], ebx

    mov     ebx, dword [rsi + 7*4]
    add     ebx, eax                ; fishes of timer value 7 and 0 both go to 6
    mov     dword [rsi + 6*4], ebx

    mov     ebx, dword [rsi + 8*4]
    mov     dword [rsi + 7*4], ebx

    mov     dword [rsi + 8*4], eax  ; and finally the new births
    loop    _next_day               ; next day

    ; the number fishes of timer value 8 is in eax already
    add     eax, dword [rsi]        ; some more manual unrolling ;)
    add     eax, dword [rsi + 1*4]
    add     eax, dword [rsi + 2*4]
    add     eax, dword [rsi + 3*4]
    add     eax, dword [rsi + 4*4]
    add     eax, dword [rsi + 5*4]
    add     eax, dword [rsi + 6*4]
    add     eax, dword [rsi + 7*4]

_done:
    mov     rdi, num_format
    mov     esi, eax
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

fish_counts     resd    9   ; int32, counts of fishes of timer value 0 - 8
