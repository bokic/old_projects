{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T-,V-,X+,Y+}
{$M 16384,0,655360}
Program Efekt;
uses Memory, Drivers, Objects, Views, Menus, App,
     Dialogs, MsgBox, Gadget, Blaster, CDRip;
Const
  SectorLen = 8200;

  cmAbout           = 101;
  cmSBlaster        = 102;
  cmCDRom           = 103;
  cmMixing          = 104;

Type
  TEfektApp = object(TApplication)
  heap : PHeapView;
  Constructor Init;
  Destructor Done; virtual;
  Procedure InitMenuBar; virtual;
  Procedure Idle;Virtual;
  Procedure SBInfo;
  Procedure CDInfo;
  End;

Constructor TEfektApp.Init;
Var R:TRect;
    Freq:Word;
Begin
inherited Init;
GetExtent(R);
R.A.Y := R.B.Y - 1;
R.A.X := R.B.X - 4;
Heap := New(PHeapView,Init(R));
Insert(Heap);
Freq:=44100;
Blaster.InitBlaster(Freq,True,False);
If (Blaster.SBNo=0)Then
   Begin
   MessageBox(#3'Can''t find Sound Blaster..'#13 +
       #3'Exit the program ?',
       nil, mfYESButton or mfNOButton);
   End;
End;

Destructor TEfektApp.Done;
Begin
inherited Done;
End;

Procedure TEfektApp.InitMenuBar;
Var R: TRect;
Begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
   NewSubMenu('~ð~', hcNoContext, NewMenu(
      NewItem('~A~bout', '', kbNoKey, cmAbout, hcNoContext,
      nil)),
   NewSubMenu('~F~ile', hcNoContext, NewMenu(
      NewItem('~E~xit', '', kbNoKey, cmQuit, hcNoContext,
      nil)),
    NewSubMenu('~D~evices', hcNoContext, NewMenu(
      NewItem('~S~ound Blaster', '', kbNoKey, cmSBlaster, hcNoContext,
      NewItem('~CD~Rom', '', kbNoKey, cmCDRom, hcNoContext,
      nil))),
    NewSubMenu('~M~ixing', hcNoContext, NewMenu(
      NewItem('~G~o..', 'F10', kbF10, cmMixing, hcNoContext,
      nil)),
      nil)))))));
End;

Procedure TEfektApp.Idle;
Begin
Heap^.UpDate;
End;

Procedure TEfektApp.SBInfo;
Begin
End;

Procedure TEfektApp.CDInfo;
Begin
End;

Var EfektApp: TEfektApp;

Procedure NewExit;Far;
Begin
EfektApp.Done;
End;

Begin
ExitProc:=@NewExit;
EfektApp.Init;
EfektApp.Run;
End.