Var
	PCIrec:Array[1..10] of Record
		PCIbase:word;
		Case integer of
			0:(l:Array[0..63] of longint);
			1:(w:Array[0..127] of word);
			2:(b:Array[0..255] of byte);
			3:(vendor,device,command,status:word;
			rev,prog:byte;class:word;
			cache,latency,header,bist:byte;
			base0,base1,base2,base3,base4,base5,xx0,xx1,rom:longint;
			capab,xx4,xx5,xx6:byte;
			xx3:longint;
			iline,ipin,mingnt,maxlat:byte);
		End;

Procedure OutP(Port:Word;Val:Byte);
Assembler;
Asm
mov dx,Port
mov al,Val
out dx,al
End;

Procedure OutPW(Port,Val:Word);
Assembler;
Asm
mov dx,Port
mov ax,Val
out dx,al
End;

Procedure OutPLong(Port:Word;Val:LongInt);
Assembler;
Asm
mov dx,Port
db $66,$8B,$46,$04 { mov eax,byte ptr Val }
db $66,$EF { out dx,eax }
End;

Function InP(Port:Word):Byte;
Assembler;
Asm
mov dx,Port
in al,dx
End;

Function InPW(Port:Word):Word;
Assembler;
Asm
mov dx,Port
in ax,dx
End;

Function InPLong(Port:Word):LongInt;
Assembler;
Asm
mov dx,Port
db $66,$ED { in eax,dx }
db $66,$C1,$C8,$10 { ror eax,16 }
mov dx,ax
db $66,$C1,$E8,$10 { shr eax,16 }
End;


procedure findPCI(flag:word);
const ROMs:array[0..3] of string[4]=(' 32K',' 64K','128K','256K');
  YesNo:array[boolean] of string[4]=('No ','Yes');
var
  i,j,z,x,max:word;
  hdr:byte;
  PCIid:longint;
  mb,tmp:longint;
  PCIval:array[1..512] of longint;
  PCIvals:integer;
  PCIType:Integer;
  s:string;

label ENDE;

