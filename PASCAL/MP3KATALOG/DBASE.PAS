{$A+,B-,D+,E-,F-,G+,I+,L+,N+,O-,P-,Q+,R+,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}
Unit DBase;
Interface{ Public symbols }

Type
	PRecord = ^TRecord;
	TRecord = Record
	Name  : Array [1..12] Of Char;
	_Type : Char;
	Offse : Longint;
	Len   : Byte;
	Dec   : Byte;
	End;

	PKey = ^TKey;
	TKey = Record
	Name:String[16];
	Order:Boolean;
	End;

	PCreateFile = ^TCreateFile;
	TCreateFile = Object
	private
	Handle : Integer;
	MField : LongInt;
	HeaLen : Word;
	RecLen : Word;
	public
	Constructor Init(FName: String);
	Procedure Add(Name: String; Tupe: Char; Len: Byte; Dec: Byte);
	Destructor Done;
	End;

	PDBase = ^TDBase;
	TDBase = Object
	public
	Handle:Integer;
	Error:Integer;
	To_Save:Boolean;
	RecordPos:LongInt;
	Year, Month, Days: Byte;
	RecordNo:LongInt;
	HeaderSize:Word;
	RecordLen:Word;
	FieldNo:Byte;
	Fields:Array[1..64] Of Record
		Name:String[12];
		Typ :char;
		Offs:LongInt;
		Len :byte;
		Decim:byte;
		End;
	Recor:Array[0..512] Of Byte;
	Procedure WriteHeader;
	public
	Constructor Init(FName: String);
	Function MyFieldData(Field: Byte):String;
	Function RecCount:LongInt;
	Procedure NextRec;
	Procedure PrevRec;
	Function DBEOF:Boolean;
	Procedure GoTop;
	Procedure GoBottom;
	Procedure AppendBlank;
	Procedure AppendCurrent;
	Procedure AppendBlankAt(Rec:LongInt);
	Procedure AppendCurrentAt(Rec:LongInt);
	Procedure MyReplace(Field: Byte; _Sou: String);
	Procedure Save;
	Procedure DbDelete;
	Procedure DbRecover;
	Function DbIsDeleted:Boolean;
	Procedure Pack;
	Procedure Zap;
	Function RecNo:LongInt;
	Procedure GetDbRec(_RecNo: LongInt);virtual;
	Destructor Done;
	End;

	PIndex = ^TIndex;
	TIndex = object
{ 	Constructor Create(Name:String;Key:PKey;From:PDBase);
	Constructor Init_Load(Name:String);
	Constructor Init(Name:String;From:PDBase);}
	End;

Var dbase_Err:Pointer;

Implementation    { Private symbols }

Function CreateF(Var FName: String):Integer;
assembler;
Asm
push ds
mov ax,$3C00 {5B00 3C00}
mov cx,32
lds dx,FName
Inc dx
int 21h
jnc @Kraj
mov ah,0
Xor ax,$8000
@Kraj:
pop ds
End;

Procedure OpenF(FName: String; Var Handle: Integer);
assembler;
Asm
push ds
mov ax,3d02h
lds dx,ss:FName
inc dx          {Deka e Pascal 6.0 i deka koristi ......}
int 21h
jnc @1
xor ax,8000h
@1:
les di,ss:Handle
mov word ptr es:[di],ax
pop ds
End;

Function CloseF(Handle: Integer):Integer;
assembler;
Asm
push ds
mov ah,3Eh
mov bx,Handle
int 21h
jnc @1
xor ax,8000h
@1:
pop ds
End;

Function ReadF(Handle: Integer; Source: Pointer; Count: Word):Integer;
Assembler;
Asm
push ds
mov ah,3Fh
mov bx,ss:Handle
mov cx,Count
lds dx,[Source]
int 21h
jnc @1
xor ax,8000h
@1:
pop ds
End;

Function WriteF(Handle: Integer; Source: Pointer; Count: Word):Integer;
Assembler;
Asm
push ds
mov ah,40h
mov bx,ss:Handle
mov cx,Count
lds dx,[Source]
int 21h
jnc @1
Xor ax,8000h
@1:
pop ds
End;

Function SeekF(Handle: Integer; Pod: LongInt):Integer;
assembler;
Asm
push ds
mov ax,4200h
mov bx,ss:handle
mov cx,word ptr [pod+2]
mov dx,word ptr [pod]
int 21h
jc @1
Xor ax,ax
@1:
pop ds
End;

