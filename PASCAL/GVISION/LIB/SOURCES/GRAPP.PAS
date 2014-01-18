{************************************************}
{   Grapp.pas                                    }
{   Graph Vision unit                            }
{   Sergey E. Levov, Moscow,1992-1994            }
{   Portions copyright (c) 1990 by Borland Int.  }
{************************************************}

unit GrApp;

{$F+,O+,S-,X+,D+}

interface

uses Graph, Objects, ExtObj, EventMan, GrDriver, Memory,
     HistList, GraV , Controls, GraMenu, GFonts,Images;

const
   CColor = #01#09#08 + { Desktop background }
   #07#15#08#08#00#04#08#00#04 + { Menus and status line }
   { Gray window }
   #07#15#08#07#15#08#00#08#07#15#08#07#15#08#09#14#01#15#07#15#08#00#08#07#00#09#15+
   { Blue window }
   #01#09#08#07#15#08#00#08#05#13#08#05#13#08#01#14#01#15#03#11#01#00#08#01#14#03#15+
   { Cyan window }
   #03#11#01#03#11#01#00#08#09#11#01#09#11#01#09#14#09#15#03#11#01#00#08#03#00#15#00+
   { Gray Dialog }
   #07#15#08#07#15#08#00#08#07#15#08#07#15#08#09#14#01#15#07#15#08#00#08#07#00#07#08+
   #00#15#14#07#15#08#00#09#15#08#14#01#15#00#15#07#15#08#08#07#15#00#14#08#00#08#07+
   #00#09#15#07#00#09#15#07#00#09#15;

{ Standard application commands }

  cmNew       = 30;
  cmOpen      = 31;
  cmSave      = 32;
  cmSaveAs    = 33;
  cmSaveAll   = 34;
  cmChangeDir = 35;
  cmDosShell  = 36;
  cmCloseAll  = 37;

{ Standard application help contexts }

{ Note: range $FF00 - $FFFF of help contexts are reserved by Borland }

  hcNew          = $FF01;
  hcOpen         = $FF02;
  hcSave         = $FF03;
  hcSaveAs       = $FF04;
  hcSaveAll      = $FF05;
  hcChangeDir    = $FF06;
  hcDosShell     = $FF07;
  hcExit         = $FF08;

  hcUndo         = $FF10;
  hcCut          = $FF11;
  hcCopy         = $FF12;
  hcPaste        = $FF13;
  hcClear        = $FF14;

  hcTile         = $FF20;
  hcCascade      = $FF21;
  hcCloseAll     = $FF22;
  hcResize       = $FF23;
  hcZoom         = $FF24;
  hcNext         = $FF25;
  hcPrev         = $FF26;
  hcClose        = $FF27;


type

{ GraphDeskTop object }

  PGraphDeskTop = ^GraphDeskTop;
  GraphDeskTop = object(GraphGroup)
    Background: PGraphBackground;
    TileColumnsFirst: Boolean;
    constructor Init(var Bounds: TRect);
    constructor Load(var S: TStream);
    procedure Cascade(var R: TRect);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitBackground; virtual;
    procedure Store(var S : TStream);
    procedure Tile(var R: TRect);
    procedure TileError; virtual;
    private
    DesktopMouse : PMouseCursor;
  end;

{ GraphProgram object }

  PGraphProgram = ^GraphProgram;
  GraphProgram = object(GraphGroup)
    constructor Init;
    destructor Done; virtual;
    function CanMoveFocus: Boolean;
    function ExecuteDialog(P: PGraphDialog; Data: Pointer): Word;
    procedure GetEvent(var Event: TEvent); virtual;
    function GetPalette : PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Idle; virtual;
    procedure InitDeskTop; virtual;
    procedure InitMenus;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    function InsertWindow(P: PGraphWindow): PGraphWindow;
    procedure OutOfMemory; virtual;
    procedure PutEvent(var Event: TEvent); virtual;
    procedure RefreshRect(Bounds : TRect); virtual;
    procedure Run; virtual;
    function ValidView(P: PGraphView): PGraphView;
    private
    procedure InitResource;
  end;

