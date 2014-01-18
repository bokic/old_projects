Unit VGraph;

Interface
const
	TopOn   	 = True;
	TopOff  	 = False;

	NormalPut = 0;
	CopyPut   = 0;
	XORPut    = 1;
	OrPut     = 2;
	AndPut    = 3;
	NotPut    = 4;

	ClipOn    = True;
	ClipOff   = False;

	Black     =   0;
	Blue      =   1;
	Green     =   2;
	Cyan      =   3;
	Red       =   4;
	Magenta   =   5;
	Brown     =   6;
	LightGray =   7;
	DarkGray  =    8;
	LightBlue =    9;
	LightGreen=   10;
	LightCyan =   11;
	LightRed  =   12;
	LightMagenta = 13;
	Yellow    =   14;
	White     =   15;

	EmptyFill      = 0;
	SolidFill      = 1;
	LineFill       = 2;
	LtSlashFill    = 3;
	SlashFill      = 4;
	BkSlashFill    = 5;
	LtBkSlashFill  = 6;
	HatchFill      = 7;
	XHatchFill     = 8;
	InterleaveFill = 9;
	WideDotFill    = 10;
	CloseDotFill   = 11;
	UserFill       = 12;

	LeftText       = 0;
	CenterText     = 1;
	RightText      = 2;
	BottomText     = 0;
	TopText        = 2;

	SolidLn   		= 0;
	DottedLn  		= 1;
	CenterLn  		= 2;
	DashedLn  		= 3;
	UserBitLn 		= 4;
	NormWidth  		= 1;
	ThickWidth 		= 3;

	DefaultFont    = 0;
	TriplexFont    = 1;
	SmallFont      = 2;
	SansSerifFont  = 3;
	GothicFont     = 4;
	HorizDir       = 0;
	VertDir        = 1;
	UserCharSize   = 0;


type

	ArcCoordsType = record
		X, Y,
		Xstart, Ystart,
		Xend, Yend : integer;
		end;
	FillPatternType = array [1..8] of Byte;
	FillSettingsType = record
		Pattern : Word;
		Color   : Word;
		end;
	LineSettingsType = record
		LineStyle : Word;
		Pattern   : Word;
		Thickness : Word;
		end;
	PaletteType = record
		Size    : Byte;
		Colors  : array[0..255] of Shortint;
		end;
	PointType = record
		X, Y : integer;
	end;
	TextSettingsType = record
		Font      : Word;
		Direction : Word;
		CharSize  : Word;
		Horiz     : Word;
		Vert      : Word;
	end;

	ViewPortType = record
		x1, y1, x2, y2 : integer;
		Clip           : Boolean;
	end;

