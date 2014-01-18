{$A+,B-,D+,E-,F-,G+,I+,L-,N-,O-,P-,Q+,R+,S+,T-,V+,X+,Y-}
{$M 16384,0,655360}
Uses Crt,Dos,Blaster;
const Pos:Byte=1;
Type Te=array[1..8000] of byte;
Var t:Boolean;
    f:Word;
    File1:File;
    r:Word;
    B:^Te;
    LG:Word;
    Times:LongInt;

procedure IntProc(Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: Word);
interrupt;
var a:Byte;
Begin
if (Pos=1) Then
	Begin
	BlockRead(File1,B^[1],4000);
	Pos:=2
	End
	Else
	Begin
   BlockRead(File1,B^[4001],4000);
   Pos:=1;
   End;
 Inc(Times);
 asm
 mov dx,dsp_addr
 add dx,$0E
 in al,dx
 mov al,$20
 out $20,al
 popa
 end;
end;

Procedure Custom_Exit;Far;
Begin
Asm
 mov dx,dsp_addr
 add dx,$0E
 in al,dx

 mov al,$20
 out $20,al
End;
Dispose(B);
Close(File1);
stop_play;
restore_irq;
asm
mov al,5
out $0A,al
end;
End;

Begin
ExitProc:=@Custom_Exit;
ClrScr;
New(B);
{t:=UseBlasterEnv;}
{Forceto(6,1,5,5,$220);}
t:=DetectSoundblaster(False);
f:=22050;
InitBlaster(f,True,True);
WriteLn('Blaster is : ',Hi(Get_BlasterVersion),'.',Lo(Get_BlasterVersion));
Assign(File1,'howcome.raw');
{$I-}
Reset(File1,1);
{$I+}
{For F:=0 to 8000 Do
    B^[F]:=$80;}
{BlockRead(File1,B^,8000);}
set_ready_irq(addr(IntProc));
set_sign(False);
set_DMAvalues(B,8000,True);
play_firstBlock(4000);
repeat
write_zaehler;
LG:=get_zaehler;

until(keypressed);
WriteLn(Times);
End.