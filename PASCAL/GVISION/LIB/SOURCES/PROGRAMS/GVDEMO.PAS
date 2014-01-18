program GvDemo;

{$X+,S+,D+}

uses Dos,Graph, Objects, EventMan, Memory,LowGraph, GrDriver, GraV, GraMenu, Controls,
  GStdDlg,MsgBox,GrApp, GEditors,Calc,Puzzle,GadGets,GFonts,Arty,Images,
  ImgView;

const
  HeapSize = 250 * (1024 div 16);

const
  cmCalculator   = 1004;
  cmShowClip     = 1005;
  cmPuzzle       = 1006;
  cmArty         = 1007;
  cmAbout        = 1008;
  cmCircles      = 1009;
  cmSelImageType = 1001;
  cmShowImage    = 1002;
  cmChangeRes    = 1003;
type
  PDemoApp = ^TDemoApp;
  TDemoApp = object(GraphApplication)
    Clock : PClockView;
    Heap : PHeapView;
    constructor Init;
    destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Idle; virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure OutOfMemory; virtual;
  end;

  PAboutPane = ^AboutPane;
  AboutPane = object(GraphView)
     constructor Init(Bounds : TRect);
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

  PCircleDemoWindow = ^CircleDemoWindow;
  CircleDemoWindow = object(GraphWindow)
     constructor Init(var Bounds : TRect);
  end;

var
  DemoApp: TDemoApp;
  ClipWindow: PEditWindow;
  EXEName: PathStr;

const
  ImageType : word = 1;
  ImageExt : array[1..2] of string[3] = ('BMP','PCX');

(*
procedure VesaDriverProc; external;
{$L vesa16.obj}

{$F+}
procedure MyRegisterProc;
begin
  if RegisterBGIDriver(@VesaDriverProc) < 0 then
     Halt(1);
end;
{$F-}
*)

function ExecDialog(P: PGraphDialog; Data: Pointer): Word;
var
  Result: Word;
begin
  Result := cmCancel;
  P := PGraphDialog(Application^.ValidView(P));
  if P <> nil then
  begin
    if Data <> nil then P^.SetData(Data^);
    Result := DeskTop^.ExecView(P);
    if (Result <> cmCancel) and (Data <> nil) then P^.GetData(Data^);
    Dispose(P, Done);
  end;
  ExecDialog := Result;
end;


function DoEditDialog(Dialog: Integer; Info: Pointer): Word; far;
var
  R: TRect;
  T: TPoint;
begin
  case Dialog of
    edOutOfMemory:
      DoEditDialog := MessageBox('Not enough memory for this operation.',
        nil, mfError + mfOkButton);
    edReadError:
      DoEditDialog := MessageBox('Error reading file %s.',
        @Info, mfError + mfOkButton);
    edWriteError:
      DoEditDialog := MessageBox('Error writing file %s.',
        @Info, mfError + mfOkButton);
    edCreateError:
      DoEditDialog := MessageBox('Error creating file %s.',
        @Info, mfError + mfOkButton);
    edSaveModify:
		begin
      DoEditDialog := MessageBox('%s has been modified. Save?',
        @Info, mfInformation + mfYesNoCancel);
      end;
    edSaveUntitled:
      begin
      DoEditDialog := MessageBox('Save untitled file?',
        nil, mfInformation + mfYesNoCancel);
      end;
    edSaveAs:
      DoEditDialog := ExecDialog(New(PFileDialog, Init('*.*',
        'Save file as', '~N~ame', fdOkButton, 101)), Info);
  end;
end;

function OpenEditor(FileName: FNameStr; Visible: Boolean): PEditWindow;
var
  P: PGraphView;
  R: TRect;
begin
  DeskTop^.GetExtent(R);
  P := Application^.ValidView(New(PEditWindow,
    Init(R, FileName, wfFramed + wfTitle + wfClose + wfZoom + wfMove + wfGrow)));
  if P <> nil then if not Visible then P^.Hide;
  DeskTop^.Insert(P);
  OpenEditor := PEditWindow(P);
end;

constructor AboutPane.Init(Bounds : TRect);
begin
   GraphView.Init(Bounds);
end;

procedure AboutPane.Draw;
var
   R : TRect;
   P : TPoint;
