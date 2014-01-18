Program Midi;
{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T+,V-,X+,Y+}
{$M 16384,0,655360}
Uses Crt;
Procedure ShiftWord(Var Value:Word);
Assembler;
Asm
les di,Value
rol word ptr es:[di],8
End;

Procedure ShiftLong(Var Value:LongInt);
Assembler;
Asm
les di,Value
mov ax,word ptr es:[di]
mov bx,word ptr es:[di+2]
rol bx,8
rol ax,8
mov word ptr es:[di+2],ax
mov word ptr es:[di],bx
End;

Var F:File;
    ChId:String[4];
    Length:LongInt;
Begin
ClrScr;
WriteLn('Midi-Info');
Assign(F,'Wannabe.mid');
Reset(F,1);
ChId[0]:=#4;
Repeat
BlockRead(F,ChId[1],4);
BlockRead(F,Length,4);
ShiftLong(Length);
Seek(F,FilePos(F)+Length);
WriteLn(ChId+'  ',Length);
Until (EOF(F));
Close(F);
End.