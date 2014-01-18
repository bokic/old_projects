Unit SYSTEM.PAS;
interface
Var DelayCnt:Word;
implementation

Procedure Delay(Del:Word);
Assemble;
 Asm
      mov cx,Del
      jcxz @@2
      mov es,seg0040
      xor di,di
      mov bl,es:[di]
 @@1: mov ax,DelayCnt
      xor dx,dx
      call DelayLoop
      loop @@1
 End;

Procedure DelayLoop;Near;Assemble;
 Asm
 @@1:  sub ax,1
       sbb dx,0
       jc  @@2
       cmp bl,es:[di]
       je @@1
 @@2:
 End;


Begin
 asm
 call DelayLoop
 not ax
 not dx
 mov cx,55
 div cx
 mov delaycnt,ax
 end;
end.