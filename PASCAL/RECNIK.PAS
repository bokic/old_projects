Uses Crt,DBase;
var
    Recnik:PDBase;
    IsEnd:Boolean;

Function Convert(New:String):String;
Var Count:Byte;
Begin
Convert[0]:=New[0];
If (New[0]>#0) Then
   For Count:=1 to Ord(New[0]) Do
       If (New[Count]=#32) Then
          Convert[Count]:=#32
          else
          Convert[Count]:=Chr(Ord(New[Count]) - 114);
End;

Begin
New(Recnik,Init('rec.dbf'));
WriteLn('ษอออออออออออออออหอออออออออออออออป' );
Repeat
Recnik^.MyReplace(1,Convert(Recnik^.MyFieldData(1)));
Recnik^.MyReplace(2,Convert(Recnik^.MyFieldData(2)));
Recnik^.Save;
WriteLn('บ'+Recnik^.MyFieldData(1)+'บ'+Recnik^.MyFieldData(2)+'บ');
IsEnd:=Recnik^.DBEOF;
If (IsEnd=False) Then Recnik^.NextRec;
Until ((IsEnd)or(keypressed));
WriteLn('ศอออออออออออออออสอออออออออออออออผ' );
Dispose(Recnik,Done);
End.