{ GraphApplication object }

  PGraphApplication = ^GraphApplication;
  GraphApplication = object(GraphProgram)
    constructor Init;
    destructor Done; virtual;
    procedure Cascade;
    procedure DosShell;
    procedure GetTileRect(var R: TRect); virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Tile;
    procedure WriteShellMsg; virtual;
  end;

{ Standard menus and status lines }

function StdStatusKeys(Next: PStatusItem): PStatusItem;
function StdDosMenuItems(Next : PMenuItem): PMenuItem;
function StdFileMenuItems(Next: PMenuItem): PMenuItem;
function StdEditMenuItems(Next: PMenuItem): PMenuItem;
function StdWindowMenuItems(Next: PMenuItem): PMenuItem;

{ App registration procedure }

procedure RegisterApp;

const

{ Public variables }

  Application: PGraphProgram = nil;
  DeskTop: PGraphDeskTop = nil;
  StatusLine: PGraphStatusLine = nil;
  MenuBar: PGraphMenuView = nil;

const
  RGraphDesktop: TStreamRec = (
    ObjType: 33;
    VmtLink: Ofs(TypeOf(GraphDesktop)^);
    Load: @GraphDesktop.Load;
    Store: @GraphDesktop.Store);

implementation

uses Dos;

const

{ Private variables }

  Pending: TEvent = (What: evNothing);

{ GraphDeskTop object }

constructor GraphDeskTop.Init(var Bounds: TRect);
begin
  GraphGroup.Init(Bounds);
  GrowMode := gfGrowHiX + gfGrowHiY;
  InitBackground;
  if Background <> nil then Insert(Background);
  DesktopMouse := PMouseCursor(StdSharedResource^.Get('STANDARD'));
end;

constructor GraphDesktop.Load(var S: TStream);
begin
  inherited Load(S);
  GetSubViewPtr(S, Background);
  S.Read(TileColumnsFirst, SizeOf(TileColumnsFirst));
end;


function Tileable(P: PGraphView): Boolean;
begin
  Tileable := (P^.Options and ofTileable <> 0) and
    (P^.State and sfVisible <> 0);
end;

procedure GraphDeskTop.Cascade(var R: TRect);
var
  CascadeNum: Integer;
  LastView: PGraphView;
  Min, Max: TPoint;
  Wait : PMouseCursor;


procedure DoCount(P: PGraphView); far;
begin
  if Tileable(P) then
  begin
    Inc(CascadeNum);
    LastView := P;
  end;
end;

procedure DoCascade(P: PGraphView); far;
var
  NR: TRect;
begin
  if Tileable(P) and (CascadeNum >= 0) then
  begin
    NR.Copy(R);
    Inc(NR.A.X, CascadeNum*CaptionHeight); Inc(NR.A.Y, CascadeNum*CaptionHeight);
    P^.Locate(NR);
    Dec(CascadeNum);
  end;
end;

begin
  Wait := PMouseCursor(StdSharedresource^.Get('WAIT'));
  CascadeNum := 0;
  ForEach(@DoCount);
  if CascadeNum > 0 then
  begin
    Wait^.MakeActive; inc(LockMouseCursor);
    LastView^.SizeLimits(Min, Max);
    if (Min.X > R.B.X - R.A.X - CascadeNum*CaptionHeight) or
       (Min.Y > R.B.Y - R.A.Y - CascadeNum*CaptionHeight) then
    begin
       dec(LockMouseCursor);
       Application^.ChangeMouseCursor;
       TileError;
    end else
    begin
      Dec(CascadeNum);
      Lock;
      ForEach(@DoCascade);
      Unlock;
      dec(LockMouseCursor);
      Application^.ChangeMouseCursor;
      Redraw;
    end;
  end;
end;

