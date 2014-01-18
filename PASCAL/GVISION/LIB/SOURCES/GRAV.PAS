{************************************************}
{   Grav.pas                                     }
{   Graph Vision unit                            }
{   Sergey E. Levov, Moscow,1992-1994            }
{   Portions copyright (c) 1990 by Borland Int.  }
{   Last updates 7 August 1995                   }
{************************************************}

Unit GraV;

{$F+,O+,S+,X+,D+}

interface

uses Crt,Graph,Objects,ExtObj,EventMan,Memory,Images;

const
{  GraphView State masks}

  sfVisible     = $0001;
  sfCursorVis   = $0002;
  sfCursorIns   = $0004;
  sfActive      = $0010;
  sfSelected    = $0020;
  sfFocused     = $0040;
  sfDragging    = $0080;
  sfDisabled    = $0100;
  sfModal       = $0200;
  sfDefault     = $0400;
  sfExposed     = $0800;
  sfIconised    = $1000;

{ GraphView Option masks }

  ofSelectable  = $0001;
  ofTopSelect   = $0002;
  ofFirstClick  = $0004;
  ofValidate    = $0008;
  ofPreProcess  = $0010;
  ofPostProcess = $0020;
  ofNoDrawSelect= $0040;
  ofTileable    = $0080;
  ofCenterX     = $0100;
  ofCenterY     = $0200;
  ofCentered    = $0300;
  ofResizeable  = $0400;
  ofMoveable    = $0800;
  ofVersion     = $3000;
  ofVersion10   = $0000;
  ofVersion20   = $1000;

{ GraphView GrowMode masks }

  gfGrowLoX = $01;
  gfGrowLoY = $02;
  gfGrowHiX = $04;
  gfGrowHiY = $08;
  gfGrowAll = $0F;
  gfGrowRel = $10;

{ GraphView DragMode masks }

  dmDragMove = $01;
  dmDragGrow = $02;
  dmLimitLoX = $10;
  dmLimitLoY = $20;
  dmLimitHiX = $40;
  dmLimitHiY = $80;
  dmLimitAll = $F0;

{ GraphView Help context codes }

  hcNoContext = 0;
  hcDragging  = 1;

{ GraphScrollBar options for GraphWindow.StandardScrollBar }

  sbHorizontal     = $0000;
  sbVertical       = $0001;
  sbHandleKeyboard = $0002;


{ GraphWindow Flags masks }

  wfMove       = $01;
  wfGrow       = $02;
  wfClose      = $04;
  wfZoom       = $08;
  wfThickFrame = $10;
  wfThinFrame  = $20;
  wfFramed     = $30;
  wfTitle      = $40;

{ GraphWindow palette entries }

  wpBlueWindow = 0;
  wpCyanWindow = 1;
  wpGrayWindow = 2;


{ Standard command codes }

  cmValid   = 0;
  cmQuit    = 1;
  cmError   = 2;
  cmMenu    = 3;
  cmClose   = 4;
  cmZoom    = 5;
  cmResize  = 6;
  cmNext    = 7;
  cmPrev    = 8;
  cmHelp    = 9;

{ Application command codes }

  cmCut     = 20;
  cmCopy    = 21;
  cmPaste   = 22;
  cmUndo    = 23;
  cmClear   = 24;
  cmTile    = 25;
  cmCascade = 26;

{ GraphDialog standard commands }

  cmOK      = 10;
  cmCancel  = 11;
  cmYes     = 12;
  cmNo      = 13;
  cmDefault = 14;

{ Standard messages }

  cmReceivedFocus     = 50;
  cmReleasedFocus     = 51;
  cmCommandSetChanged = 52;

{ GraphScrollBar messages }

  cmScrollBarChanged  = 53;
  cmScrollBarClicked  = 54;

{ GraphListViewer message }

  cmListItemSelected = 56;

{ Border style for GraphBackground }

  bsNone       = 0;
  bsUpper      = 1;
  bsLower      = 2;
  bsBump       = 1;
  bsDip        = 2;
{ Palettes }

  CBackground = #01#02#03;
  CFrame = #09#10#11#12#13#14;

  CTitleBar = #15#16#17#18;
  CCloseButton = #04#05#06#07#08;
  CZoomButton = #04#05#06#07#08;

  CScrollBar = #19#20#21#22#23;
  CIndicator = #01#02#03;
  CArrow = #04#05;
  CFoot = #01#02#03;

  CScroller = #24#25#26#27;
  CListViewer =#62#63#64#65;

  CGrayWindow = #13#14#15#16#17#18#19#20#21#22#23#24#25 +
                #26#27#28#29#30#31#32#33#34#35#36#37#38#39;
  CBlueWindow = #40#41#42#43#44#45#46#47#48#49#50#51#52 +
                #53#54#55#56#57#58#59#60#61#62#63#64#65#66;
  CCyanWindow = #67#68#69#70#71#72#73#74#75#76#77#78#79 +
                #80#81#82#83#84#85#86#87#88#89#90#91#92#93;
type

   TTitleStr = string[80];

{ Command sets }

  PCommandSet = ^TCommandSet;
  TCommandSet = set of Byte;

{ Color palette type }

  PPalette = ^TPalette;
  TPalette = String;

   PGraphView = ^GraphView;
   PGraphGroup = ^GraphGroup;

   GraphView = object(TObject)
      Owner     : PGraphGroup;
      Next      : PGraphView;
      Origin    : TPoint;
      Size      : TPoint;
      Cursor    : TPoint;
      GrowMode  : byte;
      DragMode  : byte;
      HelpCtx   : word;
      Options   : word;
      State     : word;
      EventMask : word;
      constructor Init(var Bounds : TRect);
      constructor Load(var S: TStream);
      destructor Done; virtual;
      procedure BlockCursor;
      procedure CalcBounds(var Bounds: TRect; Delta: TPoint); virtual;
      procedure ChangeBounds(var Bounds: TRect); virtual;
      procedure ChangeClipRect; virtual;
      procedure ChangeMouseCursor; virtual;
      procedure ResetClipRect; virtual;
      procedure ClearEvent(var Event: TEvent);
      function CommandEnabled(Command: Word): Boolean;
      function DataSize: Word; virtual;
      procedure DisableCommands(Commands: TCommandSet);
      procedure DragView(Event: TEvent; Mode: Byte; var Limits: TRect;
                    MinSize, MaxSize: TPoint; RealMove : boolean); virtual;
      procedure Draw; virtual;
      procedure DrawCursor; virtual;
      procedure DrawView;
      procedure EnableCommands(Commands: TCommandSet);
      procedure EndModal(Command: Word); virtual;
      function EventAvail: Boolean;
      function Execute: Word; virtual;
      function Exposed : boolean;
      function Focus : boolean;
      procedure GetBounds(var Bounds : TRect);
      procedure GetClipRect(var Rect : TRect); virtual;
      function GetColor(Color: Word): Word;
      procedure GetCommands(var Commands: TCommandSet);
      procedure GetData(var Rec); virtual;
      procedure GetEvent(var Event: TEvent); virtual;
      procedure GetExtent(var Extent : TRect);
      function GetHelpCtx: Word; virtual;
      function GetPalette: PPalette; virtual;
      procedure GetPeerViewPtr(var S: TStream; var P);
      function GetState(AState : word) : boolean;
      procedure GrowTo(X, Y: Integer);
      procedure HandleEvent(var Event: TEvent); virtual;
      procedure Hide;
      procedure HideCursor;
      procedure HideView; virtual;
      procedure KeyEvent(var Event: TEvent);
      procedure Locate(var Bounds: TRect);
      procedure MakeFirst;
      procedure MakeGlobal(Source: TPoint; var Dest: TPoint);
      procedure MakeLocal(Source: TPoint; var Dest: TPoint);
      function MouseEvent(var Event: TEvent; Mask: Word): Boolean;
      function MouseInView(Mouse: TPoint): Boolean; virtual;
      procedure MoveTo(X, Y: Integer);
      function NextView: PGraphView;
      procedure NormalCursor;
      function Prev: PGraphView;
      function PrevView: PGraphView;
      procedure PutEvent(var Event: TEvent); virtual;
      procedure PutInFrontOf(Target: PGraphView);
      procedure PutPeerViewPtr(var S: TStream; P: PGraphView);
      procedure RefreshRect(Bounds : TRect); virtual;
      procedure Select;
      procedure SetBounds(var Bounds : TRect);
      procedure SetCommands(Commands: TCommandSet);
      procedure SetCursor(X, Y: Integer);
      procedure SetData(var Rec); virtual;
      procedure SetDrawPort(Bounds : TRect);
      procedure SetState(AState : word; Enable : boolean); virtual;
      procedure Show;
      procedure ShowCursor;
      procedure SizeLimits(var Min, Max: TPoint); virtual;
      procedure Store(var S: TStream);
      function TopView: PGraphView;
      function Valid(Command: Word): Boolean; virtual;
      {basic drawing metods}
      procedure Arc(Center : TPoint; StAngle, EndAngle, Radius: Word);
      procedure Bar(Bounds : TRect);
      procedure BicolorRectangle(Bounds : TRect; Light,Dark : word; Down : boolean);
      procedure Circle(Center : TPoint; Radius : word);
      procedure DrawImg(Location : TPoint; Image : PImage; BitBlt : word);
      procedure DrawPoly(Number:Word; var PolyArray {An array of Tpoint} );
      procedure EllipticArc(Center : TPoint; StAngle,EndAngle,
                                XRadius,YRadius : word);
      procedure Ellipse(Center : TPoint; XRadius,YRadius : word);
      procedure FillEllipse(Center : TPoint; XRadius,YRadius : word);
      procedure FillPoly(Number:Word; var PolyArray {An array of Tpoint} );
      procedure Line(Bounds : TRect);
      procedure LineTo(Point : TPoint);
      procedure WriteText(S : String);
      procedure WriteTextXY(Point : TPoint; S : string);
      procedure WriteCTextXY(Point : TPoint; S : string; TextColor,AccelColor : word);
      procedure PieSlice(Center : TPoint; StAngle, EndAngle, Radius: Word);
      procedure PutBitmap(Location : TPoint; var BitMap; BitBlt : word);
      procedure PutPixel(Location : TPoint; Color : word);
      procedure Rectangle(Bounds : TRect);
      procedure MoveRect(Bounds : TRect; DeltaX,DeltaY : integer);
   private
      procedure ReDrawRect(var R : TRect; Top : PGraphView);
   end;

{ GraphBackground object }

  PGraphBackground = ^GraphBackground;
  GraphBackground = object(GraphView)
    BorderStyle : integer;
    Pattern:  word;
    constructor Init(var Bounds: TRect; APattern: word; ABorderStyle : integer);
    constructor Load(var S : TStream);
    procedure Draw; virtual;
    function GetPalette : PPalette; virtual;
    procedure Store(var S : TStream);
  end;

{ Selection modes }

  SelectMode = (NormalSelect, EnterSelect, LeaveSelect);

{ GraphGroup object }

  GraphGroup = object(GraphView)
    Last: PGraphView;
    Current: PGraphView;
    Phase: (phFocused, phPreProcess, phPostProcess);
    Clip: TRect;
    constructor Init(var Bounds: TRect);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure ChangeBounds(var Bounds: TRect); virtual;
    procedure ChangeClipRect; virtual;
    procedure ChangeMouseCursor; virtual;
    function DataSize: Word; virtual;
    procedure Delete(P: PGraphView);
    procedure DrawCursor; virtual;
    procedure Draw; virtual;
    procedure EndModal(Command: Word); virtual;
    procedure EventError(var Event: TEvent); virtual;
    function ExecView(P: PGraphView): Word;
    function Execute: Word; virtual;
    function First: PGraphView;
    function FirstThat(P: Pointer): PGraphView;
    function FocusNext(Forwards : boolean) : boolean;
    procedure ForEach(P: Pointer);
    procedure GetClipRect(var Rect : TRect); virtual;
    procedure GetData(var Rec); virtual;
    function GetHelpCtx: Word; virtual;
    procedure GetSubViewPtr(var S: TStream; var P);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Insert(P: PGraphView); virtual;
    procedure InsertBefore(P, Target: PGraphView);
    procedure Lock;
    procedure PutSubViewPtr(var S: TStream; P: PGraphView);
    procedure Redraw;
    procedure ResetClipRect; virtual;
    procedure SelectNext(Forwards: Boolean);
    procedure SetData(var Rec); virtual;
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure Store(var S: TStream);
    procedure Unlock;
    function Valid(Command: Word): Boolean; virtual;
  private
    EndState: Word;
    function At(Index: Integer): PGraphView;
    procedure DrawSubViews(P, Top: PGraphView);
    function FindNext(Forwards: Boolean): PGraphView;
    function FirstMatch(AState: Word; AOptions: Word): PGraphView;
    function IndexOf(P: PGraphView): Integer;
    procedure InsertView(P, Target: PGraphView);
    procedure RemoveView(P: PGraphView);
    procedure ResetCurrent;
    procedure SetCurrent(P: PGraphView; Mode: SelectMode);
    procedure PrepClipRect;
  end;

 { GraphScrollBar object }

  PGraphScrollBar = ^GraphScrollBar;
  GraphScrollBar = object(GraphGroup)
    Value: Integer;
    Min: Integer;
    Max: Integer;
    PgStep: Integer;
    ArStep: Integer;
    constructor Init(var Bounds: TRect);
    constructor Load(var S : TStream);
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure ScrollDraw; virtual;
    procedure SetParams(AValue, AMin, AMax, APgStep, AArStep: Integer);
    procedure SetRange(AMin, AMax: Integer);
    procedure SetState(AState : word; Enable : boolean); virtual;
    procedure SetStep(APgStep, AArStep: Integer);
    procedure SetValue(AValue: Integer);
    procedure Store(var S : TStream);
  private
    Vertical : boolean;
    function GetPos: Integer;
    function GetSize: Integer;
    procedure GetActiveRect(var Bounds : TRect);
  end;

{ GraphListViewer }

  PGraphListViewer = ^GraphListViewer;
  GraphListViewer = object(GraphView)
    HScrollBar: PGraphScrollBar;
    VScrollBar: PGraphScrollBar;
    NumCols: Integer;
    TopItem: Integer;
    Focused: Integer;
    Range: Integer;
    constructor Init(var Bounds: TRect; ANumCols: Word; AHScrollBar,
       AVScrollBar: PGraphScrollBar);
    constructor Load(var S : TStream);
    procedure ChangeBounds(var Bounds: TRect); virtual;
    procedure Draw; virtual;
    procedure DrawItem(Item : integer); virtual;
    procedure DrawItems;
    procedure FocusItem(Item: Integer); virtual;
    function GetItem(Item: Integer): pointer; virtual;
    procedure GetItemRect(Item : integer; var Bounds : TRect);
    procedure GetItemSize(var ItemSize : TPoint); virtual;
    function GetPalette : Ppalette; virtual;
    function IsSelected(Item: Integer): Boolean; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SelectItem(Item: Integer); virtual;
    procedure SetRange(ARange: Integer);
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure Store(var S : TStream);
  private
    procedure FocusItemNum(Item: Integer); virtual;
    procedure RedrawItem(Item : integer);
  end;

{ GraphWindow}

  PGraphWindow = ^GraphWindow;
  GraphWindow = object(GraphGroup)
    Flags: Byte;
    ZoomRect: TRect;
    Palette : Integer;
    Frame: PGraphView;
    WorkSpace : PGraphView;
    Caption : PGraphView;
    Title : PString;
    constructor Init(var Bounds: TRect; ATitle : TTitleStr; AFlags : word);
    destructor Done; virtual;
    constructor Load(var S : TStream);
    procedure Close; virtual;
    function GetPalette : PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Insert(P: PGraphView); virtual;
    function GetTitle(MaxSize : integer) : TTitleStr; virtual;
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure SizeLimits(var Min, Max: TPoint); virtual;
    function  StandardScrollBar(AOptions: Word): PGraphScrollBar;
    procedure Store(var S : TStream);
    procedure Zoom; virtual;
    private
    procedure InitWorkspace;
    procedure InitCaption;
    procedure InitFrame;
  end;

{ GraphScroller object }

  PGraphScroller = ^GraphScroller;
  GraphScroller = object(GraphView)
    HScrollBar: PGraphScrollBar;
    VScrollBar: PGraphScrollBar;
    Delta: TPoint;
    Limit: TPoint;
    Step : TPoint;
    DrawFlag: Boolean;
    constructor Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PGraphScrollBar);
    constructor Load(var S: TStream);
    procedure ChangeBounds(var Bounds: TRect); virtual;
    procedure GetDelta(var ADelta : TPoint); virtual;
    function GetPalette : PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure ScrollDraw; virtual;
    procedure ScrollTo(X, Y: Integer);
    procedure SetLimit(X, Y: Integer);
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure Store(var S: TStream);
  private
    DrawLock: Byte;
    procedure CheckDraw;
  end;


const
    CommandSetChanged: Boolean = False;

    MouseOwner : PGraphView = nil;
    StdMouseCursor : PMouseCursor = nil;
    LockMouseCursor : word = 0;
{ Minimum window size }

  MinWinSize: TPoint = (X: 124; Y: 84);

  CaptionHeight : integer = 14;


{ GraphViews registration procedure }

procedure RegisterGraphViews;

{ Message dispatch function }

function Message(Receiver: PGraphView; What, Command: Word;
  InfoPtr: Pointer): Pointer;

const

{ Event masks }
    PositionalEvents: Word = evMouse;
    FocusedEvents: Word = evKeyboard + evCommand;

