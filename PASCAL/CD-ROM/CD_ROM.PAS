{$A+,B-,D+,E-,F-,G+,I+,L+,N+,O-,P-,Q+,R+,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}
Program CD_Rom;
Uses Crt;
Type
    CDRom = Object
    Command : Array[1..3] Of Byte;
    UnUsed : Array[1..32] Of Byte;
    Data : Pointer;
    Neznam : Byte;
    Rezultat : Array[1..22] Of Byte;
    Constructor Init;
    Procedure SendCommand;
    End;

Constructor CDRom.Init;
Begin
Asm
les di,Self
mov cx,$40
mov al,$00
rep
stosb
End;
Data:=@Rezultat;
End;

Procedure CDRom.SendCommand;
Assembler;
Asm
mov ax,$1510
les bx,Self
mov cx,4
int $2F
{push ds
mov dx,$170
mov cx,5
lds si,Self
add si,offset CDRom.Rezultat
outsw
pop ds
push $10
call Crt.Delay
mov dx,$170
mov cx,5
les di,Self
add di,offset CDRom.Rezultat
insw}
End;

Var T:^CDRom;
Begin
New(T,Init);
ClrScr;
{T^.Command[1]:=$16;
T^.Command[3]:=$84;
T^.Neznam:=$00;
T^.Rezultat[1]:=$0D;
T^.Rezultat[2]:=$02;
T^.Rezultat[3]:=$0D;
T^.Rezultat[4]:=$03;
T^.Rezultat[5]:=$0E;
T^.Rezultat[6]:=$02;
T^.Rezultat[7]:=$0E;
T^.Rezultat[8]:=$02;
T^.Rezultat[9]:=$0E;
T^.Rezultat[10]:=$02;
T^.SendCommand;}
Repeat
T^.Command[1]:=$1A;
T^.Command[3]:=$03;
T^.Neznam:=$00;
T^.Rezultat[1]:=$0D;
T^.Rezultat[2]:=$02;
{T^.Rezultat[3]:=$07;{Vrednost za odredena pesna 3 Pesna Br.  5 Minuti 6  Sekundi  7 Stotinki }
{T^.Rezultat[4]:=$01;{Vredost za celo CD 9 Minuti 10  Sekundi  11 Stotinki }
T^.SendCommand;
GotoXY(1,1);
Write(T^.Rezultat[1]:3,T^.Rezultat[2]:3,T^.Rezultat[3]:3,
T^.Rezultat[4]:2,T^.Rezultat[5]:3,T^.Rezultat[6]:3,
T^.Rezultat[7]:3,T^.Rezultat[8]:3,T^.Rezultat[9]:3,T^.Rezultat[10]:3
,T^.Rezultat[11]:3,T^.Rezultat[12]:3,T^.Rezultat[13]:3
,T^.Rezultat[14]:3,T^.Rezultat[15]:3,T^.Rezultat[16]:3
,T^.Rezultat[17]:3,T^.Rezultat[18]:3,T^.Rezultat[19]:3
,T^.Rezultat[20]:3,T^.Rezultat[21]:3);
Until (KeyPressed);
End.