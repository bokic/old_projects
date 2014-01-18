{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T+,V-,X+,Y+}
{$M 16384,0,655360}
Uses DBase;
Procedure CutStr(Var Str:String);
Var T:Word;
Label Pola,PKraj;
Begin
If (Length(Str)>0) Then
   For T:=Length(Str) DownTo 1 Do
       Begin
       If(Str[T]<>' ') Then Goto Pola;
       Dec(Str[0]);
       End;
Pola:
If (Length(Str)>0) Then
   For T:=1 To Length(Str) Do
       Begin
       If(Str[1]<>' ') Then Goto PKraj;
       Str:=Copy(Str,2,Length(Str)-1);
       End;
PKraj:
End;

Var DBFile:PDBase;
    OutFile:File;
    Count:LongInt;
    TmpStr:String[100];
    TmpWord:Word;
    TmpLong:LongInt;
    Err:Integer;
Label Kraj;
Begin
New(DBFile,Init('c:\katalog\mp3\katmp3.dbf'));
If (DBFile^.Error<>0) Then
   Begin
   WriteLn('Error opening katmp3.dbf file, error no:',DBFile^.Error);
   Goto Kraj;
   End;
Assign(OutFile,'katmp3.dat');
ReWrite(OutFile,1);
Count:=DBFile^.RecCount;
BlockWrite(OutFile,Count,4);
Count:=0;
Repeat
Inc(Count);
DBFile^.GetDBRec(Count);
For TmpWord := 2 To 5 Do
    Begin
    TmpStr:=DBFile^.MyFieldData(TmpWord);
    TmpLong:=DBFile^.RecNo;
    CutStr(TmpStr);
    If (TmpWord=2)Then
       Begin
       Val(TmpStr,TmpLong,Err);
       If(Err<>0) Then
            Begin
            WriteLn('Error in DBF file at record',DBFile^.RecNo,', can''t get a value from "',TmpStr,'" string.');
            Close(OutFile);
            goto Kraj
            End;
       BlockWrite(OutFile,TmpLong,SizeOf(TmpLong)+1);
       End
       Else
       BlockWrite(OutFile,TmpStr,Length(TmpStr)+1);
    End;
Until(DBFile^.DBEOF);
Close(OutFile);
Kraj:
Dispose(DBFile,Done);
End.