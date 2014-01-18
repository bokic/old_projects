{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T+,V-,X+,Y+}
{$M 16384,0,655360}
Label 1;
Var T:String[80];
    Dat:String[16];
    Pos:LongInt;
    F:File;
Begin
If(ParamCount<>1) Then
    Begin
    1:
    WriteLn('Usage: cutfile.exe exename.exe');
    Halt;
    End;
T:=ParamStr(1);
If(Copy(T,Ord(T[0])-3,4)<>'.exe') Then Goto 1;
Assign(F,T);
Reset(F,1);
Dat[0]:=#16;
Repeat
BlockRead(F,Dat[1],16);
If(Copy(Dat,1,5)='.file') Then
    Begin
    Seek(F,Pos);
    Truncate(F);
    End;
Pos:=Pos+16;
Until(EOF(F)=True);
Close(F);
End.