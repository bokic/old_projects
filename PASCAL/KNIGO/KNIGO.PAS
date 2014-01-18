{$A+,B-,D+,E+,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T-,V-,X+,Y+}
{$M 16384,0,655360}
Uses SetMode,Crt,Dbase{,Xmsdbase,Xms,WatchXms};
Label 1,999,K,Er;
Const
  Firma_Nam = 'Z.T.P.Instalater';
  Firma_Tel = '+38923212495';
  Firma_Adr = 'ul:Naroden Front 31/35';
  Firma_ZSk = '40100-601-25531';
  Kn:array[1..9] of char='temp.dbf'+#0;
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
	_temp:word=0;
Var
	 __temp:Array[0..19] Of byte;
	 Knigo:PDBase;
	 Firmi:PDBase;
	 T:PDBase;
	 kraj:boolean;
	 x,y:integer;
	 is:word;
	 button:byte;
	 ch:char;
	 Off_On:boolean;
	 T1:String[4];
	 T2:String[14];
	 T3:String[6];
	 T4:String[8];
	 T5:String[13];
	 T6:String[13];
	 T7:String[14];
	 Err:Byte;
	 _T:Integer;
	 poin:pointer;

Procedure GotoXY(x,y:Byte);
Assembler;
Asm
mov ah,02h
mov bh,0
mov dl,x
dec dl
mov dh,y
dec dh
int 10h
End;

Function edit_data(Var Stri:String;x,y:byte):Shortint;
Label Lop,Kraj;
Var sx,sy,pos,_er:byte;
	 err:word;
	 ch:char;
	 data,mesec,god:byte;
