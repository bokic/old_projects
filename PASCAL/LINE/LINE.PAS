{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}
Unit Line;
Interface
Procedure SetMode(Mode:Byte);
Procedure LLine(x1,y1,x2,y2:Integer;color:Byte);
Procedure Plot(x,y:Integer;Color:Byte);
Implementation
Procedure SetMode(Mode:Byte);
Assembler;
Asm
mov ah,0
mov al,Mode
Int $10
End;

Procedure LLine(x1,y1,x2,y2:Integer;color:Byte);
var i,deltax,deltay,
    numpixels,
    d,dinc1,dinc2,
    x,xinc1,xinc2,
    y,yinc1,yinc2:Integer;
Begin
deltax:=Abs(x2-x1);
deltay:=Abs(y2-y1);
If (Deltax>=Deltay)Then
   Begin
   numpixels:=deltax+1;
   d:=(2*deltay)-deltax;
   dinc1:=deltay shl 1;
   dinc2:=(deltay-deltax) shl 1;
   xinc1:=1;
   xinc2:=1;
   yinc1:=0;
   yinc2:=1;
   End
   Else
   Begin
   numpixels:=deltay+1;
   d:=(2*deltax)-deltay;
   dinc1:=deltax shl 1;
   dinc2:=(deltax-deltay) shl 1;
   xinc1:=1;
   xinc2:=1;
   yinc1:=0;
   yinc2:=1;
   End;
If(x1>x2)Then
   Begin
   xinc1:=-xinc1;
   xinc2:=-xinc2;
   End;
If(y1>y2)Then
   Begin
   xinc1:=-xinc1;
   xinc2:=-xinc2;
   End;
x:=x1;y:=y1;
For i:=1 to NumPixels Do
    Begin
     Asm
     cmp x,319
     jg @Ne
     cmp y,199
     jg @Ne
     mov ax,$A000
     mov es,ax
     mov ax,y
     mov bx,ax
     shl ax,6
     shl bx,8
     add ax,bx
     add ax,x
     mov di,ax
     mov al,color
     mov es:[di],al
     @Ne:
     End;
    If(d<0)Then
        Begin
        d:=d+dinc1;
        x:=x+xinc1;
        y:=y+yinc1;
        End
        Else
        Begin
        d:=d+dinc2;
        x:=x+xinc2;
        y:=y+yinc2;
        End;
    End;
End;

Procedure Plot(x,y:Integer;Color:Byte);
Assembler;
Asm
mov ax,$A000
mov es,ax
mov ax,y
mov bx,ax
shl ax,6
shl bx,8
add ax,bx
add ax,x
mov di,ax
mov al,color
mov es:[di],al
End;
End.