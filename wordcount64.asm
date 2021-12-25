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

;-----------------------------------------------------------------------------
; CONSTANTS
;-----------------------------------------------------------------------------

%define BUFFER_SIZE	80 ; max buffer size

;-----------------------------------------------------------------------------
; Section DATA
;-----------------------------------------------------------------------------
SECTION .data


;-----------------------------------------------------------------------------
; Section BSS
;-----------------------------------------------------------------------------
SECTION .bss

		align 128
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
        global start            ; make label available to linker
start:                         ; standard entry point for ld
%else
        DEFAULT ABS
        global _start:function  ; make label available to linker
_start:
%endif
        nop
next_string:
	;----------------------------------------------------------
	; read string from default input
	;-----------------------------------------------------------
	SYSCALL_4 SYS_READ, FD_STDIN, buffer, BUFFER_SIZE
	test rax,rax	; check system call return value
	jz	_exit	; jump too exit if no characters have been
			; read (exa == 0)
	mov byte [buffer+rax],0
	; rsi: pointer to current character in buffer
	lea rsi,[buffer]
	
	;-----------------------------------------------------------
	; count words letters and lines
	;-----------------------------------------------------------
	mov r10,1	; word counter = 1
	mov r11,0	; line counter = 1
	mov r12,0	; char counter = 0

returnpoint:
	mov dl,[rsi]
	cmp dl,32	; check if char is Space
	jz space	; inc space counter
	cmp dl,10	; check for linefeed (newline linux)
	jz lf		; inc line counter
back:
	inc r12		; inc char counter
	inc rsi
	test dl,dl
	jnz returnpoint	; start again
	dec r12		; dec char counter by one false char count
	jmp output
space:
	inc r10		; inc space
	jmp back
lf:
	inc r11		; inc linefeed
	jmp back

	;-----------------------------------------------------------
	; Output
	;-----------------------------------------------------------
output:
	; print word counter
	; print line counter
	; print char counter
	jmp next_string
        ;-----------------------------------------------------------
        ; END OF PROGRAM
        ;-----------------------------------------------------------
_exit:	SYSCALL_2 SYS_EXIT, 0
