{************************************************}
{   Gramenu.pas                                  }
{   Graph Vision unit                            }
{   Sergey E. Levov, Moscow,1992-1994            }
{   Portions copyright (c) 1990 by Borland Int.  }
{************************************************}

unit GraMenu;

{$O+,F+,X+,I-,S-,D-}

interface

uses Graph, Objects, ExtObj, EventMan, GraV;

const
   CMenuView = #04#05#06#07#08#09#10#11#12;
   CStatusLine = #04#05#06#07#08#09#10#11#12;

type

{ TMenu types }

  TMenuStr = string[31];

  PMenu = ^TMenu;

  PMenuItem = ^TMenuItem;
  TMenuItem = record
    Next: PMenuItem;
    Name: PString;
    Command: Word;
    Disabled: Boolean;
    KeyCode: Word;
    HelpCtx: Word;
    case Integer of
      0: (Param: PString);
      1: (SubMenu: PMenu);
  end;

  TMenu = record
    Items: PMenuItem;
    Default: PMenuItem;
  end;

{ GraphMenuView object }

  PGraphMenuView = ^GraphMenuView;
  GraphMenuView = object(GraphView)
    ParentMenu: PGraphMenuView;
    Menu: PMenu;
    Current: PMenuItem;
    constructor Init(var Bounds: TRect);
    constructor Load(var S: TStream);
    procedure ChangeMouseCursor; virtual;
    function Execute: Word; virtual;
    function FindItem(Ch: Char): PMenuItem;
    function GetHelpCtx : word; virtual;
    procedure GetItemRect(Item: PMenuItem; var R: TRect); virtual;
    function GetPalette : PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function HotKey(KeyCode: Word): PMenuItem;
    function NewSubView(var Bounds: TRect; AMenu: PMenu;
      AParentMenu: PGraphMenuView): PGraphMenuView; virtual;
    procedure Store(var S: TStream);
    private
    MenuMouse : PMouseCursor;
    AutoSelectEnabled : boolean;
    procedure DrawItem(Item : PMenuItem); virtual;
    procedure RedrawItem(Item : PMenuItem);
  end;

{ GraphMenuBar object }

  PGraphMenuBar = ^GraphMenuBar;
  GraphMenuBar = object(GraphMenuView)
    constructor Init(var Bounds: TRect; AMenu: PMenu);
    destructor Done; virtual;
    procedure Draw; virtual;
    procedure GetItemRect(Item: PMenuItem; var R: TRect); virtual;
    private
    procedure DrawItem(Item : PMenuItem); virtual;
  end;

{ GraphMenuBox object }

  PGraphMenuBox = ^GraphMenuBox;
  GraphMenuBox = object(GraphMenuView)
    constructor Init(var Bounds: TRect; AMenu: PMenu;
      AParentMenu: PGraphMenuView);
    procedure Draw; virtual;
    procedure GetItemRect(Item: PMenuItem; var R: TRect); virtual;
    private
    procedure DrawItem(Item : PMenuItem); virtual;
  end;

{ TStatusItem }

  PStatusItem = ^TStatusItem;
  TStatusItem = record
    Next: PStatusItem;
    Text: PString;
    KeyCode: Word;
    Command: Word;
  end;

{ TStatusDef }

  PStatusDef = ^TStatusDef;
  TStatusDef = record
    Next: PStatusDef;
    Min, Max: Word;
    Items: PStatusItem;
  end;

{ TStatusLine }

  { Palette layout }
  { 1 = Normal text }
  { 2 = Disabled text }
  { 3 = Shortcut text }
  { 4 = Normal selection }
  { 5 = Disabled selection }
  { 6 = Shortcut selection }

  PGraphStatusLine = ^GraphStatusLine;
  GraphStatusLine = object(GraphView)
    Items: PStatusItem;
    Defs: PStatusDef;
    constructor Init(var Bounds: TRect; ADefs: PStatusDef);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Draw; virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function Hint(AHelpCtx: Word): String; virtual;
    procedure Store(var S: TStream);
    procedure Update; virtual;
  private
    procedure DrawSelect(Selected: PStatusItem);
    procedure FindItems;
  end;


{ TMenuItem routines }

function NewItem(Name, Param: TMenuStr; KeyCode: Word; Command: Word;
  AHelpCtx: Word; Next: PMenuItem): PMenuItem;
function NewLine(Next: PMenuItem): PMenuItem;
function NewSubMenu(Name: TMenuStr; AHelpCtx: Word; SubMenu: PMenu;
  Next: PMenuItem): PMenuItem;

{ TMenu routines }

function NewMenu(Items: PMenuItem): PMenu;
procedure DisposeMenu(Menu: PMenu);

{ GraphStatusLine routines }

function NewStatusDef(AMin, AMax: Word; AItems: PStatusItem;
  ANext: PStatusDef): PStatusDef;
function NewStatusKey(AText: String; AKeyCode: Word; ACommand: Word;
  ANext: PStatusItem): PStatusItem;


{ Menus registration routine }

procedure RegisterMenus;

