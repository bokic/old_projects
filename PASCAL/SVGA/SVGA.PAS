{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R-,S+,T+,V+,X+,Y+}
{$M 16384,0,655360}
Unit SVGA;

Interface

Const
   ButtonL = 0; ButtonR = 1; ButtonM = 2;
   OFF      = 0;  ON       = 1;

Type
  RGB = Record
        Red, Grn, Blu : byte
        End;
  PaletteRegister = Array[0..255] of RGB;
  SetTypes = ( FutureFont, StandardFont );
  ResType = ( VGA, SVGA6440, SVGA6448, SVGA8060, SVGA1076 );
  Position = Record
               BtnStatus,
               opCount,
               XPos, YPos : integer;
             End;
  EventRec = Record
               Event,
               BtnStatus,
               XPos, YPos : word;
             End;
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

  GenMouse = Object
      Procedure SetAccel( threshold : integer );
      Procedure Getposition( var BtnStatus, XPos, YPos : integer );
      Procedure QueryBtnDn( button : integer; var mouse : Position );
      Procedure QueryBtnUp( button : integer; var mouse : Position );
      Procedure ReadMove( var XMove, YMove : integer );
      Procedure Reset( var Status : boolean; var BtnCount : integer );
      Procedure SetRatio( horPix, verPix : integer );
      Procedure SetLimits( XPosMin, YPosMin, XPosMax, YPosMax : integer );
      Procedure SetPosition( XPos, YPos : integer );
   End;

  GraphicMouse = Object( GenMouse )
    Procedure Initialize;
    Procedure Show( ShowM : boolean );
    Procedure MPlot( xx, yy : integer );
    Procedure CheckMouse;
    Procedure ExitSVGA;
  End;

procedure SetMode( Mode : Restype );
function WhichBank( x, y : integer ): byte;
procedure LoadWriteBank( Segment : byte );
procedure Plot( x, y : integer; Color : byte );
procedure PutImage( x, y : integer; Img : XPtr );{ Puts an image in memory to screen at point (x,y), top left hand corner }
procedure LoadImage( ImageName : string; var ImagePtr : XPtr );{ Loads image from disk and puts into memory }
procedure DisposeImage( var Img : XPtr );{ Deletes image from memory }
procedure SetColor( PalNum: byte; Hue : RGB );{ Sets Color of a particular pallette }
function  GetPixel( x, y : integer ) : byte; { Returns color of a pixel }
procedure SetPalette( Hue : PaletteRegister );{ Sets all 256 pallette registers to desired pallette }
procedure CyclePalette;{ Rotates all colors in the pallette in repetitive cycle }
procedure Circle( x, y, Radius : word; Color : byte );
procedure Line( xx1, yy1, xx2, yy2 : integer; Color : byte );
procedure ClearDevice;
procedure ClearPort( x1, y1, x2, y2 : integer );{ Clears a Section of the screen }
procedure Rectangle( x1, y1, x2, y2 : word; Color : byte );
procedure RectFill( x1, y1, x2, y2 : integer; Color : byte );{ Draws a solid Rectangle }
procedure ExitGraphics;{ Exits SVGA Graphics and returns to normal text mode }
procedure OutTextXY( x, y : integer; word : string );
procedure LoadFont( CharSetName: SetTypes );{ Loads a particular Font for use }
procedure SetFont( Font : SetTypes );{ If two or more fonts are in memory this allows you to choose one }
procedure SetFontColor( Color, BackCol : byte; Trans : boolean );
  { Set forground & background color of text & transparent background or not }
  { i.e write background to screen or skip it and only write letter          }
procedure LoadPalette( PaletteName : string );{ Loads a particular pallette from disk }

var  Color : PaletteRegister;
     Bytes_per_Line, GetMaxX, GetMaxY : integer;
     mEvent : EventRec;
     PresentSeg : byte;

Implementation

Uses Dos, Crt;

Type  FCharType = Array[ 0..15, 0..12 ] of boolean;
      FCharSetType = Array[ 0..95 ] of FCharType;
      SCharType = Array[ 0..7, 0..9 ] of boolean;
      SCharSetType = Array[ 0..95 ] of SCharType;
      CardType = ( AheadA, AheadB, ATI, ChipsTech, Everex, Genoa,
                  Paradise, Trident, Tseng3000, Tseng4000, Vesa, Video7 );
      NameType = String[30];

