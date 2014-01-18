{$A+,B-,D+,E-,F-,G+,I+,L-,N-,O-,P-,Q+,R+,S+,T-,V+,X+,Y-}
{$M 16384,0,655360}
Uses Crt,Dos,Blaster;
Type Te=array[0..31999] of byte;
Var {Wav:array[1..62000] of byte;}
    t:Boolean;
    f:Word;
    File1:File;
    r:Word;
    B1,B2,B3:^Te;
Begin
ClrScr;
New(B1);
New(B2);
New(B3);
{t:=UseBlasterEnv;}
{Forceto(6,1,5,5,$220);}
t:=DetectSoundblaster(True);
f:=11025;
InitBlaster(f,False,False);
WriteLn('Blaster is : ',Hi(Get_BlasterVersion),'.',Lo(Get_BlasterVersion));
Assign(File1,ParamStr(1));
{$I-}
Reset(File1,1);
{$I+}
If (IOResult>0) Then
   Begin
   WriteLn('Can''t Open ',ParamStr(1));
   halt;
   End;
for r:=0 to 31999 do
    Begin
    {if (r/2=int(r/2)) then}
    B1^[r]:=128;
{       Else B1^[r]:=20;}
    B2^[r]:=128;
    B3^[r]:=128;
    End;
{Seek(File1,46);}
BlockRead(File1,B2^,52624);
Close(File1);
{play_oneBlock(B2,52624);}

set_DMAvalues(B2,52624,False);
set_sign(False);
{play_firstBlock(65535);}
play_oneBlock(B2,52624);
repeat
write_zaehler;
if (get_zaehler=65535) then
   Begin
   set_DMAvalues(B2,2624,True);
{   play_firstBlock(65535);}
{   play_firstBlock(1600);}
   End;
until(keypressed);
Dispose(B3);
Dispose(B2);
Dispose(B1);
End.