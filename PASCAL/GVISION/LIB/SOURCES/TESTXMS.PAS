Program TestXms;

Uses Xms,ExtObj,Crt;
Var
	S: PXMSStream;
	A : array[0..255] of byte;
	i : integer;
	Ch : Char;
Begin
If (Not Xms_Init) Then Exit;
writeln( xms_MaxAvail, ' ', xms_MemAvail );
S := New(PXmsStream,Init(0));
If (S = Nil) Then exit;
For i := 1 To 20 Do
	Begin
	FillChar(A,i,char(i+$20));
	S^.Write(A,i);
	End;
writeln(S^.GetSize);
Ch := Readkey;
S^.Seek(0);
For i := 1 To 20 Do
	begin
	Writeln(S^.GetPos);
	S^.Read(A,i);
	End;
Ch := Readkey;
Dispose(S,Done);
End.
