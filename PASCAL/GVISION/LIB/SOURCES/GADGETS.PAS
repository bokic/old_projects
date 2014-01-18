{************************************************}
{   Gadgets.pas                                  }
{   Graph Vision Demo unit                       }
{   Sergey E. Levov, Moscow,1993                 }
{   Portions copyright (c) 1990 by Borland Int.  }
{************************************************}
unit Gadgets;

{$F+,O+,S-,D+}

{ Useful gadgets: clock and heap available viewer }

interface

uses Dos, Objects, Grav,GrApp;

type
  PHeapView = ^THeapView;
  THeapView = object(GraphView)
    OldMem : LongInt;
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    function GetMemSize : LongInt; virtual;
    procedure Update;
  end;

{$IFNDEF DPMI }
  PXmsView = ^TXmsView;
  TXmsView = object(THeapView)
     function GetMemSize : LongInt; virtual;
  end;
{$ENDIF}

  PClockView = ^TClockView;
  TClockView = object(GraphView)
    Refresh: Byte;
    LastTime: DateTime;
    TimeStr: string[10];
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    function FormatTimeStr(H, M, S: Word): String; virtual;
    procedure Update; virtual;
  end;


implementation

{$IFNDEF DPMI}
uses Graph,EventMan,GrDriver,GFonts,LowGraph,Xms;
{$ELSE}
uses Graph,EventMan,GrDriver,GFonts,LowGraph;
{$ENDIF}

{ heap space viewer }

constructor THeapView.Init(var Bounds: TRect);
begin
  GraphView.Init(Bounds);
  GrowMode := gfGrowAll;
  OldMem := 0;
end;

function THeapView.GetMemSize : LongInt;
begin
   GetMemSize := MemAvail;
end;

procedure THeapView.Draw;
var
  S: String;
  i : integer;
  R : TRect;
begin
  OldMem := GetMemSize;
  i := Size.X div 8;
  if Size.X mod 8 <> 0 then Inc(i);
  Str(OldMem:i, S);
  GFonts.SetTextStyle(SystemFont,HorizDir,1);
  SetColor(GetColor(10));
  SetFillStyle(SolidFill,GetColor(4));
  SetTextJustify(Lefttext,TopText);
  GetExtent(R);
  WriteTextXy(R.A,S);
end;

procedure THeapView.Update;
begin
  if (OldMem <> GetMemSize) then DrawView;
end;

{$IFNDEF DPMI}
{ XMS space viewer }

function TXmsView.GetMemSize : LongInt;
begin
   GetMemSize := LongInt(Xms_MemAvail);
end;
{$ENDIF}

{-------- ClockView Object --------}

function LeadingZero(w: Word): String;
var s: String;
begin
  Str(w:0, s);
  LeadingZero := Copy('00', 1, 2 - Length(s)) + s;
end;

constructor TClockView.Init(var Bounds: TRect);
begin
  GraphView.Init(Bounds);
  GrowMode := gfGrowLoX + gfGrowHiX;
  FillChar(LastTime, SizeOf(LastTime), #$FF);
  TimeStr := '';
  Refresh := 1;
end;


procedure TClockView.Draw;
var
   R : TRect;
   OldMode : word;
begin
  GFonts.SetTextStyle(SystemFont,HorizDir,1);
  OldMode := Mode;
  GrDriver.SetWriteMode(NormalPut);
  SetColor(GetColor(10));
  SetFillStyle(SolidFill,GetColor(4));
  SetTextJustify(LeftText,TopText);
  GetExtent(R);
  WriteTextXY(R.A,TimeStr);
{  GrDriver.SetWriteMode(OldMode);}
  Mode:=OldMode;
end;


procedure TClockView.Update;
var
  h,m,s,hund: word;
begin
  GetTime(h,m,s,hund);
  if Abs(s - LastTime.sec) >= Refresh then
  begin
    with LastTime do
    begin
      Hour := h;
      Min := m;
      Sec := s;
    end;
    TimeStr := FormatTimeStr(h, m, s);
    DrawView;
  end;
end;

function TClockView.FormatTimeStr(H, M, S: Word): String;
begin
  FormatTimeStr := LeadingZero(h)+ ':'+ LeadingZero(m) +
    ':' + LeadingZero(s);
end;

end.
