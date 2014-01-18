{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T+,V-,X+,Y+}
{$M 16384,0,655360}
Program Efekti;
Uses Dos,Crt,Objects,EventMan,GraV,Controls,
     GraMenu,GrDriver,LowGraph,Grapp,MsgBox,Gadgets,CDRip,Blaster;
Const Buffers=4-1;
Type
   GMyApp = object(GraphApplication)
      Heap : PHeapView;
      Constructor Init;
      Destructor Done;Virtual;
      Procedure Idle;Virtual;
      Procedure HandleEvent(Var Event : TEvent);Virtual;
      Procedure InitMenuBar;Virtual;
   End;

   PInitWindow = ^InitWindow;
   InitWindow = Object(GraphDialog)
   CD_Buffer:PCDArray;
   Cur_Song,Start_Sector:PGraphInputLine;
   CD:^CD_Rip;
   Constructor Init;
   Destructor Done;virtual;
   Procedure HandleEvent(Var Event:TEvent);virtual;
   Procedure Idle;
   End;

Const
  SectorLen = 8200;

  cmInit            = 1001;
  cmInfo            = 1002;
  cmSoundBlaster    = 1003;
  cmCDRom           = 1004;
  cmBuffer          = 1005;

Var
  Debug:Boolean;
  Datoteka:Text;
  Window:PInitWindow;
  SB_Buffer:PDCDArray;
  Buffer:Array [0..Buffers] Of PCDArray;
  Dma_Pos,BufPos,CurPage:ShortInt;
  SP:Pointer;

Procedure IntProc(Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: Word);
Interrupt;
Begin
 Asm
 mov dx,dsp_addr
 add dl,$0F
 in al,dx { Sending the 16bit dma mode }
 end;
move(Buffer[DMA_Pos]^,SB_Buffer^[CurPage],30576);
 Asm
 xor CurPage,1
 mov al,Dma_Pos
 inc al
 or al,$FC
 xor al,$FC
 mov Dma_Pos,al
 mov al,$20
 out $20,al
 End;
End;

Constructor InitWindow.Init;
Var R:TRect;
Begin
R.Assign(50,50,300,400);
inherited Init(R,'Direct CD Effect');
R.Assign(20,20,70,40);
Insert(New(PGraphTextButton, Init(R, '~P~lay', 111,bfDefault+bfGrabFocus)));
R.Assign(100,20,150,40);
Insert(New(PGraphTextButton, Init(R, '~S~top', 112,bfDefault+bfGrabFocus)));
R.Assign(120,120,170,135);
Cur_Song:=New(PGraphInputLine,Init(R,2));
Cur_Song^.Data^:='1';
Insert(Cur_Song);
R.Assign(40,120,110,135);
Insert(new(PGraphLabel,Init(R,'S~o~ng No:',Cur_Song)));
R.Assign(120,140,170,155);
Start_Sector:=New(PGraphInputLine,Init(R,6));
Start_Sector^.Data^:='50';
R.Assign(30,140,110,155);
Insert(new(PGraphLabel,Init(R,'S~e~ctor No:',Start_Sector)));
Insert(Start_Sector);
End;

Destructor InitWindow.Done;
Begin
Inherited Done;
End;

Procedure InitWindow.HandleEvent(Var Event:TEvent);
Var Freq:Word;
    Sect:LongInt;
