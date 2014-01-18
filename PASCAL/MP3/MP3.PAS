Uses Crt;
Type
    PMemVar = ^MemVar;
    MemVar = Object
    Prev,Next : PMemVar;
    Golemina : LongInt;{Za Record-ot}
    Izveduvach : String[50];
    Album : String[50];
    Pesna : String[100];
    Constructor Init(Gol:LongInt;Izv : String;Alb : String;Pes : String);
    End;

    PMemArray = ^MemArray;
    MemArray = Object
    MemItem,First,Last : PMemVar;

    private
    Position : LongInt;
    Count : LongInt;
    Constructor Init;
    Destructor Done;
    Procedure Append(Golemina:LongInt;Izveduvach : String;Album : String;Pesna : String);
    Procedure GetItem(Pos:LongInt);
    End;

Constructor MemVar.Init(Gol:LongInt;Izv : String;Alb : String;Pes : String);
Begin
Golemina:=Gol;
Izveduvach:=Izv;
Album:=Alb;
Pesna:=Pes;
End;

Constructor MemArray.Init;
Begin
FillChar(Self,SizeOf(Self),0);
End;

Destructor MemArray.Done;
Var T:LongInt;
    PT:PMemVar;
Begin
If (Count>0)Then
   Begin
   GetItem(1);
   For T:= 1 To Count Do
       Begin
       PT:=MemItem^.Next;
       Dispose(MemItem);
       MemItem:=PT;
       End;
   End;
End;

Procedure MemArray.Append(Golemina:LongInt;Izveduvach : String;Album : String;Pesna : String);
Var T:LongInt;
    PT:PMemVar;
Begin
T:=Position;
GetItem(Count);
New(PT,Init(Golemina,Izveduvach,Album,Pesna));
MemItem^.Next:=PT;
PT^.Prev:=MemItem;
GetItem(T);
End;

Procedure MemArray.GetItem(Pos:LongInt);
Var T,TL:LongInt;
Label Kraj;
Begin
If(Pos=Position) Then Goto Kraj;
If(Pos>Count) Then
    Halt;
TL:=Pos-Position;
If(TL<0)Then
    Begin
    TL:=Abs(TL);
    For T:=1 To TL Do
        MemItem:=MemItem^.Prev;
    End
    Else
    Begin
    TL:=Abs(TL);
    For T:=1 To TL Do
        MemItem:=MemItem^.Next;
    End;
Position:=Pos;
Kraj:
End;

Procedure Load(Fil:PMemArray);
Var F:File;
Begin
Assign(F,'mp3kat.dat');
End;

Var MemArr:PMemArray;
Begin
New(MemArr,Init);
WriteLn('mem :' , MemAvail);
Load(MemArr);
//WriteLn(MemAvail);
Dispose(MemArr,Done);
//WriteLn(MemAvail);
End.
