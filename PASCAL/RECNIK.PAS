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
WriteLn('浜様様様様様様様僕様様様様様様様�' );
Repeat
Recnik^.MyReplace(1,Convert(Recnik^.MyFieldData(1)));
Recnik^.MyReplace(2,Convert(Recnik^.MyFieldData(2)));
Recnik^.Save;
WriteLn('�'+Recnik^.MyFieldData(1)+'�'+Recnik^.MyFieldData(2)+'�');
IsEnd:=Recnik^.DBEOF;
If (IsEnd=False) Then Recnik^.NextRec;
Until ((IsEnd)or(keypressed));
WriteLn('藩様様様様様様様瞥様様様様様様様�' );
Dispose(Recnik,Done);
End.