Var
  Mxx, Mxy, Mnx, Mny, XRes, YRes, X, Y, OldX, OldY : integer;
  regs : registers;
  Future : ^FCharSetType;
  Standard : ^SCharSetType;
  Width, Height, FontColor, BackGroundColor : byte;
  PresentSet : SetTypes;
  ShowMouse, Transparent, Sused, Fused : boolean;
  Card : CardType;
  MP, ColOld : array[ 0..3, 0..3 ] of byte;


Function Ahead : NameType;
Begin
Portw[$3CE] := $200F;
If (Port[$3CF] = $20) Then
   Ahead := 'Ahead A'
   else
   if (Port[$3CF] = $21) Then
      Ahead := 'Ahead B'
      else
      Ahead := 'False';
End;

Function AnATI : NameType;
Var s : NameType;
    Temp : string;
Begin
s[0] := #9;
move(mem[$C000:$31],s[1],9);
If (s='761295520') Then
   Begin
   Temp := 'ATI';
   If (memw[$C000:$40] = $3331) Then
      Begin
      Temp := Temp + ' Super VGA';
      Regs.AH := $12;
      Regs.BX := $5506;
      Regs.AL := $55;
      Regs.BP := $FFFF;
      Regs.SI := $0;
      intr( $10, Regs );
      If (Regs.BP = $FFFF) Then
         Temp := Temp + ' Revision 1'
         else
         Temp := Temp + ' Revision 2/3';
      End
      Else
      Temp := 'False';
   AnATI := Temp;
   End
   Else
   AnATI := 'False';
End;

Function AChipsTech : Nametype;
Var OldValue, Value : byte;
    Temp : String;
Begin
Port[$3C3] := Port[$3C3] or 16;
If (Port[$104] = $A5) Then
   Begin
   Temp:= 'Chips & Technologies';
   Port[$3C3] := Port[$3C3] And $EF;
   Port[$3D6] := 0;
   Case Port[$3D7] shr 4 of
        1 : Begin
            Port[$3D6] := $3A;
            OldValue := Port[$3D7];
            Port[$3D7] := $AA;
            Value := Port[$3D7];
            Port[$3D7] := OldValue;
            If (Value = $AA) Then
               Temp := Temp + ' 82c452'
               Else
               Temp := Temp + ' 82c451';
            End;
          2 : Temp := Temp + ' 82c455';
          3 : Temp := Temp + ' 82c453';
          5 : Temp := Temp + ' 82c456';
          End;
        AChipsTech := Temp;
   End
   Else
   AChipsTech := 'False';
End;

Function AnEverex : NameType;
Var Value : byte;
    s : NameType;
Begin
Regs.AX := $7000;
Regs.BX := 0;
intr( $10, Regs );
If (Regs.AL = $70) Then
   Begin
   Value := Regs.DX shr 4;
   If (Value = $678) Then
      AnEverex := 'Everex Ev678'
       Else
       If (Value = $236) Then
          AnEverex := 'Everex Ev236'
          Else
              Begin
              str( Value, s );
              AnEverex := 'Everex Ev'+ s;
              End;
   End
   Else
   AnEverex := 'False';
End;

Function AGenoa : Nametype;
Begin
If ((meml[$C000:mem[$C000:$37]] and $FFFF00FF) = $66990077) Then
   Begin
   Case mem[$C000:mem[$C000:$37] + 1] of
      $33, $55 : AGenoa := 'Tseng ET3000';
      $22 : AGenoa := 'Genoa 6100';
      0 : AGenoa := 'Genoa 6200/6300';
      $11 : AGenoa := 'Genoa 6400/6600';
      End;
   End
   Else
   AGenoa := 'False';
End;

Function AParadise : NameType;
Var OldValue, NewValue, New1, New2 : byte;
    Base : word;
    Temp : String;
