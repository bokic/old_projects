{************************************************}
{   Controls.pas                                 }
{   Graph Vision unit                            }
{   Sergey E. Levov, Moscow,1992-1994            }
{   Portions copyright (c) 1990 by Borland Int.  }
{************************************************}

unit Controls;

{$F+,O+,S-,X+}

interface

uses Objects,ExtObj,Graph,EventMan,Grav,Images,Validate;

Const
   Left_Text = 0;
   Right_Text = 1;
   Bottom_Text = 2;

{ GraphButton flags }

  bfNormal    = $00;
  bfDefault   = $01;
  bfLeftJust  = $02;
  bfBroadcast = $04;
  bfGrabFocus = $08;
  bfAuto      = $10;

{ GraphButton messages }

  cmGrabDefault    = 61;
  cmReleaseDefault = 62;

  CGrayDialog =
            #94#95#96#97#98#99#100#101#102#103#104#105#106#107#108#109#110 +
            #111#112#113#114#115#116#117#118#119#120#121#122#123#124#125 +
            #126#127#128#129#130#131#132#133#134#135#136#137#138#139#140 +
            #141#142#143#144#145#146#147#148#149#150#151#152#153#154#155 +
            #156#157#158;
  CBlueDialog = CGrayDialog;
  CCyanDialog = CGrayDialog;

  CDialog = CGrayDialog;

  CButton = #31#32#33#34#31#32#33#34#35#36#37#38#43#44#45#46;
  CStaticText = #24#25;
  CLabel = #26#27#28#29#30;
  CCluster = #47#48#49#50#51#52#53;
  CClusterlabel = #01#02#03#04#05;
  CInputLine = #54#55#56#57;
  CHistory = #04#05#06#07#08;
  CHistoryWindow = #1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17 +
                   #18#19#20#21#22#23#24#25#26#27#58#59#60#61;
  CHistoryViewer = #28#29#30#31;

{ GraphDialog palette entires }

  dpBlueDialog = 0;
  dpCyanDialog = 1;
  dpGrayDialog = 2;

type

{ GraphDialog }

  PGraphDialog = ^GraphDialog;
  GraphDialog = object(GraphWindow)
    constructor Init(var Bounds: TRect; ATitle: TTitleStr);
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function Valid(Command: Word): Boolean; virtual;
  end;

  PGraphButton = ^GraphButton;
  GraphButton = object(GraphView)
    Title : PString;
    Command: Word;
    Flags: Byte;
    AmDefault: Boolean;
    constructor Init(var Bounds: TRect; ATitle : TTitleStr; ACommand: Word; AFlags: Word);
    constructor Load(var S : TStream);
    destructor Done; virtual;
    procedure Draw; virtual;
    procedure DrawState(Pushed: Boolean); virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure MakeDefault(Enable: Boolean);
    procedure Press; virtual;
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure Store(var S : TStream);
    private
    Down : boolean;
  end;

{ Text push button}

  PGraphTextButton = ^GraphTextButton;
  GraphTextButton = object(GraphButton)
     procedure DrawState(Pushed : Boolean); virtual;
     procedure SetFont; virtual;
     function GetPalette : PPalette; virtual;
  end;

  PGraphBitmapButton = ^GraphBitmapButton;
  GraphBitmapButton = object(GraphButton)
     Images : PCollection;
     constructor Init(var Bounds : TRect; ATitle : TTitleStr; ACommand : word;
                      AFlags : word);
     constructor Load(var S : TStream);
     destructor Done; virtual;
     procedure DrawState(Pushed : boolean); virtual;
  end;

{ GraphGrayGroup }

  PGraphGrayGroup = ^GraphGrayGroup;
  GraphGrayGroup = object(GraphBackGround)
     constructor Init(var Bounds : TRect);
  end;

{ GraphListBox }

  PGraphListBox = ^GraphListBox;
  GraphListBox = object(GraphListViewer)
    List: PCollection;
    constructor Init(var Bounds: TRect; ANumCols: Word; AScrollBar: PGraphScrollBar);
    constructor Load(var S: TStream);
    function DataSize: Word; virtual;
    procedure GetData(var Rec); virtual;
    function GetItem(Item : integer): pointer; virtual;
    procedure NewList(AList: PCollection); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream);
  end;

  PTextListBox = ^TextListBox;
  TextListBox = object(GraphListBox)
    procedure DrawItem(Item : integer); virtual;
    procedure GetItemSize(var ItemSize : TPoint); virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
  end;

{ TSItem }

  PSItem = ^TSItem;
  TSItem = record
    Value: PString;
    Next: PSItem;
  end;

{ GraphStaticText }

  PGraphStaticText = ^GraphStaticText;
  GraphStaticText = object(GraphView)
    Text: PString;
    Font,
    CharSize : word;
    constructor Init(var Bounds: TRect; AText: String;
                     AFont,ACharSize : word);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Draw; virtual;
    function GetPalette : PPalette; virtual;
    procedure GetText(var S: String); virtual;
    procedure Store(var S: TStream);
  end;

{ GraphParamText }

  PGraphParamText = ^GraphParamText;
  GraphParamText = object(GraphStaticText)
    ParamCount: Integer;
    ParamList: Pointer;
    constructor Init(var Bounds: TRect; AText: String;
       AParamCount: Integer);
    constructor Load(var S: TStream);
    function DataSize: Word; virtual;
    procedure GetText(var S: String); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream);
  end;

{ GraphLabel }

  PGraphLabel = ^GraphLabel;
  GraphLabel = object(GraphStaticText)
    Link: PGraphView;
    Light: Boolean;
    constructor Init(var Bounds: TRect; AText: String; ALink: PGraphView);
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    function GetPalette : PPalette; virtual;
    procedure HandleEvent(var Event : TEvent); virtual;
    procedure Store(var S : TStream);
  end;

{ GraphInputLine }

  PGraphInputLine = ^GraphInputLine;
  GraphInputLine = object(GraphView)
    Data: PString;
    MaxLen: Integer;
    CurPos: Integer;
    FirstPos: Integer;
    SelStart: Integer;
    SelEnd: Integer;
    Validator : PValidator;
    constructor Init(var Bounds: TRect; AMaxLen: Integer);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure ChangeMouseCursor; virtual;
    function DataSize: Word; virtual;
    procedure Draw; virtual;
    procedure GetData(var Rec); virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SelectAll(Enable: Boolean);
    procedure SetData(var Rec); virtual;
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure SetValidator(AValid: PValidator);
    procedure Store(var S: TStream);
    function Valid(Command : word) : boolean; virtual;
  private
    InputLineCursor : PMouseCursor;
    function CanScroll(Delta: Integer): Boolean;
  end;


  PGraphTwoStateButton = ^GraphTwoStateButton;
  GraphTwoStateButton = object(GraphView)
    Checked : boolean;
    constructor Load(var S : TStream);
    procedure Check;
    procedure GetData(var Rec); virtual;
    function DataSize : word; virtual;
    procedure Draw; virtual;
    procedure DrawState(Pressed: Boolean); virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SetData(var Rec); virtual;
    procedure Press; virtual;
    procedure SetCheck(CheckState : boolean);
    procedure Store(var S : TStream);
    procedure Toggle;
    procedure UnCheck;
    private
    Down : boolean;
  end;

{ GraphCluster }

  PGraphCluster = ^GraphCluster;
  GraphCluster = object(GraphGroup)
    Value: Word;
    Sel: Integer;
    constructor Init(var Bounds: TRect; AStrings: PSItem);
    constructor Load(var S: TStream);
    function DataSize: Word; virtual;
    procedure GetData(var Rec); virtual;
    procedure GetItemSize(var ItemSize : TPoint); virtual;
    function GetHelpCtx: Word; virtual;
    function GetPalette : PPalette; virtual;
    function NewControl(Bounds : TRect; AId : integer): PGraphView; virtual;
    function Mark(Item: Integer): Boolean; virtual;
    procedure Press(Control : PGraphView); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream);
    private
    procedure InsertItem(Bounds : TRect; ItemLabel : string; AId : integer);
    procedure DrawItem(Bounds : TRect; AI : integer);
    private
       Images : PCollection;
  end;

  PGraphRadioButtons = ^GraphRadioButtons;
  GraphRadioButtons = object(GraphCluster)
    constructor Init(var Bounds : TRect; AStrings : PSItem);
    constructor Load(var S : TStream);
    destructor Done; virtual;
    procedure GetItemSize(var ItemSize : TPoint); virtual;
    procedure HandleEvent(var Event : TEvent); virtual;
    function NewControl(Bounds : TRect; AId : integer): PGraphView; virtual;
    function Mark(Item : Integer): boolean; virtual;
    procedure Press(Control : PGraphView); virtual;
  end;

  PGraphCheckBoxes = ^GraphCheckBoxes;
  GraphCheckBoxes = object(GraphCluster)
    constructor Init(var Bounds : TRect; AStrings : PSItem);
    constructor Load(var S : TStream);
    destructor Done; virtual;
    procedure GetItemSize(var ItemSize : TPoint); virtual;
    procedure HandleEvent(var Event : TEvent); virtual;
    function NewControl(Bounds : TRect; AId : integer): PGraphView; virtual;
    function Mark(Item : Integer): boolean; virtual;
    procedure Press(Control : PGraphView); virtual;
  end;

  PGraphStaticBitmap = ^GraphStaticBitmap;
  GraphStaticBitmap = object(GraphView)
     Image : PImage;
     Name : PString;
     constructor Init(var Bounds : TRect; AName : String);
     constructor Load(var S : TStream);
     destructor Done; virtual;
     procedure Draw; virtual;
     procedure Store(var S : TStream);
  end;