var
   MenuItemHeight : integer;
   StatusItemHeight : integer;
   LineHeight : integer;
const

{ Menus registration records }

  RGraphMenuBar: TStreamRec = (
     ObjType: 40;
     VmtLink: Ofs(TypeOf(GraphMenuBar)^);
     Load:    @GraphMenuBar.Load;
     Store:   @GraphMenuBar.Store
  );

  RGraphMenuBox: TStreamRec = (
     ObjType: 41;
     VmtLink: Ofs(TypeOf(GraphMenuBox)^);
     Load:    @GraphMenuBox.Load;
     Store:   @GraphMenuBox.Store
  );

  RGraphStatusLine: TStreamRec = (
     ObjType: 42;
     VmtLink: Ofs(TypeOf(GraphStatusLine)^);
     Load:    @GraphStatusLine.Load;
     Store:   @GraphStatusLine.Store
  );

implementation
uses GrDriver,GFonts;

{ TMenuItem routines }

function NewItem(Name, Param: TMenuStr; KeyCode: Word; Command: Word;
  AHelpCtx: Word; Next: PMenuItem): PMenuItem;
const
  T : PGraphView = nil;
var
  P: PMenuItem;
begin
  if (Name <> '') and (Command <> 0) then
  begin
    New(P);
    P^.Next := Next;
    P^.Name := NewStr(Name);
    P^.Command := Command;
    P^.Disabled := not T^.CommandEnabled(Command);
    P^.KeyCode := KeyCode;
    P^.HelpCtx := AHelpCtx;
    P^.Param := NewStr(Param);
    NewItem := P;
  end else
  NewItem := Next;
end;

function NewLine(Next: PMenuItem): PMenuItem;
var
  P: PMenuItem;
begin
  New(P);
  P^.Next := Next;
  P^.Name := nil;
  P^.HelpCtx := hcNoContext;
  NewLine := P;
end;

function NewSubMenu(Name: TMenuStr; AHelpCtx: Word; SubMenu: PMenu;
  Next: PMenuItem): PMenuItem;
var
  P: PMenuItem;
  i : integer;
begin
  if (Name <> '') and (SubMenu <> nil) then
  begin
    New(P);
    P^.Next := Next;
    P^.Name := NewStr(Name);
    P^.Command := 0;
    P^.Disabled := False;
    P^.HelpCtx := AHelpCtx;
    P^.SubMenu := SubMenu;
    NewSubMenu := P;
  end else
  NewSubMenu := Next;
end;

{ TMenu routines }

function NewMenu(Items: PMenuItem): PMenu;
var
  P: PMenu;
begin
  New(P);
  P^.Items := Items;
  P^.Default := Items;
  NewMenu := P;
end;

procedure DisposeMenu(Menu: PMenu);
var
  P, Q: PMenuItem;
begin
  if Menu <> nil then
  begin
    P := Menu^.Items;
    while P <> nil do
    begin
      if P^.Name <> nil then
      begin
        DisposeStr(P^.Name);
        if P^.Command <> 0 then
          DisposeStr(P^.Param) else
          DisposeMenu(P^.SubMenu);
      end;
      Q := P;
      P := P^.Next;
      Dispose(Q);
    end;
    Dispose(Menu);
  end;
end;

{ GraphMenuView }

constructor GraphMenuView.Init(var Bounds: TRect);
begin
  GraphView.Init(Bounds);
  EventMask := EventMask or (evBroadcast + evMouseMove);
  AutoSelectEnabled := false;
  MenuMouse := PMouseCursor(StdSharedResource^.Get('POINTINGHAND'));
end;

constructor GraphMenuView.Load(var S: TStream);

function DoLoadMenu: PMenu;
var
  Item: PMenuItem;
  Last: ^PMenuItem;
  Menu: PMenu;
  Tok: Byte;
begin
  New(Menu);
  Last := @Menu^.Items;
  Item := nil;
  S.Read(Tok,1);
  while Tok <> 0 do
  begin
    New(Item);
    Last^ := Item;
    Last := @Item^.Next;
    with Item^ do
    begin
      Name := S.ReadStr;
      S.Read(Command, SizeOf(Word) * 3 + SizeOf(Boolean));
      if (Name <> nil) then
        if Command = 0 then SubMenu := DoLoadMenu
        else Param := S.ReadStr;
    end;
    S.Read(Tok, 1);
  end;
  Last^ := nil;
  Menu^.Default := Menu^.Items;
  DoLoadMenu := Menu;
end;

begin
  GraphView.Load(S);
  S.Read(AutoSelectEnabled,SizeOf(Boolean));
  Menu := DoLoadMenu;
  MenuMouse := PMouseCursor(StdSharedResource^.Get('POINTINGHAND'));
end;

procedure GraphMenuView.ChangeMouseCursor;
begin
   if MenuMouse <> nil then begin
      if MouseOwner <> @Self then begin
         MenuMouse^.MakeActive;
         MouseOwner := @Self;
      end;
   end;
end;

function GraphMenuView.Execute: Word;
type
  MenuAction = (DoNothing, DoSelect, DoReturn);
