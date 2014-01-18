{$A-,B-,D-,E-,F-,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V+,X+,Y-}
Unit SetMode;
interface
Procedure SMode;
implementation
Procedure SMode;
 Assembler;
 Asm
 cli
 mov dx,$3C4
 mov al,0
 out dx,al
 mov al,1
 inc dx
 out dx,al
 dec dx
 mov dx,$3D4
 mov al,$17
 out dx,al
 inc dx
 in al,dx
 and al,$7F
 out dx,al
 dec dx
 mov al,$11
 out dx,al
 inc dx
 in al,dx
 and al,$7F
 out dx,al
 mov dx,$3CC
 in al,dx
 or al,$C0
 mov dx,$3C2
 out dx,al
 mov dx,$3D4
 mov al,6
 out dx,al
 mov al,$B
 inc dx
 out dx,al
 dec dx
 mov al,7
 out dx,al
 mov ax,$3E
 inc dx
 out dx,al
 dec dx
 mov al,9
 out dx,al
 mov al,$4F
 inc dx
 out dx,al
 dec dx
 mov al,$10
 out dx,al
 mov al,$EA
 inc dx
 out dx,al
 dec dx
 mov al,$11
 out dx,al
 mov al,$8C
 inc dx
 out dx,al
 dec dx
 mov al,$12
 out dx,al
 mov al,$DF
 inc dx
 out dx,al
 dec dx
 mov al,$15
 out dx,al
 mov al,$E7
 inc dx
 out dx,al
 dec dx
 mov al,$16
 out dx,al
 mov al,4
 inc dx
 out dx,al
 dec dx
 mov al,$11
 out dx,al
 inc dx
 in al,dx
 or al,$80
 out dx,al
 dec dx
 mov al,$17
 out dx,al
 inc dx
 in al,dx
 or al,$80
 out dx,al
 mov dx,$3C4
 mov al,0
 out dx,al
 mov al,3
 inc dx
 out dx,al
 dec dx
 sti
 push es
 mov ax,$40
 mov es,ax
 mov byte ptr es:[$84],$1D
 pop es
 end;

Begin
asm
push es
push $B800
pop es
xor di,di
xor ax,ax
mov cx,$4000
rep
stosw
pop es
end;
SMode;
end.