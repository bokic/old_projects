{$A+,B-,D+,E-,F-,G+,I+,L+,N+,O-,P-,Q+,R+,S+,T-,V-,X-,Y+}
{$M 16384,0,655360}
Uses Crt,Blaster,CDRip;
Const IInt:Byte=1;
                Pos:Array[1..20] of Integer=(0,1440,1441,1773,1774,
                                             2006,2007,3226,3227,3228,
                                             3454,3455,3456,3789,3790,
                                             3791,5249,5250,5251,5252);
                Ampl:Array[1..20] of Extended=(16422/32767,4406/32767,3665/32767,9697/32767,7974/32767,
                                               4082/32767,3168/32767,1136/32767,4615/32767,3027/32767,
                                               537/32767,1846/32767,1178/32767,2779/32767,3811/32767,
                                               1297/32767,389/32767,1685/32767,1488/32767,309/32767);
Type SB_Buf=Array [0..29999] of Integer;
Var ITimes,Times:Word;
         SB_Buffer:^SB_Buf;
         CD_Buffer:PCDArray;

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

 inc IInt
 cmp IInt,3
 jne @No3
 mov IInt,0
 @No3:
 inc ITimes
 End;
 FillChar(SB_Buffer^[10000*IInt],20000,0);
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
stop_play;
restore_irq;
asm
mov al,5
out $0A,al
end;
End;

Procedure Alloc_SB;
Var P:Pointer;
         Count:Word;
Begin
getmem(SB_Buffer,60000);
If (check_DMA_Page(SB_Buffer,60000)) Then
        Begin
         Asm
         les di,SB_Buffer
         mov bx,es
         shl bx,4
         add bx,di
         neg bx
         mov Count,bx
         End;
        freemem(SB_Buffer,60000);
        getmem(P,Count);
        getmem(SB_Buffer,60000);
        freemem(P,Count);
        End;
WriteLn(Seg(SB_Buffer^)shr 12);
FillChar(SB_Buffer^,60000,0);
End;

Var F:Word;
         CD:^CD_Rip;
			CDPos,T,T1,T2,T3,TIInt:Word;
         Err:Integer;
Begin
ExitProc:=@Custom_Exit;
If (DetectSoundblaster(False)=False)Then Halt;
F:=5500;
InitBlaster(F,True,True);
WriteLn('Blaster is : ',Hi(Get_BlasterVersion),'.',Lo(Get_BlasterVersion));
set_ready_irq(addr(IntProc));
set_sign(True);
New(CD_Buffer);
Alloc_SB;
FillChar(CD_Buffer^,SizeOf(CD_Buffer^),0);
If (ParamCount=1) Then
		  Begin
		  Val(ParamStr(1),T,Err);
		  New(CD,Init(CD_Buffer,T));
		  End
		  Else
		  New(CD,Init(CD_Buffer,100));
set_DMAValues(SB_Buffer,30000,True);
asm sti end;
play_firstBlock(10000);
CDPos:=1;
repeat
WriteLn(IInt,' ',CDPos);
If (ITimes<>Times) Then
		  If (ITimes=Times+1) Then
					 Begin
					 TIInt:=IInt;
					 Dec(TIInt);
					 If (TIInt=$FFFF) Then
								TIInt:=0;
					 For T:=0 To 9999 Do
								Begin
								If (CDPos=(1176 * 13)+1) Then
										  Begin
										  CD^.Next;
										  CDPos:=1;
										  End;
								 If ((10000*TIInt)+T+5000+Pos[20]>=30000)Then
										  T1:=(((10000*TIInt)+T+5000+Pos[20])-30000)
										  Else
										  T1:=(10000*TIInt)+T+5000+Pos[20];
								 {$Q-}
								 SB_Buffer^[T1]:=SB_Buffer^[T1] + CD_Buffer^[CDPos] div 2;
								 {$Q+}
								 For T2:=1 to 20 Do
									Begin
									T3:=T1+Pos[T2];
									If (T3>=30000) Then
										T3:=T3-30000;
									SB_Buffer^[T3]:=0;
									SB_Buffer^[T3]:=Round(SB_Buffer^[T1] + (CD_Buffer^[CDPos] * Ampl[T2]));
									End;
								Inc(CDPos);
								End;
					 If (ITimes<>Times+1) Then
								Begin
								WriteLn('Can''t continue. Or CDROM drive is to slow or there is a big jitter error.');
								Halt;
								End;
					 Inc(Times);
					 End;
Until (keypressed);
End.