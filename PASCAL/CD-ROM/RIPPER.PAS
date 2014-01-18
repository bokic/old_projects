{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T-,V+,X-,Y+}
{$M 16384,0,655360}
Uses Crt,CDRip;
Var CD_Buffer:PCDArray;
	 _File:File;
	 CD:^CD_Rip;
	 T,N:LongInt;
	 Err:Integer;
Begin
New(CD_Buffer);
FillChar(CD_Buffer^,SizeOf(CD_Buffer^),0);
If (ParamCount=1) Then
	Begin
	Val(ParamStr(1),T,Err);
	New(CD,Init(CD_Buffer,T));
   End
	Else
	New(CD,Init(CD_Buffer,0));
Assign(_File,'RIPPER.RAW');
ReWrite(_File,1);
BlockWrite(_File,CD_Buffer^,SizeOf(CD_Buffer^));
repeat
CD^.Next;
BlockWrite(_File,CD_Buffer^,SizeOf(CD_Buffer^));
Inc(N);
Write(N,#13);
Until (keypressed);
Close(_File);
End.