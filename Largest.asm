section .data
    mesg1: db 'NUMBER OF ELEMENTS: '
    mesg1l: equ $-mesg1
    mesg2: db 'INPUT ARRAY: '
    mesg2l: equ $-mesg2
    mesglarge: db 0Ah, 'LARGEST: '
    mesglargel: equ $-mesglarge
    mesgsmall: db 'SMALLEST: '
    mesgsmalll: equ $-mesgsmall

section .bss
    array: resb 100
    n: resd 1
    l: resw 1
    s: resw 1
    ;REQUIRED BY PRINT, READ
        counter: resb 1
        num: resw 1
        buf: resb 1

section .text
global _start
;FUNCTIONS
read:
    pusha
    mov word[num], 0
    readloop_001:
        mov eax, 3
        mov ebx, 0
        mov ecx, buf
        mov edx, 1
        int 80h
        cmp byte[buf], 10
        je readfinish_001
        mov ax, word[num]
        mov bx,10
        mul bx
        mov bl, byte[buf]
        sub bl, 30h
        mov bh, 0
        add ax, bx
        mov word[num], ax
        jmp readloop_001
    readfinish_001:
        popa
        ret

print:
    mov byte[counter], 0    ;to keep count of no of digits
    pusha   ;make new stack

    ext_digit:  ;To extract digit by digit from right end of the number
        cmp word[num], 0
        je printno
        add byte[counter], 1
        mov ax, word[num]
        mov dx, 0   ;Remainder in dx
        mov bx, 10
        div bx
        ;Now remainder in dx, push into stack
        push dx
        mov word[num], ax
        jmp ext_digit

    printno:
        cmp byte[counter], 0
        je print_end
        sub byte[counter], 1
        pop dx
        mov byte[buf], dl
        add byte[buf], 30h
        ;Now print digit by digit
        mov eax,4
        mov ebx,1
        mov ecx, buf
        mov edx, 1
        int 80h

        jmp printno

    print_end:
        popa
        ret

;***************************************************************************
_start:
;CODE TO READ ARRAY SIZE
    mov eax, 4
    mov ebx, 1
    mov ecx, mesg1
    mov edx, mesg1l
    int 80h

    ;Read n
    call read
    mov eax, 0
    mov ax, [num]
    mov dword[n], eax

    ;Read n over

;CODE TO DISPLAY INPUT ARRAY MESSAGE
    mov eax, 4
    mov ebx, 1
    mov ecx, mesg2
    mov edx, mesg2l
    int 80h

;CODE TO READ n NUMBERS
    mov eax, array
    mov ebx, 0  ;ACT AS COUNTER
    readloop:
        cmp ebx, dword[n]
        je readloopfinish
        ;GET A NUMBER
        call read   ;read saves register to stack and pops it on end
        ;SAVE THE NUMBER IN ARRAY
        mov cx, word[num]
        mov word[eax+2*ebx], cx
        inc ebx
        jmp readloop
    readloopfinish:


;CODE TO PERFORM SEARCH
    mov ebx, 1  ;ACT AS COUNTER
    mov eax, array
    mov edx, [array]
    mov word[l], dx
    mov word[s], dx
    searchloop:
        cmp ebx, dword[n]
        je endsearchloop
        mov ecx, 0
        mov cx, word[eax+2*ebx]
        cmp cx, word[l]
        jna notlarger
        mov word[l], cx
        notlarger:
        cmp cx, word[s]
        jnb notsmaller
        mov word[s], cx
        notsmaller:
        inc ebx
        jmp searchloop
        endsearchloop:
mov eax, 4
mov ebx, 1
mov ecx, mesgsmall
mov edx, mesgsmalll
int 80h

mov ax, word[s]
mov word[num], ax
call print

mov eax, 4
mov ebx, 1
mov ecx, mesglarge
mov edx, mesglargel
int 80h

mov ax, word[l]
mov word[num], ax
call print


exit:
