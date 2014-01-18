{$A+,B-,D+,E-,F-,G+,I+,L+,N+,O-,P-,Q+,R+,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}
Uses DBase;

Function CutStr(InStr:String):String;
Var T:Word;
    Search:Boolean;
Begin
Search:=True;
For T:=Length(InStr) DownTo 1 Do
    If ((InStr[T]=#32)And(Search)) Then
    Dec(InStr[0]) Else Search:=False;
CutStr:=InStr;
End;

Var Kn,Fi:PDBase;
    Temp:Word;
    TST:String[10];
    Lop:Word;
    Err:Word;
    File1:File;

    Header:Record
     Head1:Char;
     Head2:Char;
     Podat:Word;
     Konta:Word;
     Firm:Word;
    End;

    Podato:Record
    Status:Byte;
    Nalog:Word;
    Ime:String[18];
    Konto:Longint;
    Day:Byte;
    Month:Byte;
    Year:Word;
    Vlez:Extended;
    Izlez:Extended;
    End;

    Firmi:Record
    Konto:Word;
    Ime:String[30];
    End;
Begin
If (ParamCount=0) Then
   Begin
   WriteLn('Usage dbf2kni *.knw');
   halt;
   End;
New(Kn,Init('knigo.dbf'));
New(Fi,Init('firmi.dbf'));
Assign(File1,ParamStr(1));
Rewrite(File1,1);
Header.Head1:='b';
Header.Head2:='b';
Header.Podat:=Kn^.RecCount;
Header.Konta:=0;
Header.Firm:=Fi^.RecCount;
BlockWrite(File1,Header,SizeOf(Header));
if (Kn^.RecCount>0) Then
   Begin
   Podato.Nalog:=0;
   For Lop:=1 to Kn^.RecCount Do
       Begin
       Kn^.GetDbRec(Lop);
       If(copy(Kn^.MyFieldData(2),1,5)='i.br.')Then
           Begin
           TST:=copy(Kn^.MyFieldData(2),6,3);
           if(TST[3]=' ')Then
                Begin
                Dec(TST[0]);
                If(TST[2]=' ')Then Dec(TST[0]);
                End;
           Val(TST,Temp,Err);
           If(Podato.Nalog+1<>Temp)Then
                WriteLn('Namsto ''i.br.',Podato.Nalog+1,''' ,e dobieno ''i.br.',Temp,'''.');
           TST:=Kn^.MyFieldData(2);
           Podato.Nalog:=Temp;
           End;
        asm
        push ds
        pop es
        mov di,offset Podato.Ime
        mov cx,19
        mov al,0
        rep
        stosb
        end;
       Podato.Ime:=CutStr(Kn^.MyFieldData(2));
       Val(Kn^.MyFieldData(3),Podato.Konto,Err);
       If (Err>0) Then Halt(1);
       Val(copy(Kn^.MyFieldData(4),1,2),Podato.Day,Err);
       If (Err>0) Then Halt(2);
       Val(copy(Kn^.MyFieldData(4),4,2),Podato.Month,Err);
       If (Err>0) Then Halt(3);
       Val(copy(Kn^.MyFieldData(4),7,2),Podato.Year,Err);
       Podato.Year:=Podato.Year+1900;
       If (Err>0) Then Halt(4);
       Val(Kn^.MyFieldData(5),Podato.Vlez,Err);
       Val(Kn^.MyFieldData(6),Podato.Izlez,Err);
       BlockWrite(File1,Podato,SizeOf(Podato));
       End;
   End;

if (Fi^.RecCount>0) Then
   Begin
   For Lop:=1 to Fi^.RecCount Do
       Begin
       Fi^.GetDbRec(Lop);
       Val(Fi^.MyFieldData(1),Firmi.Konto,Err);
       If (Err>0) Then Halt(11);
       Firmi.Ime:=CutStr(Fi^.MyFieldData(2));
       BlockWrite(File1,Firmi,SizeOf(Firmi));
       End;
   End;
Close(File1);
WriteLn('Ok..');
Dispose(Fi);
Dispose(Kn);
End.