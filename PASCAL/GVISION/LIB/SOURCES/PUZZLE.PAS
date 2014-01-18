{************************************************}
{   Puzzle.pas                                   }
{   Graph Vision Demo unit                       }
{   Sergey E. Levov, Moscow,1993                 }
{   Portions copyright (c) 1990 by Borland Int.  }
{************************************************}

unit Puzzle;

{$F+,O+,S-,D-}

interface

Uses Graph, GraV, EventMan, Objects, GFonts, Controls;

type

 TBoard = array[0..5,0..5] of Char;

 PMovesTableau = ^TMovesTableau;
 TMovesTableau = object(GraphView)
   Moves : word;
   constructor Init(Bounds : TRect);
   constructor Load(var S : TStream);
   procedure Draw; virtual;
   procedure SetValue(AValue : word);
   procedure Store(var S : TStream);
 end;

 PPuzzleView = ^TPuzzleView;
 TPuzzleView = object(GraphView)
   Board: TBoard;
   Solved: Boolean;
   Indicator : PMovesTableau;
   constructor Init(Bounds: TRect; AIndicator : PMovesTableau);
   constructor Load(var S: TStream);
   procedure HandleEvent(var Event: TEvent); Virtual;
   procedure Draw; Virtual;
   procedure MoveKey(Key: Word);
   procedure MoveTile(Point: TPoint);
   procedure Scramble;
   procedure Store(var S: TStream);
   procedure WinCheck;
 end;

 PPuzzleWindow = ^TPuzzleWindow;
 TPuzzleWindow = object(GraphWindow)
   constructor Init;
 end;

const
  RPuzzleView: TStreamRec = (
     ObjType: 10010;
     VmtLink: Ofs(TypeOf(TPuzzleView)^);
     Load:    @TPuzzleView.Load;
     Store:   @TPuzzleView.Store
  );
  RMovesTableau : TStreamRec = (
     ObjType: 10011;
     VmtLink: Ofs(TypeOf(TMovesTableau)^);
     Load:    @TMovesTableau.Load;
     Store:   @TMovesTableau.Store
  );
  RPuzzleWindow: TStreamRec = (
     ObjType: 10012;
     VmtLink: Ofs(TypeOf(TPuzzleWindow)^);
     Load:    @TPuzzleWindow.Load;
     Store:   @TPuzzleWindow.Store
  );

procedure RegisterPuzzle;

Implementation

{ TPuzzleWindow }

constructor TPuzzleWindow.Init;
var
  R,R1: TRect;
  PPuzzle : PPuzzleView;
begin
  R.Assign(10, 10, 166, 130);
  GraphWindow.Init(R, 'Puzzle', wfMove + wfTitle+ wfFramed + wfClose);
  GrowMode := 0;
  WorkSpace^.GetExtent(R);
  R.B.X := R.B.Y;
  R.Grow(1,1);
  Insert(New(PGraphGrayGroup,Init(R)));
  R.Grow(-1,-1);
  R1.Assign(102,40,142, 72);
  PPuzzle := New(PPuzzleView, Init(R,New(PMovesTableau,Init(R1))));
  Insert(PPuzzle);
  Insert(PPuzzle^.Indicator);
end;

{ TMovesTableau }

constructor TMovesTableau.Init(Bounds : TRect);
begin
   GraphView.Init(Bounds);
   GrowMode := gfGrowLoY + gfGrowHiY;
end;

constructor TMovesTableau.Load(var S : TStream);
begin
   GraphView.Load(S);
   S.Read(Moves,SizeOf(Moves));
end;

procedure TMovesTableau.Draw;
var
   R : TRect;
   P : TPoint;
   Temp : String;
begin
   GetExtent(R);
   SetFillStyle(SolidFill,LightGray);
   GFonts.SetTextStyle(SystemFont,HorizDir,1);
   if not CanFillBackground then Bar(R);
   SetTextJustify(LeftText,TopText);
   SetColor(Blue);
   P := R.A;
   WriteTextXY(P,'Moves');
   inc(P.Y,16);
   Str(Moves:5,Temp);
   WriteTextXY(P,Temp);
