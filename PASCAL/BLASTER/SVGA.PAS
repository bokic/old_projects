{$G+}
Unit SVGA;

Interface

Type
  RGB = Record
        Red, Grn, Blu : byte
        End;
  PaletteRegister = Array[0..255] of RGB;
  SetTypes = ( FutureFont, StandardFont );
  ResType = ( VGA, SVGA6440, SVGA6448, SVGA8060, SVGA1076 );
  YPtr = ^YType;
  YType = Record
            Col1, Col2, Col3, Col4 : byte; { Due to TP's memory }
            NextY : YPtr;                  { memory management }
          End;                             { pointers are multiples}
   XPtr = ^XType;                           { of 8 bytes }
   XType = Record
				 NextX : XPtr;
             Y : YPtr;
			  End;

Procedure SetMode( Mode : Restype );
Function WhichBank( x, y : word ): byte;
Procedure LoadWriteBank( Segment : byte );
Procedure Plot( x, y : integer; Color : byte );
Procedure PutImage( x, y : integer; Img : XPtr );{ Puts an image in memory to screen at point (x,y), top left hand corner }
Procedure LoadImage( ImageName : string; var ImagePtr : XPtr );{ Loads image from disk and puts into memory }
Procedure DisposeImage( var Img : XPtr );{ Deletes image from memory }
Procedure SetColor( PalNum: byte; Hue : RGB );{ Sets Color of a particular pallette }
Function  GetPixel( x, y : integer ) : byte; { Returns color of a pixel }
Procedure SetPalette( Hue : PaletteRegister );{ Sets all 256 pallette registers to desired pallette }
Procedure CyclePalette;{ Rotates all colors in the pallette in repetitive cycle }
Procedure Circle( x, y, Radius : word; Color : byte );
Procedure Line( xx1, yy1, xx2, yy2 : integer; Color : byte );
Procedure ClearDevice;
Procedure ClearPort( x1, y1, x2, y2 : integer );{ Clears a Section of the screen }
Procedure Rectangle( x1, y1, x2, y2 : word; Color : byte );
Procedure RectFill( x1, y1, x2, y2 : integer; Color : byte );{ Draws a solid Rectangle }
Procedure ExitGraphics;{ Exits SVGA Graphics and returns to normal text mode }
Procedure OutTextXY( x, y : integer; word : string );
Procedure LoadFont( CharSetName: SetTypes );{ Loads a particular Font for use }
Procedure SetFont( Font : SetTypes );{ If two or more fonts are in memory this allows you to choose one }
Procedure SetFontColor( Color, BackCol : byte; Trans : boolean );
Procedure LoadPalette( PaletteName : string );{ Loads a particular pallette from disk }
Procedure WaitSync;

var  Color : PaletteRegister;
	  Bytes_per_Line, GetMaxX, GetMaxY : integer;
	  PresentSeg : byte;

Implementation

Uses Dos;

Type  FCharType = Array[ 0..15, 0..12 ] of boolean;
      FCharSetType = Array[ 0..95 ] of FCharType;
		SCharType = Array[ 0..7, 0..9 ] of boolean;
      SCharSetType = Array[ 0..95 ] of SCharType;

Var
  Mxx, Mxy, Mnx, Mny, XRes, YRes, X, Y, OldX, OldY : integer;
  regs : registers;
  Future : ^FCharSetType;
  Standard : ^SCharSetType;
  Width, Height, FontColor, BackGroundColor : byte;
  PresentSet : SetTypes;
  Transparent, Sused, Fused : boolean;
  SetBank : Pointer;

Procedure NoMode;
Begin
WriteLn('Mode not supported.');
Halt(1);
End;

Procedure SetMode( Mode : ResType );
Var ModeNum : Word;
	 ModeInfo : Record
	 None1 : Array[1..12] of Char;
	 Point : Pointer;
	 None2 : Array[1..$200] of Char;
	 End;
Begin
	 case Mode of
		VGA      : begin
						 Bytes_per_line := 320;
						 GetMaxX := 319;
						 GetMaxY := 199;
						 ModeNum := $13;
					  end;
		SVGA6440 : begin
						 Bytes_per_line := 640;
						 GetMaxX := 639;
						 GetMaxY := 399;
						 ModeNum := $100;
					  end;
		SVGA6448 : begin
						 Bytes_per_line := 640;
						 GetMaxX := 639;
						 GetMaxY := 479;
						 ModeNum := $101;
					  end;
		SVGA8060 : begin
						 Bytes_per_line := 800;
						 GetMaxX := 799;
						 GetMaxY := 599;
						 ModeNum := $103;
					  end;
		SVGA1076 : begin
						 Bytes_per_line := 1024;
						 GetMaxX := 1023;
						 GetMaxY := 767;
						 ModeNum := $105;
					  end;
	 end;
Asm
mov ax,$4F01
mov cx,ModeNum
push ss
pop es
mov di,bp
add di,offset ModeInfo
int $10
End;
SetBank := ModeInfo.Point;
Asm
mov ax,$4F02
mov bx,ModeNum
int $10
End;
end;

procedure LoadWriteBank( Segment : byte );
begin
PresentSeg := Segment;
	asm
	xor bx,bx
	xor dx,dx
	mov dl,Segment
	call dword ptr [SetBank]
	end
end;

function WhichBank( x, y : word ): byte;
begin
WhichBank := (longint( Bytes_per_line) * y + x) shr 16;
end;

procedure Plot( x, y : integer; Color : byte );
Assembler;
asm
	push x
	push y
	push cs
	call near ptr WhichBank
	cmp al,PresentSeg
	je @Ne
	push ax
	push cs
	call near ptr LoadWriteBank
@Ne:
	mov ax, Bytes_per_Line
	mov bx, y
	mul bx
	add ax, x
	mov di, ax
	mov ax, 0a000h
	mov es, ax
	mov al, Color
	mov es:[di], al
end;

procedure PutImage( x, y : integer; Img : XPtr );

  var xx, yy : integer;
		Offset, bank : longint;


  procedure TraverseYPtr( Yp : YPtr );

    begin
      if Yp <> nil then
        begin

          Bank := Offset shr 16;
          if Bank <> PresentSeg then LoadWriteBank( Bank );
          MEM[$A000:Offset] := Yp^.Col1;

          inc( Offset, Bytes_per_line );
          Bank := Offset shr 16;
          if Bank <> PresentSeg then LoadWriteBank( Bank );
          MEM[$A000:Offset] := Yp^.Col2;

          inc( Offset, Bytes_per_line );
          Bank := Offset shr 16;
          if Bank <> PresentSeg then LoadWriteBank( Bank );
          MEM[$A000:Offset] := Yp^.Col3;

          inc( Offset, Bytes_per_line );
          Bank := Offset shr 16;
          if Bank <> PresentSeg then LoadWriteBank( Bank );
          MEM[$A000:Offset] := Yp^.Col4;

          inc( Offset, Bytes_per_line );
          inc( yy, 4 );
          TraverseYPtr( Yp^.NextY );
        end;
    end;

  procedure TraverseXPtr( Xp : XPtr );

    begin
      if Xp <> nil then
        begin
          Offset := (longint(yy)*Bytes_per_line)+xx;
          TraverseYPtr( Xp^.Y );
          yy := y;
          inc( xx );
          TraverseXPtr( Xp^.NextX );
        end;
    end;

  begin
    xx := x;
    yy := y;
    TraverseXPtr( Img );
  end;

procedure LoadImage( ImageName : string; var ImagePtr : XPtr );

  var f : file of byte;
      MaxWidth, MaxHeight, Col1, Col2, Col3, Col4, th : byte;

  procedure ReadY( var Yp : YPtr );

    var TmpY : YPtr;

    begin
      new( TmpY );
      read( f, Col1, Col2, Col3, Col4 );
      TmpY^.Col1 := Col1;
      TmpY^.Col2 := Col2;
      TmpY^.Col3 := Col3;
      TmpY^.Col4 := Col4;
      inc( th, 4 );
      if th < MaxHeight then
        ReadY( TmpY^.NextY )
      else
        TmpY^.NextY := nil;
      Yp := TmpY;
    end;

  procedure ReadX( var Xp : XPtr );

    var TmpX : XPtr;

    begin
      if not eof( f ) then
        begin
          new( TmpX );
          ReadY( TmpX^.Y );
          th := 1;
          ReadX( TmpX^.NextX );
          Xp := TmpX;
        end
      else
        Xp := nil;
    end;

  begin
    assign( f, ImageName );
    reset( f );
    read( f, MaxWidth, MaxHeight );
    th := 1;
    ReadX( ImagePtr );
    close( f );
  end;

procedure DisposeImage( var Img : XPtr );

  procedure TraverseYPtr( Yp : YPtr );

    begin
      if Yp <> nil then
        begin
          TraverseYPtr( Yp^.NextY );
          Dispose( Yp );
        end;
    end;

  procedure TraverseXPtr( Xp : XPtr );

    begin
      if Xp <> nil then
        begin
          TraverseXPtr( Xp^.NextX );
          TraverseYPtr( Xp^.Y );
        end;
    end;

  begin
    TraverseXPtr( Img );
    Img := nil;
  end;

procedure SetColor( PalNum: byte; Hue : RGB );
begin
    Color[ PalNum ] := Hue;
    with regs do
      begin
        AX := $1010;
        BX := PalNum;
        CH := Hue.Grn;
        CL := Hue.Blu;
        DH := Hue.Red;
      end;
    intr( $10, regs );
  end;

function GetPixel( x, y : integer ) : byte;
Assembler;
asm
	push x
	push y
	push cs
	call near ptr WhichBank
	cmp al,PresentSeg
	je @Ne
	push ax
	push cs
	call near ptr LoadWriteBank
@Ne:
	mov ax,Bytes_Per_line
	mov bx,y
	mul bx
	add ax,x
	mov si,ax
	push $A000
	pop es
	mov al,es:[si]
	leave
	retf 4
end;

procedure SetPalette( Hue : PaletteRegister );
begin
Color := Hue;
with Regs do
	begin
	AX := $1012;
	BX := 0;
	CX := 256;
	ES := Seg( Hue );
	DX := Ofs( Hue );
	end;
intr( $10, Regs );
end;

procedure CyclePalette;
var
	 i   : byte;
	 Tmp : RGB;
begin
Tmp := Color[1];
for i := 2 to 251 do
	Color[i-1] := Color[i];
Color[251] := Tmp;
SetPalette( Color )
end;

procedure Swap( var First, Second : integer );
var temp : integer;
begin
temp   := first;
first  := second;
second := temp
end;

procedure Circle( x, y, Radius : word; Color : byte );
var a, af, b, bf, target, r2 : integer;
begin
target := 0;
a := radius;
b := 0;
r2 := Sqr( radius );
while a >= b do
	begin
	b := Round( Sqrt( r2 - sqr(a)));
	Swap( target, b );
	while b < target do
		begin
		af := (100*a) div 100;
		bf := (100*b) div 100;
		Plot( x+af, y+b, color );
		Plot( x+bf, y+a, color );
		Plot( x-af, y+b, color );
		Plot( x-bf, y+a, color );
		Plot( x-af, y-b, color );
		Plot( x-bf, y-a, color );
		Plot( x+af, y-b, color );
		Plot( x+bf, y-a, color );
		b := b + 1
		end;
	a := a - 1
	end
end;

procedure Line( xx1, yy1, xx2, yy2 : integer; color : byte );

  var
	 LgDelta, ShDelta, Cycle, LgStep, ShStep, Dtotal : integer;

  procedure VertLine( x, y1, y2: integer; color : byte );

	 var  NumNextBank : integer;

	 begin
		NumNextBank := Whichbank( x, y1 );
		if NumNextBank <> PresentSeg then LoadWriteBank( NumNextBank );
		inc( NumNextBank );
		asm
				mov ax, bytes_per_line
				mov bx, y1
				mul bx
				add ax, x
				mov di, ax
				mov ax, 0a000h
				mov es, ax
				mov al, color
				mov dx, y1
		@L01: mov es:[di], al
				inc dx
				cmp dx, y2
				ja  @L02
				add di, bytes_per_line
				jnc @L01
				push es
				push di
				push dx
				push ax
				mov ax, NumNextBank
				push ax
				call LoadWriteBank
				inc NumNextBank
				pop ax
				pop dx
				pop di
				pop es
				jmp @L01
		@L02: nop;
		end;
	 end;

procedure HorzLine( x1, x2, y: integer; color : byte );
var  NumNextBank : integer;
begin
NumNextBank := Whichbank( x1, y );
if (NumNextBank <> PresentSeg) then
		LoadWriteBank( NumNextBank );
inc( NumNextBank );
	asm
	mov ax, bytes_per_line
	mov bx, y
				mul bx
				add ax, x1
				mov di, ax
				mov ax, 0a000h
				mov es, ax
				mov al, color
				mov dx, x1
		@L01: mov es:[di], al
				inc dx
				cmp dx, x2
				ja  @L02
				add di, 1
				jnc @L01
				push es
				push di
				push dx
				push ax
				mov ax, NumNextBank
				push ax
				call LoadWriteBank
				inc NumNextBank
				pop ax
				pop dx
				pop di
				pop es
				jmp @L01
		@L02: nop;
		end;
	 end;

  begin
	 if xx1 > xx2 then swap( xx1, xx2 );
	 if yy1 > yy2 then swap( yy1, yy2 );
	 if xx1 = xx2 then VertLine( xx1, yy1, yy2, Color )
		else if yy1 = yy2 then HorzLine( xx1, xx2, yy1, Color )
		  else
			 begin
				LgDelta := xx2 - xx1;
				ShDelta := yy2 - yy1;
            if LgDelta < 0 then
              begin
                LgDelta := -LgDelta;
                LgStep := -1
              end
            else
              LgStep := 1;
              if ShDelta < 0 then
                begin
                  ShDelta := -ShDelta;
                  ShStep := -1
                end
              else
                ShStep := 1;
              if ShDelta < LgDelta then
                begin
                  Cycle := LgDelta shr 1;
                  while xx1 <> xx2 do
                    begin
                      Plot( xx1, yy1, color );
                      Cycle := Cycle + ShDelta;
                      if Cycle > LgDelta then
                        begin
                          Cycle := Cycle - LgDelta;
                          yy1 := yy1 + ShStep
                        end;
                      xx1 := xx1 + LgStep
                    end;
                  Plot( xx1, yy1, color )
                end
              else
                begin
                  Cycle := ShDelta shr 1;
                  Swap( LgDelta, ShDelta );
                  Swap( LgStep, ShStep );
                  while yy1 <> yy2 do
                    begin
                      Plot( xx1, yy1, color );
                      Cycle := Cycle + ShDelta;
                      if Cycle > LgDelta then
                        begin
                          Cycle := Cycle - LgDelta;
                          xx1 := xx1 + ShStep
                        end;
                      yy1 := yy1 + LgStep
                    end;
                  Plot( xx1, yy1, color )
                end;
          end;
  end;

procedure ClearDevice;
var i : byte;
begin
for i := 0 to 11 do
	begin
	LoadWriteBank( i );
		asm
		mov ax, 0a000h
		mov es, ax
		xor di, di
		mov cx, 07fffh
		mov ax, 000h
		rep stosw
		stosw
		end;
	end;
end;

procedure ClearPort( x1, y1, x2, y2 : integer );
var i, j, Temp : integer;
begin
if y1 > y2 then Swap( y1, y2 );
for i := 0 to 19 do
	for j := 0 to 23 do
		begin
		Temp := y1+i+j*20;
		if Temp <= y2 then
			Line( x1, Temp, x2, Temp, 0 );
		end;
end;

procedure Rectangle( x1, y1, x2, y2 : word; Color : byte );
begin
Line( x1, y1, x2, y1, Color );
Line( x2, y1, x2, y2, Color );
Line( x2, y2, x1, y2, Color );
Line( x1, y2, x1, y1, Color );
end;

procedure RectFill( x1, y1, x2, y2 : integer; Color : byte );
var  PBank : integer;
begin
if (x2 < x1) then Swap( x1, x2 );
if (y2 < y1) then Swap( y1, y2 );
	asm
			mov cx, y1
	@L00: mov ax, x1
			push cx
			push ax
			push cx
			call WhichBank
			cmp al, PresentSeg
			je  @L04
			push ax
			call LoadWriteBank
	@L04: pop cx
			mov ax, bytes_per_line
			mul cx
			add ax, x1
			mov di, ax
			mov ax, 0a000h
			mov es, ax
			mov al, color
			mov dx, x1
	@L01: mov es:[di], al
			inc dx
			cmp dx, x2
			ja  @L02
			add di, 1
			jnc @L01
			push es
			push di
			push cx
			push dx
			push ax
			push dx
			push cx
			call WhichBank
			push ax
			call LoadWriteBank
			pop ax
			pop dx
			pop cx
			pop di
			pop es
			jmp @L01
	@L02: inc cx
			cmp cx, y2
			ja  @L03
			jmp @L00
		@L03: nop;
	end;
end;

Procedure ExitGraphics;
Begin
	Asm
	mov ax,3
	int $10
	End;
If (Fused) Then
	Dispose(Future);
If (Sused) Then
	Dispose(Standard);
End;

Procedure OutTextXY( x, y : Integer; word : String);
Var 	i, j, k, symbol : Byte;
		LetterX, LetterY, xx, yy : Integer;
Begin
LetterX := x;
LetterY := y;
If (PresentSet = FutureFont) Then
	Begin
	For i := 1 To length( word ) Do
		Begin
		symbol := ord(word[i])-ord(' ');
		For j := 0 To Width Do
			For k := 0 To Height Do
				If Future^[symbol][j,k] Then
					Plot( LetterX+j, LetterY+k, FontColor )
					else
					If (Not Transparent) Then
						Plot( LetterX+j, LetterY+k, BackGroundColor );
		LetterX := LetterX + Width + 2;
		End;
	End;
If (PresentSet = StandardFont) Then
	Begin
	For i := 1 To length( word ) Do
		Begin
		symbol := ord(word[i])-ord(' ');
		For j := 0 To Width Do
			For k := 0 To Height Do
				If (Standard^[symbol][j,k]) Then
					Plot( LetterX+j, LetterY+k, FontColor )
					Else
					If (not Transparent) Then
						Plot( LetterX+j, LetterY+k, BackGroundColor );
		LetterX := LetterX + Width + 2;
		End;
	End;
End;

Procedure LoadFont( CharSetName: SetTypes );
Var 	Sfil : File of SCharSetType;
		Ffil : File of FCharSetType;
		Color : byte;
Begin
If (CharSetName = FutureFont) Then
	Begin
	GetMem(Future, 19968);
	Assign(Ffil, 'future.chr');
	Reset(Ffil);
	Read(Ffil, Future^);
	Close(Ffil);
	Fused := True;
	End;
If (CharSetName = StandardFont) Then
	Begin
	GetMem(Standard,7680);
	Assign(Sfil,'standard.chr');
	Reset(Sfil);
	Read(Sfil,Standard^);
	Close(Sfil);
	Sused := True;
	End;
End;

Procedure SetFont( Font : SetTypes );
Begin
If (Font = FutureFont) Then
	Begin
	Width := 15;
	Height := 12;
	PresentSet := FutureFont;
	End;
If (Font = StandardFont) Then
	Begin
	Width := 7;
	Height := 9;
	PresentSet := StandardFont;
	End;
End;

Procedure SetFontColor(Color, BackCol : Byte; Trans : Boolean);
Begin
FontColor := Color;
BackGroundColor := BackCol;
Transparent := Trans;
End;

Procedure LoadPalette(PaletteName : String);
Var Fil : File of PaletteRegister;
Begin
Assign( fil, PaletteName );
Reset( fil );
Read( fil, Color );
Close( fil );
SetPalette( Color );
End;

Procedure WaitSync;
Assembler;
Asm
 mov     dx,3DAh
@loop1:
 in      ax,dx
 test    al,8
 jz      @loop1
@loop2:
 in      ax,dx
 test    al,8
 jnz     @loop2
End;

Begin
SetBank := @NoMode;
SetFont( StandardFont );
SetFontColor( 253, 0, True );
PresentSeg := 0;
Sused := False;
Fused := False;
End.