Begin
textbackground(0);
pos:=1;
Lop:
gotoxy(x,y);
write(Stri);
gotoxy(x+pos-1,y);
ch:=readkey;
If (ch=#13) Then
	Begin
	edit_data:=0;
	Goto Kraj;
	End;
If (ch=#27) Then
	Begin
	edit_data:=10;
	Goto Kraj;
	End;
If ((ord(ch)>=ord('0'))And(ord(ch)<=ord('9'))) Then
	Begin
	If((ord(ch)>ord('1'))And(pos=4))Then
		Goto Lop;
	If((ord(ch)>ord('3'))And(pos=1))Then
		Goto Lop;
	Stri:=copy(Stri,1,pos-1)+ch+copy(Stri,pos+1,8-pos);
	If(pos=8)Then
		Goto Lop;
	If((pos=2)Or(pos=5))Then
		pos:=pos+2
		Else
		pos:=pos+1;
	Goto Lop;
	End;
If(ch=#0)Then
	Begin
	ch:=ReadKey;
	If(ch='H')Then {Gore}
		Begin
		edit_data:=-1;
		Goto Kraj;
		End;
	If(ch='P')Then {Dole}
		Begin
		edit_data:=1;
		Goto Kraj;
		End;
	If(ch='K')Then {Levo}
		Begin
		If(pos>1)Then
			Begin
			If(pos=1)Then
				Goto Lop;
			If((pos=4)or(pos=7))Then
				pos:=pos-2
				Else
				pos:=pos-1;
			Goto Lop;
			End;
		Goto Lop;
		End;
	If(ch='M')Then {Desno}
		Begin
		If(pos=8)Then
			Goto Lop;
		If((pos=2)Or(pos=5))Then
			pos:=pos+2
			Else
			pos:=pos+1;
		Goto Lop;
		End;
	End;
Goto Lop;
Kraj:
textbackground(0);
val(copy(Stri,1,2),data,err);
val(copy(Stri,4,2),mesec,err);
val(copy(Stri,7,2),god,err);
Asm
@Asm1L1:
mov ah,$2c
int $21{ Get time }
cmp ch,23
jne @Asm1L2
cmp cl,59
jne @Asm1L2
cmp dh,59
je @Asm1L1
@Asm1L2:
mov ah,$2A
int $21{ Get date }

push cx
push dx{ Save date }

mov cx,1900
mov ah,0
mov al,god

cmp al,90 {milenium bug}
jae @Ok
add cx,100
@Ok:

add cx,ax
mov dh,mesec
mov dl,data
mov ah,$2B
cli
int $21{ Set edit date }
mov _er,al

pop dx{ Restore old date }
pop cx
mov ah,$2B
int $21
sti
End;
If(_er<>0)Then
	Goto Lop;
textbackground(1);
End;

Function edit_text(Var Stri:String;x,y:byte):Shortint;
Label Lop,Kraj;
Var pos,len,sx,sy:byte;
	 ins:boolean;
	 ch:char;
Begin
len:=length(Stri);
ins:=True;
pos:=1;
textbackground(0);
Lop:
gotoxy(x,y);
write(Stri);
gotoxy(x+pos-1,y);
ch:=readkey;
If(ch=#27)Then
	Begin
	edit_text:=10;
	Goto Kraj;
	End;
If(ch=#8)Then
	Begin
	If(pos<2)Then
		Goto Lop;
	Stri:=copy(Stri,1,pos-2)+copy(Stri,pos,len-pos+1)+ ' ';
	pos:=pos-1;
	Goto Lop;
	End;
If(ch=#13)Then
	Begin
	edit_text:=0;
	Goto Kraj;
	End;
If(ch>#31)Then
	Begin
	If(ins)Then
		Stri:=copy(Stri,1,pos-1)+ch+copy(Stri,pos,len-pos)
		else
		Stri:=copy(Stri,1,pos-1)+ch+copy(Stri,pos+1,len-pos+1);
	If(pos<len)Then
		pos:=pos+1;
	Goto Lop;
	End;
If(ch=#0)Then
	Begin
	ch:=readkey;
	If(ch='H')Then {Gore}
		Begin
		edit_text:=-1;
		Goto Kraj;
		End;
	If(ch='P')Then {Dole}
		Begin
		edit_text:=1;
		Goto Kraj;
		End;
	If(ch='K')Then {Levo}
		Begin
		If(pos>1)Then
			pos:=pos-1;
		Goto Lop;
		End;
	If(ch='M')Then {Desno}
		Begin
		If(pos<len)Then
			Begin
			pos:=pos+1;
			Goto Lop;
			End;
		End;
	If(ch='R')Then
		Begin
		If(ins=False)Then
			ins:=true
			Else
			ins:=false;
		Asm
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
		End;
		Goto Lop;
		End;
	If(ch='S')Then {Delete}
		Begin
		If(pos>len)Then
			Goto Lop;
		Stri:=copy(Stri,1,pos-1)+copy(Stri,pos+1,len-pos)+ ' ';
		Goto Lop;
		End;
	End;
Goto Lop;
Kraj:
textbackground(1);
 Asm
 mov cx,$0D0E
 mov ah,1
 int $10
 End;
End;

Function edit_normal(Var t1:longint;x,y,len:byte):Shortint;
Label Lop,Kraj,Temp;
Var t,pos:byte;
	 Stri:String[6];
	 ch:char;
	 err:word;
	 count:byte;
Begin
textbackground(0);
count:=0;
str(t1,Stri);
If(length(Stri)<len)Then
	Begin
	Temp:
	Stri:=' '+Stri;
	If(length(Stri)<len)Then
		Goto temp;
	End;
For t:=1 To len Do
	If(Stri[t]=' ')Then
		count:=count+1;
If(count<>0)Then
	Stri:=copy(Stri,count+1,len-count)+copy(Stri,1,count);
pos:=len-count+1;
If(pos>len)Then
	pos:=Len;
Lop:
gotoxy(x,y);
write(Stri);
gotoxy(x+pos-1,y);
ch:=readkey;
If(ch=#27)Then
	Begin
	edit_normal:=10;
	Goto Kraj;
	End;
If(ch=#8)Then { Back space }
	Begin
	If(pos<2)Then
		Goto Lop;
	If((pos=2)And(Count=Len-1))Then
		Begin
		If (Copy(Stri,1,1)<>'0') Then Stri[1]:='0';
		Goto Lop;
		End;
	Stri:=copy(Stri,1,pos-2)+copy(Stri,pos,len-pos+1)+ ' ';
	pos:=pos-1;
	count:=count+1;
	Goto Lop;
	End;
If((ord(ch)>=ord('0'))and(ord(ch)<=ord('9')))Then
	Begin
	If((ch='0')And(pos=1))Then Goto Lop;
	If((Stri[1]='0')And(pos<=2))Then
		Begin
		If(ch='0')Then
			Goto Lop;
		Stri:=ch+copy(Stri,2,len-1);
		If(Len>1)Then
			pos:=2;
		End
		Else
		Begin
		If(Stri[len]=' ')Then
			count:=count-1;
		Stri:=copy(Stri,1,pos-1)+ch+copy(Stri,pos,len-pos);
		If(pos<>len)Then
			 pos:=pos+1;
		End;
	Goto Lop;
	End;
If(ch=#0)Then
	Begin
	ch:=readkey;
	If(ch='H')Then {Gore}
		Begin
		edit_normal:=-1;
		Goto Kraj;
		End;
	If(ch='P')Then {Dole}
		Begin
		edit_normal:=1;
		Goto Kraj;
		End;
	if(ch='K')Then {Levo}
		Begin
		If(pos>1)Then
			Begin
			pos:=pos-1;
			Goto Lop;
			End;
		Goto Lop;
		End;
	If(ch='M')Then {Desno}
		Begin
		If(pos<len-count+1)Then
			Begin
			If(pos=len)Then Goto Lop;
			pos:=pos+1;
			Goto Lop;
			End;
		End;
	If(ch='S')Then {Delete}
		Begin
		If(pos>len)Then
			Goto Lop;
		If((Pos=1)And(len-count=1))Then
			Begin
			Stri[1]:='0';
			Goto Lop;
			End;
		If(Stri[pos]<>' ')Then
			count:=count+1;
		Stri:=copy(Stri,1,pos-1)+copy(Stri,pos+1,len-pos)+ ' ';
		Goto Lop;
		End;
	Goto Lop;
	End;
If(ch=#13)Then
	Begin
	edit_normal:=0;
	End
	Else
	Goto Lop;
Kraj:
If(count>0)Then
	Begin
	delete(Stri,len-count+1,count);
	End;
If(Stri='')Then
	Stri:='0';
val(Stri,t1,err);
If(err<>0)Then
	Begin
	writeln;
	writeln('Error no:',err);
	halt;
	End;
str(t1:len,Stri);
gotoxy(x,y);
write(Stri);
textbackground(1);
End;

Function edit_real(Var t1:real;x,y,len:byte):Shortint;
Var Stri:String[15];
	 err:integer;
	 t,pos,sx,sy:byte;
	 ch:char;
	 count:byte;
Label Lop,Kraj;
Begin
textbackground(0);
str(t1:len:2,Stri);
count:=0;
For t:=1 To len-3 Do
	 If(Stri[t]=' ')Then
		count:=count+1;
pos:=length(Stri)-2-count;
Stri:=copy(Stri,count+1,pos-1)+copy(Stri,1,count)+copy(Stri,len-2,3);
Lop:
gotoxy(x,y);
write(Stri);
gotoxy(x+pos-1,y);
ch:=readkey;
if (ch=#27) then
   begin
   edit_real:=10;
   goto Kraj;
   end;
if ch='.' then
   begin
   pos:=len-1;
   goto Lop;
   end
   else
if ((ord(ch)>=ord('0'))and(ord(ch)<=ord('9'))) then
   begin
   If (Copy(Stri,1,2)='0 ') Then
           Begin
           Stri[1]:=ch;
           pos:=2;
           End
			  Else
           Begin
           if ((copy(Stri,len-3,1)=' ')and(pos<len-2)) then Dec(count);
           if (pos<len-2) then
              Stri:=copy(Stri,1,pos-1)+ch+copy(Stri,pos,len-pos-3)+copy(Stri,len-2,3)
              else
              Stri:=copy(Stri,1,pos-1)+ch+copy(Stri,pos+1,len-pos);
           if (pos<>len) then Inc(pos);
           if (len=pos+2) then Inc(pos);
           end;
   goto Lop;
   end
   else
if (ch=#8) then { Back Space }
   begin
   if ((pos<2)or(pos>len-2)) then goto Lop;
   If (Stri[2]<>' ') Then
                 Begin
                 Stri:=copy(Stri,1,pos-2)+copy(Stri,pos,len-pos-2)+ ' '+copy(Stri,len-2,3);
					  pos:=pos-1;
                 count:=count+1;
                 End
                 Else
                 Stri[1]:='0';
   goto Lop;
   end
   else
if (ch=#0) then
   begin
   ch:=readkey;
   if ch='H' then {Gore}
      begin
      edit_real:=-1;
      goto Kraj;
      end;
   if ch='P' then {Gore}
      begin
      edit_real:=1;
		goto Kraj;
      end;
   if ch='K' then {Levo}
      begin
      if ((pos=len-1)and(count=0)) then
         begin
         pos:=pos-2;
         goto Lop;
         end;
      if ((pos>1)and(pos<>len-1)) then
         begin
         pos:=pos-1;
         goto Lop;
         end;
      if (pos=len-1) then
         begin
         pos:=pos-count-1;
         goto Lop;
         end;
		goto Lop;
      end;
   if ch='M' then {Desno}
      begin
      if ((pos<>len)and(pos<>len-3)) then
         begin
         if Stri[pos]=' ' then
            begin
            pos:=len-1;
            goto Lop;
            end;
         pos:=pos+1;
         goto Lop;
         end;
      if (pos=len-3) then
         begin
         pos:=pos+2;
         goto Lop;
         end;
		goto Lop;
      end;
   if ch='S' then {Delete}
      begin
      If (pos>len-2) Then Goto Lop;
      If (Copy(Stri,2,1)=' ') Then
          Begin
          Stri[1]:='0';
          Goto Lop;
          End;
      If (Stri[pos]<>' ') then Inc(count);
      Stri:=copy(Stri,1,pos-1)+copy(Stri,pos+1,len-pos-3)+ ' '+copy(Stri,len-2,3);
      goto Lop;
      end;
      end
   else
if ch=#13 then
   begin
   edit_real:=0;
	end
   else
   goto Lop;
Kraj:
delete(Stri,len-2-count,count);
val(Stri,t1,err);
if err<>0 then
   begin
   writeln;
   writeln('Error no:',err);
   halt;
   end;
{if count>0 then
   begin
   for sx:=1 to count do Stri:=' '+Stri;
   end;}
Str(t1:13:2,Stri);
gotoxy(x,y);
write(Stri);
textbackground(1);
end;

function _help:byte;
type ekran = record
     chr:byte;
     boja:byte;
     end;
var datoteka:file of byte;
var Ek:array[0..24,0..79] of ekran absolute $B800:$0000 ;
    tempx,tempy,temp_read:byte;
label Y;
begin
Assign(datoteka,'knigo.hlp');
{$I-}
reset(datoteka);
{$I+}
tempx:=IOResult;
if tempx <> 0 then
	begin
   gotoxy(2,21);
   textcolor(7);
   write('ƒôæşìà óôê òöâàôàñæ ğà knigo.hlp, ãôæşìà áô:',tempx);
   _help:=tempx;
   goto Y;
   end;
Ek[1,1].chr:=214;
for tempx:=2 to 77 do Ek[1,tempx].chr:=196;
Ek[1,78].chr:=183;
for tempy:=2 to 19 do Ek[tempy,1].chr:=186;
for tempy:=2 to 19 do Ek[tempy,78].chr:=186;
Ek[20,1].chr:=211;
for tempx:=2 to 77 do Ek[20,tempx].chr:=196;
Ek[20,78].chr:=189;
for tempx:= 1 to 18
do for tempy:=0 to 75
do
   begin
   read(datoteka,temp_read);
   temp_read:=temp_read-1;
   Ek[tempx+1,tempy+2].chr:=temp_read;
   read(datoteka,temp_read);
   Ek[tempx+1,tempy+2].boja:=temp_read;
   end;
Close(datoteka);
_help:=0;
Y:
end;

function ButtonPressed:boolean;
Assembler;
asm
 mov ax,3
 int 33h
 mov ax,bx
end;

function GetMouseX:word;
Assembler;
Asm
 mov ax,3
 int 33h
 mov ax,cx
end;

function GetMouseY:word;
Assembler;
asm
 mov ax,3
 int 33h
 mov ax,dx
end;

procedure izlez;
var a:byte;
begin
 asm
 mov ax,2C00h
 int 21h
 mov a,dl
 end;
writeln('Fatal Error :',a);
port[$60]:=$ed;
 asm
 @_v2:
 jmp @_v2
 end;
end;

procedure show_mouse;
Assembler;
 asm
 mov ax,1
 int $33
end;

procedure hide_mouse;
Assembler;
asm
 mov ax,2
 int $33
end;

procedure tk;
begin
sound(1000);
delay(10);
nosound;
delay(10);
end;

Function FileExists(const Name:String):Boolean;
Assembler;
Asm
 push ds
 mov ax,3D02h
 lds dx,Name
 inc dx          {Deka e Pascal 6.0 i deka koristi ......}
 int 21h
 jnc @OK
 mov ax,0
 jmp @Kraj
@OK:
 mov bx,ax
 mov ah,3Eh
 int 21h
 mov al,1
@Kraj:
 pop ds
End;

function protect:boolean;
Assembler;
Var  Model:Record
		genconf,
		fixcyls,
		remcyls,
		heads,
		bytetrack,                     { bytes per track }
		bytesector,                    { bytes per sector }
		sectors,                       { sectors per track }
		byteisg,                       { bytes intesector gap }
		byteplo,                       { bytes in sync }
		worduniq: Word;                { words unique status }
		serial: array[1..20] of Char;
		contype,                       { controller type }
		bufsiz,                        { buffer size in 512 byte blocks }
		byteecc: Word;                 { ECC bytes trasferred in read/write long }
		firmware: array[1..8] of Char; { firmware revision }
		model: array[1..40] of Char;   { model ID }
		secsint,                       { number of sectors transferred per interrupt }
		dblword,                       { double word transfer flag }
		writepro: Word;                { write protect }
	end;
asm
(*jmp @v0{ Proverka na G.Karta }
@Video:
db 43h,23h,10h,28h,26h,33h,23h,22h
db 25h,10h,46h,59h,54h,55h,5Fh,10h
db 32h,39h,3Fh,43h
@MBoard:
db 31h,5Ch,59h,25h,21h,22h,23h
@HD:
db 'A','E','1','>','D','E','=','','6','9','B','5','2','1','<','<','!',' ','(',' ','1'
db '','','','','','','','','','','','','','','','','','',''
@v0:
mov ax,0C000h
mov es,ax
mov si,offset @Video
mov di,$3f
mov cx,20
@L1:
mov al,cs:[si]
add al,10h
cmp al,es:[di]
jne @v1
inc si
inc di
loop @L1

{Proverka na MBoard}
mov ax,0FD96h
mov es,ax
mov si,offset @MBoard
mov di,3
mov cx,7
@L2:
mov al,cs:[si]
add al,10h
cmp al,es:[di]
jne @v1
inc si
inc di
loop @L2

mov al,$EC{Proverka na HD}
mov dx,$1F7
out dx,al
@Lop1:
in ax,dx
nop
and al,$80
or al,al
jne @Lop1
mov cx,50
mov dx,$01F0
mov di,offset [Model]
push ds
pop es
@Lop2:
in ax,dx
sub ah,10h
mov es:[di],ah
inc di
sub al,10h
mov es:[di],al
inc di
loop @Lop2
pushf
cld
{ds:si es:di}
mov cx,20
mov si,offset Model.Model
push cs
pop es
mov di,offset @HD
rep
cmpsb
pushf
pop ax
popf
push ax
popf
jne @v1
xor ax,ax
jmp @v2
@v1:
mov ax,1
@v2:*)
mov ax,0
end;

procedure cursoron;
Assembler;
Asm
 mov ax,100h
 mov cx,90Ah
 int 10h
end;

procedure cursoroff;
Assembler;
Asm
 mov ax,100h
 mov cx,1000h
 int 10h
end;

function today:string;
var y:Word;
         m,d,err:byte;
    temp,temp1:string[8];
begin
   asm
   mov ah,2Ah
   int 21h
   mov y,cx
   mov m,dh
   mov d,dl
   end;
str(d,temp);
if length(temp)=1 then
   temp:='0'+temp;
temp1:=temp+'-';
str(m,temp);
if length(temp)=1 then
   temp:='0'+temp;
temp1:=temp1+temp+'-';
str(y,temp);
temp:=copy(temp,3,2);
temp1:=temp1+temp;
today:=temp1;
end;

procedure beep;
begin
sound(200);
delay(50);
nosound;
end;

Procedure MakeKnigo;
Var Kn:PCreateFile;
Begin
New(Kn,Init('knigo.dbf'));
Kn^.Add('No'   ,'N',4,0);
Kn^.Add('Naziv','C',14,0);
Kn^.Add('Konto','N',6,0);
Kn^.Add('Data' ,'D',8,0);
Kn^.Add('Dava' ,'N',13,2);
Kn^.Add('Zima' ,'N',13,2);
Kn^.Add('Saldo','N',14,2);
Dispose(Kn,Done);
End;

Procedure MakeFirmi;
Var Fi:PCreateFile;
Begin
New(Fi,Init('firmi.dbf'));
Fi^.Add('No' ,'N',3,0);
Fi^.Add('Ime','C',30,0);
Dispose(Fi,Done);
End;

Procedure MakeTemp;
Var Te:PCreateFile;
Begin
New(Te,Init('temp.dbf'));
Te^.Add('No'   ,'N',4,0 );
Te^.Add('Naziv','C',14,0);
Te^.Add('Konto','N',6,0);
Te^.Add('Data' ,'D',8,0);
Te^.Add('Dava' ,'N',13,2);
Te^.Add('Zima' ,'N',13,2);
Te^.Add('Saldo','N',14,2);
Dispose(Te,Done);
End;

procedure show1(y,gore:longint);
label Cl;
var temp:byte;
begin
temp:=0;
Firmi^.GetDbRec(gore);
if Firmi^.RecCount=0 then goto Cl;
repeat
temp:=temp+1;
if (temp<>1) then Firmi^.NextRec;
if (y=temp) then
   begin
   textbackground(2);
   gotoxy(23,temp+4);write(Firmi^.MyFieldData(1));
   gotoxy(27,temp+4);write(Firmi^.MyFieldData(2));
   textbackground(1);
   end
else
    begin
    gotoxy(23,temp+4);write(Firmi^.MyFieldData(1));
    gotoxy(27,temp+4);write(Firmi^.MyFieldData(2));
    end;
until (Firmi^.DBEOF)or(temp=13);
Cl:
if temp<13 then
   begin
   repeat
   temp:=temp+1;
   gotoxy(23,temp+4);writeln('   ');
   gotoxy(27,temp+4);writeln('                              ');
   until temp=13
   end;
end;

function shtampa(st:string):byte;
var temp:byte;
    err:byte;
    temp1:char;
label Kraj;
begin
st:='                         '+st;
for temp:=1 to length(st) do
    begin
     temp1:=st[temp];
     asm
     mov dx,0
     mov ah,0
     mov al,temp1
     int 17h
     mov err,ah
     end;
    if (err<>16) then
       begin
       shtampa:=err;
       goto Kraj;
       end;
    end;
shtampa:=16;
kraj:
end;

function initprinter:byte;
Assembler;
asm
mov dx,0
mov ax,$200
int 17h
mov al,ah
end;

procedure show(y,gore:longint);
var temp:byte;
label r0;
begin
temp:=0;
Knigo^.GetDbRec(gore);
textattr:=$17;
gotoxy(1,2);write( 'ÇÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶');
gotoxy(1,3);write( 'ºô  º      àèêâ   ºŒòğöò º  „àöà  º     ‚íæè    º    Šèíæè    º •àíäò”àèíêìà º');
gotoxy(1,4);write( 'ÇÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶');
gotoxy(1,18+5);write('ÇÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶');
gotoxy(37,19+5);write('º');
gotoxy(51,19+5);write('º');
gotoxy(65,19+5);write('º');
gotoxy(37,20+5);write('ÓÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶');
if Knigo^.RecCount=0 then
	begin
	temp:=0;
	goto r0;
	end;
repeat
temp:=temp+1;
if (temp<>1) then
	Knigo^.NextRec;
if (y=temp) then
	begin
	textbackground(2);
	gotoxy(2,temp+4);write(Knigo^.MyFieldData(1),'º',Knigo^.MyFieldData(2),
	'º',Knigo^.MyFieldData(3),'º',Knigo^.MyFieldData(4),'º'
	,Knigo^.MyFieldData(5),'º',Knigo^.MyFieldData(6),'º',
	Knigo^.MyFieldData(7));
	textbackground(1);
	end
else
	 begin
	 gotoxy(2,temp+4);write(Knigo^.MyFieldData(1),'º',Knigo^.MyFieldData(2),
	 'º',Knigo^.MyFieldData(3),'º',Knigo^.MyFieldData(4),'º'
	 ,Knigo^.MyFieldData(5),'º',Knigo^.MyFieldData(6),'º',
	 Knigo^.MyFieldData(7));
	 end;
until ((Knigo^.DBEOF) or (temp=13+5));
r0:
if (temp<13+5) then
	begin
	repeat
	temp:=temp+1;
	gotoxy(2,temp+4);write('    º              º      º        º             º             º              º');
	until temp=13+5
	end;
end;

procedure cistenje;
type ekran = record
     chr:byte;
     boja:byte;
     end;
var Ek:array[0..24,0..79] of ekran absolute $B800:$0000 ;
	T:Byte;
begin
Ek[1,0].chr:=186;
Ek[1,79].chr:=186;
Ek[3,0].chr:=186;
Ek[3,79].chr:=186;
Ek[17+5,0].chr:=186;
Ek[17+5,79].chr:=186;
Ek[19+5,0].chr:=186;
Ek[19+5,79].chr:=186;
window(2,2,79,26);
T:=textattr;
textattr:=$17;
clrscr;
textattr:=T;
window(1,1,80,30);
end;

procedure display1;
begin
textattr:=$17;
gotoxy(22,2);write('ÖÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·');
gotoxy(22,3);write('ºô.º       Šïæ ğà ™êôïàöà         º');
gotoxy(22,4);write('ÇÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶');
gotoxy(22,5);write('º   º                              º');
gotoxy(22,6);write('º   º                              º');
gotoxy(22,7);write('º   º                              º');
gotoxy(22,8);write('º   º                              º');
gotoxy(22,9);write('º   º                              º');
gotoxy(22,10);write('º   º                              º');
gotoxy(22,11);write('º   º                              º');
gotoxy(22,12);write('º   º                              º');
gotoxy(22,13);write('º   º                              º');
gotoxy(22,14);write('º   º                              º');
gotoxy(22,15);write('º   º                              º');
gotoxy(22,16);write('º   º                              º');
gotoxy(22,17);write('º   º                              º');
gotoxy(22,18);write('ÓÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½');
end;

procedure show_obicno;
label Kraj;
var y,temp,t1:longint;
    st:string[14];
    vlez,izlez,saldo,vlez1,izlez1,saldo1:real;
    s:boolean;
    err:integer;
label t0;
begin
vlez:=0;
izlez:=0;
saldo:=0;
if T^.RecCount=0 then goto Kraj;
T^.GoTop;
s:=false;
repeat
if s=false then s:=true else T^.NextRec;
val(T^.MyFieldData(5),vlez1,err);
val(T^.MyFieldData(6),izlez1,err);
val(T^.MyFieldData(7),saldo1,err);
vlez:=vlez+vlez1;
izlez:=izlez+izlez1;
saldo:=saldo+saldo1;
until T^.DBEOF;
gotoxy(1,2);write('ÇÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶');
gotoxy(1,3);write('ºô. º    àèêâ     ºŒòğöò º  „àöà  º     ‚íæè    º    Šèíæè    º •àíäò”àèíêìà º');
gotoxy(1,4);write('ÇÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶');
gotoxy(1,18+5);write('ÇÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶');
gotoxy(1,19+5);write('º                                   º             º             º              º');
gotoxy(1,20+5);write('º                                   ÓÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶');
str(vlez:13:2,st);
gotoxy(38,19+5);writeln(st);
str(izlez:13:2,st);
gotoxy(52,19+5);writeln(st);
str(saldo:14:2,st);
gotoxy(66,19+5);writeln(st);
T^.GoTop;
if T^.RecCount>13+5 then
        begin
        y:=1;
        repeat
        t1:=0;
        T^.GetDbRec(y);
        for temp:=1 to 13+5 do
                 begin
                 if t1=0 then
                         t1:=4
                         else
                         T^.NextRec;
                 t1:=t1+1;
                 gotoxy(2,t1);write(T^.MyFieldData(1),'º',T^.MyFieldData(2),
                 'º',T^.MyFieldData(3),'º',T^.MyFieldData(4),'º',T^.MyFieldData(5),
                 'º',T^.MyFieldData(6),'º',T^.MyFieldData(7));
                 end;
        ch:=readkey;
        if ch=#0 then
                begin
                ch:=readkey;
                if (ch='H')and(y<2) then beep;
                if (ch='H')and(y>=2) then y:=y-1;
                if (ch='P')and(y+13+5>T^.RecCount) then beep;
                if (ch='P')and(y+13+5<=T^.RecCount) then y:=y+1;
                if (ch='G') then y:=1;
                if (ch='O') then y:=T^.RecCount-12-5;
                if ((ch='I')and(y=1)) then beep; {PgUp}
                if (ch='I')and(y-13+5<=13+5) then y:=1;
                if (ch='I')and(y-13+5>0) then y:=y-13-5;
                if ((ch='Q')and(y=T^.RecCount-12-5)) then beep;{PgDn}
                if (ch='Q')and(y+26+5<=T^.RecCount) then y:=y+13+5;
                if (ch='Q')and(y+26+5>T^.RecCount) then y:=T^.RecCount-12-5;
                end;
        until ch=#27;
        end
        else
        begin
        y:=0;
        repeat
        if (y>0) then
                T^.NextRec;
        y:=y+1;
        gotoxy(2,y+4);write(T^.MyFieldData(1),'º',T^.MyFieldData(2),
        'º',T^.MyFieldData(3),'º',T^.MyFieldData(4),'º',T^.MyFieldData(5),
        'º',T^.MyFieldData(6),'º',T^.MyFieldData(7));
        until T^.DBEOF;
        if y<13+5 then
                for y:=y+1-1 to 13+5-1  do
                        Begin
                        gotoxy(2,y+5);write('    º              º      º        º             º             º              ');
                        End;
        ch:=readkey;
        end;
Kraj:
end;

function normal(kade:char):string;
label Kraj;
var n:Boolean;
begin
if Knigo^.RecCount=0 then
   begin
   gotoxy(3,21);write('æïà óòäàöòûê');
   goto Kraj;
   end;
T^.Zap;
n:=False;
gotoxy(3,21+5);write('òïæğö!!');
Knigo^.GoTop;
repeat
if (n=false) then
	n:=true
	else
	Knigo^.NextRec;
T^.MyReplace(1,Knigo^.MyFieldData(1));
T^.MyReplace(2,Knigo^.MyFieldData(2));
T^.MyReplace(3,Knigo^.MyFieldData(3));
T^.MyReplace(4,Knigo^.MyFieldData(4));
T^.MyReplace(5,Knigo^.MyFieldData(5));
T^.MyReplace(6,Knigo^.MyFieldData(6));
T^.MyReplace(7,Knigo^.MyFieldData(7));
T^.AppendCurrent;
until Knigo^.DBEOF;
gotoxy(3,21+5);write('        ');
if kade='E' then show_obicno;
Kraj:
cistenje;
normal:='';
end;

procedure BBilans(kade:char;Len:Byte);
var
    found:boolean;
    s:boolean;
    temp:longint;
    lastval:longint;
    presval:longint;
    prevval:longint;
    count1,count2:longint;
    TKonto,KnigoKonto:longint;
    swapr:real;
    vlez,izlez,saldo,vlez1,izlez1,saldo1:real;
    swaps:string[14];
    CurKonto:String[8];
    err:integer;
begin
If ((Len<>3)and(Len<>6)) Then Halt;
T^.Zap;
prevval:=0;
gotoxy(3,21+5);write('òïæğö!!');

for count1:=1 to Knigo^.RecCount do
    begin
    GotoXY(3,25);
    Write('Done ',count1,' of ',Knigo^.RecCount);
    Knigo^.GetDBRec(count1);
    Found:=False;
    If (Len=3) Then
       CurKonto:=copy(Knigo^.MyFieldData(3),1,3)
       else
       CurKonto:=Knigo^.MyFieldData(3);
    if(T^.RecCount=0)then
       begin
       T^.MyReplace(3,CurKonto);
       T^.MyReplace(5,Knigo^.MyFieldData(5));
       T^.MyReplace(6,Knigo^.MyFieldData(6));
       T^.MyReplace(7,Knigo^.MyFieldData(7));
       T^.AppendCurrent;
       end
       else
       begin
       for count2:=1 to T^.RecCount do
          begin
          T^.GetDBRec(count2);
          val(T^.MyFieldData(3),TKonto,err);
          val(Knigo^.MyFieldData(3),KnigoKonto,err);
          if (Len=3) then
             KnigoKonto:=KnigoKonto div 1000;
          if (KnigoKonto<TKonto) then
             begin
             T^.MyReplace(3,CurKonto);
             T^.MyReplace(5,Knigo^.MyFieldData(5));
             T^.MyReplace(6,Knigo^.MyFieldData(6));
             T^.MyReplace(7,Knigo^.MyFieldData(7));
             T^.AppendCurrentAt(count2);
             Found:=true;
             break;
             end
             else if (KnigoKonto=TKonto) then
                begin
                val(T^.MyFieldData(5),vlez,err);
                val(Knigo^.MyFieldData(5),vlez1,err);
                vlez:=vlez+vlez1;
                Str(vlez:0:2,swaps);
                T^.MyReplace(5,swaps);

                val(T^.MyFieldData(6),izlez,err);
                val(Knigo^.MyFieldData(6),izlez1,err);
                izlez:=izlez+izlez1;
                Str(izlez:0:2,swaps);
                T^.MyReplace(6,swaps);

                Str(vlez-izlez:0:2,swaps);
                T^.MyReplace(7,swaps);

                T^.Save;
                Found:=True;
                break;
                end;
          end;
       if (Found=False)Then
          begin
          T^.MyReplace(3,CurKonto);
          T^.MyReplace(5,Knigo^.MyFieldData(5));
          T^.MyReplace(6,Knigo^.MyFieldData(6));
          T^.MyReplace(7,Knigo^.MyFieldData(7));
          T^.AppendCurrent;
          end;
       end;
    end;
gotoxy(3,21+5);write('        ');
if kade='E' then show_obicno;
cistenje;
end;

function Sintetika(kade:char):string;
label Kraj;
var kon_s:string[3];
         kon_n,kon1_n,New:longint;
         err:integer;
         test:Boolean;
begin
if Knigo^.RecCount=0 then
   begin
        gotoxy(3,21+5);write('æïà óòäàöòûê èà õêğöæöêìà.');
        goto Kraj;
        end;
New:=0;
gotoxy(3,21+5);write('Vnesi konto:');
cursoron;
edit_normal(New,16,21+5,3);
cursoroff;
gotoxy(3,21+5);write('                ');
Str(New:3,kon_s);
if(kon_s='  0') then
                                Begin
                                Sintetika:='';
                                goto Kraj;
                                End;
T^.Zap;
Knigo^.GoTop;
Test:=False;
gotoxy(3,21+5);write('òïæğö!!');
repeat;
if test=False then test:=True else Knigo^.NextRec;
if (copy(Knigo^.MyFieldData(3),1,3)=kon_s) then
        begin
        T^.MyReplace(1,Knigo^.MyFieldData(1));
        T^.MyReplace(2,Knigo^.MyFieldData(2));
        T^.MyReplace(3,Knigo^.MyFieldData(3));
        T^.MyReplace(4,Knigo^.MyFieldData(4));
        T^.MyReplace(5,Knigo^.MyFieldData(5));
        T^.MyReplace(6,Knigo^.MyFieldData(6));
        T^.MyReplace(7,Knigo^.MyFieldData(7));
        T^.AppendCurrent;
        end;
until (Knigo^.DBEOF);
gotoxy(3,21+5);write('        ');
if (T^.RecCount=0) then
                  begin
                  gotoxy(3,21+5);write('æïà óòäàöòûê èà õêğöæöêüìò ìòğöo '+kon_s+'.');
                  sintetika:='';
                  goto Kraj;
                  end;
if kade='E' then show_obicno;
cistenje;
sintetika:=kon_s;
Kraj:
ch:='A';
end;

function Analitika(kade:char):string;
label Kraj;
var kon_s:string[6];
         kon_n,kon1_n,New:longint;
         err:integer;
         test:Boolean;
begin
if Knigo^.RecCount=0 then
        begin
                  gotoxy(3,21+5);write('æïà óòäàöòûê èà àğàíêöêìà.');
        goto Kraj;
        end;
New:=0;
gotoxy(3,21+5);write('Vnesi konto:');
cursoron;
edit_normal(New,16,21+5,6);
cursoroff;
Str(New:6,kon_s);
gotoxy(3,21+5);write('                   ');
if (kon_s='     0') then
                  begin
                  Analitika:='';
                  goto kraj;
                  end;
val(kon_s,kon_n,err);
if (err<>0) then halt(1);
T^.Zap;
Knigo^.GoTop;
Test:=False;
gotoxy(3,21+5);write('òïæğö!!');
repeat;
if test=False then test:=True else Knigo^.NextRec;
Val(Knigo^.MyFieldData(3),kon1_n,err);
if kon_n=kon1_n then
                  begin
                  T^.MyReplace(1,Knigo^.MyFieldData(1));
                  T^.MyReplace(2,Knigo^.MyFieldData(2));
                  T^.MyReplace(3,Knigo^.MyFieldData(3));
                  T^.MyReplace(4,Knigo^.MyFieldData(4));
                  T^.MyReplace(5,Knigo^.MyFieldData(5));
                  T^.MyReplace(6,Knigo^.MyFieldData(6));
                  T^.MyReplace(7,Knigo^.MyFieldData(7));
                  T^.AppendCurrent;
                  end;
until (Knigo^.DBEOF);
gotoxy(3,21+5);write('        ');
if T^.RecCount=0 then
        begin
        gotoxy(3,21+5);write('æïà óòäàöòûê èà àğàíêöêüìò ìòğöo '+kon_s+'.');
        Analitika:='';
        goto Kraj;
        end
        else
        begin
        Analitika:=kon_s;
        if kade='E' then show_obicno;
        cistenje;
        end;
Kraj:
end;

function Klasa(kade:char):string;
var klass:string[1];
         New:LongInt;
         test:Boolean;
begin
gotoxy(2,21+5);write('‚ğæõê ãò áôòëòö ğà ìíàõàöà:');
New:=0;
cursoron;
edit_normal(New,29,21+5,1);
cursoroff;
Str(New:1,klass);
gotoxy(2,21+5);write('                            ');
T^.Zap;
if klass='0' then klass:=' ';
test:=false;
Knigo^.GoTop;
gotoxy(3,21+5);write('òïæğö!!');
repeat
if test=false then test:=true else Knigo^.NextRec;
if (copy(Knigo^.MyFieldData(3),1,1)=klass) then
                  begin
                  T^.MyReplace(1,Knigo^.MyFieldData(1));
                  T^.MyReplace(2,Knigo^.MyFieldData(2));
                  T^.MyReplace(3,Knigo^.MyFieldData(3));
                  T^.MyReplace(4,Knigo^.MyFieldData(4));
                  T^.MyReplace(5,Knigo^.MyFieldData(5));
                  T^.MyReplace(6,Knigo^.MyFieldData(6));
                  T^.MyReplace(7,Knigo^.MyFieldData(7));
                  T^.AppendCurrent;
                  end;
until Knigo^.DBEOF;
gotoxy(3,21+5);write('        ');
if T^.RecCount=0 then
                  begin
                  if klass=' ' then klass:='0';
                  gotoxy(3,21+5);write('æïà óòäàöòûê èà ìíàõà '+klass+'.');
                  end
else
                  begin
                  if kade='E' then show_obicno;
                  cistenje;
                  end;
klasa:=klass;
end;

Procedure ZList(kade:char);
Var first:boolean;
	 _vlez,_izlez,_saldo:real;
	 vlez,izlez,saldo:Array[0..9] Of real;
	 konto:longint;
	 err:integer;
	 strings:String[14];
	 te:integer;
Begin
_vlez:=0;_izlez:=0;_saldo:=0;
vlez[0]:=0;vlez[1]:=0;vlez[2]:=0;vlez[3]:=0;vlez[4]:=0;
vlez[5]:=0;vlez[6]:=0;vlez[7]:=0;vlez[8]:=0;vlez[9]:=0;
izlez[0]:=0;izlez[1]:=0;izlez[2]:=0;izlez[3]:=0;izlez[4]:=0;
izlez[5]:=0;izlez[6]:=0;izlez[7]:=0;izlez[8]:=0;izlez[9]:=0;
saldo[0]:=0;saldo[1]:=0;saldo[2]:=0;saldo[3]:=0;saldo[4]:=0;
saldo[5]:=0;saldo[6]:=0;saldo[7]:=0;saldo[8]:=0;saldo[9]:=0;
Knigo^.GoTop;
first:=false;
gotoxy(3,21+5);write('òïæğö!!');
Repeat
If (First=false) Then
	First:=True
	Else
	Knigo^.NextRec;
val(Knigo^.MyFieldData(3),konto,err);
val(Knigo^.MyFieldData(5),_vlez,err);
val(Knigo^.MyFieldData(6),_izlez,err);
val(Knigo^.MyFieldData(7),_saldo,err);

if (konto<100000) then
	begin
	vlez[0]:=vlez[0]+_vlez;
	izlez[0]:=izlez[0]+_izlez;
	saldo[0]:=saldo[0]+_saldo;
	end;
if ((konto>=100000)and(konto<200000)) then
	begin
	vlez[1]:=vlez[1]+_vlez;
	izlez[1]:=izlez[1]+_izlez;
	saldo[1]:=saldo[1]+_saldo;
	end;
if ((konto>=200000)and(konto<300000)) then
	begin
	vlez[2]:=vlez[2]+_vlez;
	izlez[2]:=izlez[2]+_izlez;
	saldo[2]:=saldo[2]+_saldo;
	end;
if ((konto>=300000)and(konto<400000)) then
	begin
	vlez[3]:=vlez[3]+_vlez;
	izlez[3]:=izlez[3]+_izlez;
	saldo[3]:=saldo[3]+_saldo;
	end;
if ((konto>=400000)and(konto<500000)) then
	begin
	vlez[4]:=vlez[4]+_vlez;
	izlez[4]:=izlez[4]+_izlez;
	saldo[4]:=saldo[4]+_saldo;
	end;
if ((konto>=500000)and(konto<600000)) then
	begin
	vlez[5]:=vlez[5]+_vlez;
	izlez[5]:=izlez[5]+_izlez;
	saldo[5]:=saldo[5]+_saldo;
	end;
if ((konto>=600000)and(konto<700000)) then
	begin
	vlez[6]:=vlez[6]+_vlez;
	izlez[6]:=izlez[6]+_izlez;
	saldo[6]:=saldo[6]+_saldo;
	end;
if ((konto>=700000)and(konto<800000)) then
	begin
	vlez[7]:=vlez[7]+_vlez;
	izlez[7]:=izlez[7]+_izlez;
	saldo[7]:=saldo[7]+_saldo;
	end;
if ((konto>=800000)and(konto<900000)) then
	begin
	vlez[8]:=vlez[8]+_vlez;
	izlez[8]:=izlez[8]+_izlez;
	saldo[8]:=saldo[8]+_saldo;
	end;
if (konto>=900000) then
	begin
	vlez[9]:=vlez[9]+_vlez;
	izlez[9]:=izlez[9]+_izlez;
	saldo[9]:=saldo[9]+_saldo;
	end;
until Knigo^.DBEOF;
konto:=0;
T^.Zap;
te:=-1;
repeat
te:=te+1;
str(te+1,strings);
T^.MyReplace(1,strings);
str(te,strings);
T^.MyReplace(2,'Klasa '+strings);
T^.MyReplace(3,'0');
T^.MyReplace(4,today);
str(vlez[te]:13:2,strings);
T^.MyReplace(5,strings);
str(izlez[te]:13:2,strings);
T^.MyReplace(6,strings);
str(saldo[te]:14:2,strings);
T^.MyReplace(7,strings);
T^.AppendCurrent;
until te=9;
gotoxy(3,21+5);write('        ');
if kade='E' then show_obicno;
cistenje;
end;

procedure firmidat;
label Pak,Cr,Kraj,Poc;
var y,gore,pos:longint;
	 temp:string[4];{Ovde se izmeni}
	 tempStr:String[31];
	 temp1,temp2,temp3,err:integer;
	 LastRec:Boolean;
begin
hide_mouse;
y:=1;
gore:=1;
pos:=1;
cistenje;
display1;
Cr:
show1(y,gore);
Pak:
repeat
ch:=readkey;
if ch=#13 then
	begin
	if (Firmi^.RecCount=0) then
		goto Pak;
	Firmi^.GetDbRec(pos);
	TempStr:=Firmi^.MyFieldData(2);
	cursoron;
	edit_text(TempStr,27,5+y-1);
	cursoroff;
	Firmi^.MyReplace(2,TempStr);
	Firmi^.Save;
	Goto Cr;
	end;
if ch=#0 then
	begin
	ch:=readkey;
	if ch='R' then{Insert}
		begin
		Firmi^.GoBottom;
		temp:=Firmi^.MyFieldData(1);
      if temp='999' then
			begin
         beep;
         goto Pak;
         end;
      pos:=Firmi^.RecCount;
      if pos>13 then
         begin
         y:=13;
			gore:=pos-12;
         end
         else
         begin
         gore:=1;
         y:=pos;
         end;
      Show1(y,gore);
		val(temp,temp1,err);
		temp1:=temp1+1;
		str(temp1,temp);
		if (Firmi^.RecCount=0) then
			temp:='1';
		Firmi^.MyReplace(1,temp);
		Firmi^.MyReplace(2,'');
		Firmi^.AppendCurrent;
		pos:=pos+1;
		if (y=13) Then
			gore:=gore+1
			else
			y:=y+1;
		show1(y,gore);
		Firmi^.Save;
		show1(y,gore);
		end;
	if ch='S' then {Delete}
		begin
		if (Firmi^.RecCount=0) then
			goto Pak;
		Firmi^.GetDbRec(pos);
		temp:=Firmi^.MyFieldData(1);
		Knigo^.GoTop;
		If (Knigo^.RecCount>0)Then
			For Temp1:=1 To Knigo^.RecCount Do
				Begin
				Knigo^.GetDBRec(Temp1);
				TempStr:=Knigo^.MyFieldData(3);
				If((Copy(TempStr,1,3)='120')Or(Copy(TempStr,1,3)='220'))Then
					Begin
					Val(Copy(TempStr,4,3),Temp2,Err);
					TempStr:=Firmi^.MyFieldData(1);
					Val(TempStr,Temp3,Err);
					If (temp2=temp3)Then
						Begin
						Tk;
						Goto Pak;
						End;
					End;
				End;
		LastRec:=Firmi^.DBEOF;
		Firmi^.DbDelete;
		Firmi^.Save;
		Firmi^.Pack;
		If(Firmi^.RecCount=0)Then
			Begin
			display1;
			Goto Pak;
			end;
		If(pos=Firmi^.RecCount+1)Then
			Begin
			If(gore>1)Then
				gore:=gore-1
				Else
				y:=y-1;
			pos:=pos-1;
			End;
		If(LastRec)Then
			Begin
			show1(y,gore);
			Goto Pak;
			end;
		Firmi^.GetDbRec(pos);
{		if (Firmi^.RecCount=1) then goto Kraj;}
		temp:=Firmi^.MyFieldData(1);
		val(temp,temp1,err);
		temp1:=temp1-1;
		str(temp1,temp);
		Firmi^.MyReplace(1,temp);
		Firmi^.Save;
		if (Firmi^.DbEof) then goto Kraj;
      repeat
      Firmi^.NextRec;
      temp:=Firmi^.MyFieldData(1);
      val(temp,temp1,err);
      temp1:=temp1-1;
      str(temp1,temp);
      Firmi^.MyReplace(1,temp);
      Firmi^.Save;
      until Firmi^.DbEof;
      Kraj:
      show1(y,gore);
      end;

   if ch='H' then
      begin
      if pos=1 then
         begin
         beep;
         goto Pak;
         end;
      pos:=pos-1;
      if y=1 then gore:=gore-1 else y:=y-1;
      show1(y,gore);
      end;
   if ch='P' then
      begin
      if pos=Firmi^.RecCount then
         begin
         beep;
         goto Pak;
         end;
      pos:=pos+1;
      if y=13 then gore:=gore+1 else y:=y+1;
      end;
   show1(y,gore);
   goto Pak;
   end;
until (ch=#27);
cistenje;
show_mouse;
end;

procedure newa;{                         CREATE                              }
label Od_Ovde,Pak,Add,Lop,Kraj;
var temp:byte;
    _L:longint;
    S2,S4:string[20];
    r1,r2,vl,iz,sa:real;
    er,r:integer;
    _case:shortint;
begin
hide_mouse;
cistenje;
Od_ovde:
vl:=0;
iz:=0;
sa:=0;
temp:=4;
if (Knigo^.RecCount=0) then goto Add;
temp:=0;
Knigo^.GoTop;
repeat
if temp=0 then temp:=1 else Knigo^.NextRec;
val(Knigo^.MyFieldData(5),r1,er);
vl:=vl+r1;
val(Knigo^.MyFieldData(6),r1,er);
iz:=iz+r1;
val(Knigo^.MyFieldData(7),r1,er);
sa:=sa+r1;
until Knigo^.DBEOF;
Knigo^.GoBottom;
textcolor(7);
str(vl:13:2,S2);
gotoxy(38,19+5);write(S2);
str(iz:13:2,S2);
gotoxy(52,19+5);write(S2);
str(sa:14:2,S2);
gotoxy(66,19+5);write(S2);
Add:
_case:=1;
Knigo^.MyReplace(1,'1');
Knigo^.MyReplace(2,'');
Knigo^.MyReplace(3,'0');
Knigo^.MyReplace(4,today);
Knigo^.MyReplace(5,'0');
Knigo^.MyReplace(6,'0');
Knigo^.MyReplace(7,'0');
Knigo^.AppendCurrent;

if Knigo^.RecCount>1 then
	begin
	Knigo^.Save;
	Knigo^.PrevRec;
	S2:=Knigo^.MyFieldData(4);
	val(Knigo^.MyFieldData(1),r,er);
	Knigo^.NextRec;
	Knigo^.MyReplace(4,S2);
	if r=9999 then r:=0;
	r:=r+1;
	str(r,S2);
	Knigo^.MyReplace(1,S2);
	end;
Knigo^.Save;
if (Knigo^.RecCount>12+5) then
	begin
	show({13+5}0,Knigo^.RecCount-12-5);
	end
	else
	begin
	show({Knigo^.RecCount}0,1);
	end;
gotoxy(2,21+1);write(Knigo^.MyFieldData(1));
textbackground(0);
gotoxy(7,21+1);write(Knigo^.MyFieldData(2));
gotoxy(22,21+1);write(Knigo^.MyFieldData(3));
gotoxy(29,21+1);write(Knigo^.MyFieldData(4));
gotoxy(38,21+1);write(Knigo^.MyFieldData(5));
gotoxy(52,21+1);write(Knigo^.MyFieldData(6));
textbackground(1);
gotoxy(66,21+1);write(Knigo^.MyFieldData(7));
textbackground(0);
S2:=Knigo^.MyFieldData(2);
val(Knigo^.MyFieldData(3),_L,er);
S4:=Knigo^.MyFieldData(4);
val(Knigo^.MyFieldData(5),r1,er);
val(Knigo^.MyFieldData(6),r2,er);
cursoron;
Lop:
case _case of
	0:
	Begin
	If ((r1=0)And(r2=0))Then
		Begin
		_case:=4;
		Goto Lop;
		End;
	cursoroff;
	Knigo^.MyReplace(2,S2);
	Str(_L:6,S2);
	Knigo^.MyReplace(3,S2);
	Knigo^.MyReplace(4,S4);
	Str(r1:13:2,S2);
	Knigo^.MyReplace(5,S2);
	Str(r2:13:2,S2);
	Knigo^.MyReplace(6,S2);
	Str(r1-r2:14:2,S2);
	Knigo^.MyReplace(7,S2);
	vl:=vl+r1;
	iz:=iz+r2;
	sa:=sa+r1-r2;
	Knigo^.Save;
	if ((Knigo^.MyFieldData(2)='.             ')and(Knigo^.RecNo>1)) Then
		begin
		Knigo^.PrevRec;
		S2:=Knigo^.MyFieldData(2);
		Knigo^.NextRec;
		Knigo^.MyReplace(2,S2);
		Knigo^.Save;
		end;
	textbackground(1);
	str(vl:13:2,S2);
	gotoxy(38,19+5);write(S2);
	str(iz:13:2,S2);
	gotoxy(52,19+5);write(S2);
	str(sa:14:2,S2);
	gotoxy(66,19+5);write(S2);
	textbackground(1);
	if (Knigo^.RecCount>12+5) then
		show(13,Knigo^.RecCount-12-5)
		else
		show(Knigo^.RecCount,1);
	Knigo^.Save;
	goto Add;
	end;
	1:
	begin
	_case:=edit_text(S2,7,21+1);
	if(_case=0)then
		_case:=2
		else
		if(_case=1)then
			_case:=2
			else
			if(_case=-1)then
				_case:=1;
	goto Lop;
	end;
	2:
	begin
	_case:=edit_normal(_L,22,21+1,6);
	if(_case=0)then
		_case:=3
		else
		if _case=1 then
			_case:=3
			else
			if _case=-1 then
			_case:=1;
	  goto Lop;
	  end;
	  3:
	  begin
	  _case:=edit_data(S4,29,21+1);
	  if _case=0 then _case:=4
	  else
	  if _case=1 then _case:=4
	  else
	  if _case=-1 then _case:=2;
	  goto Lop;
	  end;
	  4:
	  begin
	  _case:=edit_real(r1,38,21+1,13);
	  if _case=0 then _case:=5
	  else
	  if _case=1 then _case:=5
	  else
	  if _case=-1 then _case:=3;
	  goto Lop;
	  end;
	  5:
	  begin
	  _case:=edit_real(r2,52,21+1,13);
	  if _case=1 then _case:=5
	  else
	  if _case=-1 then _case:=4;
	  goto Lop;
	  end;
	  10:
	  begin
	  cursoroff;
	  Knigo^.DBDelete;
	  Knigo^.Save;
	  Knigo^.Pack;
	  goto kraj;
	  end;
  end;
Kraj:
show_mouse;
cistenje;
end;

procedure Pregled;{                         PREGLED                          }
var _t:boolean;
	 _ts:string[10];
label S,Kraj;
begin
cistenje;
if Knigo^.RecCount=0 then
   begin
   textcolor(7);
   gotoxy(8,21);write('æïà óòäàöòûê èà óôæãíæäøâàñæ.');
   sound(200);
   delay(200);
   nosound;
   delay(1000);
   gotoxy(8,21);write('                              ');
   goto Kraj;
   end;
textcolor(7);
gotoxy(2,2);write('N     èà ’áêüæğ óôæãíæä');
gotoxy(2,3);write('A     èà €ğàíêöêìà');
gotoxy(2,4);write('S     èà •êğöæöêìà');
gotoxy(2,5);write('K     èà Œíàõê');
gotoxy(2,6);write('B     èà êíàğõ');
gotoxy(2,7);write('ENTER èà ˆàìíøüæğ êõö');
gotoxy(2,8);write('ESC   èà Šèíæè');
s:
ch:=readkey;
if ch=#0 then
   begin
   ch:=readkey;
   goto s;
   end;
if ((ch<>'N')and(ch<>'n')and(ch<>'A')and(ch<>'a')and
   (ch<>'S')and(ch<>'s')and(ch<>'B')and(ch<>'b')and
   (ch<>'K')and(ch<>'k')and(ch<>#13)and(ch<>#27)) then goto s;
cistenje;
if (ch='N')or(ch='n') then _ts:=normal('E')
else
if (ch='A')or(ch='a') then _ts:=Analitika('E')
else
if (ch='S')or(ch='s') then _ts:=Sintetika('E')
else
if (ch='B')or(ch='b') then BBilans('E',6)
else
if (ch='K')or(ch='k') then _ts:=Klasa('E')
else
if (ch=#13) then ZList('E');
Kraj:
end;{                        KRAJ PREGLED                                    }

procedure edituvanje;{                        EDITUVANJE                     }
var temp,y,pos,gore:longint;
    s:string[14];
    r1,r2,r3,r4,rt1,rt2,rt3:real;
    err,er:integer;
    _case:shortint;
    s1,s3:string[20];
    s2:longint;
    s4,s5:real;
    Del:Boolean;
label Kraj,LLop1,Pak,Lop;
begin
Del:=False;
hide_mouse;
cistenje;
if Knigo^.RecCount=0 then
   begin
   textcolor(7);
   gotoxy(8,21);write('æïà óòäàöòûê èà æäêöøâàñæ.');
   sound(200);
   delay(200);
   nosound;
   delay(1000);
   gotoxy(8,21);write('                           ');
   goto Kraj;
   end;
r1:=0;
r2:=0;
r3:=0;
er:=0;
y:=1;
pos:=1;
gore:=1;
Knigo^.GoTop;
repeat
if (er=0) then er:=1 else
   Knigo^.NextRec;
val(Knigo^.MyFieldData(5),r4,err);
r1:=r1+r4;
val(Knigo^.MyFieldData(6),r4,err);
r2:=r2+r4;
val(Knigo^.MyFieldData(7),r4,err);
r3:=r3+r4;
until (Knigo^.RecNo=Knigo^.RecCount);
textcolor(7);
str(r1:13:2,s);
gotoxy(38,19+5);write(s);
str(r2:13:2,s);
gotoxy(52,19+5);write(s);
str(r3:14:2,s);
gotoxy(66,19+5);write(s);
show(y,gore);
Pak:
temp:=0;
LLop1:
ch:=readkey;
if (ch=#27) then goto Kraj;
if (ch=#13) then
   begin
   textbackground(1);
   Knigo^.GetDbRec(pos);
   gotoxy(2,y+4);write(Knigo^.MyFieldData(1)
   ,'º',Knigo^.MyFieldData(2),'º',Knigo^.MyFieldData(3)
   ,'º',Knigo^.MyFieldData(4),'º',Knigo^.MyFieldData(5)
   ,'º',Knigo^.MyFieldData(6),'º',Knigo^.MyFieldData(7));
   textbackground(0);
   gotoxy(7,y+4);write(Knigo^.MyFieldData(2));
   gotoxy(22,y+4);write(Knigo^.MyFieldData(3));
   gotoxy(29,y+4);write(Knigo^.MyFieldData(4));
   gotoxy(38,y+4);write(Knigo^.MyFieldData(5));
   gotoxy(52,y+4);write(Knigo^.MyFieldData(6));
   textbackground(1);
   cursoron;
   _case:=1;
   s1:=Knigo^.MyFieldData(2);
   val(Knigo^.MyFieldData(3),s2,err);
   s3:=Knigo^.MyFieldData(4);
   val(Knigo^.MyFieldData(5),s4,err);
   val(Knigo^.MyFieldData(6),s5,err);
   Lop:
   case _case of
   0:   begin
        Knigo^.MyReplace(2,s1);
        str(s2:6,s);
        Knigo^.MyReplace(3,s);
        Knigo^.MyReplace(4,s3);
        str(s4:13:2,s);
        Knigo^.MyReplace(5,s);
        str(s5:13:2,s);
        Knigo^.MyReplace(6,s);
        Knigo^.Save;
        end;
   1:   begin
        _case:=edit_text(s1,7,y+4);
        if _case=0 then _case:=2
        else
        if _case=1 then _case:=2
        else
        if _case=-1 then _case:=1;
        goto Lop;
        end;
   2:   begin
        _case:=edit_normal(s2,22,y+4,6);
        if _case=0 then _case:=3
        else
        if _case=1 then _case:=3
        else
        if _case=-1 then _case:=1;
        goto Lop;
        end;
   3:   begin
        _case:=edit_data(s3,29,y+4);
        if _case=0 then _case:=4
        else
        if _case=1 then _case:=4
        else
        if _case=-1 then _case:=2;
        goto Lop;
        end;
   4:   begin
        _case:=edit_real(s4,38,y+4,13);
        if _case=0 then _case:=5
        else
        if _case=1 then _case:=5
        else
        if _case=-1 then _case:=3;
        goto Lop;
        end;
   5:   begin
        _case:=edit_real(s5,52,y+4,13);
        if _case=1 then _case:=5
        else
        if _case=-1 then _case:=4;
        goto Lop;
        Del:=False;
        end;
   10:  begin
        If (Del) Then
           Begin
           Knigo^.DBDelete;
           Knigo^.Save;
           Knigo^.Pack;
           For temp:=y+gore-1 to Knigo^.RecCount Do
               Begin
               Knigo^.GetDbRec(Temp);
               Str(temp,s);
               Knigo^.MyReplace(1,s);
               Knigo^.Save;
               End;
           End;
        Del:=False;
        End;
   end;
   cursoroff;
   val(Knigo^.MyFieldData(5),r1,err);
   val(Knigo^.MyFieldData(6),r2,err);
   str(r1-r2:14:2,s);
   Knigo^.MyReplace(7,s);
   Knigo^.Save;
   show(y,gore);
   r1:=0;
   r2:=0;
   r3:=0;
   er:=0;
   Knigo^.GoTop;
   repeat
   if (er=0) then er:=1 else
      Knigo^.NextRec;
   val(Knigo^.MyFieldData(5),r4,err);
   r1:=r1+r4;
   val(Knigo^.MyFieldData(6),r4,err);
   r2:=r2+r4;
   val(Knigo^.MyFieldData(7),r4,err);
   r3:=r3+r4;
   until Knigo^.DBEOF;
   str(r1:13:2,s);
	gotoxy(38,19+5);write(s);
	str(r2:13:2,s);
	gotoxy(52,19+5);write(s);
	str(r3:14:2,s);
	gotoxy(66,19+5);write(s);
   goto LLop1;
   end;
if (ch=#0) then
   begin
   ch:=readkey;
   if (ch='H')or(ch='P')or(ch='I')or(ch='Q')or(ch='G')or(ch='O')or(ch='R') then
      begin
      if ch='G' then {Home}
         begin
         y:=1;
         gore:=1;
         pos:=1;
         show(y,gore);
         Goto LLop1;
         end;
      if ch='O' then {End}
         begin
			if Knigo^.RecCount>13+5 then
				begin
				if gore+13+5>Knigo^.RecCount then
					begin
					y:=Knigo^.RecCount-gore+1;
					pos:=Knigo^.RecCount;
					show(y,gore);
					goto LLop1;
					end;
				y:=13+5;
				gore:=Knigo^.RecCount-12-5;
				pos:=Knigo^.RecCount;
				show(y,gore);
				end
				else
				begin
				gore:=1;
				y:=Knigo^.RecCount;
				pos:=y;
				show(y,gore);
				end;
			Goto LLop1;
			end;
		if ch='I' then {pgup}
			begin
			if pos=1 then
				begin
				beep;
				goto LLop1;
				end;
			if gore=1 then
				begin
				pos:=1;
				y:=1;
				show(y,gore);
				goto LLop1;
				end;
			if gore<14+5 then
            begin
            pos:=y;
            gore:=1;
            show(y,gore);
            goto LLop1;
            end;
			pos:=pos-13-5;
			gore:=gore-13-5;
			show(y,gore);
			goto LLop1;
			end;
		if ch='Q' then {pgdn}
			begin
			if pos+13+5>Knigo^.RecCount then
				begin
				beep;
				goto LLop1;
				end;
			pos:=pos+13+5;
			gore:=gore+13+5;
			show(y,gore);
			end;
		if (pos=1)and(ch='H') then
			begin
			beep;
			goto LLop1;
			end;
		if (pos+1>Knigo^.RecCount)and(ch='P') then
			begin
			beep;
			goto LLop1;
			end;
		if ch='H' then pos:=pos-1;
		if ch='P' then pos:=pos+1;
		if (ch='H')and(y=1) then
			begin
			gore:=gore-1;
			show(y,gore);
			Goto LLop1;
			end;
		if (ch='P')and(y=13+5) then
			begin
			gore:=gore+1;
			show(y,gore);
			goto LLop1;
			end;
		if ch='H' then y:=y-1;
		if ch='P' then y:=y+1;
		if ch='R' then
			Begin
			asm
			mov ah,5
			mov cx,$1C0D
			int $16
			end;
			Knigo^.AppendBlankAt(gore+y-1);
			Knigo^.MyReplace(3,'0');
			Knigo^.MyReplace(5,'0.00');
			Knigo^.MyReplace(6,'0.00');
			Knigo^.MyReplace(7,'0.00');
			Knigo^.Save;
			For temp:=Knigo^.RecNo to Knigo^.RecCount Do
				 Begin
				 Knigo^.GetDbRec(Temp);
				 Str(temp,s);
				 Knigo^.MyReplace(1,s);
				 Knigo^.Save;
				 End;
			Del:=True;
			End;
		end;
	end;
show(y,gore);
goto LLop1;
Kraj:
cistenje;
show_mouse;
end;

procedure brishenje;{                        BRISHENJE                       }
var temp,y,gore,pos:longint;
	 s:string[14];
	 er,err:integer;
    r1,r2,r3,r4:real;
label Kraj,LLop1,Pak,Del1;
begin
hide_mouse;
cistenje;
y:=1;
pos:=1;
gore:=1;
Pak:
temp:=0;
Del1:
if Knigo^.RecCount=0 then
   begin
   textcolor(7);
   gotoxy(8,21);write('æïà óòäàöòûê èà áôêşæñæ.');
   sound(200);
   delay(200);
   nosound;
   delay(1000);
   gotoxy(8,21);write('                         ');
   goto Kraj;
   end;
r1:=0;
r2:=0;
r3:=0;
er:=0;
Knigo^.GoTop;
repeat
if (er=0) then er:=1 else
   Knigo^.NextRec;
val(Knigo^.MyFieldData(5),r4,err);
r1:=r1+r4;
val(Knigo^.MyFieldData(6),r4,err);
r2:=r2+r4;
val(Knigo^.MyFieldData(7),r4,err);
r3:=r3+r4;
until Knigo^.DBEOF;
textcolor(7);
str(r1:13:2,s);
gotoxy(38,19+5);write(s);
str(r2:13:2,s);
gotoxy(52,19+5);write(s);
str(r3:14:2,s);
gotoxy(66,19+5);write(s);
show(y,gore);
LLop1:
if Knigo^.RecCount=0 then
   begin
   textcolor(7);
   gotoxy(8,21);write('æïà óòäàöòûê èà áôêşæñæ.');
   sound(200);
   delay(200);
   nosound;
   delay(1000);
   gotoxy(8,21);write('                         ');
   goto Kraj;
   end;
ch:=readkey;
if (ch<>#0)and(ch<>#13)and(ch<>#27) then goto LLop1;
if (ch=#27) then goto Kraj;
if (ch=#13) then
   begin
	gotoxy(8,21+5);write('„àíê öôæáà äà õæ êèáôêşæ òäáôàğêòö RECORD(D/N)?');
	repeat
	ch:=readkey;
	until((ch='D')or(ch='d')or(ch='N')or(ch='n')or(ch=#27));
	gotoxy(8,21+5);write('                                               ');
	if (ch<>'D')and(ch<>'d') then
		begin
		if ch=#0 then ch:=readkey;
		goto Llop1;
		end;
	Knigo^.GetDbRec(pos);
	Knigo^.DbDelete;
	Knigo^.Save;
	Knigo^.Pack;
	if Knigo^.RecCount=0 then
		begin
		textcolor(7);
		gotoxy(8,21+5);write('æïà óòäàöòûê èà óôæãíæäøâàñæ.');
		sound(200);
		delay(200);
		nosound;
		delay(1000);
		gotoxy(8,21+5);write('                              ');
		goto Kraj;
      end;
   if (pos>Knigo^.RecCount)and(y=1) then
      begin
      pos:=pos-1;
      gore:=gore-1;
      end;
   if (pos>Knigo^.RecCount)and(y<>1) then
      begin
      pos:=pos-1;
      y:=y-1;
      end;
   Knigo^.GetDbRec(pos);
   if (pos<=Knigo^.RecCount) then
      begin
      Knigo^.GetDbRec(pos);
		gotoxy(2,21+5);writeln('Go izmenuvam redniot broj.');{ Smeni na kirilica }
      er:=Knigo^.RecNo;
      if (Knigo^.RecNo>9999)then
         begin
         repeat
         er:=er-9999;
         until (er>9999);
         str(er,s);
         end
         else
         str(Knigo^.RecNo,s);
      Knigo^.MyReplace(1,s);
      Knigo^.Save;
      repeat
      Knigo^.NextRec;
      er:=Knigo^.RecNo;
      if (Knigo^.RecNo>9999)then
         begin
         repeat
         er:=er-9999;
         until (er>9999);
         str(er,s);
         end
         else
         str(Knigo^.RecNo,s);
      Knigo^.MyReplace(1,s);
      Knigo^.Save;
      until Knigo^.DBEOF;
		gotoxy(2,21+5);writeln('                          ');
      end;
	show(y,gore);
	goto Del1;
	end;
if (ch=#0) then
	begin
	ch:=readkey;
	if (ch='H')or(ch='P')or(ch='I')or(ch='Q')or(ch='G')or(ch='O') then {gore ili dole ili pgup ili pgdown ili home ili end}
		begin
		if ch='G' then {Home}
			begin
			y:=1;
			gore:=1;
			pos:=1;
			show(y,gore);
			Goto LLop1;
			end;
		if ch='O' then {End}
			begin
			if Knigo^.RecCount>13+5 then
				begin
				if gore+13+5>Knigo^.RecCount then
					begin
					y:=Knigo^.RecCount-gore+1;
					pos:=Knigo^.RecCount;
					show(y,gore);
					goto LLop1;
					end;
				y:=13+5;
				gore:=Knigo^.RecCount-12-5;
				pos:=Knigo^.RecCount;
				show(y,gore);
				end
				else
				begin
				gore:=1;
				y:=Knigo^.RecCount;
				pos:=y;
				show(y,gore);
				end;
			Goto LLop1;
			end;
		if ch='I' then {pgup}
			begin
			if pos=1 then
				begin
				beep;
				goto LLop1;
				end;
			if gore=1 then
				begin
				pos:=1;
				y:=1;
				show(y,gore);
				goto LLop1;
				end;
			if gore<14+5 then
				begin
				pos:=y;
				gore:=1;
				show(y,gore);
				goto LLop1;
				end;
			pos:=pos-13-5;
			gore:=gore-13-5;
			show(y,gore);
			goto LLop1;
			end;
		if ch='Q' then {pgdn}
			begin
			if pos+13+5>Knigo^.RecCount then
				begin
				beep;
				goto LLop1;
				end;
			pos:=pos+13+5;
			gore:=gore+13+5;
			show(y,gore);
			end;
		if (pos=1)and(ch='H') then
			begin
			beep;
			goto LLop1;
			end;
		if (pos+1>Knigo^.RecCount)and(ch='P') then
         begin
         beep;
         goto LLop1;
         end;
      if ch='H' then pos:=pos-1;
      if ch='P' then pos:=pos+1;
      if (ch='H')and(y=1) then
         begin
         gore:=gore-1;
         show(y,gore);
         Goto LLop1;
         end;
		if (ch='P')and(y=13+5) then
         begin
         gore:=gore+1;
         show(y,gore);
         goto LLop1;
         end;
      if ch='H' then y:=y-1;
      if ch='P' then y:=y+1;
      end;
   end;
show(y,gore);
goto LLop1;
Kraj:
cistenje;
show_mouse;
end;

procedure pr;
var ts1,ts2,ts3,ts4:string[14];
    tr1,tr2,sv,si,ssv,ssi,tt:real;
    err:integer;
label Kraj,Eerr;
begin
if T^.RecCount=0 then goto Kraj;
sv:=0;
si:=0;
ssv:=0;
ssi:=0;
ch:=#13;
shtampa(ch);
shtampa('ÖÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄ·'+#13+#10);
shtampa('ºBr  º    Naziv     ºKonto º  Data  º    Vlez     º    Izlez    º Saldo vlez  º Saldo izlez º'+#13+#10);
shtampa('ÇÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄ¶'+#13+#10);
T^.GoTop;
ch:=#0;
repeat
if ch=#0 then ch:=#1 else
T^.NextRec;
val(T^.MyFieldData(7),tr1,err);
val(T^.MyFieldData(5),tt,err);
sv:=sv+tt;
val(T^.MyFieldData(6),tt,err);
si:=si+tt;
if tr1=0 then
   begin
   ts1:='         0.00';
   ts2:='         0.00';
   end;
if tr1>0 then
   begin
   str(tr1:13:2,ts1);
   ssv:=ssv+tr1;
   ts2:='         0.00';
   end;
if tr1<0 then
   begin
   tr1:=-tr1;
   ssi:=ssi+tr1;
   str(tr1:13:2,ts2);
   ts1:='         0.00';
   end;
shtampa('º'+T^.MyFieldData(1)+'º'+T^.MyFieldData(2)+'º'+T^.MyFieldData(3)
+'º'+T^.MyFieldData(4)+'º'+T^.MyFieldData(5)+'º'+T^.MyFieldData(6)+'º'
+ts1+'º'+ts2+'º'+#13+#10);
until (T^.DBEOF);
shtampa('ÓÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄ¶'+#13+#10);
str(sv:13:2,ts1);
str(si:13:2,ts2);
str(ssv:13:2,ts3);
str(ssi:13:2,ts4);
shtampa('                                    º'+ts1+      'º'+ts2+      'º'+ts3+      'º'+ts4+      'º'+#13+#10);
shtampa('                                    ÓÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄ½'+#13+#10);
goto Kraj;
Eerr:
gotoxy(2,21);write('Greshka pri pecatenje, greshka br:',err);
Kraj:
end;

procedure printanje;
label s,Kraj;
var _ts:string[10];
    LKonto:LongInt;
    FKonto:LongInt;
    Kon   :LongInt;
    Found :Boolean;
    Recor:Word;
    Err:Integer;
    TST:String[1];
begin
cistenje;
textcolor(7);
if Knigo^.RecCount=0 then
   begin
   gotoxy(8,21);write('æïà óòäàöòûê èà óæüàöæñæ.');
   goto Kraj;
   end;
{if (initprinter<>144) then
   begin
   textcolor(7);
   gotoxy(2,21);write('æ ïòçàï äà ìòïøğêûêôàï õò óæüàöàôòö,ãôæşìà áô:',initprinter,'.');
   goto Kraj;
   end;}
textcolor(7);
gotoxy(2,2);write('N     èà ’áêüæğ óôæãíæä');
gotoxy(2,3);write('A     èà €ğàíêöêìà');
gotoxy(2,4);write('S     èà •êğöæöêìà');
gotoxy(2,5);write('K     èà Œíàõê');
gotoxy(2,6);write('B     èà êíàğõ');
gotoxy(2,7);write('ENTER èà ˆàìíøüæğ êõö');
gotoxy(2,8);write('ESC   èà Šèíæè');
s:
ch:=readkey;
if ch=#0 then
   begin
   ch:=readkey;
   goto s;
   end;
if (ch<>'N')and(ch<>'n')and
   (ch<>'A')and(ch<>'a')and
   (ch<>'S')and(ch<>'s')and
   (ch<>'B')and(ch<>'b')and
   (ch<>'K')and(ch<>'k')and
   (ch<>#13)and(ch<>#27) then goto s;
if (ch=#27) then
   begin
   cistenje;
   goto Kraj;
   end;
if (ch='N')or(ch='n') then { Normal View }
   begin
   _ts:=normal('P');
   shtampa('Obicen listing'+#13+#10);
   pr;
   end;
if (ch='A')or(ch='a') then { Analitika View }
   begin
   _ts:=analitika('P');
   if (_ts='') then
      Begin
      Kon:=0;
      Repeat
      Found:=False;
      LKonto:=Kon;
      Kon:=1000000;
      For Recor:=1 to Knigo^.RecCount do
          Begin
          Knigo^.GetDbRec(Recor);
          Val(Knigo^.MyFieldData(3),FKonto,Err);
          If ((FKonto>LKonto)And(FKonto<Kon)) Then
             Begin
             Found:=True;
             Kon:=FKonto;
             End;
          End;
      If (Found) Then
         Begin
         T^.Zap;
         For Recor:=1 to Knigo^.RecCount do
             Begin
             Knigo^.GetDbRec(Recor);
             Val(Knigo^.MyFieldData(3),FKonto,Err);
             If (FKonto=Kon) Then
                Begin
                T^.MyReplace(1,Knigo^.MyFieldData(1));
                T^.MyReplace(2,Knigo^.MyFieldData(2));
                T^.MyReplace(3,Knigo^.MyFieldData(3));
                T^.MyReplace(4,Knigo^.MyFieldData(4));
                T^.MyReplace(5,Knigo^.MyFieldData(5));
                T^.MyReplace(6,Knigo^.MyFieldData(6));
                T^.MyReplace(7,Knigo^.MyFieldData(7));
                T^.AppendBlank;
                End;
             End;
         Str(Kon,_ts);
         shtampa(#13+#10);
         shtampa('Analitika        konto br:'+_ts+#13+#10);
         pr;
         End;
      Until(Found=False);
      End
      Else
      Begin
      shtampa('Analitika        konto br:'+_ts+#13+#10);
      pr;
      End;
   end;
if (ch='S')or(ch='s') then { Sintetika View }
   begin
   _ts:=sintetika('P');
   If (_ts='')Then
      Begin
      Kon:=0;
      Repeat
      Found:=False;
      LKonto:=Kon;
      Kon:=1000;
      For Recor:=1 to Knigo^.RecCount do
          Begin
          Knigo^.GetDbRec(Recor);
          Val(Copy(Knigo^.MyFieldData(3),1,3),FKonto,Err);
          If ((FKonto>LKonto)And(FKonto<Kon)) Then
             Begin
             Found:=True;
             Kon:=FKonto;
             End;
          End;
      If (Found) Then
         Begin
         T^.Zap;
         For Recor:=1 to Knigo^.RecCount do
             Begin
             Knigo^.GetDbRec(Recor);
             Val(Copy(Knigo^.MyFieldData(3),1,3),FKonto,Err);
             If (FKonto=Kon) Then
                Begin
                T^.MyReplace(1,Knigo^.MyFieldData(1));
                T^.MyReplace(2,Knigo^.MyFieldData(2));
                T^.MyReplace(3,Knigo^.MyFieldData(3));
                T^.MyReplace(4,Knigo^.MyFieldData(4));
                T^.MyReplace(5,Knigo^.MyFieldData(5));
                T^.MyReplace(6,Knigo^.MyFieldData(6));
                T^.MyReplace(7,Knigo^.MyFieldData(7));
                T^.AppendBlank;
                End;
             End;
         Str(Kon,_ts);
         shtampa(#13+#10);
         shtampa('Sintetika        konto br:'+_ts+#13+#10);
         pr;
         End;
      Until(Found=False);
      End
      Else
      Begin
      shtampa('Sintetika'+#13+#10);
      shtampa('Konto:'+_ts+#13+#10);
      pr;
      End;
   End;
if (ch='B')or(ch='b') then { BBilans View }
   begin
   GotoXy(3,21);
   WriteLn('Analiticen ili Sinteticen BBilans:');
   TST:='A';
   repeat
   cursoron;
   Edit_Text(TST,37,21);
   cursoroff;
   until ((TST='A')or(TST='a')or(TST='S')or(TST='s'));
   cistenje;
   If ((TST='A')or(TST='a')) Then
      Begin
      BBilans('P',6);
      shtampa('Analiticki bruto bilans'+#13+#10);
      End
      else
      Begin
      BBilans('P',3);
      shtampa('Sinteticki bruto bilans'+#13+#10);
      End;
   pr;
   end;
if (ch='K')or(ch='k') then { Klasa View }
   begin
   _ts:=Klasa('P');
   shtampa('Klasi'+#13+#10);
   shtampa('Klasa br:'+_ts+#13+#10);
   pr;
   end;
if (ch=#13) then { ZList View }
   begin
   ZList('P');
   shtampa('Zaklucen list'+#13+#10);
   pr;
   end;
Kraj:
cistenje;
end;

procedure onkeys(no:byte);
begin
if no=1 then
              begin
              textbackground(2);
              textcolor(15);
              gotoxy(5,28);
              hide_mouse;
              write('‚ğæõøâàñæ');
              textbackground(1);
              gotoxy(4,28);
              write(' ');
              gotoxy(5,29);
              write('         ');
              show_mouse;
              end;
if no=2 then
              begin
              textbackground(2);
              textcolor(15);
              gotoxy(17,28);
              hide_mouse;
              write('“ôæãíæäøâàñæ');
              textbackground(1);
              gotoxy(16,28);
              write(' ');
              gotoxy(17,29);
              write('            ');
              show_mouse;
              end;
if no=3 then
              begin
              textbackground(2);
              textcolor(15);
              gotoxy(32,28);
              hide_mouse;
              write('Šèïæğøâàñæ');
              textbackground(1);
              gotoxy(31,28);
              write(' ');
              gotoxy(32,29);
              write('          ');
              show_mouse;
              end;
if no=4 then
              begin
              textbackground(2);
              textcolor(15);
              gotoxy(45,28);
              hide_mouse;
              write('ôêşæñæ');
              textbackground(1);
              gotoxy(44,28);
              write(' ');
              gotoxy(45,29);
              write('       ');
              show_mouse;
              end;
if no=5 then
              begin
              textbackground(2);
              textcolor(15);
              gotoxy(55,28);
              hide_mouse;
              write('“æüàöæñæ');
              textbackground(1);
              gotoxy(54,28);
              write(' ');
              gotoxy(55,29);
              write('        ');
              show_mouse;
              end;
if no=6 then
              begin
              textbackground(2);
              textcolor(15);
              gotoxy(66,28);
              hide_mouse;
              write('“òïòş');
              textbackground(1);
              gotoxy(65,28);
              write(' ');
              gotoxy(66,29);
              write('     ');
              show_mouse;
              end;
if no=7 then
              begin
              textbackground(2);
              textcolor(15);
              gotoxy(74,28);
              hide_mouse;
              write('Šèíæè');
              textbackground(1);
              gotoxy(73,28);
              write(' ');
              gotoxy(74,29);
              write('     ');
              show_mouse;
              end;
end;

procedure offkeys(no:byte);
begin
if (no=0)or(no=1) then
              begin
              textbackground(2);
              textcolor(15);
              gotoxy(4,28);
              hide_mouse;
              write('‚ğæõøâàñæ');
              textbackground(1);
              textcolor(0);
              write('Ü');
              gotoxy(5,29);
              write('ßßßßßßßßß');
              show_mouse;
              end;
if (no=0)or(no=2) then
              begin
              textbackground(2);
              textcolor(15);
              gotoxy(16,28);
              hide_mouse;
              write('“ôæãíæäøâàñæ');
              textbackground(1);
              textcolor(0);
              write('Ü');
              gotoxy(17,29);
              write('ßßßßßßßßßßßß');
              show_mouse;
              end;
if (no=0)or(no=3) then
              begin
              textbackground(2);
              textcolor(15);
              gotoxy(31,28);
              hide_mouse;
              write('Šèïæğøâàñæ');
              textbackground(1);
              textcolor(0);
              write('Ü');
              gotoxy(32,29);
              write('ßßßßßßßßßß');
              show_mouse;
              end;
if (no=0)or(no=4) then
              begin
              textbackground(2);
              textcolor(15);
              gotoxy(44,28);
              hide_mouse;
              write('ôêşæñæ');
              textbackground(1);
              textcolor(0);
              write('Ü');
              gotoxy(45,29);
              write('ßßßßßßß');
              show_mouse;
              end;
if (no=0)or(no=5) then
              begin
              textbackground(2);
              textcolor(15);
              gotoxy(54,28);
              hide_mouse;
              write('“æüàöæñæ');
              textbackground(1);
              textcolor(0);
              write('Ü');
              gotoxy(55,29);
              write('ßßßßßßßß');
              show_mouse;
              end;
if (no=0)or(no=6) then
              begin
              textbackground(2);
              textcolor(15);
              gotoxy(65,28);
              hide_mouse;
              write('“òïòş');
              textbackground(1);
              textcolor(0);
              write('Ü');
              gotoxy(66,29);
              write('ßßßßß');
              show_mouse;
              end;
if (no=0)or(no=7) then
              begin
              textbackground(2);
              textcolor(15);
              gotoxy(73,28);
              hide_mouse;
              write('Šèíæè');
              textbackground(1);
              textcolor(0);
              write('Ü');
              gotoxy(74,29);
              write('ßßßßß');
              show_mouse;
              end;
end;

begin
DirectVideo:=True;
 Asm
 mov ax,00h
 int 33h
 mov is,ax
 End;
If (is<> $FFFF) Then
	Begin
	 Asm
	 mov ax,3
	 int $10
	 End;
	writeln('Nema instalirano gluvce!!');
	{halt(1);}
	End;
 Asm
 mov is,bx
 End;
If (protect) Then
	izlez;
If (FileExists('knigo.dbf'+#0)=False) Then
	MakeKnigo;
If (FileExists('firmi.dbf'+#0)=False) Then
	MakeFirmi;
If (FileExists('temp.dbf'+#0)=True) Then
	asm
	mov ax,4100h
	mov dx,offset Kn
	int 21h
	end;
MakeTemp;
New(Knigo, Init('knigo.dbf'));
New(Firmi, Init('firmi.dbf'));
New(T, Init('temp.dbf'));
textcolor(7);
kraj:=False;
ch:=#1;
 asm
 mov ax,$0003
 int $10
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
 call setmode.smode
 End;
textattr:=$17;
cursoroff;
clrscr;
write('ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ™êğàğõòâò Œğêãòâòäõöâò ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('º                                                                              º');
write('ºÖÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄ·º');
write('ºº           º              º            º         º          º       º       ºº');
write('Ó¶           º              º            º         º          º       º       Ç½');
write(' ÓÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄ½');
offkeys(0);
show_mouse;
repeat;
1:repeat
X:=(GetMouseX div 8)+1;
Y:=(GetMouseY div 8)+1;
if (buttonPressed) then
         begin
         if (y<>28) then
                        begin
                        repeat
                        until (ButtonPressed=false);
                        goto 1;
                        end;
         if (x>3)and(x<14) then
                        begin
                        Off_On:=true;
                        onkeys(1);
                        repeat
                        X:=(GetMouseX div 8)+1;
                        Y:=(GetMouseY div 8)+1;
                        if ((y<>28)or(x<4)or(x>13))and(Off_On) then
                             begin
                             offkeys (1);
                             Off_On:=false;
                             end;
                        if ((y=28)and(x>3)and(x<14))and(Off_On=false) then
                             begin
                             onkeys(1);
                             Off_On:=true;
                             end;
                        until (ButtonPressed=false);
                        if (Off_On) then
                                 begin
                                 offkeys (1);
                                 if (protect=true) then izlez;
                                 hide_mouse;
                                 textbackground(3);
                                 textcolor(15);
                                 gotoxy(4,28);
                                 write('‚ğæõøâàñæ');
                                 textbackground(1);
                                 newa;
                                 offkeys (1);
                                 show_mouse;
                                 end;
                        goto 1;
                        end;
         if (x>15)and(x<29) then
                        begin
                        Off_On:=true;
                        onkeys(2);
                        repeat
                        X:=(GetMouseX div 8)+1;
                        Y:=(GetMouseY div 8)+1;
                        if ((y<>28)or(x<16)or(x>28))and(Off_On) then
                             begin
                             offkeys (2);
                             Off_On:=false;
                             end;
                        if ((y=28)and(x>15)and(x<29))and(Off_On=false) then
                             begin
                             onkeys(2);
                             Off_On:=true;
                             end;
                        until (ButtonPressed=false);
                        if (Off_On) then
                                     begin
                                     offkeys (2);
                                     if (protect=true) then izlez;
                                     hide_mouse;
                                     textbackground(3);
                                     textcolor(15);
                                     gotoxy(16,28);
                                     write('“ôæãíæäøâàñæ');
                                     textbackground(1);
                                     Pregled;
                                     offkeys (2);
                                     show_mouse;
                                     end;
                        goto 1;
                        end;
         if (x>30)and(x<42) then
                        begin
                        Off_On:=true;
                        onkeys(3);
                        repeat
                        X:=(GetMouseX div 8)+1;
                        Y:=(GetMouseY div 8)+1;
                        if ((y<>28)or(x<31)or(x>41))and(Off_On) then
                             begin
                             offkeys (3);
                             Off_On:=false;
                             end;
                        if ((y=28)and(x>30)and(x<42))and(Off_On=false) then
                             begin
                             onkeys(3);
                             Off_On:=true;
                             end;
                        until (ButtonPressed=false);
                        if (Off_On) then
                                     begin
                                     offkeys (3);
                                     if (protect=true) then izlez;
                                     hide_mouse;
                                     textbackground(3);
                                     textcolor(15);
                                     gotoxy(31,28);
                                     write('Šèïæğøâàñæ');
                                     textbackground(1);
                                     Edituvanje;
                                     offkeys (3);
                                     show_mouse;
                                     end;

                        goto 1;
                        end;
         if (x>43)and(x<52) then
                        begin
                        Off_On:=true;
                        onkeys(4);
                        repeat
                        X:=(GetMouseX div 8)+1;
                        Y:=(GetMouseY div 8)+1;
                        if ((y<>28)or(x<44)or(x>51))and(Off_On) then
                             begin
                             offkeys (4);
                             Off_On:=false;
                             end;
                        if ((y=28)and(x>43)and(x<52))and(Off_On=false) then
                             begin
                             onkeys(4);
                             Off_On:=true;
                             end;
                        until (ButtonPressed=false);
                        if (Off_On) then
                                     begin
                                     offkeys (4);
                                     if (protect=true) then izlez;
                                     hide_mouse;
                                     textbackground(3);
                                     textcolor(15);
                                     gotoxy(44,28);
                                     write('ôêşæñæ');
                                     textbackground(1);
                                     Brishenje;
                                     offkeys (4);
                                     show_mouse;
                                     end;
                        goto 1;
                        end;
         if (x>53)and(x<63) then
                        begin
                        Off_On:=true;
                        onkeys(5);
                        repeat
                        X:=(GetMouseX div 8)+1;
                        Y:=(GetMouseY div 8)+1;
                        if ((y<>28)or(x<54)or(x>62))and(Off_On) then
                             begin
                             offkeys (5);
                             Off_On:=false;
                             end;
                        if ((y=28)and(x>53)and(x<63))and(Off_On=false) then
                             begin
                             onkeys(5);
                             Off_On:=true;
                             end;
                        until (ButtonPressed=false);
                        if (Off_On) then
                           begin
                           offkeys (5);
                           if (protect=true) then izlez;
                           hide_mouse;
                           textbackground(3);
                           textcolor(15);
                           gotoxy(54,28);
                           write('“æüàöæñæ');
                           textbackground(1);
                           printanje;
                           offkeys (5);
                           show_mouse;
                           end;
                        goto 1;
                        end;
         if (x>64)and(x<71) then
                        begin
                        Off_On:=true;
                        onkeys(6);
                        repeat
                        X:=(GetMouseX div 8)+1;
                        Y:=(GetMouseY div 8)+1;
                        if ((y<>28)or(x<65)or(x>70))and(Off_On) then
                             begin
                             offkeys (6);
                             Off_On:=false;
                             end;
                        if ((y=28)and(x>64)and(x<71))and(Off_On=false) then
                             begin
                             onkeys(6);
                             Off_On:=true;
                             end;
                        until (ButtonPressed=false);
                        if (Off_On=false) then goto 1;
                        if (Off_On) then
                                 begin
                                 offkeys (6);
                                 end;
                        999:
                        hide_mouse;
                        cistenje;
                        if _help<>0 then
                           begin
                           show_mouse;
                           goto 1;
                           end;
                        repeat;
                        ch:=readkey;
                        until ch=#27;
                        cistenje;
                        offkeys(6);
                        show_mouse;
                        goto 1;
                        end;
         if (x>72)and(x<79) then
                        begin
                        Off_On:=true;
                        onkeys(7);
                        repeat
                        X:=(GetMouseX div 8)+1;
                        Y:=(GetMouseY div 8)+1;
                        if ((y<>28)or(x<73)or(x>78))and(Off_On) then
                             begin
                             offkeys (7);
                             Off_On:=false;
                             end;
                        if ((y=28)and(x>72)and(x<79))and(Off_On=false) then
                             begin
                             onkeys(7);
                             Off_On:=true;
                             end;
                        until (ButtonPressed=false);
                        if (Off_On) then offkeys (7) else goto 1;
								goto K;
                        end;
         end;
if (keypressed) then ch:=readkey;
until ch=#0;
ch:=readkey;
if ch='?' then
   begin
   if (protect=true) then izlez;
   hide_mouse;
   TextAttr:=63;
   gotoxy(4,28);
   write('‚ğæõøâàñæ');
   textbackground(1);
   newa;
   ch:=#255;
   offkeys (1);
   show_mouse;
   end;
if ch='@' then
   begin
   if (protect=true) then izlez;
   hide_mouse;
   TextAttr:=63;
   gotoxy(16,28);
   write('“ôæãíæäøâàñæ');
   textbackground(1);
   Pregled;
   ch:=#255;
   offkeys (2);
   show_mouse;
   end;
if ch='A' then
   begin
   if (protect=true) then izlez;
   hide_mouse;
   TextAttr:=63;
   gotoxy(31,28);
   write('Šèïæğøâàñæ');
   textbackground(1);
   Edituvanje;
   ch:=#255;
   offkeys (3);
   show_mouse;
   end;
if ch='B' then
   begin
   if (protect=true) then izlez;
   hide_mouse;
   TextAttr:=63;
   gotoxy(44,28);
   write('ôêşæñæ');
   textbackground(1);
   Brishenje;
   ch:=#255;
   offkeys (4);
   show_mouse;
   end;
if ch='C' then
   begin
   if (protect=true) then izlez;
   hide_mouse;
   TextAttr:=63;
   gotoxy(54,28);
   write('“æüàöæñæ');
   textbackground(1);
   printanje;
   ch:=#255;
   offkeys (5);
   show_mouse;
   end;
if ((ch=#45)or(ch='D')) then kraj:=true;
if ch=';' then goto 999;
if ch='!' then firmidat;
if ch='?' then
   begin
   onkeys(1);
   repeat
   if keypressed then ch:=readkey;
   if ch=#0 then ch:=readkey;
   until keypressed=false;
   offkeys(1);
   end;
until (kraj);
K:
textbackground(0);
textcolor(7);
hide_mouse;
clrscr;
cursoron;
Dispose(T,Done);
Dispose(Firmi,Done);
Dispose(Knigo,Done);
 Asm
 mov ax,3
 int $10
 mov ax,4100h
 mov dx,offset Kn
 int $21
 End;
End.