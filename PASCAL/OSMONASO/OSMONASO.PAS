{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T+,V-,X+,Y+}
{$M 16384,0,655360}

{
 Gj Dzj Dz  Lj  Nj  Kj  Ch  Dhj Sh
 1   2   3   4   5   6   7   8   9
}
Program Osmonasocnik;
Uses Crt;

Const tabela_g: array[1..31,0..15] of byte =(
($00,$00,$10,$38,$6C,$C6,$C6,$FE,$C6,$C6,$C6,$C6,$00,$00,$00,$00),
($00,$00,$FE,$66,$62,$60,$7C,$66,$66,$66,$66,$FC,$00,$00,$00,$00),
($00,$00,$FC,$66,$66,$66,$7C,$66,$66,$66,$66,$FC,$00,$00,$00,$00),
($00,$00,$FE,$66,$62,$60,$60,$60,$60,$60,$60,$F0,$00,$00,$00,$00),
($00,$00,$3E,$66,$66,$66,$66,$66,$66,$66,$66,$FF,$C3,$C3,$00,$00),
($18,$10,$FE,$66,$62,$60,$60,$60,$60,$60,$60,$F0,$00,$00,$00,$00),
($00,$00,$FE,$66,$62,$68,$78,$68,$60,$62,$66,$FE,$00,$00,$00,$00),
($00,$00,$DB,$DB,$DB,$7E,$3C,$3C,$7E,$DB,$DB,$DB,$00,$00,$00,$00),
($00,$00,$7C,$C6,$06,$06,$3C,$06,$06,$06,$C6,$7C,$00,$00,$00,$00),
($00,$00,$7C,$C6,$C6,$60,$38,$0C,$06,$C6,$C6,$7C,$00,$00,$00,$00),
($00,$00,$C6,$C6,$C6,$CE,$DE,$FE,$F6,$E6,$C6,$C6,$00,$00,$00,$00),
($00,$00,$1E,$0C,$0C,$0C,$0C,$0C,$CC,$CC,$CC,$78,$00,$00,$00,$00),
($00,$00,$E6,$66,$66,$6C,$78,$78,$6C,$66,$66,$E6,$00,$00,$00,$00),
($00,$00,$3E,$66,$66,$66,$66,$66,$66,$66,$66,$C6,$00,$00,$00,$00),
($00,$00,$78,$D8,$D8,$D8,$DE,$DB,$DB,$DB,$DB,$DE,$00,$00,$00,$00),
($00,$00,$C3,$E7,$FF,$FF,$DB,$C3,$C3,$C3,$C3,$C3,$00,$00,$00,$00),
($00,$00,$C6,$C6,$C6,$C6,$FE,$C6,$C6,$C6,$C6,$C6,$00,$00,$00,$00),
($00,$00,$D8,$D8,$D8,$D8,$FE,$DB,$DB,$DB,$DB,$DE,$00,$00,$00,$00),
($00,$00,$7C,$C6,$C6,$C6,$C6,$C6,$C6,$C6,$C6,$7C,$00,$00,$00,$00),
($00,$00,$FE,$C6,$C6,$C6,$C6,$C6,$C6,$C6,$C6,$C6,$00,$00,$00,$00),
($00,$00,$FC,$66,$66,$66,$7C,$60,$60,$60,$60,$F0,$00,$00,$00,$00),
($00,$00,$3C,$66,$C2,$C0,$C0,$C0,$C0,$C2,$66,$3C,$00,$00,$00,$00),
($00,$00,$FF,$DB,$99,$18,$18,$18,$18,$18,$18,$3C,$00,$00,$00,$00),
($18,$10,$E6,$66,$66,$6C,$78,$78,$6C,$66,$66,$E6,$00,$00,$00,$00),
($00,$00,$C6,$C6,$C6,$C6,$C6,$C6,$7E,$06,$C6,$7C,$00,$00,$00,$00),
($00,$3C,$18,$7E,$DB,$DB,$DB,$DB,$DB,$DB,$7E,$18,$3C,$00,$00,$00),
($00,$00,$C3,$C3,$66,$3C,$18,$18,$3C,$66,$C3,$C3,$00,$00,$00,$00),
($00,$00,$C6,$C6,$C6,$C6,$C6,$C6,$C6,$C6,$C6,$FF,$03,$03,$00,$00),
($00,$00,$C6,$C6,$C6,$C6,$C6,$7E,$06,$06,$06,$0F,$00,$00,$00,$00),
($00,$00,$C6,$C6,$C6,$C6,$C6,$C6,$C6,$C6,$C6,$FE,$18,$18,$00,$00),
($00,$00,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$FE,$00,$00,$00,$00));

