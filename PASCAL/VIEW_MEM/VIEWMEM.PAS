{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}
Uses Crt;
Type VidType=Record
	Ch:Char;
	Color:Byte;
	End;

Function hexword(w:word):String;
Const hex:String= '0123456789ABCDEF';
Begin
hexword:=hex[hi(w) div 16+1]+hex[hi(w) mod 16+1]+hex[lo(w) div 16+1]+hex[lo(w) mod 16+1];
End;

Var
	VideoMem:Array[0..24,0..79] of VidType Absolute $B800:0;
	Cha:Char;
	Top:Word;
	Tx,Ty:Word;
Begin
 Asm
 mov ax,3
 int $10
 End;
ClrScr;
Repeat
For Ty:=0 To 24 Do
	Begin
	For Tx:=0 To 15 Do
		Begin
		 Asm
		 push Top
		 pop es
		 mov si,Ty
		 shl si,4
		 add si,Tx
		 mov al,es:[si]
		 mov Cha,al
		 End;
		VideoMem[Ty,Tx+64].Ch:=Cha;
		End;
	GotoXY(1,Ty+1);
	Write(HexWord(Top+Ty));
	End;
Cha:=ReadKey;
If (Cha=#0)Then
	Begin
	Case ReadKey of
		#71:Begin{Home}
			 Top:=0;
			 End;
		#72:Begin{Gore}
			 If (Top>0) Then Dec(Top);
			 End;
		#73:Begin{PgUp}
			 If (Top>20) Then
				Top:=Top-20
				Else
				Top:=0;
			 End;
		#79:Begin{End}
			 Top:=$FFFF-24;
			 End;
		#80:Begin{Dole}
			 If (Top<$FFFF-24) Then Inc(Top);
			 End;
		#81:Begin{PgDn}
			 If (Top<$FFFF-44) Then
				Top:=Top+20
				Else
				Top:=$FFFF-24;
			 End;
		End;
	End;
Until (Cha=#27)
End.