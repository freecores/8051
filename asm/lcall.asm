;
; test lcall and bit addressable memory space
;
	mov 20h, #00h	;
	setb  02h	;
	lcall t		;
	mov P0, 20h	;
	ljmp e		;

t:
	mov P0, #10	;
	ret	;
e:
	nop	;
	nop	;

;
; test p bit in psw
;
	mov r0, #0f0h	;
	mov a, #031h	;    p=1
	mov c, psw.0	;
	jnc error	;
	mov p0, #001h	;
	mov r0, #0f1h	;
	mov a, #063h	;    p=0
	mov c, psw.0	;
	jc error	;
	mov P0, #02h	;
	jnz test1	;
	nop
	nop
	nop
test1:
	ljmp test	;

error:
	mov p1, r0;

;
; test relative jumps
;


	org 01f0h	;
done:
	nop		;
	mov p0, #33h	;
	ajmp done	;

	org 0210h
test:
	mov b, #04h	;
	clr a		;
	jz done		;

	org 02f0h	;
	mov r0, #00	;
	ljmp error	;

end


