{************************************************}
{   Calc.pas                                     }
{   Graph Vision Demo unit                       }
{   Sergey E. Levov, Moscow,1993                 }
{   Portions copyright (c) 1990 by Borland Int.  }
{************************************************}

unit Calc;

{$F+,O+,S-}

interface

uses Graph,EventMan, Objects, GraV, Controls;

type

  TCalcState = (csFirst, csValid, csError);

  PCalcDisplay = ^TCalcDisplay;
  TCalcDisplay = object(GraphView)
    Status: TCalcState;
    Number: string[15];
    Sign: Char;
    Operator: Char;
    Operand: Real;
    constructor Init(var Bounds: TRect);
    constructor Load(var S: TStream);
    procedure CalcKey(Key: Char);
    procedure Clear;
    procedure Draw; virtual;
    function GetPalette : PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
  end;

  PCalculator = ^TCalculator;
  TCalculator = object(GraphDialog)
    constructor Init;
  end;

const
  RCalcDisplay: TStreamRec = (
     ObjType: 10040;
     VmtLink: Ofs(TypeOf(TCalcDisplay)^);
     Load:    @TCalcDisplay.Load;
     Store:   @TCalcDisplay.Store
  );
  RCalculator: TStreamRec = (
     ObjType: 10041;
     VmtLink: Ofs(TypeOf(TCalculator)^);
     Load:    @TCalculator.Load;
     Store:   @TCalculator.Store
  );

procedure RegisterCalc;

implementation

uses GrDriver,GFonts;

const
  cmCalcButton = 10100;

constructor TCalcDisplay.Init(var Bounds: TRect);
begin
  GraphView.Init(Bounds);
  Options := Options or (ofSelectable + ofCenterX);
  EventMask := evKeyDown + evBroadcast;
  Clear;
end;

constructor TCalcDisplay.Load(var S: TStream);
begin
  GraphView.Load(S);
  S.Read(Status, SizeOf(Status) + SizeOf(Number) + SizeOf(Sign) +
    SizeOf(Operator) + SizeOf(Operand));
end;

procedure TCalcDisplay.CalcKey(Key: Char);
var
  R: Real;

procedure Error;
begin
  Status := csError;
  Number := 'Error';
  Sign := ' ';
end;

procedure SetDisplay(R: Real);
var
  S: string[63];
begin
  Str(R: 0: 10, S);
  if S[1] <> '-' then Sign := ' ' else
  begin
    Delete(S, 1, 1);
    Sign := '-';
  end;
  if Length(S) > 15 + 1 + 10 then Error
  else
  begin
    while S[Length(S)] = '0' do Dec(S[0]);
    if S[Length(S)] = '.' then Dec(S[0]);
    Number := S;
  end;
end;

procedure GetDisplay(var R: Real);
var
  E: Integer;
begin
  Val(Sign + Number, R, E);
end;

procedure CheckFirst;
begin
  if Status = csFirst then
  begin
    Status := csValid;
    Number := '0';
    Sign := ' ';
  end;
end;

begin
  Key := UpCase(Key);
  if (Status = csError) and (Key <> 'C') then Key := ' ';
  case Key of
    '0'..'9':
      begin
        CheckFirst;
        if Number = '0' then Number := '';
        Number := Number + Key;
      end;
    '.':
      begin
        CheckFirst;
        if Pos('.', Number) = 0 then Number := Number + '.';
      end;
    #8, #27:
      begin
        CheckFirst;
        if Length(Number) = 1 then Number := '0' else Dec(Number[0]);
      end;
    '_', #241:
      if Sign = ' ' then Sign := '-' else Sign := ' ';
    '+', '-', '*', '/', '=', '%', #13:
      begin
        if Status = csValid then
        begin
          Status := csFirst;
          GetDisplay(R);
          if Key = '%' then
            case Operator of
              '+', '-': R := Operand * R / 100;
              '*', '/': R := R / 100;
            end;
          case Operator of
            '+': SetDisplay(Operand + R);
            '-': SetDisplay(Operand - R);
            '*': SetDisplay(Operand * R);
            '/': if R = 0 then Error else SetDisplay(Operand / R);
          end;
        end;
        Operator := Key;
        GetDisplay(Operand);
      end;
    'C':
      Clear;
  end;
  DrawView;
end;

procedure TCalcDisplay.Clear;
begin
  Status := csFirst;
  Number := '0';
  Sign := ' ';
  Operator := '=';
end;

procedure TCalcDisplay.Draw;
var
  I,j: Integer;
  B: String;
  R : TRect;
  T : TPoint;
begin
  GFonts.SetTextStyle(SystemFont,HorizDir,1);
  GetExtent(R);
  j := (Size.X div 8);
  I := j - Length(Number);
  FillChar(B[1],j,' ');
  Byte(B[0]) := j;
  B[I] := Sign;
  Move(Number[1],B[I + 1], word(Number[0]));
  SetColor(GetColor(2));
  SetFillStyle(SolidFill,GetColor(1));
  if not CanFillBackground then Bar(R);
  SetTextJustify(LeftText,CenterText);
  T.X := 0;
  T.Y := Size.Y div 2;
  WriteTextXY(T,B);
end;

function TCalcDisplay.GetPalette : PPalette;
const
   P : String[Length(CStaticText)] = #24#25;
begin
   GetPalette := @P;
end;

procedure TCalcDisplay.HandleEvent(var Event: TEvent);
begin
  GraphView.HandleEvent(Event);
  case Event.What of
    evKeyDown:
      begin
        CalcKey(Event.CharCode);
        ClearEvent(Event);
      end;
    evBroadcast:
      if Event.Command = cmCalcButton then
      begin
        CalcKey(PGraphButton(Event.InfoPtr)^.Title^[1]);
        ClearEvent(Event);
      end;
  end;
end;

procedure TCalcDisplay.Store(var S: TStream);
begin
  GraphView.Store(S);
  S.Write(Status, SizeOf(Status) + SizeOf(Number) + SizeOf(Sign) +
    SizeOf(Operator) + SizeOf(Operand));
end;

{ TCalculator }

constructor TCalculator.Init;
const
  KeyChar: array[0..19] of Char = 'C'#27'%'#241'789/456*123-0.=+';
var
  I,j: Integer;
  P: PGraphView;
  R,R1: TRect;
begin
  R.Assign(40, 30, 200, 230);
  GraphDialog.Init(R, 'Calculator');
  Options := Options or ofFirstClick;
  WorkSpace^.GetExtent(R);
  R1.Assign(0,16,132,36);
  P := New(PGraphGrayGroup,Init(R1));
  P^.Options := P^.Options or ofCenterX;
  Insert(P);
  for I := 0 to 19 do
  begin
    R.A.X := (I mod 4) * 36 + 4;
    R.A.Y := (I div 4) * 24 + 50;
    R.B.X := R.A.X + 34;
    R.B.Y := R.A.Y + 22;
    P := New(PGraphTextButton, Init(R, KeyChar[I], cmCalcButton,
      bfNormal + bfBroadcast));
    P^.Options := P^.Options and not ofSelectable;
    Insert(P);
  end;
  i := CurrentFont;
  GFonts.SetTextStyle(SystemFont,HorizDir,1);
  j := GFonts.TextHeight(' ');
  GFonts.SetTextStyle(i,HorizDir,1);
  R1.Grow(-1,-((20-j) div 2));
  Insert(New(PCalcDisplay, Init(R1)));
End;

procedure RegisterCalc;
begin
  RegisterType(RCalcDisplay);
  RegisterType(RCalculator);
end;

end.