{ Stream Registration Records }

  RGraphView: TStreamRec = (
     ObjType: 1;
     VmtLink: Ofs(TypeOf(GraphView)^);
     Load:    @GraphView.Load;
     Store:   @GraphView.Store
  );
  RGraphBackground: TStreamRec = (
    ObjType: 2;
    VmtLink: Ofs(TypeOf(GraphBackground)^);
    Load: @GraphBackground.Load;
    Store: @GraphBackground.Store
  );

  RGraphGroup: TStreamRec = (
     ObjType: 3;
     VmtLink: Ofs(TypeOf(GraphGroup)^);
     Load:    @GraphGroup.Load;
     Store:   @GraphGroup.Store
  );

  RGraphListViewer: TStreamRec = (
    ObjType: 4;
    VmtLink: Ofs(TypeOf(GraphListViewer)^);
    Load:    @GraphListViewer.Load;
    Store:   @GraphListViewer.Store
  );

  RGraphScrollBar: TStreamRec = (
     ObjType: 5;
     VmtLink: Ofs(TypeOf(GraphScrollBar)^);
     Load:    @GraphScrollBar.Load;
     Store:   @GraphScrollBar.Store
  );

{ GraphWindow registration record }

  RGraphWindow: TStreamRec = (
     ObjType: 9;
     VmtLink: Ofs(TypeOf(GraphWindow)^);
     Load:    @GraphWindow.Load;
     Store:   @GraphWindow.Store
  );

  RGraphScroller: TStreamRec = (
     ObjType: 15;
     VmtLink: Ofs(TypeOf(GraphScroller)^);
     Load:    @GraphScroller.Load;
     Store:   @GraphScroller.Store
  );

implementation
uses Controls,GrDriver,GFonts,LowGraph;

type
  PFixupList = ^TFixupList;
  TFixupList = array[1..4096] of Pointer;

const
  OwnerGroup: PGraphGroup = nil;
  FixupList: PFixupList = nil;
  TheTopView: PGraphView = nil;
  LockFlag : byte = 0;

{ Current command set. All but window commands are active by default }

  CurCommandSet: TCommandSet =
    [0..255] - [cmZoom, cmClose, cmResize, cmNext, cmPrev];

{$IFNDEF VER70}
   VMTHeaderSize = $04;
{$ELSE}
   VMTHeaderSize = $08;
{$ENDIF}

{ Convert color into attribute                          }
{ In    AL = Color                                      }
{ Out   AL = Attribute                                  }

procedure MapColor; near; assembler;
const
  Self = 6;
  GetPalette_Call = $40;      {.   $3C;}
  GraphView_GetPalette = GetPalette_Call + VMTHeaderSize;

asm
        OR      AL,AL
        JE      @@3
        LES     DI,[BP].Self
@@1:    PUSH    ES
        PUSH    DI
        PUSH    AX
        PUSH    ES
        PUSH    DI
        MOV     DI,ES:[DI]
        CALL    DWORD PTR [DI].GraphView_GetPalette
        MOV     BX,AX
        MOV     ES,DX
        OR      AX,DX
        POP     AX
        POP     DI
        POP     DX
        JE      @@2
        CMP     AL,ES:[BX]
        JA      @@3
        SEGES   XLAT
        OR      AL,AL
        JE      @@3
@@2:    MOV     ES,DX
        LES     DI,ES:[DI].GraphView.Owner
        MOV     SI,ES
        OR      SI,DI
        JNE     @@1
        JMP     @@4
@@3:    XOR     AX,AX
@@4:
end;

{ Message dispatch function }

function Message(Receiver: PGraphView; What, Command: Word;
  InfoPtr: Pointer): Pointer;
var
  Event: TEvent;
begin
  Message := nil;
  if Receiver <> nil then
  begin
    Event.What := What;
    Event.Command := Command;
    Event.InfoPtr := InfoPtr;
    Receiver^.HandleEvent(Event);
    if Event.What = evNothing then Message := Event.InfoPtr;
  end;
end;

{ GraphView methods }

constructor GraphView.Init(var Bounds : TRect);
begin
   TObject.Init;
   if GraphResult <> grOK then Fail;
   Owner := nil;
   SetBounds(Bounds);
   DragMode := dmLimitLoY;
   State := sfVisible;
   EventMask := evMouseDown + evKeyDown + evCommand;
end;

constructor GraphView.Load(var S: TStream);
begin
  TObject.Init;
  S.Read(Origin,
    SizeOf(TPoint) * 3 +
    SizeOf(Byte) * 2 +
    SizeOf(Word) * 4);
end;

destructor GraphView.Done;
begin
   Hide;
   if Owner <> nil then Owner^.Delete(@Self);
end;

procedure GraphView.BlockCursor;
begin
  SetState(sfCursorIns, True);
end;

procedure GraphView.CalcBounds(var Bounds: TRect; Delta: TPoint);
var
  S, D: Integer;
  Min,Max : TPoint;

procedure Grow(var I: Integer);
begin
  if (GrowMode and gfGrowRel) = 0 then Inc(I, D) else
    I := (longInt(I) * S + (S - D) shr 1) div (S - D);
end;

function Range(Val, Min, Max: Integer): Integer;
begin
  if Val < Min then Range := Min else
    if Val > Max then Range := Max else
      Range := Val;
end;

begin
  GetBounds(Bounds);
  S := Owner^.Size.X;
  D := Delta.X;
  if GrowMode and gfGrowLoX <> 0 then Grow(Bounds.A.X);
  if GrowMode and gfGrowHiX <> 0 then Grow(Bounds.B.X);
  if (Bounds.B.X - Bounds.A.X) > (GetMaxX + 1) then
    Bounds.B.X := Bounds.A.X + (GetMaxX + 1);
  S := Owner^.Size.Y;
  D := Delta.Y;
  if GrowMode and gfGrowLoY <> 0 then Grow(Bounds.A.Y);
  if GrowMode and gfGrowHiY <> 0 then Grow(Bounds.B.Y);
  SizeLimits(Min,Max);
  Bounds.B.X := Bounds.A.X + Range(Bounds.B.X - Bounds.A.X, Min.X, Max.X);
  Bounds.B.Y := Bounds.A.Y + Range(Bounds.B.Y - Bounds.A.Y, Min.Y, Max.Y);
end;

procedure GraphView.ChangeBounds(var Bounds: TRect);
var
  R : TRect;
  R1 : TRect;
  V : PGraphView;
begin
{  HideView;}
  GetBounds(R1);
  SetBounds(Bounds);
  GetExtent(R);
  if State and sfActive <> 0 then DrawView
  else RefreshRect(R);
  if Owner <> nil then begin
     V := Owner^.Last;
     while V <> @Self do begin
        V^.GetBounds(R);
        R.Intersect(R1);
        if not R.Empty then with V^ do begin
           R.Move(-Origin.X,-Origin.Y);
           RefreshRect(R);
        end;
        V := V^.Prev;
     end;
  end;
end;

procedure GraphView.ChangeMouseCursor;
begin
   if MouseOwner <> @Self then begin
      if StdMouseCursor <> nil then StdMouseCursor^.MakeActive;
      MouseOwner := @Self;
   end;
end;

procedure GraphView.ClearEvent(var Event: TEvent);
begin
  Event.What := evNothing;
  Event.InfoPtr := @Self;
end;

function GraphView.CommandEnabled(Command: Word): Boolean;
begin
  CommandEnabled := (Command > 255) or (Command in CurCommandSet);
end;

function GraphView.DataSize: Word;
begin
  DataSize := 0;
end;

procedure GraphView.DisableCommands(Commands: TCommandSet);
begin
  CommandSetChanged := CommandSetChanged or (CurCommandSet * Commands <> []);
  CurCommandSet := CurCommandSet - Commands;
end;

procedure GraphView.DragView(Event: TEvent; Mode: Byte;
  var Limits: TRect; MinSize, MaxSize: TPoint; RealMove : boolean);
var
  P, S, B: TPoint;
  SaveBounds: TRect;
  CurBounds : TRect;
  TestBounds : TRect;
  OldColor : word;
  OldLineSettings : LineSettingsType;
  VP : ViewPortType;

function Min(I, J: Integer): Integer;
begin
  if I < J then Min := I else Min := J;
end;

function Max(I, J: Integer): Integer;
begin
  if I > J then Max := I else Max := J;
end;

procedure DrawRect(Rect : TRect);
var
   R : TRect;
   M : boolean;
begin
   HideMouse;
   GrDriver.SetWriteMode(XorPut);
   SetColor(LightGray);
   SetLineStyle(SolidLn,0,NormWidth);
   Owner^.Rectangle(Rect);
   ShowMouse;
end;

procedure MoveGrow(P, S: TPoint);
begin
  if not RealMove then DrawRect(CurBounds);
  S.X := Min(Max(S.X, MinSize.X), MaxSize.X);
  S.Y := Min(Max(S.Y, MinSize.Y), MaxSize.Y);
  P.X := Min(Max(P.X, Limits.A.X - S.X + 1), Limits.B.X - 1);
  P.Y := Min(Max(P.Y, Limits.A.Y - S.Y + 1), Limits.B.Y - 1);
  if Mode and dmLimitLoX <> 0 then P.X := Max(P.X, Limits.A.X);
  if Mode and dmLimitLoY <> 0 then P.Y := Max(P.Y, Limits.A.Y);
  if Mode and dmLimitHiX <> 0 then P.X := Min(P.X, Limits.B.X - S.X);
  if Mode and dmLimitHiY <> 0 then P.Y := Min(P.Y, Limits.B.Y - S.Y);
  CurBounds.Assign(P.X, P.Y, P.X + S.X, P.Y + S.Y);
  if not RealMove then DrawRect(CurBounds)
  else Locate(CurBounds);
end;

procedure Change(DX, DY: Integer);
begin
  if (Mode and dmDragMove <> 0) and (GetShiftState and $03 = 0) then
  begin
    Inc(P.X, DX);
    Inc(P.Y, DY);
  end else
  if (Mode and dmDragGrow <> 0) and (GetShiftState and $03 <> 0) then
  begin
    Inc(S.X, DX);
    Inc(S.Y, DY);
  end;
end;

begin
  SetState(sfDragging, True);
  if not RealMove then begin
     OldColor := Graph.GetColor;
     GetLineSettings(OldLineSettings);
  end;
  GetViewSettings(VP);
  Owner^.GetClipRect(SaveBounds);
  Owner^.SetDrawPort(SaveBounds);
  GetBounds(SaveBounds);
  CurBounds := SaveBounds;
  if not RealMove then DrawRect(CurBounds);
  if Event.What = evMouseDown then
  begin
    if not RealMove then inc(LockMouseCursor);
    if Mode and dmDragMove <> 0 then
    begin
      P.X := Origin.X - Event.Where.X;
      P.Y := Origin.Y - Event.Where.Y;
      repeat
        Inc(Event.Where.X, P.X);
        Inc(Event.Where.Y, P.Y);
        MoveGrow(Event.Where, Size);
      until not MouseEvent(Event, evMouseMove);
    end else
    begin
      P.X := Size.X - Event.Where.X;
      P.Y := Size.Y - Event.Where.Y;
      repeat
        Inc(Event.Where.X, P.X);
        Inc(Event.Where.Y, P.Y);
        MoveGrow(Origin, Event.Where);
      until not MouseEvent(Event, evMouseMove);
    end;
    if not RealMove then dec(LockMouseCursor);
  end else
  begin
    P := Origin;
    S := Size;
    repeat
      KeyEvent(Event);
      case Event.KeyCode and $FF00 of
        kbLeft: Change(-1, 0);
        kbRight: Change(1, 0);
        kbUp: Change(0, -1);
        kbDown: Change(0, 1);
        kbCtrlLeft: Change(-8, 0);
        kbCtrlRight: Change(8, 0);
        kbHome: P.X := Limits.A.X;
        kbEnd: P.X := Limits.B.X - S.X;
        kbPgUp: P.Y := Limits.A.Y;
        kbPgDn: P.Y := Limits.B.Y - S.Y;
      end;
      MoveGrow(P, S);
    until (Event.KeyCode = kbEnter) or (Event.KeyCode = kbEsc);
    if Event.KeyCode = kbEsc then begin
       if not RealMove then DrawRect(CurBounds);
       CurBounds := SaveBounds;
       if not RealMove then DrawRect(CurBounds)
       else Locate(CurBounds);
    end;
  end;
  if not RealMove then begin
     DrawRect(CurBounds);
     GrDriver.SetWriteMode(NormalPut);
     SetColor(OldColor);
     with OldLineSettings do SetLineStyle(LineStyle,Pattern,Thickness);
     Locate(CurBounds);
  end;
  SetState(sfDragging, False);
end;

procedure GraphView.Draw;
begin
end;

procedure GraphView.DrawCursor;
var
  K,I : integer;
  L,R : TRect;
begin
  if Exposed then begin
     if LockFlag <> 0 then Exit;
     GetClipRect(R);
     SetDrawPort(R);
     L.A := Cursor;
     L.B.X := L.A.X +1;
     L.B.Y := L.A.Y + GFonts.TextHeight(' ');
     if State and sfCursorIns <> 0 then K := 7 else K := 1;
     GrDriver.SetWriteMode(XORPut);
     SetLineStyle(SolidLn,0,NormWidth);
     SetColor(White);
     for i := 0 to K do begin
        Line(L);
        L.Move(1,0);
     end;
     GrDriver.SetWriteMode(NormalPut);
  end;
end;


procedure GraphView.DrawView;
var
   R : TRect;
   VP : ViewPortType;
   Hm : boolean;
begin
   if Exposed then begin
      if LockFlag <> 0 then Exit;
      GetViewSettings(VP);
      GetClipRect(R);
      SetDrawPort(R);
      MakeGlobal(R.A,R.A);
      MakeGlobal(R.B,R.B);
      if LockMouseCursor = 0 then begin
         if MouseInRect(R) then HideMouse;
         SetExclusiveArea(R);
      end;
      inc(LockMouseCursor);
      Draw;
      dec(LockMouseCursor);
      with VP do SetViewPort(X1,Y1,X2,Y2,Clip);
      if (LockMouseCursor = 0) then ShowMouse;
      if (Owner <> nil) and (LockMouseCursor= 0) then Owner^.ChangeMouseCursor;
   end;
end;

procedure GraphView.ReDrawRect(var R : TRect; Top : PGraphView);
var
   OldClip : TRect;
   OldState : word;
begin
   if Owner = nil then Exit;
   with Owner^ do begin
      Clip.Intersect(R);
      ChangeClipRect;
      DrawSubViews(Last,Top);
      ResetClipRect;
   end;
end;

procedure GraphView.EnableCommands(Commands: TCommandSet);
begin
  CommandSetChanged := CommandSetChanged or
    (CurCommandSet * Commands <> Commands);
  CurCommandSet := CurCommandSet + Commands;
end;

procedure GraphView.EndModal(Command: Word);
var
  P: PGraphView;
begin
  P := TopView;
  if TopView <> nil then TopView^.EndModal(Command);
end;

function GraphView.EventAvail: Boolean;
var
  Event: TEvent;
begin
  GetEvent(Event);
  if Event.What <> evNothing then PutEvent(Event);
  EventAvail := Event.What <> evNothing;
end;

function GraphView.Execute: Word;
begin
  Execute := cmCancel;
end;

function GraphView.Exposed: Boolean; assembler;
var
  Target: Pointer;
asm
        LES     DI,Self
        TEST    ES:[DI].GraphView.State,sfExposed
	JE	@@2
	XOR	AX,AX
	CMP	AX,ES:[DI].GraphView.Size.X
	JGE	@@2
	CMP	AX,ES:[DI].GraphView.Size.Y
	JGE	@@2
@@1:	XOR	BX,BX
	MOV	CX,ES:[DI].GraphView.Size.X
	PUSH	AX
	CALL	@@11
	POP	AX
	JNC	@@3
	LES	DI,Self
	INC	AX
	CMP	AX,ES:[DI].GraphView.Size.Y
	JL	@@1
@@2:	MOV	AL,0
	JMP	@@30
@@3:	MOV	AL,1
	JMP	@@30
@@8:	STC
@@9:	RETN
@@10:	LES	DI,ES:[DI].GraphView.Owner
@@11:	MOV	Target.Word[0],DI
	MOV	Target.Word[2],ES
	ADD	AX,ES:[DI].GraphView.Origin.Y
	MOV	SI,ES:[DI].GraphView.Origin.X
	ADD	BX,SI
	ADD	CX,SI
	LES	DI,ES:[DI].GraphView.Owner
	MOV	SI,ES
	OR	SI,DI
	JE	@@9
        CMP     AX,ES:[DI].GraphGroup.Clip.A.Y
        JL      @@8
        CMP     AX,ES:[DI].GraphGroup.Clip.B.Y
        JGE     @@8
        CMP     BX,ES:[DI].GraphGroup.Clip.A.X
        JGE     @@12
        MOV     BX,ES:[DI].GraphGroup.Clip.A.X
@@12:   CMP     CX,ES:[DI].GraphGroup.Clip.B.X
        JLE     @@13
        MOV     CX,ES:[DI].GraphGroup.Clip.B.X
@@13:   CMP     BX,CX
        JGE     @@8
        LES     DI,ES:[DI].GraphGroup.Last
@@20:   LES     DI,ES:[DI].GraphView.Next
        CMP     DI,Target.Word[0]
        JNE     @@21
        MOV     SI,ES
        CMP     SI,Target.Word[2]
        JE	@@10
@@21:   TEST    ES:[DI].GraphView.State,sfVisible
        JE      @@20
        MOV     SI,ES:[DI].GraphView.Origin.Y
        CMP     AX,SI
        JL      @@20
        ADD     SI,ES:[DI].GraphView.Size.Y
        CMP     AX,SI
        JGE     @@20
        MOV     SI,ES:[DI].GraphView.Origin.X
        CMP     BX,SI
        JL      @@22
        ADD     SI,ES:[DI].GraphView.Size.X
        CMP     BX,SI
        JGE     @@20
        MOV     BX,SI
        CMP     BX,CX
        JL      @@20
	STC
	RETN