procedure GraphDeskTop.HandleEvent(var Event: TEvent);
begin
  GraphGroup.HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmNext: FocusNext(False);
      cmPrev:
        if Valid(cmReleasedFocus) then
           Current^.PutInFrontOf(Background);
    else
      Exit;
    end;
    ClearEvent(Event);
  end;
end;

procedure GraphDeskTop.InitBackground;
var
  R: TRect;
  Pattern : word;
begin
  GetExtent(R);
  Pattern := SolidFill;
  New(Background, Init(R,Pattern,bsNone));
end;

function ISqr(X: Integer): Integer; assembler;
asm
	MOV	CX,X
        MOV	BX,0
@@1:    INC     BX
	MOV	AX,BX
	IMUL	AX
        CMP	AX,CX
        JLE	@@1
	MOV	AX,BX
        DEC     AX
end;

procedure MostEqualDivisors(N: Integer; var X, Y: Integer; FavorY: boolean);
var
  I: Integer;
begin
  I := ISqr(N);
  if ((N mod I) <> 0) then
    if (N mod (I+1)) = 0 then Inc(I);
  if I < (N div I) then I := N div I;
  if FavorY then
  begin
    X := N div I;
    Y := I;
  end
  else
  begin
    Y := N div I;
    X := I;
  end;
end;

procedure GraphDesktop.Store(var S: TStream);
begin
  inherited Store(S);
  PutSubViewPtr(S, Background);
  S.Write(TileColumnsFirst, SizeOf(TileColumnsFirst));
end;

procedure GraphDeskTop.Tile(var R: TRect);
var
  NumCols, NumRows, NumTileable, LeftOver, TileNum: Integer;
  Wait : PMouseCursor;

procedure DoCountTileable(P: PGraphView); far;
begin
  if Tileable(P) then Inc(NumTileable);
end;

function DividerLoc(Lo, Hi, Num, Pos: Integer): Integer;
begin
  DividerLoc := LongDiv(LongMul(Hi - Lo, Pos), Num) + Lo;
end;

procedure CalcTileRect(Pos: Integer; var NR: TRect);
var
  X,Y,D: Integer;
begin
  D := (NumCols - LeftOver) * NumRows;
  if Pos < D then
  begin
    X := Pos div NumRows;
    Y := Pos mod NumRows;
  end else
  begin
    X := (Pos - D) div (NumRows + 1) + (NumCols - LeftOver);
    Y := (Pos - D) mod (NumRows + 1);
  end;
  NR.A.X := DividerLoc(R.A.X, R.B.X, NumCols, X);
  NR.B.X := DividerLoc(R.A.X, R.B.X, NumCols, X+1);
  if Pos >= D then
  begin
    NR.A.Y := DividerLoc(R.A.Y, R.B.Y, NumRows+1, Y);
    NR.B.Y := DividerLoc(R.A.Y, R.B.Y, NumRows+1, Y+1);
  end else
  begin
    NR.A.Y := DividerLoc(R.A.Y, R.B.Y, NumRows, Y);
    NR.B.Y := DividerLoc(R.A.Y, R.B.Y, NumRows, Y+1);
  end;
end;

procedure DoTile(P: PGraphView); far;
var
  R: TRect;
begin
  if Tileable(P) then
  begin
    CalcTileRect(TileNum, R);
    P^.Locate(R);
    Dec(TileNum);
  end;
end;

begin
  Wait := PMouseCursor(StdSharedresource^.Get('WAIT'));
  NumTileable := 0;
  ForEach(@DoCountTileable);
  if NumTileable > 0 then
  begin
    Wait^.MakeActive; inc(LockMouseCursor);
    MostEqualDivisors(NumTileable, NumCols, NumRows, not TileColumnsFirst);
    if ((R.B.X - R.A.X) div NumCols = 0) or
       ((R.B.Y - R.A.Y) div NumRows = 0) then
    begin
      dec(LockMouseCursor);
      Application^.ChangeMouseCursor;
      TileError;
    end else
    begin
      LeftOver := NumTileable mod NumCols;
      TileNum := NumTileable-1;
      Lock;
      ForEach(@DoTile);
      Unlock;
      dec(LockMouseCursor);
      Application^.ChangeMouseCursor;
      Redraw;
    end;
  end;
