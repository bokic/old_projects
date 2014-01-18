{$A+,B-,D+,E-,F-,G+,I+,L+,N+,O-,P-,Q+,R+,S+,T+,V-,X+,Y+}
{$M 16384,0,655360}
Program Log;
Uses Crt,Graph;
Procedure Log10(Vlez:Extended;Var Izlez:Extended);
Assembler;
Asm
fldlg2
fwait
fld tbyte [bp + offset Vlez]
fwait
fyl2x
fwait
les di,Izlez;
fstp tbyte [es:di]
fwait
End;

Procedure Log2(Vlez:Extended;Var Izlez:Extended);
Assembler;
Asm
fld1
fwait
fld tbyte [bp + offset Vlez]
fwait
fyl2x
fwait
les di,Izlez;
fstp tbyte [es:di]
fwait
End;

Function Muzika(W:Extended):Extended;
Var T:Extended;
Begin
Log10(W*2,T);
Muzika:=T*10;
End;

Var N:Extended;
var
 grDriver: Integer;
 grMode: Integer;
 ErrCode: Integer;
 T:Integer;
begin
ClrScr;
grDriver := Detect;
InitGraph(grDriver, grMode,'c:\bp\bgi');
 Line(50,20,50,460);
 Line(30,440,590,440);
 Line(100,439,100,441);
 Line(150,438,150,442);
 Line(100,439,100,441);
 Line(150,438,150,442);
 Line(200,439,200,441);
 Line(250,438,250,442);
 Line(300,439,300,441);
 Line(350,438,350,442);
 Line(400,439,400,441);
 Line(450,438,450,442);
 Line(500,439,500,441);
 Line(550,438,550,442);
 OutTextXY(40,445,'0');
 OutTextXY(93,445,'50');
 OutTextXY(139,445,'100');
 OutTextXY(189,445,'150');
 OutTextXY(239,445,'200');
 OutTextXY(289,445,'250');
 OutTextXY(339,445,'300');
 OutTextXY(389,445,'350');
 OutTextXY(439,445,'400');
 OutTextXY(489,445,'450');
 OutTextXY(539,445,'500');
 OutTextXY(529,465,'Vrednost');
 Line(47,40,53,40);
 Line(49,80,51,80);
 Line(49,120,51,120);
 Line(49,160,51,160);
 Line(49,200,51,200);
 Line(48,240,52,240);
 Line(49,280,51,280);
 Line(49,320,51,320);
 Line(49,360,51,360);
 Line(49,400,51,400);
 OutTextXY(60,20,'Log * 10');
 OutTextXY(30,37,'10');
 OutTextXY(30,77,' 9');
 OutTextXY(30,117,' 8');
 OutTextXY(30,157,' 7');
 OutTextXY(30,197,' 6');
 OutTextXY(30,237,' 5');
 OutTextXY(30,277,' 4');
 OutTextXY(30,317,' 3');
 OutTextXY(30,357,' 2');
 OutTextXY(30,397,' 1');
For T:=1 to 500 Do
    Begin
    Log10(T,N);
    PutPixel(T+50,440-Round(N*40),1);
    Log2(T,N);
    PutPixel(T+50,440-Round(N*40),2);
    End;
{Log10(1,N);
Log10(2,N);
Log10(4,N);
Log10(8,N);
Log10(16,N);
Log10(32,N);
Log10(64,N);
Log10(128,N);}
N:=Muzika(1);
N:=Muzika(2);
N:=Muzika(4);
N:=Muzika(8);
N:=Muzika(16);
N:=Muzika(32);
N:=Muzika(64);
N:=Muzika(128);
N:=Muzika(256);
readkey;
asm
mov ax,3
int $10
end;
End.