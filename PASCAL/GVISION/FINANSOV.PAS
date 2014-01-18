Program FinansovoKnigovodstvo;
{$DEFINE Debug}

{$IFDEF Debug}
{$A+,B-,D+,E-,F-,G+,I+,L+,N+,O-,P-,Q+,R+,S+,T+,V+,X+,Y+}
{$M 16384,0,655360}
{$ELSE}
{$A+,B-,D-,E-,F-,G+,I-,L-,N+,O-,P-,Q-,R-,S-,T+,V+,X+,Y-}
{$M 16384,0,655360}
{$ENDIF}

Uses TVGraph, Objects, Drivers, Views, Menus, Dialogs, App, Calc, Calendar, StdDlg, Knigo01
{$IFDEF Debug}
     ,Gadget;
{$ELSE}
     ,Gadgets;
{$ENDIF}
Var BegMem:LongInt;

Const
     cmAbout      = 100;
     cmKalendar   = 101;
     cmKalkulator = 102;
     cmPodNovi    = 103;
     cmPodOpen    = 104;
     cmPodSave    = 105;
     cmPodSaveAs  = 106;
     cmPodPecat   = 107;
     cmVnePodato  = 108;
     cmVneFirmi   = 109;
     cmIzmPodato  = 110;
     cmIzmFirmi   = 111;
     cmPrePodato  = 112;
     cmPreAna     = 113;
     cmPreSin     = 114;
     cmPreBB      = 115;
     cmPreKlasi   = 116;
     cmPreZList   = 117;
     cmPreFirmi   = 118;
Type
  TKnigoApp = object(TApplication)
    Knigo   : PCollection;
    Firmi   : PCollection;
    Heap    : PHeapView;
    {$IFNDEF Debug}
    Clock   : PClockView;
    {$ENDIF}
    constructor Init;
    destructor Done; virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure Idle; virtual;
    procedure _Calendar;
    procedure Calculator;
    procedure About;
    procedure Novi;
    procedure Otvaranje;
    procedure V_Podat;
    procedure P_Podat;
    procedure P_Anali;
    procedure P_Sinte;
    procedure P_BB;
    procedure P_Klasi;
    procedure P_ZList;
    procedure P_Firmi;
    procedure HandleEvent(var Event: TEvent); virtual;
  End;

  PKnigoRec=^TKnigoRec;
  TKnigoRec=object(TObject)
    Ime    :String[14];
    Konto  :Longint;
    Day    :Byte;
    Month  :Byte;
    Year   :Word;
    Vlez   :Extended;
    Izlez  :Extended;
  End;

    PFirmiRec=^TFirmiRec;
    TFirmiRec=Object(TObject)
    Konto:Word;
    Ime:String[30];
    End;

{ Main App }
Constructor TKnigoApp.Init;
Var
  R: TRect;
Begin
  BegMem:=MemAvail;
  RegisterMenus;
  RegisterObjects;
  RegisterViews;
  RegisterApp;
  RegisterDialogs;
  RegisterCalendar;
  RegisterCalc;
  inherited Init;
  New(Knigo,Init(8000,0));
  New(Firmi,Init(1000,0));
  GetExtent(R);
  { I F NDEF Debug
  R.A.X := R.B.X - 9;
  R.A.Y := 1;
  R.B.X := R.A.X + 8;
  R.B.Y := R.A.Y + 1;
  $ E LSE}
  R.A.X := R.B.X - 9;
  R.A.Y := R.B.Y - 1;
  R.B.X := R.A.X + 8;
  R.B.Y := R.A.Y + 1;
  { E NDIF}
  Heap :=  New(PHeapView, Init(R));
  Insert(Heap);
  {$IFNDEF Debug}
  GetExtent(R);
  R.A.X := R.B.X - 9;
  R.B.X := R.A.X + 8;
  R.B.Y := R.A.Y + 1;
  Clock := New(PClockView, Init(R));
  Insert(Clock);
  {$ENDIF}
  DisableCommands([cmPodNovi,cmPodSave..cmPodPecat,cmIzmPodato..cmPreFirmi]);
  End;

