program Test;
{$M 32000,0,655360}
{$X+,D+}
uses Dos,Crt,LowGraph,GFonts,Graph,Objects,ExtObj,EventMan,
     Memory,GraV,Controls,GraMenu,Grapp,MsgBox,GStdDlg,Gadgets,GrDriver,Images,Xms;
type
   GMyApp = object(GraphApplication)
      Heap : PHeapView;
      constructor Init;
      procedure Idle; virtual;
      procedure HandleEvent(var Event : TEvent); virtual;
      procedure InitMenuBar; virtual;
   end;

  PInterior = ^TInterior;
  TInterior = object(GraphScroller)
    constructor Init(var Bounds: TRect; AHScrollBar,
      AVScrollBar: PGraphScrollBar);
    procedure GetDelta(var ADelta : TPoint); virtual;
    procedure Draw; virtual;
  end;

  PInfo = ^TInfo;
  Tinfo = object(TObject)
     C : TPoint;
     R : Integer;
     cl : word;
     constructor Init(Center : TPoint; Radius : integer; AColor : word);
  end;

  PCircleDemo = ^CircleDemo;
  CircleDemo = object(GraphView)
     Data : PCollection;
     constructor Init(var Bounds : TRect; ANum : integer);
     destructor Done; virtual;
     procedure Draw; virtual;
  end;

const
  MaxLines          = 100;
  WinCount: Integer =   0;

var
  LineCount: Integer;
  Lines: array[0..MaxLines - 1] of PString;
var
   S : String;
   StrColl : TStringCollection;
   Palette : word;
   FileToRead : PathStr;
const
   WinNum : word = 0;

const
  cmNewWin          = 1001;
  cmConfirm         = 1005;
  cmInfo            = 1004;
  cmError           = 1003;
  cmWarning         = 1002;
procedure ReadFile;
var
  F: Text;
  S: String;
begin
  LineCount := 0;
  Assign(F, FileToRead);
  {$I-}
  Reset(F);
  {$I+}
  if IOResult <> 0 then
  begin
    Writeln('Cannot open ', FileToRead);
    Halt(1);
  end;
  while not Eof(F) and (LineCount < MaxLines) do
  begin
    Readln(F, S);
    Lines[LineCount] := NewStr(S);
    Inc(LineCount);
  end;
  Close(F);
end;

procedure DoneFile;
var
  I: Integer;
begin
  for I := 0 to LineCount - 1 do
    if Lines[I] <> nil then DisposeStr(Lines[i]);
end;

constructor TInfo.Init(Center : TPoint; Radius : integer; AColor : word);
begin
   TObject.Init;
   C := Center;
   R := Radius;
   Cl := AColor;
end;

{ TInterior }
constructor TInterior.Init(var Bounds: TRect; AHScrollBar,
  AVScrollBar: PGraphScrollBar);
begin
  GraphScroller.Init(Bounds, AHScrollBar, AVScrollBar);
  GrowMode := gfGrowHiX + gfGrowHiY;
  SetLimit(128, LineCount);
  Step.X := 8;
  Step.Y := 14;
end;

procedure TInterior.GetDelta(var ADelta : TPoint);
begin
   with ADelta do begin
      X := Size.X div 8;
      Y := Size.Y div 14;
   end;
end;

procedure TInterior.Draw;
var
  BackColor,TextColor: word;
  I,j, Y, H: Integer;
  R : TRect;
  T : TPoint;
  S : String;
begin
  GFonts.SetTextStyle(SystemFont,HorizDir,1);
  BackColor := GetColor(1);
  TextColor := GetColor(2);
  H := GFonts.TextHeight(' ');
  R.Assign(0,-H,Size.X,0);
  SetFillStyle(SolidFill,BackColor);
  SetTextJustify(LeftText,CenterText);
  j := Size.X div 8;
  if (Size.X mod 8) <> 0 then inc(j);
  for Y := 0 to (Size.Y div H) do
  begin
    R.Move(0,H);
{    Bar(R);}
    SetColor(TextColor);
    i := Delta.Y + Y;
    T.X := R.A.X;
    T.Y := R.A.Y + (R.B.Y - R.A.Y) div 2;
    if (I < LineCount) and (Lines[I] <> nil) then begin
      S := Copy(Lines[i]^,Delta.X+1,j);
      if Length(S) <= j then begin
         FillChar(S[Length(S)+1],j-Length(S),' ');
         S[0] := Char(j);
      end;
    end else begin
       FillChar(S[1],j,$20);
       S[0] := Char(j);
    end;
    WriteTextXY(T,S);
  end;