{ GraphHistoryViewer }

  PGraphHistoryViewer = ^GraphHistoryViewer;
  GraphHistoryViewer = object(GraphListViewer)
    HistoryId: Word;
    constructor Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PGraphScrollBar;
      AHistoryId: Word);
    function GetPalette: PPalette; virtual;
    procedure DrawItem(Item : Integer); virtual;
    procedure GetItemSize(var ItemSize : TPoint); virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function HistoryWidth: Integer;
  end;

{ GraphHistoryWindow }

  PGraphHistoryWindow = ^GraphHistoryWindow;
  GraphHistoryWindow = object(GraphWindow)
    Viewer: PGraphHistoryViewer;
    constructor Init(var Bounds: TRect; HistoryId: Word);
    function GetPalette: PPalette; virtual;
    function GetSelection: String; virtual;
    procedure InitViewer(HistoryId: Word); virtual;
  end;

{ GraphHistory }

  PGraphHistory = ^GraphHistory;
  GraphHistory = object(GraphView)
    Link: PGraphInputLine;
    HistoryId: Word;
    constructor Init(var Bounds: TRect; ALink: PGraphInputLine; AHistoryId: Word);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Draw; virtual;
    procedure DrawState(Pushed : boolean); virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function InitHistoryWindow(var Bounds: TRect): PGraphHistoryWindow; virtual;
    procedure Press; virtual;
    procedure Store(var S: TStream);
    private
    Images : PCollection;
    Down : boolean;
  end;

{ SItem routines }

function NewSItem(Str: String; ANext: PSItem): PSItem;

{ Controls registration routine }

procedure RegisterControls;

const

{ Controls registration records }

  RGraphDialog: TStreamRec = (
     ObjType: 16;
     VmtLink: Ofs(TypeOf(GraphDialog)^);
     Load:    @GraphDialog.Load;
     Store:   @GraphDialog.Store
  );

  RGraphButton: TStreamRec = (
     ObjType: 17;
     VmtLink: Ofs(TypeOf(GraphButton)^);
     Load:    @GraphButton.Load;
     Store:   @GraphButton.Store
  );

  RGraphTextButton: TStreamRec = (
     ObjType: 18;
     VmtLink: Ofs(TypeOf(GraphTextButton)^);
     Load:    @GraphTextButton.Load;
     Store:   @GraphTextButton.Store
  );

  RGraphBitmapButton: TStreamRec = (
     ObjType: 19;
     VmtLink: Ofs(TypeOf(GraphBitmapButton)^);
     Load:    @GraphBitmapButton.Load;
     Store:   @GraphBitmapButton.Store
  );

  RGraphListBox: TStreamRec = (
    ObjType: 20;
    VmtLink: Ofs(TypeOf(GraphListBox)^);
    Load:    @GraphListBox.Load;
    Store:   @GraphListBox.Store
  );

  RTextListBox: TStreamRec = (
    ObjType: 21;
    VmtLink: Ofs(TypeOf(TextListBox)^);
    Load:    @TextListBox.Load;
    Store:   @TextListBox.Store
  );

  RGraphStaticText: TStreamRec = (
    ObjType: 22;
    VmtLink: Ofs(TypeOf(GraphStaticText)^);
    Load:    @GraphStaticText.Load;
    Store:   @GraphStaticText.Store
  );

  RGraphParamText: TStreamRec = (
    ObjType: 23;
    VmtLink: Ofs(TypeOf(GraphParamText)^);
    Load:    @GraphParamText.Load;
    Store:   @GraphParamText.Store
  );

  RGraphLabel: TStreamRec = (
    ObjType: 24;
    VmtLink: Ofs(TypeOf(GraphLabel)^);
    Load:    @GraphLabel.Load;
    Store:   @GraphLabel.Store
  );

  RGraphInputLine: TStreamRec = (
    ObjType: 25;
    VmtLink: Ofs(TypeOf(GraphInputLine)^);
    Load:    @GraphInputLine.Load;
    Store:   @GraphInputLine.Store
  );

  RGraphStaticBitmap: TStreamRec = (
     ObjType: 26;
     VmtLink: Ofs(TypeOf(GraphStaticBitmap)^);
     Load:    @GraphStaticBitmap.Load;
     Store:   @GraphStaticBitmap.Store
  );

  RGraphCluster: TStreamRec = (
     ObjType: 29;
     VmtLink: Ofs(TypeOf(GraphCluster)^);
     Load:    @GraphCluster.Load;
     Store:   @GraphCluster.Store
  );

  RGraphRadioButtons: TStreamRec = (
     ObjType: 30;
     VmtLink: Ofs(TypeOf(GraphRadioButtons)^);
     Load:    @GraphRadioButtons.Load;
     Store:   @GraphRadioButtons.Store
  );

  RGraphCheckBoxes: TStreamRec = (
     ObjType: 31;
     VmtLink: Ofs(TypeOf(GraphCheckBoxes)^);
     Load:    @GraphCheckBoxes.Load;
     Store:   @GraphCheckBoxes.Store
  );

  RGraphHistory: TStreamRec = (
     ObjType: 32;
     VmtLink: Ofs(TypeOf(GraphHistory)^);
     Load:    @GraphHistory.Load;
     Store:   @GraphHistory.Store
  );

const

{ Dialog broadcast commands }

  cmRecordHistory = 60;

implementation

uses HistList,Memory,GrDriver,GFonts;

function NewSItem(Str: String; ANext: PSItem): PSItem;
var
  Item: PSItem;
begin
  New(Item);
  Item^.Value := NewStr(Str);
  Item^.Next := ANext;
  NewSItem := Item;
end;

function HotKey(var S: String): Char;
var
  P: Word;
begin
  P := Pos('~',S);
  if P <> 0 then HotKey := UpCase(S[P+1])
  else HotKey := #0;
end;

{ GraphDialog }

constructor GraphDialog.Init(var Bounds: TRect; ATitle: TTitleStr);
begin
  GraphWindow.Init(Bounds, ATitle, wfMove + wfClose + wfThickFrame + wfTitle);
  GrowMode := 0;
  with WorkSpace^ do Options := Options or ofNoDrawSelect;
  Palette := dpGrayDialog;
end;

function GraphDialog.GetPalette: PPalette;
const
  P: array[dpBlueDialog..dpGrayDialog] of string[Length(CBlueDialog)] =
    (CBlueDialog,CCyanDialog,CGrayDialog);
begin
  GetPalette := @P[Palette];
end;

procedure GraphDialog.HandleEvent(var Event: TEvent);
var
   R,R1 : TRect;
begin
  GraphWindow.HandleEvent(Event);
  case Event.What of
    evKeyDown:
      case Event.KeyCode of
        kbEsc:
          begin
            Event.What := evCommand;
            Event.Command := cmCancel;
            Event.InfoPtr := nil;
            PutEvent(Event);
            ClearEvent(Event);
          end;
        kbEnter:
          begin
            Event.What := evBroadcast;
            Event.Command := cmDefault;
            Event.InfoPtr := nil;
            PutEvent(Event);
            ClearEvent(Event);
          end;
      end;
    evCommand:
      case Event.Command of
        cmOk, cmCancel, cmYes, cmNo:
          if State and sfModal <> 0 then
	  begin
	    EndModal(Event.Command);
            ClearEvent(Event);
          end;
      end;
  end;
end;

function GraphDialog.Valid(Command: Word): Boolean;
begin
  if Command = cmCancel then Valid := True
  else Valid := GraphGroup.Valid(Command);
end;

{ GraphButton }

constructor GraphButton.Init(var Bounds: TRect; ATitle : TTitleStr; ACommand: Word; AFlags: Word);
begin
  GraphView.Init(Bounds);
  Options := Options or (ofSelectable + ofFirstClick +
    ofPreProcess + ofPostProcess);
  EventMask := EventMask or evBroadcast;
  if not CommandEnabled(ACommand) then State := State or sfDisabled;
  Title := NewStr(ATitle);
  Flags := AFlags;
  if AFlags and bfDefault <> 0 then AmDefault := True
  else AmDefault := False;
  Command := ACommand;
  Down := false;
end;

destructor GraphButton.Done;
begin
   DisposeStr(Title);
   GraphView.Done;
end;

constructor GraphButton.Load(var S: TStream);
begin
  GraphView.Load(S);
  Title := S.ReadStr;
  S.Read(Command, SizeOf(Word) + SizeOf(Byte) + SizeOf(Boolean));
  if not CommandEnabled(Command) then State := State or sfDisabled
  else State := State and not sfDisabled;
end;

procedure GraphButton.Draw;
var
   R,R1 : TRect;
begin
  DrawState(Down);
end;

procedure GraphButton.DrawState(Pushed: Boolean);
begin
end;

