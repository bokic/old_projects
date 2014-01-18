{$A+,B-,D+,E+,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T-,V+,X-}
{$M 16384,0,655360}
uses Crt,Dos;
type ekran = record
     chr:byte;
     boja:byte;
     end;
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
const tabela_m: array[1..31,0..15] of byte =(
($00,$00,$00,$00,$00,$78,$0C,$7C,$CC,$CC,$CC,$76,$00,$00,$00,$00),
($00,$00,$06,$7C,$C0,$FC,$C6,$C6,$C6,$C6,$C6,$7C,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$FC,$66,$66,$7C,$66,$66,$FC,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$FE,$62,$60,$60,$60,$60,$F0,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$3E,$66,$66,$66,$66,$66,$FF,$81,$00,$00,$00),
($00,$00,$18,$10,$00,$FE,$62,$60,$60,$60,$60,$F0,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$7C,$C6,$FE,$C0,$C0,$C6,$7C,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$DB,$DB,$7E,$3C,$7E,$DB,$DB,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$7C,$C6,$06,$3C,$06,$C6,$7C,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$7C,$C6,$60,$38,$0C,$C6,$7C,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$C6,$CE,$DE,$FE,$F6,$E6,$C6,$00,$00,$00,$00),
($00,$00,$06,$06,$00,$0E,$06,$06,$06,$06,$06,$06,$66,$66,$3C,$00),
($00,$00,$00,$00,$00,$66,$66,$6C,$78,$6C,$66,$66,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$3E,$66,$66,$66,$66,$66,$C6,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$78,$D8,$D8,$DE,$DB,$DB,$DE,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$C3,$E7,$FF,$DB,$C3,$C3,$C3,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$C6,$C6,$C6,$FE,$C6,$C6,$C6,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$D8,$D8,$D8,$FE,$DB,$DB,$DE,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$7C,$C6,$C6,$C6,$C6,$C6,$7C,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$FE,$C6,$C6,$C6,$C6,$C6,$C6,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$FC,$66,$66,$66,$66,$66,$7C,$60,$60,$F0,$00),
($00,$00,$00,$00,$00,$7C,$C6,$C0,$C0,$C0,$C6,$7C,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$FF,$99,$18,$18,$18,$18,$3C,$00,$00,$00,$00),
($00,$00,$18,$10,$00,$66,$66,$6C,$78,$6C,$66,$66,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$C6,$C6,$C6,$C6,$C6,$C6,$7E,$06,$C6,$7C,$00),
($00,$00,$24,$18,$18,$7E,$DB,$DB,$DB,$DB,$DB,$7E,$18,$18,$24,$00),
($00,$00,$00,$00,$00,$C3,$66,$3C,$18,$3C,$66,$C3,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$C6,$C6,$C6,$C6,$C6,$C6,$FF,$03,$00,$00,$00),
($00,$00,$00,$00,$00,$C6,$C6,$C6,$7E,$06,$06,$06,$00,$00,$00,$00),
($00,$00,$00,$00,$00,$C6,$C6,$C6,$C6,$C6,$C6,$FE,$18,$00,$00,$00),
($00,$00,$00,$00,$00,$DB,$DB,$DB,$DB,$DB,$DB,$FF,$00,$00,$00,$00));
var Ek:array[0..24,0..79] of ekran absolute $B800:$0000 ;
    TDsk:array[1..100,0..75] of ekran;
    _ch:char;
    Real_y:byte;
    Real_Col:byte;
    datoteka:file of byte;
    tempx,tempy:byte;
    temp_read:byte;
begin
asm
 push bp
 mov bh,16
 mov bl,0
 mov cx,31
 mov dx,128
 push ds
 pop es
 mov bp,offset ds:tabela_g
 mov ax,$1110
 int $10
 mov bh,16
 mov bl,0
 mov cx,31
 mov dx,224
 push ds
 pop es
 mov bp,offset tabela_m
 mov ax,$1110
 int $10
 pop bp