end;

constructor CircleDemo.Init(var Bounds : TRect; ANum : integer);
var
   i : integer;
   M : PInfo;
   A : TPoint;
begin
   GraphView.Init(Bounds);
   GrowMode := gfGrowHiX + GfGrowHiY;
   Data := New(PCollection,Init(ANum,1));
   Randomize;
   for i := 0 to ANum-1 do begin
      A.X := Random(ScreenWidth);
      A.Y := Random(ScreenHeight);
      M := New(Pinfo,Init(A,Random(200),Random(GetMaxColor)));
      Data^.Insert(M);
   end;
end;

procedure CircleDemo.Draw;
var
   R : TRect;
   T : TPoint;
   X,Y : integer;
procedure DrawCircle(P : PObject); far;
begin
  if P = nil then Exit;
  with PInfo(P)^ do begin
     SetFillStyle(SolidFill,Cl);
     SetColor(Cl);
     FillEllipse(C,R,2 * R div 3);
  end;
end;

begin
   GetExtent(R);
   SetFillStyle(SolidFill,Black);
   Bar(R);
   Data^.ForEach(@DrawCircle);
end;

destructor CircleDemo.Done;
begin
   Data^.Done;
   GraphView.Done;
end;

constructor GMyApp.Init;
var
   R : TRect;
begin
   GraphApplication.Init;
   GetExtent(R);
   dec(R.B.Y,2);
   R.A.Y := R.B.Y - 14;
   R.A.X := R.B.X - 74;
   dec(R.B.X,2);
   Heap := New(PHeapView,Init(R));
   Insert(Heap);
end;

procedure GMyApp.Idle;

function IsTileable(P: PGraphView): Boolean; far;
begin
  IsTileable := P^.Options and ofTileable <> 0;
end;

begin
  GraphApplication.Idle;
  Heap^.Update;
end;


procedure GMyApp.InitMenuBar;
var R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + MenuItemHeight;
  MenuBar := New(PGraphMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
      NewItem('~O~pen', 'F3', kbF3, cmFileOpen, hcNoContext,
      NewItem('~N~ew', 'F4', kbF4, cmNewWin, hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
      nil))))),
    NewSubMenu('~W~indow', hcNoContext, NewMenu(
      NewItem('~N~ext', 'F6', kbF6, cmNext, hcNoContext,
      NewItem('~Z~oom', 'F5', kbF5, cmZoom, hcNoContext,
      nil))),
    NewSubMenu('~D~ialogs',hcNoContext,NewMenu(
      NewItem('~C~onfirm','',kbNoKey,cmConfirm,hcNoContext,
      NewItem('~E~rror','',kbNoKey,cmError,hcNoContext,
      NewItem('~I~nformation','',kbNoKey,cmInfo,hcNoContext,
      NewItem('~W~arning','',kbNoKey,cmWarning,hcNoContext,
      nil))))),
    nil))
  ))));
end;

procedure GMyApp.HandleEvent(var Event : TEvent);
var
   R : TRect;
   R1,R2 : TRect;
   W : word;
   Wnd,Child : PGraphWindow;
   Button : PGraphTextButton;
   scro : PGraphScrollBar;
   BitBtn : PGraphBitmapButton;
   t : PTextListBox;
   Radio : PGraphRadioButtons;
   Checks : PGraphCheckBoxes;
   Par : word;
   APattern: FillSettingsType;
   Pb : PByteFlow;
   Interior : PInterior;
   HScrollBar, VScrollBar: PGraphScrollBar;
   Ln : PGraphInputLine;
   D : PFileDialog;
   M : LongInt;
   Wd : PGraphDialog;
   Filter : PBmpFilter;
