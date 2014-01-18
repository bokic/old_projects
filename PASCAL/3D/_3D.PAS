Program _3D;
{Define Debug}
uses GRAPH,crt,mmx;
type
    toccka=record
    x,y,z:integer;
    end;

var kocka,rotkocka:array[0..7] of toccka;
    agol:Extended;
    gd,gm:word;

procedure SinCos(Angle:Extended;var Sin,Cos:Extended);
assembler;
asm

fildl Angle
fsincos
fstpl [Sin]
fstpl [Cos]
end;

procedure RotToccka(Stara:toccka;var Rotirana:toccka;rx, ry, rz:Extended);
var pom1,pom2:Extended;
begin
     {$mmx+}
     Rotirana.x:=Stara.x;
     Rotirana.y:=Stara.y;
     Rotirana.z:=Stara.z;
     pom1:=Rotirana.y*Cos(rx)-Rotirana.z*Sin(rx);
     pom2:=Rotirana.z*Cos(rx)+Rotirana.y*Sin(rx);
     Rotirana.y:=trunc(pom1);
     Rotirana.z:=trunc(pom2);
     pom1:=Rotirana.z*Cos(ry)-Rotirana.x*Sin(ry);
     pom2:=Rotirana.x*Cos(ry)+Rotirana.z*Sin(ry);
     Rotirana.z:=trunc(pom1);
     Rotirana.x:=trunc(pom2);
     pom1:=Rotirana.x*Cos(rz)-Rotirana.y*Sin(rz);
     pom2:=Rotirana.y*Cos(rz)+Rotirana.x*Sin(rz);
     Rotirana.x:=trunc(pom1);
     Rotirana.y:=trunc(pom2);
     {$mmx-}
end;

Procedure rotirajkocka(agx,agy,agz:Extended);
Var i:integer;
Begin
For i:=0 To 7 Do
   RotToccka(kocka[i],rotkocka[i],agx,agy,agz);
End;

procedure proektoccka(daleccina:integer;prostorna:toccka;var proekcija:toccka;centar:toccka;lekx,leky:integer);
var Temp:Extended;
begin
temp:=daleccina-(prostorna.z+centar.z);
proekcija.x:=trunc(lekx*(prostorna.x+centar.x)/temp+320);
proekcija.y:=trunc(250-leky*(prostorna.y+centar.y)/temp);
end;

procedure crtaj;
var i,lekkax,lekkay:integer;
    kamera:toccka;
begin
kamera.x:=0;
kamera.y:=0;
kamera.z:=0;
lekkax:=256;
lekkay:=256;
for i:=0 to 7 do
    proektoccka(256,rotkocka[i],rotkocka[i],kamera,lekkax,lekkay);
line(rotkocka[0].x,rotkocka[0].y,rotkocka[1].x,rotkocka[1].y);
line(rotkocka[0].x,rotkocka[0].y,rotkocka[2].x,rotkocka[2].y);
line(rotkocka[2].x,rotkocka[2].y,rotkocka[3].x,rotkocka[3].y);
line(rotkocka[3].x,rotkocka[3].y,rotkocka[1].x,rotkocka[1].y);
line(rotkocka[0].x,rotkocka[0].y,rotkocka[4].x,rotkocka[4].y);
line(rotkocka[4].x,rotkocka[4].y,rotkocka[5].x,rotkocka[5].y);
line(rotkocka[1].x,rotkocka[1].y,rotkocka[5].x,rotkocka[5].y);
line(rotkocka[2].x,rotkocka[2].y,rotkocka[6].x,rotkocka[6].y);
line(rotkocka[3].x,rotkocka[3].y,rotkocka[7].x,rotkocka[7].y);
line(rotkocka[4].x,rotkocka[4].y,rotkocka[6].x,rotkocka[6].y);
line(rotkocka[5].x,rotkocka[5].y,rotkocka[7].x,rotkocka[7].y);
line(rotkocka[6].x,rotkocka[6].y,rotkocka[7].x,rotkocka[7].y);
end;

procedure Exit_Proc;Far;
Begin
restorecrtmode;
closegraph;
End;

Var TTSin,TTCos:Extended;

begin
SinCos(20,TTSin,TTCos);
WriteLn(TTSin);
If(TTSin<>Sin(20)) Then
   Begin
   WriteLn('Greshka vo Sin');
   halt;
   End;
If(TTCos<>Cos(20)) Then
   Begin
   WriteLn('Greshka vo Cos');
   halt;
   End;
gm:=$101;gd:=$FF;
initgraph(gd,gm,'');
ExitProc:=@Exit_Proc;
kocka[0].x:=50;kocka[0].y:=50;kocka[0].z:=50;
kocka[1].x:=50;kocka[1].y:=50;kocka[1].z:=-50;
kocka[2].x:=50;kocka[2].y:=-50;kocka[2].z:=50;
kocka[3].x:=50;kocka[3].y:=-50;kocka[3].z:=-50;
kocka[4].x:=-50;kocka[4].y:=50;kocka[4].z:=50;
kocka[5].x:=-50;kocka[5].y:=50;kocka[5].z:=-50;
kocka[6].x:=-50;kocka[6].y:=-50;kocka[6].z:=50;
kocka[7].x:=-50;kocka[7].y:=-50;kocka[7].z:=-50;
agol:=0;
repeat
rotirajkocka(agol,agol,agol);
agol:=agol+0.01;
WaitRetrace;
SetColor(0);
crtaj;
SetColor(15);
rotirajkocka(agol,agol,agol);
crtaj;
until keypressed;
end.