{$A+,B+,D+,E-,F-,G+,I+,L+,N+,O-,R+,S+,V+,X+}
{$M 16384,0,655360}
{    identifier: type = value;}
const ln:string[2] =chr($0D)+chr($0A);
type TIdeInfo = record
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
var
	info:array[0..255] of byte;
	_info:array[0..255] of byte;
	sttemp:string;
	temp,tem:byte;
	info1,info2,info3,info4,info5,sb_ver:word;
	f:text;
	Model:TIdeInfo;
	Zashtita:Record
		HD			: TIdeInfo;
		CPUInfo	: LongInt;
		MainBoard: Pointer;

	End;
label t;
begin
for temp:=0 to 255 do info[temp]:=15;
for temp:=0 to 255 do _info[temp]:=14;
asm
 mov di,offset info{0044h}
 mov ax,4f00h
 int 10h
 mov di,offset _info
 mov ax,4f00h
 int 10h
 end;
info[255]:=0;_info[255]:=1;
for temp:=255 downto 1 do
    if (info[temp]<>_info[temp])then
        begin
        sttemp[0]:=chr(temp);
        for tem:=1 to temp do
            sttemp[tem]:=chr(info[tem-1]);
        end;
Assign(f,'info.nfo');
Rewrite(f);
Write(f,'CPU type information:',chr(test8086),ln);
if (test8086>5) then
   Begin

   End;
Write(f,'Bios Vesa Information:',sttemp,ln);
Write(f,'Svga Ram Information:');
for tem:=0 to 255 do
    begin
    asm
    push es
    push 0C000h
    pop es
    xor di,di
    mov al,tem
    mov ah,0
    mov ax,di
    mov al,es:[di]
    mov temp,al
    pop es
    end;
    Write(f,chr(temp));
    _info[tem]:=temp;
    end;
Write(f,ln);
 asm {  HDD    }
 mov al,$EC
 mov dx,$1F7
 out dx,al
 @Lop1:
 in ax,dx
 cmp ax,$FFFF
 je @NoIDE
 and al,$80
 or al,al
 jne @Lop1
 mov cx,50
 mov dx,$1F0
 mov di,offset [Model]
 push ds
 pop es
 @Lop2:
 in ax,dx
 mov es:[di],ah
 inc di
 mov es:[di],al
 inc di
 loop @Lop2
 @NoIDE:
 End;
write(f,'Disk information:');
For tem:=1 To 40 Do write(f,model.model[tem]);
Write(f,ln);
write(f,'Disk serial no:');
For tem:=1 To 20 Do write(f,model.serial[tem]);
Write(f,ln);
Write(f,'SB information:',Chr(Hi(SB_Ver)),' ',Chr(Lo(SB_Ver)));
Close(f);
End.