Procedure TKnigoApp.About;
Var
  R: TRect;
  D: PDialog;
  C: Word;

Begin
  R.Assign(0, 0, 40, 11);
  D := New(PDialog, Init(R, 'Informacii'));
  With D^ Do
  Begin
    Options := Options or ofCentered;
    R.Grow(-1, -1);
    Dec(R.B.Y, 3);
    Insert(New(PStaticText, Init(R,
      #13 +
      ^C'Finansovo Knigovodstvo v2.0'#13 +
      #13 +
      ^C'Copyright (c) 1996 Dekemvri'#13 +
      #13 +
      ^C'Barbulovski Boris')));
    R.Assign(15, 8, 25, 10);
    Insert(New(PButton, Init(R, 'O~K', cmOk, bfDefault)));
  End;
  C := DeskTop^.ExecView(D);
  Dispose(D, Done);
End;

Procedure TKnigoApp._Calendar;
Begin
  InsertWindow(New(PCalendarWindow, Init(cmKalendar)));
End;

Procedure TKnigoApp.Calculator;
Var P: PCalculator;
Begin
  InsertWindow(New(PCalculator, Init(cmKalkulator)));
End;

Procedure TKnigoApp.Novi;
Begin

DisableCommands([cmPodNovi,cmPodSave..cmPodSaveAs,cmIzmPodato..cmPreZList]);
Firmi^.FreeAll;
Knigo^.FreeAll;
End;

Procedure TKnigoApp.Otvaranje;
var
  D: PFileDialog;
  FileName: String[79];
  Len1,Len2,Temp:Word;
  F:File;
  Buf1:PKnigoRec;
  Buf2:PFirmiRec;
begin
  Filename:='*.KNI';
  New(D, Init(FileName, 'Otvaranje','~I~me', fdOpenButton, 1));
    If (ExecuteDialog(D,@FileName)<>cmCancel) Then
       Begin
       If (Knigo^.Count>0) Then Knigo^.FreeAll;
       If (Firmi^.Count>0) Then Firmi^.FreeAll;
       Assign(F, FileName);
       Reset(F,1);
       Seek(F,2);
       BlockRead(F,Len1,2);
       BlockRead(F,Len2,2);
       If (Len1>0) Then EnableCommands([cmIzmPodato,cmPrePodato..cmPreZList]);
       If (Len2>0) Then EnableCommands([cmIzmFirmi,cmPreFirmi]);
       For Temp:=1 to Len1 Do
           Begin
           New(Buf1,Init);
           If (Buf1=Nil) Then Halt(255);
           BlockRead(F,Buf1^.Ime,43);
           Knigo^.Insert(@Buf1^);
           End;
       For Temp:=1 to Len2 Do
           Begin
           New(Buf2,Init);
           If (Buf2=Nil) Then Halt(255);
           BlockRead(F,Buf2^.Ime,SizeOf(Buf2^)-2);
           Firmi^.Insert(@Buf2^);
           End;
       Close(F);
       EnableCommands([cmPodNovi,cmPodSave..cmPodSaveAs]);
       End;
End;

Procedure TKnigoApp.V_Podat;
Begin
  InsertWindow(New(PVPodatWindow, Init(cmVnePodato,Knigo)));
End;
Procedure TKnigoApp.P_Podat;
Begin
End;

Procedure TKnigoApp.P_Anali;
Begin
End;

Procedure TKnigoApp.P_Sinte;
Begin
End;

Procedure TKnigoApp.P_BB;
Begin
End;

Procedure TKnigoApp.P_Klasi;
Begin
End;

Procedure TKnigoApp.P_ZList;
Var t:PKnigoRec;
Begin
t:=Knigo^.At(1);
InsertWindow(New(PPPodatWindow, Init(cmPreZList,Knigo)));
End;

Procedure TKnigoApp.P_Firmi;
Begin
End;


