Uses Crt,DBase,XMSDBase,Graph;
Const Top:Word=1;
var
   grDriver: Integer;
   grMode: Integer;
   ErrCode: Integer;
   Knigo:PXMSDBase;
   T:Integer;
   Ch:Char;
Begin
New(Knigo, Init('knigo.dbf'));
grDriver := Detect;
InitGraph(grDriver, grMode,' ');
For T:=0 to 47 do
    Line(0, T*10, 639, T*10);
Line(0, 0, 0, 470);
Line(33, 0, 33, 470);
Line(147, 0, 147, 470);
Line(197, 0, 197, 470);
Line(262, 0, 262, 470);
Line(368, 0, 368, 470);
Line(474, 0, 474, 470);
OutTextXY(10,2,'RB.');
OutTextXY(70,2,'Opis');
OutTextXY(153,2,'Konto');
OutTextXY(210,2,'Datum');
OutTextXY(296,2,'Dolzi');
OutTextXY(416,2,'Pobaruva');
SetFillStyle(SolidFill,0);
Repeat
For T:=0 to 45 do
    Begin
    Knigo^.GetDBRec(Top+T);
    Bar(1,11+(T * 10),32,19+(T * 10));
{    OutTextXY(2,12+(T * 10),Knigo^.MyFieldData(1));}
    Bar(34,11+(T * 10),146,19+(T * 10));
{    OutTextXY(35,12+(T * 10),Knigo^.MyFieldData(2));}
    Bar(148,11+(T * 10),196,19+(T * 10));
{    OutTextXY(149,12+(T * 10),Knigo^.MyFieldData(3));}
    Bar(198,11+(T * 10),261,19+(T * 10));
{    OutTextXY(199,12+(T * 10),Knigo^.MyFieldData(4));}
    Bar(263,11+(T * 10),367,19+(T * 10));
{    OutTextXY(264,12+(T * 10),Knigo^.MyFieldData(5));}
    Bar(369,11+(T * 10),473,19+(T * 10));
{    OutTextXY(370,12+(T * 10),Knigo^.MyFieldData(6));}
    Bar(475,11+(T * 10),639,19+(T * 10));
    OutTextXY(476,12+(T * 10),Knigo^.MyFieldData(7));
    End;
Ch:=ReadKey;
if(Ch=#0)Then
    Begin
    Ch:=ReadKey;
    if (Ch='P') Then Inc(Top);
    if ((Ch='H')And(Top>1)) Then Dec(Top);
    End;
Until (Ch=#27);
CloseGraph;
Dispose(Knigo,Done);
End.