var
  AutoSelect: Boolean;
  Action: MenuAction;
  Ch: Char;
  Result: Word;
  ItemShown, P: PMenuItem;
  Target: PGraphMenuView;
  R: TRect;
  E: TEvent;

procedure TrackMouse;
var
  Mouse: TPoint;
  R: TRect;
begin
  MakeLocal(E.Where, Mouse);
  Current := Menu^.Items;
  while Current <> nil do
  begin
    GetItemRect(Current, R);
    if R.Contains(Mouse) then Exit;
    Current := Current^.Next;
  end;
end;

procedure TrackKey(FindNext: Boolean);

procedure NextItem;
begin
  Current := Current^.Next;
  if Current = nil then Current := Menu^.Items;
end;

procedure PrevItem;
var
  P: PMenuItem;
begin
  P := Current;
  if P = Menu^.Items then P := nil;
  repeat NextItem until Current^.Next = P;
end;

begin
  if Current <> nil then
    repeat
      if FindNext then NextItem else PrevItem;
    until Current^.Name <> nil;
end;

function MouseInOwner: Boolean;
var
  Mouse: TPoint;
  R: TRect;
begin
  MouseInOwner := False;
  if (ParentMenu <> nil) and ParentMenu^.AutoSelectEnabled then
  begin
    ParentMenu^.MakeLocal(E.Where, Mouse);
    ParentMenu^.GetItemRect(ParentMenu^.Current, R);
    MouseInOwner := R.Contains(Mouse);
  end;
end;

function MouseInMenus: Boolean;
var
  P: PGraphMenuView;
begin
  P := ParentMenu;
  while (P <> nil) and not P^.MouseInView(E.Where) do P := P^.ParentMenu;
  MouseInMenus := P <> nil;
end;

function TopMenu: PGraphMenuView;
var
  P: PGraphMenuView;
begin
  P := @Self;
  while P^.ParentMenu <> nil do P := P^.ParentMenu;
  TopMenu := P;
end;

begin
  AutoSelect := False;
  Result := 0;
  ItemShown := nil;
  Current := Menu^.Default;
  repeat
    Action := DoNothing;
    GetEvent(E);
    case E.What of
      evMouseDown:
        if MouseInView(E.Where) or MouseInOwner then
        begin
          TrackMouse;
          AutoSelect := AutoSelectEnabled;
        end else Action := DoReturn;
      evMouseUp:
        begin
          TrackMouse;
          if MouseInOwner then Current := Menu^.Default else
            if (Current <> nil) and (Current^.Name <> nil) then
              Action := DoSelect else Action := DoReturn;
        end;
      evMouseMove:
        if E.Buttons <> 0 then
        begin
          TrackMouse;
          if not (MouseInView(E.Where) or MouseInOwner) and
            MouseInMenus then Action := DoReturn;
        end;
      evKeyDown:
        case CtrlToArrow(E.KeyCode) of
          kbUp, kbDown:
            if not AutoSelectEnabled then
              TrackKey(CtrlToArrow(E.KeyCode) = kbDown) else
              if E.KeyCode = kbDown then AutoSelect := True;
          kbLeft, kbRight:
            if ParentMenu = nil then
              TrackKey(CtrlToArrow(E.KeyCode) = kbRight) else
              Action := DoReturn;
          kbHome, kbEnd:
            if not AutoSelectEnabled then
            begin
              Current := Menu^.Items;
              if E.KeyCode = kbEnd then TrackKey(False);
            end;
          kbEnter:
            begin
              AutoSelect := AutoSelectEnabled;
              Action := DoSelect;
            end;
          kbEsc:
            begin
              Action := DoReturn;
              if (ParentMenu = nil) or not ParentMenu^.AutoSelectEnabled then
                ClearEvent(E);
            end;
        else
          Target := @Self;
          Ch := GetAltChar(E.KeyCode);
          if Ch = #0 then Ch := E.CharCode else Target := TopMenu;
          P := Target^.FindItem(Ch);
          if P = nil then
          begin
            P := TopMenu^.HotKey(E.KeyCode);
            if (P <> nil) and CommandEnabled(P^.Command) then
            begin
              Result := P^.Command;
              Action := DoReturn;
            end
          end else
            if Target = @Self then
            begin
              AutoSelect := AutoSelectEnabled;
              Action := DoSelect;
              Current := P;
            end else
              if (ParentMenu <> Target) or (ParentMenu^.Current <> P) then
                Action := DoReturn;
        end;
      evCommand:
        if E.Command = cmMenu then
        begin
          AutoSelect := False;
          if ParentMenu <> nil then Action := DoReturn;
        end else Action := DoReturn;
    end;
    if ItemShown <> Current then
    begin
      RedrawItem(ItemShown);
      ItemShown := Current;
      RedrawItem(Current);
    end;
    if (Action = DoSelect) or ((Action = DoNothing) and AutoSelect) then
      if Current <> nil then with Current^ do if Name <> nil then
        if Command = 0 then
        begin
          if E.What and (evMouseDown + evMouseMove) <> 0 then PutEvent(E);
          GetItemRect(Current, R);
          R.A.X := R.A.X + Origin.X;
          R.A.Y := R.B.Y + Origin.Y;
          R.B := Owner^.Size;
          if AutoSelectEnabled then Dec(R.A.X);
          Target := TopMenu^.NewSubView(R, SubMenu, @Self);
          Result := Owner^.ExecView(Target);
          Dispose(Target, Done);
        end else if Action = DoSelect then Result := Command;
    if (Result <> 0) and CommandEnabled(Result) then
    begin
      Action := DoReturn;
      ClearEvent(E);
    end;
  until Action = DoReturn;
  if E.What <> evNothing then
    if (ParentMenu <> nil) or (E.What = evCommand) then PutEvent(E);
  if Current <> nil then
  begin
    Menu^.Default := Current;
    Current := nil;
    RedrawItem(Menu^.Default);
  end;
  Execute := Result;
