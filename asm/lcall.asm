;
; test lcall and bit addressable memory space
;
	mov 20h, #00h;
	setb  02h;
	lcall t;
	mov P0, 20h;
	ljmp e;

t:
	mov P0, #10;
	ret;
e:
	nop;
	nop;

;
; test p bit in psw
;
	mov r0, #0f0h
	mov a, #031h;    p=1
	mov c, psw.0;
	jnc error;
	mov p0, #001h;
	mov r0, #0f1h;
	mov a, #063h;    p=0
	mov c, psw.0;
	jc error;



error:
	mov p0, r0;



