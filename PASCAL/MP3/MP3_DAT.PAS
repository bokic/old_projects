Uses DBase;

Function Capital(From:String):String;
Var T:Byte;
Begin
If (From[0]>#1)Then
   For T:=2 To Ord(From[0]) Do
       If ((From[T]>='A')And(From[T]<='Z')) Then
          From[T]:=Chr(Ord(From[T])+32);
Capital:=From;
End;

Function CutStr(From:String):String;
Var
   Left,Right:Boolean;
Begin
Repeat
Left:=False;Right:=False;
If (From[0]>#0)Then
   If (From[1]=#32) Then
      Begin
      From:=Copy(From,2,Length(From)-1);
      Left:=True;
      End;
If (From[0]>#0)Then
   If (From[Ord(From[0])]=#32) Then
      Begin
      Dec(From[0]);
      Right:=True;
      End;
Until ((Left=False)And(Right=False));
{CutStr:=From;{}
CutStr:=Capital(From);{}
End;

Var DB:^_DBase;
    T,Long:LongInt;
    Out:File;
    St:String;
    Err:Integer;
    Result:Word;
Begin
New(DB,Init('katmp3.dbf'));
Assign(Out,'katmp3.dat');
ReWrite(Out,1);
Long:=DB^.RecCount;
BlockWrite(Out,Long,4,Result);
For T:=1 To DB^.RecCount Do
    Begin
    DB^.GetDBRec(T);
    Val(CutStr(DB^.MyFieldData(2)),Long,Err);
    BlockWrite(Out,Long,4);
    St:=CutStr(DB^.MyFieldData(3));
    BlockWrite(Out,St,Length(St)+1);
    St:=CutStr(DB^.MyFieldData(4));
    BlockWrite(Out,St,Length(St)+1);
    St:=CutStr(DB^.MyFieldData(5));
    BlockWrite(Out,St,Length(St)+1);
    Write(T,#13);
    End;
Close(Out);
Dispose(DB,Done);
End.