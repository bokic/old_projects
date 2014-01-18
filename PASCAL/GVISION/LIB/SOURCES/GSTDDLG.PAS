{************************************************}
{   GstdDlg.pas                                  }
{   Graph Vision unit                            }
{   Sergey E. Levov, Moscow,1992-1994            }
{   Portions copyright (c) 1990 by Borland Int.  }
{************************************************}

unit GStdDlg;

{$F+,O+,V-,X+,D-}

interface

uses Graph,Objects,Eventman,GraV, Controls, Dos;

const

{ Commands }

  cmFileOpen    = 800;   { Returned from TFileDialog when Open pressed }
  cmFileReplace = 801;   { Returned from TFileDialog when Replace pressed }
  cmFileClear   = 802;   { Returned from TFileDialog when Clear pressed }
  cmFileInit    = 803;   { Used by TFileDialog internally }
  cmChangeDir   = 804;   { Used by TChDirDialog internally }

{ Messages }

  cmDirFocused  = 805;    { A new directory was focused in the TDirListBox }
  cmFileFocused = 806;    { A new file was focused in the TFileList }
  cmFileDoubleClicked     { A file was selected in the TFileList }
                = 807;

type

  { TSearchRec }

  {  Record used to store directory information by TFileDialog }

  TSearchRec = record
    Attr: Byte;
    Time: Longint;
    Size: Longint;
    Name: string[12];
  end;