end;

procedure TMovesTableau.SetValue(AValue : word);
begin
   Moves := AValue;
   DrawView;
end;

procedure TMovesTableau.Store(var S : TStream);
begin
   GraphView.Store(S);
   S.Write(Moves,SizeOf(Moves));
end;

{ TPuzzleView }

constructor TPuzzleView.Init(Bounds: TRect; AIndicator : PMovesTableau);
type
  TBoardValue = array[1..16] of Char;
const
  SBoardValue: TBoardValue =
    ('A','B','C','D',
     'E','F','G','H',
     'I','J','K','L',
     'M','N','O',' ');
var
  I, J: Integer;
begin
  GraphView.Init(Bounds);
  Indicator := AIndicator;
  Randomize;
  Options := Options or ofSelectable;
  FillChar(Board, SizeOf(Board), '?');
  for I := 0 to 3 do
    for J := 0 to 3 do
      Board[I+1, J+1] := SBoardValue[I*4 + J+1];
  Scramble;
end;

constructor TPuzzleView.Load(var S: TStream);
begin
  GraphView.Load(S);
  S.Read(Board, SizeOf(Board) + SizeOf(Solved));
  GetPeerViewPtr(S,Indicator);
end;

Procedure TPuzzleView.Draw;
var
  I, J, K: Integer;
  B: array[0..17] of word;
  S1: String[3];
  Color: array[0..1] of record Norm,Light,Dark,Fore : word end;
  ColorBack: Word;
  R : TRect;
  P : TPoint;
const
  Map: array['A'..'O'] of Byte =
    (0, 1, 0, 1,
     1, 0, 1, 0,
     0, 1, 0, 1,
     1, 0, 1);
begin
  SetTextJustify(CenterText,Centertext);
  GFonts.SetTextStyle(SystemFont,HorizDir,1);
  with Color[0] do begin
     Norm := Red;
     Light := LightRed;
     Dark := Black;
     Fore := Yellow;
  end;
  ColorBack := LightGray;
  if Solved then Color[1] := Color[0]
  else with Color[1] do
  begin
     Norm := Blue;
     Light := LightBlue;
     Dark := Black;
     Fore := LightMagenta;
  end;
  for I := 1 to 4 do
    for J := 1 to 4 do
    begin
      R.Assign((j-1)*24,(i-1)*24,j*24,i*24);
      if Board[I, J] = ' ' then begin
         SetFillStyle(SolidFill,ColorBack);
         Bar(R);
      end else with Color[Map[Board[i,j]]] do begin
        BicolorRectangle(R,Light,Dark,false);
        R.Grow(-1,-1);
        SetFillStyle(SolidFill,Norm);
        SetColor(Fore);
        Bar(R);
        P.X := R.A.X + (R.B.X-R.A.X) div 2;
        P.Y := R.A.Y + (R.B.Y - R.A.Y) div 2;
        WriteTextXY(P,Board[i,j])
      end;
    end;
end;

procedure TPuzzleView.HandleEvent(var Event: TEvent);
begin
  GraphView.HandleEvent(Event);
  if Solved and (Event.What and (evKeyDown + evMouseDown) <> 0) then
  begin
    Scramble;
    ClearEvent(Event);
  end;
  case Event.What of
    evMouseDown: MoveTile(Event.Where);
    evKeyDown: MoveKey(Event.KeyCode);
  else
    Exit;
  end;
  ClearEvent(Event);
  WinCheck;
end;

procedure TPuzzleView.MoveKey(Key: Word);
var
  X, Y, I, J: Integer;
  CheckDraw : boolean;
  M : word;