Procedure TKnigoApp.HandleEvent(var Event: TEvent);
Begin
  TApplication.HandleEvent(Event);
  If Event.What = evCommand then
  Begin
    Case Event .Command of
      cmAbout      : About;
      cmKalendar   : _Calendar;
      cmKalkulator : Calculator;
      cmPodNovi    : Novi;
      cmPodOpen    : Otvaranje;
      cmVnePodato  : V_Podat;
      cmPrePodato  : P_Podat;
      cmPreAna     : P_Anali;
      cmPreSin     : P_Sinte;
      cmPreBB      : P_BB;
      cmPreKlasi   : P_Klasi;
      cmPreZList   : P_ZList;
      cmPreFirmi   : P_Firmi;
    Else
      Exit;
    End;
    ClearEvent(Event);
  End;
End;

Procedure TKnigoApp.InitMenuBar;
Var R: TRect;
Begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~ð~', hcNoContext, NewMenu(
      NewItem('~I~nfo','', 0, cmAbout, hcNoContext,
      NewLine(
      NewItem('~K~alendar', '', 0, cmKalendar, hcNoContext,
      NewItem('~K~alkulator', '', 0, cmKalkulator, hcNoContext, nil))))),

    NewSubMenu('~P~odatoci', hcNoContext, NewMenu(
      NewItem('~N~ovi','', 0, cmPodNovi, hcNoContext,
      NewItem('~O~tvaranje','', kbF3, cmPodOpen, hcNoContext,
      NewItem('~S~nimanje','', kbF2, cmPodSave, hcNoContext,
      NewItem('Snimanje ~k~ako?','', kbAltF2, cmPodSaveAs, hcNoContext,
      NewLine(
      NewItem('~P~ecatenje','', 0, cmPodPecat, hcNoContext,
      NewLine(
      NewItem('~I~zlez', '', kbAltX, cmQuit, hcNoContext, nil))))))))),
    NewSubMenu('~V~nesuvanje', hcNoContext, NewMenu(
      NewItem('~P~odatoci','', 0, cmVnePodato, hcNoContext,
      NewLine(
      NewItem('~F~irmi','', 0, cmVneFirmi, hcNoContext,nil)))),
    NewSubMenu('~I~zmenuvanje', hcNoContext, NewMenu(
      NewItem('~P~odatoci','', 0, cmIzmPodato, hcNoContext,
      NewLine(
      NewItem('~F~irmi','', 0, cmIzmFirmi, hcNoContext,nil)))),
    NewSubMenu('P~r~egled', hcNoContext, NewMenu(
      NewItem('~P~odatoci','', 0, cmPrePodato, hcNoContext,
      NewItem('~A~nalitika','', 0, cmPreAna, hcNoContext,
      NewItem('~S~intetitika','', 0, cmPreSin, hcNoContext,
      NewItem('~B~rutoBilans','', 0, cmPreBB, hcNoContext,
      NewItem('~K~lasi','', 0, cmPreKlasi, hcNoContext,
      NewItem('~Z~List','', 0, cmPreZList, hcNoContext,
      NewLine(
      NewItem('~F~irmi','', 0, cmPreFirmi, hcNoContext,nil))))))))),nil))))))));
End;

Procedure TKnigoApp.InitStatusLine;
Var R: TRect;
Begin
  GetExtent(R);
  R.A.Y := R.B.Y-1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, 4,
      NewStatusKey('~Alt-X~ Izlez', kbAltX, cmQuit,
      NewStatusKey('', kbTab, cmNext,
      NewStatusKey('', kbAltF3, cmClose,
      NewStatusKey('~Alt-P~ Pecatenje', kbAltP, cmPodPecat, nil)))), nil)));

End;

Procedure TKnigoApp.Idle;
Begin
  TApplication.Idle;
  Heap^.Update;
  {$IFNDEF Debug}
  Clock^.Update;
  {$ENDIF}
End;

Destructor TKnigoApp.Done;
Begin
inherited Done;
Dispose(Firmi,Done);
Dispose(Knigo,Done);
If (MemAvail>BegMem) Then WriteLn('Memory not returned:',MemAvail-BegMem);
End;

Var TVKNIGO: TKnigoApp;

Begin
  TVKNIGO.Init;
  TVKNIGO.Run;
  TVKNIGO.Done;
End.