Unit Knigo01;
Interface
{$D+}
Uses Drivers,Objects,Views,Dialogs;
Type

 PVPodatWindow = ^TvPodatWindow;
 TVPodatWindow = object(TDialog)
   Comm :Word;
   List :PView;
   OkBut:PButton;
   procedure   HandleEvent(var Event: TEvent);virtual;
   constructor Init(No:Word;Knigo:PCollection);
   procedure   close;virtual;
 end;

 PPPodatWindow = ^TPPodatWindow;
 TPPodatWindow = object(TDialog)
   Comm :Word;
   List :PView;
   CData :PCollection;
   procedure   HandleEvent(var Event: TEvent);virtual;
   constructor Init(No:Word;Knigo:PCollection);
   procedure   close;virtual;
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

Implementation

procedure TvPodatWindow.HandleEvent(var Event: TEvent);
Begin
  TDialog.HandleEvent(Event);
  if Event.What = evCommand then
    case Event.Command of
      cmClose:TvPodatWindow.Close;
    end;
End;

Constructor TvPodatWindow.Init(No:Word;Knigo:PCollection);
var
  R: TRect;
  P: PView;
begin
DisableCommands([No]);
R.assign(1,1,60,20);
inherited Init(R, 'Vnesuvanje Podatoci');
Flags:=5;
Comm:=No;
R.assign(1,2,58,10);
P := New(PListBox, Init(R,1,Nil));
P^.Options := P^.Options and not ofSelectable;
Insert(P);
R.assign(5,10,19,12);
OkBut := New(PButton, Init(R, '~O~k', cmClose,1));
Insert(OkBut);
End;

Procedure TvPodatWindow.Close;
Begin
TDialog.Close;
EnableCommands([Comm]);
End;

procedure TPPodatWindow.HandleEvent(var Event: TEvent);
Var Coma:Boolean;
Begin
  TDialog.HandleEvent(Event);
  if Event.What = evCommand then
    case Event.Command of
      cmClose:TPPodatWindow.Close;
    end;
  if Event.What = evBroadcast then
    case Event.Command of
      cmReceivedFocus:
            Begin
            EnableCommands([107])
            End;
      cmReleasedFocus:
            Begin
            DisableCommands([107]);
            End;
{      cmCommandSetChanged:
            Begin
            If (Coma) Then}
    End;
End;


constructor TPPodatWindow.Init(No:Word;Knigo:PCollection);
Var R:TRect;
    P:PListBox;
    Kon,Lon:LongInt;
    St1,St2:String;
    Re1,Re2,Ret:Extended;
    Kn:PKnigoRec;
Begin
DisableCommands([No]);
R.assign(1,1,60,20);
If (No=117) then
                 Begin
                 inherited Init(R, 'ZList');
                 New(CData,Init(10,0))
                 End
            else
                 Begin
                 inherited Init(R, 'Vnesuvanje Podatoci');
                 New(CData,Init(8000,0));
                 End;
Case No Of
     117:For Kon:=0 to 9 do
             Begin
             Re1:=0;Re2:=0;Ret:=0;
             For Lon:=0 to Knigo^.Count-1 Do
                 Begin
                 Kn:=Knigo^.At(Lon);
                 If ((Kn^.Konto>=Kon*100000)And(Kn^.Konto<(Kon+1)*100000)) Then
                    Begin
                    Re1:=Re1+Kn^.Vlez;
                    Re2:=Re2+Kn^.Izlez;
                    End;
                 End;
             Str(Kon:1,St2);
             St1:='Klasa br:'+St2;
             Str(Re1:13:2,St2);
             St1:=St1+St2+' ';
             Str(Re2:13:2,St2);
             St1:=St1+St2+' ';
             If (Re1>Re2) Then Ret:=Re1-Re2;
             Str(Ret:13:2,St2);
             St1:=St1+St2+' ';
             If (Re1<Re2) Then Ret:=Re2-Re1
                          Else Ret:=0;
             Str(Ret:13:2,St2);
             St1:=St1+St2+' ';
             CData^.Insert(NewStr(St1));
             End;
         End;
Flags:=5;
Comm:=No;
R.assign(1,2,58,12);
New(P, Init(R,1,nil));
P^.NewList(CData);
Insert(P);
End;

procedure TPPodatWindow.Close;
Var t:Word;
Begin
For t:=0 to CData^.Count-1 Do DisposeStr(CData^.At(t));
CData^.Count:=0;
CData^.SetLimit(0);
Dispose(CData);
inherited Close;
EnableCommands([Comm]);
End;

End.