Begin
Idle;
If(Event.What=EvCommand) Then
    Case Event.Command Of
       111:
           Begin
           If (Debug) then
              Begin
              WriteLn(Datoteka,'Start of the Play button commands---');
              WriteLn(Datoteka,'Starting to alocate memory for SB Buffer.');
              Flush(Datoteka);
              End;
           If(SB_Buffer=Nil)Then
               New(SB_Buffer);
           FillChar(SB_Buffer^,SizeOf(SB_Buffer^),0);
           If (Debug) then
              Begin
              WriteLn(Datoteka,'Starting to alocate memory for CD Buffer.');
              Flush(Datoteka);
              End;
           If(CD_Buffer=Nil)Then
               New(CD_Buffer);
           FillChar(CD_Buffer^,SizeOf(CD_Buffer^),0);
           Val(Start_Sector^.Data^,Sect,Freq);
           If (Debug) then
              Begin
              WriteLn(Datoteka,'Starting to initialize CD-ROM.');
              Flush(Datoteka);
              End;
           New(CD,Init(CD_Buffer,Sect));
           Move(CD_Buffer^,SB_Buffer^[0],SizeOf(CD_Buffer^));
           If (Debug) then
              Begin
              WriteLn(Datoteka,'Starting to Read from CD-ROM.');
              Flush(Datoteka);
              End;
           CD^.Next;
           Move(CD_Buffer^,SB_Buffer^[1],SizeOf(CD_Buffer^));
           Freq:=44100;
           If (Debug) then
              Begin
              WriteLn(Datoteka,'Starting to initialize SB.');
              Flush(Datoteka);
              End;
           InitBlaster(Freq,True,True);
           set_sign(True);
           For Freq:= 0 To Buffers Do
               Begin
               New(Buffer[Freq]);
               FillChar(Buffer[Freq]^,SizeOf(Buffer[Freq]^),0);
               CD^.Next;
               Move(CD_Buffer^,Buffer[Freq]^,SizeOf(Buffer[Freq]^));
               End;
           If (Debug) then
              Begin
              WriteLn(Datoteka,'Starting to set the SB IRQ.');
              Flush(Datoteka);
              End;
           set_ready_irq(addr(IntProc));
           If (Debug) then
              Begin
              WriteLn(Datoteka,'Starting to set the SB DMA Values.');
              Flush(Datoteka);
              End;
           set_DMAValues(SB_Buffer,30576,True);
           If (Debug) then
              Begin
              WriteLn(Datoteka,'Starting a Play command.');
              Flush(Datoteka);
              End;
           play_firstBlock(15288);
           If (Debug) then
              Begin
              WriteLn(Datoteka,'End of the Play button commands---');
              Flush(Datoteka);
              End;
           ClearEvent(Event);
           End;
       112:
           Begin
           stop_play;
           Restore_IRQ;
           For Freq:= 0 To Buffers Do
               If (Buffer[Freq]<>Nil)Then
                  Begin
                  Dispose(Buffer[Freq]);
                  Buffer[FReq]:=Nil;
                  End;
           If (SB_Buffer<>Nil) Then
              Begin
              Dispose(SB_Buffer);
              SB_Buffer:=Nil;
              End;
           If (CD_Buffer<>Nil) Then
              Begin
              Dispose(CD_Buffer);
              CD_Buffer:=Nil;
              End;
           If (CD<>Nil) Then
              Begin
              Dispose(CD,Done);
              CD:=Nil;
              End;
           DMA_Pos:=0;BufPos:=0;CurPage:=0;
           ClearEvent(Event);
           End;
    End;
Inherited HandleEvent(Event);
ClearEvent(Event);
End;

Procedure InitWindow.Idle;
Var TST:String[3];
    T:Word;
    Eff:LongInt;