end;

function GraphMenuView.FindItem(Ch: Char): PMenuItem;
var
  P: PMenuItem;
  I: Integer;
begin
  Ch := UpCase(Ch);
  P := Menu^.Items;
  while P <> nil do
  begin
    if (P^.Name <> nil) and not P^.Disabled then
    begin
       I := Pos('~', P^.Name^);
       if (I <> 0) and (Ch = UpCase(P^.Name^[I + 1])) then
      begin
        FindItem := P;
        Exit;
      end;
    end;
    P := P^.Next;
  end;
  FindItem := nil;
end;

procedure GraphMenuView.GetItemRect(Item: PMenuItem; var R: TRect);
begin
end;

function GraphMenuView.GetPalette : PPalette;
const
  P: String[Length(CMenuView)] = CMenuView;
begin
  GetPalette := @P;
end;


procedure GraphMenuView.DrawItem(Item : PMenuItem);
begin
end;

procedure GraphMenuView.RedrawItem(Item : PMenuItem);
var
   R : TRect;
   OldClip : TRect;
   Hm : boolean;
begin
   if Item = nil then Exit;
   GetExtent(R);
   MakeGlobal(R.A,R.A);
   MakeGlobal(R.B,R.B);
   Hm := MouseInRect(R);
   GetItemRect(Item,R);
   R.Move(Origin.X,Origin.Y);
   OldClip.Copy(owner^.Clip);
   Owner^.Clip.Intersect(R);
   if not Hm then inc(LockMouseCursor);
   DrawView;
   if not Hm then dec(LockMouseCursor);
   Owner^.Clip.Copy(OldClip);
end;

function GraphMenuView.GetHelpCtx: Word;
var
  C: PGraphMenuView;
begin
  C := @Self;
  while (C <> nil) and
     ((C^.Current = nil) or (C^.Current^.HelpCtx = hcNoContext) or
      (C^.Current^.Name = nil)) do
    C := C^.ParentMenu;
  if C <> nil then GetHelpCtx := C^.Current^.HelpCtx
  else GetHelpCtx := hcNoContext;
end;

procedure GraphMenuView.HandleEvent(var Event: TEvent);
var
  CallDraw: Boolean;
  P: PMenuItem;

procedure UpdateMenu(Menu: PMenu);
var
  P: PMenuItem;
  CommandState: Boolean;
begin
  P := Menu^.Items;
  while P <> nil do
  begin
    if P^.Name <> nil then
      if P^.Command = 0 then UpdateMenu(P^.SubMenu)
      else
      begin
        CommandState := CommandEnabled(P^.Command);
        if P^.Disabled = CommandState then
        begin
          P^.Disabled := not CommandState;
        end;
      end;
    P := P^.Next;
  end;
end;

procedure DoSelect;
begin
  PutEvent(Event);
  Event.Command := Owner^.ExecView(@Self);
  if (Event.Command <> 0) and CommandEnabled(Event.Command) then
  begin
    Event.What := evCommand;
    Event.InfoPtr := nil;
    PutEvent(Event);
  end;
  ClearEvent(Event);
end;

begin
  GraphView.HandleEvent(Event);   {!!}
  if Menu <> nil then
    case Event.What of
      evMouseDown:
        DoSelect;
      evKeyDown:
        if (FindItem(GetAltChar(Event.KeyCode)) <> nil) then
          DoSelect
        else
        begin
          P := HotKey(Event.KeyCode);
          if (P <> nil) and (CommandEnabled(P^.Command)) then
          begin
            Event.What := evCommand;
            Event.Command := P^.Command;
            Event.InfoPtr := nil;
            PutEvent(Event);
            ClearEvent(Event);
          end;
        end;
      evCommand:
        if Event.Command = cmMenu then DoSelect;
      evBroadcast:
        if Event.Command = cmCommandSetChanged then
        begin
          CallDraw := False;
          UpdateMenu(Menu);
        end;
    end;
end;

function GraphMenuView.HotKey(KeyCode: Word): PMenuItem;

function FindHotKey(P: PMenuItem): PMenuItem;
var
  T: PMenuItem;