end;

procedure GraphDesktop.TileError;
begin
end;

{ TProgram }

constructor GraphProgram.Init;
var
  R: TRect;
  Name : String;
begin
  Application := @Self;
  InitResource;
  StdMouseCursor := PMouseCursor(StdSharedResource^.Get('STANDARD'));
  R.Assign(0, 0, GetMaxX+1, GetMaxY+1);
  GraphGroup.Init(R);
  State := sfVisible + sfSelected + sfFocused + sfModal + sfExposed;
  InitMenus;
  InitDeskTop;
  if MenuBar <> nil then Insert(MenuBar);
  if DeskTop <> nil then Insert(DeskTop);
  if StatusLine <> nil then Insert(StatusLine);
  Options :=  ofNoDrawSelect;
end;

destructor GraphProgram.Done;
begin
  if DeskTop <> nil then Dispose(DeskTop, Done);
  if MenuBar <> nil then Dispose(MenuBar, Done);
  if StatusLine <> nil then Dispose(StatusLine, Done);
  if StdSharedResource <> nil then Dispose(StdSharedResource,Done);
  Application := nil;
  inherited Done;
end;

function GraphProgram.CanMoveFocus: Boolean;
begin
  CanMoveFocus := Desktop^.Valid(cmReleasedFocus);
end;

function GraphProgram.ExecuteDialog(P: PGraphDialog; Data: Pointer): Word;
var
  C: Word;
begin
  ExecuteDialog := cmCancel;
  if ValidView(P) <> nil then
  begin
    if Data <> nil then P^.SetData(Data^);
    C := Desktop^.ExecView(P);
    if (C <> cmCancel) and (Data <> nil) then P^.GetData(Data^);
    Dispose(P, Done);
    ExecuteDialog := C;
  end;
end;

procedure GraphProgram.GetEvent(var Event: TEvent);
var
  R: TRect;

function ContainsMouse(P: PGraphView): Boolean; far;
begin
  ContainsMouse := (P^.State and sfVisible <> 0) and
    P^.MouseInView(Event.Where);
end;

begin
  if Pending.What <> evNothing then
  begin
    Event := Pending;
    Pending.What := evNothing;
  end else
  begin
    GetMouseEvent(Event);
    if Event.What = evNothing then
    begin
      GetKeyEvent(Event);
      if Event.What = evNothing then Idle;
    end else begin
      If Event.What = evMouseMove then
      if LockMouseCursor = 0 then ChangeMouseCursor;
    end;
  end;
  if StatusLine <> nil then
    if (Event.What and evKeyDown <> 0) or
      (Event.What and evMouseDown <> 0) and
      (FirstThat(@ContainsMouse) = PGraphView(StatusLine)) then
      StatusLine^.HandleEvent(Event);
end;

function GraphProgram.GetPalette: PPalette;
const
  P: String[Length(CColor)] = CColor;
begin
   GetPalette := @P;
end;

procedure GraphProgram.HandleEvent(var Event: TEvent);
var
  I: Word;
  C: Char;
begin
  GraphGroup.HandleEvent(Event);
  if Event.What = evCommand then
    if Event.Command = cmQuit then
    begin
      EndModal(cmQuit);
      ClearEvent(Event);
    end;
end;

procedure GraphProgram.Idle;
begin
  if StatusLine <> nil then StatusLine^.Update;
  if CommandSetChanged then
  begin
    Message(@Self, evBroadcast, cmCommandSetChanged, nil);
    CommandSetChanged := False;
  end;
end;

procedure GraphProgram.InitResource;
var
   Name : String;
begin
  RegisterObjects;
  RegisterExtObj;
  RegisterImages;
  Name := ParamStr(0);
  StdResource :=  New(PResourceFile,Init(
     New(PBufstream,Init(Name,stOpenRead,1024))));
  if StdResource^.Count = 0 then begin
     Dispose(StdResource,Done);
     StdResource :=  New(PResourceFile,Init(
        New(PBufstream,Init('Standard.rsc',stOpenRead,1024))));
   end;
   StdSharedResource := New(PSharedResource,Init(StdResource));