Procedure St0toStr(Var Source, Dest);
Assembler;
Asm
push ds
lds si,Source
les di,Dest
push di
inc di
mov cx,0FFFFh
inc cx
@Loop:
mov al,ds:[si]
cmp al,0
Je @Exit
mov es:[di],al
inc si
inc di
inc cx
jmp @Loop
@Exit:
pop di
mov es:[di],cl
pop ds
End;

Procedure StrtoSt0(Var Source, Dest; len: word);{len = Max Len}
Assembler;
Asm
Push ds
LDs si,Source
LEs di,Dest
Mov cl,[si]
Mov ch,0
Cmp cx,len
jna @2
mov cx,len
@2:
Inc si
Rep
Movsb
Mov byte ptr es:[di],0
Pop ds
End;

Procedure Error(ErrNo:Integer);
Begin

End;

Constructor TCreateFile.Init(FName: String);
Label Kraj;
Var Temp:Integer;
	Header:Record
	Ver    :Byte;
	Year   :Byte;
	Month  :Byte;
	Day    :Byte;
	RecNo  :LongInt;
	HeaLen :Word;
	RecLen :Word;
	Junk   :Array[1..20] Of char;
	End;
Begin
RecLen := 1;
MField := 1;
HeaLen := SizeOf(Header);
FName := FName + #0;
Temp := CreateF(FName);
If (Temp < 0) Then Goto Kraj;
Handle := Temp;
Header.Ver := 3;
Asm
 mov    ah,$2A
 int    $21
 mov    ax,cx
 mov    bl,100
 push   dx
 div    bl
 mul    bl
 pop    dx
 sub    cx,ax
 mov    di,bp
 add    di,offset Header.Year
 mov    Byte ptr ss:[di],cl

 mov    di,bp
 add    di,offset Header.Month
 mov    Byte ptr ss:[di],dh

 mov    di,bp
 add    di,offset Header.Day
 mov    Byte ptr ss:[di],dl
End;
Header.RecNo:=0;
For Temp:=1 To 20 Do
	Header.Junk[Temp]:=#0;
WriteF(Handle, @Header, SizeOf(Header));
Kraj:
End;

Procedure TCreateFile.Add(Name: String; Tupe: Char; Len: Byte; Dec: Byte);
Var T:Byte;
	Rec:Record
		Name:Array[1..11] Of char;
		Tip :char;
		Off :LongInt;
		Len :Byte;
		DeP :Byte;
		Jun :Array[1..14] Of char;
		End;
Begin
For t:= 1 To 10 Do
	If (Length(Name) >= t) Then
		Rec.Name[t] := Name[t]
		Else
		Rec.Name[t] := #0;
Rec.Name[11] := #0;
Case (Tupe) Of
	'C':Begin
		Dec := 0;
		End;
	 'D':Begin
		Len := 8;
		Dec := 0;
		End;
	Else
		Begin
		Tupe := 'N';
		If (Len < Dec) Then
			Dec := Len;
		End;
	 End;
Rec.Tip := Tupe;
Rec.Off := MField;
Rec.Len := Len;
Rec.Dep := Dec;
For t:= 1 To 14 Do
	Rec.Jun[t] := #0;
WriteF(Handle, @Rec, SizeOf(Rec));
MField := MField + Len;
HeaLen := HeaLen + SizeOf(Rec);
RecLen := RecLen + Len;
End;

Destructor TCreateFile.Done;
Var t:Char;
Begin
t := #$0D;
WriteF(Handle, @T, 1);
Inc(HeaLen);
SeekF(Handle, 8);
WriteF(Handle, @HeaLen, 4);
CloseF(Handle);
End;
(*------------------------------------------------------*)
Function TDBase.MyFieldData(Field: Byte):String;
Var Count:Byte;
	T:String;
Begin
If ((Field > 16)Or(Field > FieldNo)) Then
		Begin
		Error := 85;
      WriteLn('Field out of range.');
		Exit;
		End;
Case (Fields[Field].Typ) Of
		'D':
				Begin
				T[0] := Chr(Fields[Field].Len);
				For Count:= 1 To Fields[Field].Len Do
						T[Count] := chr(Recor[Lo(Fields[Field].Offs) + Count - 1]);
				MyFieldData := copy(T, 7, 2) + '-' + copy(T, 5, 2) + '-' + copy(T, 3, 2);
				End;
				Else
                Begin
                T[0] := Chr(Fields[Field].Len);
                For Count:= 1 To Fields[Field].Len Do
                        T[Count] := chr(Recor[Lo(Fields[Field].Offs) + Count - 1]);
                MyFieldData := T;
                End;
        End;
