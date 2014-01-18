{$A+,B-,D+,E-,F-,G+,I+,L+,N+,O-,P-,Q+,R+,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}
Uses Crt,Blaster;
Type SB=Array[1..16000] of Integer;
Var f:Word;
    Times:LongInt;
    IInt:Byte;
    Fi:File;
    S:^SB;
    T:Word;

procedure IntProc(Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: Word);
interrupt;
Begin
 asm
 mov dx,dsp_addr
 add dx,$0E
 in ax,dx
 end;
 asm
 mov al,$20
 out $20,al
 end;
BlockRead(Fi,S^[(IInt*8000)+1],16000,F);
 asm
 xor IInt,1
 End;
Inc(Times);
end;

Procedure Custom_Exit;Far;
Begin
Asm
 mov dx,dsp_addr
 add dx,$0E
 in al,dx
End;

Asm
 mov al,$20
 out $20,al
End;
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
If (DetectSoundblaster(False)=False)Then Halt;
Assign(Fi,'loop8st.raw');
Reset(Fi,1);
{Seek(Fi,48);}
New(S);
For T:=1 to 16000 do S^[T]:=0;
BlockRead(Fi,S^,32000,F);
f:=44100;
InitBlaster(f,True,False);
WriteLn('Blaster is : ',Hi(Get_BlasterVersion),'.',Lo(Get_BlasterVersion));
set_ready_irq(addr(IntProc));
set_sign(True);
set_DMAvalues(S,16000*2,True);
play_firstBlock(8000*2);
asm sti end;
repeat
write_zaehler;
until(keypressed);
WriteLn(Times:5);
Close(Fi);
End.