begin
  while P <> nil do
  begin
    if P^.Name <> nil then
      if P^.Command = 0 then
      begin
        T := FindHotKey(P^.SubMenu^.Items);
        if T <> nil then
        begin
          FindHotKey := T;
          Exit;
        end;
      end
      else if not P^.Disabled and (P^.KeyCode <> kbNoKey) and
        (P^.KeyCode = KeyCode) then
      begin
        FindHotKey := P;
        Exit;
      end;
    P := P^.Next;
  end;
  FindHotKey := nil;
end;

begin
  HotKey := FindHotKey(Menu^.Items);
end;

function GraphMenuView.NewSubView(var Bounds: TRect; AMenu: PMenu;
  AParentMenu: PGraphMenuView): PGraphMenuView;
begin
  NewSubView := New(PGraphMenuBox, Init(Bounds, AMenu, AParentMenu));
end;

procedure GraphMenuView.Store(var S: TStream);

procedure DoStoreMenu(Menu: PMenu);
var
  Item: PMenuItem;
  Tok: Byte;
begin
  Tok := $FF;
  Item := Menu^.Items;
  while Item <> nil do
  begin
    with Item^ do
    begin
      S.Write(Tok, 1);
      S.WriteStr(Name);
      S.Write(Command, SizeOf(Word) * 3 + SizeOf(Boolean));
      if (Name <> nil) then
        if Command = 0 then DoStoreMenu(SubMenu)
        else S.WriteStr(Param);
    end;
    Item := Item^.Next;
  end;
  Tok := 0;
  S.Write(Tok, 1);
end;

begin
  GraphView.Store(S);
  S.Write(AutoSelectEnabled, SizeOf(Boolean));
  DoStoreMenu(Menu);
end;


{ GraphMenuBar }

constructor GraphMenuBar.Init(var Bounds: TRect; AMenu: PMenu);
var
  R: TRect;
begin
  GraphMenuView.Init(Bounds);
  GrowMode := gfGrowHiX;
  Menu := AMenu;
  Options := Options or ofPreProcess;
  AutoSelectEnabled := true;
end;

destructor GraphMenuBar.Done;
begin
  GraphMenuView.Done;
  DisposeMenu(Menu);
end;

procedure GraphMenuBar.DrawItem(Item : PMenuItem);
var
   R,R1 : TRect;
   P : TPoint;
   L,V,H : integer;
   CNormal,CSelect,CNormDisabled,CSelDisabled,
   CSelHighLight,CNormHighLight,Color,Color1 : word;
begin
   if Item = nil then Exit;
   CNormal := GetColor(8);
   CSelect := GetColor(5);
   CNormDisabled := GetColor(7);
   CSelDisabled := GetColor(4);
   CSelHighLight := GetColor(6);
   CNormHighLight := GetColor(9);
   if Item^.Name = nil then Exit;
   GetItemRect(Item,R);
    L := TextWidth(Item^.Name^);
   if R.A.X + L+ 16 < Size.X then
   begin
     SetColor(GetColor(1));
     if not CanFillBackground then Bar(R);
     if Item^.Disabled then
       if Item = Current then
         Color := CSelDisabled else
         Color := CNormDisabled else
       if Item = Current then
         Color := CSelect else
         Color := CNormal;
     if Item^.Disabled then Color1 := Color
     else begin
        if Item = Current then Color1 := CSelHighLight
        else Color1 := CNormHighLight;
     end;
     if Item = Current then begin
        SetColor(GetColor(2));
        R1.Assign(R.A.X,R.A.Y,R.A.X+1,R.B.Y);
        Line(R1);
        SetColor(GetColor(3));
        R1.Assign(R.B.X-1,R.A.Y,R.B.X,R.B.Y);
        Line(R1);
     end else begin
        SetColor(GetColor(2));
        R1.Assign(R.A.X,R.A.Y,R.B.X,R.A.Y+1);
        Line(R1);
        SetColor(GetColor(3));
        R1.Assign(R.A.X,R.B.Y-1,R.B.X,R.B.Y);
        Line(R1);
     end;
     GFonts.SetTextStyle(SystemFont,HorizDir,1);
     SetTextJustify(LeftText,CenterText);
     P.X := R.A.X + 8;
     P.Y := Size.Y div 2;
     WriteCTextXY(P,Item^.Name^,Color,Color1);
   end;
end;

procedure GraphMenuBar.Draw;
var
  P: PMenuItem;
  R,R1 : TRect;
  C : word;
begin
  GetExtent(R);
  GFonts.SetTextStyle(SystemFont,HorizDir,1);
  SetFillStyle(SolidFill,GetColor($0001));
  Bar(R);
  BicolorRectangle(R,GetColor(2),GetColor(3),false);
  if Menu <> nil then
  begin
    P := Menu^.Items;
    while P <> nil do begin
       DrawItem(P);
       P := P^.Next;
    end;
  end;
end;

procedure GraphMenuBar.GetItemRect(Item: PMenuItem; var R: TRect);
var
  P: PMenuItem;
