Uses Dbase,Xmsdbase,Xms,WatchXms;
Var DB,Select:PXmsDBase;
         T,T2,Pos:LongInt;
         Err,N:Integer;
         TSt:String;
         OutFile:Text;
Label OK;
Begin
New(DB,Init('katmp3.dbf'));
New(Select,Init('lale.dbf'));
Assign(OutFile,'katalog.txt');
ReWrite(OutFile);
For T:=1 To Select^.RecCount Do
        Begin
        Inc(N);
        Select^.GetDBRec(T);
        TSt:=Select^.MyFieldData(1);
        For T2:=1 To DB^.RecCount Do
                Begin
                DB^.GetDBRec(T2);
                If (TSt=DB^.MyFieldData(1))Then
                        Goto Ok;
                End;
        WriteLn('Can''t find the file..');
        Halt(3);
        Ok:
        WriteLn(OutFile,DB^.MyFieldData(3):5,'³',DB^.MyFieldData(4):5,'³',DB^.MyFieldData(5));
        Write('Record ',T,' of ',Select^.RecCount,#13);
        End;
WriteLn;
Close(OutFile);
Dispose(Select,Done);
Dispose(DB,Done);
End.