@@22:   CMP     CX,SI
        JLE     @@20
        ADD     SI,ES:[DI].GraphView.Size.X
        CMP     CX,SI
        JG      @@23
        MOV     CX,ES:[DI].GraphView.Origin.X
        JMP     @@20
@@23:	PUSH	Target.Word[2]
	PUSH	Target.Word[0]
	PUSH    ES
        PUSH    DI
        PUSH    SI
        PUSH    CX
	PUSH	AX
        MOV     CX,ES:[DI].GraphView.Origin.X
        CALL    @@20
	POP	AX
        POP     CX
        POP     BX
        POP     DI
        POP     ES
	POP	Target.Word[0]
	POP	Target.Word[2]
        JC      @@20
	RETN
@@30:
end;

function GraphView.Focus: Boolean;
var
  Result: Boolean;
begin
  Result := True;
  if State and (sfSelected + sfModal) = 0 then
  begin
    if Owner <> nil then
    begin
      Result := Owner^.Focus;
      if Result then
        if ((Owner^.Current = nil) or
          (Owner^.Current^.Options and ofValidate = 0) or
          (Owner^.Current^.Valid(cmReleasedFocus))) then
          Select
        else
          Result := False;
    end;
  end;
  Focus := Result;
end;

procedure GraphView.GetBounds(var Bounds: TRect); assembler;
asm
        PUSH    DS
        LDS     SI,Self
        ADD     SI,OFFSET GraphView.Origin
        LES     DI,Bounds
        CLD
        LODSW                           {Origin.X}
        MOV     CX,AX
        STOSW
        LODSW                           {Origin.Y}
        MOV     DX,AX
        STOSW
        LODSW                           {Size.X}
        ADD     AX,CX
        STOSW
        LODSW                           {Size.Y}
        ADD     AX,DX
        STOSW
        POP     DS
end;

procedure GraphView.GetClipRect(var Rect: TRect);
var
   R : TRect;
begin
  GetBounds(Rect);
  if Owner <> nil then
     Rect.Intersect(Owner^.Clip);
  Rect.Move(-Origin.X, -Origin.Y);
end;

function GraphView.GetColor(Color: Word): Word; assembler;
asm
        MOV     AX,Color
        CALL    MapColor
end;

procedure GraphView.GetCommands(var Commands: TCommandSet);
begin
  Commands := CurCommandSet;
end;

procedure GraphView.GetData(var Rec);
begin
end;

procedure GraphView.GetEvent(var Event: TEvent);
begin
  if Owner <> nil then Owner^.GetEvent(Event);
end;

procedure GraphView.GetExtent(var Extent: TRect); assembler;
asm
        PUSH    DS
        LDS     SI,Self
        ADD     SI,OFFSET GraphView.Size
        LES     DI,Extent
        CLD
        XOR     AX,AX
        STOSW
        STOSW
        MOVSW
        MOVSW
        POP     DS
end;

function GraphView.GetHelpCtx: Word;
begin
  if State and sfDragging <> 0 then
    GetHelpCtx := hcDragging else
    GetHelpCtx := HelpCtx;
end;

function GraphView.GetPalette: PPalette;
begin
  GetPalette := nil;
end;


procedure GraphView.GetPeerViewPtr(var S: TStream; var P);
var
  Index: Integer;
begin
  S.Read(Index, SizeOf(Word));
  if (Index = 0) or (OwnerGroup = nil) then Pointer(P) := nil
  else
  begin
    Pointer(P) := FixupList^[Index];
    FixupList^[Index] := @P;
  end;
end;

function GraphView.GetState(AState : word) : boolean;
begin
   GetState := State and AState = AState;
end;

procedure GraphView.GrowTo(X, Y: Integer);
var
  R: TRect;
begin
  R.Assign(Origin.X, Origin.Y, Origin.X + X, Origin.Y + Y);
  Locate(R);
end;

procedure GraphView.HandleEvent(var Event: TEvent);
begin
  case Event.What of
     evMouseDown :
        begin
           if (State and (sfSelected + sfDisabled) = 0) and
              (Options and ofSelectable <> 0) then
           begin
{             Select;
             if Options and ofFirstClick = 0 then ClearEvent(Event);}
             if not Focus or (Options and ofFirstClick = 0) then
             ClearEvent(Event);
           end;
        end;
  end;
end;

procedure GraphView.Hide;
begin
  if State and sfVisible <> 0 then SetState(sfVisible, False);
end;

procedure GraphView.HideCursor;
begin
  SetState(sfCursorVis, False);
end;

procedure GraphView.HideView;
var
   R : TRect;
   OldState : word;
begin
   if LockFlag <> 0 then Exit;
   GetExtent(R);
   if R.Empty then Exit;
   OldState := State;
   State := State and not (sfVisible + sfExposed);
   GetBounds(R);
   ReDrawRect(R,nil);  {@Self}
   State := OldState;
end;

procedure GraphView.KeyEvent(var Event: TEvent);
begin
  repeat GetEvent(Event) until Event.What = evKeyDown;
end;

procedure GraphView.Locate(var Bounds: TRect);
var
  R,R1: TRect;
  Min, Max: TPoint;

function Range(Val, Min, Max: Integer): Integer;
begin
  if Val < Min then Range := Min else
    if Val > Max then Range := Max else
      Range := Val;
end;

begin
  SizeLimits(Min, Max);
  Bounds.B.X := Bounds.A.X + Range(Bounds.B.X - Bounds.A.X, Min.X, Max.X);
  Bounds.B.Y := Bounds.A.Y + Range(Bounds.B.Y - Bounds.A.Y, Min.Y, Max.Y);
  GetBounds(R);
  if not Bounds.Equals(R) then
  begin
    ChangeBounds(Bounds);
    with Cursor do SetCursor(X,Y);
  end;
end;

procedure GraphView.MakeFirst;
begin
  PutInFrontOf(Owner^.First);
end;

procedure GraphView.MakeGlobal(Source: TPoint; var Dest: TPoint); assembler;
asm
        LES     DI,Self
        XOR     AX,AX
        MOV     DX,AX
@@1:    ADD     AX,ES:[DI].GraphView.Origin.X
        ADD     DX,ES:[DI].GraphView.Origin.Y
        LES     DI,ES:[DI].GraphView.Owner
        MOV     SI,ES
        OR      SI,DI
        JNE     @@1
        ADD     AX,Source.X
        ADD     DX,Source.Y
        LES     DI,Dest
        CLD
        STOSW
        XCHG    AX,DX
        STOSW
end;

procedure GraphView.MakeLocal(Source: TPoint; var Dest: TPoint); assembler;
asm
        LES     DI,Self
        XOR     AX,AX
        MOV     DX,AX
@@1:    ADD     AX,ES:[DI].GraphView.Origin.X
        ADD     DX,ES:[DI].GraphView.Origin.Y
        LES     DI,ES:[DI].GraphView.Owner
        MOV     SI,ES
        OR      SI,DI
        JNE     @@1
        NEG     AX
        NEG     DX
        ADD     AX,Source.X
        ADD     DX,Source.Y
        LES     DI,Dest
        CLD
        STOSW
        XCHG    AX,DX
        STOSW
end;

function GraphView.MouseEvent(var Event: TEvent; Mask: Word): Boolean;
begin
  repeat GetEvent(Event) until Event.What and (Mask or evMouseUp) <> 0;
  MouseEvent := Event.What <> evMouseUp;
end;

function GraphView.MouseInView(Mouse: TPoint): Boolean;
var
  Extent: TRect;
begin
  MakeLocal(Mouse, Mouse);
  GetExtent(Extent);
  MouseInView := Extent.Contains(Mouse);
end;

procedure GraphView.MoveTo(X, Y: Integer);
var
  R: TRect;
begin
  R.Assign(X, Y, X + Size.X, Y + Size.Y);
  Locate(R);
end;

function GraphView.NextView: PGraphView;
begin
  if @Self = Owner^.Last then NextView := nil else NextView := Next;
end;

procedure GraphView.NormalCursor;
begin
  SetState(sfCursorIns, False);
end;

function GraphView.Prev: PGraphView; assembler;
asm
        LES     DI,Self
        MOV     CX,DI
        MOV     BX,ES
@@1:    MOV     AX,DI
        MOV     DX,ES
        LES     DI,ES:[DI].GraphView.Next
        CMP     DI,CX
        JNE     @@1
        MOV     SI,ES
        CMP     SI,BX
        JNE     @@1
end;

function GraphView.PrevView: PGraphView;
begin
  if @Self = Owner^.First then PrevView := nil else PrevView := Prev;
end;

procedure GraphView.PutEvent(var Event: TEvent);
begin
  if Owner <> nil then Owner^.PutEvent(Event);
end;

procedure GraphView.PutInFrontOf(Target: PGraphView);
var
  P, LastView: PGraphView;
  R: TRect;

procedure MoveView;
begin
  Owner^.RemoveView(@Self);
  Owner^.InsertView(@Self, Target);
end;

begin
  if (Owner <> nil) and (Target <> @Self) and (Target <> NextView) and
    ((Target = nil) or (Target^.Owner = Owner)) then
    if State and sfVisible = 0 then MoveView else
    begin
      LastView := NextView;
      P := Target;
      while (P <> nil) and (P <> LastView) do P := P^.NextView;
      if P = nil then LastView := Target;
      State := State and not sfVisible;
      MoveView;
      State := State or sfVisible;
      if Options and ofSelectable <> 0 then Owner^.ResetCurrent;
      if LastView = Target then
      begin
         GetBounds(R);
         RedrawRect(R,nil);
      end;
   end;
end;

procedure GraphView.PutPeerViewPtr(var S: TStream; P: PGraphView);
var
  Index: Integer;
begin
  if (P = nil) or (OwnerGroup = nil) then Index := 0
  else Index := OwnerGroup^.IndexOf(P);
  S.Write(Index, SizeOf(Word));
end;

procedure GraphView.RefreshRect(Bounds : TRect);

function NextExposed(P : PGraphView) : PGraphView;
begin
   while (P <> nil) and not P^.Exposed do P := P^.NextView;
   NextExposed := P;
end;

procedure DoDraw(Bounds : TRect; Target : PGraphView);
var
   R,R1 : TRect;
begin
   if Owner = nil then Exit;
   Owner^.Clip.Copy(Bounds);
   Owner^.ChangeClipRect;
   Target := NextExposed(Target);
   if Target = nil then begin
      Owner^.ResetClipRect;
      Exit;
   end;
   if Target = @Self then begin
      Owner^.RefreshRect(Bounds);
      Owner^.ResetClipRect;
   end else begin
      Target^.GetBounds(R);
      R.Intersect(Bounds);
      if R.Empty then DoDraw(Bounds,Target)
      else begin
         if Bounds.B.Y > R.B.Y then begin
             with Bounds do R1.Assign(A.X, R.B.Y, B.X, B.Y);
             Bounds.B.Y := R.B.Y;
             DoDraw(R1, Target);
         end;
         if Bounds.A.Y < R.A.Y then begin
            with Bounds do R1.Assign(A.X, A.Y, B.X, R.A.Y);
            DoDraw(R1, Target);
            Bounds.A.Y := R.A.Y;
         end;
         if Bounds.B.X > R.B.X then begin
            with Bounds do R1.Assign(R.B.X, A.Y, B.X, B.Y);
            DoDraw(R1, Target);
         end;
         if Bounds.A.X < R.A.X then begin
            with Bounds do R1.Assign(A.X, A.Y, R.A.X, B.Y);
            DoDraw(R1, Target);
         end;
         Owner^.ResetCliprect;
      end;
   end;
end;

begin
   if Exposed then begin
      Bounds.Move(Origin.X,Origin.Y);
      DoDraw(Bounds,Owner^.First);
   end;
end;

procedure GraphView.Select;
begin
  if Options and ofTopSelect <> 0 then MakeFirst else
    if Owner <> nil then Owner^.SetCurrent(@Self, NormalSelect);
end;

procedure GraphView.SetBounds(var Bounds: TRect); assembler;
asm
        PUSH    DS
        LES     DI,Self
        LDS     SI,Bounds
        MOV     AX,[SI].TRect.A.X
        MOV     ES:[DI].Origin.X,AX
        MOV     AX,[SI].TRect.A.Y
        MOV     ES:[DI].Origin.Y,AX
        MOV     AX,[SI].TRect.B.X
        SUB     AX,[SI].TRect.A.X
        MOV     ES:[DI].Size.X,AX
        MOV     AX,[SI].TRect.B.Y
        SUB     AX,[SI].TRect.A.Y
        MOV     ES:[DI].Size.Y,AX
        POP     DS
end;

procedure GraphView.SetCursor(X, Y: Integer);
var
   Clip : TRect;
begin
  if (not State) and (sfVisible + sfCursorVis + sfFocused) = 0
  then DrawCursor;
  Cursor.X := X;
  Cursor.Y := Y;
  GetClipRect(Clip);
  with Clip do begin
     Dec(X,A.X);
     Dec(Y,A.Y);
  end;
  Graph.MoveTo(X,Y);
  if (not State) and (sfVisible + sfCursorVis + sfFocused) = 0
  then DrawCursor;
end;

procedure GraphView.ChangeClipRect;
begin
{  do nothing}
end;

procedure GraphView.ResetClipRect;
begin
end;

procedure GraphView.SetCommands(Commands: TCommandSet);
begin
  CommandSetChanged := CommandSetChanged or (CurCommandSet <> Commands);
  CurCommandSet := Commands;
end;

procedure GraphView.SetData(var Rec);
begin
end;

procedure GraphView.SetDrawPort(Bounds : TRect);
var
   R : TRect;
begin
   with R do begin
      MakeGlobal(Bounds.A,A);
      MakeGlobal(Bounds.B,B);
      if B.X > ScreenWidth then B.X := ScreenWidth;
      if B.Y > ScreenHeight then B.Y := ScreenHeight;
      SetViewPort(A.X,A.Y,B.X-1,B.Y-1,true);
   end;
end;

procedure GraphView.SetState(AState: Word; Enable: Boolean);
var
  Command: Word;
begin
  if AState = sfCursorIns then
  if Exposed and ((not State) and (sfCursorVis+ sfFocused) = 0)
  then DrawCursor;
  if Enable then
    State := State or AState else
    State := State and not AState;
  if Owner <> nil then
    case AState of
      sfVisible:
        begin
          if Owner^.State and sfExposed <> 0 then
            SetState(sfExposed, Enable);
          if not Enable then begin
             HideCursor;
             HideView;
          end;
          if Options and ofSelectable <> 0 then Owner^.ResetCurrent
          else  begin
             DrawView; {if Enable then DrawView;}
             if (not State) and (sfVisible + sfCursorVis + sfFocused) = 0 then
             DrawCursor;
          end;
        end;
      sfCursorVis: if Exposed and (State and sfFocused <> 0) then
                   DrawCursor;
      sfCursorIns: if Exposed and ((not State) and (sfCursorVis+sfFocused) = 0)
                   then DrawCursor;
      sfFocused:
        begin
          if Enable then
            Command := cmReceivedFocus else
            Command := cmReleasedFocus;
          Message(Owner, evBroadcast, Command, @Self);
          if (State and sfCursorVis) <> 0 then DrawCursor;
        end;
    end;
end;

procedure GraphView.Show;
begin
  if State and sfVisible = 0 then SetState(sfVisible, True);
end;

procedure GraphView.ShowCursor;
begin
  SetState(sfCursorVis, True);
end;

procedure GraphView.SizeLimits(var Min, Max: TPoint);
begin
  Longint(Min) := 0;
  if Owner <> nil then
    Max := Owner^.Size else
    Longint(Max) := $7FFF7FFF;
end;

procedure GraphView.Store(var S: TStream);
var
  SaveState: Word;
begin
  SaveState := State;
  State := State and not (sfActive + sfSelected + sfFocused + sfExposed);
  S.Write(Origin,
    SizeOf(TPoint) * 3 +
    SizeOf(Byte) * 2 +
    SizeOf(Word) * 4);
  State := SaveState;
end;

function GraphView.TopView: PGraphView;
var
  P: PGraphView;
begin
  if TheTopView = nil then
  begin
    P := @Self;
    while (P <> nil) and (P^.State and sfModal = 0) do P := P^.Owner;
    TopView := P;
  end
  else TopView := TheTopView;
end;

function GraphView.Valid(Command: Word): Boolean;
begin
  Valid := True;
end;

{ Basic drawing procedures for GraphView}

procedure GraphView.Arc(Center : TPoint; StAngle, EndAngle, Radius: Word);
var
   Clip : TRect;
begin
   GetClipRect(Clip);
   with Clip do begin
      Dec(Center.X,A.X);
      Dec(Center.Y,A.Y);
   end;
   with Center do Graph.Arc(X,Y,StAngle,EndAngle,Radius);
end;

procedure GraphView.Bar(Bounds : TRect);
var
   Clip : TRect;
begin
   GetClipRect(Clip);
   Bounds.Intersect(Clip);
   with Clip do Bounds.Move(-A.X,-A.Y);
   with Bounds do Graph.Bar(A.X,A.Y,B.X-1,B.Y-1);
end;

procedure GraphView.Circle(Center : TPoint; Radius : word);
var
   Clip : TRect;
begin
   GetClipRect(Clip);
   with Clip do begin
      Dec(Center.X,A.X);
      Dec(Center.Y,A.Y);
   end;
   with Center do Graph.Circle(X,Y,Radius);
