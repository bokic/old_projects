{$A+,B-,D+,E-,F-,G+,I+,L+,N+,O-,P-,Q+,R+,S+,T+,V-,X+,Y+}
{$M 16384,0,655360}
Uses crt;
type
    toccka=record
        x,y,z:Double;
    end;

    lice=record
        t1,t2,t3,t4:toccka;
        color:byte;
        end;

var poligon,rotpoly:array[0..5] of lice;
    normala:array[0..5] of toccka;
    pocetok,kraj:array[0..200] of word;
    agol:Double;
    i:word;

procedure RotToccka(Stara : toccka;var Rotirana : toccka;rx,ry,rz:Double);
var pom1,pom2,pom3,pom4:double;
Begin
Rotirana.X :=Stara.X;
Rotirana.Y :=Stara.Y;
Rotirana.Z :=Stara.Z;
pom1:=(Rotirana.Y*Cos(rx)) - (Rotirana.Z * Sin(rx));
pom2:=(Rotirana.Z*Cos(rx)) + (Rotirana.Y* Sin(rx));
Rotirana.y := Round(pom1);
Rotirana.z := Round(pom2);
pom3:=pom2*Cos(ry) - Rotirana.X*Sin(ry);
pom4:=Rotirana.X*Cos(ry) + pom2*Sin(ry);
Rotirana.y := Round(pom3);
Rotirana.x := Round(pom4);
pom1:=pom4*Cos(rz) - pom3*Sin(rz);
pom2:=pom3*Cos(rz) + pom4*Sin(rz);
Rotirana.x := Round(pom1);
Rotirana.y := Round(pom2);
End;

Procedure ScanEdge(xp:integer;yp:integer;xk:integer;yk:integer);
Var i,tmp,x,y:longint;
    m:Double;
Begin
If (yk<>yp) Then
    Begin
    If (yk<yp) Then
       Begin
       tmp:=yp;
       yp:=yk;
       yk:=tmp;
       tmp:=xp;
       xp:=xk;
       xk:=tmp;
       End;
    x:=xp*65536;
    m:=((xk-xp)*65536)/(yk-yp);
    x:=round(x+m);
    yp:=yp+1;
    For y:=yp To yk Do
        Begin
        If ((Y>0)And(Y<200)) Then
           If (pocetok[y]=65535) Then
              pocetok[y]:=round(x/65536)
              Else
              kraj[y]:=round(x/65536);
        x:=round(x+m);
        End;
    End;
End;

Procedure Horizontal(x1,x2,y:Word;col:Byte);Assembler;
Asm
mov ax,$A000
mov es,ax
mov ax,y
mov di,ax
shl ax,8
shl di,6
add di,ax
add di,x1
mov al,col
mov cx,x2
sub cx,x1
{inc cx}
rep stosb
{@loop1:
mov byte ptr es:[di],al
inc di
dec cx
jnz @Loop1}
End;

Procedure FillPoly(x1,y1,x2,y2,x3,y3,x4,y4,color:Integer);
Label FillLoop;
Var i,tmp:integer;
Begin
For i:=0 To 200 Do
    Begin
    pocetok[i]:=65535;
    kraj[i]:=65535;
    End;