end;
real_Y:=1;
Real_Col:=15;
textcolor(7);
textbackground(1);
clrscr;
write('ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·');
write('ºÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·º');
write('ºº                                                                            ºº');
write('ºº                                                                            ºº');
write('ºº                                                                            ºº');
write('ºº                                                                            ºº');
write('ºº                                                                            ºº');
write('ºº                                                                            ºº');
write('ºº                                                                            ºº');
write('ºº                                                                            ºº');
write('ºº                                                                            ºº');
write('ºº                                                                            ºº');
write('ºº                                                                            ºº');
write('ºº                                                                            ºº');
write('ºº                                                                            ºº');
write('ºº                                                                            ºº');
write('ºº                                                                            ºº');
write('ºº                                                                            ºº');
write('ºº                                                                            ºº');
write('ºº                                                                            ºº');
write('ºÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½º');
write('ºÖÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄ·º');
write('ºº           º              º           º         º          º       º        ºº');
write('Ó¶           º              º           º         º          º       º        Ç½');
write(' ÓÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄ½');
              textbackground(2);
              textcolor(15);
              gotoxy(4,23);
              write('‚ğæõøâàñæ');
              textbackground(1);
              textcolor(0);
              write('Ü');
              gotoxy(5,24);
              write('ßßßßßßßßß');
              textbackground(2);
              textcolor(15);
              gotoxy(16,23);
              write('“ôæãíæäøâàñæ');
              textbackground(1);
              textcolor(0);
              write('Ü');
              gotoxy(17,24);
              write('ßßßßßßßßßßßß');
              textbackground(2);
              textcolor(15);
              gotoxy(31,23);
              write('†äêöøâàñæ');
              textbackground(1);
              textcolor(0);
              write('Ü');
              gotoxy(32,24);
              write('ßßßßßßßßß');
              textbackground(2);
              textcolor(15);
              gotoxy(43,23);
              write('ôêşæñæ');
              textbackground(1);
              textcolor(0);
              write('Ü');
              gotoxy(44,24);
              write('ßßßßßßß');
              textbackground(2);
              textcolor(15);
              gotoxy(53,23);
              write('“æüàöæñæ');
              textbackground(1);
              textcolor(0);
              write('Ü');
              gotoxy(54,24);
              write('ßßßßßßßß');
              textbackground(2);
              textcolor(15);
              gotoxy(64,23);
              write('“òïòş');
              textbackground(1);
              textcolor(0);
              write('Ü');
              gotoxy(65,24);
              write('ßßßßß');
              textbackground(2);
              textcolor(15);
              gotoxy(72,23);
              write('Šèíæè.');
              textbackground(1);
              textcolor(0);
              write('Ü');
              gotoxy(73,24);
              write('ßßßßßß');