end;

procedure GraphView.DrawImg(Location : TPoint; Image : PImage; BitBlt : word);
var
   Clip,Bounds : TRect;
begin
   GetClipRect(Clip);
   with Clip do begin
      dec(Location.X,A.X);
      dec(Location.Y,A.Y);
   end;
   with Location do Image^.Draw(X,Y,BitBlt);
end;

procedure GraphView.EllipticArc(Center : TPoint; StAngle,EndAngle,
                                XRadius,YRadius : word);
var
   Clip : TRect;
begin
   GetClipRect(Clip);
   with Clip do begin
      Dec(Center.X,A.X);
      Dec(Center.Y,A.Y);
   end;
   with Center do Graph.Ellipse(X,Y,StAngle,EndAngle,XRadius,YRadius);
end;

procedure GraphView.Ellipse(Center : TPoint; XRadius,YRadius : word);
begin
   EllipticArc(Center,0,360,XRadius,YRadius);
end;

procedure GraphView.FillEllipse(Center : TPoint; XRadius,YRadius : word);
var
   Clip : TRect;
begin
   GetClipRect(Clip);
   with Clip do begin
      Dec(Center.X,A.X);
      Dec(Center.Y,A.Y);
   end;
   with Center do Graph.FillEllipse(X,Y,XRadius,YRadius);
end;

procedure GraphView.Line(Bounds : TRect);
var
   Clip : TRect;
begin
{   GetClipRect(Clip);}
   GetBounds(Clip);
   if Owner <> nil then
      Clip.Intersect(Owner^.Clip);
   with Clip do Bounds.Move(-(A.X-Origin.X),-(A.Y-Origin.Y));
{   with Clip do Bounds.Move(-A.X,-A.Y);}
   with Bounds do begin
      if (A.X < B.X) then dec(B.X) else
      if A.X > B.X then dec(A.X);
      if A.Y < B.Y then Dec(B.Y) else
      if A.Y > B.Y then dec(A.Y);
      Graph.Line(A.X,A.Y,B.X,B.Y);
   end;
end;

procedure GraphView.LineTo(Point : TPoint);
var
   Clip : TRect;
   Pt : TPoint;
begin
   Pt := Point;
   GetClipRect(Clip);
   with Clip do begin
      dec(Pt.X,A.X);
      dec(Pt.Y,A.Y);
   end;
   with Pt do Graph.LineTo(X,Y);
   with Point do SetCursor(X,Y);
end;

procedure GraphView.Rectangle(Bounds : TRect);
var
   Clip : TRect;
begin
   GetClipRect(Clip);
   with Clip do Bounds.Move(-A.X,-A.Y);
   with Bounds do Graph.Rectangle(A.X,A.Y,B.X-1,B.Y-1);
end;

procedure GraphView.BicolorRectangle(Bounds : TRect; Light,Dark : word; Down : boolean);
var
   Clip,R : TRect;
   UpperLeft,RightDown : word;
begin
   GetClipRect(Clip);
   with Clip do Bounds.Move(-A.X,-A.Y);
   if Down then begin
      UpperLeft := Dark;
      RightDown := Light;
   end else begin
      UpperLeft := Light;
      RightDown := Dark;
   end;
   SetLineStyle(SolidLn,0,NormWidth);
   with Bounds do begin
      SetColor(UpperLeft);
      Graph.Line(A.X,A.Y,A.X,B.Y-1);
      Graph.Line(A.X,A.Y,B.X-1,A.Y);
      SetColor(RightDown);
      Graph.Line(A.X,B.Y-1,B.X-1,B.Y-1);
      Graph.Line(B.X-1,A.Y,B.X-1,B.Y-1);
   end;
end;

procedure GraphView.WriteText(S : String);
var
   CP : TPoint;
   i,j : integer;
   Clip : TRect;
begin
   CP := Cursor;
   WriteTextXY(CP,S);
   with CP do SetCursor(X+TextWidth(S),Y);
end;

procedure GraphView.WriteTextXY(Point : TPoint; S : string);
var
   Clip : TRect;
   I,J : integer;
begin
{   GetClipRect(Clip);}
   GetBounds(Clip);
   if Owner <> nil then
      Clip.Intersect(Owner^.Clip);
   with Clip do begin
      Dec(Point.X,(A.X-Origin.X));
      Dec(Point.Y,(A.Y-Origin.Y));
{      Dec(Point.X,A.X);
      Dec(Point.Y,A.Y);}
   end;
   GFonts.OutTextXY(Point,S);
end;

procedure GraphView.WriteCTextXY(Point : TPoint; S : string; TextColor,AccelColor : word);
var
   Tmp,Tmp1 : string;
   P : integer;
   Color1,Color2 : word;
   Old : TextSettingsType;
   Pt : TPoint;
   OldCursor : TPoint;
begin
    P := Pos('~', S);
    Pt := Point;
    Color1 := TextColor;
    Color2 := AccelColor;
    if P > 0 then begin
      OldCursor := Cursor;
      GetTextSettings(Old);
      Tmp := Copy(S, 1, P-1);
      if Old.Horiz = CenterText then begin
         CStrToStr(S,Tmp1);
         dec(Point.X,GFonts.TextWidth(Tmp1) div 2);
      end;
      SetColor(Color1);
      WriteTextXY(Point,Tmp);
      with Point do SetCursor(X+TextWidth(Tmp),Y);
      SetTextJustify(LeftText,Old.Vert);
      S := Copy(S, P+1, Length(S)-P);
      P := Pos('~', S);
      Tmp := Copy(S,1,P-1);
      SetColor(Color2);
      WriteText(Tmp);
      S := Copy(S,P+1,length(S)-P);
      SetColor(Color1);
      WriteText(S);
      with Old do begin
         SetTextJustify(Horiz,Vert);
      end;
      with OldCursor do SetCursor(X,Y);
   end else begin
      SetColor(Color1);
      WriteTextXY(Point,S);
   end;
end;

procedure GraphView.PieSlice(Center : TPoint; StAngle, EndAngle, Radius: Word);
var
   Clip : TRect;
begin
   GetClipRect(Clip);
   with Clip do begin
      Dec(Center.X,A.X);
      Dec(Center.Y,A.Y);
   end;
   with Center do Graph.PieSlice(X,Y,StAngle,EndAngle,Radius);
end;

procedure GraphView.PutBitmap(Location : TPoint; var BitMap; BitBlt : word);
var
   Clip,Bounds : TRect;
begin
   GetClipRect(Clip);
   with Clip do begin
      dec(Location.X,A.X);
      dec(Location.Y,A.Y);
   end;
   with Location do DrawImage(X,Y,BitMap,BitBlt);
end;

procedure GraphView.PutPixel(Location : TPoint; Color : word);
var
   Clip : TRect;
begin
   GetClipRect(Clip);
   if Clip.Contains(Location) then
   with Location do Graph.PutPixel(X,Y,Color);
end;

procedure GraphView.MoveRect(Bounds : TRect; DeltaX,DeltaY : integer);
var
   Clip : TRect;
begin
   GetClipRect(Clip);
   with Bounds do begin
      Move(-Clip.A.X,-Clip.A.Y);
      MoveBlock(A.X,A.Y,B.X-1,B.Y-1,DeltaX,DeltaY);
   end;
end;

Type PPointArray= ^TPointArray;
     TPointArray = Array [1..1] of TPoint;

procedure GraphView.FillPoly(Number:Word;Var PolyArray);

var
   Clip      : TRect;
   i         : Integer;
   TempArray : PPointArray;
begin
   GetClipRect(Clip);
   GetMem(TempArray,Number*sizeof(Tpoint));
   Move(PolyArray,TempArray^,Number*sizeof(Tpoint));
   for i:=1 to Number do
     with Clip do
     begin
       dec(TempArray^[I].X,A.X);
       dec(TempArray^[I].Y,A.Y);
     end;
   Graph.FillPoly(Number,TempArray^);
   FreeMem(TempArray,Number*sizeof(TPoint));
end;

procedure GraphView.DrawPoly(Number:Word;Var PolyArray);

var
   Clip      : TRect;
   i         : Integer;
   TempArray : PPointArray;
begin
   GetClipRect(Clip);
   GetMem(TempArray,Number*sizeof(Tpoint));
   Move(PolyArray,TempArray^,Number*sizeof(Tpoint));
   for i:=1 to Number do
     with Clip do
     begin
       dec(TempArray^[I].X,A.X);
       dec(TempArray^[I].Y,A.Y);
     end;
   Graph.DrawPoly(Number,TempArray^);
   FreeMem(TempArray,Number*sizeof(TPoint));
end;

{ GraphBackground }

constructor GraphBackground.Init(var Bounds: TRect; APattern: word;
              ABorderStyle : Integer);
begin
  GraphView.Init(Bounds);
  GrowMode := gfGrowHiX + gfGrowHiY;
  Pattern := APattern;
  BorderStyle := ABorderStyle;
end;

constructor GraphBackground.Load(var S: TStream);
begin
  GraphView.Load(S);
  S.Read(Pattern, SizeOf(Pattern));
  S.Read(BorderStyle,SizeOf(BorderStyle));
end;

procedure GraphBackground.Draw;
var
	OldPattern : FillSettingsType;
	R : TRect;
begin
	GetClipRect(R);
	R.Move(-R.A.X,-R.A.Y);
	GetFillSettings(OldPattern);
	SetFillStyle(Pattern,GetColor(1));
   with R do Graph.Bar(A.X,A.Y,B.X-1,B.Y-1);
	if (BorderStyle <> 0) then
		begin
		GetExtent(R);
		BicolorRectangle(R, GetColor($0002), GetColor($0003),BorderStyle = bsLower);
		end;
	with OldPattern do
		SetFillStyle(Pattern,Color);
end;

function GraphBackground.GetPalette : PPalette;
const
  P: String[Length(CBackground)] = CBackground;
begin
  GetPalette := @P;
end;

procedure GraphBackground.Store(var S: TStream);
begin
  GraphView.Store(S);
  S.Write(Pattern, SizeOf(Pattern));
  S.Write(BorderStyle,SizeOf(BorderStyle));
end;

{ GraphGroup }

constructor GraphGroup.Init(var Bounds: TRect);
begin
  GraphView.Init(Bounds);
  Options := Options or ofSelectable;
  GetExtent(Clip);
  EventMask := $FFFF;
end;

constructor GraphGroup.Load(var S: TStream);
var
  FixupSave: PFixupList;
  Count, I: Integer;
  P, Q: ^Pointer;
  V: PGraphView;
  OwnerSave: PGraphGroup;
begin
  GraphView.Load(S);
  GetExtent(Clip);
  OwnerSave := OwnerGroup;
  OwnerGroup := @Self;
  FixupSave := FixupList;
  S.Read(Count, SizeOf(Word));
  asm
        MOV     CX,Count
        SHL     CX,1
        SHL     CX,1
        SUB     SP,CX
        MOV     FixupList.Word[0],SP
        MOV     FixupList.Word[2],SS
        MOV     DI,SP
        PUSH    SS
        POP     ES
        XOR     AL,AL
        CLD
        REP     STOSB
  end;
  for I := 1 to Count do
  begin
    V := PGraphView(S.Get);
    if V <> nil then InsertView(V, nil);
  end;
  V := Last;
  for I := 1 to Count do
  begin
    V := V^.Next;
    P := FixupList^[I];
    while P <> nil do
    begin
      Q := P;
      P := P^;
      Q^ := V;
    end;
  end;
  OwnerGroup := OwnerSave;
  FixupList := FixupSave;
  GetSubViewPtr(S, V);
  SetCurrent(V, NormalSelect);
end;

destructor GraphGroup.Done;
var
  P, T: PGraphView;
begin
  HideCursor;
  Hide;
  P := Last;
    if P <> nil then
    repeat
      T := P^.Prev;
      Dispose(P, Done);
      P := T;
    until Last = nil;
  GraphView.Done;
end;

function GraphGroup.At(Index: Integer): PGraphView; assembler;
asm
        LES     DI,Self
        LES     DI,ES:[DI].GraphGroup.Last
        MOV     CX,Index
@@1:    LES     DI,ES:[DI].GraphView.Next
        LOOP    @@1
        MOV     AX,DI
        MOV     DX,ES
end;

procedure GraphGroup.ChangeBounds(var Bounds: TRect);
var
  D: TPoint;
  R1,R2 : TRect;
  V : PGraphView;

procedure DoCalcChange(P: PGraphView); far;
var
  R: TRect;
begin
  P^.CalcBounds(R, D);
  P^.ChangeBounds(R);
end;

begin
  D.X := Bounds.B.X - Bounds.A.X - Size.X;
  D.Y := Bounds.B.Y - Bounds.A.Y - Size.Y;
{  if Longint(D) = 0 then HideView
  else begin
     if ((Origin.X <> Bounds.A.X) or (Origin.Y <> Bounds.A.Y)) then HideView
     else if (D.X < 0) or (D.Y < 0) then HideView;
  end;}
  GetBounds(R2);
  SetBounds(Bounds);
  PrepClipRect;
  Lock;
  ForEach(@DoCalcChange);
  Unlock;
  if State and sfActive <> 0 then DrawView
  else begin
     GetExtent(R1);
     Refreshrect(R1);
  end;
  if Owner <> nil then begin
     if LockMouseCursor = 0 then HideMouse;
     inc(LockMouseCursor);
     V := Owner^.Last;
     while V <> @Self do begin
        V^.GetBounds(R1);
        R1.Intersect(R2);
        if not R1.Empty then with V^ do begin
           R1.Move(-Origin.X,-Origin.Y);
           RefreshRect(R1);
        end;
        V := V^.Prev;
     end;
     Dec(LockMouseCursor);
     if LockMouseCursor = 0 then ShowMouse;
  end;
end;

procedure GraphGroup.ChangeClipRect;

procedure DoResetClip(P : PGraphView); far;
begin
   P^.ResetClipRect;
end;

begin
   Lock;
   ForEach(@DoResetClip);
   Unlock;
end;

procedure GraphGroup.ChangeMouseCursor;
var
   Who : PGraphView;

function ContainsMouse(P: PGraphView): Boolean; far;
begin
  ContainsMouse := (P^.State and sfVisible <> 0) and
    P^.MouseInView(MouseWhere);
end;

begin
   Who := FirstThat(@ContainsMouse);
   if (Who <> nil) and (LockMouseCursor= 0) then begin
{      if Who <> MouseOwner then begin}
         MouseOwner := nil;
         Who^.ChangeMouseCursor;
{      end;}
   end;
end;

procedure GraphGroup.ResetClipRect;

procedure DoResetClip(P : PGraphView); far;
begin
   P^.ResetClipRect;
end;

begin
   PrepClipRect;
   Lock;
   ForEach(@DoResetClip);
   UnLock;
end;

function GraphGroup.DataSize: Word;
var
  T: Word;

procedure AddSubviewDataSize(P: PGraphView); far;
begin
  Inc(T, P^.DataSize);
end;

begin
  T := 0;
  ForEach(@AddSubviewDataSize);
  DataSize := T;
end;

procedure GraphGroup.Delete(P: PGraphView);
var
  SaveState: Word;
begin
  SaveState := P^.State;
  P^.Hide;
  RemoveView(P);
  P^.Owner := nil;
  P^.Next := nil;
  if SaveState and sfVisible <> 0 then P^.Show;
end;

procedure GraphGroup.Draw;
var
  R: TRect;
  MF : boolean;
begin
    GetClipRect(R);
    MakeGlobal(R.A,R.A);
    MakeGlobal(R.B,R.B);
    MF := MouseInRect(R);
    if MF then HideMouse;
    DrawSubViews(Last,nil);
    if MF then ShowMouse;
end;

procedure GraphGroup.DrawSubViews(P, Top: PGraphView);
begin
  while P <> Top do
  begin
    P^.DrawView;
    P := P^.PrevView;
  end;
end;

procedure GraphGroup.EndModal(Command: Word);
begin
  if State and sfModal <> 0 then EndState := Command
  else GraphView.EndModal(Command);
end;

procedure GraphGroup.EventError(var Event: TEvent);
begin
  if Owner <> nil then Owner^.EventError(Event);
end;

function GraphGroup.Execute: Word;
var
  E: TEvent;
begin
  repeat
    EndState := 0;
    repeat
      GetEvent(E);
      HandleEvent(E);
      if E.What <> evNothing then EventError(E);
    until EndState <> 0;
  until Valid(EndState);
  Execute := EndState;
end;

function GraphGroup.ExecView(P: PGraphView): Word;
var
  SaveOptions: Word;
  SaveOwner: PGraphGroup;
  SaveTopView: PGraphView;
  SaveCurrent: PGraphView;
  SaveCommands: TCommandSet;
begin
  if P <> nil then
  begin
    SaveOptions := P^.Options;
    SaveOwner := P^.Owner;
    SaveTopView := TheTopView;
    SaveCurrent := Current;
    GetCommands(SaveCommands);
    TheTopView := P;
    P^.Options := P^.Options and not ofSelectable;
    P^.SetState(sfModal, True);
    SetCurrent(P, EnterSelect);
    if SaveOwner = nil then GraphGroup.Insert(P);
    if LockMouseCursor = 0 then
      if Owner = nil then ChangeMouseCursor
      else Owner^.ChangeMouseCursor;
    ExecView := P^.Execute;
    if SaveOwner = nil then GraphGroup.Delete(P);
    SetCurrent(SaveCurrent, LeaveSelect);
    P^.SetState(sfModal, False);
    P^.Options := SaveOptions;
    TheTopView := SaveTopView;
    SetCommands(SaveCommands);
    if LockMouseCursor = 0 then
       if Owner = nil then ChangeMouseCursor
       else Owner^.ChangeMouseCursor;
  end else ExecView := cmCancel;
