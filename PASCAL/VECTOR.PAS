Uses Crt;

function hexword(w:word):string;
const hex:string= '0123456789ABCDEF';
begin
hexword:=hex[hi(w) div 16+1]+hex[hi(w) mod 16+1]+hex[lo(w) div 16+1]+hex[lo(w) mod 16+1];
end;

function hex(b:byte):string;
const hex_st:string= '0123456789ABCDEF';
begin
hex:=hex_st[b div 16+1]+hex_st[b mod 16+1];
end;

Var
	 Interupt: Array[0..$FF] of Pointer Absolute 0:0;
	 T:Byte;
Begin
For T:=0 To $FF Do
	 If ((T shl 12 = 0)And(T>0)) Then
		Begin
		If (Readkey=#27) Then Exit
		End
    Else
	 If (Interupt[T]=nil)Then
		  WriteLn('Interupt ',T:3,' is empty.')
        Else
			If(Seg(Interupt[T]^)<$A000) Then
				 WriteLn('Interupt ',hex(T),' is pointing to ',hexword(Seg(Interupt[T]^)),':',hexword(Ofs(Interupt[T]^)),' User address.')
				 Else
				 WriteLn('Interupt ',hex(T),' is pointing to ',hexword(Seg(Interupt[T]^)),':',hexword(Ofs(Interupt[T]^)),' Bios address.');
End.