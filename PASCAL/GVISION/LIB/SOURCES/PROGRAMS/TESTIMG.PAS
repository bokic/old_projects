Program testimg;
Uses Crt,Dos,Graph,Grdriver,Eventman,Images;
Var
	Filter : PFilter;
	Image : TImage;
	Ch : Char;
	D : DirStr;
	N : NameStr;
	E : ExtStr;
Begin
If (ParamStr(1) = '') Then
	Exit;
Fsplit(ParamStr(1),D,N,E);
If (E = '.bmp') Then
	Filter := New(PBmpFilter,Init)
	Else
	If (E = '.pcx') Then
		Filter := New(PPcxFilter,Init)
		else
		Exit;
InitVideo;
Image.Import(ParamStr(1),Filter);
Image.Draw(0,0,NormalPut);
Ch := ReadKey;
Image.Done;
Dispose(Filter,Done);
End.