end;

function GraphGroup.First: PGraphView;
begin
  if Last = nil then First := nil else First := Last^.Next;
end;

function GraphGroup.FirstMatch(AState: Word; AOptions: Word): PGraphView;

function Matches(P: PGraphView): Boolean; far;
begin
  Matches := (P^.State and AState = AState) and
    (P^.Options and AOptions = AOptions);
end;

begin
  FirstMatch := FirstThat(@Matches);
end;

function GraphGroup.FirstThat(P: Pointer): PGraphView; assembler;
var
  ALast: Pointer;
asm
        LES     DI,Self
        LES     DI,ES:[DI].GraphGroup.Last
        MOV     AX,ES
        OR      AX,DI
        JE      @@3
        MOV     WORD PTR ALast[2],ES
        MOV     WORD PTR ALast[0],DI
@@1:    LES     DI,ES:[DI].GraphView.Next
        PUSH    ES
        PUSH    DI
        PUSH    ES
        PUSH    DI
        PUSH    WORD PTR [BP]
        CALL    P
        POP     DI
        POP     ES
        OR      AL,AL
        JNE     @@2
        CMP     DI,WORD PTR ALast[0]
        JNE     @@1
        MOV     AX,ES
        CMP     AX,WORD PTR ALast[2]
        JNE     @@1
        XOR     DI,DI
        MOV     ES,DI
@@2:    MOV     SP,BP
@@3:    MOV     AX,DI
        MOV     DX,ES
end;

function GraphGroup.FindNext(Forwards: Boolean): PGraphView;
var
  P: PGraphView;
begin
  FindNext := nil;
  if Current <> nil then
  begin
    P := Current;
    repeat
      if Forwards then P := P^.Next else P := P^.Prev;
    until ((P^.State and (sfVisible + sfDisabled) = sfVisible) and
      (P^.Options and ofSelectable <> 0)) or (P = Current);
    if P <> Current then FindNext := P;
  end;
end;

function GraphGroup.FocusNext(Forwards: Boolean): Boolean;
var
  P: PGraphView;
begin
  P := FindNext(Forwards);
  FocusNext := True;
  if P <> nil then FocusNext := P^.Focus;
end;

procedure GraphGroup.ForEach(P: Pointer); assembler;
var
  ALast: Pointer;
asm
        LES     DI,Self
        LES     DI,ES:[DI].GraphGroup.Last
        MOV     AX,ES
        OR      AX,DI
        JE      @@4
        MOV     WORD PTR ALast[2],ES
        MOV     WORD PTR ALast[0],DI
        LES     DI,ES:[DI].GraphView.Next
@@1:    CMP     DI,WORD PTR ALast[0]
        JNE     @@2
        MOV     AX,ES
        CMP     AX,WORD PTR ALast[2]
        JE      @@3
@@2:    PUSH    WORD PTR ES:[DI].GraphView.Next[2]
        PUSH    WORD PTR ES:[DI].GraphView.Next[0]
        PUSH    ES
        PUSH    DI
        PUSH    WORD PTR [BP]
        CALL    P
        POP     DI
        POP     ES
        JMP     @@1
@@3:    PUSH    WORD PTR [BP]
        CALL    P
@@4:
end;


procedure GraphGroup.GetClipRect(var Rect : TRect);
begin
   Rect.Copy(Clip);
end;

procedure GraphGroup.GetData(var Rec);
type
  Bytes = array[0..65534] of Byte;
var
  I: Word;
  V: PGraphView;
begin
  I := 0;
  if Last <> nil then
  begin
    V := Last;
    repeat
      V^.GetData(Bytes(Rec)[I]);
      Inc(I, V^.DataSize);
      V := V^.Prev;
    until V = Last;
  end;
end;

function GraphGroup.GetHelpCtx: Word;
var
  H: Word;
begin
  H:= hcNoContext;
  if Current <> nil then H := Current^.GetHelpCtx;
  if H = hcNoContext then H := GraphView.GetHelpCtx;
  GetHelpCtx := H;
end;

procedure GraphGroup.GetSubViewPtr(var S: TStream; var P);
var
  Index: Word;
begin
  S.Read(Index, SizeOf(Word));
  if Index > 0 then
     Pointer(P) := At(Index)
  else Pointer(P) := nil;
end;

procedure GraphGroup.HandleEvent(var Event: TEvent);

procedure DoHandleEvent(P: PGraphView); far;
begin
  if (P = nil) or ((P^.State and sfDisabled <> 0)
    and (Event.What and (PositionalEvents or FocusedEvents) <> 0)) then Exit;
  case Phase of
    phPreProcess: if P^.Options and ofPreProcess = 0 then Exit;
    phPostProcess: if P^.Options and ofPostProcess = 0 then Exit;
  end;
  if (Event.What and P^.EventMask) <> 0 then P^.HandleEvent(Event);
end;

function ContainsMouse(P: PGraphView): Boolean; far;
begin
  ContainsMouse := (P^.State and sfVisible <> 0) and
    P^.MouseInView(Event.Where);
end;

begin
  GraphView.HandleEvent(Event);
  if Event.What and FocusedEvents <> 0 then
  begin
    Phase := phPreProcess;
    ForEach(@DoHandleEvent);
    Phase := phFocused;
    DoHandleEvent(Current);
    Phase := phPostProcess;
    ForEach(@DoHandleEvent);
  end else
  begin
    Phase := phFocused;
    if (Event.What and PositionalEvents <> 0) then
      DoHandleEvent(FirstThat(@ContainsMouse)) else
      ForEach(@DoHandleEvent);
  end;
end;

function GraphGroup.IndexOf(P: PGraphView): Integer; assembler;
asm
        LES     DI,Self
        LES     DI,ES:[DI].GraphGroup.Last
        MOV     AX,ES
        OR      AX,DI
        JE      @@3
        MOV     CX,DI
        MOV     BX,ES
        XOR     AX,AX
@@1:    INC     AX
        LES     DI,ES:[DI].GraphView.Next
        MOV     DX,ES
        CMP     DI,P.Word[0]
        JNE     @@2
        CMP     DX,P.Word[2]
        JE      @@3
@@2:    CMP     DI,CX
        JNE     @@1
        CMP     DX,BX
        JNE     @@1
        XOR     AX,AX
@@3:
end;

procedure GraphGroup.Insert(P: PGraphView);
begin
  InsertBefore(P, First);
end;

procedure GraphGroup.InsertBefore(P, Target: PGraphView);
var
  SaveState: Word;
begin
  if (P <> nil) and (P^.Owner = nil) and
    ((Target = nil) or (Target^.Owner = @Self)) then
  begin
    if P^.Options and ofCenterX <> 0 then
      P^.Origin.X := (Size.X - P^.Size.X) div 2;
    if P^.Options and ofCenterY <> 0 then
      P^.Origin.Y := (Size.Y - P^.Size.Y) div 2;
    SaveState := P^.State;
    P^.Hide;
    InsertView(P, Target);
    P^.ResetClipRect;
    if SaveState and sfVisible <> 0 then P^.Show;
  end;
end;

procedure GraphGroup.InsertView(P, Target: PGraphView);
begin
  P^.Owner := @Self;
  if Target <> nil then
  begin
    Target := Target^.Prev;
    P^.Next := Target^.Next;
    Target^.Next := P;
  end else
  begin
    if Last = nil then P^.Next := P else
    begin
      P^.Next := Last^.Next;
      Last^.Next := P;
    end;
    Last := P;
  end;
end;

procedure GraphGroup.Lock;
begin
   inc(LockFlag);
end;

procedure GraphGroup.PutSubViewPtr(var S: TStream; P: PGraphView);
var
  Index: Word;
begin
  if P = nil then Index := 0
  else Index := IndexOf(P);
  S.Write(Index, SizeOf(Word));
end;

procedure GraphGroup.Redraw;
begin
   GetExtent(Clip);
   DrawSubViews(Last,nil);
   PrepClipRect;
end;

procedure GraphGroup.RemoveView(P: PGraphView); assembler;
asm
        PUSH    DS
        LDS     SI,Self
        LES     DI,P
        LDS     SI,DS:[SI].GraphGroup.Last
        PUSH    BP
        MOV     AX,DS
        OR      AX,SI
        JE      @@7
        MOV     AX,SI
        MOV     DX,DS
        MOV     BP,ES
@@1:    MOV     BX,WORD PTR DS:[SI].GraphView.Next[0]
        MOV     CX,WORD PTR DS:[SI].GraphView.Next[2]
        CMP     CX,BP
        JE      @@5
@@2:    CMP     CX,DX
        JE      @@4
@@3:    MOV     SI,BX
        MOV     DS,CX
        JMP     @@1
@@4:    CMP     BX,AX
        JNE     @@3
        JMP     @@7
@@5:    CMP     BX,DI
        JNE     @@2
        MOV     BX,WORD PTR ES:[DI].GraphView.Next[0]
        MOV     CX,WORD PTR ES:[DI].GraphView.Next[2]
        MOV     DS:WORD PTR [SI].GraphView.Next[0],BX
        MOV     DS:WORD PTR [SI].GraphView.Next[2],CX
        CMP     DX,BP
        JNE     @@7
        CMP     AX,DI
        JNE     @@7
        CMP     CX,BP
        JNE     @@6
        CMP     BX,DI
        JNE     @@6
        XOR     SI,SI
        MOV     DS,SI
@@6:    POP     BP
        PUSH    BP
        LES     DI,Self
        MOV     WORD PTR ES:[DI].GraphView.Last[0],SI
        MOV     WORD PTR ES:[DI].GraphView.Last[2],DS
@@7:    POP     BP
        POP     DS
end;

procedure GraphGroup.ResetCurrent;
begin
  SetCurrent(FirstMatch(sfVisible, ofSelectable), NormalSelect);
end;

procedure GraphGroup.DrawCursor;
begin
  if Current <> nil then Current^.DrawCursor;
end;

procedure GraphGroup.SelectNext(Forwards: Boolean);
var
  P: PGraphView;
begin
    P := FindNext(Forwards);
    if P <> nil then P^.Select;
end;

procedure GraphGroup.PrepClipRect;
var
   R : TRect;
begin
   if Owner <> nil then begin
      GetBounds(Clip);
      Owner^.GetClipRect(R);
      Clip.Intersect(R);
      if not Clip.Empty then Clip.Move(-Origin.X,-Origin.Y);
   end else GetExtent(Clip);
end;

procedure GraphGroup.SetCurrent(P: PGraphView; Mode: SelectMode);

procedure SelectView(P: PGraphView; Enable: Boolean);
var
   R : TRect;
begin
  if P <> nil then begin
     if Enable then Lock;
     P^.SetState(sfSelected, Enable); {прорисовывается в SetState}
     if Enable then begin
        Unlock;
        if Options and ofNoDrawSelect = 0 then begin
{           P^.GetClipRect(R);
           P^.RefreshRect(R);}
           P^.DrawView;
        end;
     end;
  end;
end;

procedure FocusView(P: PGraphView; Enable: Boolean);
begin
  if (State and sfFocused <> 0) and (P <> nil) then
    P^.SetState(sfFocused, Enable);
end;

begin
  if Current <> P then
  begin
    FocusView(Current, False);
    if Mode <> EnterSelect then
       SelectView(Current, False);
    if Mode <> LeaveSelect then
       SelectView(P, True);
    FocusView(P, True);
    Current := P;
    ChangeMouseCursor;
  end;
end;

procedure GraphGroup.SetData(var Rec);
type
  Bytes = array[0..65534] of Byte;
var
  I: Word;
  V: PGraphView;
begin
  I := 0;
  if Last <> nil then
  begin
    V := Last;
    repeat
      V^.SetData(Bytes(Rec)[I]);
      Inc(I, V^.DataSize);
      V := V^.Prev;
    until V = Last;
  end;
end;

procedure GraphGroup.SetState(AState: Word; Enable: Boolean);

procedure DoSetState(P: PGraphView); far;
begin
  P^.SetState(AState, Enable);
end;

procedure DoExpose(P: PGraphView); far;
begin
  if P^.State and sfVisible <> 0 then P^.SetState(sfExposed, Enable);
end;

begin
  GraphView.SetState(AState, Enable);
  case AState of
    sfActive, sfDragging:
      ForEach(@DoSetState);
    sfFocused:
      if Current <> nil then Current^.SetState(sfFocused, Enable);
    sfExposed:
      ForEach(@DoExpose);
  end;
end;

procedure GraphGroup.Store(var S: TStream);
var
  Count: Integer;
  OwnerSave: PGraphGroup;

procedure DoPut(P: PGraphView); far;
begin
  S.Put(P);
end;

begin
  GraphView.Store(S);
  OwnerSave := OwnerGroup;
  OwnerGroup := @Self;
  Count := IndexOf(Last);
  S.Write(Count, SizeOf(Word));
  ForEach(@DoPut);
  PutSubViewPtr(S, Current);
  OwnerGroup := OwnerSave;
end;

procedure GraphGroup.Unlock;
begin
  if LockFlag <> 0 then Dec(LockFlag);
end;

function GraphGroup.Valid(Command: Word): Boolean;

function IsInvalid(P: PGraphView): Boolean; far;
begin
  IsInvalid := not P^.Valid(Command);
end;

begin
  Valid := True;
  if Command = cmReleasedFocus then
  begin
    if (Current <> nil) and (Current^.Options and ofValidate <> 0) then
      Valid := Current^.Valid(Command);
  end
  else
    Valid := FirstThat(@IsInvalid) = nil;
end;

{ GraphListViewer }

constructor GraphListViewer.Init(var Bounds: TRect; ANumCols: Word;
  AHScrollBar, AVScrollBar: PGraphScrollBar);
var
  ArStep, PgStep: Integer;
  ItemSize : TPoint;
  i : integer;
begin
  GraphView.Init(Bounds);
  Options := Options or (ofFirstClick + ofSelectable);
  EventMask := EventMask or evBroadcast;
  Range := 0;
  NumCols := ANumCols;
  Focused := 0;
  GetItemSize(ItemSize);
  if AVScrollBar <> nil then
  begin
    if NumCols = 1 then
    begin
      PgStep := (Size.Y div ItemSize.Y) -1;
      ArStep := 1;
    end else
    begin
      PgStep := (Size.Y div ItemSize.Y) * NumCols;
      ArStep := Size.Y div ItemSize.Y;
    end;
    AVScrollBar^.SetStep(PgStep, ArStep);
  end;
  if AHScrollBar <> nil then AHScrollBar^.SetStep(Size.X div NumCols, 1);
  HScrollBar := AHScrollBar;
  VScrollBar := AVScrollBar;
end;

constructor GraphListViewer.Load(var S: TStream);
begin
  GraphView.Load(S);
  GetPeerViewPtr(S, HScrollBar);
  GetPeerViewPtr(S, VScrollBar);
  S.Read(NumCols, SizeOf(Word) * 4);
end;

procedure GraphListViewer.ChangeBounds(var Bounds: TRect);
begin
  GraphView.ChangeBounds(Bounds);
  if HScrollBar <> nil then HScrollBar^.SetStep(Size.X div NumCols, 1);
end;

procedure GraphListViewer.Draw;
var
  I,ColWidth: Integer;
  R : TRect;
begin
  GetExtent(R);
  GFonts.SetTextStyle(SystemFont,HorizDir,1);
  SetFillStyle(SolidFill,GetColor(1));
  if not CanFillBackground then Bar(R);
  DrawItems;
end;

procedure GraphListViewer.DrawItems;
var
   I,J,K,Item : integer;
   ItemSize : TPoint;
   R : TRect;
begin
  GetItemSize(ItemSize);
  K := (Size.Y div ItemSize.Y);
  if (Size.Y mod ItemSize.Y) <> 0 then inc(K);
  for I := 0 to K - 1 do
  begin
    for J := 0 to NumCols-1 do
    begin
      Item := J*K + I + TopItem;
      if Item < Range then DrawItem(Item)
      else begin
         SetFillStyle(SolidFill,GetColor(1));
         GetItemRect(Item,R);
         Bar(R);
      end;
    end;
  end;
end;

procedure GraphListViewer.DrawItem(Item : Integer);
begin
end;

procedure GraphListViewer.FocusItem(Item: Integer);
var
   OldFocused,i : integer;
   R,OldClip : TRect;
   ItemSize : TPoint;
begin
  if Item = Focused then Exit;
  GetItemSize(ItemSize);
  i := (Size.Y div ItemSize.Y);
  if (Size.Y mod ItemSize.Y) <> 0 then inc(i);
  OldFocused := Focused;
  Focused := Item;
  if Item < TopItem then begin
    if NumCols = 1 then TopItem := Item
    else TopItem := Item - Item mod i;
    DrawView;
  end else if Item >= TopItem + (i*NumCols) then
  begin
    if NumCols = 1 then TopItem := Item - i + 1
    else TopItem := Item - Item mod i - (i*(NumCols - 1));
    DrawView;
  end else begin
     RedrawItem(OldFocused);
     RedrawItem(Focused);
  end;
  if VScrollBar <> nil then VScrollBar^.SetValue(Item);
end;

procedure GraphListViewer.FocusItemNum(Item: Integer);
begin
  if Item < 0 then Item := 0
  else if (Item >= Range) and (Range > 0) then Item := Range-1;
  if Range <> 0 then FocusItem(Item);
end;

function GraphListViewer.GetPalette: PPalette;
const
  P: String[Length(CListViewer)] = CListViewer;
begin
  GetPalette := @P;
end;

function GraphListViewer.GetItem(Item: Integer): Pointer;
begin
  Abstract;
end;

