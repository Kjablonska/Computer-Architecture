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

    %define     img         [ebp+8]
    %define     width       [ebp+12]
    %define     row_bytes   [ebp-4]
    %define     img_line    [ebp-8]
    %define     img_col     [ebp-12]
    %define     count       [ebp-16]

; Finding width in bytes.
    mov		edx,	width
	and		edx,	31		; % 32

; Pushing result on stack.
skip:
	add		edx,	width
	sar		edx,	3		  ; Dividing result by 8 to get number of bytes.
	push	edx


mov		ebx,	1	        ; Row loop counter (i) = 1.
; i loop
rowLoop:
    cmp		ebx,	width	; Comparing against image height (= width).
	jz		endRowLoop
; j loop
columnLoop:
    cmp		edi,	width
	jz		endColumnLoop

    inc		edi                 ; Increase column (j) counter.
	jmp		columnLoop

endColumnLoop:
	inc		ebx                 ; Increase column (i) counter.
	jmp		rowLoop

endRowLoop:
    add		esp,	4
	pop		esi
	pop		edi
	pop 	ebx

; Epilogue
	pop		ebp
	ret

