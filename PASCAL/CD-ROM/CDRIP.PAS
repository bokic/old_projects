{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T+,V-,X+,Y+}
{$M 16384,0,655360}
Unit CDRip;
interface  { Public symbols }
Const     { Constants }
     CDBuffer=13;

Type

  PCDArray = ^CDArray;
     CDArray = Array[1..(1176 * CDBuffer)] of Integer;
     PDCDArray = ^DCDArray;
     DCDArray = Array[0..1] of CDArray;

 CD_Rip = Object
     private
     Data : PDCDArray;
     ExData : PCDArray;
     CurSect : LongInt;
     public
     Constructor Init(Buffer:PCDArray;Pos:LongInt);
     Procedure Next;
     Destructor Done;
     private
     Function Search(P1,P2:Pointer):Boolean;
     End;

Procedure CDRead(Count:Byte;Pos:LongInt;Dat:Pointer);

Implementation   { Private symbols }

Type
  ReadControl = Record
    Len     : Byte;
    SubUnit : Byte;
    Command : Byte;
    Status  : Word;
    Reserved: Array [1..8] of Byte;
    AddrMode  : Byte;
    TransAddr : Pointer;
    NumSecs   : Word;
    StartSec  : LongInt;
    ReadMode  : Byte;
    IL_Size,
    IL_Skip   : Byte;
  End;

Var CD_Drive:Byte;

Procedure CDRead(Count:Byte;Pos:LongInt;Dat:Pointer);
Var Comman:ReadControl;
Begin
FillChar(Comman,SizeOf(Comman),0);
Comman.Len:=sizeof(Comman);
Comman.Command:=$80;
Comman.TransAddr:=Dat;
Comman.AddrMode:=0;
Comman.NumSecs:=Count;
Comman.StartSec:=Pos;
Comman.ReadMode:=1;
 Asm
 mov ax,$1510
 mov cl,4
 mov ch,0
 push ss
 pop es
 mov bx,bp
 add bx,Offset Comman
 int $2F
 End;
End;

Constructor CD_Rip.Init(Buffer:PCDArray;Pos:LongInt);
Begin
Data:=Nil;
ExData:=Buffer;
CurSect:=Pos;
New(Data);
If(Data<>Nil)Then
    Begin
    CDRead(0,0,ExData);{ Poradi Sinronizacija }
    CDRead(0,CurSect,ExData);{ Poradi Sinronizacija }
    CDRead(13,CurSect,ExData);
    CurSect:=CurSect+13;
    End;
End;

Procedure CD_Rip.Next;
Label Lop,Kraj;
Var R:Word;
Begin
Asm Sti End;
Lop:
CDRead(26,CurSect-5,Data);{ Ovde }
For r:=1 To 15287 Do
    Begin
    {$Q-,R-}
    If (Search(@ExData^[13 * 1176],@Data^[0][r])) Then
    {$Q+,R+}
        Begin
        CurSect:=CurSect+13;
        Move(Data^[0][r+1],ExData^,SizeOf(ExData^));
        Goto Kraj;
        End;
    End;
Goto Lop;
Kraj:
End;

Destructor CD_Rip.Done;
Begin
If (Data<>Nil) Then
   Begin
   Dispose(Data);
   Data:=Nil
   End;
End;

Function CD_Rip.Search(P1,P2:Pointer):Boolean;
Assembler;
Asm
push ds
pushf
les di,P1
lds si,P2
std
mov al,0
mov cx,100
rep
cmpsw
jne @1
inc al
@1:
popf
pop ds
End;

Var Test:Boolean;

Begin
 Asm
 mov ax,$1500
 int $2F
 mov Test,al
 mov CD_Drive,cl
 End;
If (Test=False) Then
	Begin
	WriteLn('MSCDEX is not installed..');
	Halt;
	End;
End.