type

  { TFileInputLine is a special input line that is used by      }
  { TFileDialog that will update its contents in response to a  }
  { cmFileFocused command from a TFileList and to a cmDirFocused}
  { from TDirListBox                                            }

  PFileInputLine = ^TFileInputLine;
  TFileInputLine = object(GraphInputLine)
    constructor Init(var Bounds: TRect; AMaxLen: Integer);
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  PPathInfo = ^TPathInfo;
  TpathInfo = object(GraphStaticText)
     procedure Draw; virtual;
     procedure NewText(AText : string);
  end;

  { TFileCollection is a collection of TSearchRec's.            }

  PFileCollection = ^TFileCollection;
  TFileCollection = object(TSortedCollection)
    function Compare(Key1, Key2: Pointer): Integer; virtual;
    procedure FreeItem(Item: Pointer); virtual;
    function GetItem(var S: TStream): Pointer; virtual;
    procedure PutItem(var S: TStream; Item: Pointer); virtual;
  end;

  { TSortedListBox is a TListBox that assumes it has a          }
  { TStoredCollection instead of just a TCollection.  It will   }
  { perform an incremental search on the contents.              }

  PSortedListBox = ^TSortedListBox;
  TSortedListBox = object(TextListBox)
    SearchPos: Word;
    ShiftState: Byte;
    constructor Init(var Bounds: TRect; ANumCols: Word;
      AScrollBar: PGraphScrollBar);
    procedure HandleEvent(var Event: TEvent); virtual;
    function GetKey(var S: String): Pointer; virtual;
    procedure NewList(AList: PCollection); virtual;
  end;

  { TFileList is a TSortedList box that assumes it contains     }
  { a TFileCollection as its collection.  It also communicates  }
  { through broadcast messages to TFileInput and TInfoPane      }
  { what file is currently selected.                            }

  PFileList = ^TFileList;
  TFileList = object(TSortedListBox)
    constructor Init(var Bounds: TRect; AWildCard: PathStr;
      AScrollBar: PGraphScrollBar);
    destructor Done; virtual;
    function DataSize: Word; virtual;
    procedure FocusItem(Item: Integer); virtual;
    procedure GetData(var Rec); virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    function GetKey(var S: String): Pointer; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure ReadDirectory(AWildCard: PathStr);
    procedure SetData(var Rec); virtual;
    procedure SetState(AState : word; Enable : boolean); virtual;
  end;

  { TDirEntry }

  PDirEntry = ^TDirEntry;
  TDirEntry = record
    DisplayText: PString;
    Directory: PString;
  end;

  { TDirCollection is a collection of TDirEntry's used by       }
  { TDirListBox.                                                }

  PDirCollection = ^TDirCollection;
  TDirCollection = object(TCollection)
    function GetItem(var S: TStream): Pointer; virtual;
    procedure FreeItem(Item: Pointer); virtual;
    procedure PutItem(var S: TStream; Item: Pointer); virtual;
  end;

  { TDirListBox displays a tree of directories for use in the }
  { TChDirDialog.                                               }

  PDirListBox = ^TDirListBox;
  TDirListBox = object(TextListBox)
    Dir: DirStr;
    Cur: Word;
    constructor Init(var Bounds: TRect; AScrollBar: PGraphScrollBar);
    destructor Done; virtual;
    function DataSize : word; virtual;
    procedure FocusItem(Item: Integer); virtual;
    procedure GetData(var Rec); virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure NewDirectory(var ADir: DirStr);
    procedure SetData(var Rec); virtual;
    procedure SetState(AState : word; Enable : boolean); virtual;
  end;

{ TFileDialog is a standard file name input dialog            }

  TWildStr = PathStr;

const
  fdOkButton      = $0001;      { Put an OK button in the dialog }
  fdOpenButton    = $0002;      { Put an Open button in the dialog }
  fdReplaceButton = $0004;      { Put a Replace button in the dialog }
  fdClearButton   = $0008;      { Put a Clear button in the dialog }
  fdHelpButton    = $0010;      { Put a Help button in the dialog }
  fdNoLoadDir     = $0100;      { Do not load the current directory }
                                { contents into the dialog at Init. }
                                { This means you intend to change the }
                                { WildCard by using SetData or store }
                                { the dialog on a stream. }

type

  PFileDialog = ^TFileDialog;
  TFileDialog = object(GraphDialog)
    FileName: PFileInputLine;
    FileList: PFileList;
    DirList: PDirListBox;
    PathInfo : PPathInfo;
    WildCard: TWildStr;
    Directory: PString;
    constructor Init(AWildCard: TWildStr; ATitle: String;
      InputName: String; AOptions: Word; HistoryId: Byte);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure GetData(var Rec); virtual;
    procedure GetFileName(var S: PathStr);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream);
    function Valid(Command: Word): Boolean; virtual;
  private
    procedure ChangeDir(Dir : TWildStr);
  end;

const
  cdNormal     = $0000; { Option to use dialog immediately }
  cdNoLoadDir  = $0001; { Option to init the dialog to store on a stream }
  cdHelpButton = $0002; { Put a help button in the dialog }

const

  CInfoPane = #30;

  { TStream registration records }

  RFileInputLine: TStreamRec = (
     ObjType: 60;
     VmtLink: Ofs(TypeOf(TFileInputLine)^);
     Load:    @TFileInputLine.Load;
     Store:   @TFileInputLine.Store
  );
  RFileCollection: TStreamRec = (
     ObjType: 61;
     VmtLink: Ofs(TypeOf(TFileCollection)^);
     Load:    @TFileCollection.Load;
     Store:   @TFileCollection.Store
  );
  RFileList: TStreamRec = (
     ObjType: 62;
     VmtLink: Ofs(TypeOf(TFileList)^);
     Load:    @TFileList.Load;
     Store:   @TFileList.Store
  );
  RPathInfo : TStreamRec = (
     ObjType: 63;
     VmtLink: Ofs(TypeOf(TPathInfo)^);
     Load:    @TPathInfo.Load;
     Store:   @TPathInfo.Store
  );
  RFileDialog: TStreamRec = (
     ObjType: 64;
     VmtLink: Ofs(TypeOf(TFileDialog)^);
     Load:    @TFileDialog.Load;
     Store:   @TFileDialog.Store
  );
  RDirCollection: TStreamRec = (
     ObjType: 65;
     VmtLink: Ofs(TypeOf(TDirCollection)^);
     Load:    @TDirCollection.Load;
     Store:   @TDirCollection.Store
  );
  RDirListBox: TStreamRec = (
     ObjType: 66;
     VmtLink: Ofs(TypeOf(TDirListBox)^);
     Load:    @TDirListBox.Load;
     Store:   @TDirListBox.Store
  );


procedure RegisterStdDlg;

implementation

uses ExtObj,GrApp, Memory, HistList, MsgBox,GrDriver,GFonts;

function DriveValid(Drive: Char): Boolean; assembler;
asm
	MOV	DL,Drive
        MOV	AH,36H
        SUB	DL,'A'-1
        INT	21H
        INC	AX
        JE	@@2
@@1:	MOV	AL,1
@@2:
end;

function PathValid(var Path: PathStr): Boolean;
var
  ExpPath: PathStr;
  F: File;
  SR: SearchRec;
begin
  ExpPath := FExpand(Path);
  if Length(ExpPath) <= 3 then PathValid := DriveValid(ExpPath[1])
  else
  begin
    if ExpPath[Length(ExpPath)] = '\' then Dec(ExpPath[0]);
    FindFirst(ExpPath, Directory, SR);
    PathValid := (DosError = 0) and (SR.Attr and Directory <> 0);
  end;
end;

function ValidFileName(var FileName: PathStr): Boolean;
const
  IllegalChars = ';,=+<>|"[] \';
var
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;

{ Contains returns true if S1 contains any characters in S2 }
function Contains(S1, S2: String): Boolean; near; assembler;
asm
	PUSH	DS
        CLD
        LDS	SI,S1
        LES	DI,S2
        MOV	DX,DI
        XOR	AH,AH
        LODSB
        MOV	BX,AX
        OR      BX,BX
        JZ      @@2
        MOV	AL,ES:[DI]
        XCHG	AX,CX
@@1:	PUSH	CX
	MOV	DI,DX
	LODSB
        REPNE	SCASB
        POP	CX
        JE	@@3
	DEC	BX
        JNZ	@@1
@@2:	XOR	AL,AL
	JMP	@@4
@@3:	MOV	AL,1
@@4:	POP	DS
end;

begin
  ValidFileName := True;
  FSplit(FileName, Dir, Name, Ext);
  if not ((Dir = '') or PathValid(Dir)) or Contains(Name, IllegalChars) or
    Contains(Dir, IllegalChars) then ValidFileName := False;
end;

function GetCurDir: DirStr;
var
  CurDir: DirStr;
begin
  GetDir(0, CurDir);
  if Length(CurDir) > 3 then
  begin
    Inc(CurDir[0]);
    CurDir[Length(CurDir)] := '\';
  end;
  GetCurDir := CurDir;
end;

type
  PSearchRec = ^TSearchRec;

function IsWild(var S: String): Boolean;
begin
  IsWild := (Pos('?',S) > 0) or (Pos('*',S) > 0);
end;

function IsDir(var S: String): Boolean;
var
  SR: SearchRec;
begin
  FindFirst(S, Directory, SR);
  if DosError = 0 then
    IsDir := SR.Attr and Directory <> 0
  else IsDir := False;
end;

{ TFileInputLine }

constructor TFileInputLine.Init(var Bounds: TRect; AMaxLen: Integer);
begin
  GraphInputLine.Init(Bounds, AMaxLen);
  EventMask := EventMask or evBroadcast;
end;

procedure TFileInputLine.HandleEvent(var Event: TEvent);
var
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
begin
  GraphInputLine.HandleEvent(Event);
  if (Event.What = evBroadcast) and (State and sfSelected = 0) then
  begin
    case Event.Command of
      cmFileFocused :
        begin
          Data^ := PSearchRec(Event.InfoPtr)^.Name;
          DrawView;
        end;
      cmDirFocused  :
        begin
          Data^ := PDirEntry(Event.InfoPtr)^.DisplayText^ + '\' +
                   PFileDialog(Owner^.Owner)^.WildCard;
          DrawView;
        end;
    end;
  end;
end;

procedure TPathInfo.Draw;
var
   R : TRect;
begin
   GetExtent(R);
   SetFillStyle(SolidFill,LightGray);
   Bar(R);
   GraphStaticText.Draw;
end;

procedure TPathInfo.NewText(Atext : string);
begin
   DisposeStr(Text);
   Text := NewStr(AText);
   DrawView;
end;

function TFileCollection.Compare(Key1, Key2: Pointer): Integer;
begin
  if PSearchRec(Key1)^.Name = PSearchRec(Key2)^.Name then Compare := 0
  else if PSearchRec(Key1)^.Name > PSearchRec(Key2)^.Name then
    Compare := 1
  else Compare := -1;
end;

procedure TFileCollection.FreeItem(Item: Pointer);
begin
  Dispose(PSearchRec(Item));
end;

function TFileCollection.GetItem(var S: TStream): Pointer;
var
  Item: PSearchRec;
begin
  New(Item);
  S.Read(Item^, SizeOf(TSearchRec));
  GetItem := Item;
end;

procedure TFileCollection.PutItem(var S: TStream; Item: Pointer);
begin
  S.Write(Item^, SizeOf(TSearchRec));
end;

{ TSortedListBox }

constructor TSortedListBox.Init(var Bounds: TRect; ANumCols: Word;
  AScrollBar: PGraphScrollBar);
begin
  TextListBox.Init(Bounds, ANumCols, AScrollBar);
  SearchPos := 0;
end;

procedure TSortedListBox.HandleEvent(var Event: TEvent);
var
  ShiftKeys: Byte absolute $40:$17;
  CurString, NewString: String;
  K: Pointer;
  Value, OldPos, OldValue: Integer;
  T: Boolean;

function Equal(var S1: String; var S2: String; Count: Word): Boolean;
var
  I: Word;
begin
  Equal := False;
  if (Length(S1) < Count) or (Length(S2) < Count) then Exit;
  for I := 1 to Count do
    if UpCase(S1[I]) <> UpCase(S2[I]) then Exit;
  Equal := True;
end;

begin
  OldValue := Focused;
  if (Event.What = evBroadcast) and
     ((Event.Command = cmScrollbarChanged) or
     (Event.Command = cmScrollBarClicked)) then
     TextListBox.HandleEvent(Event)
  else TextListBox.HandleEvent(Event);
  if OldValue <> Focused then SearchPos := 0;
  if Event.What = evKeyDown then
  begin
    if Event.CharCode <> #0 then
    begin
      Value := Focused;
      if Value < Range then CurString := GetText(Value, 255)
      else CurString := '';
      OldPos := SearchPos;
      if Event.KeyCode = kbBack then
      begin
        if SearchPos = 0 then Exit;
        Dec(SearchPos);
        if SearchPos = 0 then ShiftState := ShiftKeys;
        CurString[0] := Char(SearchPos);
      end
      else if (Event.CharCode = '.') then SearchPos := Pos('.',CurString)
      else
      begin
        Inc(SearchPos);
        if SearchPos = 1 then ShiftState := ShiftKeys;
        CurString[0] := Char(SearchPos);
        CurString[SearchPos] := Event.CharCode;
      end;
      K := GetKey(CurString);
      T := PSortedCollection(List)^.Search(K, Value);
      if Value < Range then
      begin
        if Value < Range then NewString := GetText(Value, 255)
        else NewString := '';
        if Equal(NewString, CurString, SearchPos) then
        begin
          if Value <> OldValue then
          FocusItem(Value);
        end
        else SearchPos := OldPos;
      end
      else SearchPos := OldPos;
      if (SearchPos <> OldPos) or (Event.CharCode in ['A'..'Z','a'..'z']) then
        ClearEvent(Event);
    end;
  end;
end;

function TSortedListBox.GetKey(var S: String): Pointer;
begin
  GetKey := @S;
end;

procedure TSortedListBox.NewList(AList: PCollection);
begin
  TextListBox.NewList(AList);
  SearchPos := 0;
end;

{ TFileList }

constructor TFileList.Init(var Bounds: TRect; AWildCard: PathStr;
  AScrollBar: PGraphScrollBar);
begin
  TSortedListBox.Init(Bounds, 1, AScrollBar);
end;

destructor TFileList.Done;
begin
  if List <> nil then Dispose(List, Done);
  TextListBox.Done;
end;

function TFileList.DataSize: Word;
begin
  DataSize := 0;
end;

procedure TFileList.FocusItem(Item: Integer);
begin
  TSortedListBox.FocusItem(Item);
  if State and sfFocused <> 0 then
     Message(Owner, evBroadcast, cmFileFocused, List^.At(Item));
end;

procedure TFileList.GetData(var Rec);
begin
end;

function TFileList.GetKey(var S: String): Pointer;
const
  SR: TSearchRec = ();

procedure UpStr(var S: String);
var
  I: Integer;
begin
  for I := 1 to Length(S) do S[I] := UpCase(S[I]);
end;

begin
  SR.Attr := 0;
  SR.Name := S;
  UpStr(SR.Name);
  GetKey := @SR;
end;

function TFileList.GetText(Item: Integer; MaxLen: Integer): String;
var
  S: String;
  SR: PSearchRec;
  i,j : integer;
begin
  if GetItem(Item) <> nil then begin
     i := MaxLen div 8;
     if (MaxLen mod 8) <> 0 then inc(i);
     SR := PSearchRec(GetItem(Item));
     S := SR^.Name;
     j := Length(S);
     if j > i then S := Copy(S,1,i)
     else begin
        FillChar(S[j+1],i-j,' ');
        inc(Byte(S[0]),i-j);
     end;
     GetText := S;
  end else GetText := '';
end;

procedure TFileList.HandleEvent(var Event: TEvent);
begin
  if (Event.What = evMouseDown) and (Event.Double) then
  begin
    Event.What := evCommand;
    Event.Command := cmOK;
    PutEvent(Event);
    ClearEvent(Event);
  end
  else
    TSortedListBox.HandleEvent(Event);
end;

procedure TFileList.ReadDirectory(AWildCard: PathStr);
const
  FindAttr = ReadOnly + Archive;
  AllFiles = '*.*';
  PrevDir  = '..';
var
  S: SearchRec;
  P: PSearchRec;
  FileList: PFileCollection;
  CurPath: PathStr;
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
  Event: TEvent;
  Tmp: PathStr;
begin
  AWildCard := FExpand(AWildCard);
  FSplit(AWildCard, Dir, Name, Ext);
  FileList := New(PFileCollection, Init(5, 5));
  FindFirst(AWildCard, FindAttr, S);
  P := @P;
  while (P <> nil) and (DosError = 0) do
  begin
    if (S.Attr and Directory = 0) then
    begin
      P := MemAlloc(SizeOf(P^));
      if P <> nil then
      begin
        Move(S.Attr, P^, SizeOf(P^));
        FileList^.Insert(P);
      end;
    end;
    FindNext(S);
  end;
  if P = nil then MessageBox(#13#13'Too many files.', nil, mfOkButton + mfInformation);
  NewList(FileList);
  SetState(sfDisabled,List^.Count = 0);
end;

procedure TFileList.SetData(var Rec);
begin
  with PFileDialog(Owner^.Owner)^ do
    Self.ReadDirectory(Directory^ + WildCard);
end;

procedure TFileList.SetState(AState : word; Enable : Boolean);
begin
   TSortedListBox.SetState(AState,Enable);
   if State and sfDisabled <> 0 then Exit;
   if (State and sfFocused <> 0) and (Owner <> nil) then
       Message(Owner, evBroadcast, cmFileFocused, List^.At(Focused));
end;

{ TFileDialog }

constructor TFileDialog.Init(AWildCard: TWildStr; ATitle: String;
  InputName: String; AOptions: Word; HistoryId: Byte);
var
  Control: PGraphView;
  R: TRect;
  S: String;
  Opt: Word;
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
  Wait : PMouseCursor;
begin
  Wait := PMouseCursor(StdSharedresource^.Get('WAIT'));
  if Wait <> nil then Wait^.MakeActive;
  inc(LockMouseCursor);
  R.Assign(120,8,513,342);
  GraphDialog.Init(R, ATitle);
  Options := Options or ofCentered;
  AWildCard := FExpand(AWildCard);
  FSplit(AWildCard,Dir,Name,Ext);
  if Length(Dir) > 3 then dec(Dir[0]);
  WildCard := Name+Ext;
  R.Assign(24,25,246,40);
  Insert(New(PGraphGrayGroup,Init(R)));
  R.Grow(-1,-1);
  FileName := New(PFileInputLine, Init(R, 79));
  FileName^.Data^ := Name+Ext;
  Insert(FileName);
  R.Assign(24,10,24+CStrLen(InputName)*8,24);
  Control := New(PGraphLabel, Init(R, InputName, FileName));
  Insert(Control);
  R.Assign(247,25,262,40);
  Insert(New(PGraphGrayGroup,Init(R)));
  R.Grow(-1,-1);
  Control := New(PGraphHistory, Init(R, FileName, HistoryId));
  Insert(Control);

  R.Assign(24,69,262,85);
  Insert(new(PGraphGrayGroup,Init(R)));
  R.Grow(-1,-1);
  PathInfo := New(PPathInfo,Init(R,'',SystemFont,1));
  Insert(PathInfo);
  R.Assign(24,54,104,68);
  Control := New(PGraphLabel, Init(R, 'Path', PathInfo));
  Insert(Control);

  R.Assign(124,112,139,282);
  Control := New(PGraphScrollBar, Init(R));
  Insert(Control);
  R.Assign(24,112,124,282);
  Insert(New(PGraphGrayGroup,Init(R)));
  R.Grow(-1,-1);
  FileList := New(PFileList, Init(R, WildCard, PGraphScrollBar(Control)));
  Insert(FileList);
  R.Assign(24,97,104,111);
  Control := New(PGraphLabel, Init(R, '~F~iles', FileList));
  Insert(Control);
  R.Assign(247, 112, 262, 282);
  Control := New(PGraphScrollBar, Init(R));
  Insert(Control);
  R.Assign(147, 112, 247, 282);
  Insert(New(PGraphGrayGroup,Init(R)));
  R.Grow(-1,-1);
  DirList := New(PDirListBox, Init(R, PGraphScrollBar(Control)));
  Insert(DirList);
  R.Assign(147, 97, 223, 111);
  Control := New(PGraphLabel, Init(R, 'Direc~t~ory', DirList));
  Insert(Control);

  R.Assign(290,70,353,109);
  Opt := bfDefault+bfGrabFocus;
  if AOptions and fdOpenButton <> 0 then
  begin
{    if LowMemory then Insert(New(PGraphTextButton, Init(R, 'Open', cmFileOpen, Opt)))
    else} Insert(New(PGraphBitmapButton,Init(R,'~O~PEN',cmFileOpen,Opt)));
    Opt := bfNormal+bfGrabFocus;
    Inc(R.A.Y,55); Inc(R.B.Y,55);
  end;
  if AOptions and fdOkButton <> 0 then
  begin
{    if LowMemory then Insert(New(PGraphTextButton, Init(R, 'O~K~', cmFileOpen, Opt)))
    else} Insert(New(PGraphBitmapButton,Init(R,'O~K~',cmFileOpen,Opt)));
    Opt := bfNormal + bfGrabFocus;
    Inc(R.A.Y,55); Inc(R.B.Y,55);
  end;
  if AOptions and fdReplaceButton <> 0 then
  begin
{    if LowMemory then Insert(New(PGraphTextButton, Init(R, '~R~eplace',cmFileReplace, Opt)))
    else} Insert(New(PGraphBitmapButton,Init(R,'~R~EPLACE',cmFileReplace,Opt)));
    Opt := bfNormal + bfGrabFocus;
    Inc(R.A.Y,55); Inc(R.B.Y,55);
  end;
  if AOptions and fdClearButton <> 0 then
  begin
{    if LowMemory then Insert(New(PGraphTextButton, Init(R, '~C~lear',cmFileClear, Opt)))
    else} Insert(New(PGraphBitmapButton,Init(R,'C~L~EAR',cmFileClear,Opt)));
    Opt := bfNormal + bfGrabFocus;
    Inc(R.A.Y,55); Inc(R.B.Y,55);
  end;
{  if LowMemory then Insert(New(PGraphTextButton, Init(R, 'Cancel', cmCancel, bfNormal)))
  else} Insert(New(PGraphBitmapButton,Init(R,'~C~ANCEL',cmCancel,Opt)));
  Inc(R.A.Y,55); Inc(R.B.Y,55);
  if AOptions and fdHelpButton <> 0 then
  begin
{    if LowMemory then Insert(New(PGraphTextButton, Init(R, 'Help',cmHelp, bfNormal)))
    else} Insert(New(PGraphBitmapButton,Init(R,'~H~ELP',cmHelp,Opt)));
    Inc(R.A.Y,55); Inc(R.B.Y,55);
  end;
  PGraphGroup(WorkSpace)^.SelectNext(false);
  if AOptions and fdNoLoadDir = 0 then ChangeDir(Dir);
  dec(LockMouseCursor);
  Application^.ChangeMouseCursor;
end;

constructor TFileDialog.Load(var S: TStream);
var
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
  ViewId: Word;
begin
  GraphDialog.Load(S);
  S.Read(WildCard, SizeOf(TWildStr));
  GetSubViewPtr(S, FileName);
  GetSubViewPtr(S, FileList);
  GetSubViewPtr(S, DirList);
  GetSubViewPtr(S,PathInfo);
  FSplit(WildCard,Dir,Name,Ext);
  ChangeDir(Dir);
  DirList^.Select;
end;

destructor TFileDialog.Done;
begin
  DisposeStr(Directory);
  GraphDialog.Done;
end;

procedure TFileDialog.GetData(var Rec);
begin
  GetFilename(PathStr(Rec));
end;

procedure TFileDialog.GetFileName(var S: PathStr);
var
  Path: PathStr;
  Name: NameStr;
  Ext: ExtStr;
  TPath: PathStr;
  TName: NameStr;
  TExt: NameStr;

function LTrim(S: String): String;
var
  I: Integer;
begin
  I := 1;
  while (I < Length(S)) and (S[I] = ' ') do Inc(I);
  LTrim := Copy(S, I, 255);
end;

function RTrim(S: String): String;
var
  I: Integer;
begin
  while S[Length(S)] = ' ' do Dec(S[0]);
  RTrim := S;
end;

function RelativePath(var S: PathStr): Boolean;
var
  I,J: Integer;
  P: PathStr;
begin
  S := LTrim(RTrim(S));
  if (S <> '') and ((S[1] = '\') or (S[2] = ':')) then RelativePath := False
  else RelativePath := True;
end;

function NoWildChars(S: String): String; assembler;
asm
	PUSH	DS
	LDS	SI,S
        XOR     AX,AX
	LODSB
	XCHG	AX,CX
        LES     DI,@Result
        INC     DI
@@1:	LODSB
	CMP	AL,'?'
	JE	@@2
	CMP	AL,'*'
	JE	@@2
	STOSB
@@2:	LOOP	@@1
	XCHG	AX,DI
	MOV	DI,WORD PTR @Result
	SUB	AX,DI
        DEC     AX
        STOSB
	POP	DS
end;

begin
  S := FileName^.Data^;
  if RelativePath(S) then S := FExpand(Directory^ + S)
  else S := FExpand(S);
  FSplit(S, Path, Name, Ext);
  if ((Name = '') or (Ext = '')) and not IsDir(S) then
  begin
    FSplit(WildCard, TPath, TName, TExt);
    if ((Name = '') and (Ext = '')) then S := Path + TName + TExt
    else if Name = '' then S := Path + TName + Ext
    else if Ext = '' then
    begin
      if IsWild(Name) then S := Path + Name + TExt
      else S := Path + Name + NoWildChars(TExt);
    end;
  end;
end;

procedure TFileDialog.HandleEvent(var Event: TEvent);
var
   CurDir : DirStr;
   P : PDirEntry;
begin
  GraphDialog.HandleEvent(Event);
  if Event.What = evCommand then
    case Event.Command of
      cmFileOpen, cmFileReplace, cmFileClear:
        begin
          EndModal(Event.Command);
          ClearEvent(Event);
        end;
      cmChangeDir:
        begin
          P := DirList^.List^.At(DirList^.Focused);
          CurDir := P^.Directory^;
          if (Length(CurDir) > 3) and (CurDir[Length(CurDir)] = '\') then
          CurDir := Copy(CurDir,1,Length(CurDir)-1);
          ChangeDir(CurDir);
        end;
    end;
end;

procedure TFileDialog.SetData(var Rec);
begin
  GraphDialog.SetData(Rec);
  if (PathStr(Rec) <> '') and (IsWild(TWildStr(Rec))) then
  begin
{    FileName^.Data^ := WildCard;}
    Valid(cmFileInit);
    FileName^.Select;
  end;
end;

procedure TFileDialog.ChangeDir(Dir : TWildStr);
var
   CurDir : TWildStr;
   io : word;
begin
   CurDir := GetCurDir;
   if Dir <> CurDir then begin
{$I-}
      ChDir(Dir);
      IO := IOResult;
      if IO <> 0 then begin
         MessageBox(#13#13'Invalid directory.', nil, mfError + mfOkButton);
         if Length(CurDir) > 3 then dec(CurDir[0]);
         ChDir(CurDir);
{$I+}
      end;
      Dir := GetCurDir;
   end;
   DisposeStr(Directory);
   Directory := NewStr(Dir);
   DirList^.NewDirectory(Dir);
   PathInfo^.NewText(Dir);
   FileList^.ReadDirectory(WildCard);
end;

procedure TFileDialog.Store(var S: TStream);
begin
  GraphDialog.Store(S);
  S.Write(WildCard, SizeOf(TWildStr));
  PutSubViewPtr(S, FileName);
  PutSubViewPtr(S, FileList);
  PutSubViewPtr(S, DirList);
  PutSubViewPtr(S, PathInfo);
end;

function TFileDialog.Valid(Command: Word): Boolean;
var
  T: Boolean;
  FName: PathStr;
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;

function CheckDirectory(var S: PathStr): Boolean;
begin
  if not PathValid(S) then
  begin
    MessageBox(#13#13'Invalid drive or directory.', nil, mfError + mfOkButton);
    FileName^.Select;
    CheckDirectory := False;
  end else CheckDirectory := True;
end;

begin
  if Command = 0 then
  begin
    Valid := True;
    Exit;
  end else Valid := False;
  if GraphDialog.Valid(Command) then
  begin
    GetFileName(FName);
    if (Command <> cmCancel) and (Command <> cmFileClear) then
    begin
      if IsWild(FName) then
      begin
        FSplit(FName, Dir, Name, Ext);
        if CheckDirectory(Dir) then
        begin
          DisposeStr(Directory);
          Directory := NewStr(Dir);
          WildCard := Name+Ext;
          PathInfo^.NewText(Directory^);
          DirList^.NewDirectory(Directory^);
          FileList^.ReadDirectory(Directory^+WildCard);
          FileList^.Select;
        end
      end
      else if IsDir(FName) then
      begin
        if CheckDirectory(FName) then
        begin
          DisposeStr(Directory);
	  Directory := NewSTr(FName+'\');
          PathInfo^.NewText(Directory^);
          DirList^.NewDirectory(Directory^);
	  FileList^.ReadDirectory(Directory^+WildCard);
          FileList^.Select;
        end;
      end else if ValidFileName(FName) then Valid := True
      else
      begin
        MessageBox(#13#13'Invalid file name.', nil, mfError + mfOkButton);
        Valid := False;
      end
    end
    else Valid := True;
  end;
end;

{ TDirCollection }

function TDirCollection.GetItem(var S: TStream): Pointer;
var
  DirItem: PDirEntry;
begin
  New(DirItem);
  DirItem^.DisplayText := S.ReadStr;
  DirItem^.Directory := S.ReadStr;
  GetItem := DirItem;
end;

procedure TDirCollection.FreeItem(Item: Pointer);
var
  DirItem: PDirEntry absolute Item;
begin
  DisposeStr(DirItem^.DisplayText);
  DisposeStr(DirItem^.Directory);
  Dispose(DirItem);
end;

procedure TDirCollection.PutItem(var S: TStream; Item: Pointer);
var
  DirItem: PDirEntry absolute Item;
begin
  S.WriteStr(DirItem^.DisplayText);
  S.WriteStr(DirItem^.Directory);
end;

{ TDirListBox }

constructor TDirListBox.Init(var Bounds: TRect; AScrollBar:
  PGraphScrollBar);
begin
  TextListBox.Init(Bounds, 1, AScrollBar);
  Dir := '';
end;

destructor TDirListBox.Done;
begin
  if List <> nil then Dispose(List, Done);
  TextListBox.Done;
end;

function TDirListBox.DataSize : word;
begin
   DataSize := 0;
end;

procedure TDirListBox.FocusItem(Item: Integer);
begin
  TextListBox.FocusItem(Item);
  Message(Owner, evBroadcast, cmDirFocused, List^.At(Item));
end;

procedure TDirListBox.GetData(var Rec);
begin
end;

function TDirListBox.GetText(Item: Integer; MaxLen: Integer): String;
var
  S: String;
  i,j : integer;
begin
   i := MaxLen div 8;
   if (MaxLen mod 8) <> 0 then inc(i);
   S := PDirEntry(List^.At(Item))^.DisplayText^;
   j := Length(S);
   if j > i then S := Copy(S,1,i)
   else begin
      FillChar(S[j+1],i-j,' ');
      inc(Byte(S[0]),i-j);
   end;
   GetText := S;
end;

procedure TDirListBox.HandleEvent(var Event: TEvent);
begin
  if (Event.What = evMouseDown) and (Event.Double) then
  begin
    Event.What := evCommand;
    Event.Command := cmChangeDir;
    PutEvent(Event);
    ClearEvent(Event);
  end
  else
    TextListBox.HandleEvent(Event);
end;

procedure TDirListBox.NewDirectory(var ADir: DirStr);
const
  IndentSize         = ' ';
var
  AList: PCollection;
  NewDir, Dirct: DirStr;
  C, OldC: Char;
  S, Indent: String[80];
  P: PString;
  isFirst: Boolean;
  SR: SearchRec;
  I: Integer;
  DirEntry: PDirEntry;
function NewDirEntry(DisplayText, Directory: String): PDirEntry; near;
var
  DirEntry: PDirEntry;
begin
  New(DirEntry);
  DirEntry^.DisplayText := NewStr(DisplayText);
  DirEntry^.Directory := NewStr(Directory);
  NewDirEntry := DirEntry;
end;

function GetCurDrive: Char; assembler;
asm
	MOV	AH,19H
        INT	21H
        ADD	AL,'A'
end;

begin
  Dir := ADir;
  AList := New(PDirCollection, Init(5,5));
  OldC := ' ';
  Dirct := Dir;
  if Dirct[Length(Dirct)] <> '\' then Dirct := Dirct + '\';
  NewDir := Dirct+ '*.*';
  FindFirst(NewDir, Directory, SR);
  while DosError = 0 do
  begin
    if (SR.Attr and Directory <> 0) and (SR.Name <> '.') then
    begin
       if SR.Name = '..' then begin
          S := Dirct;
          repeat
             Dec(S[0]);
          until S[Length(S)] = '\';
       end else S := Dirct + SR.Name;
       AList^.Insert(NewDirEntry(SR.Name, S));
    end;
    FindNext(SR);
  end;
  for C := 'A' to 'Z' do
  begin
    if (C < 'C') or DriveValid(C) then
    begin
      S := C + ':';
      AList^.Insert(NewDirEntry(S, S + '\'));
    end;
  end;
  NewList(AList);
  FocusItem(Cur);
end;

procedure TDirListBox.SetData(var Rec);
begin
end;

procedure TDirListBox.SetState(AState : word; Enable : Boolean);
begin
   TextListBox.SetState(AState,Enable);
   if (State and sfFocused <> 0) and (Owner <> nil) then
       Message(Owner, evBroadcast, cmDirFocused, List^.At(Focused));
end;

procedure RegisterStdDlg;
begin
  RegisterType(RFileInputLine);
  RegisterType(RFileCollection);
  RegisterType(RFileList);
  RegisterType(RFileDialog);
  RegisterType(RDirCollection);
  RegisterType(RDirListBox);
end;

end.