const MaxX=30;
      MaxY=25;
      Top:Byte=1;
      XPos:Byte=1;
      YPos:Byte=1;
      WPos:Byte=1;

Var Polinja:Array[1..MaxX,1..MaxY] of Char;
    Iminja:Array[1..70] of String[20];
    PolinjaRes:Array[1..MaxX,1..MaxY] of Boolean;

Procedure ReDraw;
Var T:Byte;
Begin
ClrScr;
Asm
mov bh,16
mov bl,0
mov cx,31
mov dx,128
push ds
pop es
push bp
mov bp,offset ds:tabela_g
mov ax,$1110
int $10
pop bp
End;
GotoXY(3,1);
WriteLn('имямямямямямямямямямямямямямямямямямямямямямямямямямямямямям╩');
For T:=1 to 10 Do
    Begin
    GotoXY(3,T+1);
    WriteLn('╨ Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё Ё ╨');
    End;
GotoXY(3,12);
WriteLn('хмомомомомомомомомомомомомомомомомомомомомомомомомомомомомом╪');
For T:=1 to 70 Do Iminja[T]:='                    ';
End;

Procedure UpDate;
Var T1,T2:Byte;
    TS:String[2];
Begin
For T1:=1 To 10 Do
    Begin
    Str(Top+T1-1:2,TS);
    TextAttr:=$07;
    GotoXY(1,T1+1);Write(TS);
    For T2:=1 To MaxX Do
        Begin
        GotoXY(T2*2+2,T1+1);
        If(PolinjaRes[T2,T1+Top-1]=False) Then TextAttr:=$07 Else TextAttr:=$0F;
        Write(Polinja[T2,T1+Top-1]);
        End
    End;
GotoXY(70,3);Write('Top:',Top,' ');
GotoXY(70,4);Write('XPos:',XPos,' ');
GotoXY(70,5);Write('YPos:',YPos,' ');
TextAttr:=$07;
GotoXY(XPos*2+2,YPos+1);
End;

Function Change(Ch:Char):Char;
Begin
 Ch:=UpCase(Ch);
 Case Ch of
      #65:{A}Ch:=#128;
      #66:{B}Ch:=#129;
      #67:{C}Ch:=#155;
      #68:{D}Ch:=#132;
      #69:{E}Ch:=#134;
      #70:{F}Ch:=#153;
      #71:{G}Ch:=#131;
      #72:{H}Ch:=#154;
      #73:{I}Ch:=#138;
      #74:{J}Ch:=#139;
      #75:{K}Ch:=#140;
      #76:{L}Ch:=#141;
      #77:{M}Ch:=#143;
      #78:{N}Ch:=#144;
      #79:{O}Ch:=#146;
      #80:{P}Ch:=#147;
      #81:{Q}Ch:=#142;
      #82:{R}Ch:=#148;
      #83:{S}Ch:=#149;
      #84:{T}Ch:=#150;
      #85:{U}Ch:=#152;
      #86:{V}Ch:=#130;
      #87:{W}Ch:=#145;
      #88:{X}Ch:=#157;
      #89:{Y}Ch:=#137;
      #64:{@}Ch:=#135;
      #90:{Z}Ch:=#136;
      #91:{[}Ch:=#151;
      #93:{]}Ch:=#158;
      #96:{`}Ch:=#156;
      #92:{\}Ch:=#133;
 end;
Change:=Ch;
End;

Function edit_text(var Stri:string;x,y:byte;Kirilica:Boolean):Shortint;
Label Lop,Kraj;
Var pos,len,sx,sy:byte;
    ins:boolean;
    ch:char;
Begin
len:=Length(Stri);
ins:=True;
pos:=1;
textbackground(1);
Lop:
gotoxy(x,y);
write(Stri);
gotoxy(x+pos-1,y);
If (Kirilica) Then
   Ch:=Change(readkey)
   Else
   Ch:=readkey;
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
textbackground(0);
 asm
 mov cx,$0D0E
 mov ah,1
 int $10
 end;
end;

Procedure F2;
Var TB:ShortInt;
    TSt:String[20];
    T,TX,TY,Go_Ima:Byte;
    NX,NY:ShortInt;
    Is_There:Boolean;