begin
   GetExtent(R);
   SetFillStyle(SolidFill,GetColor(1));
	Bar(R);
   SetFillStyle(SolidFill,Red);
   SetColor(Red);
   P.X := 17;
   P.Y := 47;
   FillEllipse(P,15,15);
   SetFillStyle(SolidFill,Green);
   SetColor(Green);
   P.X := 43;
   P.Y := 47;
   FillEllipse(P,15,15);
   SetFillStyle(SolidFill,Blue);
   SetColor(Blue);
   P.X := 30;
   P.Y := 70;
   FillEllipse(P,15,15);
   GFonts.SetTextStyle(3,HorizDir,1);
   Fillbackground := false;
   SetColor(DarkGray);
   P.X := 115;
	P.Y := 10;
   WriteTextXY(P,'Graph Vision');
   dec(P.X);
   dec(P.Y);
   SetColor(Blue);
   WritetextXY(P,'Graph Vision');
   FillBackground := true;
   GFonts.SetTextStyle(2,HorizDir,1);
   P.X := 121;
   P.Y := 40;
   SetFillStyle(SolidFill,GetColor(1));
   SetColor(Black);
   WriteTextXY(P,'Written by');
   inc(P.Y,15);
   P.X := 100;
   WriteTextXY(P,'Sergey E. Levov');
   inc(P.Y,32);
   P.X := 70;
   WriteTextXY(P,'Phone: (095) 954-55-78');
   inc(P.Y,15);
	P.X := 80;
   WriteTextXY(P,'E-mail: serg@riis.ru');
end;

constructor TInfo.Init(Center : TPoint; Radius : integer; AColor : word);
begin
   TObject.Init;
   C := Center;
   R := Radius;
   Cl := AColor;
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
   Dispose(Data,Done);
   GraphView.Done;
end;

constructor CircleDemoWindow.Init(var Bounds : Trect);
var
   R : TRect;
begin
   GraphWindow.Init(Bounds,'Circles',wfFramed + wfTitle + wfClose + wfZoom + wfMove + wfGrow);
{   GrowMode := gfGrowRel;}
   WorkSpace^.GetExtent(R);
   Insert(New(PCircleDemo, Init(R,20)));
end;

constructor TDemoApp.Init;
var
  H: Word;
  R: TRect;
begin
  MaxHeapSize := HeapSize;
  GraphApplication.Init;
  DisableCommands([cmSave, cmSaveAs, cmCut, cmCopy, cmPaste, cmClear,
    cmUndo, cmFind, cmReplace, cmSearchAgain]);
  EditorDialog := DoEditDialog;
  GetExtent(R);
  R.A.X := R.B.X - 74;
  inc(R.A.Y);
  R.B.Y := R.A.Y + 14;
  Clock := New(PClockView,Init(R));
  Insert(Clock);
  GetExtent(R);
  dec(R.B.Y,2);
  R.A.Y := R.B.Y - 14;
  R.A.X := R.B.X - 74;
  dec(R.B.X,2);
  Heap := New(PHeapView,Init(R));
  Insert(Heap);
  ClipWindow := OpenEditor('', False);
  if ClipWindow <> nil then
  begin
    Clipboard := ClipWindow^.Editor;
    Clipboard^.CanUndo := False;
  end;
end;

destructor TDemoApp.Done;
begin
  GraphApplication.Done;
end;

procedure TDemoApp.HandleEvent(var Event: TEvent);

procedure FileOpen;
var
  FileName: FNameStr;
begin
  FileName := '*.*';
  if ExecDialog(New(PFileDialog, Init('*.*', 'Open file',
    '~N~ame', fdOpenButton, 100)), @FileName) <> cmCancel
  then OpenEditor(FileName, True);
end;

procedure SelectType;
var
   D : PGraphDialog;
   R,R1 : TRect;
   RB : PGraphRadioButtons;
begin
   R.Assign(0,0,150,80);
   R.Move((Desktop^.Size.X - R.B.X) div 2, (Desktop^.Size.Y - R.B.Y) div 2);
   D := New(PGraphDialog,Init(R,'Image type'));
   D^.WorkSpace^.GetExtent(R);
   R.Grow(-1,-5);
   R.B.X := 70;
   RB := New(PGraphRadioButtons,Init(R,
             NewSItem('~B~MP',
             NewSItem('~P~CX',
             nil))
          ));
{   RB^.SetData(ImageType);}
   D^.Insert(RB);
   R1.Assign(74,10,139,49);
   D^.Insert(New(PGraphBitmapButton,Init(R1,'OK',cmOk,bfDefault)));
   PGraphGroup(D^.WorkSpace)^.SelectNext(false);
   D^.SetData(ImageType);
   if DeskTop^.ExecView(D) = cmOk then D^.GetData(ImageType);
   Dispose(D,Done);
