{************************************************}
{   GFonts.pas                                   }
{   Graph Vision unit                            }
{   Sergey E. Levov, Moscow,1992-1994            }
{************************************************}

unit GFonts;
{$X+,G+,I-,S-,P-,D-}

interface
uses Objects;

type

   BiosFontParams = record
      Width : word;
      Height : word;
      BytesPerChar : word;
      case TwoPart : boolean of
      false : (ImageTable : pointer);
      true :  (Base,Top : pointer);
   end;

   PFont = ^TFont;
   TFont = object(TObject)
      FontName : String;
      constructor Init(AName : string);
      function TextWidth(S : String) : integer; virtual;
      function TextHeight(S : String) : integer; Virtual;
      procedure OutText(S : String); virtual;
      procedure OutTextXY(Location : TPoint; S : String); virtual;
      procedure SetTextStyle(Direction,Size : word); virtual;
      function GetFontName : string;
      function CanFillBackground : boolean; virtual;
      function GetCharHeight(Ch : Char) : word; virtual;
      function GetCharWidth(Ch : Char) : word;  virtual;
   end;

   PBGIFont = ^TBGIFont;
   TBGIFont = object(TFont)
      ID : integer;
      constructor Init(AName : String; AID : integer);
      function TextWidth(S : String) : integer; virtual;
      function TextHeight(S : String) : integer; Virtual;
      procedure OutText(S : String); virtual;
      procedure OutTextXY(Location : TPoint; S : String); virtual;
      procedure SetTextStyle(Direction,Size : word); virtual;
      function CanFillBackground : boolean; virtual;
      function GetCharHeight(Ch : Char) : word; virtual;
      function GetCharWidth(Ch : Char) : word;  virtual;
   end;

   PDefaultBGIFont = ^TDefaultBGIFont;
   TDefaultBGIFont = object(TBGIFont)
      procedure OutText(S : String); virtual;
      procedure OutTextXY(Location : TPoint; S : String); virtual;
   end;

   PRasterFont = ^TRasterFont;
   TRasterFont = object(TFont)
     FirstChar    : byte;       {first char code in image table}
     CharCount    : byte;       {chars in table (one less) }
     ImageTable : Pointer;      {pointer to font definition table}
     CharHeight : word;         {real char height}
     constructor Init(AName : String; AImageTable : Pointer; First,Count : byte);
     function BytesPerChar(Ch : Char) : word; virtual;
     function GetCharImage(Ch : Char) : Pointer; virtual;
     function GetCharHeight(Ch : Char) : word; virtual;
     procedure OutText(S : String); virtual;
     procedure OutTextXY(Location : TPoint; S : String); virtual;
     function TextHeight(S : String) : integer; virtual;
     function TextWidth(S : String) : integer; virtual;
   end;

   PFixedFont = ^TFixedFont;
   TFixedFont = object(TRasterFont)
     CharWidth : word;          {real char width}
     constructor Init(AName : String; AImageTable : Pointer;
                      First,Count : byte;
                      AWidth,AHeight : word);
     function BytesPerChar(Ch : Char) : word; virtual;
     function GetCharWidth(Ch : Char) : word;  virtual;
     function GetCharImage(Ch : Char) : Pointer; virtual;
   end;

   PBiosFont = ^TBiosFont;
   TBiosFont = object(TFixedFont)
     Bytes : word;
     constructor Init(AName : String; AImageTable : Pointer; AWidth,
                      AHeight,ABytes : word);
     function BytesPerChar(Ch : Char) : word; virtual;
   end;

   P8x8BiosFont = ^T8x8BiosFont;
   T8x8BiosFont = object(TBiosFont)
     Top : Pointer;
     constructor Init(AName : string; ABase,ATop : Pointer; ABytes : word);
     function GetCharImage(Ch : Char) : Pointer; virtual;
   end;

const
   SystemFont : integer = 0;       {System font init as default font}
   CurrentFont : integer = 0;      {Current font initialises as default font}
   FillBackground : boolean = true; {draw background pixels if true}

var
   Fonts : PCollection;

procedure InitFonts;
procedure DoneFonts;
procedure SelectFont(Font : integer);
function CanFillBackground : boolean;
procedure OutText(S : String);
procedure OutTextXY(Location : TPoint; S : String);
procedure SetTextStyle(Font,Direction : word; CharSize : word);
function TextHeight(S : String) : integer;
function TextWidth(S : String) : integer;

implementation
uses Graph,GrDriver,LowGraph,Memory;

