{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T+,V-,X+,Y+}
{$M 16384,0,655360}
Type FileMem=Array [0..1024] of byte;
Var F:File;
    T1,T2:FileMem;
    Lop:Word;
    TPos:LongInt;
Begin
Assign(F,ParamStr(1));
Reset(F,1);
WriteLn('Golemina na fajl-ot :',ParamStr(1),' e ',FileSize(F));
Write('Vnesi vrednost na pocetna pozicija na sporedba:');
ReadLn(TPos);
Seek(F,TPos);
BlockRead(F,T1,1024);
Seek(F,0);
BlockRead(F,T2,1024);
Seek(F,TPos);
BlockRead(F,T2,1024);
For Lop:=1 to 1024 do
    Begin
    If(T1[Lop]<>T2[Lop]) Then
           WriteLn('Najdeno e razlicno citanje.');
{           else
           WriteLn('Nema razlicno citanje.');}
    End;
Close(F);
End.