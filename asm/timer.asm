;
;
; testing timers and interrupts
;
;
;

	ajmp start;

	.org 03h	;external interrupt 0
	reti;

	.org 0bh	;t/c 0 interrupt
tc0:
	nop;
	jz tc0;
	mov p0, #00h
	setb c;
	reti;

	.org 13h	;external interrupt 1
	reti;

	.org 1bh	;t/c 1 interrupt
	mov p0, #01h	;
	mov a, #01h	;
	reti;

	.org 23h	;serial interface interrupt
	reti;


start:
	mov ie, #08ah	;enable interrupts
	mov ip, #008h	;set prioriti lelev of t/c 1 to 1
	mov tmod, #000h	;t/c 0 and t/c 1 in timer mode 0
	mov th0, #0a0h	;load timer 0
	mov tl0, #000h	;
	mov th1, #090h	;load timer 1
	mov tl1, #000h	;
	clr a;
	clr c;
	mov tcon, #050h	;start timers

loop:
	nop		;
	nop		;
	nop		;
	jnc loop	;
	mov p0, #02h	;