Begin
If ((CD_Buffer<>Nil)And(DMA_Pos<>BufPos)) Then
    Begin
    If (DMA_Pos<>BufPos+1)Then
       Begin
       Str(DMA_Pos,TST);
       Cur_Song^.Data^:=TST;
       Cur_Song^.DrawView;
       End;
    CD^.Next;
{    Move(CD_Buffer^,Buffer[BufPos],SizeOf(CD_Buffer^));{}
     For T:=1 To 15288 Do
         Begin
         Eff:=Longint(LongInt(Buffer[BufPos]^[T] div 4) + CD_Buffer^[T]);
         If ((Eff>=-32768)And(Eff<=32767)) Then
            Buffer[BufPos]^[T]:=Eff
            Else
            If (Eff<-32768) Then
               Buffer[BufPos]^[T]:=-32768
               Else
               Buffer[BufPos]^[T]:=32767
         End;
     Asm
     mov al,BufPos
     inc al
     or al,$FC
     xor al,$FC
     mov BufPos,al
     End;
    End;
End;

Constructor GMyApp.Init;
Var
   R : TRect;
   Temp:Array [1..1176] of Integer;
Begin
{  DriverType := Vesa256;
  DriverMode := 2;
  VesaDriverNames[Vesa256] := 'bgi256';
  EmulateMouseCursor := True;{}
  Randomize;
  Inherited Init;
  GetExtent(R);
  Dec(R.B.Y,2);
  R.A.Y := R.B.Y - 14;
  R.A.X := R.B.X - 74;
  Dec(R.B.X,2);
  Heap := New(PHeapView,Init(R));
  Insert(Heap);
  If (MaxAvail<300000) Then
     Begin
     MessageBox(#13'I need more memory (300k for heap).',
     nil,mfOkButton);
     Halt;
     End;
   Temp[1]:=-32000;
   Temp[2]:=32000;
   CDRead(1,100,@Temp);{ Poradi Test }
   If ((Temp[1]=-32000)and(Temp[2]=32000)) Then
     Begin
     MessageBox(#13'This CD-ROM driver can''t use Readlong Command.',nil,mfOkButton);
     Halt;
     End;{}
If (ParamStr(1)='/dump') Then
   Begin
   Debug:=True;
   Assign(Datoteka,'efekti.log');
   ReWrite(Datoteka);
   End;
End;

Destructor GMyApp.Done;
Begin
Dispose(Heap,Done);
Inherited Done;
End;

Procedure GMyApp.Idle;
Begin
Heap^.Update;
If (Window<>Nil) Then Window^.Idle;
End;

Procedure GMyApp.InitMenuBar;
Var R: TRect;
Begin
  GetExtent(R);
  R.B.Y := R.A.Y + MenuItemHeight;
  MenuBar := New(PGraphMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
      NewItem('~I~nit', '', kbnoKey, cmInit, hcNoContext,
      NewItem('~I~nfo', '', kbnoKey, cmInfo, hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
      Nil))))),
    NewSubMenu('~D~evices', hcNoContext, NewMenu(
      NewItem('~S~ound Blaster', '', kbnoKey, cmSoundBlaster, hcNoContext,
      NewItem('~C~D Rom', '', kbnoKey, cmCDRom, hcNoContext,
      NewLine(
      NewItem('~B~uffers', '', kbnoKey, cmBuffer, hcNoContext,
      Nil))))),
    Nil))
  )));
End;

Procedure GMyApp.HandleEvent(Var Event : TEvent);
Begin
   If (Event.What = evKeyDown) Then
      Begin
      Case Event.KeyCode Of
         kbF10 :
            Begin
               If (DeskTop^.Current <> Nil) Then
                  Message(DeskTop^.Current,evCommand,cmClose,Nil);
               ClearEvent(event);
            End;
         kbShiftTab :
            Begin
            Message(DeskTop,evCommand,cmPrev,Nil);
            ClearEvent(Event);
            End;
         End;
      End;
   If (Event.What = evCommand) Then
   Case Event.Command Of
        cmInit:
               Begin
               If(Blaster.UseBlasterEnv=False) Then
                    If (DetectSoundblaster(False)=False) Then
                       Begin
                       MessageBox(#13'Can''t Found Sound Blaster.',
                       nil,mfOkButton);
                       Exit;
                       End;
               Window:=New(PInitWindow,Init);
               Desktop^.Insert(Window);
               End;
        cmInfo:;
        cmSoundBlaster:;
        cmCDRom:;
   End;
   GraphApplication.HandleEvent(Event);
   ClearEvent(Event);
end;

Var MyApp : GMyApp;

Procedure Exit_Proc;Far;
Begin
ExitProc:=SP;
If (Debug) then
   Begin
   WriteLn(Datoteka,'Starting Exit Procedure');
   Flush(Datoteka);
   End;
 asm
 mov ax,3
 int $10
 end;
If (Blaster.SBNo>0)Then
  Begin
  If (Debug) then
     Begin
     WriteLn(Datoteka,'Starting Stop Command for SB.');
     Flush(Datoteka);
     End;
  stop_play;
  If (Debug) then
     Begin
     WriteLn(Datoteka,'Starting to restore int pointer for SB.');
     Flush(Datoteka);
     End;
  restore_irq;
  End;
If (Debug) then WriteLn(Datoteka,'End Exit Procedure');
If (Debug) then Close(Datoteka);
End;

Begin
SP:=ExitProc;
ExitProc:=@Exit_Proc;
MyApp.Init;
MyApp.Run;
MyApp.Done;
End.