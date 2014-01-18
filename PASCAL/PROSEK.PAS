{$A-,B-,D+,E+,F-,G+,I+,L+,N+,O-,P-,Q+,R+,S-,T-,V-,X+,Y+}
{$M 16384,0,655360}

Program Prosek;
Uses Crt;

Type
    PPredmet=^TPredmet;
    TPredmet =object
     Ime:String[10];
     Ocenka:Byte;
     end;

    PPredmeti=^TPredmeti;
    TPredmeti=object
     XPos,YPos:Byte;
     public
     NoPred:Byte;
     Predmet:array [1..20] of PPRedmet;
     Constructor Init(_Predmet:Byte);
     Destructor Done;
     Procedure Run;
     Function ZemiPozicija(X,Y:Byte):Shortint;
     end;

function edit_text(var Stri:string;x,y:byte):Shortint;
label Lop,Kraj;
var pos,len,sx,sy:byte;
    ins:boolean;
    ch:char;
begin
len:=length(Stri);
ins:=True;
pos:=1;
textbackground(0);
Lop:
gotoxy(x,y);
write(Stri);
gotoxy(x+pos-1,y);
ch:=readkey;
if (ch=#27) then
   begin
   edit_text:=10;
   goto Kraj;
   end;
if (ch=#8) then
   begin
   if (pos<2) then goto Lop;
   Stri:=copy(Stri,1,pos-2)+copy(Stri,pos,len-pos+1)+ ' ';
      pos:=pos-1;
   goto Lop;
   end;
if (ch=#13) then
   begin
   edit_text:=0;
   goto Kraj;
   end;
if (ch>#31) then
   begin
   if (ins) then
   Stri:=copy(Stri,1,pos-1)+ch+copy(Stri,pos,len-pos)
   else
   Stri:=copy(Stri,1,pos-1)+ch+copy(Stri,pos+1,len-pos+1);
   if (pos<len) then pos:=pos+1;
   goto Lop;
   end;
if (ch=#0) then
   begin
   ch:=readkey;
   if ch='H' then {Gore}
      begin
      edit_text:=-1;
      goto Kraj;
      end;
   if ch='P' then {Dole}
      begin
      edit_text:=1;
      goto Kraj;
      end;
   if ch='K' then {Levo}
      begin
      if (pos>1) then pos:=pos-1;
      goto Lop;
      end;
   if ch='M' then {Desno}
      begin
      if (pos<len) then
         begin
         pos:=pos+1;
         goto Lop;
         end;
      end;
   if (ch='R') then
      begin
      if ins=False then ins:=true else ins:=false;
      asm
      mov al,ins
      cmp al,0
      jne @1
      mov cx,$0F02
      mov ah,1
      int $10
      jmp  @Kraj
      @1:
      mov cx,$0D0E
      mov ah,1
      int $10
      @Kraj:
      end;
      goto Lop;
      end;
   if ch='S' then {Delete}
      begin
      if (pos>len) then goto Lop;
      Stri:=copy(Stri,1,pos-1)+copy(Stri,pos+1,len-pos)+ ' ';
      goto Lop;
      end;
   end;
goto Lop;
Kraj:
textbackground(1);
asm
 mov cx,$0D0E
 mov ah,1
 int $10
end;
end;

function edit_normal(var t1:longint;x,y,len:byte):Shortint;
label Lop,Kraj,Temp;
var t,pos:byte;
    Stri:string[6];
    ch:char;
    err:word;
    count:byte;
begin
textbackground(0);
count:=0;
str(t1,Stri);
if (length(Stri)<len) then
   begin
   Temp:
   Stri:=' '+Stri;
   if length(Stri)<len then goto temp;
   end;
for t:=1 to len do
    if (Stri[t]=' ') then count:=count+1;
if (count<>0) then
   Stri:=copy(Stri,count+1,len-count)+copy(Stri,1,count);
pos:=len-count+1;
if (pos>len) then pos:=Len;
Lop:
gotoxy(x,y);
write(Stri);
gotoxy(x+pos-1,y);
ch:=readkey;
if (ch=#27) then
   begin
   edit_normal:=10;
   goto Kraj;
   end;
if (ch=#8) then { Back space }
   begin
   if (pos<2) then goto Lop;
   If ((pos=2)And(Count=Len-1)) then
      Begin
      If (Copy(Stri,1,1)<>'0') Then Stri[1]:='0';
      Goto Lop;
      End;
   Stri:=copy(Stri,1,pos-2)+copy(Stri,pos,len-pos+1)+ ' ';
   pos:=pos-1;
   count:=count+1;
   goto Lop;
   end;
if ((ord(ch)>=ord('0'))and(ord(ch)<=ord('9'))) then
   begin
   if ((ch='0')and(pos=1)) then goto Lop;
   if ((Stri[1]='0')and(pos<=2)) then
      begin
      if (ch='0') then goto Lop;
      Stri:=ch+copy(Stri,2,len-1);
      If (Len>1) Then pos:=2;
      end
      else
      begin
      if Stri[len]=' ' then count:=count-1;
          Stri:=copy(Stri,1,pos-1)+ch+copy(Stri,pos,len-pos);
      if (pos<>len) then
          begin
          pos:=pos+1;
          end;
      end;
   goto Lop;
   end;
if (ch=#0) then
   begin
   ch:=readkey;
   if ch='H' then {Gore}
      begin
      edit_normal:=-1;
      goto Kraj;
      end;
   if ch='P' then {Dole}
      begin
      edit_normal:=1;
      goto Kraj;
      end;
   if ch='K' then {Levo}
      begin
      if (pos>1) then
         begin
         pos:=pos-1;
         goto Lop;
         end;
      goto Lop;
      end;
   if ch='M' then {Desno}
      begin
      if (pos<len-count+1) then
         begin
         if pos=len then goto Lop;
         pos:=pos+1;
         goto Lop;
         end;
      end;
   if ch='S' then {Delete}
      begin
      if (pos>len) then goto Lop;
      If ((Pos=1)And(len-count=1)) Then
         Begin
         Stri[1]:='0';
         Goto Lop;
         End;
      if (Stri[pos]<>' ') then count:=count+1;
      Stri:=copy(Stri,1,pos-1)+copy(Stri,pos+1,len-pos)+ ' ';
      goto Lop;
      end;
   goto Lop;
   end;
if ch=#13 then
   begin
   edit_normal:=0;
   end
   else
   goto Lop;
Kraj:
if (count>0) then
   begin
   delete(Stri,len-count+1,count);
   end;
if (Stri='') then Stri:='0';
val(Stri,t1,err);
if (err<>0) then
   begin
   writeln;
   writeln('Error no:',err);
   halt;
   end;
str(t1:len,Stri);
gotoxy(x,y);
write(Stri);
textbackground(1);
end;

Procedure cursoron;
Assembler;
Asm
 MOV ax, 0100h
 MOV cx, 090Ah
 INT 10h
End;

Procedure cursoroff;
Assembler;
Asm
 MOV ax, 0100h
 MOV cx, 1000h
 INT 10h
End;


Constructor TPredmeti.Init(_Predmet:Byte);
var Temp1:Byte;
Begin
NoPred:=_Predmet;
For Temp1:= 1 to _Predmet Do
    Begin
    New(Predmet[Temp1]);
    Predmet[Temp1]^.Ime:='           ';
    Predmet[Temp1]^.Ocenka:=0;
    End;
XPos:=1;YPos:=1;
End;

Destructor TPredmeti.Done;
var Temp1:Byte;
Begin
For Temp1:= 1 to NoPred Do Dispose(Predmet[Temp1]);
End;

Procedure TPredmeti.Run;
var Temp1,Temp2:byte;
    RTemp:Real;
    Izlez:Boolean;
    Stri:String[10];
Begin
clrscr;
Gotoxy(28,2);Write('ษออออออออออัออออออออป');
Gotoxy(28,3);Write('บ Predmet  ณ Ocenka บ');
Gotoxy(28,4);Write('วฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤถ');
For Temp1:=1 To NoPred Do
    Begin
    Gotoxy(28,4+Temp1);Write('บ          ณ0       บ');
    End;
Gotoxy(28,Temp1+5);Write('ฬออออออออัอฯออออออออน');
Gotoxy(28,Temp1+6);Write('บ Prosek ณ0         บ');
Gotoxy(28,Temp1+7);Write('ศออออออออฯออออออออออผ');
Izlez:=False;
Repeat
Case ZemiPozicija(XPos,YPos)of
 -1:Begin
    If ((XPos>1)or(YPos>1))Then
       Begin
       If (XPos=2) Then XPos:=1 Else
          Begin
          XPos:=2;Dec(YPos);
          End;
       End;
    End;
 0..1:
    Begin
    If ((XPos=1)or(YPos<NoPred))Then
       Begin
       If (XPos=1) Then XPos:=2 Else
          Begin
          XPos:=1;Inc(YPos);
          End;
       End;
    End;
 else; Izlez:=True;
End;

Temp2:=0;RTemp:=0;
For Temp1:=1 to NoPred Do
    Begin
    If ((Predmet[Temp1]^.Ime<>'          ')And(Predmet[Temp1]^.Ocenka>0)) Then
       Begin
       Inc(Temp2);
       RTemp:=RTemp+Predmet[Temp1]^.Ocenka;
       End;
    End;
If (Temp2>0) Then RTemp:=RTemp/Temp2;
Str(RTemp:10:10,Stri);
GotoXY(38,NoPred+6);Write(Stri);
Until Izlez;
End;

Function TPredmeti.ZemiPozicija(X,Y:Byte):Shortint;
Var L:LongInt;
Begin
 Case X of
 1:Begin
   CursorOn;
   ZemiPozicija:=edit_text(Predmet[y]^.Ime,29,y+4);
   CursorOff;
   End;
 2:
   Begin
   Repeat
   CursorOn;
   L:=Predmet[y]^.Ocenka;
   ZemiPozicija:=edit_Normal(L,40,y+4,1);
   CursorOff;
   Predmet[y]^.Ocenka:=L;
   Until (L < 6);
   End;
 End;
L:=TextAttr;
If ((Predmet[y]^.Ime='          ')or(Predmet[y]^.Ocenka=0)) Then TextAttr:=$17 Else TextAttr:=$1F;
GotoXY(29,y+4);Write(Predmet[y]^.Ime);
GotoXY(40,y+4);Write(Predmet[y]^.Ocenka);
TextAttr:=L;
End;

Label Kraj;
Var MainPredmeti:PPredmeti;
    Temp1:LongInt;
Begin
CursorOff;
textattr:=$17;
Repeat
ClrScr;
Gotoxy(28,2);Write('ษออออออออออออออออออออออป');
Gotoxy(28,3);Write('บ        G.U.C.        บ');
Gotoxy(28,4);Write('บ "Zdravko Cvetkovski" บ');
Gotoxy(28,5);Write('ศออออออออออออออออออออออผ');
If (ReadKey=#27) Then Goto Kraj;
ClrScr;
Gotoxy(28,2);Write('Vnesi go brojot na predmeti:');
CursorOn;
Temp1:=0;
repeat
edit_normal(Temp1,56,2,2);
until ((Temp1<19)and(Temp1>1));
CursorOff;
MainPredmeti:=New(PPredmeti,Init(Temp1));
MainPredmeti^.Run;
Dispose(MainPredmeti,Done);
Until True=False;
Kraj:
textattr:=$7;
ClrScr;
CursorOn;
End.