	mov a, #048h;
	mov sbuf, a;
	mov a,#10;

test0:
	nop
	dec a;
	jnz test0;

	mov p0, scon;

	mov a, #05eh;
	mov scon, #080h;
	mov sbuf,a;
	mov a, #15;

test21:
	nop
	nop
	dec a;
	jnz test21;

	mov p0, scon;

	mov a, #05eh;
	mov pcon, #080h;
	mov sbuf,a;
	mov a, #25;

test22:
	nop
	nop
	dec a;
	jnz test22;

	mov p0, scon;

	mov a, #05eh;
	mov scon, #040h;
	mov sbuf,a;
	mov a, #20;

test11:
	nop
	nop
	nop
	nop
	movx @R0, a;
	dec a;
	jnz test11;

	mov p0, scon;

	mov a, #05eh;
	setb scon.3;
	mov sbuf,a;
	mov a, #20;

test12:
	nop
	nop
	nop
	nop
	movx @R0, a;
	dec a;
	jnz test12;

	mov p0, scon;

	mov a, #05eh;
	mov scon, #0c0h;
	mov sbuf,a;
	mov a, #20;

test31:
	nop
	nop
	nop
	nop
	movx @R0, a;
	dec a;
	jnz test31;

	mov p0, scon;

	mov a, #05eh;
	setb scon.3;
	mov sbuf,a;
	mov a, #20;

test32:
	nop
	nop
	nop
	nop
	movx @R0, a;
	dec a;
	jnz test32;

	mov p0, scon;


	mov p0, #00;