procedure GraphButton.HandleEvent(var Event: TEvent);
var
  C: Char;
  Cm : word;
  Mouse: TPoint;
  ClickRect,R,R1: TRect;
begin
  GetExtent(ClickRect);
  if Event.What = evMouseDown then
  begin
	 MakeLocal(Event.Where, Mouse);
	 if not ClickRect.Contains(Mouse) then ClearEvent(Event);
  end;
  if Flags and bfGrabFocus <> 0 then
	  GraphView.HandleEvent(Event);
  case Event.What of
	 evMouseDown:
		begin
		  Down := False;
		  repeat
			 MakeLocal(Event.Where, Mouse);
			 if Down <> ClickRect.Contains(Mouse) then
			 begin
				Down := not Down;
				DrawView;
			 end;
			 if (Flags and bfAuto <> 0) and (Event.What =  evMouseAuto) then
			 if Down then begin
				 Press;
				 DrawView;
			 end;
		  until not MouseEvent(Event, evMouseMove + evMouseAuto);
		  if Down then
		  begin
			 Press;
			 Down := false;
			 DrawView;
		  end;
		  ClearEvent(Event);
		end;
	 evKeyDown :
		begin
		  if Title <> nil then C := HotKey(Title^) else C := #0;
		  if (Event.KeyCode = GetAltCode(C)) or
			 (Owner^.Phase = phPostProcess) and (C <> #0) and
			 (Upcase(Event.CharCode) = C) or
			 (State and sfFocused <> 0) and (Event.CharCode = ' ') then
		  begin
			  Down := true;
			  DrawView;
			  Press;
           Down := false;
           DrawView;
           ClearEvent(Event);
         end;
      end;
    evBroadcast:
      case Event.Command of
        cmDefault:
          if AmDefault then
          begin
            Press;
            ClearEvent(Event);
          end;
        cmGrabDefault, cmReleaseDefault:
          if Flags and bfDefault <> 0 then
          begin
            AmDefault := Event.Command = cmReleaseDefault;
            DrawView;
          end;
        cmCommandSetChanged:
          begin
            SetState(sfDisabled, not CommandEnabled(Command));
          end;
      end;
  end;
end;

procedure GraphButton.MakeDefault(Enable: Boolean);
var
  C: Word;
begin
  if Flags and bfDefault = 0 then
  begin
    if Enable then C := cmGrabDefault else C := cmReleaseDefault;
    Message(Owner, evMessage, C, @Self);
    AmDefault := Enable;
  end;
end;

procedure GraphButton.Press;
var
  E: TEvent;
begin
  if Flags and bfBroadcast <> 0 then
    Message(Owner, evMessage, Command, @Self) else
  begin
    E.What := evCommand;
    E.Command := Command;
    E.InfoPtr := @Self;
    PutEvent(E);
  end;
end;

procedure GraphButton.SetState(AState: Word; Enable: Boolean);
begin
   GraphView.SetState(AState, Enable);
   if AState and sfFocused <> 0 then begin
     MakeDefault(Enable);
     DrawView;
   end;
   if AState and sfDisabled <> 0 then DrawView;
end;

procedure GraphButton.Store(var S: TStream);
begin
  GraphView.Store(S);
  S.WriteStr(Title);
  S.Write(Command, SizeOf(Word) + SizeOf(Byte) + SizeOf(Boolean));
end;

{ GraphTextButton }


procedure GraphTextButton.DrawState(Pushed : Boolean);
var
   ButtonColor,
   TextColor,HighLight,
   Light,Dark : word;
   R,R1 : TRect;
   S : string;

procedure DrawTitle;
var
   T : TPoint;
begin
  SetFont;
  T.Y := (Size.Y) div 2;
  if (Flags and bfLeftJust <> 0) then
	  begin
	  T.X := 1;
	  SetTextJustify(LeftText,CenterText)
	  end
	  else
	  begin
	  T.X := Size.X  div 2;
	  if (T.X < 1) then
			T.X := 1;
	  SetTextJustify(CenterText,CenterText);
	  end;
  if Down then
	  begin
	  inc(T.X,2);
	  inc(T.Y,2);
	  end;
  SetColor(TextColor);
  WriteCTextXY(T,Title^,TextColor,HighLight);
end;

begin
	if (State and sfDisabled <> 0) then
		begin
		ButtonColor := GetColor(13);
		Light := GetColor(14);
		Dark := GetColor(15);
		TextColor := GetColor(16);
		HighLight := TextColor;
		end
		else
		begin
		ButtonColor := GetColor(1);
		Light := GetColor(2);
		Dark := GetColor(3);
		TextColor := GetColor(4);
		HighLight := GetColor(12);
		if (State and sfActive <> 0) then
			if (State and sfFocused <> 0) then
				begin
				ButtonColor := GetColor(1);
				Light := GetColor(2);
				Dark := GetColor(3);
				TextColor := GetColor(4);
				HighLight := GetColor(12);
				end
			else
			if AmDefault then
				begin
				ButtonColor := GetColor(5);
				Light := GetColor(6);
				Dark := GetColor(7);
				textColor := GetColor(9);
				HighLight := GetColor(12);
				end;
		end;
	GetExtent(R);
	SetLineStyle(SolidLn,0,NormWidth);
	SetColor(Dark);
	Rectangle(R);
	R.Grow(-1,-1);
	SetFillStyle(SolidFill,ButtonColor);
   Bar(R);
	if Pushed then
		begin
		SetColor(Dark);
		with R do
			begin
			R1.Assign(A.X,A.Y,A.X+1,B.Y-1);
			Line(R1);
			R1.Assign(A.X,A.Y,B.X,A.Y+1);
			Line(R1);
			R.Grow(-1,-1);
			end;
		end
		else
		begin
		BiColorRectangle(R,Light,Dark,false);
		R.Grow(-1,-1);
		end;
	DrawTitle;
end;

procedure GraphTextButton.SetFont;
begin
	GFonts.SettextStyle(SystemFont,HorizDir,1);
end;

function GraphTextButton.GetPalette: PPalette;
const
   P : String[Length(CButton)] = CButton;
begin
   GetPalette := @P;
end;

constructor GraphBitmapButton.Init(var Bounds : TRect; ATitle : TTitleStr;
               ACommand : word; AFlags : word);
var
   S : String;
   I : integer;
begin
   GraphButton.Init(Bounds,ATitle,ACommand,AFlags);
   CStrToStr(ATitle,S);
   Images := PCollection(StdSharedResource^.Get(S));
   if Images = nil then Fail;
end;

constructor GraphBitmapButton.Load(var S : TStream);
var
   Str : String;
begin
   GraphButton.Load(S);
   CStrToStr(Title^,Str);
   Images := PCollection(StdSharedResource^.Get(Str));
   if Images = nil then Fail;
end;

destructor GraphBitmapButton.Done;
var
   S : String;
begin
   CStrToStr(Title^,S);
   if Images <> nil then StdSharedResource^.Free(S);
   GraphButton.Done;
end;

procedure GraphBitmapButton.DrawState(Pushed : boolean);
var
   WorkImage : integer;
   R : TRect;
   P : pointer;
begin
   if Images = nil then Exit;
   if Pushed then WorkImage := 1 else begin
      WorkImage := 0;
      if State and sfActive  <> 0 then
      if State and sfFocused <> 0 then WorkImage := 2;
   end;
   GetExtent(R);
   P := Images^.At(WorkImage);
   if P <> nil then DrawImg(R.A,PImage(P),NormalPut);
end;

{ GraphGrayGroup }

constructor GraphGrayGroup.Init(var Bounds : TRect);
begin
   GraphBackground.Init(Bounds,SolidFill,bsLower);
   GrowMode := 0;
end;

{ GraphListBox }

type
  TListBoxRec = record
    List: PCollection;
    Selection: Word;
  end;

constructor GraphListBox.Init(var Bounds: TRect; ANumCols: Word;
   AScrollBar: PGraphScrollBar);
var
  ARange: Integer;
begin
  GraphListViewer.Init(Bounds, ANumCols, nil, AScrollBar);
  List := nil;
  SetRange(0);
end;

constructor GraphListBox.Load(var S: TStream);
begin
  GraphListViewer.Load(S);
  List := PCollection(S.Get);
end;

function GraphListBox.DataSize: Word;
begin
  DataSize := SizeOf(TListBoxRec);
end;

procedure GraphListBox.GetData(var Rec);
begin
  TListBoxRec(Rec).List := List;
  TListBoxRec(Rec).Selection := Focused;
end;

function GraphListBox.GetItem(Item : integer) : pointer;
begin
   if List <> nil then GetItem := List^.At(Item)
   else GetItem := nil;
end;
 
procedure GraphListBox.NewList(AList: PCollection);
begin
  if List <> nil then Dispose(List, Done);
  List := AList;
  if AList <> nil then SetRange(AList^.Count)
  else SetRange(0);
  if Range > 0 then FocusItem(0);
  DrawView;
end;

procedure GraphListBox.SetData(var Rec);
begin
  NewList(TListBoxRec(Rec).List);
  FocusItem(TListBoxRec(Rec).Selection);
  DrawView;
end;

procedure GraphListBox.Store(var S: TStream);
begin
  GraphListViewer.Store(S);
  S.Put(List);
end;

{ TextListBox }

procedure TextListBox.DrawItem(Item : integer);
var
   ColWidth : integer;
   R : TRect;
   i,j : integer;
   TextColor,BackColor : word;
   P,ItemSize : TPoint;
begin
   GetItemSize(ItemSize);
   GetItemRect(Item,R);
   SetTextJustify(LeftText,Centertext);
   if State and (sfSelected + sfActive + sfFocused) = (sfSelected + sfActive + sfFocused) then
   begin
      if IsSelected(Item) then begin
         TextColor := GetColor(4);
         BackColor := GetColor(3);
      end else begin
         TextColor := GetColor(2);
         BackColor := GetColor(1);
      end;
   end else
   begin
      if IsSelected(Item) then TextColor :=GetColor(4) else TextColor := GetColor(2);
      BackColor := GetColor(1);
   end;
   SetFillStyle(SolidFill,BackColor);
   if not CanFillBackground then Bar(R);
   SetColor(TextColor);
   P := R.A;
   P.Y := P.Y + (ItemSize.Y div 2);
   WriteTextXY(P,GetText(Item,R.B.X-R.A.X));
end;

procedure TextListBox.GetItemSize(var ItemSize : TPoint);
begin
   with ItemSize do begin
      Y := GFonts.TextHeight(' ');
      X := Size.X div NumCols;
   end;
end;

function TextListBox.GetText(Item : integer; MaxLen : integer) : String;
var
   S : string;
   i,j : integer;
begin
   if GetItem(Item) <> nil then begin
      i := MaxLen div 8;
      if (MaxLen mod 8) <> 0 then inc(i);
      S := PString(GetItem(Item))^;
      j := Length(S);
      if j > i then S := Copy(S,1,i)
      else begin
         FillChar(S[j+1],i-j,' ');
         inc(Byte(S[0]),i-j);
      end;
      GetText := S;
   end else GetText := '';
end;

{ GraphStaticText }

constructor GraphStaticText.Init(var Bounds: TRect; AText: String;
                                 AFont,ACharSize : word);
begin
  GraphView.Init(Bounds);
  Text := NewStr(AText);
  Font := AFont;
  CharSize := ACharSize;
end;

constructor GraphStaticText.Load(var S: TStream);
begin
  GraphView.Load(S);
  Text := S.ReadStr;
  S.Read(Font,SizeOf(word)*2);
end;

destructor GraphStaticText.Done;
begin
  DisposeStr(Text);
  GraphView.Done;
end;

procedure GraphStaticText.Draw;
var
  Center: Boolean;
  I, J, L, P, Y: Integer;
  S,S1: String;
  B : string;
  StartPoint : TPoint;
  R : TRect;
begin
  GetText(S);
  GetExtent(R);
  GFonts.SetTextStyle(Font,HorizDir,CharSize);
  SetFillStyle(SolidFill,GetColor(1));
  Bar(R);
  L := Length(S);
  P := 1;
  Y := 0;
  SetTextJustify(LeftText,TopText);
  Center := False;
  while Y < Size.Y do
  begin
    if P <= L then
    begin
      if S[P] = #3 then
      begin
        Center := True;
        Inc(P);
      end;
      I := P;
      repeat
        J := P;
        while (P <= L) and (S[P] = ' ') do Inc(P);
        while (P <= L) and (S[P] <> ' ') and (S[P] <> #13) do Inc(P);
      until (P > L) or (P >= I + (Size.X div TextWidth('A'))) or (S[P] = #13);
      if P > I + (Size.X div TextWidth('A')) then
        if J > I then P := J else P := I + (Size.X div TextWidth('A'));
      S1 := Copy(S,I,P-I);
      i := TextWidth(S1);
      j := (Size.X - i) div 2;
      StartPoint.X := 0;
      StartPoint.Y := Y;
      if Center then inc(StartPoint.X,j);
      SetColor(GetColor(2));
      WriteTextXY(StartPoint,S1);
      while (P <= L) and (S[P] = ' ') do Inc(P);
      if (P <= L) and (S[P] = #13) then
      begin
        Center := False;
        Inc(P);
        if (P <= L) and (S[P] = #10) then Inc(P);
      end;
    end;
    Inc(Y,TextHeight(S1));
  end;
end;

function GraphStaticText.GetPalette : PPalette;
const
   P : String[Length(CStaticText)] = CStatictext;
begin
   GetPalette := @P;
end;
 
procedure GraphStaticText.GetText(var S: String);
begin
  if Text <> nil then S := Text^
  else S := '';
end;

procedure GraphStaticText.Store(var S: TStream);
begin
  GraphView.Store(S);
  S.WriteStr(Text);
  S.Write(Font,SizeOf(word)*2);
end;

{ GraphParamText }

constructor GraphParamText.Init(var Bounds: TRect; AText: String;
  AParamCount: Integer);
begin
  GraphStaticText.Init(Bounds, AText, SystemFont,1);
  ParamCount := AParamCount;
end;

constructor GraphParamText.Load(var S: TStream);
begin
  GraphStaticText.Load(S);
  S.Read(ParamCount, SizeOf(Integer));
end;

function GraphParamText.DataSize: Word;
begin
  DataSize := ParamCount * SizeOf(Longint);
end;

procedure GraphParamText.GetText(var S: String);
begin
  if Text <> nil then FormatStr(S, Text^, ParamList^)
  else S := '';
end;

procedure GraphParamText.SetData(var Rec);
begin
  ParamList := @Rec;
end;

procedure GraphParamText.Store(var S: TStream);
begin
  GraphStaticText.Store(S);
  S.Write(ParamCount, SizeOf(Integer));
end;

{ GraphLabel }

constructor GraphLabel.Init(var Bounds: TRect; AText: String; ALink: PGraphView);
begin
  GraphStaticText.Init(Bounds, AText, SystemFont,1);
  Link := ALink;
  Options := Options or (ofPreProcess + ofPostProcess);
  EventMask := EventMask or evBroadcast;
end;

constructor GraphLabel.Load(var S: TStream);
begin
  GraphStaticText.Load(S);
  GetPeerViewPtr(S, Link);
end;

procedure GraphLabel.Draw;
var
  Center : boolean;
  Color1,Color: Word;
  S : string;
  i,j : integer;
  StartPoint : TPoint;
  R : TRect;
begin
  GetExtent(R);
  S := Text^;
  Center := False;
  if S[1] = #3 then begin
     Center := true;
     S := Copy(S,2,Length(S)-1);
  end;
  SetFillStyle(SolidFill,GetColor(1));
  if not CanFillBackground then Bar(R);
  if (State and sfDisabled <> 0) then begin
     Color1 := GetColor(2);
     Color := Color1;
  end else begin
     Color1 := GetColor(5);
     if Light then Color := GetColor(4)
     else Color := GetColor(3);
  end;
  GFonts.SetTextStyle(Font,HorizDir,CharSize);
  SetTextJustify(LeftText,TopText);
  i := TextWidth(S);
  j := (Size.X - i) div 2;
  StartPoint.X := 0;
  StartPoint.Y := 0;
  if Center then inc(StartPoint.X,j);
  WriteCTextXY(StartPoint,S,Color,Color1);
end;

function GraphLabel.GetPalette : PPalette;
const
   P : String[Length(CLabel)] = CLabel;
begin
   GetPalette := @P;
end;
 

procedure GraphLabel.HandleEvent(var Event: TEvent);
var
  C: Char;

  procedure FocusLink;
  begin
    if (Link <> nil) and (Link^.Options and ofSelectable <> 0) then
      Link^.Focus;
    ClearEvent(Event);
  end;

begin
  GraphStaticText.HandleEvent(Event);
  if Event.What = evMouseDown then
  begin
    if Link <> nil then Link^.Select;
    ClearEvent(Event);
  end
  else if Event.What = evKeyDown then
  begin
    C := HotKey(Text^);
    if (GetAltCode(C) = Event.KeyCode) or
       ((C <> #0) and (Owner^.Phase = phPostProcess) and
        (UpCase(Event.CharCode) = C)) then
        FocusLink;
  end
  else if Event.What = evBroadcast then
    if ((Event.Command = cmReceivedFocus) or
       (Event.Command = cmReleasedFocus)) and
       (Link <> nil) then
    begin
      if Light <> (Link^.State and sfFocused <> 0) then begin
         Light := Link^.State and sfFocused <> 0;
         DrawView;
      end;
    end;
end;

procedure GraphLabel.Store(var S: TStream);
begin
  GraphStaticText.Store(S);
  PutPeerViewPtr(S, Link);
end;

{ GraphInputLine }

constructor GraphInputLine.Init(var Bounds: TRect; AMaxLen: Integer);
begin
  GraphView.Init(Bounds);
  State := State or sfCursorVis;
  Options := Options or (ofSelectable + ofFirstClick);
  GetMem(Data, AMaxLen + 1);
  Data^ := '';
  MaxLen := AMaxLen;
  InputLineCursor := PMouseCursor(StdSharedResource^.Get('IBEAM'));
end;

constructor GraphInputLine.Load(var S: TStream);
begin
  GraphView.Load(S);
  S.Read(MaxLen, SizeOf(Integer) * 5);
  GetMem(Data, MaxLen + 1);
  S.Read(Data^[0], 1);
  S.Read(Data^[1], Length(Data^));
  if Options and ofVersion >= ofVersion20 then
    Validator := PValidator(S.Get);
  Options := Options or ofVersion20;
  InputLineCursor := PMouseCursor(StdSharedResource^.Get('IBEAM'));
end;

destructor GraphInputLine.Done;
begin
  FreeMem(Data, MaxLen + 1);
  StdSharedresource^.Free('IBEAM');
  SetValidator(nil);
  GraphView.Done;
end;

function GraphInputLine.CanScroll(Delta: Integer): Boolean;
begin
  if Delta < 0 then
    CanScroll := FirstPos > 0 else
  if Delta > 0 then
    CanScroll := Length(Data^) - FirstPos > (Size.X div 8) else
    CanScroll := False;
end;

procedure GraphInputLine.ChangeMouseCursor;
begin
   if (State and sfActive <> 0) then
   begin
      if InputLineCursor <> nil then InputLineCursor^.MakeActive;
      MouseOwner := @Self;
   end else if StdMouseCursor <> nil then StdMouseCursor^.MakeActive;
end;

function GraphInputLine.DataSize: Word;
var
  DSize: Word;

begin
  DSize := 0;

  if Validator <> nil then
    DSize := Validator^.Transfer(Data^, nil, vtDataSize);
  if DSize <> 0 then
    DataSize := DSize
  else
    DataSize := MaxLen + 1;
end;

procedure GraphInputLine.Draw;
var
  NormTextColor,
  NormBackColor,
  SelTextColor,
  SelBackColor : word;
  L, R: Integer;
  S : String;
  P : TPoint;
  R1 : TRect;
  j : integer;
begin
   GFonts.SetTextStyle(SystemFont,HorizDir,1);
   SetCursor((CurPos - FirstPos)*8 , 0);
   NormTextColor := GetColor(2);
   NormBackColor := GetColor(1);
   SelTextColor := GetColor(4);
   SelBackColor := GetColor(3);
   L := 0;
   R := 0;
   j := Size.X div 8;
   if Size.X mod 8 <> 0 then inc(J);
   if State and sfSelected <> 0 then
   begin
     if SelStart > FirstPos then L := SelStart else L := FirstPos;
     if SelEnd > FirstPos+j then R := FirstPos + j
     else R := SelEnd;
   end;
   SetFillStyle(SolidFill,NormbackColor);
   SetTextJustify(LeftText,CenterText);
   S := Copy(Data^,FirstPos+1,j);
   P.X := 0;
   P.Y := Size.Y div 2;
   if not CanFillBackground then begin
     R1.Assign(0,0,Size.X,Size.Y);
     Bar(R1);
   end else begin
      if Length(S) <= j then begin
         FillChar(S[Length(S)+1],j-Length(S),' ');
         S[0] := Char(j);
      end;
   end;
   SetColor(NormTextColor);
   WriteTextXY(P,S);
   if  L < R then begin
      SetFillStyle(SolidFill,SelBackColor);
      R1.Assign((L-FirstPos)*8,0,(R-FirstPos)*8,Size.Y);
      if not CanFillBackground then Bar(R1);
      S := Copy(Data^,L+1,R-L);
      P.X := (L-FirstPos)*8;
      SetColor(SelTextColor);
      WriteTextXY(P,S);
   end;
  if Exposed and ((not State) and (sfCursorVis+ sfFocused) = 0)
  then DrawCursor;
end;

procedure GraphInputLine.GetData(var Rec);
begin
  if (Validator = nil) or
     (Validator^.Transfer(Data^, @Rec, vtGetData) = 0) then
  begin
     FillChar(Rec, DataSize, #0);
     Move(Data^, Rec, Length(Data^) + 1);
  end;
end;

function GraphInputLine.GetPalette: PPalette;
const
  P: String[Length(CInputLine)] = CInputLine;
begin
  GetPalette := @P;
end;

procedure GraphInputLine.HandleEvent(var Event: TEvent);
const
  PadKeys = [$47, $4B, $4D, $4F, $73, $74];
var
  Delta, Anchor, I: Integer;
  ExtendBlock: Boolean;
  OldData: string;
  OldCurPos, OldFirstPos,
  OldSelStart, OldSelEnd: Integer;
  WasAppending: Boolean;
  CurMousePos : Integer;
  DrawFlag : boolean;

function MouseDelta: Integer;
var
  Mouse: TPoint;
begin
  MakeLocal(Event.Where, Mouse);
  if Mouse.X < 0 then MouseDelta := -1 else
  if Mouse.X >= Size.X then MouseDelta := 1 else
  MouseDelta := 0;
end;

function MousePos: Integer;
var
  Pos: Integer;
  Mouse: TPoint;
begin
  MakeLocal(Event.Where, Mouse);
  Mouse.X := (Mouse.X) div 8;
  Mouse.Y := (Mouse.Y) div 8;
  Pos := Mouse.X + FirstPos;
  if Pos < 0 then Pos := 0;
  if Pos > Length(Data^) then Pos := Length(Data^);
  MousePos := Pos;
end;

procedure DeleteSelect;
begin
  if SelStart <> SelEnd then
  begin
    Delete(Data^, SelStart + 1, SelEnd - SelStart);
    CurPos := SelStart;
  end;
end;

procedure AdjustSelectBlock;
begin
  if CurPos < Anchor then
  begin
    SelStart := CurPos;
    SelEnd := Anchor;
  end else
  begin
    SelStart := Anchor;
    SelEnd := CurPos;
  end;
end;

procedure SaveState;
begin
  if Validator <> nil then
  begin
    OldData := Data^;
    OldCurPos := CurPos;
    OldFirstPos := FirstPos;
    OldSelStart := SelStart;
    OldSelEnd := SelEnd;
    WasAppending := Length(Data^) = CurPos;
  end;
end;

procedure RestoreState;
begin
  if Validator <> nil then
  begin
    Data^ := OldData;
    CurPos := OldCurPos;
    FirstPos := OldFirstPos;
    SelStart := OldSelStart;
    SelEnd := OldSelEnd;
  end;
end;

function CheckValid(NoAutoFill: Boolean): Boolean;
var
  OldLen: Integer;
  NewData: String;
begin
  if Validator <> nil then
  begin
    CheckValid := False;
    OldLen := Length(Data^);
    if (Validator^.Options and voOnAppend = 0) or
      (WasAppending and (CurPos = OldLen)) then
    begin
      NewData := Data^;
      if not Validator^.IsValidInput(NewData, NoAutoFill) then
        RestoreState
      else
      begin
        if Length(NewData) > MaxLen then NewData[0] := Char(MaxLen);
        Data^ := NewData;
        if (CurPos >= OldLen) and (Length(Data^) > OldLen) then
          CurPos := Length(Data^);
        CheckValid := True;
      end;
    end
    else
    begin
      CheckValid := True;
      if CurPos = OldLen then
        if not Validator^.IsValidInput(Data^, False) then
        begin
          Validator^.Error;
          CheckValid := False;
        end;
    end;
  end
  else
    CheckValid := True;
end;

begin
  GraphView.HandleEvent(Event);
  DrawFlag := false;
  if State and sfSelected <> 0 then
    case Event.What of
      evMouseDown:
        begin
          DrawFlag := true;
          Delta := MouseDelta;
          if CanScroll(Delta) then
          begin
            repeat
              if CanScroll(Delta) then
              begin
                Inc(FirstPos, Delta);
                DrawView;
              end;
            until not MouseEvent(Event, evMouseAuto);
          end else
          if Event.Double then SelectAll(True) else
          begin
            Anchor := MousePos;
            CurMousePos := MousePos;
            repeat
              if Event.What = evMouseAuto then
              begin
                Delta := MouseDelta;
                if CanScroll(Delta) then Inc(FirstPos, Delta);
              end;
              CurPos := MousePos;
              AdjustSelectBlock;
              DrawFlag := CurMousePos <> MousePos;
              CurMousePos := MousePos;
              HideMouse;
              SetCursor((CurPos - FirstPos)*8 , 0);
              ShowMouse;
              if DrawFlag then begin
                 DrawView;
              end;
            until not MouseEvent(Event, evMouseMove + evMouseAuto);
          end;
          ClearEvent(Event);
          DrawFlag := false;
        end;
      evKeyDown:
        begin
          SaveState;
          Event.KeyCode := CtrlToArrow(Event.KeyCode);
          if (Event.ScanCode in PadKeys) and
             (GetShiftState and $03 <> 0) then
          begin
            Event.CharCode := #0;
            if CurPos = SelEnd then Anchor := SelStart
            else Anchor := SelEnd;
            ExtendBlock := True;
          end
          else
            ExtendBlock := False;
          case Event.KeyCode of
            kbLeft:
              begin
                if CurPos > 0 then Dec(CurPos);
                if CurPos < FirstPos then DrawFlag := true;
              end;
            kbRight:
              begin
                 if CurPos < Length(Data^) then begin
                    Inc(CurPos);
                    CheckValid(true);
                 end;
                 if CurPos >= FirstPos + (Size.X div 8) then DrawFlag := true;
              end;
            kbHome:
              begin
                 CurPos := 0;
                 if FirstPos > 0 then DrawFlag := true;
              end;
            kbEnd:
              begin
                CurPos := Length(Data^);
                CheckValid(True);
                if CurPos >= FirstPos + (Size.X div 8) then DrawFlag := true;
              end;
            kbBack:
              if CurPos > 0 then
              begin
                Delete(Data^, CurPos, 1);
                Dec(CurPos);
                if FirstPos > 0 then Dec(FirstPos);
                CheckValid(true);
                DrawFlag := true;
              end;
            kbDel:
              begin
                if SelStart = SelEnd then
                  if CurPos < Length(Data^) then
                  begin
                    SelStart := CurPos;
                    SelEnd := CurPos + 1;
                  end;
                DeleteSelect;
                CheckValid(true);
                DrawFlag := true;
              end;
            kbIns:
              SetState(sfCursorIns, State and sfCursorIns = 0);
          else
            case Event.CharCode of
              ' '..#255:
                begin
                  if State and sfCursorIns <> 0 then
                    Delete(Data^, CurPos + 1, 1) else DeleteSelect;
                  if CheckValid(true) then
                  begin
                  if Length(Data^) < MaxLen then
                     begin
                       if FirstPos > CurPos then FirstPos := CurPos;
                       Inc(CurPos);
                       Insert(Event.CharCode, Data^, CurPos);
                     end;
                     CheckValid(true);
                     DrawFlag := true;
                  end;
                end;
              ^Y:
                begin
                  Data^ := '';
                  CurPos := 0;
                end;
            else
              Exit;
            end
          end;
          if ExtendBlock then
            AdjustSelectBlock
          else
          begin
            SelStart := CurPos;
            SelEnd := CurPos;
          end;
          if FirstPos > CurPos then FirstPos := CurPos;
          I := CurPos - (Size.X div 8);
          if FirstPos < I then begin
             FirstPos := I;
             DrawFlag := true;
          end;
          HideMouse;
          SetCursor((CurPos - FirstPos)*8 , 0);
          ShowMouse;
          if DrawFlag then begin
             DrawView;
          end;
          ClearEvent(Event);
        end;
    end;
end;

procedure GraphInputLine.SelectAll(Enable: Boolean);
begin
  CurPos := 0;
  FirstPos := 0;
  SelStart := 0;
  if Enable then SelEnd := Length(Data^) else SelEnd := 0;
  DrawView;
end;

procedure GraphInputLine.SetData(var Rec);
begin
  if (Validator = nil) or
    (Validator^.Transfer(Data^, @Rec, vtSetData) = 0) then
     Move(Rec, Data^[0], DataSize);
  SelectAll(True);
end;

procedure GraphInputLine.SetState(AState: Word; Enable: Boolean);
begin
  GraphView.SetState(AState, Enable);
  if (AState = sfSelected) or ((AState = sfActive) and
    (State and sfSelected <> 0)) then SelectAll(Enable)
  else if AState = sfFocused then
    DrawView;
end;

procedure GraphInputLine.SetValidator(AValid: PValidator);
begin
  if Validator <> nil then Validator^.Free;
  Validator := AValid;
end;

procedure GraphInputLine.Store(var S: TStream);
begin
  GraphView.Store(S);
  S.Write(MaxLen, SizeOf(Integer) * 5);
  S.WriteStr(Data);
  S.Put(Validator);
end;

function GraphInputLine.Valid(Command: Word): Boolean;
begin
  Valid := inherited Valid(Command);
  if (Validator <> nil) and (State and sfDisabled = 0) then
    if Command = cmValid then
      Valid := Validator^.Status = vsOk
    else if Command <> cmCancel then
      if not Validator^.Valid(Data^) then
      begin
        Select;
        Valid := False;
      end;
end;

{ GraphTwoStateButton }

constructor GraphTwoStateButton.Load(var S : TStream);
begin
   GraphView.Load(S);
   S.Read(Checked,SizeOf(Boolean));
end;

procedure GraphTwoStateButton.Check;
begin
   SetCheck(true);
end;

procedure GraphTwoStateButton.GetData(var Rec);
begin
   boolean(Rec) := Checked;
end;

function GraphTwoStateButton.DataSize : word;
begin
   DataSize := SizeOf(boolean);
end;

procedure GraphTwoStateButton.Draw;
begin
   DrawState(Down);
end;

procedure GraphTwoStateButton.DrawState(Pressed: boolean);
begin
end;

procedure GraphTwoStateButton.HandleEvent(var Event: TEvent);
var
  Mouse: TPoint;
  ClickRect: TRect;
begin
  GetExtent(ClickRect);
  if Event.What = evMouseDown then
  begin
    MakeLocal(Event.Where, Mouse);
    if not ClickRect.Contains(Mouse) then ClearEvent(Event);
  end;
  GraphView.HandleEvent(Event);
  case Event.What of
    evMouseDown:
      begin
        Down := False;
        repeat
          MakeLocal(Event.Where, Mouse);
          if Down <> ClickRect.Contains(Mouse) then
          begin
            Down := not Down;
            DrawView;
          end;
        until not MouseEvent(Event, evMouseMove);
        if Down then
        begin
          Press;
          Down := false;
          DrawView;
        end;
        ClearEvent(Event);
      end;
    evKeyDown :
      if (State and sfFocused <> 0) and (Event.CharCode = ' ') then
      begin
         Down := true;
         DrawView;
			Press;
         Down := false;
         DrawView;
         ClearEvent(Event);
      end;
  end;
end;

procedure GraphTwoStateButton.Press;
begin
   Toggle;
end;

procedure GraphTwoStateButton.SetData(var Rec);
begin
   Checked := boolean(Rec);
   DrawView;
end;

procedure GraphTwoStateButton.SetCheck(CheckState : boolean);
begin
   Checked := CheckState;
end;

procedure GraphTwoStateButton.Store(var S : TStream);
begin
   GraphView.Store(S);
   S.Write(Checked,SizeOf(Boolean));
end;

procedure GraphTwoStateButton.Toggle;
begin
   SetCheck(not Checked);
end;

procedure GraphTwoStateButton.UnCheck;
begin
   SetCheck(false);
end;

const
   cmSetControls = 80;

{ ClusterControl - internal object used by GraphCluster descendants }

type
   PClusterControl = ^ClusterControl;
   ClusterControl = object(GraphTwoStateButton)
     ID : integer;
     constructor Init(var Bounds : TRect; AID : integer);
     procedure DrawState(Pressed : boolean); virtual;
     procedure HandleEvent(var Event : TEvent); virtual;
     procedure Press; virtual;
   end;

   PClusterLabel = ^ClusterLabel;
   ClusterLabel = object(Graphlabel)
      procedure Draw; virtual;
      function GetPalette : PPalette; virtual;
      procedure HandleEvent(var Event : TEvent); virtual;
   end;

const

  RClusterControl: TStreamRec = (
     ObjType: 27;
     VmtLink: Ofs(TypeOf(ClusterControl)^);
     Load:    @ClusterControl.Load;
     Store:   @ClusterControl.Store
  );

  RClusterLabel: TStreamRec = (
     ObjType: 28;
     VmtLink: Ofs(TypeOf(ClusterLabel)^);
     Load:    @ClusterLabel.Load;
     Store:   @ClusterLabel.Store
  );

{ ClusterControl methods }

constructor ClusterControl.Init(var Bounds : TRect; AID : integer);
begin
   GraphTwoStateButton.Init(Bounds);
   Options := Options or (ofSelectable + ofFirstClick +
   ofPreProcess + ofPostProcess);
   EventMask := EventMask or evBroadcast;
   ID := AId;
end;

procedure ClusterControl.DrawState(Pressed : boolean);
var
   i : integer;
   R : TRect;
   P : pointer;
begin
   if Checked then i := 1 else i := 0;
   if Pressed then inc(i,2);
   GetBounds(R);
   if Owner <> nil then PGraphCluster(Owner)^.DrawItem(R,i);
end;

procedure ClusterControl.HandleEvent(var Event : TEvent);
begin
   GraphTwoStateButton.HandleEvent(Event);
   if (Event.What = evBroadcast) and (Event.Command = cmSetControls)
   then begin
      SetCheck(PGraphCluster(Owner)^.Mark(ID));
      if Checked then Select;
      DrawView;
   end;
end;

procedure ClusterControl.Press;
begin
   PGraphCluster(Owner)^.Press(@Self);
   DrawView;
end;

{ ClusterLabel methods }

procedure ClusterLabel.Draw;
var
  Center : boolean;
  Color1,Color: Word;
  S : string;
  i,j : integer;
  StartPoint : TPoint;
  R : TRect;
begin
  S := Text^;
  Center := False;
  if S[1] = #3 then begin
     Center := true;
     S := Copy(S,2,Length(S)-1);
  end;
  if State and sfDisabled <> 0 then begin
     Color1 := GetColor(5);
     Color := Color1;
  end else begin
     Color1 := GetColor(4);
     if Light then Color := GetColor(2)
     else Color := GetColor(3);
  end;
  GFonts.SetTextStyle(Font,HorizDir,CharSize);
  SetTextJustify(LeftText,CenterText);
  i := TextWidth(S);
  j := (Size.X - i) div 2;
  StartPoint.X := 3;
  StartPoint.Y := Size.Y div 2+1;
  GetExtent(R);
  SetFillStyle(SolidFill,GetColor(1));
  if not CanFillBackground then Bar(R);
  if Center then inc(StartPoint.X,j);
  WriteCTextXY(StartPoint,S,Color,Color1);
end;

function ClusterLabel.GetPalette : PPalette;
const
   P : String[Length(CClusterLabel)] = CClusterLabel;
begin
   GetPalette := @P;
end;

procedure ClusterLabel.HandleEvent(var Event : TEvent);
var
   E : TEvent;
begin
   E := Event;
   GraphLabel.HandleEvent(Event);
   if E.What = evMouseDown then begin
      if Link <> nil then PClusterControl(Link)^.Press;
   end;
end;

{ GraphCluster }

constructor GraphCluster.Init(var Bounds: TRect; AStrings: PSItem);
var
  I,J,R,C: Integer;
  P: PSItem;
  Cols,Rows,H,W : integer;
  R1 : TRect;
  ItemSize : TPoint;
begin
  GraphGroup.Init(Bounds);
  Options := Options or (ofSelectable + ofFirstClick);
  GetExtent(R1);
  Insert(New(PGraphGrayGroup,Init(R1)));
  I := 0;
  P := AStrings;
  while P <> nil do
  begin
    Inc(I);
    P := P^.Next;
  end;
  GetItemSize(ItemSize);
  Cols := 1;
  j := Size.Y div ItemSize.Y;
  if j < i then begin
     Cols := i div j;
     if (i mod j) > 0 then inc(Cols);
  end;
  Rows := i div Cols;
  if (i mod Cols) > 0 then inc(Rows);
  H := Size.Y div Rows;
  W := Size.X div Cols;
  i := 0;
  while AStrings <> nil do
  begin
    P := AStrings;
    R := i div Cols;
    C := i mod Cols;
    R1.Assign(W*C,H*R,W*(C+1),H*(R+1));
    InsertItem(R1,AStrings^.Value^,i+1);
    DisposeStr(AStrings^.Value);
    AStrings := AStrings^.Next;
    Dispose(P);
    inc(i);
  end;
  Value := 0;
end;

constructor GraphCluster.Load(var S : TStream);
begin
   GraphGroup.Load(S);
   S.Read(Value,SizeOf(Word) + SizeOf(Integer));
end;

function GraphCluster.GetHelpCtx: Word;
begin
  GetHelpCtx := HelpCtx + Sel;
end;

procedure GraphCluster.GetItemSize(var ItemSize : TPoint);
begin
  Abstract;
end;

function GraphCluster.GetPalette : PPalette;
const
   P : String[Length(CCluster)] = CCluster;
begin
   GetPalette := @P;
end;

function GraphCluster.NewControl(Bounds : TRect; AId : integer): PGraphView;
begin
  Abstract;
end;

procedure GraphCluster.DrawItem(Bounds : Trect; AI : integer);
var
  P : Pointer;
  ClipRect : TRect;
begin
   if Images <> nil then begin
      P := Images^.At(Ai);
      GetClipRect(ClipRect);
      SetDrawPort(ClipRect);
      DrawImg(Bounds.A,PImage(P),NormalPut);
   end;
end;

procedure GraphCluster.InsertItem(Bounds : TRect; ItemLabel : String; AId : integer);
var
   ItemSize : TPoint;
   L : integer;
   R,R1 : TRect;
   P : PGraphView;
begin
   GetItemSize(ItemSize);
   R.Copy(Bounds);
   R.Grow(-8,0);
   L := (R.B.Y - R.A.Y -ItemSize.Y) div 2;
   with R do R1.Assign(A.X,A.Y+L,A.X + ItemSize.X,B.Y -L);
   P := NewControl(R1,AId);
   Insert(P);
   with R1 do R.Assign(B.X+7,A.Y,Bounds.B.X-8,A.Y + ItemSize.Y);
   Insert(New(PClusterLabel,Init(R,ItemLabel,P)));
end;

function GraphCluster.DataSize: Word;
begin
  DataSize := SizeOf(Value);
end;

procedure GraphCluster.GetData(var Rec);
begin
  Word(Rec) := Value;
end;

procedure GraphCluster.SetData(var Rec);
begin
  Value := Word(Rec);
  Message(@Self,evBroadcast,cmSetControls,nil);
end;

function GraphCluster.Mark(Item: Integer): Boolean;
begin
  Mark := False;
end;

procedure GraphCluster.Press(Control: PGraphView);
begin
end;

procedure GraphCluster.Store(var S : TStream);
begin
  GraphGroup.Store(S);
  S.Write(Value, SizeOf(Word) + SizeOf(Integer));
end;

{ GraphRadioButtons methods }

constructor GraphRadioButtons.Init(var Bounds : TRect; AStrings : PSItem);
begin
   GraphCluster.Init(Bounds,AStrings);
   Value := 1;
   Message(@Self,evBroadcast,cmSetControls,nil);
   Images := PCollection(StdSharedResource^.Get('RADIOBUTTON'));
end;

constructor GraphRadioButtons.Load(var S : TStream);
begin
   GraphCluster.Load(S);
   Images := PCollection(StdSharedResource^.Get('RADIOBUTTON'));end;

destructor GraphRadioButtons.Done;
begin
   StdSharedResource^.Free('RADIOBUTTON');
   GraphCluster.Done;
end;

procedure GraphRadioButtons.GetItemSize(var ItemSize : TPoint);
begin
   with ItemSize do begin
      X := 13;
      Y := 13;
   end;
end;

procedure GraphRadioButtons.HandleEvent(var Event : TEvent);
begin
   GraphCluster.HandleEvent(Event);
   if Event.What = evKeyDown then begin
      case Event.KeyCode of
         kbDown,
         kbUp   :
           begin
              SelectNext(Event.KeyCode = kbUp);
              if Current <> nil then PClusterControl(Current)^.Press;
              ClearEvent(Event);
           end;
      end;
   end;
end;

function GraphRadioButtons.NewControl(Bounds : TRect; AId : integer): PGraphView;
begin
   NewControl := New(PClusterControl,Init(Bounds,AId));
end;

function GraphRadioButtons.Mark(Item : Integer): boolean;
begin
   Mark := (Item = Value);
end;

procedure GraphRadioButtons.Press(Control : PGraphView);
begin
   if Value <> PClusterControl(Control)^.ID then
   begin
      Value := 0;
      Message(@Self,evBroadcast,cmSetControls,nil);
      Value := PClusterControl(Control)^.ID;
      PClusterControl(Control)^.Check;
   end;
end;

{ GraphCheckBoxes methods }

constructor GraphCheckBoxes.Init(var Bounds : TRect; AStrings : PSItem);
begin
   GraphCluster.Init(Bounds,AStrings);
   Message(@Self,evBroadcast,cmSetControls,nil);
   Images := PCollection(StdSharedResource^.Get('CHECKBOX'));
   SelectNext(false);
end;

constructor GraphCheckBoxes.Load(var S : TStream);
begin
   GraphCluster.Load(S);
   Images := PCollection(StdSharedResource^.Get('CHECKBOX'));
end;

destructor GraphCheckBoxes.Done;
begin
   StdSharedResource^.Free('CHECKBOX');
   GraphCluster.Done;
end;

procedure GraphCheckBoxes.GetItemSize(var ItemSize : TPoint);
begin
   with ItemSize do begin
      X := 13;
      Y := 13;
   end;
end;

procedure GraphCheckBoxes.HandleEvent(var Event : TEvent);
begin
   GraphCluster.HandleEvent(Event);
   if Event.What = evKeyDown then begin
      case Event.KeyCode of
         kbDown,
         kbUp   :
           begin
              SelectNext(Event.KeyCode = kbUp);
              ClearEvent(Event);
           end;
      end;
   end;
end;

function GraphCheckBoxes.NewControl(Bounds : TRect; AId : integer): PGraphView;
begin
   NewControl := New(PClusterControl,Init(Bounds,AId));
end;

function GraphCheckBoxes.Mark(Item : Integer): boolean;
var
   Mask : word;
begin
   Mask := 1;
   Mark := (Value and (Mask shl (Item-1))) <> 0;
end;

procedure GraphCheckBoxes.Press(Control : PGraphView);
var
   Mask : word;
begin
   Mask := 1;
   Mask := Mask shl (PClusterControl(Control)^.ID-1);
   Value := Value xor Mask;
   PClusterControl(Control)^.Toggle;
end;

{ GraphStaticBitmap }

constructor GraphStaticBitmap.Init(var Bounds : Trect; AName : string);
begin
   GraphView.Init(Bounds);
   Name := NewStr(AName);
   Image := PImage(StdSharedResource^.Get(AName));
end;

constructor GraphStaticBitmap.Load(var S: TStream);
begin
   GraphView.Load(S);
   Name := S.ReadStr;
   Image := PImage(StdSharedResource^.Get(Name^));
end;

destructor GraphStaticBitmap.Done;
begin
   if Image <> nil then StdSharedResource^.Free(Name^);
   DisposeStr(Name);
   GraphView.Done;
end;

procedure GraphStaticBitmap.Draw;
var
   R : TRect;
begin
   if Image <> nil then begin
      GetExtent(R);
      DrawImg(R.A,Image,NormalPut);
   end;
end;

procedure GraphStaticBitmap.Store(var S : TStream);
begin
   GraphView.Store(S);
   S.WriteStr(Name);
end;

{ GraphHistoryViewer }

constructor GraphHistoryViewer.Init(var Bounds: TRect; AHScrollBar,
  AVScrollBar: PGraphScrollBar; AHistoryId: Word);
begin
  GraphListViewer.Init(Bounds, 1, AHScrollBar, AVScrollBar);
  HistoryId := AHistoryId;
  SetRange(HistoryCount(AHistoryId));
  if Range > 1 then FocusItem(1);
  HScrollBar^.SetRange(1, HistoryWidth-(Size.X div 8) + 3);
end;

function GraphHistoryViewer.GetPalette: PPalette;
const
  P: String[Length(CHistoryViewer)] = CHistoryViewer;
begin
  GetPalette := @P;
end;

procedure GraphHistoryViewer.DrawItem(Item : Integer);
var
   ColWidth : integer;
   R : TRect;
   i,j : integer;
   TextColor,BackColor : word;
   P,ItemSize : TPoint;
   Text : String;
   Indent : integer;
begin
   if HScrollBar <> nil then Indent := HScrollBar^.Value
   else Indent := 0;
   GetItemSize(ItemSize);
   GetItemRect(Item,R);
   GFonts.SetTextStyle(SystemFont,HorizDir,1);
   SetTextJustify(LeftText,Centertext);
   if State and (sfSelected + sfActive + sfFocused) = (sfSelected + sfActive + sfFocused) then
   begin
      if IsSelected(Item) then begin
         TextColor := GetColor(4);
         BackColor := GetColor(3);
      end else begin
         TextColor := GetColor(2);
         BackColor := GetColor(1);
      end;
   end else
   begin
      if IsSelected(Item) then TextColor :=GetColor(4) else TextColor := GetColor(2);
      BackColor := GetColor(1);
   end;
   SetFillStyle(SolidFill,BackColor);
   Bar(R);
   SetColor(TextColor);
   P := R.A;
   P.Y := P.Y + (ItemSize.Y div 2);
   Text := GetText(Item,R.B.X-R.A.X);
   Text := Copy(Text,Indent,ColWidth);
   WriteTextXY(P,Text);
end;

procedure GraphHistoryViewer.GetItemSize(var ItemSize : TPoint);
begin
   with ItemSize do begin
      Y := TextHeight(' ');
      if Y = 8 then inc(Y,2);
      X := Size.X div NumCols;
   end;
end;

function GraphHistoryViewer.GetText(Item: Integer; MaxLen: Integer): String;
begin
  GetText := HistoryStr(HistoryId, Item);
end;

procedure GraphHistoryViewer.HandleEvent(var Event: TEvent);
begin
  if ((Event.What = evMouseDown) and (Event.Double)) or
     ((Event.What = evKeyDown) and (Event.KeyCode = kbEnter)) then
  begin
    EndModal(cmOk);
    ClearEvent(Event);
  end else if ((Event.What = evKeyDown) and (Event.KeyCode = kbEsc)) or
    ((Event.What = evCommand) and (Event.Command = cmCancel)) then
  begin
    EndModal(cmCancel);
    ClearEvent(Event);
  end else
  GraphListViewer.HandleEvent(Event);
end;

function GraphHistoryViewer.HistoryWidth: Integer;
var
  Width, T, Count, I: Integer;
begin
  Width := 0;
  Count := HistoryCount(HistoryId);
  for I := 0 to Count-1 do
  begin
    T := Length(HistoryStr(HistoryId, I));
    if T > Width then Width := T;
  end;
  HistoryWidth := Width;
end;

{ GraphHistoryWindow }

constructor GraphHistoryWindow.Init(var Bounds: TRect; HistoryId: Word);
var
  S : string;
begin
  Str(HistoryId,S);
  GraphWindow.Init(Bounds, 'History '+S, wfThinFrame);
  InitViewer(HistoryId);
end;

function GraphHistoryWindow.GetPalette: PPalette;
const
  P: String[Length(CHistoryWindow)] = CHistoryWindow;
begin
  GetPalette := @P;
end;

function GraphHistoryWindow.GetSelection: String;
begin
  GetSelection := Viewer^.GetText(Viewer^.Focused,255);
end;

procedure GraphHistoryWindow.InitViewer(HistoryId: Word);
var
  R: TRect;
  H,V : PGraphScrollBar;
begin
  V := StandardScrollBar(sbVertical + sbHandleKeyboard);
  H := StandardScrollBar(sbHorizontal + sbHandleKeyboard);
  Workspace^.GetExtent(R);
  R.Grow(-1,-1);
  Viewer := New(PGraphHistoryViewer, Init(R,H,V,HistoryId));
  Insert(Viewer);
end;

{ GraphHistory }

constructor GraphHistory.Init(var Bounds: TRect; ALink: PGraphInputLine;
  AHistoryId: Word);
begin
  GraphView.Init(Bounds);
  Images := PCollection(StdSharedResource^.Get('DOWN'));
  Options := Options or ofPostProcess;
  EventMask := EventMask or evBroadcast;
  Link := ALink;
  HistoryId := AHistoryId;
  Down := false;
end;

destructor GraphHistory.Done;
begin
   if Images <> nil then StdSharedResource^.Free('DOWN');
   GraphView.Done;
end;

constructor GraphHistory.Load(var S: TStream);
var
   Filter : PFilter;
   i,NumOfStates : integer;
begin
  GraphView.Load(S);
  GetPeerViewPtr(S, Link);
  S.Read(HistoryId, SizeOf(Word));
  Images := PCollection(StdSharedResource^.Get('DOWN'));
end;

procedure GraphHistory.Draw;
begin
  DrawState(Down);
end;

procedure GraphHistory.DrawState(Pushed : boolean);
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

function GraphHistory.GetPalette: PPalette;
const
  P: String[Length(CHistory)] = CHistory;
begin
  GetPalette := @P;
end;

procedure GraphHistory.HandleEvent(var Event: TEvent);
var
   ClickRect : TRect;
   Mouse : TPoint;
begin
  GetExtent(ClickRect);
  GraphView.HandleEvent(Event);
  case Event.What of
    evMouseDown:
      begin
        Down := False;
        repeat
          MakeLocal(Event.Where, Mouse);
          if Down <> ClickRect.Contains(Mouse) then
          begin
            Down := not Down;
            DrawView;
          end;
        until not MouseEvent(Event, evMouseMove + evMouseAuto);
        if Down then
        begin
          Press;
          Down := false;
          DrawView;
        end;
        ClearEvent(Event);
      end;
   evKeyDown:
     if (CtrlToArrow(Event.KeyCode) = kbDown) and
     (Link^.State and sfFocused <> 0) then
     begin
        Down := true;
        DrawView;
		  Press;
        Down := false;
        DrawView;
        ClearEvent(Event);
     end;
   evBroadcast:
      if ((Event.Command = cmReleasedFocus) and (Event.InfoPtr = Link))
      or (Event.Command = cmRecordHistory) then
      HistoryAdd(HistoryId, Link^.Data^);
   end;
end;

function GraphHistory.InitHistoryWindow(var Bounds: TRect): PGraphHistoryWindow;
var
  P: PGraphHistoryWindow;
begin
  P := New(PGraphHistoryWindow, Init(Bounds, HistoryId));
  P^.HelpCtx := Link^.HelpCtx;
  InitHistoryWindow := P;
end;

procedure GraphHistory.Press;
var
  HistoryWindow: PGraphHistoryWindow;
  R,P: TRect;
  C: Word;
  Rslt: String;
begin
   Link^.Select;
   HistoryAdd(HistoryId, Link^.Data^);
   Link^.GetBounds(R);
   Inc(R.B.Y,104);
   Owner^.GetExtent(P);
   if R.B.Y > P.B.Y then R.Move(0,-(R.B.Y-P.B.Y));
   R.Intersect(P);
   R.Grow(2,0);
   inc(R.B.X,16);
   HistoryWindow := InitHistoryWindow(R);
   if HistoryWindow <> nil then
   begin
      C := Owner^.ExecView(HistoryWindow);
      if C = cmOk then
      begin
        Rslt := HistoryWindow^.GetSelection;
        if Length(Rslt) > Link^.MaxLen then Rslt[0] := Char(Link^.MaxLen);
        Link^.Data^ := Rslt;
        Link^.SelectAll(True);
        Link^.DrawView;
      end;
      Dispose(HistoryWindow, Done);
   end;
end;

procedure GraphHistory.Store(var S: TStream);
begin
  GraphView.Store(S);
  PutPeerViewPtr(S, Link);
  S.Write(HistoryId, SizeOf(Word));
end;

procedure RegisterControls;
begin
   RegisterType(RGraphDialog);
   RegisterType(RGraphButton);
   RegisterType(RGraphTextButton);
   RegisterType(RGraphBitmapButton);
   RegisterType(RGraphListBox);
   RegisterType(RTextListBox);
   RegisterType(RGraphStaticText);
   RegisterType(RGraphParamText);
   RegisterType(RGraphlabel);
   RegisterType(RGraphInputLine);
   RegisterType(RGraphStaticBitmap);
   RegisterType(RClusterControl);
   RegisterType(RClusterLabel);
   RegisterType(RGraphCluster);
   RegisterType(RGraphHistory);
end;

end.