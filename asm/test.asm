; test
;
; r0- counter
; r1, r2- delay
; r4- shift

   nop;
   nop;
   mov 90h,#0aah;
   mov R0,#01h;
   mov r5, #00h;
   mov 80h, #0fh;

d:
   nop;
   nop;
   nop;
   jz d;
   mov r4, #01h;
   mov 80h, #00h;

start:
   mov 90h, r4;
   nop;
   acall delay;

   mov 80h, r0;
   mov a,r5;
   nop;
   nop;

   jz up;
   inc r0;
   ajmp ed;

up:
   dec r0;

ed:
   mov a, r4;
   rr a;
   mov r4,a;
   nop;
   ajmp start;
   mov 80h,#11h;


delay:
   mov r1, #0ffh;
   mov r2, #0ffh;
z1:
   mov a, #0ffh;
z2:
   mov r1, a;
   mov a, r2;
   add a, #02h;
   mov a, r1;
   dec a;
   nop;
   nop;
   nop;
   nop;
   nop;
   nop;
   nop;
   nop;
   jnz z2;
   dec r2;
   mov a,r2;
   jnz z1;
   ret;

   
       
   .org 50h
   nop;
   mov a, #01;
   mov r5, #00h
   nop;
   nop;
   reti;

   .org 65h
   nop;
   mov r5, #0fh
   mov a, #01;
   nop;
   nop;
   reti;