begin
  R.Assign(8, 0, 8, Size.Y);
  P := Menu^.Items;
  while True do
  begin
    R.A.X := R.B.X;
    if P^.Name <> nil then Inc(R.B.X, CStrLen(P^.Name^) shl 3 +16);
    if P = Item then Exit;
    P := P^.Next;
  end;
end;

{ GraphMenuBox }

constructor GraphMenuBox.Init(var Bounds: TRect; AMenu: PMenu;
  AParentMenu: PGraphMenuView);
var
  W, H, L: Integer;
  P: PMenuItem;
  R: TRect;
begin
  W := 0;
  H := 0;
  if AMenu <> nil then
  begin
    P := AMenu^.Items;
    while P <> nil do
    begin
      if P^.Name <> nil then
      begin
        L := CStrLen(P^.Name^) shl 3;
        if P^.Command = 0 then Inc(L, 24) else
          if P^.Param <> nil then Inc(L, TextWidth('   '+P^.Param^));
        if L > W then W := L;
        Inc(H,MenuItemHeight);
      end else Inc(H,LineHeight);
      P := P^.Next;
    end;
  end;
  Inc(W,22);
  Inc(H,8);
  R.Copy(Bounds);
  if R.A.X + W < R.B.X then R.B.X := R.A.X + W else R.A.X := R.B.X - W;
  if R.A.Y + H < R.B.Y then R.B.Y := R.A.Y + H else R.A.Y := R.B.Y - H;
  GraphMenuView.Init(R);
  Options := Options or ofPreProcess;
  Menu := AMenu;
  ParentMenu := AParentMenu;
end;

procedure GraphMenuBox.DrawItem(Item : PMenuItem);
var
   R,R1 : TRect;
   P : TPoint;
   CNormal, CSelect, CNormDisabled, CSelDisabled,
   CSelHighLight,CNormHighLight,Color,Color1 : word;
   Temp : string;
begin
   if Item = nil then Exit;
   GetItemRect(Item,R);
   CNormal := GetColor(8);
   CSelect := GetColor(5);
   CNormDisabled := GetColor(7);
   CSelDisabled := GetColor(4);
   CSelHighLight := GetColor(6);
   CNormHighLight := GetColor(9);
   Color := CNormal;
   if Item^.Name = nil then begin
      with R do begin
         SetColor(GetColor(3));
         R1.Assign(A.X,A.Y+3,B.X,A.Y+4);
         Line(R1);
         SetColor(GetColor(2));
         R1.Assign(A.X,A.Y+4,B.X,A.Y+5);
         Line(R1);
      end;
   end else
   begin
      if Item^.Disabled then
        if Item = Current then
          Color := CSelDisabled else
          Color := CNormDisabled else
        if Item = Current then Color := CSelect;
      if Item^.Disabled then Color1 := Color
      else begin
         if Item = Current then Color1 := CSelHighLight
         else Color1 := CNormHighLight;
      end;
      Bar(R);
      if Item = Current then BicolorRectangle(R,GetColor(2),GetColor(3),true);
      SetColor(Color);
      SetTextJustify(LeftText,CenterText);
      Temp := ' '+Item^.Name^;
      P := R.A;
      P.Y := P.Y + (MenuItemHeight div 2);
      if Item = Current then
      begin
         inc(P.X);
         Inc(P.Y);
      end;
      WriteCTextXY(P,Temp,Color,Color1);
      if Item^.Command <> 0 then
        if Item^.Param <> nil then begin
           Temp := Item^.Param^+ ' ';
           P.X := R.B.X - TextWidth(Temp)-2;
           if Item = Current then inc(P.X);
           WriteTextXY(P,Temp);
        end;
   end;
end;

procedure GraphMenuBox.Draw;
var
  P: PMenuItem;
  R,R1 : TRect;
begin
  GetExtent(R);
  GFonts.SetTextStyle(SystemFont,HorizDir,1);
  SetFillStyle(SolidFill,GetColor(1));
  Bar(R);
  BicolorRectangle(R,GetColor(2),GetColor(3),false);
  if Menu <> nil then
  begin
    P := Menu^.Items;
    while P <> nil do
    begin
      DrawItem(P);
      P := P^.Next;
    end;
  end;
end;

procedure GraphMenuBox.GetItemRect(Item: PMenuItem; var R: TRect);
var
  Y: Integer;
  P: PMenuItem;
begin
  Y := 4;
  P := Menu^.Items;
  while P <> Item do
  begin
    if P^.Name <> nil then Inc(Y,MenuItemHeight)
    else Inc(Y,LineHeight);
    P := P^.Next;
  end;
  R.Assign(0, Y, Size.X, Y + MenuItemHeight);
  if Item^.Name = nil then R.B.Y := Y + LineHeight;
  R.Grow(-4,0);
end;

{ GraphStatusLine }

constructor GraphStatusLine.Init(var Bounds: TRect; ADefs: PStatusDef);
begin
  GraphView.Init(Bounds);
  Options := Options or ofPreProcess;
  EventMask := EventMask or evBroadcast;
  GrowMode := gfGrowLoY + gfGrowHiX + gfGrowHiY;
  Defs := ADefs;
  FindItems;
