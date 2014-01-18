program Float;
{$A-,B-,D+,E-,F-,G+,I+,L+,N+,O-,P-,Q+,R+,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}
uses Crt;
type
     Test=array [0..9] of byte;
     PTest=^Test;

var
    N:PTest;
    Bit,Bajt:Word;
    CC,HCC:Char;
    A:Extended;

procedure ReDraw(var _T:PTest);
var Tx,Ty:Word;
    _Ch:Char;
    PR:^Extended;
    TST:string;
begin
GotoXY(1,1);
PR:=@_T^[0];
For Ty:=0 to 9 Do
    Begin
    For Tx:=0 to 7 Do
        Begin
         asm
         xor ax,ax
         mov cl,'0'
         les si,_T
         les si,es:[si]
         add si,Ty
         mov al,es:[si];
         mov bx,Tx
         db $0F,$A3,$D8 {pishi shto e}
         jnc @Ne
         inc cl
         @Ne:
         mov _Ch,cl
         End;
        _Ch := '0' + _T^[Ty;
        Write(_Ch);
        End;
    End;
WriteLn;
Str(PR^:80:80,TST);
WriteLn(PR^:80:80);
End;

Begin
ClrScr;
A:=0.1;
N:=@A;
repeat
ReDraw(N);
GotoXY(Bit+1,Bajt+1);
CC:=ReadKey;
case CC of
     #0:  Begin
          HCC:=ReadKey;
           Case Hcc of
                'H':If (Bajt>0) Then Dec(Bajt);{Up}
                'P':If (Bajt<9) Then Inc(Bajt);{Down}
                'K':If (Bit>0) Then Dec(Bit);{Levo}
                'M':If (Bit<7) Then Inc(Bit);{Desno}
           end;
          End;
     #32: Asm
          les si,N
          add si,Bajt
          mov cl,es:[si]
          mov ch,byte ptr[Bit]
          inc ch
          cmp ch,2
          jng @Ok
          sub ch,2
          push cx
          mov cl,ch
          mov ch,0
          mov al,2
          mov bl,2
          @Lop:
          mul bl
          Loop @Lop
          pop cx
          mov ch,al
          @Ok:
          xor byte ptr es:[si],ch
          End;
End;
until (CC=#27);
End.