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

	push	ebx
	push	edi
	push	esi

	push	ebp
	mov		ebp, 	esp

    %define     img     [ebp + 20]
	%define     width	[ebp + 24]

jmp epilogue
; [(bit per pixel * width + 31 )/ 32 ] *4 = row size in bytes.
	mov		edx,	width
	add		edx,	31
	shr		edx,	5			; =/32
	shl		edx,	2			; =*4

	push 	edx					; row_size in bytes [ebp - 4]

	%define		row_size		[ebp - 4]

	; Allocate memory of the size of row_size * width.
	mov		eax,	width
	imul	eax,	edx
	push	eax					; [ebp - 8]
	%define		image_size		[ebp - 8]

	sub			esp,	eax

	%define		dest_image		[ebp - 12]

	mov		esi, img
	mov		edi, dest_image

	mov		ecx, 1

rowLoop:
    cmp		ecx,	width		; Comparing against image height (= width).
	jz		endRowLoop

	push 	ecx
	mov 	ecx, width			; columnLoop counter

columnLoop:

	xor		ah, ah				; ah = bit_number = 0
	mov		al, 7				; al = shift = 7
	mov		dword[newByte], 0
	push 	ecx
	mov		ecx, 8
	call 	createByte
	pop		ecx						; Restore columnLoop counter
	;mov		[newByte], BYTE 0xFF	; white

	; coy_s = width - 1;
	mov 	ebx, 	width
	dec		ebx,
	mov		dword[coy_s], ebx

	; Calculate destination index.
	mov 	edx, width
	imul 	edx, dword[coy_d]			; coy_d * width
;
	mov		ebx, [cox_d]
	add 	edx, ebx				; dest = cox_d + coy_d * width;
	mov		[dest], edx

	; Replace byte in data[dest] with byte returned by createByte.
	add		dword[dest], edi
	mov		ebx, [newByte]
	mov		[dest], ebx

	; Increase cox_d.
	inc		dword[cox_d]

	inc		ah					; bit_number++
	; if bit_number > 7, then bit_number = 0.
	cmp		ah,	8
	xor		ah, ah
	loop	columnLoop


endColumnLoop:
	pop		ecx					; rowLoop counter
	inc		ecx

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


; Copy from destination array to source array.
	mov		eax, img
	mov		ebx, dest_image
	mov 	ecx, image_size
	xor		dl, dl
copy:
	mov		edx, [ebx]
	mov		[eax], edx
	;mov		[eax], byte 0xFF
	inc		eax
	dec		ebx
	loop copy



epilogue:
	mov		eax, dest_image
	mov		eax, img
	mov		esp, ebp
	pop		ebp

	pop		esi
	pop		edi
	pop		ebx
;
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
	add 	edx, ebx			; edx = source = cox_s + coy_s * width;
	mov		[source], edx		; source index
	;add		dword[source], esi

	push	ecx					; Push loop counter to use cl register.

	; Get single bit from [source] byte.
	; bit = data[source] AND (1 SHL bit_number)
	xor 	edx, edx
	mov		cl, ah				; ah = bit_number
	mov		dl, 1
	shl		dl, cl				; 1 SHL bit_number
	mov		ah, cl

	mov 	bl, [edi + source]
	and		bl, dl
;
	;; bit SHL shift
	mov		cl, al
	shl		bl, cl
	dec		cl					; shift--
	mov 	al, cl

	; byte += bit
	add		[newByte], bl
	;mov		[newByte], BYTE 0xFF
	; coy_s--
	dec		dword[coy_s]
	pop		ecx					; exc = loop counter

	loop createByte
	ret