begin
   if (Event.What = evKeyDown) then begin
      case Event.KeyCode of
         kbF10 :
            begin
               if DeskTop^.Current <> nil then
               Message(DeskTop^.Current,evCommand,cmClose,nil);
               ClearEvent(event);
            end;
         kbShiftTab : begin
                        Message(DeskTop,evCommand,cmPrev,nil);
                        ClearEvent(Event);
                      end;
      end;
   end;
   if (Event.What = evCommand) and (Event.Command = cmFileOpen) then begin
      D := New(PFileDialog, Init('*.*', 'Open a File',
      '~N~ame', fdOpenButton, 100));
      D := PFileDialog(Application^.ValidView(D));
      if D <> nil then
      begin
         W := Desktop^.ExecView(D);
         if W = cmCancel then begin
            Dispose(D,Done);
            ClearEvent(Event);
	    Exit;
         end;
         D^.GetFileName(FileToRead);
         Dispose(D,Done);
         ReadFile;
         R.Assign(10,10,200,200);
         Wnd := New(PGraphWindow,Init(R,FileToRead,
                    wfMove + wfGrow + wfTitle+ wfFramed + wfZoom + wfClose));
         Wnd^.Palette := wpCyanWindow;
         VScrollbar := Wnd^.StandardScrollBar(sbVertical+sbHandleKeyboard);
         HScrollBar := Wnd^.StandardScrollBar(sbHorizontal+sbHandleKeyboard);
         Wnd^.WorkSpace^.GetExtent(R);
         R.Grow(-1,-1);
         Wnd^.Insert(New(PInterior,Init(R,HScrollBar,VScrollBar)));
         DeskTop^.Insert(Wnd);
      end;
   end else
   if (Event.What = evCommand) and (Event.Command = cmNewWin) then begin
       repeat
          R.Assign(Random(GetMaxX),Random(GetMaxY),
          Random(GetMaxX),Random(GetMaxY));
          GetExtent(R1);
          R1.Intersect(R);
       until (not R1.Empty) and (R1.B.X-R1.A.X > MinWinSize.X)
       and (R1.B.Y-R1.A.Y > MinWinSize.Y);
       inc(WinNum);
       Palette := (WinNum mod 3);
       Str(WinNum,S);
       W := wfThickFrame + wfTitle + wfZoom + wfMove + wfGrow;
       M := MemAvail;
       Wnd :=New(PGraphWindow,Init(R,'Test window '+S,W));
       Wnd^.Palette := Palette;
{       if WinNum = 1 then begin
          R2.Assign(5,5,215,20);
          Scro := New(PGraphScrollBar,Init(R2));
          Scro^.SetParams(0,0,50,10,1);
          Wnd^.Insert(Scro);
          R2.Assign(40,40,55,240);
          Scro := New(PGraphScrollBar,Init(R2));
          Wnd^.Insert(Scro);
       end;}
       if WinNum = 2 then begin
          Wnd^.WorkSpace^.GetExtent(R2);
          Wnd^.Insert(New(PCircleDemo, Init(r2,20)));
       end;
       if WinNum = 3 then begin
          Dispose(Wnd,Done);
          Wnd := nil;
          R2.Assign(100,20,500,450);
          Wd := New(PGraphDialog,Init(R2,'Test dialog'));
          WD^.Palette := dpBlueDialog; 
          R2.Assign(20,20,83,59);
          BitBtn := New(PGraphBitmapButton,Init(R2,'OK',cmOk,bfNormal));
          M := memAvail;
          Wd^.Insert(BitBtn);
          M := MemAvail;
          R2.Move(70,0);
          BitBtn := New(PGraphBitmapButton,Init(R2,'CANCEL',cmCancel,bfNormal+ bfGrabFocus));
          M := MemAvail;
          Wd^.Insert(BitBtn);
          R2.Move(70,0);
          BitBtn := New(PGraphBitmapButton,Init(R2,'HELP',cmYes,bfNormal+bfGrabFocus));
          M := MemAvail;
          Wd^.Insert(BitBtn);
          R2.Move(70,0);
          BitBtn := New(PGraphBitmapButton,Init(R2,'SETUP',cmCancel,bfNormal+bfGrabFocus));
          M := Memavail;
          Wd^.Insert(BitBtn);
          R2.Move(70,0);
          Wd^.Insert(New(PGraphTextButton,Init(r2,'C~a~ncel',cmCancel, bfDefault+bfGrabFocus)));
          R2.Assign(212,78,227,160);
          Scro := New(PGraphScrollBar,Init(R2));
          Wd^.Insert(Scro);
          R2.Assign(10,78,212,160);
          Wd^.Insert(New(PGraphGrayGroup,Init(R2)));
          R2.Grow(-2,-2);
          t := (New(PTextListBox,Init(R2,1,Scro)));
          Wd^.Insert(t);
          t^.NewList(@StrColl);
          R2.Assign(10,63,227,77);
          Wd^.Insert(New(PGraphLabel,Init(R2,'It is ~l~istbox',t)));
          R2.Assign(10,190,227,256);
          Radio := New(PGraphRadioButtons,Init(R2,
             NewSItem('~F~irst radio button',
             NewSItem('~S~econd radio button',
             NewSItem('~T~hird radio button',
             nil)))
          ));
    {      Par := 2;
          Radio^.SetData(par);}
          Wd^.Insert(Radio);
          R2.Assign(10,174,200,188);
          Wd^.Insert(New(PGraphLabel,Init(R2,'~R~adioButtons',Radio)));
          R2.Assign(10,280,227,346);
          Checks := New(PGraphCheckBoxes,Init(R2,
             NewSItem('~F~irst check box',
             NewSItem('~S~econd check box',
             NewSItem('~T~hird check box',
             nil)))
          ));
    {      Par := 6;
          Checks^.SetData(Par);}
          Wd^.Insert(Checks);
          R2.Assign(10,264,200,278);
          Wd^.Insert(New(PGraphLabel,Init(R2,'~C~heckBoxes',Checks)));
          R2.Assign(10,370,227,388);
          Wd^.Insert(New(PGraphGrayGroup,Init(R2)));
          R1.Copy(R2);
          R2.Grow(-2,-2);
          dec(R2.B.X,13);
          Ln := New(PGraphInputLine,Init(R2,40));
          Wd^.Insert(Ln);
          R1.A.X := R1.B.X-13;
          R1.Move(-1,1);
          Wd^.Insert(New(PGraphHistory,Init(R1,Ln,1)));
          R2.Assign(240,78,289,143);
          Wd^.Insert(New(PGraphStaticBitmap,Init(R2,'CONFIRM')));
          R2.Move(0,70);
          Wd^.Insert(New(PGraphStaticBitmap,Init(R2,'ERROR')));
          R2.Move(0,70);
          Wd^.Insert(New(PGraphStaticBitmap,Init(R2,'INFORMATION')));
          R2.Move(0,70);
          Wd^.Insert(New(PGraphStaticBitmap,Init(R2,'WARNING')));
          if NOT LowMemory then
          PGraphGroup(Wd^.WorkSpace)^.SelectNext(false);
          if LowMemory then Dispose(Wd,Done) else DeskTop^.Insert(Wd);
       end;
       if LowMemory then begin
          if Wnd <> nil then Dispose(Wnd,Done);
       end else
          DeskTop^.Insert(Wnd);
       ClearEvent(Event);
   end;
   if Event.What = evCommand then
      Case Event.Command of
         cmConfirm,
         cmError,
         cmInfo,
         cmWarning:
            begin
               MessageBox(#13'This is test message box with buttons and static text',
               nil,Event.Command-cmWarning+ mfYesNoCancel);
            end;
      end;
   GraphApplication.HandleEvent(Event);
   ClearEvent(Event);