End;

Function TDBase.RecCount:LongInt;
Begin
RecCount := RecordNo;
End;

Procedure TDBase.NextRec;
Begin
If (RecordNo = RecordPos) Then
        Error := 88
        Else
        GetDbRec(RecordPos + 1);
End;

Procedure TDBase.PrevRec;
Begin
If (RecordPos = 1) Then
        Error := 88
        Else
        GetDbRec(RecordPos - 1);
End;

Function TDBase.DBEOF:Boolean;
Begin
If (RecordNo = RecordPos) Then
        DBEOF := True
        Else
        DBEOF := False;
End;

Procedure TDBase.GoTop;
Begin
If (RecordNo = 0) Then
        Error := 88
        Else
        GetDbRec(1);
End;

Procedure TDBase.GoBottom;
Begin
If (RecordNo = 0) Then
        Error := 88
        Else
        GetDbRec(RecordNo);
End;

Procedure TDBase.AppendBlank;
Var T:Word;
Begin
If (To_Save) Then
   Begin
   Save;
   To_Save:=False;
   End;
Recor[0]:=32;{ Dodadeno 2005g}
FillChar(Recor[1],SizeOf(Recor)-1,0);
AppendCurrent;
End;

Procedure TDBase.AppendCurrent;
Label Kraj;
Var Er:Integer;
Begin
Er := SeekF(Handle, HeaderSize + (RecordNo * RecordLen));
If (Er <> 0) Then
   Halt;
Recor[0] := 32;
Er := WriteF(Handle, @Recor, RecordLen);
Inc(RecordNo);
RecordPos := RecordNo;
WriteHeader;
To_Save:=False;
Kraj:
End;

Procedure TDBase.AppendBlankAt(Rec:LongInt);
Var T:LongInt;
Begin
If (Rec>0)Then
        Begin
        AppendBlank;
        If(Rec<RecordNo)Then
                 Begin
                 For T:=RecordNo - 1 DownTo Rec Do
                          Begin
                          GetDBRec(T);
                          SeekF(Handle, HeaderSize + RecordPos * RecordLen);
                          WriteF(Handle, @Recor, RecordLen);
                          End;
                 GetDBRec(Rec);
                 Recor[0]:=32;
                 FillChar(Recor[1],SizeOf(Recor)-1,0);
                 SeekF(Handle, HeaderSize + (RecordPos - 1) * RecordLen);
                 WriteF(Handle, @Recor, RecordLen);
                 End;
        End
        Else
        AppendBlank;
End;

Procedure TDBase.AppendCurrentAt(Rec:LongInt);
Var
   T:Word;
   NewRecor:Pointer;
Begin
If (Rec<=RecordNo)Then
   Begin
   GetMem(NewRecor,RecordLen);
   Move(Recor,NewRecor^,RecordLen);
   To_Save:=False;
   AppendBlank;
   If(Rec<RecordNo)Then
      Begin
      For T:=RecordNo - 1 DownTo Rec Do
         Begin
         GetDBRec(T);
         SeekF(Handle, HeaderSize + RecordPos * RecordLen);
         WriteF(Handle, @Recor, RecordLen);
         End;
      GetDBRec(Rec);
      Recor[0]:=32;
      Move(NewRecor^,Recor,RecordLen);
      SeekF(Handle, HeaderSize + (RecordPos - 1) * RecordLen);
      WriteF(Handle, @Recor, RecordLen);
      End;
   FreeMem(NewRecor,RecordLen);
   End
   Else
   AppendCurrent;
End;

Procedure TDBase.MyReplace(Field: Byte; _Sou: String);
Label Kraj;
Var C:Byte;
         P,Er:Integer;
			Ex:Real;
         T:String;
         T1:String[1];
