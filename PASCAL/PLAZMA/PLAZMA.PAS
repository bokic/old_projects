{$A+,B-,D-,E-,F-,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V+,X+,Y-}
{$M 16384,0,655360}
Procedure PSet(X,Y:Word;Col:Byte);
Assembler;
Asm
push $a000
pop es
mov ax,y
mov bx,320
mul bx
add ax,x
mov si,ax
mov al,Col
mov es:[si],al
End;

Function GetPoint(X,Y:Word):Byte;
Assembler;
Asm
push $a000
pop es
mov ax,y
mov bx,320
mul bx
add ax,x
mov si,ax
mov al,es:[si]
End;

Procedure SetPalette;
Procedure SetPal(Index:Byte;Color:LongInt);
Assembler;
Asm
mov ax,$1010
mov bh,0
mov bl,Index
mov cx,word ptr Color
mov dh,byte ptr Color+2
int $10
End;
Var T:Byte;
Begin
For T:=0 To 63 Do
        Begin
        SetPal(t,(t + 256 * (63 - t)));
        SetPal(t+64,(63 - t + 256 * 256 * t));
        SetPal(t+128,((256 * 256 * (63 - t) + 256 * t)));
        End;
End;

Function RND:Real;
Begin
RND:= random(10000)/10000;
End;

Function Max(V1,V2,V3,V4:Byte):Byte;
Var MaxBr:Byte;
Begin
MaxBr:=V1;
If (V2 > MaxBr) Then MaxBr:=V2;
If (V3 > MaxBr) Then MaxBr:=V3;
If (V4 > MaxBr) Then MaxBr:=V4;
Max:=MaxBr;
End;

Function Min(V1,V2,V3,V4:Byte):Byte;
Var MinBr:Byte;
Begin
MinBr:=V1;
If (V2 < MinBr) Then MinBr:=V2;
If (V3 < MinBr) Then MinBr:=V3;
If (V4 < MinBr) Then MinBr:=V4;
Min:=MinBr;
End;

Procedure Plazma(Xlg,Ylg,Xdd,Ydd:Word);
Var
        X1,Y1:Word;
        PTlglg,PTlgdd,PTddlg,PTdddd,PTmin,PTmax:Byte;
Begin
X1:=(Xlg + Xdd) div 2;
Y1:=(Ylg + Ydd) div 2;

PTlglg:=GetPoint(Xlg,Ylg);
PTlgdd:=GetPoint(Xlg,Ydd);
PTddlg:=GetPoint(Xdd,Ylg);
PTdddd:=GetPoint(Xdd,Ydd);
PTmin:=MIN(PTlglg, PTlgdd, PTddlg, PTdddd);
PTmax:=MAX(PTlglg, PTlgdd, PTddlg, PTdddd);

If (GetPoint(X1, Y1)  = 0) Then
        PSET (X1, Y1,(PTlglg + PTlgdd + PTddlg + PTdddd) div 4);
If (GetPoint(Xlg, Y1) = 0) Then
        PSET (Xlg, Y1, Round(PTlglg + INT(RND * (PTlgdd - PTlglg))));
If (GetPoint(Xdd, Y1) = 0) Then
        PSET (Xdd, Y1, Round(PTddlg + INT(RND * (PTdddd - PTddlg))));
If (GetPoint(X1, Ylg) = 0) Then
        PSET (X1, Ylg, Round(PTlglg + INT(RND * (PTddlg - PTlglg))));
If (GetPoint(X1, Ydd) = 0) Then
        PSET (X1, Ydd, Round(PTdddd + INT(RND * (PTlgdd - PTdddd))));

If (Abs(integer(X1) - integer(Xlg)) = 1) Then
        Exit;

Plazma(Xlg, Ylg, X1, Y1);
Plazma(Xlg, Ydd, X1, Y1);
Plazma(Xdd, Ylg, X1, Y1);
Plazma(Xdd, Ydd, X1, Y1);
End;

Begin
Randomize;
 Asm
 mov ax,$13
 int $10
 End;
SetPalette;
PSET (1, 1, 1);
PSET (1, 129, 128);
PSET (129, 1, 128);
PSET (129, 129, 175);
PSET (257, 1, 128);
PSET (257, 129, 1);
Plazma(1, 1, 257, 129);
ReadLn;
 Asm
 mov ax,$3
 int $10
 End;
End.