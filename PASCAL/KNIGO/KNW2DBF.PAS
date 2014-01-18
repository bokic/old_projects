{$A+,B-,D+,E-,F-,G+,I+,L+,N+,O-,P-,Q+,R+,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}
Uses DBase,Crt;

Var Kn,Fi:PDBase;
    NKn,NFi:PCreateFile;
    Temp:Word;
    TST,NSt:String[15];
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
ClrScr;
If (ParamCount=0) Then
   Begin
   WriteLn('Usage knw2dbf *.knw');
   halt;
   End;
New(NKn,Init('knigo.dbf'));
NKn^.Add('NO','N',4,0);
NKn^.Add('NAZIV','C',14,0);
NKn^.Add('KONTO','N',6,0);
NKn^.Add('DATA','D',8,0);
NKn^.Add('DAVA','N',13,2);
NKn^.Add('ZIMA','N',13,2);
NKn^.Add('SALDO','N',14,2);
Dispose(NKn,Done);

New(NFi,Init('firmi.dbf'));
NFi^.Add('NO','N',3,0);
NFi^.Add('IME','C',30,0);
Dispose(NFi,Done);

New(Kn,Init('knigo.dbf'));
New(Fi,Init('firmi.dbf'));
Assign(File1,ParamStr(1));
Reset(File1,1);
BlockRead(File1,Header,SizeOf(Header));

if (Header.Podat>0) Then
   Begin
   For Lop:=1 to Header.Podat Do
       Begin
       BlockRead(File1,Podato,SizeOf(Podato));
       Str(Lop,TSt);
       Kn^.MyReplace(1,TSt);
       Kn^.MyReplace(2,Podato.Ime);
       Str(Podato.Konto,TSt);
       Kn^.MyReplace(3,TSt);
       Str(Podato.Day:2,NSt);
       TSt:=NSt+'-';
       Str(Podato.Month:2,NSt);
       TSt:=TSt+NSt+'-';
       Str(Podato.Year:4,NSt);
       TSt:=TSt+NSt;
       Kn^.MyReplace(4,TSt);
       Str(Podato.Vlez:0:2,TSt);
       Kn^.MyReplace(5,TSt);
       Str(Podato.Izlez:0:2,TSt);
       Kn^.MyReplace(6,TSt);
       Str(Podato.Vlez-Podato.Izlez:0:2,TSt);
       Kn^.MyReplace(7,TSt);
       Kn^.AppendBlank;
       End;
   End;

if (Fi^.RecCount>0) Then
   Begin
   For Lop:=1 to Fi^.RecCount Do
       Begin
       End;
   End;
Close(File1);
WriteLn('Ok..');
Dispose(Fi);
Dispose(Kn);
End.