Begin
If (meml[$C000:$7D] = $3D414756) Then
   Begin
   Temp := 'Paradise';
   If (odd(Port[$3CC])) Then
      Base:= $3D4
      Else
      Base := $3B4;
   Port[Base] := $2B;
   OldValue := Port[Base+1];
   Port[Base+1] := $AA;
   NewValue := Port[Base+1];
   Port[Base+1] := OldValue;
   If (NewValue <> $AA) Then
      Temp := Temp + ' PVGA1A'
      Else
      Begin
      Port[$3C4] := $12;
      OldValue := Port[$3C5];
      Port[$3C5] := OldValue and $BF;
      New1 := Port[$3C5] and 64;
      Port[$3C5] := OldValue or $40;
      New2 := Port[$3C5] and 64;
      Port[$3C5] := OldValue;
      If ((New1 <> 0) or (New2 = 0)) Then
         Temp := Temp + ' WD90C00'
         Else
         Begin
         Port[$3C4] := $10;
         OldValue := Port[$3C5];
         Port[$3C5] := OldValue and $FB;
         New1 := Port[$3C5] and 4;
         Port[$3C5] := OldValue or 4;
         New2 := Port[$3C5] and 4;
         Port[$3C5] := OldValue;
         If ((New1 <> 0) or (New2 = 0)) Then
            Temp := Temp + ' WD90C10'
            else
            Temp := Temp + ' WD90C11';
         End;
      End;
   AParadise := Temp;
   End
   Else
   AParadise := 'False';
End;

Function ATrident : NameType;
Var OldValue, Value : byte;
    Temp : String;
Begin
Port[$03C4] := $E;
OldValue := Port[$03C5];
Port[$03C5] := 0;
Value := Port[$03C5] AND $F;
Port[$03C5] := OldValue;
If (Value = $2) Then
   Begin
   Temp := 'Trident';
   Port[$3C4] := 11;
   If (Port[$3C5] = 35) Then
      Temp := Temp + ' 9000'
      else
      If (Port[$3C5] = 3) Then
         Temp := Temp + ' 8900'
         Else
         If (Port[$3C5] = 2) Then
            Temp := Temp + ' 8800CS'
            Else
            If (Port[$3C5] = 1) Then Temp := Temp + ' 8800BR';
         ATrident := Temp;
   End
   Else
   ATrident := 'False';
End;

Function ATseng : NameType;
Var OldValue, NewValue, Value : byte;
    Base : word;
    Temp : String;
Begin
OldValue := Port[$3CD];
Port[$3CD] := $55;
NewValue := Port[$3CD];
Port[$3CD] := OldValue;
If (NewValue = $55) Then
   Begin
   Temp := 'Tseng';
   If odd( Port[$3CC] ) Then
      Base := $3C4
      Else
      Base := $3B4;
   Port[Base] := $33;
   OldValue := Port[Base+1];
   NewValue := OldValue xor 15;
   Port[Base+1] := NewValue;
   Value := Port[Base+1];
   Port[Base+1] := OldValue;
   If (Value = NewValue) Then
      Temp := Temp + ' ET4000'
      Else
      Temp := Temp + ' ET3000';
   ATseng := Temp;
   End
   Else
   ATseng := 'False';
End;

Function AVesa : NameType;
Var Info    :Record
    Info    :Array [1..4] of char;
    Ver     :Word;
    Pem_P   :Pointer;
    Capat   :Array [1..4] of byte;
    ModesP  :Pointer;
    Memory  :Word;
    {-----Vesa 2.0------}
    Oem_So  :Word;
    Vendor  :Pointer;
    Prod_Nam:Pointer;
    Prod_Rev:Pointer;
    Els     :Array [1..256] of char;
    End;
    Temp:NameType;
    T2:String[10];
    Resul:Word;
Begin
 Asm
 mov ax,$4F00
 mov di,offset Info
 add di,bp
 push ss
 pop es
 int $10
 mov Resul,Ax
 end;
If (Resul=$4F) Then
   Begin
   Str(Info.Memory*64,T2);
   Temp:=T2+'kb';
   Str(Lo(Info.Ver),T2);
   Temp:='.'+T2+' '+Temp;
   Str(Hi(Info.Ver),T2);
   Temp:=T2+Temp;
   Avesa:='Vesa '+Temp;
   End
   Else
   AVesa:='False';
End;

Function AVideo7 : NameType;
Var Value, OldValue, NewValue : byte;
    Base : word;
    Temp : String;
Begin
If (odd( Port[$3CC] )) Then
   Base := $3D4
   Else
   Base := $3B4;
Port[Base] := 12;
OldValue := Port[Base+1];
Port[Base+1] := $55;
NewValue := Port[Base+1];
Port[Base] := $1F;
Value := Port[Base+1];
Port[Base] := 12;
Port[Base+1] := OldValue;
If (Value = byte( $55 xor $EA )) Then
   Begin
   Temp := 'Video7';
   Port[$3C4] := $8E;
   Case Port[$3C5] of
      $80..$FF : Temp := Temp + ' VEGA VGA';
      $70..$7F : Temp := Temp + ' V7VGA FASTWRITE/VRAM';
      $50..$59 : Temp := Temp + ' V7VGA Version 5';
      $41..$49 : Temp := Temp + ' 1024i';
      End;
   AVideo7 := Temp;
   End
   Else
   AVideo7 := 'False';