Begin
T := _Sou;
Case (Fields[Field].Typ) Of
     'C':
         if (Fields[Field].len <> Length(T)) Then
            Begin
            if (Fields[Field].len < Length(T)) Then
               T := Copy(T, 1, Fields[Field].len)
               Else
               Begin
               C := Ord(T[0]);
               Inc(C);
               T[0] := Chr(Fields[Field].len);
               For C:= C To Fields[Field].len Do
                   T[C] := ' ';
               End;
            End;

     'N':
         if (Fields[Field].Decim = 0) Then
            Begin
            T1 := ' ';
            If (T = '') Then
               Goto Kraj;
            If (Fields[Field].len < Length(T)) Then
               T := Copy(T, 1, Fields[Field].len);
            If (Fields[Field].len > Length(T)) Then
               For C:= 1 To(Fields[Field].len - Ord(T[0])) Do
                   Insert(T1, T, 1);
            End
            Else
            Begin
            P:=Pos(',',T);
            if(P>0) Then
               T:=copy(T,1,P-1)+'.'+copy(T,P+1,Length(T)-P);
            Val(T, Ex, Er);
            If (Er <> 0) Then
               Begin
               Error := 86;
               Goto Kraj;
               End;
            Str(Ex: Fields[Field].len: Fields[Field].Decim, T);
            End;
          'D':
                        Begin
                        If ((T[0] <> #10)And(T[0] <> #8)) Then
                                Begin
                                Error := 89;
                                Goto Kraj;
                                End;
                        If ((T[3] <> '-')Or(T[6] <> '-')) Then
                                Begin
                                Error := 89;
                                Goto Kraj;
                                End;
                        If (T[0] = #8) Then
                                T := '19' + Copy(T, 7, 4) + Copy(T, 4, 2) + Copy(T, 1, 2)
                                Else
                                If (T[0] = #10) Then
                                T := Copy(T, 7, 4) + Copy(T, 4, 2) + Copy(T, 1, 2);
                         End;
          'L':
                         Begin
                         End;
          Else
						 Begin
						 Error := 86;
						Goto Kraj;
						End;
          End;
For C:= 1 To Length(T) Do
   Recor[Fields[Field].offs + C - 1] := Ord(T[C]);
To_Save:=True;
Kraj:
End;

Procedure TDBase.Save;
Label Kraj;
Var Er:Integer;
Begin
WriteHeader;
If (RecordNo > 0) Then
   Begin
   Er := SeekF(Handle, HeaderSize + (RecordPos - 1) * RecordLen);
   Er := WriteF(Handle, @Recor, RecordLen);
   End;
Kraj:
End;

Procedure TDBase.DBDelete;
Begin
If (Recor[0] = 32) Then
   Begin
   Recor[0] := 42;
   To_Save:=True;
   End;
End;

Function TDBase.DbIsDeleted:Boolean;
Begin
If (Recor[0] = 32) Then
   DbIsDeleted := False
   Else
   DbIsDeleted := True;
End;

Procedure TDBase.DbRecover;
Begin
If (Recor[0] <> 32)Then
   Begin
   Recor[0] := 32;
   To_Save:=True;
   End;
End;

Procedure TDBase.Pack;
Label Kraj;
Var Er:Integer;
    Rp,Wp,T:LongInt;
Begin
If (To_Save) Then
        Begin
        Save;
        To_Save:=False;
        End;
If (RecordNo = 0) Then Goto Kraj;
Wp := 1;
T := RecordNo;
For Rp:= 1 To RecordNo Do
    Begin
    GetDbRec(Rp);
    If (Recor[0] = 42) Then
       T := T - 1;
    If ((Rp <> Wp)And(Recor[0] = 32)) Then
       Begin
       Er := SeekF(Handle, HeaderSize + (Wp - 1) * RecordLen);
       If (Er <> 0) Then
          Begin
          Error := Handle Xor $8000;
          Goto Kraj;
          End;
       Er := WriteF(Handle, @Recor, RecordLen);
       If (Er < 1) Then
          Begin
          Error := Handle Xor $8000;
          Goto Kraj;
          End;
       End;
       If (Recor[0] = 32) Then
          Inc(Wp);
    End;
If (RecordNo <> T) Then
     Begin
     Er := SeekF(Handle, HeaderSize + (Wp) * RecordLen);
     Er := WriteF(Handle, Nil, 0);
     RecordNo := T;
     WriteHeader;
     End;
Kraj:
End;

Procedure TDBase.Zap;
Label Kraj;
Var Er:Integer;
Begin
RecordNo := 0;
WriteHeader;
RecordPos := 0;
Er := SeekF(Handle, HeaderSize);
If (Er <> 0) Then
     Begin
     Error := Handle;
     Goto Kraj;
     End;
Er := WriteF(Handle, Nil, 0);
Kraj:
End;

Function TDBase.RecNo:LongInt;
Begin
RecNo := RecordPos;
End;

Procedure TDBase.GetDbRec(_RecNo: LongInt);
Label Kraj;
Var
   T:LongInt;
   Er:Integer;
Begin
If (To_Save) Then
        Begin
        Save;
        To_Save:=False;
        End;
If ((_RecNo < 1)Or(_RecNo > RecordNo)) Then
        Begin
        Error := 88;
        Goto Kraj;
        End;
T := HeaderSize + (_RecNo - 1) * RecordLen;
Er := SeekF(Handle, t);
If (Er <> 0) Then
        Begin
        Error := Er;
        Goto Kraj;
        End;
Er := ReadF(Handle, @Recor, RecordLen);
If (Er < 1) Then
        Error := Handle Xor $8000;
RecordPos := _RecNo;
Kraj:
End;

Constructor TDBase.Init(FName: String);
Label Kraj;
Var
   Temp    :Integer;
   Ver     :Byte;
   FPos    :Word;
   TField  :Record
   Name   :Array[1..11] Of Char;
   Typ    :Char;
   Addr   :LongInt;
   Len    :Byte;
   Decimal:Byte;
   Unused :Array[1..14] Of Char;
   Recor  :Array[1..100] Of byte;
   End;
Begin
Error := 0;
FName := FName + #0;
RecordPos := 0;
To_Save:=False;
OpenF(FName, Handle);
If (Handle < 0) Then
     Begin
     Error := $81;
     Goto Kraj;
     End;
Temp := ReadF(Handle, @Ver, 1);
If (Temp < 1) Then
     Begin
     Error := Handle Xor $8000;
     Goto Kraj;
     End;
If (Ver <> 3) Then
     Begin
     Error := $82;
     Goto Kraj;
     End;
Temp := SeekF(Handle, 4);
If (Temp < 0) Then
     Begin
     Error := Handle Xor $8000;
     Goto Kraj;
     End;
Temp := ReadF(Handle, @RecordNo, 8);
If (Temp < 0) Then
     Begin
     Error := Handle Xor $8000;
     Goto Kraj;
     End;
Temp := SeekF(Handle, 32);
If (Temp < 0) Then
	Begin
	Error := Handle Xor $8000;
	Goto Kraj;
	End;
FieldNo := 0;

Repeat
	Temp := ReadF(Handle, @TField, 32);
	If (Temp < 0) Then
		Begin
		Error := Handle Xor $8000;
		Goto Kraj;
		End;
	If (TField.Name[1] = #$0D) Then
		Goto Kraj;
	Inc(FieldNo);
	If (FieldNo = 65) Then
		Begin
		Error := $84;
		Goto Kraj;
		End;
	St0toStr(TField.Name, Fields[FieldNo].Name);
	Fields[FieldNo].Typ := TField.Typ;
	Fields[FieldNo].Offs := TField.Addr;
	Fields[FieldNo].Len := TField.Len;
	Fields[FieldNo].Decim := TField.Decimal;
	Until (1 = 2) ;
Kraj:
If (Error = 0) Then
	If (RecordNo > 0) Then
		TDBase.GetDbRec(1)
		Else
		FillChar(Recor,SizeOf(Recor),#32);
End;

Procedure TDBase.WriteHeader;
Var y:word;
    m,d:byte;
Begin
Asm
	Mov ah,2Ah
	Int 21h
	les di,Self
	mov es:[di+TDBase.Days],dl
	mov es:[di+TDBase.Month],dh
	mov ax,cx
	mov bx,100
	div bl
	mul bl
	Mov y,cx
	Mov m,dh
	Mov d,dl
End;
Year:=y-((y Div 100)*100);
Month:=m;
Days:=d;
SeekF(Handle, 1);
WriteF(Handle, @Year, 11);
End;

Destructor TDBase.Done;
Begin
If (To_Save) Then
        Begin
        Save;
        To_Save:=False;
        End;
Error := CloseF(Handle);
End;

End.

{
Error No:
00: No Error
01-80: Dos Errors;
81: File not found
82: File not DBase
83: Header Courupted
84: Too many Fields
85: Field Out of range
86: Record Not Valid
87: Record too long
88: Record Out of range
89: Field Input Error}