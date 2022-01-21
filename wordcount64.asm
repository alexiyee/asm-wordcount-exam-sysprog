;-----------------------------------------------------------------------------
; wordcount64.asm - count number of words, lines, and characters
;-----------------------------------------------------------------------------
;
; DHBW Ravensburg - Campus Friedrichshafen
;
; Vorlesung Systemnahe Programmierung (SNP)
;
; TESTAT TI20
;
;----------------------------------------------------------------------------
;
; Architecture:  x86-64
; Language:      NASM Assembly Language
;
; Course:    ( ) TIT20    ( ) TIM20    (X) TIS20
; Author 1: Dominic Zedler
; Author 2: Daniel Pape
; Author 3: Alexander Leonardo Voigt
;
;----------------------------------------------------------------------------

%include "syscall.inc"  ; OS-specific system call macros

extern uint_to_ascii

;-----------------------------------------------------------------------------
; CONSTANTS
;-----------------------------------------------------------------------------

%define BUFFER_SIZE		65536	; max buffer size
%define CHR_LF			10	; line Feed

;-----------------------------------------------------------------------------
; Section DATA
;-----------------------------------------------------------------------------
SECTION .data

chcnt		dq 0
wdcnt		dq 0
lncnt		dq 1 ; because every text starts in the first line

outstr:
		db "Chars: "
.chars		db "             ", CHR_LF
		db "Words: "
.words 		db "             ", CHR_LF
		db "Lines: "
.lines		db "             ", CHR_LF
outstr_len	equ $-outstr
		db 0

chstr		dq outstr.chars
chstr_len	equ $-chstr
wdstr		dq outstr.words
lnstr		dq outstr.lines

;-----------------------------------------------------------------------------
; Section BSS
;-----------------------------------------------------------------------------
SECTION .bss

buffer		resb BUFFER_SIZE 

;-----------------------------------------------------------------------------
; SECTION TEXT
;-----------------------------------------------------------------------------
SECTION .text

        ;-----------------------------------------------------------
        ; PROGRAM'S START ENTRY
        ;-----------------------------------------------------------
%ifidn __OUTPUT_FORMAT__, macho64
        DEFAULT REL
        global start		; make label available to linker
start:				; standard entry point for ld
%else
        DEFAULT ABS
        global _start:function  ; make label available to linker
_start:
%endif
        nop
	;----------------------------------------------------------
	; read string from default input
	;-----------------------------------------------------------
	SYSCALL_4 SYS_READ, FD_STDIN, buffer, BUFFER_SIZE
	test rax,rax	; check system call return value
	jz _exit	; jump too exit if no characters have been
			; read (rax == 0)
	mov byte [buffer+rax],0
	; rsi: pointer to current character in buffer
	lea rsi,[buffer]


returnpoint:
	mov dl,[rsi]
	cmp dl,33		; check if char is Space
	; war jz
	jb space		; inc space counter
	;cmp dl,10		; check for linefeed (newline linux)
	;jz lf			; inc line counter
back:
	inc qword [chcnt]	; inc char counter
	inc rsi
	test dl,dl
	jnz returnpoint		; start again
	dec qword [chcnt]	; dec char counter by one false char count
	dec qword [wdcnt]	; dec word counter by one false count
	jmp convert
space:
	inc qword [wdcnt]	; inc space
	cmp dl,10		; check for Linefeed
	jz lf			; jump
	jmp back
lf:
	inc qword [lncnt]	; inc linefeed
	jmp back		

	;-----------------------------------------------------------
	; Convert register content to ASCII 
	;-----------------------------------------------------------
convert:
	mov rsi,[chcnt]
	mov rdi,outstr.chars
	call uint_to_ascii	; convert chars into ASCII
	mov rsi,[wdcnt]
	mov rdi,outstr.words
	call uint_to_ascii	; convert words into ASCII
	mov rsi,[lncnt]
	mov rdi,outstr.lines
	call uint_to_ascii	; convert lines into ASCII
	;-----------------------------------------------------------
	; Output
	;-----------------------------------------------------------
output:
	SYSCALL_4 SYS_WRITE, FD_STDOUT, outstr, outstr_len

        ;-----------------------------------------------------------
        ; END OF PROGRAM
        ;-----------------------------------------------------------
_exit:	SYSCALL_2 SYS_EXIT, 0