End;

Procedure NoMode;
Begin
writeln;
write( ' Mode not supported.' );
Halt(1);
End;

Procedure SetMode( Mode : ResType );
Var ModeNum, i : byte;
    Tp: NameType;
    Tmp : real;
Begin
    if Ahead <> 'False' then
      begin
        Tp := Ahead;
        if Tp = 'Ahead A' then Card := AheadA
          else Card := AheadB;
        case Mode of
          VGA      : ModeNum := $13;
          SVGA6440 : ModeNum := $60;
          SVGA6448 : ModeNum := $61;
          SVGA8060 : ModeNum := $62;
          SVGA1076 : ModeNum := $63;
        end;
        if (ModeNum = $63) and (Card = AheadA) then NoMode;
      end
    else if AnATI <> 'False' then
      begin
        Tp := AnATI;
        case Mode of
          VGA      : ModeNum := $13;
          SVGA6440 : ModeNum := $61;
          SVGA6448 : ModeNum := $62;
          SVGA8060 : ModeNum := $63;
        end;
        if Mode=SVGA1076 then NoMode;
        Card := ATI;
      end
    else if AChipsTech <> 'False' then
      begin
        Tp := AChipsTech;
        if ((Tp='Chips & Technologies 82c452') or
            (Tp='Chips & Technologies 82c453')) then
           begin
             case Mode of
               VGA      : ModeNum := $13;
               SVGA6440 : ModeNum := $78;
               SVGA6448 : ModeNum := $79;
               SVGA8060 : ModeNum := $7C;
               SVGA1076 : ModeNum := $7E;
             end;
             if (Mode=SVGA1076) or ((Mode in [SVGA8060,SVGA1076]) and
                (Tp = 'Chips & Technologies 82c452')) then
                  NoMode;
             Card := ChipsTech;
           end
        else
          NoMode;
      end
    else if AnEverex <> 'False' then
      begin
        Tp := AnEverex;
        case Mode of
          VGA      : ModeNum := $13;
          SVGA6440 : ModeNum := $14;
          SVGA6448 : ModeNum := $30;
          SVGA8060 : ModeNum := $31;
          SVGA1076 : ModeNum := $32;
        end;                            { ??? How about Trident Chips }
        if (Tp = 'Everex Ev678') or (Tp = 'Everex Ev236') then
          Card := Trident   { 678, 236 Chips use Trident }
        else Card := Everex;
      end
    else if AGenoa <> 'False' then
      begin
        Tp := AGenoa;
        if Tp = 'Tseng 3000' then
          begin
            case Mode of
              VGA      : ModeNum := $13;
              SVGA6440 : ModeNum := $2F;
              SVGA6448 : ModeNum := $2E;
              SVGA8060 : ModeNum := $30;
            end;
            if Mode=SVGA1076 then NoMode;
            Card := Tseng3000;
          end
        else
          begin
            case Mode of
              VGA      : ModeNum := $13;
              SVGA6440 : ModeNum := $7E;
              SVGA6448 : ModeNum := $5C;
              SVGA8060 : ModeNum := $6C;
            end;
            if Mode=SVGA1076 then NoMode;
            Card := Genoa;
          end;
      end
    else if AParadise <> 'False' then
      begin
        Tp := AParadise;
        case Mode of
          VGA      : ModeNum := $13;
          SVGA6440 : ModeNum := $5E;
          SVGA6448 : ModeNum := $5F;
          SVGA8060 : ModeNum := $5C;
        end;
        if (Mode=SVGA1076) or ((Mode=SVGA8060) and not(Tp='Paradise WD90C11')) then
          NoMode;
        Card := Paradise;
      end
    else if ATrident <> 'False'then
      begin
        Tp := ATrident;
        case Mode of
          VGA      : ModeNum := $13;
          SVGA6440 : ModeNum := $5C;
          SVGA6448 : ModeNum := $5D;
          SVGA8060 : ModeNum := $5E;
          SVGA1076 : ModeNum := $62;
        end;
        if (Mode in [SVGA8060,SVGA1076]) and ((Tp='Trident 8800CS') or (Tp='Trident 8800CS')) then
          NoMode;
        Card := Trident;
      end
    else if ATseng <> 'False' then
      begin
        Tp := ATseng;
        case Mode of
          VGA      : ModeNum := $13;
          SVGA6440 : ModeNum := $2F;
          SVGA6448 : ModeNum := $2E;
          SVGA8060 : ModeNum := $30;
          SVGA1076 : ModeNum := $38;
        end;
        if (Mode=SVGA1076) and (Tp='Tseng ET3000') then
          NoMode;
        if Tp = 'Tseng ET3000' then Card := Tseng3000
          else Card := Tseng4000;
      end
    else if AVideo7 <> 'False' then
      begin
        Tp := AVideo7;
        case Mode of
          VGA      : ModeNum := $13;
          SVGA6440 : ModeNum := $66;
          SVGA6448 : ModeNum := $67;
          SVGA8060 : ModeNum := $69;
        end;
        if Mode = SVGA1076 then NoMode;
        Card := Video7;
      end
    else if AVesa <> 'False' then
      begin
      Tp := AVesa;
        case Mode of
          VGA      : ModeNum := $FF;
          SVGA6440 : ModeNum := $00;
          SVGA6448 : ModeNum := $01;
          SVGA8060 : ModeNum := $03;
          SVGA1076 : ModeNum := $05;
          end;
      Card := Vesa;
      end
    else
      begin
        write( 'Graphics card Unrecognizable......' );
        Halt( 1 );
      end;
    case Mode of
      VGA      : begin
                   Bytes_per_line := 320;
                   GetMaxX := 319;
                   GetMaxY := 199;
                 end;
      SVGA6440 : begin
                   Bytes_per_line := 640;
                   GetMaxX := 639;
                   GetMaxY := 399;
                 end;
      SVGA6448 : begin
                   Bytes_per_line := 640;
                   GetMaxX := 639;
                   GetMaxY := 479;
                 end;
      SVGA8060 : begin
                   Bytes_per_line := 800;
                   GetMaxX := 799;
                   GetMaxY := 599;
                 end;
      SVGA1076 : begin
                   Bytes_per_line := 1024;
                   GetMaxX := 1023;
                   GetMaxY := 767;
                 end;
    end;
    if ((Card <> Video7)And(Card <> Vesa)) then
      begin
        Regs.AH := 0;
        Regs.AL := ModeNum;
        intr( $10, Regs );
      end;
    if Card = ATI then                { Certain cards have to be  }
      asm                             { initialized before use    }
        push es
        push bx
        mov ax, 0c000h
        mov es, ax
        mov bx, 10h
        mov dx, es:[bx]
        pop bx
        pop es
        mov al, 0beh
        out dx, al
        inc dl
        in al, dx
        mov ah, al
        and ah, 0f7h
        dec dl
        mov al, 0beh
        out dx, ax
      end;
      if Card = ChipsTech then
        asm
          mov dx, 3d6h
          mov al, 0bh
          out dx, al
          in al, dx
          and al, 0fdh
          out dx, al
        end;
      if Card = Paradise then
        asm
          mov dx, 3ceh
          mov al, 0fh
          mov ah, 05h
          out dx, ax
          add dx, 4
          mov al, 29h
          mov ah, 85h
          out dx, ax
          mov dx, 3c4h
          mov al, 06h
          mov ah, 48h
          out dx, ax
          mov dx, 3c4h
          mov al, 11h
          out dx, al
          inc dx
          in  al, dx
          and al, 7fh
          out dx, al
          mov dx, 3ceh
          mov al, 0bh
          out dx, al
          inc dx
          in  al, dx
          and al, 0f7h
          out dx, al
        end;
      if Card = Vesa then
        asm
          mov al,ModeNum
          cmp al,$FF
          jne @Vesa
          mov ax,$13
          int $10
          jmp @End
          @Vesa:
          mov ax,$4f02
          mov bh,1
          mov bl,ModeNum
          int $10
          @End:
        end;
      if Card = Video7 then
        asm
          mov bx, 67h
          mov ax, 6f05h
          int 10h
          mov dx, 3c4h
          mov al, 6
          mov ah, 0eah
          out dx, ax
        end;
  end;