end;

constructor GraphStatusLine.Load(var S: TStream);

function DoLoadStatusItems: PStatusItem;
var
  Count: Integer;
  Cur, First: PStatusItem;
  Last: ^PStatusItem;
begin
  Cur := nil;
  Last := @First;
  S.Read(Count, SizeOf(Integer));
  while Count > 0 do
  begin
    New(Cur);
    Last^ := Cur;
    Last := @Cur^.Next;
    Cur^.Text := S.ReadStr;
    S.Read(Cur^.KeyCode, SizeOf(Word) * 2);
    Dec(Count);
  end;
  Last^ := nil;
  DoLoadStatusItems := First;
end;

function DoLoadStatusDefs: PStatusDef;
var
  AMin: Word;
  Cur, First: PStatusDef;
  Last: ^PStatusDef;
  Count: Integer;
begin
  Last := @First;
  S.Read(Count, SizeOf(Integer));
  while Count > 0 do
  begin
    New(Cur);
    Last^ := Cur;
    Last := @Cur^.Next;
    S.Read(Cur^.Min, 2 * SizeOf(Word));
    Cur^.Items := DoLoadStatusItems;
    Dec(Count);
  end;
  Last^ := nil;
  DoLoadStatusDefs := First;
end;

begin
  GraphView.Load(S);
  Defs := DoLoadStatusDefs;
  FindItems;
end;

destructor GraphStatusLine.Done;
var
  T: PStatusDef;

procedure DisposeItems(Item: PStatusItem);
var
  T: PStatusItem;
begin
  while Item <> nil do
  begin
    T := Item;
    Item := Item^.Next;
    DisposeStr(T^.Text);
    Dispose(T);
  end;
end;

begin
  while Defs <> nil do
  begin
    T := Defs;
    Defs := Defs^.Next;
    DisposeItems(T^.Items);
    Dispose(T);
  end;
  GraphView.Done;
end;

procedure GraphStatusLine.Draw;
begin
  DrawSelect(nil);
end;

procedure GraphStatusLine.DrawSelect(Selected: PStatusItem);
var
  T: PStatusItem;
  I, L: Integer;
  CSelect, CNormal, CSelDisabled, CNormDisabled,
  CSelHighLight,CNormHighLight,Color,Color1 : word;
  HintBuf: String;
  R,R1 : TRect;
  P : TPoint;
begin
  GetExtent(R);
  SetFillStyle(SolidFill,GetColor(1));
  SetLineStyle(SolidLn,0,NormWidth);
  SetWriteMode(NormalPut);
  GFonts.SetTextStyle(SystemFont,HorizDir,1);
  if not CanFillBackground then Bar(R);
  BicolorRectangle(R,GetColor(2),GetColor(3),false);
  R.Grow(-1,-1);
  BicolorRectangle(R,GetColor(2),GetColor(3),true);
   CNormal := GetColor(8);
   CSelect := GetColor(5);
   CNormDisabled := GetColor(7);
   CSelDisabled := GetColor(4);
   CSelHighLight := GetColor(6);
   CNormHighLight := GetColor(9);
  T := Items;
  R.Grow(-1,0);
  I := R.A.X;
  SetTextJustify(LeftText,Centertext);
  while T <> nil do
  begin
    if T^.Text <> nil then
    begin
      L := CStrLen(T^.Text^) * 8;
      if I + L + 16 < R.B.X then
      begin
        if CommandEnabled(T^.Command) then
          if T = Selected then
            Color := CSelect else
            Color := CNormal else
          if T = Selected then
            Color := CSelDisabled else
            Color := CNormDisabled;
        if CommandEnabled(T^.Command) then begin
           if T = Selected then Color1 := CSelHighLight
           else Color1 := CNormHighLight;
        end else Color1 := Color;
        R1.Assign(I,R.A.Y,I+L+16,R.B.Y);
        P.X := R1.A.X;
        P.Y := Size.Y div 2;
        WriteCTextXY(P,' '+T^.Text^+' ',Color,Color1);
      end;
      Inc(I, L + 16);
    end;
    T := T^.Next;
  end;
  if I < R.B.X then
  begin
    HintBuf := Hint(HelpCtx);
    if HintBuf <> '' then
    begin
      if i > R.A.X then begin
         R1.Assign(I,R.A.Y+1,I+1,R.B.Y-1);
         SetColor(GetColor(2));
         Line(R1);
         R1.Move(1,0);
         SetColor(GetColor(3));
         Line(R1);
         P.X := R1.B.X;
      end else P.X := I;
      P.Y := Size.Y div 2;
      Inc(I, 8);
      WriteTextXY(P,' ');
      if I + Length(HintBuf)*8 > R.B.X then HintBuf[0] := Char((R.B.X - I) div 8);
      P.X := I;
      inc(i,Length(HintBuf)*8);
      SetColor(GetColor(8));
      WriteTextXY(P,HintBuf)
    end;
  end;
  if i < R.B.X then begin
     R.Grow(-1,-1);
     R.A.X := i;
     Bar(R);
  end;
