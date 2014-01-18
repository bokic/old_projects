{$A+,B-,D+,E-,F-,G+,I+,L+,N+,O-,P-,Q+,R+,S+,T+,V-,X+,Y+}
{$M 16384,0,655360}
Program Rotacija_i_Proekcija;
uses graph,crt;
type
    toccka=record
    x,y,z:integer;
    end;

var kocka,rotkocka:array[0..7] of toccka;
    agol:Double;
    gd,gm:integer;

Procedure SinCos(var Angle,Sin,Cos:Double);
Assembler;
Asm
les di,Angle
fld qword ptr es:[di]
fwait
db $D9,$FB
les di,Sin
fwait
fstp qword ptr es:[di]
les di,Cos
{fwait{}
fstp qword ptr es:[di]
{fwait{}
End;

procedure Retrase;
Assembler;
Asm
mov     dx,3DAh
@sub_4_1:
in      ax,dx
test    al,8
jz      @sub_4_1
@sub_4_2:
in      ax,dx
test    al,8
jnz     @sub_4_2
End;

procedure RotToccka(Stara:toccka;var Rotirana:toccka;Rx, Ry, Rz:Double);
var pom1,pom2,pom3,pom4,
    TSinRx,TCosRx,TSinRy,TCosRy,TSinRz,TCosRz:Double;
begin
     SinCos(Rx,TSinRx,TCosRx);
     SinCos(Ry,TSinRy,TCosRy);
     SinCos(Rz,TSinRz,TCosRz);
     Rotirana.x:=Stara.x;
     Rotirana.y:=Stara.y;
     Rotirana.z:=Stara.z;
     pom1:=Rotirana.y*TCosRx-Rotirana.z*TSinRx;
     pom2:=Rotirana.z*TCosRx+Rotirana.y*TSinRx;
     Rotirana.y:=trunc(pom1);
     Rotirana.z:=trunc(pom2);
     pom3:=pom2      *TCosRy-Rotirana.x*TSinRy;
     pom4:=Rotirana.x*TCosRy+pom2      *TSinRy;
     Rotirana.z:=trunc(pom3);
     Rotirana.x:=trunc(pom4);
     pom3:=pom4      *TCosRz-pom1      *TSinRz;
     pom2:=pom1      *TCosRz+pom4      *TSinRz;
     Rotirana.x:=trunc(pom3);
     Rotirana.y:=trunc(pom2);
end;

Procedure rotirajkocka(agx,agy,agz:Double);
Var i:integer;
Begin
For i:=0 To 7 Do
   RotToccka(kocka[i],rotkocka[i],agx,agy,agz);
End;

procedure proektoccka(daleccina:integer;prostorna:toccka;var proekcija:toccka;centar:toccka;lekx,leky:integer);
var temp:Double;
begin
temp:=daleccina-(prostorna.z+centar.z);
proekcija.x:=trunc(lekx*(prostorna.x+centar.x)/temp+320);
proekcija.y:=trunc(250-leky*(prostorna.y+centar.y)/temp);
end;

procedure Crtaj;
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

begin
ExitProc:=@Exit_Proc;
detectgraph(gd,gm);initgraph(gd,gm,'d:\borlandc\bgi');
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
retrase;{}
cleardevice;
crtaj;
until keypressed;
end.