const
   Font8x8 = 1;
   Font8x14 = 2;
   Font8x16 = 3;

   FontNames : Array[1..3] of String[14] = ('8x8 BIOS font',
                                            '8x14 BIOS font',
                                            '8x16 BIOS font');
   DefaultSysFont : integer = 2;   {default font for EGA/VGA}

var
   TextSettings : TextSettingsType;
   FillSettings : FillSettingsType;

{ BIOS fonts support routines }

function GetMaxFont : integer;
begin
   GetMaxFont := 3;
end;

procedure GetFontParams(Font : integer; var Params : BiosFontParams);
var
   H : word;
   B : byte absolute $40:$85;
   T : byte;
   P : Pointer;
   R : PByteArray absolute P;

{$IFDEF DPMI}
   CallBack : TRealRegs {absolute  RealModeRegs};
{$ENDIF}

function GetBytePerChar : byte; assembler;
asm
	MOV	ES,Seg0040
	MOV	AL,ES:B
end;

begin
{$IFDEF DPMI}
   FillChar(CallBack,SizeOf(CallBack),#0);
{$ENDIF}
   if Font > GetMaxFont then
   with Params do begin
      ImageTable := nil;
      Width := 0;
      Height := 0;
      BytesPerChar := 0;
   end else
   begin
     case Font of
        Font8x8 : T := $23;
        Font8x14 : T := $22;
        Font8x16 : T := $24;
     end;
     asm
        push    bp
        push    ds
        mov     ah,$11
        mov     bl,2
        mov     al,T
        int     $10
        pop     ds
        pop     bp
     end;
     Params.BytesPerChar := GetBytePerChar;
     Params.Width := 8;
     case Font of
        Font8x8 : T := 3;
        Font8x14 : T := 2;
        Font8x16 : T := 6;
     end;
     asm
{$IFNDEF DPMI}
        mov     ax,$1130
        mov     bh,T
        push    bp
        int     $10
        mov     ax,bp
        pop     bp
        mov     H,cx
        mov     P.word[0],ax
        mov     P.word[2],es
{$ELSE}
        mov     CallBack.RealEAX.word[0],$1130
        mov     bh,T
        mov     CallBack.RealEBX.word[0],bx
        lea     di,CallBack
        push    es
        push    ss
        pop     es
        mov     ax,$300;
        mov     bx,$10
        xor     cx,cx
        int     $31
        pop     es
        mov     ax,CallBack.RealECX.word[0]
        mov     H,ax
        mov     bx,CallBack.RealES
        mov     ax,0002
        int     $31
        mov     P.word[2],ax
        mov     ax,CallBack.RealEBP.word[0]
        mov     P.word[0],ax
{$ENDIF}
      end;
     Params.Height := H;
     if Font <> Font8x8 then begin
        Params.TwoPart := false;
        Params.ImageTable := P
     end else begin
        Params.TwoPart := true;
        Params.Base := P;
        inc(T);
        asm
{$IFNDEF DPMI}
           mov     ax,$1130
           mov     bh,T
           push    bp
           int     $10
           mov     ax,bp
           pop     bp
           mov     P.word[0],ax
           mov     P.word[2],es
{$ELSE}
           mov     CallBack.RealEAX.word[0],$1130
           mov     bh,T
           mov     CallBack.RealEBX.word[0],bx
           lea     di,CallBack
           push    es
           push    ss
           pop     es
           mov     ax,$300;
           mov     bx,$10
           xor     cx,cx
           int     $31
           pop     es
           mov     bx,CallBack.RealES
           mov     ax,0002
           int     $31
           mov     P.word[2],ax
           mov     ax,CallBack.RealEBP.word[0]
           mov     P.word[0],ax
{$ENDIF}
        end;
        Params.Top := P;
     end;
   end;
end;

{ Methods for miscell font objects }

{ TFont methods }

constructor TFont.Init(AName : string);
begin
   TObject.Init;
   FontName := AName;
end;

function TFont.CanFillBackground : boolean;
begin
   CanFillBackground := true;
end;

function TFont.TextWidth(S : String) : integer;
begin
   Abstract;
end;

function TFont.TextHeight(S : String) : integer;
begin
   Abstract;
end;

procedure TFont.OutText(S : String);
begin
end;

procedure TFont.OutTextXY(Location : TPoint; S : String);
begin
end;

procedure TFont.SetTextStyle(Direction,Size : word);
begin
end;

function TFont.GetFontName : String;
begin
   GetFontName := FontName;
end;

function TFont.GetCharHeight(Ch : Char) : word;
begin
   Abstract;
end;

function TFont.GetCharWidth(Ch : Char) : word;
begin
   Abstract;
end;

{ TBGIFont methods}

constructor TBGIFont.Init(AName : String; AId : integer);
begin
   TFont.Init(AName);
   ID := AId;
end;

function TBGIFont.CanFillBackground : boolean;
begin
   CanFillBackground := false;
end;

function TBGIFont.TextWidth(S : String) : integer;
begin
   TextWidth := Graph.TextWidth(S);
end;

function TBGIFont.TextHeight(S : String) : integer;
begin
   TextHeight := Graph.TextHeight(S);
end;

procedure TBGIFont.OutText(S : String);
var
  V : ViewPortType;
  Cp : TPoint;
  i,j : integer;
begin
   Graph.OutText(S);
end;

procedure TBGIFont.OutTextXY(Location : TPoint; S : String);
var
  V : ViewPortType;
  i,j : integer;
begin
   with Location do Graph.OutTextXY(X,Y,S);
end;

procedure TBGIFont.SetTextStyle(Direction,Size : word);
begin
   Graph.SetTextStyle(Id,Direction,Size);
end;

function TBGIFont.GetCharHeight(Ch : Char) : word;
var
   S : string[1];
begin
   S[1] := Ch;
   GetCharHeight := TextHeight(S);
end;

function TBGIFont.GetCharWidth(Ch : Char) : word;
var
   S : string[1];
begin
   S[1] := Ch;
   GetCharWidth := TextWidth(S);
end;

procedure TDefaultBGIFont.OutText(S : String);
var
  V : ViewPortType;
  Cp : TPoint;
  i,j : integer;
begin
   GetViewSettings(V);
   CP.X := GetX;
   CP.Y := GetY;
   if CP.X < 0 then begin
      if Length(S) > 0 then J := (TextWidth(S) div Length(S)) else J := TextWidth('A');
      i := Abs(CP.X) div J;
      if Abs(CP.X) mod J > 0
      then inc(i);
      if i > Length(S) then i := Length(S);
      Graph.MoveTo(GetX+(i*j),GetY);
      S := Copy(S,i+1,Length(S)-i);
   end;
   Graph.OutText(S);
   Graph.MoveTo(GetX + TextWidth(S),GetY);
end;

procedure TDefaultBGIFont.OutTextXY(Location : TPoint; S : String);
var
  V : ViewPortType;
  i,j : integer;
begin
   GetViewSettings(V);
   if Location.X < 0 then begin
      if Length(S) > 0 then J := (TextWidth(S) div Length(S)) else J := TextWidth('A');
      i := Abs(Location.X) div J;
      if Abs(Location.X) mod J > 0
      then inc(i);
      inc(Location.X,i*j);
      S := Copy(S,i+1,Length(S)-i);
   end;
   with Location do Graph.OutTextXY(X,Y,S);
end;

{ TRasterFont methods }

procedure ExtractCharImage(X1,Y1,X2,Y2 : integer; W,H : integer;
                           var Source, Dest); assembler;
var
   SourceRowLen : word;
   DestLines,DestRowLen : word;
   DestLastMask : byte;
asm
       push    ds
       lds     si,Source
       les     di,Dest
       mov     cl,3
       cld
       mov     ax,W
       mov     bx,ax
       shr     ax,cl
       test    bx,7
       je      @@0
       inc     ax
@@0:   mov     SourceRowLen,ax
       mov     ax,x2               { bytes per row }
       sub     ax,x1
       inc     ax
       mov     bx,ax
{       mov     cl,3}
       shr     ax,cl
       test    bl,7
       je      @@1
       inc     ax
@@1:   mov     DestRowLen,ax
       mov     ax,y2               { rows }
       sub     ax,y1
       mov     DestLines,ax
       mov     ax,bx
       dec     ax
       mov     cx,$FF07            { define mask for last byte }
       test    bl,7
       je      @@1a
       and     cl,al
       xor     cl,7
       shl     ch,cl
@@1a:  mov     DestLastMask,ch
{ calculate start addr into source buffer }
       mov     ax,y1
       mov     bx,x1
       mov     cl,bl
       mov     dx,SourceRowLen
       mul     dx
       shr     bx,3
       add     bx,ax
       add     si,bx                { ds:si now points to first moved byte }
       and     cl,7                 { cl - shift count }
       mov     ch,DestLastMask
{ copy from Source to Dest }
       mov     dx,DestLines
@@2:   push    si
       mov     bx,DestRowLen
@@4:   lodsw                        { load word }
       dec     si
       rol     ax,cl                { prepare byte }
       stosb                        { save it }
       dec     bx                   { entire line moved ? }
       jnz     @@4                  { no - continue }
       and     es:[di-1],ch
       pop     si
       add     si,SourceRowLen
       dec     dx                   { all lines? }
       jns     @@2                  { no - continue }
{ all done }
       pop     ds
end;

constructor TRasterFont.Init(AName : String; AImageTable : Pointer; First,Count : byte);
begin
   TFont.Init(AName);
   ImageTable := AImageTable;
   FirstChar := First;
   CharCount := Count;
end;

function TRasterFont.BytesPerChar(Ch : Char) : word;
begin
   BytesPerChar := 0;
end;

function TRasterFont.GetCharHeight(Ch : Char) : word;
begin
   GetCharHeight := CharHeight;
end;

function TRasterFont.GetCharImage(Ch : Char) : Pointer;
begin
{   GetCharImage := nil;}
   Abstract;
end;

procedure TRasterFont.OutText(S : String);
var
   CP : TPoint;
begin
   CP.X := GetX;
   CP.Y := GetY;
   OutTextXY(CP,S);
   Graph.MoveTo(CP.X + TextWidth(S),CP.Y);
end;

procedure TRasterFont.OutTextXY(Location : TPoint; S : String);
var
   H,W,L,F,M,i : integer;
   Img,NI : pointer;
   X1,Y1,X2,Y2 : integer;
   Nx1,Ny1,Nx2,Ny2 : integer;
   NeedClip : boolean;
begin
   NeedClip := false;
   H := TextHeight(S);
   GetViewSettings(ViewPort);
   GetTextSettings(TextSettings);
   F := GetColor;
   inc(Location.X,ViewPort.X1);
   inc(Location.Y,ViewPort.Y1);
   case TextSettings.Vert of
     BottomText : dec(Location.Y,H);
     CenterText : dec(Location.Y,H div 2);
   end;
   W := TextWidth(S);
   case TextSettings.Horiz of
      RightText : dec(Location.X,W);
      CenterText : dec(Location.X,W div 2);
   end;
   GetFillSettings(FillSettings);
   L := Length(S);
   if not ViewPort.Clip then with ViewPort do begin
      X1 := 0;
      Y1 := 0;
      X2 := ScreenWidth-1;
      Y2 := ScreenHeight-1;
   end;
   SetController;
   for i := 1 to L do begin
      W := GetCharWidth(S[i]);
      with Location do begin
         Nx1 := X;
         Ny1 := Y;
      end;
      Nx2 := Nx1+W-1;
      Ny2 := Ny1+H-1;
      if Nx2 > ViewPort.X2 then begin
         Nx2 := ViewPort.X2;
         NeedClip := true;
      end;
      if Nx1 < ViewPort.X1 then begin
         Nx1 := ViewPort.X1;
         NeedClip := true;
      end;
      if Ny2 > ViewPort.Y2 then begin
         Ny2 := ViewPort.Y2;
         NeedClip := true;
      end;
      if Ny1 < ViewPort.Y1 then  begin
         Ny1 := ViewPort.Y1;
         NeedClip := true;
      end;
      Img := GetCharImage(S[i]);
      if not NeedClip then
         DrawChar(Location.X,Location.Y,W,H,F,FillSettings.Color,FillBackground,Img)
      else begin
         M := ((W shr 3)+1) * H;
         Ni := MemAlloc(M);
         if (Nx1 <= Nx2) and (Ny1 <= Ny2) then begin
            with Location do
            ExtractCharImage(Nx1-X,Ny1-Y,Nx2-X,Ny2-Y,W,H,Img^,Ni^);
            DrawChar(Nx1,Ny1,Nx2-Nx1+1,Ny2-Ny1+1,F,FillSettings.Color,FillBackground,Ni);
         end;
         FreeMem(Ni,M);
      end;
      inc(Location.X,W);
   end;
   ResetController;
end;

function TRasterFont.TextHeight(S : String) : integer;
begin
   TextHeight := CharHeight;
end;

function TRasterFont.TextWidth(S : String) : integer;
var
   W : integer;
   i : integer;
begin
   W := 0;
   for i := 1 to length(S) do
     if (byte(S[i]) >= FirstChar) and (byte(S[i]) < (FirstChar + CharCount)) then
     inc(W,GetCharWidth(S[i]));
   TextWidth := W;
end;

{ TFixedFont methods }

constructor TFixedFont.Init(AName : String; AImageTable : Pointer;
                            First,Count : byte;
                            AWidth,AHeight : word);
begin
   TRasterFont.Init(AName,AImageTable,First,Count);
   CharWidth := AWidth;
   CharHeight := AHeight;
end;

function TFixedFont.BytesPerChar(Ch : Char) : word; assembler;
asm
{   i := CharWidth div 8;
   if (CharWidth mod 8) <> 0 then inc(i);
   BytesPerChar := CharHeight * i;}
       mov     cl,3
       mov     bx,CharWidth
       mov     ax,bx
       shr     ax,cl
       test    bx,7
       je      @@1
       inc     ax
@@1:   mov     dx,CharHeight
       mul     dx
end;

function TFixedFont.GetCharWidth(Ch : Char) : word;
begin
   GetCharWidth := CharWidth;
end;

function TFixedFont.GetCharImage(Ch : Char) : Pointer;
var
   P : Pointer;
begin
   P := ImageTable;
   if P <> nil then begin
      if (byte(Ch) >= FirstChar) and (byte(Ch) <= (FirstChar + CharCount))
      then inc(LongInt(P),(byte(Ch) - FirstChar) * BytesPerChar(Ch));
   end;
   GetCharImage := P;
end;

{ TBiosFont Method }

constructor TBiosFont.Init(AName : String; AImageTable : Pointer;
                           AWidth,AHeight,ABytes : word);
begin
   TFixedFont.Init(AName,AImageTable,0,255,AWidth,AHeight);
   Bytes := ABytes;
end;

function TBiosFont.BytesPerChar(Ch : Char) : word;
begin
   BytesPerChar := Bytes;
end;

{ T8x8BiosFont - special case of TBiosFont }

constructor T8x8BiosFont.Init(AName : String; ABase,ATop : Pointer; ABytes : word);
begin
   TBiosFont.Init(AName,ABase,8,8,ABytes);
   Top := ATop;
end;

function T8x8BiosFont.GetCharImage(Ch : Char) : Pointer;
var
   SaveTablePtr : Pointer;
begin
   if byte(Ch) >= 128 then begin
      SaveTablePtr := ImageTable;
      ImageTable := Top;
      FirstChar := 128;
      CharCount := 127;
   end;
   GetCharImage := TBiosFont.GetCharImage(Ch);
   if byte(Ch) >= 128 then begin
      ImageTable := SaveTablePtr;
      FirstChar := 0;
      CharCount := 255;
   end;
end;

procedure InitFonts;
var
  FontCount,I : integer;
  Params : BiosFontParams;
begin
  Fonts := New(PCollection,Init(1,1));
  Fonts^.Insert(New(PDefaultBGIFont,Init('Default 8x8 font',0)));
  FontCount := GetMaxFont;
  if FontCount <= 0 then Exit;
  for I := 1 to FontCount do
  begin
     GetFontParams(i,Params);
     case Params.TwoPart of
        false : with Params do
           Fonts^.Insert(New(PBiosFont,Init(FontNames[i],ImageTable,Width,Height,BytesPerChar)));
        true : with Params do
           Fonts^.Insert(New(P8x8BiosFont,Init(FontNames[i],Base,Top,BytesPerChar)));
     end;
     if i = DefaultSysFont then SystemFont := Fonts^.Count-1;
  end;
end;

procedure DoneFonts;
begin
   if Fonts <> nil then Fonts^.Done;
end;

procedure SelectFont(Font : integer);
begin
   if (Font > 0) and (Font <= Fonts^.Count) then CurrentFont := Font;
{   else CurrentFont := 0;}
end;

function CanFillBackground : boolean;
begin
   CanFillBackground := PFont(Fonts^.At(CurrentFont))^.CanFillBackground;
end;

procedure SetTextStyle(Font,Direction : word; CharSize : word);
begin
   SelectFont(Font);
   PFont(Fonts^.At(CurrentFont))^.SetTextStyle(Direction,CharSize);
end;

procedure OutText(S : String);
begin
   PFont(Fonts^.At(CurrentFont))^.OutText(S);
end;

procedure OutTextXY(Location : TPoint; S : String);
begin
   PFont(Fonts^.At(CurrentFont))^.OutTextXY(Location,S);
end;

function TextHeight(S : String) : integer;
begin
   TextHeight := PFont(Fonts^.At(CurrentFont))^.TextHeight(S);
end;

function TextWidth(S : String) : integer;
begin
   TextWidth := PFont(Fonts^.At(CurrentFont))^.TextWidth(S);
end;

end.