procedure LoadWriteBank( Segment : byte );

  begin
    PresentSeg := Segment;
    if Card = Trident then
        asm
          mov bl, Segment
          mov dx, 3c4h
          mov al, 0eh
          xor bl, 02
          mov ah, bl
          out dx, ax
        end
    else if Card = Tseng3000 then
        asm
          mov bl, Segment
          mov dx, 3cdh
          in  al, dx
          and al, 0f8h
          and bl, 07h
          or  al, bl
          out dx, al
        end
    else if Card = Tseng4000 then
        asm
          mov bl, Segment
          mov dx, 3cdh
          in  al, dx
          and al, 0f0h
          and bl, 0fh
          or  al, bl
          out dx, al
        end
      else if Card = Paradise then
        asm
          mov bl, Segment
          mov dx, 3ceh
          mov al, 09h
          mov ah, bl
          shl ah, 1
          shl ah, 1
          shl ah, 1
          shl ah, 1
          out dx, ax
        end
      else if Card = Genoa then
        asm
          mov bl, Segment
          mov dx, 3c4h
          mov al, 06h
          out dx, al
          inc dx
          in  al, dx
          and al, 0c7h
          and bl, 07h
          shl bl, 1
          shl bl, 1
          shl bl, 1
          or  al, bl
          out dx, al
        end
      else if Card = ChipsTech then
        asm
          mov bl, Segment
          mov dx, 3d6h
          mov al, 10h
          mov ah, bl
          shl ah, 1
          shl ah, 1
          out dx, ax
        end
      else if Card = ATI then
        asm
          mov bl, Segment
          push es
          push bx
          mov ax, 0c000h
          mov es, ax
          mov bx, 10h
          mov dx, es:[bx]
          pop bx
          pop es
          mov al, 0b2h
          out dx, al
          inc dl
          in al, dx
          mov ah, al
          and ah, 0e1h
          shl bl, 1
          or ah, bl
          mov al, 0b2h
          dec dl
          out dx, ax
        end
      else if Card = Vesa then
        asm
        mov ax,$4f05
        xor bx,bx
        mov dh,0
        mov dl,Segment
        int $10
        end
      else if Card = Video7 then
      { This is for the V7VGA Chip Versions 1-3 }
      { Version 4 is different }
        asm
          mov bl, Segment
          mov dx, 3c4h
          mov ah, bl
          and ah, 1
          mov al, 0f9h
          out dx, ax

          mov ah, bl
          and ah, 2
          shl ah, 1
          shl ah, 1
          shl ah, 1
          shl ah, 1
          mov dx, 3cch

          in  al, dx
          and al, 0dfh
          mov dx, 3c2h

          or  al, ah
          out dx, al

          mov dx, 3c4h
          mov al, 0f6h
          out dx, al
          inc dx
          in  al, dx

          mov ah, al
          and ah, 0fch
          shr bl, 1

          shr bl, 1
          and bl, 3
          or  ah, bl
          mov al, ah
          out dx, al
        end;
  end;
{ *** }