end;

procedure ShowImage;
var
   FileName : FNameStr;
   R : TRect;
   P : PGraphView;
begin
   FileName := '*.'+ImageExt[ImageType];
   if ExecDialog(New(PFileDialog,Init('*.*','Show image','~N~ame',
   fdOpenButton,100)), @FileName) <> cmCancel
   then begin
     DeskTop^.GetExtent(R);
     case ImageType of
       1 :  P := Application^.ValidView(New(PBmpWindow, Init(R, FileName)));
       2 :  P := Application^.ValidView(New(PPCXWindow, Init(R,FileName)));
     end;
     DeskTop^.Insert(P);
   end;
end;

procedure Calculator;
begin
  DeskTop^.Insert(ValidView(New(PCalculator, Init)));
end;

procedure Puzzle;
begin
  DeskTop^.Insert(ValidView(New(PPuzzleWindow,Init)));
end;

procedure Arty;
begin
   DeskTop^.Insert(ValidView(New(PArtyWindow,Init)));
end;

procedure Circles;
var
   R,R1 : Trect;
begin
   Randomize;
   repeat
      R.Assign(Random(GetMaxX),Random(GetMaxY),
      Random(GetMaxX),Random(GetMaxY));
      GetExtent(R1);
      R1.Intersect(R);
   until (not R1.Empty) and (R1.B.X-R1.A.X > MinWinSize.X)
   and (R1.B.Y-R1.A.Y > MinWinSize.Y);
   Desktop^.Insert(ValidView(New(PCircleDemoWindow,Init(R))));
end;

procedure About;
var
   D : PGraphDialog;
   R : TRect;
   P : PGraphView;
begin
  R.Assign(0, 0, 351, 258);
  R.Move((Desktop^.Size.X - R.B.X) div 2, (Desktop^.Size.Y - R.B.Y) div 2);
  D := New(PGraphDialog,Init(R,'About'));
  with D^ do begin
     R.Assign(14,13,325,157);
     Insert(New(PGraphGrayGroup,Init(R)));
     R.Assign(28,26,318,144);
     Insert(New(PAboutPane,Init(R)));
     R.Assign(132,174,195,213);
     P := New(PGraphBitmapButton,Init(R,'O~K~',cmOk,bfNormal));
     Insert(P);
     SelectNext(false);
  end;
   DeskTop^.ExecView(D);
   Dispose(D,Done);
end;

procedure FileNew;
begin
  OpenEditor('Boro', True);
end;

procedure ShowClip;
begin
  if ClipWindow <> nil then begin
     ClipWindow^.Select;
     ClipWindow^.Show;
  end;
end;

procedure ChangeScreenResolution;
{ just an exalmple - quick and dirty }
{ realised for 16 color modes only }
var R : TRect;
begin
  DoneEvents;
  DoneVideo;
  if DriverType=StandardVGA
    then
      begin
   	DriverType := Vesa256;
      DriverMode := VESA256_640x480;
	   EmulateMouseCursor := false;
      end
    else
      begin
	DriverType := StandardVGA;
	DriverMode := VGA640x480;
	EmulateMouseCursor := false;
      end;
  InitVideo;
  R.Assign(0,0,ScreenWidth,ScreenHeight);
  Application^.ChangeBounds(R);
  InitEvents;
end;

procedure ChangeMemViewer;
begin
end;
   
begin
  GraphApplication.HandleEvent(Event);
  case Event.What of
    evCommand:
      case Event.Command of
        cmOpen: FileOpen;
        cmNew: FileNew;
        cmDosShell: DosShell;
        cmShowClip: ShowClip;
        cmTile: Tile;
        cmCalculator: Calculator;
        cmCascade: Cascade;
        cmPuzzle: Puzzle;
        cmArty : Arty;
        cmAbout : About;
        cmCircles : Circles;
        cmSelImageType: SelectType;
        cmShowImage : ShowImage;
        cmChangeRes : ChangeScreenResolution;
      else
        Exit;
      end;
  else
    Exit;
  end;
  ClearEvent(Event);
end;

procedure TDemoApp.Idle;