procedure Arc (X,Y: Integer; StAngle, EndAngle, Radius: Word);
procedure Bar(x1, y1, x2, y2: Integer);
procedure Bar3D(x1, y1, x2, y2: Integer; Depth: Word; Top: Boolean);
procedure Circle(X,Y: Integer; Radius: Word);
procedure ClearDevice;
procedure ClearViewPort;
procedure CloseGraph;
procedure DetectGraph(var GraphDriver, GraphMode: Integer);
procedure DrawPoly(NumPoints: Word; var PolyPoints);
procedure Ellipse(X, Y: Integer; StAngle, EndAngle: Word; XRadius, YRadius:Word);
procedure FillEllipse(X, Y: Integer; XRadius, YRadius: Word);
procedure FillPoly(NumPoints: Word; var PolyPoints);
procedure FloodFill(X, Y: Integer; Border: Word);
procedure GetArcCoords(var ArcCoords: ArcCoordsType);
procedure GetAspectRatio(var Xasp, Yasp: Word);
function GetBkColor: Word;
function GetColor: Word;
procedure GetDefaultPalette(var Palette: PaletteType);
function GetDriverName: string;
procedure GetFillPattern(var FillPattern: FillPatternType);
procedure GetFillSettings(var FillInfo: FillSettingsType);
function GetGraphMode: Integer;
procedure GetImage(x1, y1, x2, y2: Integer; var BitMap);
procedure GetLineSettings(var LineInfo: LineSettingsType);
function GetMaxColor: Word;
function GetMaxMode: Integer;
function GetMaxX: Integer;
function GetMaxY: Integer;
function GetModeName(ModeNumber: Integer): string;
procedure GetModeRange(GraphDriver:Integer; var LoMode, HiMode:Integer);
procedure GetPalette(var Palette: PaletteType);
function GetPaletteSize: Integer;
function GetPixel(X,Y: Integer): Word;
procedure GetTextSettings(var TextInfo: TextSettingsType);
procedure GetViewSettings(var ViewPort: ViewPortType);
function GetX: Integer;
function GetY: Integer;
procedure GraphDefaults;
function GraphErrorMsg(ErrorCode: Integer): string;
function GraphResult: Integer;
function ImageSize(x1, y1, x2, y2: Integer): Word;
procedure InitGraph(var GraphDriver:Integer; var GraphMode: Integer;PathToDriver: string);
function InstallUserDriver(Name: string; AutoDetectPtr: pointer): integer;
function InstallUserFont(FontFileName: string ): Integer;
procedure Line(x1, y1, x2, y2: Integer);
procedure LineRel(Dx, Dy: Integer);
procedure LineTo(X, Y: Integer);
procedure MoveRel(Dx, Dy: Integer);
procedure MoveTo(X, Y: Integer);
procedure OutText(TextString: string);
procedure OutTextXY(X,Y: Integer; TextString: string);
procedure PieSlice(X, Y: Integer; StAngle, EndAngle, Radius: Word);
procedure PutImage(X, Y: Integer; var BitMap; BitBlt: Word);
procedure PutPixel(X, Y: Integer; Pixel: Word);
procedure Rectangle(x1, y1, x2, y2: Integer);
function RegisterBGIdriver(driver: pointer): Integer;
function RegisterBGIfont(Font: pointer): Integer;
procedure RestoreCrtMode;
procedure Sector(x, y: Integer; StAngle,EndAngle, XRadius, YRadius: Word);
procedure SetActivePage(Page: Word);
procedure SetAllPalette(var Palette);
function SetAspectRatio(Xasp, Yasp: Word): Word;
procedure SetBkColor(ColorNum: Word);
procedure SetColor(Color: Word);
procedure SetFillPattern(Pattern: FillPatternType; Color: Word);
procedure SetFillStyle(Pattern: Word; Color: Word);
procedure SetGraphBufSize(BufSize: Word);
procedure SetGraphMode(Mode: Integer);
procedure SetLineStyle(LineStyle: Word; Pattern: Word; Thickness: Word);
procedure SetPalette(ColorNum: Word; Color: Shortint);
procedure SetRGBPalette(ColorNum, RedValue, GreenValue, BlueValue:Integer);
procedure SetTextJustify(Horiz, Vert: Word);
procedure SetTextStyle(Font, Direction: Word; CharSize: Word);
procedure SetUserCharSize(MultX, DivX, MultY, DivY: Word);
procedure SetViewPort(x1, y1, x2, y2: Integer; Clip: Boolean);
procedure SetVisualPage(Page: Word);
procedure SetWriteMode(WriteMode: Integer);
function TextHeight(TextString: string): Word;
function TextWidth(TextString: string): Word;