procedure GraphListViewer.GetItemSize(var ItemSize : TPoint);
begin
   Abstract;
end;

procedure GraphListViewer.GetItemRect(Item : integer; var Bounds : TRect);
var
   ColWidth,i,j,k : integer;
   R : TRect;
   ItemSize : Tpoint;
begin
   GetItemSize(ItemSize);
   ColWidth := Size.X div NumCols;
   k := (Size.Y div ItemSize.Y);
   if (Size.Y mod ItemSize.Y) <> 0 then inc (k);
   i := (Item - TopItem) div k;
   j := (Item - TopItem) mod k;
   R.Assign(ColWidth*i,ItemSize.Y*j,Colwidth*(i+1),ItemSize.Y*(j+1));
   Bounds.Copy(R);
end;

function GraphListViewer.IsSelected(Item: Integer): Boolean;
begin
  IsSelected := Item = Focused;
end;

procedure GraphListViewer.HandleEvent(var Event: TEvent);
const
  MouseAutosToSkip = 4;
var
  Mouse: TPoint;
  ColWidth: Word;
  OldItem, NewItem: Integer;
  Count: Word;
  ItemSize : TPoint;
  k : integer;
begin
  GraphView.HandleEvent(Event);
  GetItemSize(ItemSize);
  k := Size.Y div ItemSize.Y;
  if (Size.Y mod ItemSize.Y) <> 0 then inc(k);
  if Event.What = evMouseDown then
  begin
    ColWidth := Size.X div NumCols + 1;
    OldItem := Focused;
    MakeLocal(Event.Where, Mouse);
    NewItem := (Mouse.Y div ItemSize.Y) + (k * (Mouse.X div ColWidth)) + TopItem;
    Count := 0;
    repeat
      if NewItem <> OldItem then FocusItemNum(NewItem);
      OldItem := NewItem;
      MakeLocal(Event.Where, Mouse);
      if MouseInView(Event.Where) then
	NewItem := (Mouse.Y div ItemSize.Y) + (k * (Mouse.X div ColWidth)) + TopItem
      else
      begin
        if NumCols = 1 then
	begin
	  if Event.What = evMouseAuto then Inc(Count);
	  if Count = MouseAutosToSkip then
	  begin
	    Count := 0;
	    if Mouse.Y < 0 then NewItem := Focused-1
	    else if Mouse.Y >= Size.Y then NewItem := Focused+1;
	  end;
        end
        else
	begin
	  if Event.What = evMouseAuto then Inc(Count);
	  if Count = MouseAutosToSkip then
	  begin
	    Count := 0;
	    if Mouse.X < 0 then NewItem := Focused-k
	    else if Mouse.X >= Size.X then NewItem := Focused+k
	    else if Mouse.Y < 0 then
	      NewItem := Focused - Focused mod k
	    else if Mouse.Y > Size.Y then
	      NewItem := Focused - Focused mod k + k - 1;
	  end
        end;
      end;
    until not MouseEvent(Event, evMouseMove + evMouseAuto);
    if Event.Double and (Range > Focused) then SelectItem(Focused);
    ClearEvent(Event);
  end
  else if Event.What = evKeyDown then
  begin
    if (Event.CharCode = ' ') and (Focused < Range) then
    begin
      SelectItem(Focused);
      NewItem := Focused;
    end
    else case CtrlToArrow(Event.KeyCode) of
      kbUp: NewItem := Focused - 1;
      kbDown: NewItem := Focused + 1;
      kbRight: if NumCols > 1 then NewItem := Focused + k else Exit;
      kbLeft: if NumCols > 1 then NewItem := Focused - k else Exit;
      kbPgDn: NewItem := Focused + k * NumCols;
      kbPgUp: NewItem := Focused - k * NumCols;
      kbHome: NewItem := TopItem;
      kbEnd: NewItem := TopItem + k * NumCols - 1;
      kbCtrlPgDn: NewItem := Range - 1;
      kbCtrlPgUp: NewItem := 0;
    else
      Exit;
    end;
    FocusItemNum(NewItem);
    ClearEvent(Event);
  end else if Event.What = evBroadcast then
    if Options and ofSelectable <> 0 then
      if (Event.Command = cmScrollBarClicked) and
         ((Event.InfoPtr = HScrollBar) or (Event.InfoPtr = VScrollBar)) then
        Select
      else if (Event.Command = cmScrollBarChanged) then
      begin
        if (VScrollBar = Event.InfoPtr) then
        begin
          if Focused <> VScrollBar^.Value then FocusItemNum(VScrollBar^.Value);
        end else if (HScrollBar = Event.InfoPtr) then DrawView;
      end;
end;

procedure GraphListViewer.RedrawItem(Item : integer);
var
   R,OldClip : TRect;
begin
   if Owner = nil then Exit;
   GetItemRect(Item,R);
   R.Move(Origin.X,Origin.Y);
   OldClip.Copy(owner^.Clip);
   Owner^.Clip.Intersect(R);
   DrawView;
   Owner^.Clip.Copy(OldClip);
end;

procedure GraphListViewer.SelectItem(Item: Integer);
begin
  Message(Owner, evBroadcast, cmListItemSelected, @Self);
end;

procedure GraphListViewer.SetRange(ARange: Integer);
begin
  Range := ARange;
  if VScrollBar <> nil then
  begin
    if Focused > ARange then Focused := 0;
    TopItem := Focused;
    VScrollbar^.SetParams(Focused, 0, ARange-1, VScrollBar^.PgStep,
      VScrollBar^.ArStep);
  end;
end;

procedure GraphListViewer.SetState(AState: Word; Enable: Boolean);
begin
  GraphView.SetState(AState, Enable);
  if AState and sfFocused <> 0 then
    RedrawItem(Focused);
end;

procedure GraphListViewer.Store(var S: TStream);
begin
  GraphView.Store(S);
  PutPeerViewPtr(S, HScrollBar);
  PutPeerViewPtr(S, VScrollBar);
  S.Write(NumCols, SizeOf(Word) * 4);
end;


{ GraphScrollBar }

{ internally used objects}
type

   PIndicator = ^Indicator;
   Indicator = object(GraphView)
      constructor Init(var Bounds : TRect);
      procedure Draw; virtual;
      function GetPalette : PPalette; virtual;
      procedure HandleEvent(var Event : TEvent); virtual;
   end;

   PFoot = ^Foot;
   Foot = object(GraphView)
      constructor Init(var Bounds : TRect);
      procedure Draw; virtual;
      function GetPalette : PPalette; virtual;
      procedure HandleEvent(var Event : TEvent); virtual;
   end;

   PArrow = ^Arrow;
   Arrow = object(GraphBitmapButton)
      constructor Init(var Bounds : TRect; AName : TTitleStr;
                       ACommand : word; AFlags : word);
      procedure DrawState(Pushed : boolean); virtual;
      procedure HandleEvent(var Event : TEvent); virtual;
   end;

const
   cmEnableArrowS  = 68;
   cmDisableArrows = 69;
   cmLeftArrow  = 70;
   cmRightArrow = 71;
   cmPageLeft   = 72;
   cmPageRight  = 73;
   cmUpArrow    = 74;
   cmDownArrow  = 75;
   cmPageUp     = 76;
   cmPageDown   = 77;
   cmIndicatorMoved = 78;
   cmSBValueChanged = 79;

const

{ Controls registration records }

  RIndicator: TStreamRec = (
     ObjType: 6;
     VmtLink: Ofs(TypeOf(Indicator)^);
     Load:    @Indicator.Load;
     Store:   @Indicator.Store
  );

  RFoot: TStreamRec = (
     ObjType: 7;
     VmtLink: Ofs(TypeOf(Foot)^);
     Load:    @Foot.Load;
     Store:   @Foot.Store
  );

  RArrow: TStreamRec = (
     ObjType: 8;
     VmtLink: Ofs(TypeOf(Arrow)^);
     Load:    @Arrow.Load;
     Store:   @Arrow.Store
  );


{ methods for GraphScrollBar internal objects}

constructor Indicator.Init(var Bounds : TRect);
begin
   GraphView.Init(Bounds);
   DragMode := dmLimitAll;
   EventMask := EventMask or evBroadcast;
end;

procedure Indicator.Draw;
var
   R,R1 : TRect;
begin
   SetFillStyle(SolidFill,GetColor(1));
   GetExtent(R);
   SetColor(GetColor(1));
   Bar(R);
   with R do begin
      R1.Assign(A.X,A.Y,B.X,A.Y+1);
      SetColor(GetColor(2));
      Line(R1);
      R1.Assign(A.X,A.Y,A.X+1,B.Y);
      Line(R1);
      SetColor(GetColor(3));
      R1.Assign(A.X,B.Y-1,B.X,B.Y);
      Line(R1);
      R1.Assign(B.X-1,A.Y,B.X,B.Y);
      Line(R1);
      if Size.X > Size.Y then
         R1.Assign(Size.X div 2 -1,A.Y+1,Size.X div 2,B.Y-1)
      else R1.Assign(A.X+1,Size.Y div 2-1,B.X-1,Size.Y div 2);
      SetColor(GetColor(3));
      Line(R1);
      if Size.X > Size.Y then R1.Move(1,0)
      else R1.Move(0,1);
      SetColor(GetColor(2));
      Line(R1);
   end;
end;

function Indicator.GetPalette : PPalette;
const
   P : String[Length(CIndicator)] = CIndicator;
begin
   GetPalette := @P;
end;

procedure Indicator.HandleEvent(var Event : TEvent);
var
   R : TRect;
   Mouse : TPoint;
   Limits : TRect;
   Min,Max : TPoint;
   P : integer;
begin
   GraphView.HandleEvent(Event);
   if Event.What = evMouseDown then begin
      GetExtent(R);
      MakeLocal(Event.Where,Mouse);
      if R.Contains(Mouse) then begin
         Owner^.GetExtent(Limits);
         if PGraphScrollBar(Owner)^.Vertical then begin
            Limits.Grow(-1,-Owner^.Size.X-1);
         end else begin
            Limits.Grow(-Owner^.Size.Y-1,-1);
         end;
         SizeLimits(Min,Max);
         DragView(Event, DragMode or dmDragMove, Limits, Min, Max,true);
         Message(Owner,evBroadcast,cmIndicatorMoved,@Self);
         ClearEvent(Event);
      end;
   end else
   if (Event.What = evBroadcast) and (Event.Command = cmSBValueChanged)
   then begin
      P := PGraphScrollBar(Owner)^.GetPos;
      PGraphScrollBar(Owner)^.GetActiveRect(R);
      if PGraphScrollBar(Owner)^.Vertical then R.Move(0,P-Size.Y div 2)
      else R.Move(P-Size.X div 2 ,0);
      R.B.X := R.A.X + Size.X;
      R.B.Y := R.A.Y + Size.Y;
      Locate(R);
      ClearEvent(Event);
   end;
end;

constructor Foot.Init(var Bounds : TRect);
begin
   GraphView.Init(Bounds);
   if Size.Y > Size.X then
      GrowMode := gfGrowHiY
   else
      GrowMode := gfGrowHiX;
end;

procedure Foot.Draw;
var
   Bounds,R : TRect;
begin
   SetFillStyle(SolidFill,GetColor(1));
   GetExtent(Bounds);
   Bar(Bounds);
   BicolorRectangle(Bounds,GetColor(2),GetColor(3),true);
   with Bounds do begin
      if Size.X > Size.Y then R.Assign(A.X+Size.Y,A.Y+1,A.X+Size.Y+1,B.Y-1)
      else R.Assign(A.X+1,A.Y+Size.X,B.X-1,A.Y+Size.X+1);
      SetColor(GetColor(3));
      Line(R);
      if Size.X > Size.Y then R.Move(-1,0)
      else R.Move(0,-1);
      SetColor(GetColor(2));
      Line(R);
      if Size.X > Size.Y then R.Assign(B.X-Size.Y,A.Y+1,B.X-Size.Y+1,B.Y-1)
      else R.Assign(A.X+1,B.Y-Size.X,B.X-1,B.Y-Size.X+1);
      SetColor(GetColor(3));
      Line(R);
      if Size.X > Size.Y then R.Move(-1,0)
      else R.Move(0,-1);
      SetColor(GetColor(2));
      Line(R);
   end;
end;

function Foot.GetPalette : PPalette;
const
   P : String[Length(CFoot)] = CFoot;
begin
   GetPalette := @P;
end;

procedure Foot.HandleEvent(var Event : TEvent);
var
   Mark,P : integer;
   Command : word;
   Mouse : TPoint;
begin
   GraphView.HandleEvent(Event);
   case Event.What of
      evMouseDown :
         begin
            MakeLocal(Event.Where,Mouse);
            P := PGraphScrollBar(Owner)^.GetPos;
            if PGraphScrollBar(Owner)^.Vertical then begin
               Mark := Mouse.Y;
               inc(P,Size.X);
            end else begin
               Mark := Mouse.X;
               inc(P,Size.Y);
            end;
            if Mark < P then begin
               if PGraphScrollBar(Owner)^.Vertical then Command := cmPageUp
               else Command := cmPageLeft;
            end else begin
               if PGraphScrollBar(Owner)^.Vertical then Command := cmPageDown
               else Command := cmPageRight;
            end;
            Message(Owner,evBroadcast,Command,@Self);
            ClearEvent(Event);
         end;
   end;
end;

{ Arrow methods}

constructor Arrow.Init(var Bounds : TRect; AName : TTitleStr; ACommand : word;
                  AFlags : word);
begin
   GraphBitmapButton.Init(Bounds,AName,ACommand,AFlags);
   State := State or sfDisabled;
end;

procedure Arrow.DrawState(Pushed : boolean);
var
  WorkImage : integer;
   R : TRect;
   P : pointer;
begin
   if Images = nil then Exit;
   if Pushed then WorkImage := 1 else WorkImage := 0;
   if State and sfDisabled <> 0 then inc(WorkImage,2);
   GetExtent(R);
   P := Images^.At(WorkImage);
   DrawImg(R.A,PImage(P),NormalPut);
end;

procedure Arrow.HandleEvent(var Event : TEvent);
begin
   if (Event.What = evBroadcast) and (Event.Command = cmCommandSetChanged)
   then Exit;
   GraphButton.HandleEvent(Event);
   if (Event.What = evBroadcast) then begin
      case Event.Command  of
         cmEnableArrows: SetState(sfDisabled, false);
         cmDisableArrows: SetState(sfDisabled, true);
      end;
   end;
end;

constructor GraphScrollBar.Init(var Bounds: TRect);
var
   R,R1 : TRect;
   Command : word;
   C : string;
   Button : PGraphButton;
begin
   GraphGroup.Init(Bounds);
   Value := 0;
   Min := 0;
   Max := 0;
   PgStep := 1;
   ArStep := 1;
   if Size.X < Size.Y then Vertical := true;
   Options := Options and not ofSelectable;
   GetExtent(R1);
   Insert(New(PFoot,Init(R1)));
   if Vertical then begin
      with R1 do R.Assign(A.X,A.Y,B.X,A.Y+Size.X);
      Command := cmUpArrow;
      C := 'UP'
   end else begin
      with R1 do R.Assign(A.X,A.Y,A.X+Size.Y,B.Y);
      Command := cmLeftArrow;
      C := 'LEFT';
  end;
   R.Grow(-1,-1);
   Insert(New(PArrow,Init(R,C,Command,bfNormal+bfBroadcast+bfAuto)));
   if Vertical then begin
      with R1 do R.Assign(A.X,B.Y-Size.X,B.X,B.Y);
      Command := cmDownArrow;
      C := 'DOWN';
   end else begin
      with R1 do R.Assign(B.X-Size.Y,A.Y,B.X,B.Y);
      Command := cmRightArrow;
      C := 'RIGHT';
   end;
   R.Grow(-1,-1);
   Button := New(PArrow,Init(R,C,Command,bfNormal+bfBroadcast+bfAuto));
   if Vertical then begin
      Button^.GrowMode := gfGrowHiY + gfGrowLoY;
      with R1 do R.Assign(A.X,A.Y+Size.X,B.X,A.Y + 3*Size.X)
   end else begin
      Button^.GrowMode := gfGrowHiX + gfGrowLoX;
      with R1 do R.Assign(A.X+Size.Y,A.Y,A.X+3*Size.Y,B.Y);
   end;
   Insert(Button);
   R.Grow(-1,-1);
   Insert(New(PIndicator,Init(R)));
end;

constructor GraphScrollBar.Load(var S : TStream);
begin
   GraphGroup.Load(S);
   S.Read(Value, 5*SizeOf(Integer));
   S.Read(Vertical,SizeOf(Boolean));
end;

procedure GraphScrollBar.GetActiveRect(var Bounds : TRect);
begin
   GetExtent(Bounds);
   if Vertical then
      Bounds.Grow(-1,-(2 *Size.X))
   else
      Bounds.Grow(-(2*Size.Y),-1);
end;

function GraphScrollBar.GetPalette : PPalette;
const
   P : String[Length(CScrollBar)] = CScrollBar;
begin
   GetPalette := @P;
end;

function GraphScrollBar.GetPos: Integer;
var
  R: Integer;
  R1 : TRect;
  S : integer;
begin
  R := Max - Min;
  if R = 0 then
    GetPos := 0 else
    begin
      S := GetSize;
      GetPos := LongDiv(LongMul(Value - Min, S) + R shr 1, R);
    end;
end;

function GraphScrollBar.GetSize : integer;
var
   R1 : TRect;
begin
   GetActiveRect(R1);
   if Vertical then with R1 do GetSize := B.Y - A.Y
   else with R1 do GetSize := B.X - A.X;
end;

procedure GraphScrollBar.HandleEvent(var Event: TEvent);
var
  V,P, S : Integer;
  Mouse: TPoint;
  Extent,R: TRect;
  E : TEvent;