begin
  CheckDraw := false;
  for I:=1 To 4 do
    for J:=1 To 4 do
      if Board[i,j] = ' ' then
      begin
        Y:=I;
        X:=J;
      end;

  case Key of
    kbDown:
      if Y > 1 then
      begin
        Board[Y, X] := Board[Y-1, X];
        Board[Y-1, X] := ' ';
        if Indicator <> nil then begin
           M := Indicator^.Moves;
           Indicator^.SetValue(M+Byte(M<1000));
        end;
        CheckDraw := true;
      end;
    kbUp:
      if Y < 4 then
      begin
        Board[Y, X] := Board[Y+1, X];
        Board[Y+1, X] := ' ';
        if Indicator <> nil then begin
           M := Indicator^.Moves;
           Indicator^.SetValue(M+Byte(M<1000));
        end;
        CheckDraw := true;
      end;
    kbRight:
      if X > 1 then
      begin
        Board[Y, X] := Board[Y, X-1];
        Board[Y, X-1] := ' ';
        if Indicator <> nil then begin
           M := Indicator^.Moves;
           Indicator^.SetValue(M+Byte(M<1000));
        end;
        CheckDraw := true;
      end;
    kbLeft:
      if X < 4 then
      begin
        Board[Y, X] := Board[Y, X+1];
        Board[Y, X+1] := ' ';
        if Indicator <> nil then begin
           M := Indicator^.Moves;
           Indicator^.SetValue(M+Byte(M<1000));
        end;
        CheckDraw := true;
      end;
  end;
if CheckDraw then DrawView;
end;

procedure TPuzzleView.MoveTile(Point: TPoint);
var
  P: TPoint;
  X, Y: Word;
  CheckDraw : boolean;
  M : word;
begin
  MakeLocal(Point, P);
  X := ((P.X + 24) div 24);
  Y := ((P.Y + 24) div 24);
  CheckDraw := false;
  if (X > 0) and (X < 5) and (Y > 0) and (Y < 5) Then
  begin
    if Board[Y, X-1] = ' ' then
    begin
      Board[Y, X-1] := Board[Y, X];
      Board[Y, X] := ' ';
      if Indicator <> nil then begin
         M := Indicator^.Moves;
         Indicator^.SetValue(M+Byte(M<1000));
      end;
      CheckDraw := true;
    end;
    if Board[Y-1, X] = ' ' then
    begin
      Board[Y-1, X] := Board[Y, X];
      Board[Y, X] := ' ';
      if Indicator <> nil then begin
         M := Indicator^.Moves;
         Indicator^.SetValue(M+Byte(M<1000));
      end;
      CheckDraw := true;
    end;
    if Board[Y, X+1] = ' ' then
    begin
      Board[Y, X+1] := Board[Y, X];
      Board[Y, X] := ' ';
      if Indicator <> nil then begin
         M := Indicator^.Moves;
         Indicator^.SetValue(M+Byte(M<1000));
      end;
      CheckDraw := true;
    end;
    if Board[Y+1, X] = ' ' then
    begin
      Board[Y+1, X] := Board[Y, X];
      Board[Y, X] := ' ';
      if Indicator <> nil then begin
         M := Indicator^.Moves;
         Indicator^.SetValue(M+Byte(M<1000));
      end;
      CheckDraw := true;
    end;
  end;
  if CheckDraw then DrawView;
end;

procedure TPuzzleView.Scramble;
var
   M : word;
begin
  Solved := False;
  if Owner <> nil then Owner^.Lock;
  M := 0;
  repeat
    case Random(4) of
      0: MoveKey(kbUp);
      1: MoveKey(kbDown);
      2: MoveKey(kbRight);
      3: MoveKey(kbLeft);
    end;
    inc(M);
  until M=500;
  if Owner <> nil then Owner^.Unlock;
  if Indicator <> nil then Indicator^.SetValue(0);
  DrawView;
end;

procedure TPuzzleView.Store(var S: TStream);
begin
  GraphView.Store(S);
  S.Write(Board, SizeOf(Board) + SizeOf(Solved));
  PutPeerViewPtr(S,Indicator);
end;

procedure TPuzzleView.WinCheck;
type
  BoardStr = array [0..35] of Char;
const
  FBoard: BoardStr = '???????ABCD??EFGH??IJKL??MNO ???????';
var
  I: Integer;
begin
  Solved := BoardStr(Board) = FBoard;
  if Solved then DrawView;
end;

procedure RegisterPuzzle;
begin
  RegisterType(RPuzzleView);
  RegisterType(RMovesTableau);
  RegisterType(RPuzzleWindow);
end;

end.
