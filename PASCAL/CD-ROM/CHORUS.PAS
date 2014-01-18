{$A+,B-,D+,E-,F-,G+,I+,L+,N+,O-,P-,Q+,R+,S+,T-,V+,X-,Y+}
{$M 16384,0,655360}
Uses Crt,Blaster,CDRip;
Const Pos:Array[1..20] of Integer=(0,1440,1441,1773,1774,
											  2006,2007,3226,3227,3228,
											  3454,3455,3456,3789,3790,
											  3791,5249,5250,5251,5252);
Const Ampl:Array[1..20] of Extended=(16422/32767,4406/32767,3665/32767,9697/32767,7974/32767,
												 4082/32767,3168/32767,1136/32767,4615/32767,3027/32767,
												 537/32767,1846/32767,1178/32767,2779/32767,3811/32767,
												 1297/32767,389/32767,1685/32767,1488/32767,309/32767);
Var RealSBBuffer:Array[1..4000] of Integer;
	SBBuffer:Array[1..21000] of Integer;
	F:Word;
	CD:^CD_Rip;
	CD_Buffer:PCDArray;
Begin
WriteLn('Real time Chorus effect from AudioCD');
WriteLn('By Boris Barbulovski - BokiC');
If (DetectSoundBlaster(False)=False) Then
	Begin
	WriteLn('Can''t find Sound Blaster 16');
	Halt;
	End;
F:=44100;
New(CD_Buffer);
FillChar(CD_Buffer^,SizeOf(CD_Buffer^),0);
New(CD,Init(CD_Buffer,0));

InitBlaster(F,True,True);
set_DMAvalues(@RealSBBuffer,4000,True);
set_sign(True);
RealSBBuffer[4000]:=20000;
play_firstBlock(2000);
Repeat
{CD^.Next;}

Until (KeyPressed);
stop_play;
End.