Implementation   { Private symbols }
{label           { Labels }
{const           { Constants }
{type            { Types }
{var             { Variables }
procedure Arc (X,Y: Integer; StAngle, EndAngle, Radius: Word);
Begin
WriteLn('Not work');
End;
procedure Bar(x1, y1, x2, y2: Integer);
Begin
WriteLn('Not work');
End;
procedure Bar3D(x1, y1, x2, y2: Integer; Depth: Word; Top: Boolean);
Begin
WriteLn('Not work');
End;
procedure Circle(X,Y: Integer; Radius: Word);
Begin
WriteLn('Not work');
End;
procedure ClearDevice;
Begin
WriteLn('Not work');
End;
procedure ClearViewPort;
Begin
WriteLn('Not work');
End;
procedure CloseGraph;
Begin
WriteLn('Not work');
End;
procedure DetectGraph(var GraphDriver, GraphMode: Integer);
Begin
WriteLn('Not work');
End;
procedure DrawPoly(NumPoints: Word; var PolyPoints);
Begin
WriteLn('Not work');
End;
procedure Ellipse(X, Y: Integer; StAngle, EndAngle: Word; XRadius, YRadius:Word);
Begin
WriteLn('Not work');
End;
procedure FillEllipse(X, Y: Integer; XRadius, YRadius: Word);
Begin
WriteLn('Not work');
End;
procedure FillPoly(NumPoints: Word; var PolyPoints);
Begin
WriteLn('Not work');
End;
procedure FloodFill(X, Y: Integer; Border: Word);
Begin
WriteLn('Not work');
End;
procedure GetArcCoords(var ArcCoords: ArcCoordsType);
Begin
WriteLn('Not work');
End;
procedure GetAspectRatio(var Xasp, Yasp: Word);
Begin
WriteLn('Not work');
End;
function GetBkColor: Word;
Begin
WriteLn('Not work');
End;
function GetColor: Word;
Begin
WriteLn('Not work');
End;
procedure GetDefaultPalette(var Palette: PaletteType);
Begin
WriteLn('Not work');
End;
function GetDriverName: string;
Begin
WriteLn('Not work');
End;
procedure GetFillPattern(var FillPattern: FillPatternType);
Begin
WriteLn('Not work');
End;
procedure GetFillSettings(var FillInfo: FillSettingsType);
Begin
WriteLn('Not work');
End;
function GetGraphMode: Integer;
Begin
WriteLn('Not work');
End;
procedure GetImage(x1, y1, x2, y2: Integer; var BitMap);
Begin
WriteLn('Not work');
End;
procedure GetLineSettings(var LineInfo: LineSettingsType);
Begin
WriteLn('Not work');
End;
function GetMaxColor: Word;
Begin
WriteLn('Not work');
End;
function GetMaxMode: Integer;
Begin
WriteLn('Not work');
End;
function GetMaxX: Integer;
Begin
WriteLn('Not work');
End;
function GetMaxY: Integer;
Begin
WriteLn('Not work');
End;
function GetModeName(ModeNumber: Integer): string;
Begin
WriteLn('Not work');
End;
procedure GetModeRange(GraphDriver:Integer; var LoMode, HiMode:Integer);
Begin
WriteLn('Not work');
End;
procedure GetPalette(var Palette: PaletteType);
Begin
WriteLn('Not work');
End;
function GetPaletteSize: Integer;
Begin
WriteLn('Not work');
End;
function GetPixel(X,Y: Integer): Word;
Begin
WriteLn('Not work');
End;
procedure GetTextSettings(var TextInfo: TextSettingsType);
Begin
WriteLn('Not work');
End;
procedure GetViewSettings(var ViewPort: ViewPortType);
Begin
WriteLn('Not work');
End;
function GetX: Integer;
Begin
WriteLn('Not work');
End;
function GetY: Integer;
Begin
WriteLn('Not work');
End;
procedure GraphDefaults;
Begin
WriteLn('Not work');
End;
function GraphErrorMsg(ErrorCode: Integer): string;
Begin
WriteLn('Not work');
End;
function GraphResult: Integer;
Begin
WriteLn('Not work');
End;
function ImageSize(x1, y1, x2, y2: Integer): Word;
Begin
WriteLn('Not work');
End;
procedure InitGraph(var GraphDriver:Integer; var GraphMode: Integer;PathToDriver: string);
Begin
WriteLn('Not work');
End;
function InstallUserDriver(Name: string; AutoDetectPtr: pointer): integer;
Begin
WriteLn('Not work');
End;
function InstallUserFont(FontFileName: string ): Integer;
Begin
WriteLn('Not work');
End;
procedure Line(x1, y1, x2, y2: Integer);
Begin
WriteLn('Not work');
End;
procedure LineRel(Dx, Dy: Integer);
Begin
WriteLn('Not work');
End;
procedure LineTo(X, Y: Integer);
Begin
WriteLn('Not work');
End;
procedure MoveRel(Dx, Dy: Integer);
Begin
WriteLn('Not work');
End;
procedure MoveTo(X, Y: Integer);
Begin
WriteLn('Not work');
End;
procedure OutText(TextString: string);
Begin
WriteLn('Not work');
End;
procedure OutTextXY(X,Y: Integer; TextString: string);
Begin
WriteLn('Not work');
End;
procedure PieSlice(X, Y: Integer; StAngle, EndAngle, Radius: Word);
Begin
WriteLn('Not work');
End;
procedure PutImage(X, Y: Integer; var BitMap; BitBlt: Word);
Begin
WriteLn('Not work');
End;
procedure PutPixel(X, Y: Integer; Pixel: Word);
Begin
WriteLn('Not work');
End;
procedure Rectangle(x1, y1, x2, y2: Integer);
Begin
WriteLn('Not work');
End;
function RegisterBGIdriver(driver: pointer): Integer;
Begin
WriteLn('Not work');
End;
function RegisterBGIfont(Font: pointer): Integer;
Begin
WriteLn('Not work');
End;
procedure RestoreCrtMode;
Begin
WriteLn('Not work');
End;
procedure Sector(x, y: Integer; StAngle,EndAngle, XRadius, YRadius: Word);
Begin
WriteLn('Not work');
End;
procedure SetActivePage(Page: Word);
Begin
WriteLn('Not work');
End;
procedure SetAllPalette(var Palette);
Begin
WriteLn('Not work');
End;
function SetAspectRatio(Xasp, Yasp: Word): Word;
Begin
WriteLn('Not work');
End;
procedure SetBkColor(ColorNum: Word);
Begin
WriteLn('Not work');
End;
procedure SetColor(Color: Word);
Begin
WriteLn('Not work');
End;
procedure SetFillPattern(Pattern: FillPatternType; Color: Word);
Begin
WriteLn('Not work');
End;
procedure SetFillStyle(Pattern: Word; Color: Word);
Begin
WriteLn('Not work');
End;
procedure SetGraphBufSize(BufSize: Word);
Begin
WriteLn('Not work');
End;
procedure SetGraphMode(Mode: Integer);
Begin
WriteLn('Not work');
End;
procedure SetLineStyle(LineStyle: Word; Pattern: Word; Thickness: Word);
Begin
WriteLn('Not work');
End;
procedure SetPalette(ColorNum: Word; Color: Shortint);
Begin
WriteLn('Not work');
End;
procedure SetRGBPalette(ColorNum, RedValue, GreenValue, BlueValue:Integer);
Begin
WriteLn('Not work');
End;
procedure SetTextJustify(Horiz, Vert: Word);
Begin
WriteLn('Not work');
End;
procedure SetTextStyle(Font, Direction: Word; CharSize: Word);
Begin
WriteLn('Not work');
End;
procedure SetUserCharSize(MultX, DivX, MultY, DivY: Word);
Begin
WriteLn('Not work');
End;
procedure SetViewPort(x1, y1, x2, y2: Integer; Clip: Boolean);
Begin
WriteLn('Not work');
End;
procedure SetVisualPage(Page: Word);
Begin
WriteLn('Not work');
End;
procedure SetWriteMode(WriteMode: Integer);
Begin
WriteLn('Not work');
End;
function TextHeight(TextString: string): Word;
Begin
WriteLn('Not work');
End;
function TextWidth(TextString: string): Word;
Begin
WriteLn('Not work');
End;

end.