{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T+,V-,X+,Y+}
{$M 16384,0,655360}
Program FmTest;
Uses SVga,Blaster,Crt;

Procedure FmDelay(Val:Word);
Assembler;
Asm
push dx
mov cx,Val
mov dx,$388
@1:
in al,dx
loop @1
pop dx
End;

Procedure SetFm(Index:Byte;Val:Byte);
Assembler;
Asm
mov dx,$388
mov al,Index
out dx,al
push 6
call FmDelay
inc dx
mov al,Val
out dx,al
push 35
call FmDelay
End;

Procedure NoteOff;
Begin
SetFm($B0,0);
End;

Procedure SetFreq(Freq:Word);
Begin
SetFm($10,$01);{Set the modulator's multiple to 1}
SetFm($40,$10);{Set the modulator's level to about 40 dB}
SetFm($60,$F0);{Modulator attack:  quick;   decay:   long}
SetFm($80,$77);{Modulator sustain: medium;  release: medium}
SetFm($23,$00);{Set the carrier's multiple to 1}
SetFm($20,64);
SetFm($43,$00);{Set the carrier to maximum volume (about 47 dB)}
SetFm($63,$F4);{Carrier attack:  quick;   decay:   long}
SetFm($83,$77);{Carrier sustain: medium;  release: medium}
SetFm($E0,$01);
SetFm($BD,$00);
SetFm($A0,Lo(Freq));{Set voice frequency's LSB (it'll be a D#)}
SetFm($B0,$20+(4 shl 2)+(Hi(Freq) And 3));
End;

Const Noti:Array [1..12] of Word=($16B,$181,$198,$1B0,$1CA,$1E5,$202,$220,$241,$263,$287,$2AE);
Var T1,T2:Byte;
		  T3:Word;
		  Ch:Char;
		  Freq:Word;
		  Prim_Buffer,Sec_Buffer:Array[0..639] of Byte;
Begin
SetFm($4,$60);
SetFm($4,$80);
asm
mov dx,$388
in al,dx
mov T1,al
end;
SetFm($2,$FF);
SetFm($4,$21);
FmDelay(200);
asm
mov dx,$388
in al,dx
mov T2,al
end;
SetFm($4,$60);
SetFm($4,$80);
If ((T1<>0)or(T2<>192)) Then
   Begin
   WriteLn('There is no SB found!!');
   Halt;
	End;
{Wr_MixerReg($3D,$40);
Wr_MixerReg($3E,$20);}
DetectSoundBlaster(True);
SetMode(SVGA6448);
line(0,240,639,240,15);
InitBlaster(Freq,False,False);
Set_DMAvalues(@Prim_Buffer,SizeOf(Prim_Buffer),False);
Repeat
While (Not KeyPressed) Do
	Begin
	Move(Prim_Buffer,Sec_Buffer,SizeOf(Prim_Buffer));
	 Get_Sample;
	For T3:=0 To 639 Do
		Begin
		Prim_Buffer[T3]:=Get_Sample;
		End;
	WaitSync;
	For T3:=0 To 639 Do
		Begin
{		Line(T3,Sec_Buffer[T3]+112,T3+1,Sec_Buffer[T3+1]+112,0);
		Line(T3,Prim_Buffer[T3]+112,T3+1,Prim_Buffer[T3+1]+112,10);}
		If (Prim_Buffer[T3]<>Sec_Buffer[T3])Then
			Begin
			Plot(T3,Sec_Buffer[T3]+112,0);
			Plot(T3,Prim_Buffer[T3]+112,10);
			End;
		If ((Prim_Buffer[T3]<>128)And(Sec_Buffer[T3]=128)) Then
			Plot(T3,128+112,15);
		End;
	End;
Ch:=ReadKey;
if (Ch=#0) Then
		  ReadKey;
Case Ch Of
 'z':
        Begin
        NoteOff;
        SetFreq(Noti[2]);
        End;
 'x':
        Begin
        NoteOff;
        SetFreq(Noti[4]);
        End;
 'c':
        Begin
        NoteOff;
        SetFreq(Noti[5]);
        End;
 'v':
        Begin
        NoteOff;
        SetFreq(Noti[7]);
        End;
 'b':
        Begin
        NoteOff;
        SetFreq(Noti[9]);
        End;
 'n':
        Begin
        NoteOff;
        SetFreq(Noti[11]);
        End;
 'm':
        Begin
        NoteOff;
        SetFreq(Noti[12]);
        End;
End;
until (Ch=#27);
ExitGraphics;
End.