end;

var
   MyApp : GMyApp;
   A : PGraphView;
   F : PGraphWindow;
   D : GraphGroup;
   R,R1 : TRect;
  MaxX, MaxY  : word;     { The maximum resolution of the screen }
  ErrorCode   : integer;  { Reports any graphics errors }
  MaxColor    : word;     { The maximum color value available }
  OldExitProc : Pointer;  { Saves exit procedure address }
  PathToDriver : string;
  Ch : Char;
  i : integer;
begin
{  DriverType := Vesa16;
    DriverMode := Vesa16_800x600;}
{    VesaDriverNames[Vesa256] := 'svga';
    Vesa256Modes[0] := 33;
    Vesa256Modes[1] := 34;
    Vesa256Modes[2] := 35;
    Vesa256Modes[3] := 36;
	 Vesa256Modes[4] := 37;}
  EmulateMouseCursor := true;
  Randomize;
  StrColl.Init(10,2);
  with StrColl do begin
     AtInsert(0,NewStr('Test string 1'));
     AtInsert(1,NewStr('Test string 2'));
     AtInsert(2,NewStr('Test listbox'));
     AtInsert(3,NewStr('and associate'));
     AtInsert(4,NewStr('scrollbar'));
     AtInsert(5,NewStr('        '));
     AtInsert(6,NewStr('aaaaaaaaaaaaaaaaaa'));
     AtInsert(7,NewStr('bbbbbbbbbbbb'));
     AtInsert(8,NewStr('ccccccccc'));
  end;
  R.Assign(10,10,50,50);
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
  DoneFile;
end.