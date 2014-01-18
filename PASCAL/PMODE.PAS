Function _Hex(W: Word): String;
Const Hex: String= '0123456789ABCDEF';
Begin
  _Hex:= Hex[Hi(W) Div 16+ 1] + Hex[Hi(W) Mod 16+ 1] + Hex[Lo(W) Div 16+ 1] + Hex[Lo(W) Mod 16+ 1];
End;

Var
  T: Word;
  R, W: Boolean;
  F: Text;
  P: Pointer;
Begin
  Repeat
    GetMem(P, 65535);
  Until(MaxAvail< 65535);
  Asm
    Mov AX, 3
    Int $10
    Mov AX, $4 F02
    Mov BX, $4013
    { Int $10}
    Db $66, $Be, 0, 0, 2, 0
    Db $67, $8 A, 6
  End;
  WriteLn(MemAvail: 8, MaxAvail: 9);
  Assign(F, 'Test.inf');
  Rewrite(F);
  For T:= 0 To $Ffff Do
  Begin
    Asm
      Mov R, 0
      Mov W, 0
      Mov AX, T
      Verr AX
      Jne @Ne1
      Inc R
      @Ne1:
      Verw AX
      Jne @Ne2
      Inc W
      @Ne2:
    End;
    If ((R) Or(W)) Then
    Begin
      If ((R) And(W= False)) Then WriteLn(F, 'Readable           segment found:', _Hex(T));
      If ((R= False) And(W)) Then WriteLn(F, '         Writeable segment found:', _Hex(T));
      If ((R) And(W))       Then WriteLn(F, 'Readable Writeable segment found:', _Hex(T));
    End;
  End;
  Close(F);
  Asm
    Mov AX, 3
    Int $10
  End;
End.