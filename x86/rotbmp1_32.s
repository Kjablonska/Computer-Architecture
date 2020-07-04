section .data
cox_s 		dw 0			; x coordinate of source byte.
coy_s 		dw 0			; y coordinate of source byte.

cox_d 		dw 0			; x coordinate of destination byte.
coy_d 		dw 0			; y coordinate of destination byte.

dest		dw 0
source		dw 0

bajt		dw 0

section	.text
global  rotbmp1

rotbmp1:
; Prologue
	push	ebp
	mov		ebp, 	esp

; Pushing registers to the stack.
	push	ebx
	push	edi
	push	esi
	;push	ecx
;
    %define     img         	[ebp + 8]
	%define     width	        [ebp + 12]

	mov		esi,	[ebp + 8]

	mov		edx,	width
	and		edx,	31		; % 32

; Pushing result on stack.
skip:
	add		edx,	width
	sar		edx,	3		  	; Dividing result by 8 to get number of bytes.
	push	edx					; byte width at [ebp - 16].

	mov ebx, 0
	mov edi, 0

	mov		ecx,	[ebp - 16]
	mov		esi,	[ebp + 8]

rowLoop:
    cmp		ebx,	width		; Comparing against image height (= width).
	jz		endRowLoop

; columnLoop (j) takes each bit in byte in the row.
columnLoop:
    cmp		edi,	width
	jz		endColumnLoop

	mov		ecx, 8
	mov		ah, 0				; ah = bit_number
	mov		al, 7				; al = shift
	mov		cl, 0

	; createByte should return byte to be swapped.
	call 	createByte			; segmentation fault

	; coy_s = width - 1;
	mov 	dl, 	width
	sub		dl,		1
	mov		[coy_s],	dl

	; Calculate destination index.
	mov 	ebx, [coy_d]
	mov 	eax, width
	;sub 	ebx, 1
	imul 	eax, ebx			; coy_d * width
;
	mov		ebx, [cox_d]
	;sub 	ebx, 1
	add 	eax, ebx			; dest = cox_d + coy_d * width;
	mov		[dest], dh

	; Replace byte in data[dest] with byte reutrned by createByte - TO DO.
	; mov	[dest], byte

	; byte = 0.
	; xor byte, byte

	; Increase cox_d.
	mov		dh,	[cox_d]
	inc		dh
	mov		[cox_d],	dh
;
	; if bit_number > 7, then bit_number = 0.
	cmp		ah,	8
	mov		ah,	0

    inc		edi                 ; Increase column (j) counter.
	jmp		columnLoop

endColumnLoop:
	inc		ebx                 ; Increase column (i) counter.

	; Increase coy_d.
	mov		dl, [cox_d]
	inc		dl
	mov		[coy_d], dl

	mov		dl, 0
	mov		[cox_d], dl			; cox_d = 0

	; Increase cox_s.
	mov		dl, [cox_s]
	inc		dl
	mov		[cox_s], dl

	; coy_s = width - 1.
	mov		eax, 	width
	sub		eax, 	1
	mov		[coy_s], 	eax

	mov		ah,	0				; bit_number = 0.
	jmp		rowLoop

endRowLoop:
    add		esp,	4
	pop		esi
	pop		edi
	pop 	ebx

; Epilogue
	pop		ebp
	ret


createByte:

	; ecx = 8. Loop from 1 to 8.
	; initial value:		ah, 0			; ah = bit_number
	; initial value:		al, 7			; al = shift


	; source index = cox_s + coy_s * width
	mov 	ebx, [coy_s]
	mov 	eax, width
	;sub 	ebx, 1
	imul 	eax, ebx			; coy_s * width

	mov		ebx, [cox_s]
	;sub 	ebx, 1
	add 	eax, ebx			; source = cox_s + coy_s * width;
	mov		[source], dh

	; bit = data[source] AND  (1 SHL bit_number)
	mov		cl, ah				; ah = bit_number
	mov		dl, 1	; dl
	shl		dl, cl				; 1 SHL bit_number
	inc		cl
	mov		ah, cl

	mov		eax, [source]
	add		eax, esi			; eax = data[eax] (???)
	mov		dh, [eax]
	and		dh, dl				; dh = bit

	;; bit SHL shift
	mov		cl, al
	shl		dh, cl
	dec		cl
	mov 	al, cl

	; byte += bit
	; add 	byte, dh

	; coy_s--
	mov 	dl,	[coy_s]
	dec		dl
	mov		[coy_s], dl

	loop createByte