begin
PCItype:=0;mb:=0;
outp($CF8,0);
outp($CFA,0);
If ((flag<>PCI_type2) and (inp($CF8)=0) and (inp($CFA)=0)) Then
	PCItype:=2
	Else
	If (flag<>PCI_type1) Then
		begin
		tmp:=inplong($CF8);
		for i:=1 to 10 do; {delay}
		outplong($CF8,$80000000);
		for i:=1 to 10 do;
		if inplong($CF8)=$80000000 then PCItype:=1;
		for i:=1 to 10 do;
		outplong($CF8,tmp);
		end;
	PCIvals:=0;
	writeln('Bus  Device:  In  Stat   Memory:');
	If (PCItype>0) Then
		begin
		wrlog(LOG_Crit,'PCI bus type '+istr(PCItype));
		case PCItype of
			1:begin   {PCI type 1}
				i:=0;max:=4096;
				while i<max do
					begin
					outplong($CF8,$80000000+i*longint(256));
					tmp:=inplong($CFC);
					wrlog(LOG_Crit,'PCI test #'+istr(i)+': '+hex8(tmp));
					if (word(tmp)<>$FFFF) and ((tmp shr 16)<>$FFFF) then
						begin
						inc(PCIvals);
						PCIval[PCIvals]:=tmp;
						inc(PCIdevs);
						PCIrec[PCIdevs].PCIbase:=i;
						PCIrec[PCIdevs].l[0]:=tmp;
						for j:=1 to 63 do
							begin
							outplong($CF8,$80000000+i*longint(256)+j*4);
							PCIrec[PCIdevs].l[j]:=inplong($CFC);
							end;
						hdr:=PCIrec[PCIdevs].b[$E];  {SAVE header field}
						s:=copy(hex4(i),2,3)+' '+hex4(PCIrec[PCIdevs].vendor)+' '
						+hex4(PCIrec[PCIdevs].device)
						+' '+hex4(PCIrec[PCIdevs].w[$1e])+' '+hex8(PCIrec[PCIdevs].l[2])+' ';
						if (PCIrec[PCIdevs].status and 32)>0 then s:=s+'6' else s:=s+'3'; {66 vs 33MHz}
						if (PCIrec[PCIdevs].command and 1)>0 then s:=s+'I' else s:=s+'i'; {IO access}
						if (PCIrec[PCIdevs].command and 2)>0 then s:=s+'M' else s:=s+'m'; {Mem access}
						if (PCIrec[PCIdevs].command and 4)>0 then s:=s+'B' else s:=s+'b'; {Bus Master}
						s:=s+wrPCIbase(PCIrec[PCIdevs].base0)+wrPCIbase(PCIrec[PCIdevs].base1)
						+wrPCIbase(PCIrec[PCIdevs].base2)+wrPCIbase(PCIrec[PCIdevs].base3)
						+wrPCIbase(PCIrec[PCIdevs].base4)+wrPCIbase(PCIrec[PCIdevs].base5);
						writeln(s);
						if (PCIrec[PCIdevs].status and $10)<>0 then
							begin
							s:='';
							z:=PCIrec[PCIdevs].capab;
							while z<>0 do
								begin
								j:=PCIrec[PCIdevs].b[z];
								x:=PCIrec[PCIdevs].b[z+2];
								if j=2 then
									begin
									s:=s+' AGP v'+istr(x shr 4)+'.'+istr(x and 15);
									if (PCIrec[PCIdevs].b[z+9] and 1)>0 then s:=s+' Enabled';
									s:=s+' 1x:';
									if (PCIrec[PCIdevs].b[z+4] and 1)>0 then s:=s+'S';
									if (PCIrec[PCIdevs].b[z+8] and 1)>0 then s:=s+'E';
									s:=s+' 2x:';
									if (PCIrec[PCIdevs].b[z+4] and 2)>0 then s:=s+'S';
									if (PCIrec[PCIdevs].b[z+8] and 2)>0 then s:=s+'E';
									s:=s+' Sband:';
									if (PCIrec[PCIdevs].b[z+5] and 2)>0 then s:=s+'S';
									if (PCIrec[PCIdevs].b[z+9] and 2)>0 then s:=s+'E';
									end
									else
									s:=s+' Cap'+hex2(j)+' v'+istr(x shr 4)+'.'+istr(x and 15);
								z:=PCIrec[PCIdevs].b[z+1];
								end;
							if s<>'' then writeln(s);
							end;
						case PCIrec[PCIdevs].class of
							$600:begin                {Host Bridge chipset}
								MB:=PCIrec[PCIdevs].l[0];
								dec(PCIdevs);
								if mb=$88811060 then max:=384;   {UMC 8881/6}
								if mb=$06001080 then max:=1024;  {CONTAQ 82c595}
								if mb=$00011078 then max:=256;   {Cyrix MediaGX}
								end;
							1,$300,$301,$380:;  {VGA & 8514/A etc}
							else dec(PCIdevs);
							end;
						end;
					if (hdr<128) or ((i and 7)=7) then
						i:=(i+8) and $FFF8
						else
						inc(i);
					end;
				end;
			2:begin   {PCI type 2}
				outp($CF8,$80);
				outp($CFA,0);   {Bus select?}
				for i:=0 to 15 do
					begin
					tmp:=inplong($C000+i*256);
					wrlog(LOG_Crit,'PCI test #'+istr(i)+': '+hex8(tmp));
					if (word(tmp)<>$FFFF) and ((tmp shr 16)<>$FFFF) then
						begin
						inc(PCIdevs);
						PCIrec[PCIdevs].PCIbase:=i;
						PCIrec[PCIdevs].l[0]:=tmp;
						for j:=1 to 63 do
							PCIrec[PCIdevs].l[j]:=inplong($C000+i*256+j*4);
						case PCIrec[PCIdevs].class of
							$600:begin
								MB:=PCIrec[PCIdevs].l[0];
								dec(PCIdevs);
								end;
							1,$300:;  {VGA & 8514/A}
							else
								dec(PCIdevs);
							end;
						end;
					end;
			outp($CF8,0);
			end;
		end;
ENDE:
  {  SetTextMode;}
s:='PCI bus type '+istr(PCItype)+' MB: '+hex4(mb)+':'+hex4(mb shr 16)+' Devices:';
wrlog(LOG_Crit,s);
writeln(s);
if PCIdevs>0 then
	begin
	for i:=1 to PCIdevs do
		begin
		wrlog(LOG_Crit,'  Vendor: '+hex4(PCIrec[i].vendor)+'  Device: '
					+hex4(PCIrec[i].device)+'.'+hex2(PCIrec[PCIdevs].b[8])
					+'  Cmd: '+hex4(PCIrec[i].command)+' Stat: '+hex4(PCIrec[i].status));
		writeln('  Vendor: '+hex4(PCIrec[i].vendor)+'  Device: '+hex4(PCIrec[i].device)
					+'.'+hex2(PCIrec[i].b[8])+'  Cmd: '+hex4(PCIrec[i].command)
					+' Stat: '+hex4(PCIrec[i].status));
		if PCIrec[i].base0<>0 then mkPCIbase('Base0',i,0);
		if PCIrec[i].base1<>0 then mkPCIbase('Base1',i,1);
		if PCIrec[i].base2<>0 then mkPCIbase('Base2',i,2);
		if PCIrec[i].base3<>0 then mkPCIbase('Base3',i,3);
		if PCIrec[i].base4<>0 then mkPCIbase('Base4',i,4);
		if PCIrec[i].base5<>0 then mkPCIbase('Base5',i,5);
		if PCIrec[i].rom<>0   then mkPCIbase('ROM  ',i,8);

		writeln;
		end;
	end;
readkey;
end;
end;*)

Begin
InPLong($220);
End.