Label KrP1;
Begin
Repeat
GotoXY(9,15);Write(WPos:2);
TextAttr:=$17;
TB:=Edit_Text(Iminja[WPos],11,15,True);
TextAttr:=$7;
If (TB<>10) Then
   Begin
    Case TB Of
         1  : If(WPos<70)Then Inc(WPos);

         0  : Begin
              TSt:=Iminja[WPos];
              While (Tst[length(TSt)]=#32) do Dec(TSt[0]);
              If (TSt[0]=#0) Then Exit;
              For T:=1 to Ord(TSt[0]) Do TSt[T]:=UpCase(TSt[T]);
              Go_Ima:=0;
              For TY:=1 to MaxY Do
                  For TX:=1 to MaxX Do
                      For NY:=-1 to 1 Do
                          For NX:=-1 to 1 Do
                              IF((TX+(Ord(TSt[0])*NX)>=0)And(TX+(Ord(TSt[0])*NX)<=MaxX+1)
                              And(TY+(Ord(TSt[0])*NY)>=0)And(TY+(Ord(TSt[0])*NY)<=MaxY+1)) Then
                                   Begin
                                   If ((Nx=0)And(Ny=0)) Then
                                      Goto KrP1;
                                   Is_There:=True;
                                   For T:=0 To Ord(TSt[0])-1 Do
                                       Begin
                                       If(Polinja[TX+(NX*T),TY+(NY*T)]<>TST[T+1]) Then Is_There:=False;
                                       End;
                                   If (Is_There) Then
                                      Begin
                                      For T:=0 To Ord(TSt[0])-1 Do
                                          Begin
                                          PolinjaRes[TX+(NX*T),TY+(NY*T)]:=True;
                                          End;
                                      If(NY=-1) Then
                                                Top:=TY-Ord(TSt[0])+1
                                                Else
                                                Top:=TY;
                                      If (Top>16) Then Top:=16;
                                      UpDate;
                                      If(ReadKey=#0) Then ReadKey;
                                      End;
                                   KrP1:
                                   End;
              End;

        -1  : If(WPos>1)Then Dec(WPos);
    End;
   End;
Until (TB=10);
Window(9,15,30,15);
Clrscr;
Window(1,1,80,25);
End;

Procedure Load;
Var L:File;
    Sr:String[8];
    TB:ShortInt;
Label Kr;
Begin
GotoXY(60,20);Write('Ime na fajlot?');
Sr:='        ';
Repeat
Repeat
TB:=Edit_Text(Sr,60,21,False);
If (TB=10) Then Goto Kr;
Until (TB=0);
While (Sr[Ord(Sr[0])]=#32) Do
      Dec(Sr[0]);
Assign(L,Sr+'.osm');
{$I-}
Reset(L,1);
Until (IOResult=0);
{$I+}
BlockRead(L,Polinja,1050{SizeOf(Polinja)+SizeOf(Iminja)}{1050});
Close(L);
Kr:
Window(60, 20, 80, 22);
ClrScr;
Window(1, 1, 80, 25);
End;

Procedure Save;
Var L:File;
    Sr:String[8];
    TB:ShortInt;
Label Kr;
Begin
GotoXY(60,20);Write('Ime na fajlot?');
Sr:='        ';
Repeat
TB:=Edit_Text(Sr,60,21,False);
If (TB=10) Then Goto Kr;
until (TB=0);
Assign(L,Sr+'.osm');
{$I-}
ReWrite(L,1);
{$I+}
BlockWrite(L,Polinja,SizeOf(Polinja)+SizeOf(Iminja));
Close(L);
Kr:
Window(60, 20, 80, 22);
ClrScr;
Window(1, 1, 80, 25);
End;

Var Ch:Char;
Begin
TextAttr:=7;
ReDraw;
UpDate;

Repeat
Ch:=Change(UpCase(ReadKey));
If (Ch=#0) Then
   Begin
   Ch:=ReadKey;
   Case Ch Of
        '<':F2; {F2}

        #31:Save; {Save}

        '&':Load; {Load}

        'M':If (Xpos<MaxX) Then Inc(XPos);{Desno}
        'K':If (Xpos>1) Then Dec(XPos);{Levo}
        'H':If ((Ypos>1)or(Top>1)) Then {Gore}
               Begin
               If (YPos=1) Then Dec(Top)
                           Else Dec(YPos);
               End;
        'P':If (Top<16) Then {Dole}
               Begin
               If (YPos<10) Then Inc(YPos)
                              Else Inc(Top);
               End;

   end;
   UpDate;
   Ch:=#0;
   End;
If ((Ch>=#128)And(Ch<=#160)or(Ch='`')or(Ch=' ')) Then
   Begin
   If (Ch=' ') Then Polinja[XPos,Top+YPos-1]:=#0
      Else
      Change(Ch);
      Polinja[XPos,Top+YPos-1]:=Ch;
   If (XPos=MaxX) Then
      Begin
      If (Top+YPos-1<MaxY) Then
         Begin
         If (YPos=10) Then
            Inc(Top)
            Else
            Inc(YPos);
         XPos:=1;
         End;
      End
      Else Inc(XPos);
   UpDate;
   End;
Until (Ch=#27)
End.