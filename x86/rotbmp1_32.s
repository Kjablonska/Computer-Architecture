section .data
cox_s 		dw 0			; x coordinate of source byte.
coy_s 		dw 0			; y coordinate of source byte.

cox_d 		dw 0			; x coordinate of destination byte.
coy_d 		dw 0			; y coordinate of destination byte.

shift 		dw 7
bit_number 	dw 0

dest		dw 0

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

    %define     img         	[ebp + 8]
	%define     img_dest        [ebp + 12]
    %define     width       	[ebp + 16]
	;%define		width			[ebp + 16]
	mov		edx,	width
	and		edx,	31		; % 32

; Pushing result on stack.
skip:
	add		edx,	width
	sar		edx,	3		  ; Dividing result by 8 to get number of bytes.
	push	edx			; Array pointer.
	;mov		ecx,	img_empty

	mov ebx, 1
	mov edi, 1
rowLoop:
    cmp		ebx,	width	; Comparing against image height (= width).
	jz		endRowLoop

; columnLoop (j) takes each bit in byte in the row.
columnLoop:
    cmp		edi,	width
	jz		endColumnLoop

	mov 	ah, [bit_number]
	mov		al, [shift]
	; Tutaj pętla k.
	;call 	bitFromBytesLoop

	; Increment bit_number;
	inc 	ah
;
	mov 	al, 7		; shift = 7.

	; coy_s = width - 1;
	mov 	dl, 	width
	sub		dl,		1
	mov		[coy_s],	dl

	; Calculate destination index.
	mov ebx, [coy_d]
	mov eax, width
	sub ebx, 1
	imul eax, ebx	; (coy_d - 1) * width
;
	mov	ebx, [cox_d]
	sub ebx, 1
	add eax, ebx	; dest = (cox_d - 1) + (coy_d - 1) * width;
	mov		[dest], dh

	; Load byte to img_empty[dest].

	; byte = 0.

	; Increase cox_d.
	mov		dh,	[cox_d]
	inc		dh
	mov		[cox_d],	dh
;
	;; if bit_number > 7, then bit_number = 0.
	cmp		ah,	7
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
	mov		[cox_d], dl			; cox_d = 0.

	; Increase cox_s.
	mov		dl, [cox_s]
	inc		dl
	mov		[cox_s], dl

	; coy_s = width - 1.
	mov		eax, 	width
	sub		eax, 	1
	mov		[coy_s], 	eax

	mov		ah,	0		; bit_number = 0.
	jmp		rowLoop

endRowLoop:
    add		esp,	4
	pop		esi
	pop		edi
	pop 	ebx

; Epilogue
	pop		ebp
	ret

;bitFromBytesLoop:
