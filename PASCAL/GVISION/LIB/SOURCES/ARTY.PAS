{**************************************************}
{    Arty.pas                                      }
{    Graph Vision demo unit                        }
{    Sergey E.Levov, Moscow, 1993                  }
{**************************************************}

unit Arty;

{$F+,O+,S-,D-}

interface

uses Graph, EventMan,Objects, Grav;

const
   Memory  = 50;
   cmIdle  = 10101;

type
  PArtyView = ^ArtyView;
  ArtyView = object(GraphView)
     Lines:  array [1..Memory] of record
                                 LS: TPoint;
                                 LE: TPoint;
                                 LColor : integer;
                                 IsUpdate : boolean;
                               end;
     S,E : TPoint;
     CurrentLine,
     ColorCount,
     IncrementCount : integer;
     Delta1,Delta2 : TPoint;
     MaxColors : word;
     MaxDelta : integer;
     Color: integer;
     BackColor:integer;
     constructor Init(Bounds : TRect);
     procedure Draw; virtual;
     procedure Update;
     private
     FirstDraw : boolean;
     procedure AdjustX(var X,DeltaX: integer);
     procedure AdjustY(var Y,DeltaY: integer);
     procedure DrawLine(Ps,Pe : TPoint; AColor : word);
     procedure SaveCurrentLine(CurrentColor: word);
     procedure SelectNewColor;
     procedure SelectNewDeltaValues;
     procedure Updateline;
  end;

  PArtyWindow = ^ArtyWindow;
  ArtyWindow = object(GraphWindow)
     Party : PArtyView;
     constructor Init;
     procedure HandleEvent(var Event : TEvent); virtual;
  end;


implementation
uses GrDriver,LowGraph;

constructor ArtyView.Init(Bounds : TRect);
var
  I: integer;
  StartX, StartY: integer;
begin
  GraphView.Init(Bounds);
  Randomize;
  CurrentLine    := 1;
  MaxColors := GetMaxColor;
  SelectNewColor;
  IncrementCount := 0;
  MaxDelta := 16;
  BackColor := Black;
  StartX := Size.X div 2;
  StartY := Size.Y div 2;
  for I := 1 to Memory do with Lines[I] do begin
     IsUpdate := true;
     LS.X := StartX; LE.X := StartX+1;
     LS.Y := StartY; LE.Y := StartY+1;
  end;
  S.X := StartX;
  E.X := StartX;
  S.Y := StartY+1;
  E.Y := StartY+1;
  FirstDraw := true;
end;

procedure ArtyView.AdjustX(var X,DeltaX: integer);
var
  TestX: integer;
begin
  TestX := X+DeltaX;
  if (TestX<1) or (TestX>Size.X) then begin
    TestX := X;
    DeltaX := -DeltaX;
  end;
  X := TestX;
end;

procedure ArtyView.AdjustY(var Y,DeltaY: integer);
var
  TestY: integer;
begin
  TestY := Y+DeltaY;
  if (TestY<1) or (TestY>Size.Y) then begin
    TestY := Y;
    DeltaY := -DeltaY;
  end;
  Y := TestY;
end;

procedure ArtyView.SelectNewColor;
begin
  Color := Random(MaxColors)+1;
  ColorCount := 3*(1+Random(5));
end;

procedure ArtyView.SelectNewDeltaValues;
begin
  Delta1.X := Random(MaxDelta)-(MaxDelta Div 2);
  Delta2.X := Random(MaxDelta)-(MaxDelta Div 2);
  Delta1.Y := Random(MaxDelta)-(MaxDelta Div 2);
  Delta2.Y := Random(MaxDelta)-(MaxDelta Div 2);
  IncrementCount := 2*(1+Random(4));
end;


procedure ArtyView.SaveCurrentLine(CurrentColor: word);
begin
  with Lines[CurrentLine] do
  begin
    LS := S;
    LE := E;
    LColor := CurrentColor;
    IsUpdate := true;
  end;
end;

procedure ArtyView.DrawLine(PS,PE : TPoint; AColor : word);
var
  R : TRect;
begin
  R.A := PS;
  R.B := PE;
  SetColor(AColor);
  Line(R);
end;

procedure ArtyView.Draw;
var
  I: integer;
  R : TRect;
  OldMode : integer;
  LL : LineSettingsType;
begin
  OldMode := Mode;
  GrDriver.SetWriteMode(NormalPut);
  if FirstDraw then begin
     GetExtent(R);
     SetFillStyle(SolidFill,BackColor);
     Bar(R);
  end;
  GetLineSettings(LL);
  for I := 1 to Memory do with Lines[I] do begin
    if LColor = BackColor then
    with LL do SetLineStyle(LineStyle,Pattern,ThickWidth);
    DrawLine(LS,LE,LColor);
    if LColor = BackColor then
    with LL do SetLineStyle(LineStyle,Pattern,Thickness);
  end;
  GrDriver.SetWriteMode(OldMode);
end;

procedure ArtyView.Updateline;
begin
  Inc(CurrentLine);
  if CurrentLine > Memory then CurrentLine := 1;
  Dec(ColorCount);
  Dec(IncrementCount);
end;

procedure ArtyView.Update;
var
   R : TRect;
   Old : boolean;
begin
   with Lines[CurrentLine] do begin
      IsUpdate := true;
      LColor := BackColor;
   end;
   Old := FirstDraw;
   FirstDraw := false;
   GetClipRect(R);
   RefreshRect(R);
   if ColorCount = 0 then SelectNewColor;
   if IncrementCount=0 then SelectNewDeltaValues;

    AdjustX(S.X,Delta1.X); AdjustX(E.X,Delta2.X);
    AdjustY(S.Y,Delta1.Y); AdjustY(E.Y,Delta2.Y);

    if Random(9)=5 then begin
      S.X := (S.X+E.X) div 2; { shorten the lines }
      E.Y := (S.Y+E.Y) div 2;
    end;

    SaveCurrentLine(Color);
    RefreshRect(R);
    UpdateLine;
    FirstDraw := old;
end;

constructor ArtyWindow.Init;
var
   R : TRect;
begin
   R.Assign(50, 50, 350, 270);
   GraphWindow.Init(R, 'Arty', wfMove + wfTitle+ wfFramed + wfClose);
   GrowMode := 0;
   WorkSpace^.GetExtent(R);
   PArty := New(PArtyView,Init(R));
   Insert(PArty);
end;

procedure ArtyWindow.HandleEvent(var Event : TEvent);
var
   R : TRect;
begin
   GraphWindow.HandleEvent(Event);
   if (Event.What = evBroadcast) and(Event.Command = cmIdle)
   then PArty^.Update;
end;

end.
