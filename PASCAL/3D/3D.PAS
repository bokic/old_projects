{$A+,B-,D+,E-,F-,G+,I-,L+,N+,O-,P-,Q-,R-,S-,T+,V-,X+,Y+}
{$M 16384,0,655360}
uses graph,crt,graph3d;

procedure SetVisPage(VP:Byte);
Assembler;
Asm
mov ah,$5
mov al,VP
int $10
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

procedure SMode;
var
   user:Integer;
   grDriver: Integer;
   grMode: Integer;
   ErrCode: Integer;
begin
DetectGraph(grDriver,grMode);
grMode:=2;
InitGraph(grDriver, grMode,'d:\borlandc\bgi');{}
{user:=InstallUserDriver('BGI256',nil);
grMode:=3;
InitGraph(user, grMode,'c:\bp\bgi');{}
End;

Var Poly:PListPolygon;
    Wind:P3DWindow;
    AP,VP:Byte;
    TSt:String;
    Ch:Char;
Begin
New(Poly,Init(New(PListVertex,Init)));
New(Wind,Init(640,300,0.5,270,0));{320,76}
Wind^.LOffset:=320;
Wind^.TOffset:=150;
SMode;
Poly^.Add(0,0,0,100,0,0,0,0,0);
Poly^.Add(0,0,0,0,100,0,0,0,0);
Poly^.Add(0,0,0,0,0,100,0,0,0);
Poly^.Add(-175,-290,0,-95,-290,0,-95,-210,0);
Poly^.Add(-175,-290,0,-95,-210,0,-175,-210,0);
Poly^.Add(-165,-210,0,175,290,0,175,-210,0);
Poly^.Add(-165,-210,0,-165,290,0,175,290,0);
Poly^.Add(-175,-210,0,-165,-210,0,-165,280,0);
Poly^.Add(-175,-210,0,-165,280,0,-175,280,0);
Poly^.Add(-85,-210,0,-85,-230,0,165,-210,0);
Poly^.Add(-85,-230,0,165,-230,0,165,-210,0);
Inc(AP);
SetActivePage(1);
{SetVisualPage(0);
{SetPage(AP,VP);}
repeat
repeat

{SetActivePage(AP);}
SetVisualPage(VP);
SetVisPage(VP);

SetBKColor(0);{}
{SetPage(AP,VP);}
{ClearViewPort;}
Retrase;
ClearDevice;
{Str(Wind^.Angle.Left:3:0,TSt);
OutTextXY(0,0,'AngleL=3werweqrkl');
Str(Wind^.Angle.Top:3:0,TSt);
OutTextXY(0,20,'AngleT='+TSt);}
circle(Round(Wind^.LOffset),Round(Wind^.TOffset),4);
Wind^.D2dDraw(Poly);
If (Wind^.Angle.Left<1) Then
   Wind^.Angle.Left:=359+Wind^.Angle.Left
   Else
   Wind^.Angle.Left:=Wind^.Angle.Left-1;{}
{If (Wind^.Angle.Top<1) Then
   Wind^.Angle.Top:=359+Wind^.Angle.Top
   Else
   Wind^.Angle.Top:=Wind^.Angle.Top-1;{}
AP:=AP xor 1;
VP:=VP xor 1;
until (keypressed);
Ch:=ReadKey;
Case Ch Of
#0: Begin
    Ch:=ReadKey;
     Case Ch of
     'H':Wind^.Angle.Top:=Wind^.Angle.Top+1;
     'P':Wind^.Angle.Top:=Wind^.Angle.Top-1;
     'K':Wind^.Angle.Left:=Wind^.Angle.Left+1;
     'M':Wind^.Angle.Left:=Wind^.Angle.Left-1;
     End;
    Ch:=#0;
    End;
'+':Wind^.Zoom:=Wind^.Zoom+0.1;
'-':Wind^.Zoom:=Wind^.Zoom-0.1;
'8':Wind^.TOffset:=Wind^.TOffset+1;
'2':Wind^.TOffset:=Wind^.TOffset-1;
'6':Wind^.LOffset:=Wind^.LOffset-1;
'4':Wind^.LOffset:=Wind^.LOffset+1;
End;
until Ch=#27;
CloseGraph;
Dispose(Wind);
Dispose(Poly,Done);
End.