gotoxy(3,3);
repeat
_ch:=readkey;
if _ch=#0 then
   begin
   _ch:=readkey;

   if _ch='&' then { Load }
      begin
      if (paramcount=1) then
      Assign(datoteka,ParamStr(1))
      else
      Assign(datoteka,'knigo.hlp');
      reset(datoteka);
      for tempx:= 1 to 18
      do for tempy:=0 to 75
      do begin
         read(datoteka,temp_read);
         temp_read:=temp_read-1;
         TDsk[tempx,tempy].chr:=temp_read;
         Ek[tempx+1,tempy+2].chr:=temp_read;
         read(datoteka,temp_read);
         TDsk[tempx,tempy].boja:=temp_read;
         Ek[tempx+1,tempy+2].boja:=temp_read;
         end;
      Close(datoteka);
      _ch:=#0;
      end;
   if _ch=#31 then   { Save }
      begin
      if (paramcount=1) then
      Assign(datoteka,ParamStr(1))
      else
      Assign(datoteka,'knigo.hlp');
      Rewrite(datoteka);
      for tempx:= 1 to 18
      do for tempy:=0 to 75
      do begin
         TDsk[tempx,tempy].chr:=TDsk[tempx,tempy].chr+1;
         write(datoteka,TDsk[tempx,tempy].chr);
         TDsk[tempx,tempy].chr:=TDsk[tempx,tempy].chr-1;
         write(datoteka,TDsk[tempx,tempy].boja);
         end;
      Close(datoteka);
      _ch:=#0;
      end;
   if _ch='G' then { Home }
      begin
      gotoxy(3,WhereY);
      _ch:=#0;
      end;
   if _ch='O' then { End }
      begin
      gotoxy(78,WhereY);
      _ch:=#0;
      end;

   if _ch='P' then { Dole }
      begin
       if  Real_Y=18 then
           begin
           sound(200);
           delay(10);
           nosound;
           end
           else
           begin
           gotoxy(WhereX,WhereY+1);
           Real_Y:=Real_Y+1;
           end;
      _ch:=#0;
      end;

   if _ch='H' then { Gore }
      begin
       if  Real_Y=1 then
           begin
           sound(200);
           delay(10);
           nosound;
           end
           else
           begin
           gotoxy(WhereX,WhereY-1);
           Real_Y:=Real_Y-1;
           end;
      _ch:=#0;
      end;
   if _ch='K' then { Levo }
      begin
       if  WhereX=3 then
           begin
           sound(200);
           delay(10);
           nosound;
           end
           else
           begin
           gotoxy(WhereX-1,WhereY);
           end;
      _ch:=#0;
      end;
   if _ch='M' then { Desno }
      begin
       if  WhereX=78 then
           begin
           sound(200);
           delay(10);
           nosound;
           end
           else
           begin
           gotoxy(WhereX+1,WhereY);
           end;
      _ch:=#0;
      end;
   if _ch=';' then { F1 }
      begin
      _ch:=chr(Ek[WhereY-1,WhereX-1].boja);
       asm
       mov bl,_ch
       add bl,240
       mov _ch,bl
       end;
      Real_Col:=ord(_ch);
      Ek[WhereY-1,WhereX-1].boja:=ord(_ch);
      TDsk[Real_Y,WhereX-3].boja:=ord(_ch);
      _ch:=#0;
      end;
   if _ch='<' then { F2 }
      begin
      _ch:=chr(Ek[WhereY-1,WhereX-1].boja);
       asm
       mov bl,_ch
       add bl,16
       mov _ch,bl
       end;
      Real_Col:=ord(_ch);
      Ek[WhereY-1,WhereX-1].boja:=ord(_ch);
      TDsk[Real_Y,WhereX-3].boja:=ord(_ch);
      _ch:=#0;
      end;
   if _ch='=' then { F3 }
      begin
      _ch:=chr(Ek[WhereY-1,WhereX-1].boja);
       asm
       mov bl,_ch
       rol bl,4
       add bl,240
       rol bl,4
       mov _ch,bl
       end;
      Real_Col:=ord(_ch);
      Ek[WhereY-1,WhereX-1].boja:=ord(_ch);
      TDsk[Real_Y,WhereX-3].boja:=ord(_ch);
      _ch:=#0;
      end;
   if _ch='>' then { F4 }
      begin
      _ch:=chr(Ek[WhereY-1,WhereX-1].boja);
       asm
       mov bl,_ch
       rol bl,4
       add bl,16
       rol bl,4
       mov _ch,bl
       end;
      Real_Col:=ord(_ch);
      Ek[WhereY-1,WhereX-1].boja:=ord(_ch);
      TDsk[Real_Y,WhereX-3].boja:=ord(_ch);
      _ch:=#0;
      end;
   end;
if (_ch<>#0)and(_ch<>#27) then
   begin
   Ek[WhereY-1,WhereX-1].chr:=ord(_Ch);
   TDsk[Real_Y,WhereX-3].chr:=ord(_ch);
   Ek[WhereY-1,WhereX-1].boja:=Real_Col;
   TDsk[Real_Y,WhereX-3].boja:=Real_Col;
   if (wherex<78) then gotoxy(wherex+1,wherey);
   end;
until _ch=#27;
textbackground(0);
textcolor(7);
clrscr;
end.