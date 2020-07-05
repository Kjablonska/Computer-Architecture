section .data
cox_s 		dw 0			; x coordinate of source byte.
coy_s 		dw 0			; y coordinate of source byte.

cox_d 		dw 0			; x coordinate of destination byte.
coy_d 		dw 0			; y coordinate of destination byte.

dest		dw 0
source		dw 0

newByte		dw 0

section	.text
global  rotbmp1

rotbmp1:
; Prologue
	push	ebp
	mov		ebp, 	esp


    %define     img     [ebp + 8]
	%define     width	[ebp + 12]

; [(bit per pixel * width + 31 )/ 32 ] *4

	mov		edx,	width
	add		edx,	31
	shr		edx,	5			; =/32
	shl		edx,	2			; =*4
	push 	edx					; row_size in bytes [ebp + 16]

	; Allocate memory of the size of row_size * width.
	mov			eax,	width
	imul		eax,	edx
	push		eax
	%define		dest_image		[ebp + 20]

	mov		esi, img
	mov		edi, dest_image

	mov		ecx, width
	mov		ah, 0

rowLoop:
    cmp		ecx,	width		; Comparing against image height (= width).
	jz		endRowLoop

	push 	ecx
	mov 	ecx, width				; columnLoop counter

columnLoop:
	loop	endColumnLoop

	;xor		ah, ah				; ah = bit_number = 0
	mov		al, 7				; al = shift = 7
	mov		dword[newByte], 0
	push 	ecx
	mov		ecx, 8
	call 	createByte
	pop		ecx					; Restore columnLoop counter

	; coy_s = width - 1;
	mov 	ebx, 	width
	dec		ebx,
	mov		dword[coy_s], ebx

	; Calculate destination index.
	mov 	edx, width
	imul 	edx, dword[coy_d]			; coy_d * width
;
	mov		ebx, [cox_d]
	add 	edx, ebx			; dest = cox_d + coy_d * width;
	mov		[dest], edx

	; Replace byte in data[dest] with byte returned by createByte.
	add		dword[dest], edi

	;mov		[dest],	ebx
	;mov		ebx, [newByte]
	;mov		[dest], ebx
	mov		[newByte], ebx
	xchg	[dest], ebx

	; Increase cox_d.
	inc		dword[cox_d]

	inc		ah
	; if bit_number > 7, then bit_number = 0.
	cmp		ah,	7
	xor		ah, ah


endColumnLoop:
	;inc		ebx                 ; Increase column (i) counter.
	pop		ecx					; rowLoop counter

	; coy_d++
	inc		dword[coy_d]

	; cox_d = 0
	mov		dword[cox_d], 0

	; cox_s++
	inc		dword[cox_s]

	; coy_s = width - 1.
	mov		ebx,	width
	dec		ebx
	mov		dword[coy_s], ebx

	jmp		rowLoop

endRowLoop:
	mov		ecx, 	width		; rowLoop counter
    add		esp,	4
	pop		esi
	;pop		edi

; Epilogue
	pop		ebp
	ret


createByte:

	; ecx = 8. Loop from 1 to 8.
	; initial value:		ah, 0			; ah = bit_number
	; initial value:		al, 7			; al = shift

	; source index = cox_s + coy_s * width

	mov 	ebx, [coy_s]
	mov 	edx, width
	imul 	edx, ebx			; coy_s * width
	mov		ebx, [cox_s]
	add 	edx, ebx			; source = cox_s + coy_s * width;

	mov		[source], edx		; source index

	push	ecx					; Push loop counter to use cl register.
	xor 	ebx, ebx
	; bit = data[source] AND  (1 SHL bit_number)
	mov		cl, ah				; ah = bit_number
	mov		dl, 1		; dl
	shl		dl, cl				; 1 SHL bit_number
	inc		cl					; bit_number++
	mov		ah, cl

	mov		ebx, [source]
	add		ebx, esi			; ebx = data[source]
	add		ebx, [esi + 10]		; offset?
	mov		dh, [ebx]
	and		dh, dl				; bh = bit

	; bit SHL shift
	mov		cl, al
	shl		dh, cl
	dec		cl					; shift--
	mov 	al, cl
;
	; byte += bit
	add 	[newByte], dh
;
	; coy_s--
	dec		dword[coy_s]
	pop		ecx					; exc = loop counter

	loop createByte