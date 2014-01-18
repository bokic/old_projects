{************************************************}
{   Images.pas                                   }
{   Graph Vision unit                            }
{   Sergey E. Levov, Moscow,1993-1994            }
{   Last changes: 7 August 1995                  }
{************************************************}
unit Images;
{$X+,G+,I-,S-,F+,O+,D+}

interface
Uses Objects, ExtObj, LowGraph;

type

{ BMP file header structure }

  PBitmapFileHeader = ^TBitmapFileHeader;
  TBitmapFileHeader = record
    bfType: Word;                         { file type. Must be 'BM' }
    bfSize: Longint;                      { file size }
    bfReserved1: Word;                    { reserved, alwais 0 }
    bfReserved2: Word;
    bfOffBits: Longint;                   { absolute offset to image start }
  end;

{ information about Windows 3.* DIB }

  PBitmapInfoHeader = ^TBitmapInfoHeader;
  TBitmapInfoHeader = record
    biSize: Longint;                      { = SizeOf(TBitmapInfoHeader) }
    biWidth: Longint;                     { bitmap width in pixels}
    biHeight: Longint;                    { bitmap height in scan lines }
    biPlanes: Word;                       { number of bit planes; must be 1 }
    biBitCount: Word;                     { bits per pixel; must be 1,4,8 or 24 }
    biCompression: Longint;               { compression type: 0-unpacked;
                                          { 1 - RLE8, 2 - RLE4}
    biSizeImage: Longint;                 { image size in bytes }
    biXPelsPerMeter: Longint;
    biYPelsPerMeter: Longint;
    biClrUsed: Longint;                   { Number of colors in color table }
    biClrImportant: Longint;
  end;

  TRGBQuad = record
    rgbBlue : Byte;
    rgbGreen : Byte;
    rgbRed : Byte;
    rgbReserved: Byte;
  end;

   TRGBTriple = record
      rgbtBlue: Byte;
      rgbtGreen: Byte;
      rgbtRed: Byte;
   end;

  PBitmapInfo = ^TBitmapInfo;
  TBitmapInfo = record
    Header: TBitmapInfoHeader;
    Colors: array[0..0] of TRGBQuad;   {record end;}
  end;

{ information about OS/2 PM DIBs }

  PBitmapCoreHeader = ^TBitmapCoreHeader;
  TBitmapCoreHeader = record
    bcSize: Longint;                      { = SizeOf(TBitmapCoreHeader) }
    bcWidth: Word;                        { bitmap width in pixels }
    bcHeight: Word;                       { bitmap height in scan lines }
    bcPlanes: Word;                       { number of bit planes; must be 1 }
    bcBitCount: Word;                     { bits per pixel; must be 1,4,8 or 24 }
  end;

  PBitmapCoreInfo = ^TBitmapCoreInfo;
  TBitmapCoreInfo = record
    bmciHeader: TBitmapCoreHeader;
    bmciColors: array[0..0] of TRGBTriple;    {record end;}
  end;

{ data structures for PCX files  }

   PPCXPaletteEntry = ^TPCXPaletteEntry;
   TPCXPaletteEntry = record
      rgbRed   : byte;
      rgbGreen : byte;
      rgbBlue  : byte;
   end;

   PPCXPalette = ^TPCXPalette;
   TPCXPalette = record
     Flag         : byte;                 { palette flag; if 0Ch - exists }
     Palette      : array[0..255] of TPCXPaletteEntry;
   end;

   PPCXHeader = ^TPCXHeader;
   TPCXHeader = record
     Manufacturer : byte;                 { always 0Ah }
     Version      : byte;
     Encoding     : byte;                 { 0 -no compression; 1- run length }
     BitsPixel    : byte;                 { bits per pixel in each bit plane }
     Xmin,Ymin    : integer;
     Xmax,Ymax    : integer;
     Hdpi,Vdpi    : integer;              { hor & vert device resolution }
     ColorMap     : array[0..15] of TPCXPaletteEntry; { color palette for 16-color images }
     Reserved     : byte;
     NPlanes      : byte;                 { number of color planes }
     BytesPerLine : word;                 { always even }
     PaletteInfo  : integer;              { additional palette info flag }
     HScreenSize  : word;
     VScreenSize  : word;
     Filler       : array[0..53] of byte;
   end;

   PFilter = ^TFilter;

   PImage = ^TImage;
   TImage = object(TObject)
      Size : TPoint;
      Data : PStream;
      constructor Init(ASize : TPoint);
      constructor Import(AName : FNameStr; AFilter : PFilter);
      constructor Load(var S : TStream);
      destructor Done; virtual;
      function GetBytesPerLine : integer;
      procedure GetLine(Line : integer; var Buffer);
      procedure PutLine(Line : Integer; var Buffer);
      procedure Draw(X,Y : integer; BitBlt : word);
      procedure Export(AName : FNameStr; AFilter : PFilter);
   private
      function InitStream : PStream;
   end;

   TFilter = object(TObject)
      Stream : PStream;
      ErrorCode : integer;
      constructor Load(var S : TStream);
      destructor Done; virtual;
      procedure Open(AName : FNameStr); virtual;
      procedure GetSize(var ASize : TPoint); virtual;
      procedure GetHeader; virtual;
      procedure LoadImage(AImage : PImage); virtual;
      procedure Save(AName : FNameStr; AImage : PImage); virtual;
      procedure SaveImage(AImage : PImage); virtual;
      procedure Store(var S : TStream);
   end;

   PBmpFilter = ^TBmpFilter;
   TBmpFilter = object(TFilter)
      Header : TBitmapInfoHeader;
      procedure Open(AName : FNameStr); virtual;
      procedure GetSize(var ASize : TPoint); virtual;
      procedure GetHeader; virtual;
      procedure LoadImage(AImage : PImage); virtual;
      procedure Save(AName : FNameStr; AImage : PImage); virtual;
      procedure SaveImage(AImage : PImage); virtual;
   end;

   PPCXFilter = ^TPCXFilter;
   TPCXFilter = object(TFilter)
      Header : TPCXHeader;
      procedure Open(AName : FNameStr); virtual;
      procedure GetSize(var ASize : TPoint); virtual;
      procedure GetHeader; virtual;
      procedure LoadImage(AImage : PImage); virtual;
      procedure Save(AName : FNameStr; AImage : PImage); virtual;
      procedure SaveImage(AImage : PImage); virtual;
   end;

   PBgiFilter = ^TBgiFilter;
   TBgiFilter = object(TFilter)
      Header : TPoint;
      procedure Open(AName : FNameStr); virtual;
      procedure GetSize(var ASize : TPoint); virtual;
      procedure GetHeader; virtual;
      procedure LoadImage(AImage : PImage); virtual;
      procedure Save(AName : FNameStr; AImage : PImage); virtual;
      procedure SaveImage(AImage : PImage); virtual;
   end;


procedure RegisterImages;

const

   giOk            =  0;
   giError         = -1;             {generic image import error}
   giIOError       = -2;             { IO error }
   giInvalidFormat = -3;             { invalid format }
   giNoLoadMem     = -4;

const

  RBmpFilter: TStreamRec = (
    ObjType: 80;
    VmtLink: Ofs(TypeOf(TBmpFilter)^);
    Load: @TBmpFilter.Load;
    Store: @TBmpFilter.Store);

  RBgiFilter: TStreamRec = (
    ObjType: 81;
    VmtLink: Ofs(TypeOf(TBgiFilter)^);
    Load: @TBgiFilter.Load;
    Store: @TBgiFilter.Store);

  RPCXFilter: TStreamRec = (
    ObjType: 82;
    VmtLink: Ofs(TypeOf(TPCXFilter)^);
    Load: @TPCXFilter.Load;
    Store: @TPCXFilter.Store);

  RImage : TStreamRec = (
    ObjType: 90;
    VmtLink: Ofs(TypeOf(TImage)^);
    Load: @TImage.Load;
    Store: nil);


implementation
uses Graph,Memory,GrDriver;

const
   TStream_Read = VMTHeaderSize + $14;
{   TImage_PutLine = VMTHeaderSize + $08;}

{ TImage methods }

constructor TImage.Init(ASize : TPoint);
begin
   TObject.Init;
   Size := ASize;
   Data := InitStream;
   if Data = nil then Fail;
end;

constructor TImage.Import(AName : FNameStr; AFilter : PFilter);
begin
   if AFilter = nil then begin
      Fail;
      Exit;
   end;
   TObject.Init;
   AFilter^.Open(AName);
   if AFilter^.ErrorCode <> giOK then begin
      Fail;
      Exit;
   end;
   AFilter^.GetSize(Size);
   Data := InitStream;
   if Data <> nil then AFilter^.LoadImage(@Self)
   else begin
     AFilter^.ErrorCode := giNoLoadMem;
     Fail;
   end;
end;

constructor TImage.Load(var S : TStream);
var
   Filter : PFilter;
begin
   TObject.Init;
   Filter := PFilter(S.Get);
   if Filter=nil then begin
      Fail;
      Exit;
   end;
   Filter^.Stream := @S;
   Filter^.GetHeader;
   Filter^.GetSize(Size);
   Data := InitStream;
   if Data <> nil then Filter^.LoadImage(@Self)
   else Fail;
   Filter^.Stream := nil;
   Dispose(Filter,Done);
end;


procedure TImage.Export(AName : FNameStr; AFilter : PFilter);
begin
   if AFilter = nil then Exit;
   AFilter^.Save(AName,@Self);
end;

destructor TImage.Done;
begin
   if Data <> nil then Dispose(PStream(Data),Done);
   TObject.Done;
end;

function TImage.GetBytesPerLine : integer;
var
   T,B : integer;
begin
   T := Size.X * BitPerPlane;
   B := T shr 3;
   if (T and 7) <> 0 then inc(B);
   GetBytesPerLine := B * Planes;
end;


function TImage.InitStream : PStream;
var
   S : PStream;
   m : LongInt;
begin
{$IFDEF DPMI}
	S := New(PMemoryStream,Init(LongInt(Size.X) * Size.Y,1024));
{$ELSE}
	M := LongInt(Size.X) * Size.Y;

   if M > $FFF0 then begin
      S := New(PXMSStream,Init(M));
      if S = nil then S := New(PEmsStream,Init(M,M));
   end else S := New(PMemoryStream,Init(M,1024));
{$ENDIF}
   if S <> nil then begin
      if S^.Status <> stOK then begin
         Dispose(S,Done);
         S := nil;
      end;
   end;
   InitStream := S;
end;

procedure TImage.GetLine(Line : integer; var Buffer);
var
   NewPos : LongInt;
   Bytes : integer;
begin
NewPos := LongInt(Line) * Size.X;
with PStream(Data)^ do
	begin
	if (GetPos <> NewPos) then
		Seek(NewPos);
	Read(Buffer,Size.X);
	end;
end;

procedure TImage.PutLine(Line : integer; var Buffer);
var
   NewPos : LongInt;
   Bytes : integer;
begin
NewPos := LongInt(Line) * Size.X;
with PStream(Data)^ do
	begin
	if (GetPos <> NewPos) then
		Seek(NewPos);
	Write(Buffer,Size.X);
	end;
end;

procedure TImage.Draw(X,Y : integer; BitBlt : word);
var
   i,j : integer;
   Buf : pointer;
   RB : PByteArray;
   Temp : PByteArray;
   B,Lines : integer;
   BS,K : word;
   X1,Y1,X2,Y2 : integer;
   Nx1,Ny1,Nx2,Ny2 : integer;
   NeedClip : boolean;
begin
   GetViewSettings(ViewPort);
	with ViewPort do
		begin
		inc(X,X1);
		inc(Y,Y1);
		if (not Clip) then
			begin
			X1 := 0;
			Y1 := 0;
			X2 := ScreenWidth - 1;
			Y2 := ScreenHeight - 1;
			end;
		end;
	if (MaxAvail > $20000) then
		BS := $FFF0
		else
		BS := word(MaxAvail) shr 1;
	X1 := X;
	Y1 := Y;
	X2 := X + Size.X - 1;
	Y2 := Y + Size.Y - 1;
	Nx1 := X1;
	Ny1 := Y1;
	NX2 := X2;
   Ny2 := Y2;
	with ViewPort do
		begin
		if (Ny2 > Y2) then Ny2 := Y2;
		if (Ny1 < Y1) then Ny1 := Y1;
		end;
   Lines :=  Ny2 - Ny1 + 1;     { how many lines should be drawn }
	if (Lines = 0) then Exit;
	i := Ny1 - Y1;               { first drawing line number }
   NeedClip := false;
		if (Nx2 > ViewPort.X2) then
			begin
			Nx2 := ViewPort.X2;
			NeedClip := true;
			end;
		if (Nx1 < ViewPort.X1) then
			begin
			Nx1 := ViewPort.X1;
			NeedClip := true;
			end;
	B := (Nx2-Nx1+1)*BitPerPlane;     { bytes for one line }
	J := B shr 3;
	if ((B and 7) <> 0) then inc(J);
	B := J * Planes;
	K := (BS - 6) div B;             { how many lines we can put into buffer }
	if (K = 0) then Exit;            { can't allocate buffer - exit }
	if (K > Lines) then K := Lines;

   BS := K * word(B) + 6;              { alloc memory for K lines + 3 words }
   GetMem(Buf,BS);
   LongInt(RB) := LongInt(Buf)+4;
   GetMem(Temp,word(Size.X));
   repeat
      if Lines < K then K := Lines;
      dec(Lines,K);
      LongRec(Buf^).Lo := Nx2-Nx1;    { set up header }
      LongRec(Buf^).Hi := K-1;
		for j := 0 to K-1 do
			begin
			GetLine(i,Temp^);
			inc(i);
			if (NeedClip) then
				ConvertPixRow(Temp^[Nx1-X1],RB^[j*B],Nx2-Nx1+1)
			else
				ConvertPixRow(Temp^,RB^[j*B],Size.X);
		end;
		with ViewPort do
			PutImage(NX1-X1,NY1-Y1,Buf^,BitBlt);
      inc(NY1,K);
	until (Lines=0);
	FreeMem(Buf,BS);               { free memory }
   FreeMem(Temp,Size.X);
end;


{ TFilter methods }
constructor TFilter.Load(var S : TStream);
begin
   TObject.Init;
end;

destructor TFilter.Done;
begin
   if Stream <> nil then begin
      Dispose(Stream,Done);
      Stream := nil;
   end;
   TObject.Done;
end;

procedure TFilter.Open(AName : FNameStr);
begin
   Abstract;
end;

procedure TFilter.GetHeader;
begin
   Abstract;
end;

procedure TFilter.GetSize(var ASize : TPoint);
begin
   Abstract;
end;

procedure TFilter.LoadImage(AImage : PImage);
begin
   Abstract;
end;

procedure TFilter.Save(AName : FNameStr; AImage : PImage);
begin
   Abstract;
end;

procedure TFilter.SaveImage(AImage : PImage);
begin
   Abstract;
end;

procedure TFilter.Store(var S : TStream);
begin
end;


{ TBgiFilter methods }

procedure TBGIFilter.Open(AName : FNameStr);
begin
   ErrorCode := giOk;
   Stream := New(PDosStream,Init(AName,stOpenRead));
   if Stream <> nil then begin
      if Stream^.Status <> stOK then begin
         Dispose(Stream,Done);
         ErrorCode := giIOError;
         Exit;
      end;
      GetHeader;
   end;
end;

procedure TBGIFilter.GetHeader;
begin
   Stream^.Read(Header,SizeOf(TPoint));
end;

procedure TBgiFilter.GetSize(var ASize : TPoint);
begin
   with Header do begin
      ASize.X := X + 1;
      ASize.Y := Y + 1;
   end;
end;

procedure TBGIFilter.LoadImage(AImage : PImage);
var
   IS,I : word;
   D : pointer;
begin
   if AImage <> nil then begin
      IS := AImage^.GetBytesPerLine;
      D := MemAlloc(IS);
      for I := 0 to Header.Y do begin
         Stream^.Read(PByteArray(D)^,IS);
         AImage^.PutLine(I,D^);
      end;
      Stream^.Read(i,SizeOf(integer));
   end else ErrorCode := giError;
end;

procedure TBGIFilter.Save(AName : FNameStr; AImage : PImage);
begin
   Stream := New(PDosStream,Init(AName,stCreate));
   if Stream <> nil then begin
      if Stream^.Status <> stOK then begin
         Dispose(Stream,Done);
         ErrorCode := giIOError;
         Exit;
      end;
      SaveImage(AImage);
      Dispose(Stream,Done);
   end else ErrorCode := giIOError;
end;

procedure TBGIFilter.SaveImage(AImage : PImage);
var
   A : LongRec;
   LS,i : integer;
   D : pointer;
begin
   A.Lo := AImage^.Size.X-1;
   A.Hi := AImage^.Size.Y-1;
   Stream^.Write(A,SizeOf(LongInt));
   LS := AImage^.GetBytesPerLine;
   D := MemAlloc(LS);
   for i := 0 to A.Hi do begin
      AImage^.GetLine(i,D^);
      Stream^.Write(D^,LS);
   end;
   FreeMem(D,LS);
   Stream^.Write(LS,SizeOf(Integer));
end;


{ TBMPFilter methods }

procedure TBmpFilter.Open(AName : FNameStr);
var
   FileHeader : TBitmapFileHeader;
begin
   Stream := New(PDosStream,Init(AName,stOpenRead));
   if Stream <> nil then begin
      if Stream^.Status <> stOK then begin
         Dispose(Stream,Done);
         ErrorCode := giIOError;
         Exit;
      end;
      Stream^.Read(FileHeader,SizeOf(TBitmapFileHeader));
      with FileHeader do
      if (bfType <> $4D42) or (bfSize <= bfOffBits) then begin
         Dispose(Stream,Done);
         ErrorCode := giInvalidFormat;
         Exit;
      end;
      GetHeader;
   end;
end;

procedure TBmpFilter.GetHeader;
var
   CurPos : LongInt;
   Bits : word;
   Os2Header : TBitmapCoreHeader absolute Header;
begin
   CurPos := Stream^.GetPos;
   Stream^.Read(Header,SizeOf(TBitmapInfoHeader));
   if Header.biSize = SizeOf(TBitmapInfoHeader) then begin
      inc(CurPos,Header.biSize);
      Bits := Header.biBitCount;
   end else begin
      inc(CurPos,Os2Header.bcSize);
      Bits := Os2Header.bcBitCount;
   end;
   Stream^.Seek(CurPos);
   if Bits > Planes * BitPerPlane then begin
      Dispose(Stream,Done);
      ErrorCode := giError;
   end;
end;

procedure TBmpFilter.GetSize(var ASize : TPoint);
var
   Os2Header : TBitmapCoreHeader absolute Header;
begin
   if Header.biSize = SizeOf(TBitmapInfoHeader) then begin
      ASize.X := integer(Header.biWidth);
      ASize.Y := integer(Header.biHeight);
   end else begin
      ASize.X := integer(Os2Header.bcWidth);
      ASize.Y := integer(Os2Header.bcHeight);
   end;
end;


procedure TBmpFilter.LoadImage(AImage : PImage);
var
   Os2Header : TBitmapCoreHeader absolute Header;
   WindowsBMP : boolean;
   Compressed : boolean;
   CurPos,ImageSize : LongInt;
   Colrs,Bits,T,I : word;
   BmpBufSize : word;
   PixelsPerByte : word;
   ImgBuf : pointer;
   BmpBuf : pointer;
   TransmitBuf : pointer;
   ExtraBytes,SkipBytes : word;
   OldDS,BufCount : word;
   Width,Lines : word;
   Palette : TPaletteType;
   PalEntry : TRGBQuad;
   Image : PImage;
   Siz : TPoint;
   S : PStream;
begin
   if LowMemory then begin
      ErrorCode := giNoLoadMem;
      Exit;
   end;
   GetSize(Siz);
   S := Stream;
   CurPos := S^.GetPos;
   WindowsBMP := Header.biSize = SizeOf(TBitmapInfoHeader);
   if WindowsBMP then
   begin   { processing Windows-style bitmap }
      Bits := Header.biBitCount;
      PixelsPerByte := 8 div Bits;
      Compressed := Header.biCompression <> 0;
      ImageSize := Header.biSizeImage;
      if not Compressed and (ImageSize = 0) then
         ImageSize := (LongInt(Siz.X)+ integer((Siz.X and 1) <> 0)) * Siz.Y div PixelsPerByte;
   end
   else begin { otherwise OS/2-style bitmap }
      Bits := Os2Header.bcBitCount;
      PixelsPerByte := 8 div Bits;
      ImageSize := (LongInt(Siz.X)+ integer((Siz.X and 1) <> 0)) * Siz.Y div PixelsPerByte;
      Compressed := false;
   end;
   { define number of palette entries }
   Colrs := 1 shl Bits;
   T := Colrs;
   if WindowsBMP then begin
      with Header do
      if biClrUsed <> 0 then T := word(biClrUsed);
      for i := 0 to T-1 do begin
         S^.Read(PalEntry,SizeOf(TRGBQuad));
         with PalEntry do
         Palette.Colors[i] := GetNearestColor(Colrs,rgbRed,rgbGreen,rgbBlue);
      end;
      inc(CurPos,T * SizeOf(TRGBQuad));
   end else begin
      for i := 0 to T-1 do begin
         S^.Read(PalEntry,SizeOf(TRGBTriple));
         with PalEntry do
         Palette.Colors[i] := GetNearestColor(Colrs,rgbRed,rgbGreen,rgbBlue);
      end;
      inc(CurPos, T * SizeOf(TRGBTriple));
   end;
   Palette.Size := T;
   if ImageSize = 0 then ImageSize := S^.GetSize - CurPos;
   S^.Seek(CurPos);
{   ImgBuf := MemAlloc(AImage^.GetBytesPerLine);}
   TransmitBuf := MemAlloc(word(Siz.X));
   if MaxAvail >= 64 * 1024 then BmpBufSize := 63 * 1024
   else BmpBufSize := word(MaxAvail);
   if LongInt(BMPBufSize) > ImageSize then BmpBufSize := word(ImageSize);
   GetMem(BMPBuf,BmpBufSize);
   Width := Siz.X;
   Lines := Siz.Y;
   asm
         cmp    byte ptr Compressed,true
         jne    @@0
         jmp    @@12
{ process uncompressed bitmap }
@@0:     mov    ax,Width
         mul    Bits
         mov    bx,ax
         shr    ax,3
         test   bx,7
         je     @@1
         inc    ax
@@1:     mov    dx,ax
         shr    ax,2
         test   dx,3
         je     @@2
         inc    ax
@@2:     shl    ax,2
         sub    ax,dx
         mov    ExtraBytes,ax           { calculate extra bytes }
         mov    al,byte ptr Bits
         mov    ah,byte ptr PixelsPerByte
         mov    T,ax
{ processing bitmap image }
         xor    ax,ax
         mov    BufCount,ax             { force to read part of image into buf }
         mov    SkipBytes,ax
         mov    OldDS,ds                { save current DS }
{ processing current line }
@@4:     dec    Lines                      { actual line number }
         mov    bx,Width
         lds    si,TransmitBuf
@@5:     call   @@GetByte
         mov    cx,T
{ processing pixels stored in current byte }
@@7:     {xor    ah,ah}
         shl    ah,8
         shl    ax,cl
         mov    ds:[si],ah
         inc    si
         dec    bx                      { all done with current line? }
         jz     @@8                     { yes }
         dec    ch                      { all done with current byte? }
         jnz    @@7                     { no - repeat }
         jmp    @@5                     { yes - get next byte }
{ skip extra bytes if any }
@@8:     mov    cx,ExtraBytes
         or     cx,cx
         je     @@10
         sub    BufCount,cx
         jc     @@9
         add    di,cx
         mov    SkipBytes,0
         jmp    @@10
@@9:     neg    BufCount
         mov    ax,BufCount
         mov    SkipBytes,ax
         mov    BufCount,0
@@10:
         call   @@PutLine
         cmp    Lines,0                { all done? }
         je     @@11                   { yes }
         jmp    @@4                    { go to process next bitmap line }
@@11:    jmp    @@exit

@@GetByte:
         cmp    BufCount,0              { all done with current buffer? }
         ja     @@6                     { no }
         push   bx
         push   ds                      { preserve ds and si }
         push   si
         mov    ds,OldDS
         les    di,BmpBuf               { pointer to input buffer }
         push   es                      { place onto stack as 1st param }
         push   di
         mov    ax,BmpBufSize
         cmp    ImageSize.word[2],0
         jne    @@5_1
         cmp    ImageSize.word[0],ax
         jae    @@5_1
         mov    ax,ImageSize.word[0]
@@5_1:   sub    ImageSize.word[0],ax
         sbb    ImageSize.word[2],0
         push   ax                      { count as 2nd parameter}
         sub    ax,SkipBytes
         mov    BufCount,ax
         les    di,S                    { SELF param for stream }
         push   es
         push   di
         mov    di,es:[di]              { call stream' Read method }
         call   dword ptr [di].TStream_Read
         les    di,BmpBuf
         add    di,SkipBytes
         pop    si
         pop    ds
         pop    bx
@@6:     mov    al,es:[di]              { load byte }
         inc    di
         dec    BufCount
         retn

@@PutLine:
         mov    ds,OldDS
         push   es                      { preserve pointer to current buf }
         push   di
{ convert pixels string our palette }
         les    di,TransmitBuf
         push   es                      { ptr to source buf as 1st param }
         push   di
{         les    di,ImgBuf}
         push   es                      { ptr to dest buffer as 2nd param }
         push   di
         push   Width                   { image width }
         lea    di,Palette
         push   ss
         push   di
{         call   ConvertPixRow}
         call    TranslatePalette
{ place row into image }
         push    Lines                  { current line number as 1st param }
{         push    ImgBuf.word[2]
         push    ImgBuf.word[0]}
         push    TransmitBuf.word[2]
         push    TransmitBuf.word[0]
         les     di,AImage
         push    es
         push    di
         call    TImage.PutLine
{ restorte actual values }
         pop     di                     { restore pointer in bitmap buf }
         pop     es
         retn

{ compressed bitmap }
@@12:    mov    al,byte ptr Bits
         mov    ah,byte ptr PixelsPerByte
         mov    T,ax
{ processing bitmap image }
         xor    ax,ax
         mov    BufCount,ax             { force to read part of image into buf }
         mov    SkipBytes,ax
         mov    OldDS,ds                { save current DS }
@@13:    dec    Lines
         jns    @@13_1
         jmp    @@exit
@@13_1:
         lds    si,TransmitBuf
@@14:    call   @@GetByte
         or     al,al
         jz     @@15                    { escape or absolute mode }
{ encoded mode }
         mov    bx,ax                   { repeat count }
         call   @@GetByte               { get pixel(s) value }
         mov    dl,al
         mov    cx,T
@@14_1:  {xor    ah,ah}
         shl    ah,8
         shl    ax,cl
         mov    ds:[si],ah
         inc    si
         dec    bl
         jz     @@14
         dec    ch
         jnz    @@14_1
         mov    al,dl
         mov    cx,T
         jmp    @@14_1

@@15:    call   @@GetByte
         cmp    al,2
         ja     @@17
{ escape sequence }
@@16:    or     al,al                   { end of line? }
         jnz    @@16_1
         call   @@PutLine
         jmp    @@13
@@16_1:  cmp    al,1                    { end of bitmap? }
         jne    @@16_2
         mov    ds,OldDS
         jmp    @@exit
@@16_2:  { move current position (???) }
         { don't know how process it. Just skip two bytes }
         call   @@GetByte
         call   @@GetByte
         jmp    @@14
{ absolute mode }
@@17:    mov    bx,ax
         mov    cx,T
@@17_1:  call   @@GetByte
@@17_2:  shl    ah,8
         shl    ax,cl
         mov    ds:[si],ah
         inc    si
         dec    bl
         jnz    @@17_4
         test   di,1
         jz     @@17_3
         call   @@GetByte
@@17_3:  jmp    @@14
@@17_4:  dec    ch
         jnz    @@17_2
         mov    cx,T
         jmp    @@17_1
@@exit:
   end;

   { dispose all used buffers }
   FreeMem(BmpBuf,BmpBufSize);
   FreeMem(TransmitBuf,word(Siz.X));
{   FreeMem(ImgBuf,AImage^.GetBytesPerLine);}
end;

procedure TBMPFilter.Save(AName : FNameStr; AImage : PImage);
begin
end;

procedure TBmpFilter.SaveImage(AImage : PImage);
begin
end;

{ TPCXFilter methods }

procedure TPCXFilter.Open(AName : FNameStr);
begin
   Stream := New(PDosStream,Init(AName,stOpenRead));
   if Stream <> nil then begin
      if Stream^.Status <> stOK then begin
         Dispose(Stream,Done);
         ErrorCode := giIOError;
         Exit;
      end;
      GetHeader;
   end;
end;

procedure TPCXFilter.GetHeader;
var
   CurPos : LongInt;
begin
   CurPos := Stream^.GetPos;
   Stream^.Read(Header,SizeOf(TPCXHeader));
   if (Header.Manufacturer <> $0A) { or (Header.Version <> 5)} or
      (Header.BitsPixel > BitPerPlane) then ErrorCode := giInvalidFormat;
end;

procedure TPCXFilter.GetSize(var ASize : TPoint);
begin
   with Header do begin
      ASize.X := XMax - XMin + 1;
      ASize.Y := YMax - YMin + 1;
   end;
end;

procedure TPCXFilter.LoadImage(AImage : PImage);
var
   Compressed : boolean;
   CurPos,ImageSize : LongInt;
   Colrs,Bits,T,I : word;
   PcxBufSize : word;
   PixelsPerByte : word;
   ImgBuf : pointer;
   PcxBuf : pointer;
   TransmitBuf : pointer;
   OldDS,BufCount,Count : word;
   Width,HPlanes,Lines,BPLine : word;
   Palette : TPaletteType;
   PalEntry : TPCXPaletteEntry;
   Image : PImage;
   Siz : TPoint;
   S : PStream;
begin
   if ErrorCode <> giOK then Exit;
   if LowMemory then begin
      ErrorCode := giNoLoadMem;
      Exit;
   end;
   GetSize(Siz);
   S := Stream;
   Bits := Header.BitsPixel;
   HPlanes := Header.NPlanes;
   PixelsPerByte := 8 div Bits;
   Colrs := 1 shl (Bits * HPlanes);
   Compressed := boolean(Header.Encoding);
{   ImageSize := LongInt(Header.Filler[0]);}
   CurPos := S^.GetPos;
{   if ImageSize = 0 then begin}
      ImageSize := S^.GetSize - CurPos;
{   end;}
   if PixelsPerByte = 1 then begin    { 256 colors - process additional palette}
      S^.Seek(S^.GetSize - SizeOf(TPCXPalette) + 1);
      {if LongInt(Header.Filler[0]) = 0 then} dec(ImageSize,SizeOf(TPCXPalette));
      for i := 0 to Colrs-1 do begin
         S^.Read(PalEntry,SizeOf(TPCXPaletteEntry));
         with PalEntry do
         Palette.Colors[i] := GetNearestColor(Colrs,rgbRed,rgbGreen,rgbBlue);
      end;
   end else begin   { process palette from header }
      for i := 0 to Colrs - 1 do begin
         with Header.ColorMap[i] do
         Palette.Colors[i] := GetNearestColor(Colrs,rgbRed,rgbGreen,rgbBlue);
      end;
   end;
   Palette.Size := Colrs;
   S^.Seek(CurPos);
{   BPLine := AImage^.GetBytesPerLine div Planes;}
   BPLine := Siz.X div PixelsPerByte;
   if (Siz.X mod PixelsPerByte) <> 0 then inc(BPLine);
   ImgBuf := MemAlloc(AImage^.GetBytesPerLine);
   TransmitBuf := MemAlloc(word(Siz.X));
   if MaxAvail >= 64 * 1024 then PcxBufSize := 63 * 1024
   else PcxBufSize := word(MaxAvail);
   if LongInt(PcxBufSize) > ImageSize then PcxBufSize := word(ImageSize);
   GetMem(PcxBuf,PcxBufSize);
   Width := Siz.X;
   Lines := Siz.Y;
   Count := 0;
   asm
         xor    ax, ax
         mov    BufCount,ax             { force to read part of image into buffer}
         mov    cx,ax
         mov    OldDS,ds
         cmp    byte ptr Compressed,true
         je     @@4
{ process uncompressed pcx }
@@0:     mov    cx,HPlanes               { planes count }
         cmp    PixelsPerByte,1
         jne    @@0_1
         les    di,TransmitBuf
         jmp    @@0_2
@@0_1:   les    di,ImgBuf
@@0_2:   push   cx
         mov    cx, BPLine
@@1:     call   @@GetByte               { get current byte }
         stosb                          { and store it into buffer }
         loop   @@1
         test   BPLine,1                { is even? }
         je     @@1_1                   { yes }
         call   @@GetByte               { no - skip one byte }
@@1_1:   pop    cx
         loop   @@0_2                   { load next bit plane }
         call   @@PutData
         inc    Count
         mov    cx,Count
         cmp    cx,Lines
         jl     @@0                     { go to process next line }
         jmp    @@exit

@@GetByte:
         cmp    BufCount,0              { all done with current buffer? }
         ja     @@8                     { no }
         push   bx
         push   es                      { preserve es and di }
         push   di
         mov    ds,OldDS
         les    di,PcxBuf               { pointer to input buffer }
         push   es                      { place onto stack as 1st param }
         push   di
         mov    ax,PcxBufSize
         cmp    ImageSize.word[2],0
         jne    @@7
         cmp    ImageSize.word[0],ax
         jae    @@7
         mov    ax,ImageSize.word[0]
@@7:     sub    ImageSize.word[0],ax
         sbb    ImageSize.word[2],0
         push   ax                      { count as 2nd parameter}
         mov    BufCount,ax
         les    di,S                    { SELF param for stream }
         push   es
         push   di
         mov    di,es:[di]              { call stream' Read method }
         call   dword ptr [di].TStream_Read
         lds    si,PcxBuf
         pop    di
         pop    es
         pop    bx
@@8:     lodsb
         dec    BufCount
         retn

@@PutData:
         push   ds                 { save current pointer for file buffer}
         push   si
         mov    ds,OldDS
         cmp    PixelsPerByte,1
         je     @@3
{ convert to device independent format }
         les    di,ImgBuf
         push   es
         push   di
         les    di,TransmitBuf
         push   es
         push   di
         push   Width
         push   PixelsPerByte
         push   HPlanes
         call   ConvertToDib
(*         lds    si,TransmitBuf
         mov    cx,BPLine
@@2:     push   cx
         xor    bx,bx
         mov    al,es:[di]
         add    bx,BPLine
         mov    ah,es:[di+bx]
         add    bx,BPLine
         mov    dl,es:[di+bx]
         add    bx,BPLine
         mov    dh,es:[di+bx]
         mov    cx,PixelsPerByte
@@2_1:   xor    bx,bx
         rcl    dh,1
         rcl    bl,1
         rcl    dl,1
         rcl    bl,1
         rcl    ah,1
         rcl    bl,1
         rcl    al,1
         rcl    bl,1
         mov    ds:[si],bl
         inc    si
         loop   @@2_1
         pop    cx
         inc    di
         loop   @@2          *)

@@3:
{ convert pixels string to our palette }
         les    di,TransmitBuf
         push   es                      { ptr to source buf as 1st param }
         push   di
{         les    di,ImgBuf}
         push   es                      { ptr to dest buffer as 2nd param }
         push   di
         push   Width                   { image width }
         lea    di,Palette
         push   ss
         push   di
{         call   ConvertPixRow}
         call   TranslatePalette
{ place row into image }
         push    Count                  { current line number as 1st param }
{         push    ImgBuf.word[2]
         push    ImgBuf.word[0]}
         push    TransmitBuf.word[2]
         push    TransmitBuf.word[0]
         les     di,AImage
         push    es
         push    di
         call    TImage.PutLine
{ restorte actual values }
         pop     si                     { restore pointer in bitmap buf }
         pop     ds
         retn

{ run-length encoded image }
@@4:     mov    dx,HPlanes      {dx}        { planes count }
         cmp    PixelsPerByte,1
         jne    @@4_1
         les    di,TransmitBuf
         jmp    @@4_2
@@4_1:   les    di,ImgBuf

@@4_2:   push   dx                      { save bit plane count }
         mov    bx,BPLine
         or     cx,cx
         jne    @@5_0
@@4_3:   call   @@GetByte
         mov    ah,al
         and    ah,$C0
         cmp    ah,$C0                  { count byte? }
         je     @@5                     { yes }
         stosb                          { no - store single byte }
         dec    bx
         jmp    @@6
@@5:     and    al,$3F
         xor    ch,ch
         mov    cl,al                   { count }
         call   @@GetByte               { get data byte }
@@5_0:   cmp    bx,cx
         jge    @@5_2
         xchg   bx,cx
         sub    bx,cx
         rep    stosb
         xchg   bx,cx
         pop    dx
         dec    dx
         jz     @@5_1
         push   dx
         mov    bx,BPLine
         jmp    @@5_0
@@5_1:   push   ax
         push   cx
         call   @@PutData
         pop    cx
         pop    ax
         jmp    @@6_2
@@5_2:   sub    bx,cx
         rep    stosb
@@6:     jnz    @@4_3
         pop    dx
         dec    dx
         jnz    @@4_2

@@6_1:   call   @@PutData
         xor    cx,cx
@@6_2:   inc    Count
         mov    dx,Count
         cmp    dx,Lines
         jge    @@exit
         jmp    @@4
@@exit:  mov    ds,OldDS
   end;
   { dispose all used buffers }
   FreeMem(PcxBuf,PcxBufSize);
   FreeMem(TransmitBuf,word(Siz.X));
   FreeMem(ImgBuf,AImage^.GetBytesPerLine);
end;

procedure TPCXFilter.Save(AName : FNameStr; AImage : PImage);
begin
end;

procedure TPCXFilter.SaveImage(AImage : PImage);
begin
end;

procedure RegisterImages;
begin
  RegisterType(RBmpFilter);
  RegisterType(RBgiFilter);
  RegisterType(RPCXFilter);
  RegisterType(RImage);
end;

end.