end;

procedure GraphStatusLine.FindItems;
var
  P: PStatusDef;
begin
  P := Defs;
  while (P <> nil) and ((HelpCtx < P^.Min) or (HelpCtx > P^.Max)) do
    P := P^.Next;
  if P = nil then Items := nil else Items := P^.Items;
end;


function GraphStatusLine.GetPalette: PPalette;
const
  P: string[Length(CStatusLine)] = CStatusLine;
begin
  GetPalette := @P;
end;

procedure GraphStatusLine.HandleEvent(var Event: TEvent);
var
  Mouse: TPoint;
  T: PStatusItem;
  R : TRect;

function ItemMouseIsIn: PStatusItem;
var
  I,K: Word;
  T: PStatusItem;
begin
  ItemMouseIsIn := nil;
  I := 2;
  T := Items;
  while T <> nil do
  begin
    if T^.Text <> nil then
    begin
      K := I + CStrLen(T^.Text^)*8 + 16;
      if (Mouse.X >= I) and (Mouse.X < K) then
      begin
        ItemMouseIsIn := T;
        Exit;
      end;
      I := K;
    end;
    T := T^.Next;
  end;
end;

begin
  GraphView.HandleEvent(Event);
  case Event.What of
    evMouseDown:
      begin
        GetExtent(R);
        SetDrawPort(R);
        T := nil;
        repeat
          MakeLocal(Event.Where, Mouse);
          if T <> ItemMouseIsIn then
          begin
            T := ItemMouseIsIn;
          end;
        until not MouseEvent(Event, evMouseMove);
        if (T <> nil) and CommandEnabled(T^.Command) then
        begin
          Event.What := evCommand;
          Event.Command := T^.Command;
          Event.InfoPtr := nil;
          PutEvent(Event);
        end;
        ClearEvent(Event);
        GetClipRect(R);
        {DrawView;}
        RefreshRect(R);
      end;
    evKeyDown:
      begin
        T := Items;
        while T <> nil do
        begin
          if (Event.KeyCode = T^.KeyCode) and
            CommandEnabled(T^.Command) then
          begin
            Event.What := evCommand;
            Event.Command := T^.Command;
            Event.InfoPtr := nil;
            Exit;
          end;
          T := T^.Next;
        end;
      end;
    evBroadcast:
      if Event.Command = cmCommandSetChanged then {DrawView;}
      begin
         GetClipRect(R);
         RefreshRect(R);
      end;
  end;
end;

function GraphStatusLine.Hint(AHelpCtx: Word): String;
begin
  Hint := '';
end;

procedure GraphStatusLine.Store(var S: TStream);

procedure DoStoreStatusItems(Cur: PStatusItem);
var
  T: PStatusItem;
  Count: Integer;
begin
  Count := 0;
  T := Cur;
  while T <> nil do
  begin
    Inc(Count);
    T := T^.Next
  end;
  S.Write(Count, SizeOf(Integer));
  while Cur <> nil do
  begin
    S.WriteStr(Cur^.Text);
    S.Write(Cur^.KeyCode, SizeOf(Word) * 2);
    Cur := Cur^.Next;
  end;
end;

procedure DoStoreStatusDefs(Cur: PStatusDef);
var
  Count: Integer;
  T: PStatusDef;
begin
  Count := 0;
  T := Cur;
  while T <> nil do
  begin
    Inc(Count);
    T := T^.Next
  end;
  S.Write(Count, SizeOf(Integer));
  while Cur <> nil do
  begin
    with Cur^ do
    begin
      S.Write(Min, SizeOf(Word) * 2);
      DoStoreStatusItems(Items);
    end;
    Cur := Cur^.Next;
  end;
end;

begin
  GraphView.Store(S);
  DoStoreStatusDefs(Defs);
end;

procedure GraphStatusLine.Update;
var
  H: Word;
  P: PGraphView;
  R : TRect;
begin
  P := TopView;
  if P <> nil then
    H := P^.GetHelpCtx else
    H := hcNoContext;
  if HelpCtx <> H then
  begin
    HelpCtx := H;
    FindItems;
    GetClipRect(R);
    RefreshRect(R);
  end;
end;

function NewStatusDef(AMin, AMax: Word; AItems: PStatusItem;
  ANext:PStatusDef): PStatusDef;
var
  T: PStatusDef;
begin
  New(T);
  with T^ do
  begin
    Next := ANext;
    Min := AMin;
    Max := AMax;
    Items := AItems;
  end;
  NewStatusDef := T;
end;

function NewStatusKey(AText: String; AKeyCode: Word; ACommand: Word;
  ANext: PStatusItem): PStatusItem;
var
  T: PStatusItem;
begin
  New(T);
  T^.Text := NewStr(AText);
  T^.KeyCode := AKeyCode;
  T^.Command := ACommand;
  T^.Next := ANext;
  NewStatusKey := T;
end;


procedure RegisterMenus;
begin
   RegisterType(RGraphMenuBar);
   RegisterType(RGraphMenuBox);
   RegisterType(RGraphStatusLine);
end;

end.