procedure Clicked(MoveIndicator : boolean);
begin
  Message(Owner, evMessage{evBroadcast}, cmScrollBarClicked, @Self);
  if MoveIndicator then Message(@Self,evBroadcast,cmSBValueChanged,@Self);
end;

begin
  GraphGroup.HandleEvent(Event);
  case Event.What of
    evMessage:
       case Event.Command of
          cmLeftArrow,
          cmUpArrow    :
             begin
                SetValue(Value - ArStep);
                Clicked(true);
                ClearEvent(Event);
             end;
          cmRightArrow,
          cmDownArrow  :
             begin
                SetValue(Value + ArStep);
                Clicked(true);
                ClearEvent(Event);
             end;
       end;
    evBroadcast:
       case Event.Command of
          cmPageUp,
          cmPageLeft :
             begin
                SetValue(Value - PgStep);
                Clicked(true);
                ClearEvent(Event);
             end;
          cmPageDown,
          cmPageRight :
             begin
                SetValue(Value + PgStep);
                Clicked(true);
                ClearEvent(Event);
             end;
          cmIndicatorMoved :
            begin
               PGraphView(Event.InfoPtr)^.GetBounds(Extent);
               S := GetSize;
               GetActiveRect(R);
               with Extent do begin
                  if Vertical then P := A.Y + (B.Y-A.Y) div 2 - R.A.Y
                  else P := A.X + (B.X-A.X) div 2 - R.A.X;
               end;
               V := LongDiv(LongMul(P,Max-Min)+ S shr 1, S+1)+ Min;
               SetValue(V);
               S := GetPos;
               Clicked(P <> S);
               ClearEvent(Event);
            end;
          cmScrollBarChanged :
               if Event.InfoPtr = @Self then
               Message(@Self,evBroadcast,cmSBValueChanged,@Self);
       end;
    evKeyDown:
      if State and sfVisible <> 0 then
      begin
        if not Vertical then
          case CtrlToArrow(Event.KeyCode) of
            kbLeft:
               begin
                  E.What := evMessage;
                  E.Command := cmLeftArrow;
               end;
            kbRight:
               begin
                  E.What := evMessage;
                  E.Command := cmRightArrow;
               end;
            kbCtrlLeft:
               begin
                  E.What := evBroadcast;
                  E.Command := cmPageLeft;
               end;
            kbCtrlRight:
               begin
                  E.What := evBroadcast;
                  E.Command := cmPageRight;
               end;
            kbHome:
               begin
                  SetValue(Min);
                  Clicked(true);
                  ClearEvent(Event);
                  Exit;
               end;
            kbEnd:
               begin
                  SetValue(Max);
                  Clicked(true);
                  ClearEvent(Event);
                  Exit;
               end;
          else
            Exit;
          end
        else
          case CtrlToArrow(Event.KeyCode) of
            kbUp:
               begin
                  E.What := evMessage;
                  E.Command := cmUpArrow;
               end;
            kbDown:
               begin
                  E.What := evMessage;
                  E.Command := cmDownArrow;
               end;
            kbPgUp:
               begin
                  E.What := evBroadcast;
                  E.Command := cmPageUp;
               end;
            kbPgDn:
               begin
                  E.What := evBroadcast;
                  E.Command := cmPageDown;
               end;
            kbCtrlPgUp:
               begin
                  SetValue(Min);
                  Clicked(true);
                  ClearEvent(Event);
                  Exit;
               end;
            kbCtrlPgDn:
               begin
                  SetValue(Max);
                  Clicked(true);
                  ClearEvent(Event);
                  Exit;
               end;
          else
            Exit;
          end;
        Message(@Self,E.What,E.Command,nil);
        ClearEvent(Event);
      end;
  end;
end;

procedure GraphScrollBar.ScrollDraw;
begin
  Message(Owner, evBroadcast, cmScrollBarChanged, @Self);
end;

procedure GraphScrollBar.SetParams(AValue, AMin, AMax, APgStep,
  AArStep: Integer);
var
  SValue: Integer;
begin
  if AMax < AMin then AMax := AMin;
  if AValue < AMin then AValue := AMin;
  if AValue > AMax then AValue := AMax;
  SValue := Value;
  if (SValue <> AValue) then Value := AValue;
  if (Min <> AMin) or (Max <> AMax) then begin
    Min := AMin;
    Max := AMax;
    SetState(sfDisabled, Min = Max);
  end;
  PgStep := APgStep;
  ArStep := AArStep;
  ScrollDraw;
end;

procedure GraphScrollBar.SetRange(AMin, AMax: Integer);
begin
  SetParams(Value, AMin, AMax, PgStep, ArStep);
end;

procedure GraphScrollBar.SetStep(APgStep, AArStep: Integer);
begin
  SetParams(Value, Min, Max, APgStep, AArStep);
end;

procedure GraphScrollBar.SetState(AState : word; Enable : boolean);
begin
   GraphGroup.SetState(AState,Enable);
   if AState and sfDisabled <> 0 then begin
      if Enable then Message(@Self,evBroadcast,cmDisableArrows,@Self)
      else Message(@Self,evBroadcast,cmEnableArrows,@Self);
   end;
end;

procedure GraphScrollBar.SetValue(AValue: Integer);
begin
  SetParams(AValue, Min, Max, PgStep, ArStep);
end;

procedure GraphScrollBar.Store(var S : TStream);
begin
   GraphGroup.Store(S);
   S.Write(Value, 5*SizeOf(Integer));
   S.Write(Vertical,SizeOf(Boolean));
end;

{ internally used objects}

type

{ window frame}

  PGraphFrame = ^GraphFrame;
  GraphFrame = object(GraphView)
    Place : boolean;
    Thick : boolean;
    constructor Init(var Bounds: TRect; AThick,CaptionPlace : boolean);
    constructor Load(var S : TStream);
    procedure ChangeMouseCursor; virtual;
    procedure Draw; virtual;
    function Getpalette : PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function MouseInView(Mouse : TPoint) : boolean; virtual;
    procedure Store(var S : TStream);
    private
    FrameCursors : array [0..1] of PMouseCursor;
    procedure LoadCursors;
  end;

{ window title bar}

   PGraphTitleBar = ^GraphTitleBar;
   GraphTitleBar = object(GraphView)
      constructor Init(var Bounds : TRect);
      constructor Load(var S : TStream);
      procedure ChangeMouseCursor; virtual;
      procedure Draw; virtual;
      function GetPalette : PPalette; virtual;
      procedure HandleEvent(var Event : TEvent); virtual;
      procedure SetState(AState : word; Enable : boolean); virtual;
      private
      TitleCursor : PMouseCursor;
   end;

{ window Close button}

  PCloseButton = ^CloseButton;
  CloseButton = object(GraphButton)
     constructor Init(var Bounds: TRect; ATitle : TTitleStr; ACommand: Word; AFlags: Word);
     procedure DrawState(Pushed : boolean); virtual;
     function GetPalette : PPalette; virtual;
  end;

  PZoomButton = ^ZoomButton;
  ZoomButton = object(GraphBitmapButton)
     constructor Init(var Bounds : TRect; ATitle : TTitleStr; ACommand : word;
                      AFlags : word);
     procedure DrawState(Pushed : boolean); virtual;
  end;

  PWindowWorkspace = ^WindowWorkspace;
  WindowWorkspace = object(GraphGroup)
     constructor Init(var Bounds : TRect);
     procedure HandleEvent(var Event : TEvent); virtual;
  end;

const

{ Internal objects registration records }

   RGraphFrame : TStreamRec = (
     ObjType: 10;
     VmtLink: Ofs(TypeOf(GraphFrame)^);
     Load:    @GraphFrame.Load;
     Store:   @GraphFrame.Store
  );

  RGraphTitleBar : TStreamRec = (
     ObjType: 11;
     VmtLink: Ofs(TypeOf(GraphTitleBar)^);
     Load:    @GraphTitleBar.Load;
     Store:   @GraphTitleBar.Store
  );

  RCloseButton : TStreamRec = (
     ObjType: 12;
     VmtLink: Ofs(TypeOf(CloseButton)^);
     Load:    @CloseButton.Load;
     Store:   @CloseButton.Store
  );