scanedge(x1,y1,x2,y2);
scanedge(x2,y2,x3,y3);
scanedge(x3,y3,x4,y4);
scanedge(x4,y4,x1,y1);
For i:=0 To 200 Do
    Begin
    If (pocetok[i]>kraj[i]) Then
       Begin
       tmp:=pocetok[i];
       pocetok[i]:=kraj[i];
       kraj[i]:=tmp;
       End;
    If (Pocetok[i]<>65535) Then
       If (Kraj[i]=65535) Then
          Kraj[i]:=Pocetok[i]
          Else
              Begin
              Horizontal(Pocetok[i],Kraj[i],i,color);
{              Delay(5);{}
              End;
    End;
End;

Procedure Proektoccka(prostorna:toccka;var xp,yp:integer);
Begin
xp:=Round((256*prostorna.x/(256-prostorna.z))+160);
yp:=Round(100-(256*prostorna.y/(256-prostorna.z)));
End;

Procedure DrawPoly(poly:lice;norm:toccka);
Var x1,x2,x3,x4,y1,y2,y3,y4:integer;
Begin
If (Norm.Z>0) Then
   Begin
   x1:=Round(poly.t1.x)+160;
   y1:=Round(poly.t1.y)+100;
   x2:=Round(poly.t2.x)+160;
   y2:=Round(poly.t2.y)+100;
   x3:=Round(poly.t3.x)+160;
   y3:=Round(poly.t3.y)+100;
   x4:=Round(poly.t4.x)+160;
   y4:=Round(poly.t4.y)+100;
   FillPoly(x1,y1,x2,y2,x3,y3,x4,y4,poly.color);
   End;
End;

Procedure CalcNorm(poly:lice;var norm:toccka);
Var v1,v2:toccka;
Begin
v1.x:=poly.t4.x-poly.t1.x; v1.y:=poly.t4.y-poly.t1.y;
v2.x:=poly.t2.x-poly.t1.x; v2.y:=poly.t2.y-poly.t1.y;
norm.z:=v1.x*v2.y-v2.x*v2.y;
End;

Procedure ClearScreen;Assembler;
Asm
mov ax,$A000
mov es,ax
db $66
mov ax,$3444
db $54,$64
mov di,0
mov cx,16000
rep
db $66
stosw
End;

Procedure Retreace;Assembler;
Asm
mov dx,$3DA
@RIma:
in ax,dx
test al,8
jz @RIma
@RNema:
in ax,8
test al,8
jnz @RNema
End;

Procedure InitObject;
Begin
poligon[0].t1.x:=-50;poligon[0].t1.y:= 50;poligon[0].t1.z:= 50;
poligon[0].t2.x:= 50;poligon[0].t2.y:= 50;poligon[0].t2.z:= 50;
poligon[0].t3.x:= 50;poligon[0].t3.y:=-50;poligon[0].t3.z:= 50;
poligon[0].t4.x:=-50;poligon[0].t4.y:=-50;poligon[0].t4.z:= 50;
poligon[0].color:=1;
rotpoly[0]:=poligon[0];
poligon[1].t1.x:=-50;poligon[1].t1.y:= 50;poligon[1].t1.z:=-50;
poligon[1].t2.x:=-50;poligon[1].t2.y:=-50;poligon[1].t2.z:=-50;
poligon[1].t3.x:= 50;poligon[1].t3.y:=-50;poligon[1].t3.z:=-50;
poligon[1].t4.x:= 50;poligon[1].t4.y:= 50;poligon[1].t4.z:=-50;
poligon[1].color:=15;
rotpoly[1]:=poligon[1];
poligon[2].t1.x:=-50;poligon[2].t1.y:= 50;poligon[2].t1.z:=-50;
poligon[2].t2.x:=-50;poligon[2].t2.y:= 50;poligon[2].t2.z:= 50;
poligon[2].t3.x:=-50;poligon[2].t3.y:=-50;poligon[2].t3.z:= 50;
poligon[2].t4.x:=-50;poligon[2].t4.y:=-50;poligon[2].t4.z:=-50;
poligon[2].color:=3;{Dole}
rotpoly[2]:=poligon[2];
poligon[3].t1.x:= 50;poligon[3].t1.y:= 50;poligon[3].t1.z:=-50;
poligon[3].t2.x:= 50;poligon[3].t2.y:=-50;poligon[3].t2.z:=-50;
poligon[3].t3.x:= 50;poligon[3].t3.y:=-50;poligon[3].t3.z:= 50;
poligon[3].t4.x:= 50;poligon[3].t4.y:= 50;poligon[3].t4.z:= 50;
poligon[3].color:=4;{Gore}
rotpoly[3]:=poligon[3];
poligon[4].t1.x:=-50;poligon[4].t1.y:=-50;poligon[4].t1.z:= 50;
poligon[4].t2.x:= 50;poligon[4].t2.y:=-50;poligon[4].t2.z:= 50;
poligon[4].t3.x:= 50;poligon[4].t3.y:=-50;poligon[4].t3.z:=-50;
poligon[4].t4.x:=-50;poligon[4].t4.y:=-50;poligon[4].t4.z:=-50;
poligon[4].color:=5;
rotpoly[4]:=poligon[4];
poligon[5].t1.x:=-50;poligon[5].t1.y:= 50;poligon[5].t1.z:= 50;
poligon[5].t2.x:=-50;poligon[5].t2.y:= 50;poligon[5].t2.z:=-50;
poligon[5].t3.x:= 50;poligon[5].t3.y:= 50;poligon[5].t3.z:=-50;
poligon[5].t4.x:= 50;poligon[5].t4.y:= 50;poligon[5].t4.z:= 50;
poligon[5].color:=15;
rotpoly[5]:=poligon[5];
End;

Begin
InitObject;Agol:=0;
 Asm
 mov ax,$13
 int $10
 End;
Repeat
For i:=0 To 5 Do
    Begin
    RotToccka(poligon[i].t1,rotpoly[i].t1,agol,agol+1.5,agol);
    RotToccka(poligon[i].t2,rotpoly[i].t2,agol,agol+1.5,agol);
    RotToccka(poligon[i].t3,rotpoly[i].t3,agol,agol+1.5,agol);
    RotToccka(poligon[i].t4,rotpoly[i].t4,agol,agol+1.5,agol);
    End;
For i:=0 To 5 Do
    Begin
    CalcNorm(rotpoly[i],normala[i]);
    End;
Delay(50);
Retreace;
ClearScreen;
For i:=0 To 5 Do
    Begin
    DrawPoly(rotpoly[i],normala[i]);
    End;
{Retreace;}
agol:=agol+0.05;{delay(42);{}
Until (keypressed);
Asm
mov ax,3
int $10
End;
End.