end;

procedure GraphProgram.InitDeskTop;
var
  R: TRect;
  R1 : TRect;
  TextStyle : TextSettingsType;
begin
  GetTextSettings(TextStyle);
  GetExtent(R);
  if MenuBar <> nil then begin
     MenuBar^.GetBounds(R1);
     R.A.Y := R1.B.Y;
  end;
  if StatusLine <> nil then begin
     StatusLine^.GetBounds(R1);
     R.B.Y := R1.A.Y;
  end;
  New(DeskTop, Init(R));
end;

procedure GraphProgram.InitMenus;
var
  i,j : integer;
begin
  j := CurrentFont;
  GFonts.SetTextStyle(SystemFont,HorizDir,1);
  i := GFonts.TextHeight(' ');
  GFonts.SetTextStyle(j,HorizDir,1);
  if i = 8 then begin
     MenuItemHeight := 16;
     StatusItemheight := 16;
  end else begin
     MenuItemheight := i+3;
     StatusItemHeight := i+4;
  end;
  LineHeight := MenuItemHeight div 2;
  InitMenuBar;
  InitStatusLine;
end;

procedure GraphProgram.InitMenuBar;
var
  i : integer;
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + MenuItemHeight;
  MenuBar := New(PGraphMenuBar, Init(R, nil));
end;

procedure GraphProgram.InitStatusLine;
var
  R: TRect;
  i : integer;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - StatusItemHeight;
  New(StatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      StdStatusKeys(nil)), nil)));
end;

function GraphProgram.InsertWindow(P: PGraphWindow): PGraphWindow;
begin
  InsertWindow := nil;
  if ValidView(P) <> nil then
    if CanMoveFocus then
    begin
      Desktop^.Insert(P);
      InsertWindow := P;
    end
    else
      Dispose(P, Done);
end;

procedure GraphProgram.OutOfMemory;
begin
end;

procedure GraphProgram.PutEvent(var Event: TEvent);
begin
  Pending := Event;
end;

procedure GraphProgram.RefreshRect(Bounds : TRect);
begin
   Inc(LockMouseCursor);
   DrawView;
   Dec(LockMouseCursor);
end;

procedure GraphProgram.Run;
begin
  Execute;
end;

function GraphProgram.ValidView(P: PGraphView): PGraphView;
begin
  ValidView := nil;
  if P <> nil then
  begin
    if LowMemory then
    begin
      Dispose(P, Done);
      OutOfMemory;
      Exit;
    end;
    if not P^.Valid(cmValid) then
    begin
      Dispose(P, Done);
      Exit;
    end;
    ValidView := P;
  end;
end;

{ TApplication }

constructor GraphApplication.Init;
begin
  InitMemory;
  LowMemSize := 1024;   {16 * 1024 / 16 }
  InitVideo;
{  DetectMouse;}
  InitFonts;
  InitEvents;
  InitSysError;
  InitHistory;
  GraphProgram.Init;
end;

destructor GraphApplication.Done;
begin
  GraphProgram.Done;
  DoneHistory;
  DoneSysError;
  DoneEvents;
  DoneFonts;
  DoneVideo;
  DoneMemory;
end;

procedure GraphApplication.Cascade;
var
  R: TRect;
begin
  GetTileRect(R);
  if Desktop <> nil then Desktop^.Cascade(R);
end;

procedure GraphApplication.DosShell;
begin
  DoneSysError;
  DoneEvents;
  RestoreCrtMode;
  DoneDosMem;
  WriteShellMsg;
  SwapVectors;
  Exec(GetEnv('COMSPEC'), '');
  SwapVectors;
  InitDosMem;
  SetGraphMode(GetGraphMode);
  InitEvents;
  InitSysError;
  Redraw;
end;

