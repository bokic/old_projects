Unit Window;
Interface
Type
	PWindow = ^TWindow;
	TWindow = Record
	Xpos,YPos,Width,Height:Byte;
	OldColor:Byte;
	OldCurX,OldCurY:Byte;
	Data:Pointer;
	End;

Function CreateWindow(Caption:String;XPos,YPos,Width,Height,Color:Byte):PWindow;
Procedure DestroyWindow(Window:PWindow);

Implementation
Uses Crt;
Function CreateWindow(Caption:String;XPos,YPos,Width,Height,Color:Byte):PWindow;
Type
	PWordStream=^TWordStream;
	TWordStream=Array[0..4095] of Word;
Var
	Ekran:Array[0..24,0..79] of Word Absolute($B800):($0000);
	T:PWindow;
	PW:PWordStream;
	X,Y:Byte;
	OldVal,Pos:Word;
	OldColor,Count:Byte;
Begin
new(T);
T^.XPos:=XPos;
T^.YPos:=YPos;
T^.Width:=Width;
T^.Height:=Height;
T^.OldColor:=TextAttr;
T^.OldCurX:=WhereX;
T^.OldCurY:=WhereY;
GetMem(T^.Data,Width*Height*2);
PW:=T^.Data;
For Y:=0 To Height Do
	For X:=0 To Width Do
		PW^[(Y*(Width+1)*2)+X]:=Ekran[YPos+Y-1,XPos+X-1];
OldColor:=TextAttr;
TextAttr:=Color;
For Y:=0 To Height Do
	Begin
	GotoXY(XPos,YPos+Y);
	If (Y=0)Then
		Begin
		Write('É');
		For Count:=1 To Width-2 Do
			Write('Í');
		Write('»')
		End
		Else
		If (Y=Height)Then
			Begin
			Write('È');
			For Count:=1 To Width-2 Do
				Write('Í');
			Write('¼')
			End
			Else
			Begin
			Write('º');
			For Count:=1 To Width-2 Do
				Write(' ');
			Write('º')
			End;
	End;
If (Caption<>'')Then
	Begin
	GotoXY(XPos+2,YPos);
	Write(Caption);
	End;
GotoXY(XPos+1,YPos+1);
CreateWindow:=T;
End;

Procedure DestroyWindow(Window:PWindow);
Type
	PWordStream=^TWordStream;
	TWordStream=Array[0..4095] of Word;
Var
	Ekran:Array[0..24,0..79] of Word Absolute($B800):($0000);
	PW:PWordStream;
	X,Y:Byte;
	OldVal,Pos:Word;
	OldColor,Count:Byte;
Begin
With Window^ Do
	Begin
	PW:=Data;
	For Y:=0 To Height Do
		For X:=0 To Width Do
			Ekran[YPos+Y-1,XPos+X-1]:=PW^[(Y*(Width+1)*2)+X];
	FreeMem(Data,Width*Height*2);
	GotoXY(OldCurX,OldCurY);
	TextAttr:=OldColor;
	Dispose(Window);
	End;
End;
End.