function IsTileable(P: PGraphView): Boolean; far;
begin
  IsTileable := P^.Options and ofTileable <> 0;
end;

begin
  GraphApplication.Idle;
  Clock^.Update;
  Heap^.Update;
  Message(DeskTop,evBroadcast,cmIdle,nil);
  if Desktop^.FirstThat(@IsTileable) <> nil then
    EnableCommands([cmTile, cmCascade])
  else
    DisableCommands([cmTile, cmCascade]);
end;

procedure TDemoApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + MenuItemHeight;
  MenuBar := New(PGraphMenuBar, Init(R, NewMenu(
	 NewSubMenu('~ð~', hcNoContext, NewMenu(
      NewItem('Ca~l~culator', '', kbNoKey, cmCalculator, hcNoContext,
      NewItem('~P~uzzle','',kbNoKey,cmPuzzle,hcNoContext,
      NewItem('~A~rty','',kbNoKey,cmArty,hcNoContext,
      NewItem('A~b~out','',kbNoKey,cmAbout,hcNoContext,
      NewItem('C~i~rcles','',kbNoKey,cmCircles,hcNoContext,
      NewItem('~C~hange resolution','',kbNoKey,cmChangeRes,hcNoContext,
      nil))))))),
    NewSubMenu('~D~OS',hcNoContext,NewMenu(
      NewItem('D~O~S shell', '', kbNoKey, cmDosShell, hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
      nil)))),
    NewSubMenu('~T~ext',hcNoContext,NewMenu(
      NewItem('~O~pen...', 'F3', kbF3, cmOpen, hcNoContext,
      NewItem('~N~ew', '', kbNoKey, cmNew, hcNoContext,
      NewItem('~S~ave', 'F2', kbF2, cmSave, hcNoContext,
      NewItem('S~a~ve as...', '', kbNoKey, cmSaveAs, hcNoContext,
      NewItem('~U~ndo', '', kbNoKey, cmUndo, hcNoContext,
      NewLine(
      NewItem('Cu~t~', 'Shift-Del', kbShiftDel, cmCut, hcNoContext,
      NewItem('~C~opy', 'Ctrl-Ins', kbCtrlIns, cmCopy, hcNoContext,
      NewItem('~P~aste', 'Shift-Ins', kbShiftIns, cmPaste, hcNoContext,
      NewItem('~S~how clipboard', '', kbNoKey, cmShowClip, hcNoContext,
      NewLine(
      NewItem('C~l~ear', 'Ctrl-Del', kbCtrlDel, cmClear, hcNoContext,
      nil))))))))))))),
    NewSubMenu('~I~mages', hcNoContext, NewMenu(
      NewItem('~S~elect image type','',kbNoKey,cmSelImageType,hcNoContext,
      NewLine(
      NewItem('~L~oad image', '', kbNoKey, cmShowImage, hcNoContext,
      nil)))),
    NewSubMenu('~W~indows', hcNoContext, NewMenu(
      NewItem('~S~ize/move','Ctrl-F5', kbCtrlF5, cmResize, hcNoContext,
      NewItem('~Z~oom', 'F5', kbF5, cmZoom, hcNoContext,
      NewItem('~T~ile', '', kbNoKey, cmTile, hcNoContext,
      NewItem('C~a~scade', '', kbNoKey, cmCascade, hcNoContext,
      NewItem('~N~ext', 'F6', kbF6, cmNext, hcNoContext,
      NewItem('~P~revious', 'Shift-F6', kbShiftF6, cmPrev, hcNoContext,
      NewItem('~C~lose', 'Alt-F3', kbAltF3, cmClose, hcNoContext,
      nil)))))))),
    nil))))))));
end;

procedure TDemoApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - StatusItemHeight;
  New(StatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~F2~ Save', kbF2, cmSave,
      NewStatusKey('~F3~ Open', kbF3, cmOpen,
      NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
      NewStatusKey('~F5~ Zoom', kbF5, cmZoom,
      NewStatusKey('~F6~ Next', kbF6, cmNext,
      NewStatusKey('~F10~ Menu', kbF10, cmMenu,
      NewStatusKey('', kbCtrlF5, cmResize,
      nil))))))),
    nil)));
end;

procedure TDemoApp.OutOfMemory;
begin
  MessageBox('Not enough memory for this operation.',
    nil, mfError + mfOkButton);
end;

begin
  DemoApp.Init;
  DemoApp.Run;
  DemoApp.Done;
end.