procedure GraphApplication.GetTileRect(var R: TRect);
begin
  Desktop^.GetExtent(R);
end;

procedure GraphApplication.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  case Event.What of
    evCommand:
      begin
        case Event.Command of
          cmTile: Tile;
          cmCascade: Cascade;
          cmDosShell: DosShell;
        else
          Exit;
        end;
        ClearEvent(Event);
      end;
  end;
end;

procedure GraphApplication.Tile;
var
  R: TRect;
begin
  GetTileRect(R);
  if Desktop <> nil then Desktop^.Tile(R);
end;

procedure GraphApplication.WriteShellMsg;
begin
  PrintStr('Type EXIT to return...');
end;

{ App registration procedure }

procedure RegisterApp;
begin
  RegisterType(RGraphDesktop);
end;

{ Standard menus and status lines }

function StdStatusKeys(Next: PStatusItem): PStatusItem;
begin
  StdStatusKeys :=
    NewStatusKey('', kbAltX, cmQuit,
    NewStatusKey('', kbF10, cmMenu,
    NewStatusKey('', kbAltF3, cmClose,
    NewStatusKey('', kbF5, cmZoom,
    NewStatusKey('', kbCtrlF5, cmResize,
    NewStatusKey('', kbF6, cmNext,
    NewStatusKey('', kbShiftF6, cmPrev,
    Next)))))));
end;

function StdDosMenuItems(Next : PMenuItem): PMenuItem;
begin
  StdDosMenuItems :=
    NewItem('~C~hange dir...', '', kbNoKey, cmChangeDir, hcChangeDir,
    NewItem('~D~OS shell', '', kbNoKey, cmDosShell, hcDosShell,
    NewItem('E~x~it', 'Alt+X', kbAltX, cmQuit, hcExit,
    Next)));
end;

function StdFileMenuItems(Next: PMenuItem): PMenuItem;
begin
  StdFileMenuItems :=
    NewItem('~N~ew', '', kbNoKey, cmNew, hcNew,
    NewItem('~O~pen...', 'F3', kbF3, cmOpen, hcOpen,
    NewItem('~S~ave', 'F2', kbF2, cmSave, hcSave,
    NewItem('S~a~ve as...', '', kbNoKey, cmSaveAs, hcSaveAs,
    NewItem('Save a~l~l', '', kbNoKey, cmSaveAll, hcSaveAll,
    Next)))));
end;

function StdEditMenuItems(Next: PMenuItem): PMenuItem;
begin
  StdEditMenuItems :=
    NewItem('~U~ndo', '', kbAltBack, cmUndo, hcUndo,
    NewLine(
    NewItem('Cu~t~', 'Shift+Del', kbShiftDel, cmCut, hcCut,
    NewItem('~C~opy', 'Ctrl+Ins', kbCtrlIns, cmCopy, hcCopy,
    NewItem('~P~aste', 'Shift+Ins', kbShiftIns, cmPaste, hcPaste,
    NewItem('C~l~ear', 'Ctrl+Del', kbCtrlDel, cmClear, hcClear,
    Next))))));
end;

function StdWindowMenuItems(Next: PMenuItem): PMenuItem;
begin
  StdWindowMenuItems :=
    NewItem('~T~ile', '', kbNoKey, cmTile, hcTile,
    NewItem('C~a~scade', '', kbNoKey, cmCascade, hcCascade,
    NewItem('Cl~o~se all', '', kbNoKey, cmCloseAll, hcCloseAll,
    NewLine(
    NewItem('~S~ize/Move','Ctrl+F5', kbCtrlF5, cmResize, hcResize,
    NewItem('~Z~oom', 'F5', kbF5, cmZoom, hcZoom,
    NewItem('~N~ext', 'F6', kbF6, cmNext, hcNext,
    NewItem('~P~revious', 'Shift+F6', kbShiftF6, cmPrev, hcPrev,
    NewItem('~C~lose', 'Alt+F3', kbAltF3, cmClose, hcClose,
    Next)))))))));
end;

end.
