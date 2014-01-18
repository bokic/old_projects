{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T+,V-,X+,Y+}
{$M 16384,0,655360}
Uses Crt;

Function Get(Reg:Byte):Byte;
Assembler;
Asm
mov     dx,224h
mov     al,Reg
out     dx,al
inc     dx
in      al,dx
End;

Function hexbyte(w:byte):String;
Const hex:String= '0123456789ABCDEF';
Begin
hexbyte:=hex[(w div 16)+1]+hex[(w mod 16)+1];
End;

Var Base:Byte;
    T:Word;
    Ch,Ch2:Char;
Begin
ClrScr;
repeat
Ch:=#255;
Ch2:=#255;
If (KeyPressed) Then
   Begin
   Ch:=ReadKey;
   If (Ch=#0) Then Ch2:=ReadKey;
    Case Ch Of
    '-':Begin
        {$R-}
        Base:=Base-16;
        End;
    '+':Begin
        Base:=Base+16;
        {$R+}
        End;
    End;
   End;
 GotoXY(1,1);
 For T:=0 To 15 Do
     Begin
	  WriteLn('Regs ',Base+T:3,' or ',hexbyte(Base+T),'h = ',Get(Base+T):3,' or ',hexbyte(Get(Base+T)));
     End;
until (Ch=#27);
End.