function WhichBank( x, y : integer ): byte;
begin
WhichBank := (longint( Bytes_per_line) * y + x) shr 16;
end;

procedure Plot( x, y : integer; Color : byte );

{  var Segment : byte;}

  begin
{   Segment := WhichBank( x, y );
   if Segment <> PresentSeg then LoadWriteBank( Segment );}
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

{  var Segment : byte;
{      Off:LongInt;
      Ofset : word;
      Test:Byte;}
  begin
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
    end;
{    Segment := WhichBank( x, y );
    if Segment <> PresentSeg then LoadWriteBank( Segment );
{    Off := (longint( Bytes_per_line) * y + x);}
    asm
    mov ax,Bytes_Per_line
    mov bx,y
    mul bx
    add ax,x
    mov si,ax
    end;
{    Ofset := Lo(longint( Bytes_per_line) * y + x);}
{    GetPixel := Mem[$A000:Ofset];}
    asm
    push $A000
    pop es
{    mov di,Ofset}
    mov al,es:[si]
{    mov [bp-1],al}
    leave
    retf 4
    end;
{    Test:= Mem[$A000:Offset];}
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

  var
    temp : integer;

  begin
    temp   := first;
    first  := second;
    second := temp
  end;


procedure Circle( x, y, Radius : word; Color : byte );

  var
    a, af, b, bf, target, r2 : integer;

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
      if NumNextBank <> PresentSeg then LoadWriteBank( NumNextBank );
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
      if x2 < x1 then Swap( x1, x2 );
      if y2 < y1 then Swap( y1, y2 );
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

procedure ExitGraphics;

  begin
    Regs.AH := 0;
    Regs.AL := 3;
    intr( $10, Regs );
    if Fused then dispose( Future );
    if Sused then dispose( Standard );
  end;

procedure OutTextXY( x, y : integer; word : string );

  var i, j, k, symbol : byte;
      LetterX, LetterY, xx, yy : integer;

  begin
    LetterX := x;
    LetterY := y;
    if PresentSet = FutureFont then
      begin
         for i := 1 to length( word ) do
           begin
             symbol := ord(word[i])-ord(' ');
             for j := 0 to Width do
               for k := 0 to Height do
                   if Future^[symbol][j,k] then
                         Plot( LetterX+j, LetterY+k, FontColor )
                   else if not Transparent then
                         Plot( LetterX+j, LetterY+k, BackGroundColor );
             LetterX := LetterX + Width + 2;
           end;
      end;
    if PresentSet = StandardFont then
      begin
         for i := 1 to length( word ) do
           begin
             symbol := ord(word[i])-ord(' ');
             for j := 0 to Width do
               for k := 0 to Height do
                   if Standard^[symbol][j,k] then
                         Plot( LetterX+j, LetterY+k, FontColor )
                   else if not Transparent then
                         Plot( LetterX+j, LetterY+k, BackGroundColor );
             LetterX := LetterX + Width + 2;
           end;
      end;
  end;

procedure LoadFont( CharSetName: SetTypes );

  var Sfil : file of SCharSetType;
      Ffil : file of FCharSetType;
      Color : byte;

  begin
    if CharSetName = FutureFont then
      begin
        GetMem( Future, 19968 );
        assign( Ffil, 'future.chr' );
        reset( Ffil );
        Read( Ffil, Future^ );
        Close( Ffil );
        Fused := True;
      end;
    if CharSetName = StandardFont then
      begin
        GetMem( Standard, 7680 );
        assign( Sfil, 'standard.chr' );
        reset( Sfil );
        Read( Sfil, Standard^ );
        Close( Sfil );
        Sused := True;
      end;
  end;

procedure SetFont( Font : SetTypes );

  begin
    if Font = FutureFont then
      begin
        Width := 15;
        Height := 12;
        PresentSet := FutureFont;
      end;
    if Font = StandardFont then
      begin
        Width := 7;
        Height := 9;
        PresentSet := StandardFont;
      end;
  end;

procedure SetFontColor( Color, BackCol : byte; Trans : boolean );
  begin
    FontColor := Color;
    BackGroundColor := BackCol;
    Transparent := Trans;
  end;

procedure LoadPalette( PaletteName : string  );

  var Fil : File of PaletteRegister;

  begin
    assign( fil, PaletteName );
    reset( fil );
    read( fil, Color );
    Close( fil );
    SetPalette( Color );
  end;

procedure MouseHandler( Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP : word );

   INTERRUPT;
   begin
      mEvent.Event     := AX;
      mEvent.BtnStatus := BX;
      mEvent.xPos      := CX;
      mEvent.yPos      := DX;
      inline( $8B/$E5/$5D/$07/$1F/$5F/$5E/$5A/$59/$5B/$58/$CB );
   end;

procedure GenMouse.Reset( var Status : boolean; var BtnCount : integer );
   begin
      regs.AX := $00;
      intr($33,regs);
      Status   := regs.AX <> 0;
      BtnCount := regs.BX;
   end;

procedure GenMouse.SetAccel( threshold : integer );
   begin
      regs.AX := $13;
      regs.DX := threshold;
      intr($33,regs);
   end;

procedure GenMouse.GetPosition( var BtnStatus, XPos, YPos : integer );
   begin
      regs.AX := $03;
      intr($33,regs);
      Btnstatus := regs.BX;
      XPos := X; YPos := Y;
   end;

procedure GenMouse.SetPosition( XPos, YPos : integer );
   begin
     X := XPos;
     Y := YPos;
   end;

procedure GenMouse.SetRatio( horPix, verPix : integer );
  begin
     regs.AX := $0F;
     regs.CX := horPix;
     regs.DX := verPix;
     intr($33,regs);
  end;

procedure GenMouse.QueryBtnDn( button : integer; var mouse : Position );
   begin
      regs.AX := $05;
      regs.BX := button;
      intr($33,regs);
      mouse.BtnStatus := regs.AX;
      mouse.opCount := regs.BX;
      mouse.XPos    := regs.CX;
      mouse.YPos    := regs.DX;
   end;

procedure GenMouse.QueryBtnUp( button : integer; var mouse : Position );
   begin
      regs.AX := $06;
      regs.BX := button;
      intr($33,regs);
      mouse.BtnStatus := regs.AX;
      mouse.opCount := regs.BX;
      mouse.XPos    := regs.CX;
      mouse.YPos    := regs.DX;
   end;

procedure GenMouse.SetLimits( XPosMin, YPosMin, XPosMax, YPosMax : integer );
   begin
     Mxx := XPosMax;
     Mxy := YPosMax;
     Mnx := XPosMin;
     Mny := YPosMin;
   end;

procedure GenMouse.ReadMove( var XMove, Ymove : integer );
   begin
      asm
      mov ax,$0B
      int $33
      les di,Xmove
      mov es:[di],cx
      les di,Ymove
      mov es:[di],dx
      end;
{      regs.AX := $0B;
      intr($33,regs);
      XMove := regs.CX;
      Ymove := regs.DX;}
   end;

procedure GraphicMouse.MPlot( xx, yy : integer );

  var TX, TY, x, y : integer;

  begin
    for TY := 0 to 3 do
      begin
        y := yy + TY;
        if y < GetMaxY then
        for TX := 0 to 3 do
          begin
            x := xx + TX;
            if (MP[TX,TY] <> 0) AND (x < GetMaxX) then
                Plot( x, y, MP[TX,TY] );
          end;
      end;
  end;

procedure GraphicMouse.Show( ShowM : boolean );

  var i, j, x, y : integer;

  begin
    ShowMouse := ShowM;
    if ShowM then
      begin
        for i := 0 to 3 do
          for j := 0 to 3 do
            ColOld[ i, j ] := GetPixel( OldX + i, OldY + j );
        MPlot( OldX, OldY );
      end
    else
      for i := 0 to 3 do
        begin
          x := OldX + i;
          for j := 0 to 3 do
            begin
              y := OldY + j;
              Plot( x, y, ColOld[i,j] );
            end;
        end;
  end;

procedure GraphicMouse.CheckMouse;

  var XNew, YNew, i, j : integer;

  begin
    ReadMove( XNew, YNew );
    if ((X+XNew) <> X) OR ((Y+YNew) <> Y) then
      begin
        if ((X + XNew) > Mxx-1) then X := Mxx-1
          else if ((X + XNew) < Mnx) then X := Mnx
            else inc( X, XNew );
        if ((Y + YNew) > Mxy-1) then Y := Mxy-1
          else if ((Y + YNew) < Mny) then Y := Mny
            else inc( Y, YNew );
        if ShowMouse then
          begin
            Show( False );
            ShowMouse := True;
            for i := 0 to 3 do
              for j := 0 to 3 do
                ColOld[ i, j ] := GetPixel( X + i, Y + j );
            MPlot( X, Y );
          end;
        OldX := X; OldY := Y;
      end;
  end;

procedure GraphicMouse.Initialize;

   var mStatus : boolean;
       Btn : integer;

   begin
      Reset( mStatus, Btn );
      if mStatus then
        begin
          X := GetMaxX div 2;
          Y := GetMaxY div 2;
          OldX := X; OldY := Y;
          SetLimits( 0, 0, GetMaxX, GetMaxY );
          SetPosition( X, Y );
          MP[0,0] := 255; MP[0,1] := 255;  {     0 1 2 3  }
          MP[0,2] := 255; MP[0,3] := 255;  {  0  # # # #  }
          MP[1,0] := 255; MP[1,1] := 1;    {  1  # * * #  }
          MP[1,2] := 1;   MP[1,3] := 255;  {  2  # *      }
          MP[2,0] := 255; MP[2,1] := 1;    {  3  # #      }
          MP[2,2] := 0;   MP[2,3] := 0;    { Mouse Pointer }
          MP[3,0] := 255; MP[3,1] := 255;
          MP[3,2] := 0;   MP[3,3] := 0;
          Show( True );                    { Transparent = 0 }
        end;                               { White = 255     }
   end;                                    { Black = 1       }

procedure GraphicMouse.ExitSVGA;
   begin
      SetLimits( lo(WindMin)*8, hi(WindMin)*8, lo(WindMax)*8, hi(WindMax)*8);
      regs.AX := $0A;
      regs.BX := 1;
      regs.CX := 6;
      regs.DX := 7;
      intr($33,regs);
      SetPosition( 0, 0 );
      regs.AX := $02;
      intr($33,regs);
   end;


begin
  SetFont( StandardFont );
  SetFontColor( 253, 0, True );
  PresentSeg := 0;
  Sused := False;
  Fused := False;
end.