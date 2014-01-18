{$A+,B-,D+,E-,F-,G+,I+,L+,N+,O-,P-,Q+,R+,S+,T+,V-,X+,Y+}
{$M 16384,0,655360}
Uses graph,crt;
type
    toccka=record
        x:integer;
        y:integer;
        z:integer;
    end;
    nrm=record
        x:real;
        y:real;
        z:real;
    end;
    lice=record
        t1:toccka;
        t2:toccka;
        t3:toccka;
        t4:toccka;
    end;
var poligon :array[0..5] of lice;
    rotpoly :array[0..5] of lice;
    normala :array[0..5] of nrm;
    agol:real;
    gm,gd:integer;
    i:word;

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

procedure RotToccka(Stara : toccka;var Rotirana : toccka;rx,ry,rz:real);
var pom1,pom2,pom3,pom4:real;
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

Procedure Drawpoly(poly:lice;norm:nrm);
Begin
If (norm.z>0) then
  Begin
  line(poly.t1.x+320,poly.t1.y+240,poly.t2.x+320,poly.t2.y+240);
  line(poly.t2.x+320,poly.t2.y+240,poly.t3.x+320,poly.t3.y+240);
  line(poly.t3.x+320,poly.t3.y+240,poly.t4.x+320,poly.t4.y+240);
  line(poly.t4.x+320,poly.t4.y+240,poly.t1.x+320,poly.t1.y+240);
  end;
End;

Procedure calcnorm(poly:lice;var norm:nrm);
Var v1,v2:nrm;
Begin
v1.x:=poly.t2.x-poly.t1.x;
v1.y:=poly.t2.y-poly.t1.y;
v2.x:=poly.t4.x-poly.t1.x;
v2.y:=poly.t4.y-poly.t1.y;
norm.z:=(v1.x * v2.y) - (v2.x * v1.y);
end;

Begin
poligon[0].t1.x:=-50;poligon[0].t1.y:= 50;poligon[0].t1.z:= 50;
poligon[0].t2.x:= 50;poligon[0].t2.y:= 50;poligon[0].t2.z:= 50;
poligon[0].t3.x:= 50;poligon[0].t3.y:=-50;poligon[0].t3.z:= 50;
poligon[0].t4.x:=-50;poligon[0].t4.y:=-50;poligon[0].t4.z:= 50;
rotpoly[0]:=poligon[0];
poligon[1].t1.x:=-50;poligon[1].t1.y:= 50;poligon[1].t1.z:=-50;
poligon[1].t2.x:=-50;poligon[1].t2.y:=-50;poligon[1].t2.z:=-50;
poligon[1].t3.x:= 50;poligon[1].t3.y:=-50;poligon[1].t3.z:=-50;
poligon[1].t4.x:= 50;poligon[1].t4.y:= 50;poligon[1].t4.z:=-50;
rotpoly[1]:=poligon[1];
poligon[2].t1.x:=-50;poligon[2].t1.y:= 50;poligon[2].t1.z:=-50;
poligon[2].t2.x:=-50;poligon[2].t2.y:= 50;poligon[2].t2.z:= 50;
poligon[2].t3.x:=-50;poligon[2].t3.y:=-50;poligon[2].t3.z:= 50;
poligon[2].t4.x:=-50;poligon[2].t4.y:=-50;poligon[2].t4.z:=-50;
rotpoly[2]:=poligon[2];
poligon[3].t1.x:= 50;poligon[3].t1.y:= 50;poligon[3].t1.z:=-50;
poligon[3].t2.x:= 50;poligon[3].t2.y:=-50;poligon[3].t2.z:=-50;
poligon[3].t3.x:= 50;poligon[3].t3.y:=-50;poligon[3].t3.z:= 50;
poligon[3].t4.x:= 50;poligon[3].t4.y:= 50;poligon[3].t4.z:= 50;
rotpoly[3]:=poligon[3];
poligon[4].t1.x:=-50;poligon[4].t1.y:=-50;poligon[4].t1.z:= 50;
poligon[4].t2.x:= 50;poligon[4].t2.y:=-50;poligon[4].t2.z:= 50;
poligon[4].t3.x:= 50;poligon[4].t3.y:=-50;poligon[4].t3.z:=-50;
poligon[4].t4.x:=-50;poligon[4].t4.y:=-50;poligon[4].t4.z:=-50;
rotpoly[4]:=poligon[4];
poligon[5].t1.x:=-50;poligon[5].t1.y:= 50;poligon[5].t1.z:= 50;
poligon[5].t2.x:=-50;poligon[5].t2.y:= 50;poligon[5].t2.z:=-50;
poligon[5].t3.x:= 50;poligon[5].t3.y:= 50;poligon[5].t3.z:=-50;
poligon[5].t4.x:= 50;poligon[5].t4.y:= 50;poligon[5].t4.z:= 50;
rotpoly[5]:=poligon[5];
detectgraph(gd,gm);
initgraph(gd,gm,'d:\borlandc\bgi');
agol:=0;
Repeat
for i:=0 to 5 do
    Begin
    RotToccka(poligon[i].t1,rotpoly[i].t1,1-agol,-agol,0);
    RotToccka(poligon[i].t2,rotpoly[i].t2,1-agol,-agol,0);
    RotToccka(poligon[i].t3,rotpoly[i].t3,1-agol,-agol,0);
    RotToccka(poligon[i].t4,rotpoly[i].t4,1-agol,-agol,0);
    End;
for i:=0 to 5 do
    calcnorm(rotpoly[i],normala[i]);
Retrase;
ClearDevice;
for i:=0 to 5 do
    DrawPoly(rotpoly[i],normala[i]);
agol:=agol+0.1;
until keypressed;
restorecrtmode;
CloseGraph;
End.