{
  RZoomButton : TStreamRec = (
}

  RWindowWorkSpace : TStreamrec = (
     ObjType: 14;
     VmtLink: Ofs(TypeOf(WindowWorkSpace)^);
     Load:    @WindowWorkSpace.Load;
     Store:   @WindowWorkSpace.Store
  );

{ metods for internal object}

{ GraphFrame metods}

constructor GraphFrame.Init(var Bounds: TRect; AThick,CaptionPlace : boolean);
begin
  GraphView.Init(Bounds);
  Place := CaptionPlace;
  Thick := AThick;
  GrowMode := gfGrowHiX + gfGrowHiY;
  EventMask := EventMask or evBroadcast;
  LoadCursors;
end;

constructor GraphFrame.Load(var S : TStream);
begin
  GraphView.Load(S);
  S.Read(Place,2*SizeOf(Place));
  LoadCursors;
end;

procedure GraphFrame.ChangeMouseCursor;
var
   Mouse : TPoint;
   R,R1 : TRect;
   i : integer;
begin
   if (Owner^.State and sfActive <> 0) and
      (Owner^.Options and ofResizeable <> 0) then
   begin
      i := -1;
      GetExtent(R);
      MakeLocal(MouseWhere,Mouse);
      R1.Assign(R.A.X,R.A.Y+12,R.A.X+6,R.B.Y-12);
      if R1.Contains(Mouse) then i := 0 else
      begin
         R1.Assign(R.B.X-6,R.A.Y+12,R.B.X,R.B.Y-12);
         if R1.Contains(Mouse) then i := 0 else
         begin
            R1.Assign(R.A.X+12,R.A.Y,R.B.X-12,R.A.Y+6);
            if R1.Contains(Mouse) then i := 1 else
            begin
               R1.Assign(R.A.X+12,R.B.Y-6,R.B.X-12,R.B.Y);
               if R1.Contains(Mouse) then i := 1;
            end;
         end;
      end;
      if i <> -1 then begin
         if FrameCursors[i] <> nil then begin
            FrameCursors[i]^.MakeActive;
            MouseOwner := @Self;
         end;
      end;
   end else if StdMouseCursor <> nil then StdMouseCursor^.MakeActive;

end;

procedure GraphFrame.Draw;
var
  CFrame1,CFrame2,CFrame3 : Word;
  R,R1 : TRect;
begin
  if (Owner = nil) then
		Exit;
  GetBounds(R);
  GrDriver.SetWriteMode(NormalPut);
  if (State and sfActive <> 0) then
	  begin
	  CFrame1 := GetColor(1);
	  CFrame2 := GetColor(2);
	  CFrame3 := GetColor(3);
	  end
	  else
	  begin
	  CFrame1 := GetColor(4);
	  CFrame2 := GetColor(5);
	  CFrame3 := GetColor(6);
	  end;
  SetLineStyle(SolidLn,0,NormWidth);
{  BiColorRectangle(R,CFrame2,CFrame3,false);} { Namesto Ova }
	SetColor(CFrame1);{ Ova }
	R1.Assign(R.A.X,R.A.Y,R.B.X,R.A.Y);
	line(R1);
	R1.Assign(R.A.X,R.A.Y,R.A.X,R.B.Y);
	line(R1);
	SetColor(CFrame2);
	R1.Assign(R.A.X+1,R.A.Y+1,R.B.X,R.A.Y+1);
	line(R1);
	R1.Assign(R.A.X+1,R.A.Y+1,R.A.X+1,R.B.Y);
	line(R1);
	SetColor(0);
	R1.Assign(R.B.X-1,R.A.Y-1,R.B.X-1,R.B.Y-1);
	line(R1);
	R1.Assign(R.A.X-1,R.B.Y-1,R.B.X,R.B.Y-1);
	line(R1);
	SetColor(CFrame3);
	R1.Assign(R.B.X-2,R.A.Y+1,R.B.X-2,R.B.Y-1);
	line(R1);
	R1.Assign(R.A.X+1,R.B.Y-2,R.B.X-2,R.B.Y-2);
	line(R1);{ Ova }

  if (Thick) then
	  begin
	  R.Grow(-3,-3); {Ovde beshe (-2,-2) }
	  SetColor(CFrame1);
	  SetLineStyle(SolidLn,0,ThickWidth);
	  Rectangle(R);
	  end;
  if (Place) then
	  begin
	  R1.Copy(R);
	  R1.B.Y := R1.A.Y + Captionheight+2 ;
	  SetFillStyle(SolidFill,CFrame1);
	  Bar(R1);
	  inc(R.A.Y,CaptionHeight);
	  end;
  if (Thick) then
	  R.Grow(-2,-2)
	  else
	  R.Grow(-1,-1);
  SetLineStyle(SolidLn,0,NormWidth);
  BicolorRectangle(R,CFrame2,CFrame3,True);
end;

function GraphFrame.GetPalette : PPalette;
const
  P: String[Length(CFrame)] = CFrame;
begin
  GetPalette := @P;
end;

procedure GraphFrame.HandleEvent(var Event: TEvent);
var
  Mouse: TPoint;
  R : TRect;

procedure DragWindow(Mode: Byte);

var
  Limits: TRect;
  Min, Max: TPoint;
  R : TRect;

begin
  Owner^.Owner^.GetExtent(Limits);
  Owner^.SizeLimits(Min, Max);
  Owner^.DragView(Event, Owner^.DragMode or Mode, Limits, Min, Max, false);
  ClearEvent(Event);
end;

begin
  GraphView.HandleEvent(Event);
  if (Event.What = evMouseDown) and (State and sfActive <> 0) then
  begin
    if MouseInView(Event.Where) then
    if Owner^.Options and ofResizeable <> 0 then
    DragWindow(dmDragGrow);
  end;
end;

procedure GraphFrame.LoadCursors;
begin
   FrameCursors[0] := PMouseCursor(StdSharedresource^.Get('RESIZEHOR'));
   FrameCursors[1] := PMouseCursor(StdSharedresource^.Get('RESIZEVERT'));
end;

function GraphFrame.MouseInView(Mouse : TPoint) : boolean;
var
   R : TRect;
begin
   MouseInView := false;
   GetExtent(R);
   MakeLocal(Mouse, Mouse);
   if R.Contains(Mouse) then begin
      R.Grow(-6,-6);
      MouseInView := not R.Contains(Mouse);
   end;
end;

procedure GraphFrame.Store(var S : TStream);
begin
   GraphView.Store(S);
   S.Write(Place,2*SizeOf(Place));
end;

{ GraphTitleBar metods}

constructor GraphTitleBar.Init(var Bounds : TRect);
begin
   GraphView.Init(Bounds);
   GrowMode := gfGrowHiX;
   Options := Options and not ofSelectable;
   TitleCursor := PMouseCursor(StdSharedresource^.Get('MOVE'));
end;

constructor GraphTitleBar.Load(var S : TStream);
begin
   GraphView.Load(S);
   TitleCursor := PMouseCursor(StdSharedresource^.Get('MOVE'));
end;

procedure GraphTitleBar.ChangeMouseCursor;
begin
   if (State and sfActive <> 0) and
   (Owner^.Options and ofMoveAble <> 0) then
   begin
      if TitleCursor <> nil then TitleCursor^.MakeActive;
      MouseOwner := @Self;
   end else if StdMouseCursor <> nil then StdMouseCursor^.MakeActive;
end;

procedure GraphTitleBar.Draw;
var
   R : TRect;
   P : TPoint;
   BarColor,TextColor : word;
   L : integer;
   S : String;
begin
   if Owner = nil then Exit;
   GetExtent(R);
   GFonts.SetTextStyle(SystemFont,HorizDir,1);
   SetTextJustify(LeftText,CenterText);
   if State and sfActive = 0 then begin
      BarColor := GetColor(3);
      TextColor := GetColor(4);
   end else begin
      BarColor := GetColor(1);
      TextColor := GetColor(2);
   end;
   SetFillStyle(SolidFill,BarColor);
   Bar(R);
   SetColor(TextColor);
   with R do L := (B.X - A.X) div 8;
   if Owner <> nil then S := PGraphWindow(Owner)^.GetTitle(L) else S := '';
   if Length(S) > L then P.X := 0
   else P.X := R.A.X + ((L - Length(S)) div 2 * 8);
   with R do P.Y := A.Y + (B.Y - A.Y) div 2;
   WriteTextXY(P,S);
end;

function GraphTitleBar.GetPalette : PPalette;
const
   P : string[Length(CTitleBar)] = CTitleBar;
begin
   GetPalette := @P;
end;

procedure GraphTitleBar.HandleEvent(var Event : TEvent);
var
  Limits: TRect;
  Min, Max: TPoint;
begin
   GraphView.HandleEvent(Event);
   case Event.What of
       evMouseDown :
          if MouseInView(Event.Where) and (State and sfActive <> 0) then
          if Owner^.Options and ofMoveAble <> 0 then begin
             Owner^.Owner^.GetExtent(Limits);
             Owner^.SizeLimits(Min, Max);
             Owner^.DragView(Event, Owner^.DragMode or dmDragMove,
                             Limits, Min, Max, false);
             ClearEvent(Event);
          end;
   end;
end;

procedure GraphTitleBar.SetState(AState : word; Enable : boolean);
begin
   GraphView.SetState(AState,Enable);
   if (AState and sfActive <> 0) and not Enable then
      DrawView;
end;

{ CloseButton method}

constructor CloseButton.Init(var Bounds: TRect; ATitle : TTitleStr; ACommand: Word; AFlags: Word);
begin
   GraphButton.Init(Bounds,ATitle,ACommand,AFlags);
   Options := Options and not ofSelectable;
end;

procedure CloseButton.DrawState(Pushed : boolean);
var
	R,R1 : TRect;
	BorderColor,ButtonColor,
	TextColor : word;
begin
	If (State and sfDisabled <> 0) Then
		begin
		ButtonColor := GetColor(1);
		TextColor := GetColor(5);
		end
		else
		begin
		ButtonColor := GetColor(1);
		TextColor := GetColor(4);
		end;
	GetExtent(R);
	SetFillStyle(SolidFill,ButtonColor);
	Bar(R);
	SetColor(GetColor(3));
	SetLineStyle(SolidLn,0,NormWidth);
	Rectangle(R);
	If (Pushed) Then
		Begin
		SetColor(GetColor(3));
		With R Do
			Begin
			R1.Assign(A.X,B.Y-1,B.X,B.Y);
			Line(R1);
			R1.Assign(B.X-1,A.Y,B.X,B.Y);
			Line(R1);
			R.Move(1,1);
			End;
		End
		Else
		Begin
		SetColor(GetColor(2));
		With R Do
			Begin
			R1.Assign(A.X,A.Y,A.X+1,B.Y-1);
			Line(R1);
			R1.Assign(A.X,A.Y,B.X-1,A.Y+1);
			Line(R1);
		End;
	End;
	SetColor(TextColor);
	R1.Copy(R);
	R1.Grow(-4,-4);
	Line(R1);
	With R1 Do
		R.Assign(B.X,A.Y,A.X,B.Y);
	Line(R);
end;

function CloseButton.GetPalette : PPalette;
const
	P : String[Length(CCloseButton)] = CCloseButton;
begin
   GetPalette := @P;
end;

{ ZoomButton methods }

constructor ZoomButton.Init(var Bounds : TRect; ATitle : TTitleStr;
                       ACommand : word; AFlags : word);
begin
   GraphBitmapButton.Init(Bounds,ATitle,ACommand,AFlags);
   GrowMode := gfGrowLoX + gfGrowHiX;
   Options := Options and not ofSelectable;
end;

procedure ZoomButton.DrawState(Pushed : boolean);
var
   WorkImage : integer;
   R : TRect;
   P : pointer;
begin
   if Images = nil then Exit;
   if Pushed then WorkImage := 1 else
   if State and sfDisabled <> 0 then WorkImage := 2 else WorkImage := 0;
   if Owner <> nil then with PGraphWindow(Owner)^ do
     if Longint(Size) = Longint(Owner^.Size) then inc(WorkImage,3);
   GetExtent(R);
   P := Images^.At(WorkImage);
   DrawImg(R.A,PImage(P),NormalPut);
end;

{ WindowWorkSpace metod}

constructor WindowWorkspace.Init(var Bounds : TRect);
var
   R : TRect;
begin
   GraphGroup.Init(Bounds);
   GrowMode := gfGrowHiX + gfGrowHiY;
   Options := Options or ofFirstClick;
   GetExtent(R);
   Insert(New(PGraphBackground,Init(R,SolidFill,bsUpper)));
end;

procedure WindowWorkspace.HandleEvent(var Event : TEvent);
begin
   if Event.What = evMessage then begin
      with Event do Message(Owner,evBroadcast,Command,InfoPtr);
      Exit;
   end;
   GraphGroup.HandleEvent(Event);
end;

{ GraphWindow }

constructor GraphWindow.Init(var Bounds: TRect; ATitle : TTitleStr;
                             AFlags : word);
var
   R : TRect;
begin
  GraphGroup.Init(Bounds);
  Options := Options or (ofSelectable + ofTopSelect);
  GrowMode := gfGrowAll + gfGrowRel;
  Title := NewStr(ATitle);
  Flags := AFlags;
  Palette := wpGrayWindow;
  if Flags and wfFramed <> 0 then InitFrame;
  if Flags and wfTitle <> 0 then InitCaption;
  if Flags and wfGrow <> 0 then Options := Options or ofResizeable;
  if Flags and wfMove <> 0 then Options := Options or ofMoveable;
  InitWorkspace;
  GetBounds(ZoomRect);
end;

destructor GraphWindow.Done;
begin
   DisposeStr(Title);
   GraphGroup.Done;
end;

constructor GraphWindow.Load(var S: TStream);
var
  FrameIdent: Word;
begin
  GraphGroup.Load(S);
  S.Read(Flags, SizeOf(Byte) + SizeOf(TRect) + SizeOf(Integer));
  GetSubViewPtr(S, Frame);
  GetSubViewPtr(S,WorkSpace);
  GetSubViewPtr(S,Caption);
  Title := S.ReadStr;
end;

procedure GraphWindow.Close;
begin
  if Valid(cmClose) then Free;
end;

function GraphWindow.GetPalette : PPalette;
const
  P: array[wpBlueWindow..wpGrayWindow] of string[Length(CBlueWindow)] =
    (CBlueWindow, CCyanWindow, CGrayWindow);
begin
  GetPalette := @P[Palette];
end;

function GraphWindow.GetTitle(MaxSize: Integer): TTitleStr;
begin
  if Title <> nil then GetTitle := Title^
  else GetTitle := '';
end;

procedure GraphWindow.HandleEvent(var Event: TEvent);
var
  Limits: TRect;
  Min, Max: TPoint;
begin
  if (Event.What = evBroadcast) and (Event.Command = cmCommandSetChanged)
     and (Event.InfoPtr <> @Self) then Exit;
  GraphGroup.HandleEvent(Event);
  if (Event.What = evCommand) then
    case Event.Command of
      cmResize:
        if Options and (ofMoveable + ofResizeable) <> 0 then
        begin
          Owner^.GetExtent(Limits);
          SizeLimits(Min, Max);
          DragView(Event, DragMode or (Flags and (wfMove + wfGrow)),
                   Limits, Min, Max, false);
          ClearEvent(Event);
        end;
      cmClose:
        begin
          ClearEvent(Event);
          if State and sfModal = 0 then Close else
          begin
            Event.What := evCommand;
            Event.Command := cmCancel;
            PutEvent(Event);
            ClearEvent(Event);
          end;
        end;
      cmZoom:
        begin
          Zoom;
          ClearEvent(Event);
        end;
    end
  else if Event.What = evKeyDown then
    case Event.KeyCode of
      kbTab:
        begin
          PWindowWorkspace(WorkSpace)^.FocusNext(False); {SelectNext(False);}
          ClearEvent(Event);
        end;
      kbShiftTab:
        begin
          PWindowWorkspace(WorkSpace)^.FocusNext(True); {SelectNext(True);}
          ClearEvent(Event);
        end;
    end
end;

procedure GraphWindow.InitWorkspace;
var
   R : TRect;
begin
   GetExtent(R);
   if Frame <> nil then begin
      if Flags and wfThickFrame <> 0 then R.Grow(-5,-5)
      else R.Grow(-2,-2);
   end;
   if Caption <> nil then Inc(R.A.Y,Caption^.Size.Y+1);
   WorkSpace := New(PWindowWorkspace,Init(R));
   GraphGroup.Insert(WorkSpace);
end;

procedure GraphWindow.InitCaption;
var
   R,R1 : TRect;
   T : String;
begin
   GetExtent(R);
   if Frame <> nil then begin
      if Flags and wfThickFrame <> 0 then R.Grow(-5,-3)
      else R.Grow(-1,-1);
   end;
   R.B.Y := R.A.Y + CaptionHeight-1;
   if Flags and wfClose <> 0 then begin
      with R do R1.Assign(A.X,A.Y,A.X+CaptionHeight-1,B.Y);
      GraphGroup.Insert(New(PCloseButton,Init(R1,'',cmClose,bfNormal)));
      R.A.X := R1.B.X;
   end;
   if Flags and wfZoom <> 0 then begin
      with R do R1.Assign(B.X-CaptionHeight+1,A.Y,B.X,B.Y);
      R.B.X := R1.A.X;
      GraphGroup.Insert(New(PZoomButton,Init(R1,'ZOOM',cmZoom,bfNormal)));
   end;
   Caption := New(PGraphTitleBar,Init(R));
   GraphGroup.Insert(Caption);
end;

procedure GraphWindow.InitFrame;
var
  R: TRect;
  CaptionPlace : Boolean;
begin
  GetExtent(R);
  CaptionPlace := Flags and wfTitle <> 0;
  Frame := New(PGraphFrame, Init(R,Flags and wfThickFrame <> 0,CaptionPlace));
  GraphGroup.Insert(Frame);
end;

procedure GraphWindow.Insert(P: PGraphView);
begin
   PWindowWorkspace(Workspace)^.Insert(P);
end;

procedure GraphWindow.SetState(AState: Word; Enable: Boolean);
var
  WindowCommands: TCommandSet;
begin
  GraphGroup.SetState(AState, Enable);
  if AState = sfSelected then
  begin
    SetState(sfActive, Enable);
    WindowCommands := [cmNext, cmPrev];
    if Flags and wfGrow <> 0 then
      WindowCommands := WindowCommands + [cmResize];
    if Flags and wfClose <> 0 then
      WindowCommands := WindowCommands + [cmClose];
    if Flags and wfZoom <> 0 then
      WindowCommands := WindowCommands + [cmZoom];
    if Enable then EnableCommands(WindowCommands)
    else DisableCommands(WindowCommands);
    if Enable then Lock;
    Message(@Self, evBroadcast, cmCommandSetChanged, @Self);
    if Enable then Unlock;
  end;
end;

procedure GraphWindow.SizeLimits(var Min, Max: TPoint);
begin
  GraphView.SizeLimits(Min, Max);
  Min.X := MinWinSize.X;
  Min.Y := MinWinSize.Y;
end;

function GraphWindow.StandardScrollBar(AOptions: Word): PGraphScrollBar;
var
  R,R1: TRect;
  S: PGraphScrollBar;
begin
  WorkSpace^.GetBounds(R);
  if AOptions and sbVertical = 0 then begin
    R1.Assign(R.A.X-1, R.B.Y-CaptionHeight, R.B.X-1, R.B.Y+1);
    dec(R.B.Y,CaptionHeight-1);
  end else begin
    R1.Assign(R.B.X-CaptionHeight,R.A.Y-1,R.B.X+1,R.B.Y+1);
    dec(R.B.X,CaptionHeight-1);
  end;
  WorkSpace^.ChangeBounds(R);
  S := New(PGraphScrollBar, Init(R1));
  if AOptions and sbVertical <> 0 then S^.GrowMode := gfGrowHiY + gfGrowLoX + gfGrowHiX
  else S^.GrowMode := gfGrowHiX + gfGrowLoY + gfGrowHiY;
  GraphGroup.Insert(S);
  if AOptions and sbHandleKeyboard <> 0 then
    S^.Options := S^.Options or ofPostProcess;
  StandardScrollBar := S;
end;

procedure GraphWindow.Store(var S: TStream);
begin
  GraphGroup.Store(S);
  S.Write(Flags, SizeOf(Byte) + SizeOf(TRect) + SizeOf(Integer));
  PutSubViewPtr(S, Frame);
  PutSubViewPtr(S,WorkSpace);
  PutSubViewPtr(S,Caption);
  S.WriteStr(Title);
end;

procedure GraphWindow.Zoom;
var
  R: TRect;
  Max, Min: TPoint;
begin
  SizeLimits(Min, Max);
  if Longint(Size) <> Longint(Max) then
  begin
    GetBounds(ZoomRect);
    Longint(R.A) := 0;
    R.B := Max;
    Locate(R);
  end else Locate(ZoomRect);
end;

{ GraphScroller }

constructor GraphScroller.Init(var Bounds: TRect; AHScrollBar,
  AVScrollBar: PGraphScrollBar);
begin
  GraphView.Init(Bounds);
  Options := Options or ofSelectable;
  EventMask := EventMask or evBroadcast;
  Step.X := 1;
  Step.Y := 1;
  HScrollBar := AHScrollBar;
  VScrollBar := AVScrollBar;
end;

constructor GraphScroller.Load(var S: TStream);
begin
  GraphView.Load(S);
  GetPeerViewPtr(S, HScrollBar);
  GetPeerViewPtr(S, VScrollBar);
  S.Read(Delta, SizeOf(TPoint)*2);
end;

procedure GraphScroller.ChangeBounds(var Bounds: TRect);
begin
  SetBounds(Bounds);
  Inc(DrawLock);
  SetLimit(Limit.X, Limit.Y);
  Dec(DrawLock);
  DrawFlag := True; {False;}
{  DrawView;}
end;

procedure GraphScroller.CheckDraw;
begin
  if (DrawLock = 0) and DrawFlag then
  begin
    DrawFlag := False;
{    DrawView;}
    ScrollDraw;
  end;
end;

procedure GraphScroller.GetDelta(var ADelta : TPoint);
begin
   with ADelta do begin
      X := Size.X div Step.X;
      Y := Size.Y div Step.Y;
   end;
end;

function GraphScroller.GetPalette : PPalette;
const
   P : String[Length(CScroller)] = CScroller;
begin
   GetPalette := @P;
end;

procedure GraphScroller.HandleEvent(var Event: TEvent);
begin
  GraphView.HandleEvent(Event);
  if (Event.What = evBroadcast) and (Event.Command = cmScrollBarChanged) and
     ((Event.InfoPtr = HScrollBar) or (Event.InfoPtr = VScrollBar)) then
      ScrollDraw;
end;

procedure GraphScroller.ScrollDraw;
var
  D: TPoint;
  dx,dy : integer;
  R,Clip : TRect;
  VP : ViewPortType;
begin
  if HScrollBar <> nil then D.X := HScrollBar^.Value
  else D.X := 0;
  if VScrollBar <> nil then D.Y := VScrollBar^.Value
  else D.Y := 0;
  if (D.X <> Delta.X) or (D.Y <> Delta.Y) then
  begin
    Dx := Delta.X-D.X;
    Dy := Delta.Y-D.Y;
{    if DrawLock <> 0 then DrawFlag := True else begin}
       Delta := D;
       Dx := Dx * Step.X;
       Dy := Dy * Step.Y;
    if DrawLock <> 0 then DrawFlag := True else begin
       GetViewSettings(VP);
       GetClipRect(Clip);
       SetDrawPort(Clip);
       R.Copy(Clip);
       MakeGlobal(R.A,R.A);
       MakeGlobal(R.B,R.B);
       if LockMouseCursor = 0 then begin
          if MouseInRect(R) then HideMouse;
          SetExclusiveArea(R);
       end;
       MoveRect(Clip,Dx,Dy);
       if LockMouseCursor = 0 then ShowMouse;
       if Dx <> 0 then begin
          if Dx > 0 then with Clip do R.Assign(A.X,A.Y,A.X+Dx,B.Y)
          else with Clip do R.Assign(B.X+Dx,A.Y,B.X,B.Y);
          R.Intersect(Clip);
          RefreshRect(R);
       end;
       if Dy <> 0 then begin
          if Dy >= 0 then with Clip do R.Assign(A.X,A.Y,B.X,A.Y+Dy)
          else with Clip do R.Assign(A.X,B.Y+Dy,B.X,B.Y);
          R.Intersect(Clip);
          RefreshRect(R);
       end;
       with VP do SetViewPort(X1,Y1,X2,Y2,Clip);
       SetCursor(Cursor.X + Dx, Cursor.Y + Dy);
    end;
  end;
end;

procedure GraphScroller.ScrollTo(X, Y: Integer);
begin
  Inc(DrawLock);
  if HScrollBar <> nil then HScrollBar^.SetValue(X);
  if VScrollBar <> nil then VScrollBar^.SetValue(Y);
  Dec(DrawLock);
  ScrollDraw;
end;

procedure GraphScroller.SetLimit(X, Y: Integer);
var
  D : TPoint;
begin
  Limit.X := X;
  Limit.Y := Y;
  GetDelta(D);
{  CheckDraw;}
  Inc(DrawLock);
  if HScrollBar <> nil then
    HScrollBar^.SetParams(HScrollBar^.Value, 0, X - D.X, D.X - 1, 1);
  if VScrollBar <> nil then
    VScrollBar^.SetParams(VScrollBar^.Value, 0, Y - D.Y, D.Y - 1, 1);
  Dec(DrawLock);
  CheckDraw;
end;
procedure GraphScroller.SetState(AState: Word; Enable: Boolean);

procedure ShowSBar(SBar: PGraphScrollBar);
var
   Enable : boolean;
begin
  if (SBar <> nil) then begin
    Enable := GetState(sfActive + sfSelected);
    SBar^.SetState(sfDisabled,not Enable);
  end;
end;

begin
  GraphView.SetState(AState, Enable);
  if AState and (sfActive + sfSelected) <> 0 then
  begin
    ShowSBar(HScrollBar);
    ShowSBar(VScrollBar);
  end;
end;

procedure GraphScroller.Store(var S: TStream);
begin
  GraphView.Store(S);
  PutPeerViewPtr(S, HScrollBar);
  PutPeerViewPtr(S, VScrollBar);
  S.Write(Delta, SizeOf(TPoint)*2);
end;


{ GraphViews registration procedure }

procedure RegisterGraphViews;
begin
  RegisterType(RGraphView);
  RegisterType(RGraphBackGround);
  RegisterType(RGraphGroup);
  RegisterType(RGraphListViewer);
  RegisterType(RIndicator);
  RegisterType(RFoot);
  RegisterType(RArrow);
  RegisterType(RGraphScrollBar);
  RegisterType(RGraphWindow);
  RegisterType(RGraphFrame);
  RegisterType(RGraphTitleBar);
  RegisterType(RCloseButton);
  RegisterType(RWindowWorkSpace);
  RegisterType(RGraphScroller);
end;

end.
