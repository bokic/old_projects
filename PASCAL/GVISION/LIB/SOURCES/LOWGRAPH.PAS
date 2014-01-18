{**************************************************}
{              LowGraph.pas                        }
{         Low-level graphics routines              }
{     Sergey E. Levov, Moscow,1992-1994            }
{     Last changes: 11 March 1995                  }
{**************************************************}
unit LowGraph;
{$G+,F+,O+,D+}
interface
type

   TPaletteType = record
      Size : word;
      Colors : array[0..255] of byte;
   end;

   TModeInfo = record
      Driver : integer;
      Mode : integer;
      BiosMode : integer;
      SwitchBank : boolean;
   end;

const
   Mode : byte = 0;              {write mode for text drawing}
   SwitchBank : boolean = false;
   EmulateMouseCursor : boolean = false;

var
   ScreenWidth: integer;
   ScreenHeight: integer;
   Planes : integer;
   BitPerPlane : integer;
   BytesPerLine : integer;
   FalseMode : byte;
   CursorAreaSize : word;

{   ConvertPixRow : procedure(var Source,Dest; Width : word; var Palette : TPaletteType);}
   ConvertPixRow : procedure(var Source,Dest; Width : word);
{   ConvertToDib  : procedure(var Source,Dest; Width,Pixels,Planes : word);}
   DrawChar : procedure(X,Y : integer; Width,Height : word; Fore,Back : word;
                      FillBackgr : boolean; Image : pointer);
   ExtractImage : procedure(X1,Y1,X2,Y2 : integer; var Source, Dest);
   MovePixels : procedure(X1,Y1,X2,Y2 : integer; DeltaX,DeltaY : integer);
   SetController : procedure;
   ResetController : procedure;
   GetBlock : procedure(X,Y,SizeX,SizeY : integer; var Bitmap);
   PutBlock : procedure(X,Y : integer; var Bitmap);
   DrawMouseShape : procedure(X,Y : integer; var Shape);

procedure GetVesaModeInfo(Mode : word);
function GetNearestColor(Count : Integer; rgbRed,rgbGreen,rgbBlue : byte) : byte;
procedure ConvertToDib(var Source,Dest; Width,Pixels,Planes : word);
procedure TranslatePalette(var Source,Dest; Width : word; var Palette : TPaletteType);
procedure SetupMethods16;
procedure SetupMethods256;

implementation

{$IFDEF DPMI}
uses WinApi;
{$ENDIF}

type

{$IFDEF DPMI}
  TRealRegs = record
    RealEDI: Longint;
    RealESI: Longint;
    RealEBP: Longint;
    Reserved: Longint;
    RealEBX: Longint;
    RealEDX: Longint;
    RealECX: Longint;
    RealEAX: Longint;
    RealFlags: Word;
    RealES: Word;
    RealDS: Word;
    RealFS: Word;
    RealGS: Word;
    RealIP: Word;
    RealCS: Word;
    RealSP: Word;
    RealSS: Word;
  end;

{$ENDIF}

  TVesaInfo = record
    VESASignature: array[0..3] of Byte;  {'VESA'}
    VESAVersion  : Word;                 {version number}
    OEMStringPtr : Pointer;              {ptr to manufacturer name}
    Capabilities : array[0..3] of Byte;  {capabilities (not used)}
    VideoModePtr : Pointer;              {ptr to list of supported videomodes}
    TotalMemory  : word;                 {number of 64k videomemory blocks}
    Filler       : array[1..238] of byte;
  end;

 TVesaMode=Record
   Attr     : Word;         { Mode Attributes                   }
   WinA     : Byte;         { Window A attributes               }
   WinB     : Byte;         { Window B attributes               }
   Gran     : Word;         { Window granularity in K bytes     }
   WinSiz   : Word;         { Size of window in K bytes         }
   SegA     : Word;         { Segment address of window A       }
   SegB     : Word;         { Segment address of window B       }
   WinFunc  : Procedure;    { Windows positioning function      }
   Bytes    : Word;         { Number of bytes per line          }
   Width    : Word;         { Number of horizontal pixels       }
   Height   : Word;         { Number of vertical pixels         }
   CharW    : Byte;         { Width of character cell           }
   CharH    : Byte;         { Height of character cell          }
   Planes   : Byte;         { Number of memory planes           }
   Bits     : Byte;         { Number of bits per pixel          }
   nBanks   : Byte;         { Number of banks        (not used) }
   Model    : Byte;         { Memory model type                 }
   Banks    : Byte;         { Size of bank           (not used) }
   Pages    : Byte;         { Number of image pages             }
   Reserved : Byte; { The following are for 15,16,24,32 bit colour modes }
   RedMaskSize   : Byte;    { Size of Red mask in bits          }
   RedFieldPos   : Byte;    { Bit position of LSB of Red mask   }
   GreenMaskSize : Byte;    { Size of Green mask in bits        }
   GreenFieldPos : Byte;    { Bit position of LSB of Green mask }
   BlueMaskSize  : Byte;    { Size of Blue mask in bits         }
   BlueFieldPos  : Byte;    { Bit position of LSB of Blue mask  }
   RsvdMaskSize  : Byte;    { Size of Reserved mask in bits     }
   RsvdFieldPos  : Byte;    { Bit pos. of LSB of Reserved mask  }
   DirColModeInf : Byte;    { Direct Colour mode attributes     }
   Filler   : Array[0..215] Of Byte; { Not used - filler        }
 End;

  RgbTriple = record
    rgbRed,
    rgbGreen,
    rgbBlue : byte;
  end;

var
   VesaMode : TVesaMode;
   VesaInfo : TVesaInfo;
   RGBPal256 : array[0..767] of byte;
   MapColor : array[0..15] of word;

const
   Vga16Colors : array[0..15] of RgbTriple =
      (
         (rgbRed :  0; rgbGreen :  0; rgbBlue :  0),
         (rgbRed :  0; rgbGreen :  0; rgbBlue : 40),
         (rgbRed :  0; rgbGreen : 40; rgbBlue :  0),
         (rgbRed :  0; rgbGreen : 40; rgbBlue : 40),
         (rgbRed : 40; rgbGreen :  7; rgbBlue :  7),
         (rgbRed : 40; rgbGreen :  0; rgbBlue : 40),
         (rgbRed : 40; rgbGreen : 30; rgbBlue :  0),
         (rgbRed : 49; rgbGreen : 49; rgbBlue : 49),
         (rgbRed : 26; rgbGreen : 26; rgbBlue : 26),
         (rgbRed :  0; rgbGreen :  0; rgbBlue : 63),
         (rgbRed :  9; rgbGreen : 63; rgbBlue :  9),
         (rgbRed :  0; rgbGreen : 63; rgbBlue : 63),
         (rgbRed : 63; rgbGreen : 10; rgbBlue : 10),
         (rgbRed : 44; rgbGreen :  0; rgbBlue : 63),
         (rgbRed : 63; rgbGreen : 63; rgbBlue : 18),
         (rgbRed : 63; rgbGreen : 63; rgbBlue : 63)
      );



procedure SetBank(NewBank : word); assembler;
asm
   mov   ax, NewBank
   mov   cx, 64
   mul   cx
   mov   cx,VesaMode.Gran
   or    cx,cx
   jz    @@e
   div   cx
   mov   dx, ax
   mov   ax, $4F05
   push  ax
   push  dx
   xor   bx, bx
   int   10h
   pop   dx
   pop   ax
   inc   bx
   int   10h
@@e:
end;

function GetBank : word; near; assembler;
asm
   mov   ax, $4F05
   mov   bx, $100
   int   10h
   mov   ax, dx
end;

procedure GetVesaModeInfo(Mode : word); assembler;
{$IFNDEF DPMI}
asm
        lea     di,VesaInfo
        mov     ax, ds
        mov     es, ax
        mov     ax,$4F00
        int     $10
        lea     di,VesaMode
        mov     cx,Mode
        mov     ax,ds
        mov     es,ax
        mov     ax,$4F01
        int     $10
end;
{$ELSE}
var
  Segment, Selector: Word;
asm
        mov     SwitchBank,true
{$IFOPT G+}
        PUSH    0000H
        PUSH    0100H
{$ELSE}
        XOR     AX,AX
        PUSH    AX
        INC     AH
        PUSH    AX
{$ENDIF}
{ alloc dos memory for data transfer }
        CALL    GlobalDosAlloc
        MOV     Segment,DX
        MOV     Selector,AX
{ get VESA info }
        MOV     DI,OFFSET RealModeRegs
        MOV     WORD PTR [DI].TRealRegs.RealSP, 0
        MOV     WORD PTR [DI].TRealRegs.RealSS, 0
        MOV     WORD PTR [DI].TRealRegs.RealEAX, 4F00H
        MOV     WORD PTR [DI].TRealRegs.RealES, DX
        MOV     WORD PTR [DI].TRealRegs.RealEDI, 0
        MOV     AX,DS
        MOV     ES,AX
        MOV     AX,0300H
        MOV     BX,0010H
        XOR     CX,CX
        INT     31H
{ copy it into VesaInfo variable }
        mov     cx, $100
        lea     di, VesaInfo
        push    ds
        pop     es
        mov     dx, ds
        mov     ds, Selector
        xor     si,si
        cld
        rep     movsb
        mov     ds, dx
{ get current VESA mode info }
        MOV     DI,OFFSET RealModeRegs
        mov     cx, Mode
        mov     dx, Segment
        MOV     WORD PTR [DI].TRealRegs.RealSP, 0
        MOV     WORD PTR [DI].TRealRegs.RealSS, 0
        MOV     WORD PTR [DI].TRealRegs.RealEAX, 4F01H
        mov     word ptr [di].TrealRegs.RealECX, cx
        MOV     WORD PTR [DI].TRealRegs.RealES, DX
        MOV     WORD PTR [DI].TRealRegs.RealEDI, 0
        MOV     AX,DS
        MOV     ES,AX
        MOV     AX,0300H
        MOV     BX,0010H
        XOR     CX,CX
        INT     31H
{ copy it }
        mov     cx, $100
        lea     di, VesaMode
        push    ds
        pop     es
        mov     dx, ds
        mov     ds, Selector
        xor     si,si
        cld
        rep     movsb
        mov     ds, dx
{ free memory associated with selector }
        PUSH    Selector
        CALL    GlobalDosFree
end;
{$ENDIF}

procedure SetController16; assembler;
asm
       mov     dx,$3CE
       mov     ax,$0A05              { set write mode 2, read mode 1 }
       out     dx,ax
       mov     ah,byte ptr Mode      { use current write mode }
       mov     al,3
       out     dx,ax
       mov     ax,7
       out     dx,ax
end;

procedure ResetController16; assembler;
asm
       mov     dx,$3C4
       mov     ax,$0F02
       out     dx,ax
       mov     dx,$3CE
       mov     ax,$FF08
       out     dx,ax
       mov     ax,5
       out     dx,ax
       mov     ax,3
       out     dx,ax
       mov     ax,$0F07
       out     dx,ax
end;


procedure MovePixels16(X1,Y1,X2,Y2 : integer; DeltaX,DeltaY : integer);
assembler;
var
   Nx1,Ny1,Nx2,Ny2 : word;
   StartMask,EndMaskl,EndMaskR : word;
   RowLen,NumOfLines : word;
   IncrMem,BPLine,SwapMask : word;
   LastMask,SourceShift,TargetShift : byte;
   Source,Target,Work : pointer;
   SaveDS : word;
   OldBank,CurBank,TargetBank,SourceBank : word;
   Switch : byte;
   NextLine : word;
asm
       push    ds
       mov     SaveDS,ds
       mov     al,SwitchBank
       mov     Switch,al
       mov     ax,BytesPerLine
       mov     BPLine,ax
       mov     ax,DeltaX
{calculate new X coordinates. Assume all coords are inside screen area}
       mov     bx,X1
       add     bx,ax
       mov     Nx1,bx           {save new x1}
       mov     bx,X2
       add     bx,ax
       mov     Nx2,bx           {save new x2}
{ now calculate new y coords}
       mov     ax,DeltaY
       mov     bx,y1
       add     bx,ax
       mov     Ny1,bx           {save new y1}
       mov     bx,y2
       add     bx,ax
       mov     Ny2,bx
       sub     bx,Ny1
       inc     bx
       mov     NumOfLines,bx    {number of lines to move}
       test    Switch,true
       jnz     @@MoveBits0
       mov     al,byte ptr X1
       mov     ah,byte ptr Nx1
       and     ax,$0707
       cmp     ah,al
       jne     @@MoveBits
       jmp     @@MoveBytes
@@MoveBits0:
       call    GetBank
       mov     OldBank,ax            { save current bank }
       mov     CurBank,ax
@@MoveBits:
       mov     cl,3
       mov     bx,X2
       mov     ax,X1
       sub     bx,ax
       mov     ax,bx
       shr     bx,cl
       inc     bx
@@Bits0:
       mov     RowLen,bx        { bytes in one row }
{ establish addressing }
       mov     SwapMask,0
       mov     dx,BPLine
       mov     ax,DeltaY
       test    ax,$8000
       jz      @@Bits2
@@Bits1:
       mov     ax,y1             {DeltaY < 0 or Ny1 > y2 }
       mul     dx
       mov     si,x1
       shr     si,cl
       add     si,ax
       adc     dx,0
       test    Switch,true
       jz      @@2
       mov     SourceBank,dx
@@2:   mov     dx, BPLine
       mov     ax,Ny1
       mul     dx
       mov     di,Nx1
       shr     di,cl
       add     di,ax
       adc     dx,0
       test    Switch,true
       jz      @@3
       mov     TargetBank,dx
@@3:
       lea     dx,@@RowForw
       mov     NextLine,dx
       mov     bx,BPLine
       mov     IncrMem,bx
       jmp     @@Bits4
@@Bits2:
       mov     ax,Ny1
       cmp     ax,y2
       ja      @@Bits1
       mov     ax,y2
       mul     dx
       mov     si,x1
       shr     si,cl
       add     si,ax
       adc     dx,0
       test    Switch,true
       jz      @@0
       mov     SourceBank,dx
@@0:   mov     dx,BPLine
       mov     ax,Ny2
       mul     dx
       mov     di,Nx1
       shr     di,cl
       add     di,ax
       adc     dx,0
       test    Switch,true
       jz      @@1
       mov     TargetBank,dx
@@1:
       lea     dx,@@RowBack
       mov     NextLine,dx
       mov     bx,BPLine
       not     bx
       inc     bx
       mov     IncrMem,bx
@@Bits4:
       mov     ax,SegA000
       mov     ds,ax
       mov     es,ax
       cld
       mov     Source.word[0],si        {save source and target pointers}
       mov     Source.word[2],ds
       mov     Target.word[0],di
       mov     Target.word[2],es
{allocate temporary buffer }
       sub     sp,BPLine
       mov     Work.word[0],sp
       mov     Work.word[2],ss
       mov     ax,x2
       sub     ax,x1
       mov     cx,$FF07
       and     cl,al
       xor     cl,7
       shl     ch,cl
       mov     LastMask,ch
       mov     cl,3
       mov     bx,x1
       and     bl,7
       mov     SourceShift,bl   {shift when move bytes into buffer}
       mov     bx,Nx1
       xor     bl,7
       inc     bl
       and     bl,7
       mov     TargetShift,bl    {shift when move bytes back into memory}
       mov     cl,bl
       mov     ch,LastMask
       mov     bx,$FF           { 00000000 11111111}
       mov     al,ch            { 11110000 }
       cbw                      { 11111111 11110000 }
       cmp     RowLen,1
       jne     @@Bits5
       mov     bl,ch            { 00000000 11110000 }
       mov     ah,ch
       xor     al,al            { 11110000 00000000 }
@@Bits5:
       shl     ax,cl
       shl     bx,cl
       mov     bl,al            { al=endmask right }
       mov     al,8             { ah=endmask left  }
       mov     EndMaskL,ax
       mov     ah,bl
       mov     EndMaskR,ax
       mov     ah,bh            { bh=startmask }
       mov     StartMask,ax
{ set up graphics controller }
       mov     dx,$3CE
       mov     ax,5             { read mode 0, write mode 0}
       out     dx,ax
       mov     ax,3             { ah := value for data rotate/function}
       out     dx,ax
{ loop for each row move }
@@Bits6:
       mov     ax,0ff08h        { ah := 0ffh (value for bit mask reg)}
       out     dx,ax
       mov     ax,0802h         { value for map mask reg}
       mov     bx,0304h         { plane #3, read map select}
@@Bits7:
       push    ax
       push    bx
       lds     si,Source        { load pointers }
       test    Switch,true
       jz      @@7_1
       mov     dx,SourceBank
       cmp     dx,CurBank               {need to switch source bank?}
       je      @@7_1                    {no}
       call    @@ChangeBank
@@7_1: les     di,Work
       mov     dx,$3C4          { sequence i/o port) }
       out     dx,ax
       mov     dx,$3CE
       mov     ax,bx
       out     dx,ax
       mov     bx,RowLen
       mov     cl,SourceShift
       or      cl,cl            { need to shift? }
       jz      @@Bits9             { no }

@@Bits8:
       lodsw                    { non-aligned block }
       dec     si
       rol     ax,cl
       stosb
       dec     bx
       jnz     @@Bits8
       jmp     @@Bits10

@@Bits9:
       mov     cx,bx            { move byte-aligned block }
       shr     cx,1
       rep     movsw
       adc     cx,0
       rep     movsb

@@Bits10:
       lds     si,Work
       les     di,Target
       test    Switch,true
       jz      @@11
       push    dx
       mov     dx,TargetBank
       cmp     dx,CurBank
       je      @@10
       call    @@ChangeBank
@@10:  pop     dx
@@11:  mov     bx,RowLen
       mov     ch,LastMask
       mov     cl,TargetShift
       cmp     cx,$FF00
       jne     @@Bits11             { non-aligned }
       mov     cx,bx
       shr     cx,1
       rep     movsw
       adc     cx,0
       rep     movsb
       jmp     @@Bits16
@@Bits11:
       mov     ax,StartMask     { eg. 00000111 }
       out     dx,ax
       lodsw                    { eg. 10101110 11111111 }
       dec     si
       or      cl,cl            { shift? }
       jnz     @@Bits12             { yes }
       dec     bx
       jnz     @@Bits13
       jmp     @@Bits15
@@Bits12:
       rol     ax,cl            { eg. 01110111 11111101 }
       mov     ch,es:[di]       { latch byte }
       mov     es:[di],ah
       inc     di
       dec     bx
@@Bits13:
       dec     bx
       jng     @@Bits15
       push    ax
       mov     ax,0ff08h
       out     dx,ax
       pop     ax
@@Bits14:
       mov     es:[di],al
       inc     di
       lodsw
       dec     si
       rol     ax,cl
       dec     bx
       jnz     @@Bits14
@@Bits15:
       mov     bx,ax
       mov     ax,EndMaskl
       out     dx,ax
       mov     ch,es:[di]
       mov     es:[di],bl
       inc     di
       mov     ax,EndMaskR
       out     dx,ax
       mov     ch,es:[di]
       mov     es:[di],bh
       pop     bx
       pop     ax
       shr     ah,1
       dec     bh
       js      @@Bits16
       jmp     @@Bits7
@@Bits16:
{       mov     ax,IncrMem
       mov     bx,1
       test    ax,$8000
       jz      @@16
       mov     bx,-1
@@16:  add     Target.word[0],ax
       jnc     @@16_1
       add     TargetBank,bx
@@16_1:
       add     Source.word[0],ax
       jnc     @@16_2
       add     SourceBank,bx
@@16_2:}
       call    [NextLine]
       dec     NumOfLines
       jz      @@Bits19
       mov     dx,$3CE
       jmp     @@Bits6
@@Bits19:
       add     sp,BPLine
       jmp     @@exit

@@RowForw:
       mov     ax,BPLine
       add     Source.word[0],ax          {modify source pointer}
       jnc     @@a1
       inc     SourceBank
@@a1:  add     Target.word[0],ax          {modify target pointer}
       jnc     @@a2
       inc     TargetBank
@@a2:  retn

@@RowBack:
       mov     ax,BPLine
       sub     Source.word[0],ax
       jnc     @@a3
       dec     SourceBank
@@a3:  sub     Target.word[0],ax
       jnc     @@a4
       dec     TargetBank
@@a4:  retn

@@MoveBytes:                      {move bytes without shift op}
       mov     cl,3
       mov     bx,X2
       mov     ax,X1
       shr     bx,cl
       shr     ax,cl
       sub     bx,ax
       inc     bx
       mov     RowLen,bx          { bytes in one row }
{ establish addressing }
       mov     SwapMask,1
       mov     dx,BPLine
       mov     ax,DeltaY
       test    ax,$8000
       jz      @@Bytes2
@@Bytes1:
       mov     ax,y1             {DeltaY < 0 or Ny1 > y2 or Nx1 < x1 }
       mul     dx
       mov     si,x1
       shr     si,cl
       add     si,ax
       mov     dx, BPLine
       mov     ax,Ny1
       mul     dx
       mov     di,Nx1
       shr     di,cl
       add     di,ax
       mov     bx,BPLine
       sub     bx,RowLen
       mov     IncrMem,bx
       cld
       jmp     @@Bytes4

@@Bytes2:
       mov     ax,Ny1
       cmp     ax,y2
       ja      @@Bytes1
       cmp     ax,y1
       ja      @@Bytes3
       mov     ax,DeltaX
       test    ax,$8000
       jnz     @@Bytes1
       mov     ax,y1
       mul     dx
       mov     si,x2
       shr     si,cl
       add     si,ax
       mov     dx,BPLine
       mov     ax,Ny1
       mul     dx
       mov     di,Nx2
       shr     di,cl
       add     di,ax
       std
       mov     SwapMask,-1
       mov     bx,BPLine
       add     bx,RowLen
       mov     IncrMem,bx
       jmp     @@Bytes4
@@Bytes3:
       mov     ax,y2
       mul     dx
       mov     si,x1
       shr     si,cl
       add     si,ax
       mov     dx,BPLine
       mov     ax,Ny2
       mul     dx
       mov     di,Nx1
       shr     di,cl
       add     di,ax
       cld
       mov     bx,BPLine
       not     bx
       inc     bx
       sub     bx,RowLen
       mov     IncrMem,bx
@@Bytes4:
       mov     ax,SegA000
       mov     ds,ax
       mov     es,ax
       mov     ax,x2
       mov     cx,$FF07
       and     cl,al
       xor     cl,7
       shl     ch,cl            {mask for last byte}
       mov     cl,8
       mov     EndMaskl,cx
       push    cx
       mov     bx,x1
       mov     cx,$FF07
       and     cl,bl
       shr     ch,cl            {mask for start byte}
       mov     cl,8
       mov     StartMask,cx
       pop     cx
       test    SwapMask,$8000
       jz      @@Noswap
       mov     ax,StartMask             {swap start and end masks}
       xchg    EndMaskl,ax
       mov     StartMask,ax

{ in general case we need 3 different operations to move entire row:
  1. first byte - move only bits enabled with StartMask;
  2. some middle bytes will be moved entirely;
  3. last byte - move only bits enabled with EndMask;
  But if first or last byte mask is $ff it is the same as op 2.
  So we will use start mask and end mask as flags also: if mask = 0
  then skip specific operation                                      }
@@Noswap:
       cmp     RowLen,1
       jne     @@Bytes5
       mov     ax,StartMask
       and     ax,EndMaskL
       mov     byte ptr StartMask,al
       mov     EndMaskL,0
@@Bytes5:
       mov     ax,StartMask
       xor     ah,$FF
       jnz     @@Bytes6
       mov     StartMask,ax
@@Bytes6:
       mov     ax,EndMaskl
       xor     ah,$FF
       jnz     @@Bytes7
       mov     EndMaskl,ax
@@Bytes7:
       mov     cx,RowLen
       mov     ax,StartMask
       or      ah,ah
       jz      @@Bytes10               {don't mask start byte}
{move start byte}
@@Bytes8:
       mov     dx,$3CE            {graphics controller i/o port}
       out     dx,ax              {set up mask ah into bit mask reg (8)}
       mov     ax,5               {read mode 0, write mode 0, al - mode reg}
       out     dx,ax
       mov     bx,$0802           {value for map mask reg = 1000b}
       mov     ax,$0304           {plane #3 ,'read map select' reg}

@@Bytes9:
       mov     dx,$3CE
       out     dx,ax              {set plane into 'read map select'}
       mov     dx,$3C4            {sequence i/o port}
       push    ax
       mov     ax,bx
       out     dx,ax
       mov     al,ds:[si]         {get start byte}
       or      es:[di],al         {latch destination byte}
       mov     es:[di],al
       pop     ax
       shr     bh,1
       dec     ah
       jns     @@Bytes9
       add     di,SwapMask
       add     si,SwapMask
       dec     cx
       jcxz    @@Bytes13                {jump if entire row moved}

@@Bytes10:
       test    EndMaskL.byte[1],$FF
       jz      @@Bytes11
       dec     cx                  {preserve last byte}
       jcxz    @@Bytes12                {if no more bytes}

{move middle bytes}

@@Bytes11:
       mov     dx,$3C4
       mov     ax,$0F02            {enable all planes}
       out     dx,ax
{ found in TEGL sources:
   set bit mask. The book is incorrect in stating that
   write mode 1 ignores the bit mask. - ? }
       mov     dx,$3CE
       mov     ax,$0008            {ignore bits, use latches}
       out     dx,ax
       mov     ax,$0105             {read mode 0, write mode 1}
       out     dx,ax
       rep     movsb
{move last byte}

@@Bytes12:
       mov     ax,EndMaskL
       or      ah,ah
       jz      @@Bytes13
       mov     cx,1
       jmp     @@Bytes8

@@Bytes13:
       dec     NumOfLines          {all done?}
       jz      @@exit              {yes - reset controller and exit}
       add     si,IncrMem
       add     di,IncrMem
       jmp     @@Bytes7

@@ChangeBank:
       mov     CurBank,dx
       push    ax
       push    bx
       push    cx
       push    ds
       mov     ds,SaveDS
       push    dx
       call    SetBank
       pop     ds
       pop     cx
       pop     bx
       pop     ax
       retn

@@exit:
       pop     ds
       cld
       test    Switch,true
       jz      @@e
       push    OldBank
       call    SetBank
@@e:   call    ResetController16
end;

procedure MovePixels256(X1,Y1,X2,Y2 : integer; DeltaX,DeltaY : integer); assembler;
var
   Nx1,Ny1,Nx2,Ny2 : word;
   SaveDS,RowLen,NumOfLines : word;
   IncrMem,BPLine : word;
   OldBank,CurBank,SourceBank,TargetBank : word;
   NextLine : word;
   Source,Target,Work : pointer;

asm
       push    ds
       mov     SaveDS,ds
       mov     ax,BytesPerLine
       mov     BPLine,ax
       mov     ax,DeltaX
{calculate new X coordinates. Assume all coords are inside screen area}
       mov     bx,X1
       add     bx,ax
       mov     Nx1,bx           {save new x1}
       mov     bx,X2
       add     bx,ax
       mov     Nx2,bx           {save new x2}
       sub     bx,Nx1
       inc     bx
       mov     RowLen,bx        {bytes in one moved row}
       call    GetBank
       mov     OldBank,ax            { save current bank }
       mov     CurBank,ax
{ now calculate new y coords}
       mov     ax,DeltaY
       mov     bx,y1
       add     bx,ax
       mov     Ny1,bx           {save new y1}
       mov     bx,y2
       add     bx,ax
       mov     Ny2,bx
       sub     bx,Ny1
       inc     bx
       mov     NumOfLines,bx    {number of lines to move}
       mov     bx,BPLine
{ establish addressing }
       test    DeltaY,$8000
       jz      @@2
@@1:
       mov     ax,Y1
       mov     si,X1
       mul     bx                    { dx -  bank for read data }
       add     si,ax
       adc     dx,0
       mov     SourceBank,dx
       mov     ax,Ny1
       mov     di,Nx1
       mul     bx                    { dx - bank for write data }
       add     di,ax
       adc     dx,0
       mov     TargetBank,dx
       lea     dx,@@RowForw
       mov     NextLine,dx
       sub     bx,RowLen
@@1_1:
       mov     IncrMem,bx
       mov     es,SegA000
       mov     Source.word[0],si        {save source and target pointers}
       mov     Source.word[2],es
       mov     Target.word[0],di
       mov     Target.word[2],es
{allocate temporary buffer }
       sub     sp,BPLine
       mov     Work.word[0],sp
       mov     Work.word[2],ss
       jmp     @@a
@@2:
       mov     ax,Ny1
       cmp     ax,Y2
       ja      @@1
       cmp     ax,Y1
       ja      @@3
       jmp     @@1
@@3:   mov     ax,Y2
       mul     bx
       mov     si,X1
       add     si,ax
       adc     dx,0
       mov     SourceBank,dx
       mov     ax,Ny2
       mul     bx
       mov     di,Nx1
       add     di,ax
       adc     dx,0
       mov     TargetBank,dx
       add     bx,RowLen
       lea     dx,@@RowBack
       mov     NextLine,dx
       jmp     @@1_1
{ move bytes from source to temp buffer }
@@a:   mov     cx,RowLen
       les     di,Work
       lds     si,Source
       mov     dx,SourceBank
@@a_0: cmp     dx,CurBank               {need to switch source bank?}
       je      @@a_1                    {no}
       call    @@ChangeBank
@@a_1: test    si,1             { Videomem addr is word aligned? }
       jz      @@a_3            { no }
       call    @@MoveByteFrom
       dec     cx
@@a_3: push    cx
       shr     cx,1
       jz      @@a_41
@@a_31:
       cmp     dx,CurBank
       je      @@a_4
       call    @@ChangeBank
@@a_4: mov     ax,ds:[si]
       stosw
       add     si,2
       adc     dx,0
       loop    @@a_31
@@a_41:
       pop     cx
       test    cx,1
       jz      @@a_51
       cmp     dx,CurBank
       je      @@a_5
       call    @@ChangeBank
@@a_5:
       call    @@MoveByteFrom
{ move from temp buffer to target area }
@@a_51:
       mov     cx,RowLen
       lds     si,Work
       les     di,Target
       mov     dx,TargetBank
@@a_6: cmp     dx,CurBank               {need to target source bank?}
       je      @@a_7                    {no}
       call    @@ChangeBank
@@a_7: test    di,1
       jz      @@a_71
       call    @@MoveByteTo
       dec     cx
@@a_71:
       push    cx
       shr     cx,1
       jz      @@a_77
@@a_75:
       cmp     dx,CurBank               {need to target source bank?}
       je      @@a_72                   {no}
       call    @@ChangeBank
@@a_72:
       lodsw
       mov     es:[di],ax
       add     di,2
       adc     dx,0
@@a_73:
       loop    @@a_75                      {repeat until all bytes moved}
@@a_77:
       pop     cx
       test    cx,1
       jz      @@a_74
       cmp     dx,CurBank
       je      @@a_76
       call    @@ChangeBank
@@a_76:
       call    @@MoveByteTo
@@a_74:
       dec     NumOfLines
       jz      @@exit
       call    [NextLine]
       jmp     @@a                        {go to next row move}

@@RowForw:
       mov     ax,BPLine
       add     Source.word[0],ax          {modify source pointer}
       jnc     @@a1
       inc     SourceBank
@@a1:  add     Target.word[0],ax          {modify target pointer}
       jnc     @@a2
       inc     TargetBank
@@a2:  retn

@@RowBack:
       mov     ax,BPLine
       sub     Source.word[0],ax
       jnc     @@a3
       dec     SourceBank
@@a3:  sub     Target.word[0],ax
       jnc     @@a4
       dec     TargetBank
@@a4:  retn

@@ChangeBank:
       mov     CurBank,dx
       push    cx
       push    dx
       push    ds
       mov     ds,SaveDS
       push    dx
       call    SetBank
       pop     ds
       pop     dx
       pop     cx
       retn

@@MoveByteFrom:
       mov     al,ds:[si]       { yes - move one byte }
       inc     si
       jnz     @@a_2                    {if stay in the same source bank}
       inc     dx
@@a_2: stosb
       retn

@@MoveByteTo:
       lodsb
       mov     es:[di],al
       inc     di
       jnz     @@a5
       inc     dx
@@a5:  retn

@@exit:
       add     sp,BPLine
       pop     ds
       cld
       push    OldBank
       call    SetBank
end;

procedure ExtractImage16(X1,Y1,X2,Y2 : integer; var Source,Dest); assembler;
var
   SourceLines,SourceRowLen : word;
   DestLines,DestRowLen : word;
   DestLastMask : byte;
asm
       push    ds
       lds     si,Source
       les     di,Dest
       mov     cl,3
       cld
       lodsw                       { row length for source image}
       inc     ax
       mov     bx,ax
       shr     ax,cl
       test    bx,7
       je      @@0
       inc     ax
@@0:   mov     SourceRowLen,ax
       lodsw                       { rows count }
       mov     SourceLines,ax

{ prepare image header for Dest buffer }
       mov     ax,x2               { bytes per row }
       sub     ax,x1
       stosw
       inc     ax
       mov     bx,ax
       push    bx
       mov     cl,3
       shr     ax,cl
       test    bl,7
       je      @@1
       inc     ax
@@1:   mov     DestRowLen,ax
       mov     ax,y2               { rows }
       sub     ax,y1
       mov     DestLines,ax
       stosw
       pop     ax
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
       shl     dx,2                { * 4 bit planes }
       mul     dx
       shr     bx,3
       add     bx,ax
       add     si,bx                { ds:si now points to first moved byte }
       and     cl,7                 { cl - shift count }
       mov     ch,DestLastMask
{ copy from Source to Dest }
       mov     dx,DestLines
@@2:   mov     ax,4                 { bit planes count }
@@3:   push    ax
       push    si
       mov     bx,DestRowLen
@@4:   lodsw                        { load word }
       dec     si
       rol     ax,cl                { prepare byte }
       stosb                        { save it }
       dec     bx                   { entire bit plane moved ? }
       jnz     @@4                  { no - continue }
       and     es:[di-1],ch
       pop     si
       add     si,SourceRowLen      { next bit plane addr }
       pop     ax
       dec     ax                   { all bit planes ? }
       jnz     @@3                  { no - continue }
       dec     dx                   { all lines? }
       jns     @@2                  { no - continue }
{ all done }
       pop     ds
end;

procedure ExtractImage256(X1,Y1,X2,Y2 : integer; var Source,Dest); assembler;
var
   SourceLines,SourceRowLen : word;
   DestLines,DestRowLen : word;
   DestLastMask : byte;
asm
       push    ds
       lds     si,Source
       les     di,Dest
       cld
       lodsw                       { row length for source image}
       inc     ax
       mov     SourceRowLen,ax
       lodsw                       { rows count }
{ prepare image header for Dest buffer }
       mov     ax,x2               { bytes per row }
       sub     ax,x1
       stosw
       inc     ax
       mov     DestRowLen,ax
       mov     ax,Y2
       sub     ax,Y1
       stosw
       mov     Destlines,ax        { rows }
{ calculate start addr into source buffer }
       mov     ax,SourceRowLen
       mov     cx,Y1
       mul     cx
       add     ax,X1
       add     si,ax
{ move bytes from source to dest }
@@1:   push    si
       mov     cx,DestRowLen
       rep     movsb
       pop     si
       add     si,SourceRowLen
       dec     DestLines            { all done? }
       jns     @@1                  { no }
       pop     ds
end;

procedure DrawChar16(X,Y : integer; Width,Height : word; Fore,Back : word;
                      FillBackgr : boolean; Image : pointer); assembler;
var
   RowLen : word;
   MemInc : word;
   WidthMask : word;
   Shift : word;
   Count : word;
   OldBank : word;
   CurBank : word;
   SaveDS : word;
   Switch : boolean;
asm
       cld
       mov     SaveDS,ds
       mov     es,SegA000            { calculate start address for drawing }
       call    GetBank
       mov     OldBank,ax            { save current bank }
       mov     CurBank,ax
       mov     al,byte ptr SwitchBank
       mov     Switch,al
       mov     ax,Y
       mov     di,X
       mov     dx,BytesPerLine
       mul     dx                    { dx - start bank for drawing }
       shr     di,3
       add     di,ax
       adc     dx,0
       cmp     dx,CurBank            { out of current window boundary? }
       je      @@0                    { no }
       test    byte ptr Switch, true
       je      @@0
       push    dx
       mov     CurBank,dx
       call    SetBank               { move memory window to new position }
@@0:   mov     ax,Width              { calculate bytes per row }
       mov     bx,ax
       shr     ax,3
       test    bx,7
       je      @@1
       inc     ax
@@1:   mov     RowLen,ax             { calc additional mask }
       mov     cx,bx
       and     cl,7
       xor     cl,7
       inc     cl
       and     cl,7
       mov     ax,$00FF
       shl     al,cl
       mov     cx,X
       and     cl,7                  { calculate shift value and end mask }
       xor     cl,7
       inc     cl
       and     cl,7
       mov     ch,$FF
       shl     ch,cl
       mov     Shift,cx
       shl     ax,cl
       mov     WidthMask,ax
       mov     dx,$3CE
       mov     ax,BytesPerLine
       sub     ax,RowLen
       mov     MemInc,ax             { increment for video memory pointer }
       lds     si,Image              { load char image pointer }
       mov     bl,byte ptr Fore
       mov     bh,byte ptr Back
       test    X,7
       jne     @@NotAligned

{ write byte-aligned character }
       mov     al,8
@@a1:  mov     cx,RowLen
@@a2:  dec     cx
       mov     ah,[si]               { pattern }
       out     dx,ax                 { update bit mask reg }
       and     es:[di],bl            { update foreground pixels }
       test    byte ptr FillBackgr,true
       je      @@a3
       not     ah                    { invert pattern }
       or      cx,cx                 { last byte ? }
       jne     @@a2a                 { no }
       and     ah,WidthMask.byte[0]
@@a2a: out     dx,ax
       and     es:[di],bh
@@a3:  inc     di
       inc     si
       or      cx,cx
       jnz     @@a2                  { draw next byte }
       add     di,MemInc
       jnc     @@a4
       test    byte ptr Switch, true
       je      @@a4
       inc     CurBank
       push    ax
       push    bx
       push    dx
       push    ds
       push    CurBank
       mov     ds,SaveDs
       call    SetBank
       pop     ds
       pop     dx
       pop     bx
       pop     ax
@@a4:  dec     Height
       jnz     @@a1                  { draw next line }
       jmp     @@exit

{ write non-aligned chars }
@@NotAligned:
       mov     cx,RowLen
       mov     Count,cx
       dec     Count
       mov     cx,Shift              { ch - mask, cl -shift count }
{ draw left side of char }
       shl      ah,8
@@na2: mov     al,[si]
       shl     ax,cl                 { ah - bits for pattern byte left side }
       mov     al,8
       out     dx,ax                 { update bit mask reg }
       and     es:[di],bl            { update foreground pixels }
       test    byte ptr FillBackgr,true
       je      @@na3
       not     ch                    { need to update background pixels }
       not     ah
       and     ah,ch
       test    Count,$FFFF       { processing with last byte? }
       jnz     @@na_                 { no }
       and     ah,WidthMask.byte[1]
@@na_: out     dx,ax
       and     es:[di],bh
@@na3:
       inc     di
       inc     si

{ processing some middle bytes here }
       mov     ah,[si-1]
       mov     cx,Shift
       test    Count,$FFFF
       jz      @@Right
       dec     Count
       jmp     @@na2
{ right side of char }
@@Right:
       mov     al,[si]
       shl     ax,cl
       mov     al,8
       and     ah,ch
       out     dx,ax                 { update bit mask reg }
       and     es:[di],bl            { update foreground pixels }
       test    byte ptr FillBackgr,true
       je      @@na5
       not     ah
       and     ah,ch                    { need to update background pixels }
       and     ah,WidthMask.byte[0]
       out     dx,ax
       and     es:[di],bh
       xor     cx,cx
@@na5: add     di,MemInc
       jnc     @@na6
       test    byte ptr Switch,true
       je      @@na6
       inc     CurBank
       push    ax
       push    bx
       push    dx
       push    ds
       push    CurBank
       mov     ds,SaveDS
       call    SetBank
       pop     ds
       pop     dx
       pop     bx
       pop     ax

@@na6: dec     Height
       jnz     @@NotAligned

@@exit:
       mov     ds,SaveDS
       test    byte ptr Switch,true
       je      @@done
       push    OldBank
       call    SetBank
@@done:
end;

procedure DrawChar256(X,Y : integer; Width,Height : word; Fore,Back : word;
                      FillBackgr : boolean; Image : pointer); assembler;
var
   RowLen : word;
   MemInc : word;
   Count : word;
   OldBank : word;
   CurBank : word;
   SaveDS : word;
asm
       cld
       mov     SaveDS,ds
       mov     es,SegA000            { calculate start address for drawing }
       mov     ax,BytesPerLine
       sub     ax,Width
       mov     MemInc,ax             { increment for video memory pointer }
       call    GetBank
       mov     OldBank,ax            { save current bank }
       mov     CurBank,ax
       mov     ax,Y
       mov     di,X
       mov     dx,BytesPerLine
       mul     dx                    { dx - start bank for drawing }
       add     di,ax
       adc     dx,0
       cmp     dx,CurBank            { out of current window boundary? }
       je      @@0                   { no }
       push    dx
       mov     CurBank,dx
       call    SetBank               { move memory window to new position }

@@0:   lds     si,Image              { load char image pointer }
       mov     bl,byte ptr Fore
       mov     bh,byte ptr Back

@@1:   mov     dx,Width
@@2:   lodsb                         { load current byte }
       mov     cx,8
       cmp     dx,cx
       jge     @@3
       mov     cx,dx
@@3:   sub     dx,cx
@@4:   rcl     al,1                  { extract one bit }
       jnc     @@5
       mov     es:[di],bl            { if carry = 1 set foreground pixel }
       jmp     @@6
@@5:   test    byte ptr FillBackgr,true
       je      @@6
       mov     es:[di],bh            { else set background pixel }
@@6:   inc     di
       jnz     @@6_a
       inc     CurBank
       push    ax
       push    bx
       push    cx
       push    dx
       push    ds
       push    CurBank
       mov     ds,SaveDs
       call    SetBank
       pop     ds
       pop     dx
       pop     cx
       pop     bx
       pop     ax
@@6_a: loop    @@4
       or      dx,dx                 { all done with current row?}
       jnz     @@2                   { no - draw pixels from next byte}
       add     di,MemInc
       jnc     @@7
       inc     CurBank
       push    bx
       push    ds
       push    CurBank
       mov     ds,SaveDs
       call    SetBank
       pop     ds
       pop     bx

@@7:   dec     Height
       jnz     @@1                   { draw next line }
@@exit:
       mov     ds,SaveDS
       push    OldBank
       call    SetBank
end;

function GetNearestColor(Count : integer; rgbRed,rgbGreen,rgbBlue : byte) : byte;

var
   i,k,Best : word;
   a,b,c : LongInt;
   Distance,BestDistance : LongInt;
{   RGBPal : array[0..255] of RGBTriple;}
   RGBP : array[0..255] of RGBTriple absolute rgbPal256;

begin
   Best := 0;
   BestDistance := $0FFFFFFF;
   for i := 0 to Count-1 do begin
{      if Count <= 16 then k := MapColor[i]
      else k := i;                         }
      if Count > 16 then begin
         a := RGBP[i].rgbRed - (rgbRed shr 2);
         b := RGBP[i].rgbGreen - (rgbGreen shr 2);
         c := RGBP[i].rgbBlue - (rgbBlue shr 2);
      end else begin
         a := Vga16Colors[i].rgbRed - (rgbRed shr 2);
         b := Vga16Colors[i].rgbGreen - (rgbGreen shr 2);
         c := Vga16Colors[i].rgbBlue - (rgbBlue shr 2);
      end;
      Distance := (a * a) + (b * b) + (c * c);
      if Distance <= BestDistance then begin
{         if Count <= 16 then Best := i
         else Best := k;}
         Best := i;
         BestDistance := Distance;
      end;
   end;
   GetNearestColor := byte(Best);
end;

procedure TranslatePalette(var Source,Dest; Width : word; var Palette : TPaletteType); assembler;
asm
        push   ds
        les    di,Source        { array of pixel's colors (byte per pixel) }
        mov    cx,Width
        lds    bx,Palette
        add    bx,2
@@2:    mov    al,es:[di]       { load color value }
        xlat                    { convert it to Borland' color set }
        stosb                   { and store }
        loop   @@2
        pop    ds
end;
procedure ConvertPixRow16(var Source,Dest; Width : word{; var Palette : TPaletteType}); assembler;
var
   i : word;
asm
(*
{ first convert colors }
        push   ds
        les    di,Source        { array of pixel's colors (byte per pixel) }
        mov    cx,Width
        lds    bx,Palette
        add    bx,2
@@2:    mov    al,es:[di]       { load color value }
        xlat                    { convert it to Borland' color set }
        stosb                   { and store }
        loop   @@2
*)
{ calculate scan line width in bytes }
        push   ds
        mov    ax,Width
        shr    ax,3
        test   Width,7
        je     @@3
        inc    ax
@@3:    mov    cx,3             { bit planes count }
@@4:    push   cx
        push   ax
        lds    si,Source
        les    di,Dest
        mul    cx               { calc offset to current bit plane }
        mov    bx,ax
        mov    dx,Width
@@5:    mov    cx,8
@@6:    ror    byte ptr [si],1           { extract one bit }
        rcl    byte ptr es:[di+bx],1     { and place it into current bit plane }
        inc    si
        dec    dx               { all done with current bit plane }
        jz     @@7              { yes }
        loop   @@6
        inc    di               { fill in next byte in current bit plane }
        jmp    @@5
@@7:    dec    cx
        jz     @@8
        shl    byte ptr es:[di+bx],cl
@@8:    pop    ax
        pop    cx
        dec    cx               { all bit planes? }
        jns    @@4              { no - continue }
        pop    ds
end;

procedure ConvertPixRow256(var Source,Dest; Width : word{; var Palette : TPaletteType}); assembler;
var
   i : word;
asm
(*
{ first convert colors }
        push   ds
        les    di,Source        { array of pixel's colors (byte per pixel) }
        mov    cx,Width
        lds    bx,Palette
        add    bx,2
@@2:    mov    al,es:[di]       { load color value }
        xlat                    { convert it to Borland' color set }
        stosb                   { and store }
        loop   @@2*)
{ copy from source to dest }
        push   ds
        lds    si,Source
        les    di,Dest
        mov    cx,Width
        rep    movsb
        pop    ds
end;

procedure ConvertToDib(var Source,Dest; Width,Pixels,Planes : word); assembler;
var
   BPLine : word;
asm
         push   ds
         mov    ax,Width
         div    Pixels
         or     dx,dx
         jz     @@1
         inc    ax
@@1:     mov    cx,ax
         les    di,Source
         lds    si,Dest
         cmp    Planes,1
         jne    @@1_1
         xor    ax,ax
@@1_1:   mov    BPLine,ax
@@2:     push   cx
         xor    bx,bx
         mov    al,es:[di]
         add    bx,BPLine
         mov    ah,es:[di+bx]
         add    bx,BPLine
         mov    dl,es:[di+bx]
         add    bx,BPLine
         mov    dh,es:[di+bx]
         mov    cx,Pixels
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
         loop   @@2
         pop    ds
end;
{
procedure ConvertToDib256(var Source,Dest; Width,Pixels,Planes : word); assembler;
asm
         push   ds
         lds    si,Source
         les    di,Dest
         mov    cx,Width
         rep    movsb
         pop    ds
end;
}
procedure GetBlock16(X,Y,SizeX,SizeY : integer; var Bitmap); assembler;
var
   SaveDS : word;
   BPLine,MemInc : word;
   OldBank,CurBank : word;
asm
       mov     SaveDS,ds
       call    GetBank
       mov     OldBank,ax
       mov     CurBank,ax
       mov     ax,SizeX
       shr     ax,3
       mov     BPLine,ax
       mov     ax,Y
       mov     si,X
       test    si,7
       je      @@0
       inc     BPLine
@@0:   mov     dx,BytesPerLine
       mul     dx
       shr     si,3
       add     si,ax
       adc     dx,0
       cmp     dx,CurBank            { out of current window boundary? }
       je      @@1                    { no }
{       test    byte ptr Switch, true
       je      @@1}
       push    dx
       mov     CurBank,dx
       call    SetBank               { move memory window to new position }
@@1:   mov     ax,BytesPerLine
       mov     MemInc,ax
{ move from video memory to buffer }
       les     di,Bitmap
       mov     ax,BPLine
       shl     ax,3
       stosw
       mov     ax,SizeY
       stosw
       mov     ds,SegA000
       mov     dx,$3CE               { dx= graphics controller i/o port }
       mov     ax,5                  { read mode 0, write mode 0 }
       out     dx,ax                 { al= 5 (mode register) }
@@2:   mov     ax,$304               { ah= plane #3, al= 4 (read map select) }
@@3:   out     dx,ax
       push    ax
       mov     cx,BPLine
{       push    CurBank}
       push    si
@@4:   mov     al,ds:[si]
       stosb
       inc     si
{       jnz     @@4_1
       inc     CurBank
       push    cx
       push    ds
       push    CurBank
       mov     ds,SaveDs
       call    SetBank
       pop     ds
       pop     cx}
@@4_1: loop    @@4
       pop     si
{       pop     CurBank}
       pop     ax
       dec     ah
       jns     @@3
       add     si,MemInc
       jnc     @@4_2
       inc     CurBank
       push    ds
       push    dx
       push    CurBank
       mov     ds,SaveDs
       call    SetBank
       pop     dx
       pop     ds
@@4_2: dec     SizeY
       jnz     @@2
       mov     ds,SaveDS
       mov     dx,CurBank
       cmp     dx,OldBank
       je      @@exit
       push    OldBank
       call    SetBank
@@exit:
       call    ResetController
end;

procedure GetBlock256(X,Y,SizeX,SizeY : integer; var Bitmap); assembler;
var
   SaveDS : word;
   MemInc : word;
   OldBank,CurBank : word;
asm
       mov     SaveDS,ds
       call    GetBank
       mov     OldBank,ax
       mov     CurBank,ax
       mov     ax,Y
       mov     si,X
@@0:   mov     dx,BytesPerLine
       mul     dx
       add     si,ax
       adc     dx,0
       cmp     dx,CurBank            { out of current window boundary? }
       je      @@1                    { no }
       push    dx
       mov     CurBank,dx
       call    SetBank               { move memory window to new position }
@@1:   mov     bx,BytesPerLine
       mov     ax,SizeX
       mov     cx,ax
       sub     bx,ax
       mov     MemInc,bx
{ move from video memory to buffer}
       les     di, Bitmap
       stosw
       mov     ax,SizeY
       stosw
       mov     ds,SegA000
@@2:   mov     al,ds:[si]
       stosb
       inc     si
       jnz     @@2_1
       inc     CurBank
       push    cx
       push    ds
       push    CurBank
       mov     ds,SaveDs
       call    SetBank
       pop     ds
       pop     cx
@@2_1: loopnz  @@2
       add     si,MemInc
       jnc     @@2_2
       inc     CurBank
       push    ds
       push    CurBank
       mov     ds,SaveDs
       call    SetBank
       pop     ds
@@2_2: mov     cx,SizeX
       dec     SizeY
       jnz     @@2
       mov     ds,SaveDS
       push    OldBank
       call    SetBank
end;

procedure PutBlock16(X,Y : integer; var Bitmap); assembler;
var
   SaveDS : word;
   BPLine,MemInc : word;
   OldBank,CurBank : word;
   Count : word;
asm
       mov     SaveDS,ds
       call    GetBank
       mov     OldBank,ax
       mov     CurBank,ax
       mov     ax,BytesPerLine
       mov     MemInc,ax
       mov     es,SegA000
       lds     si,Bitmap
       lodsw
       mov     bx,ax
       shr     ax,3
       mov     BPLine,ax
       test    bx,7
       je      @@0_0
       inc     BPLine
@@0_0: lodsw
       mov     Count,ax
       mov     ax,Y
       mov     di,X
@@0:   mov     dx,MemInc
       mul     dx
       shr     di,3
       add     di,ax
       adc     dx,0
       cmp     dx,CurBank            { out of current window boundary? }
       je      @@1                    { no }
{       test    byte ptr Switch, true
       je      @@1}
       push    ds
       push    dx
       mov     ds,SaveDS
       mov     CurBank,dx
       call    SetBank               { move memory window to new position }
       pop     ds
@@1:
{ set up graphics controller}
       mov     dx,$3CE
       mov     ax,0003               { ah = normal put, al = 3 select register}
       out     dx,ax
       mov     ax,$0805              { ah=read mode 1, write mode 0 }
       out     dx,ax
       mov     ax,0007               { ah = 0 (don't care for all maps) }
       out     dx,ax
       mov     ax,$FF08              { value for bit mask reg }
       out     dx,ax
       mov     ax,1
       out     dx,ax
       mov     dx,$3C4              { dx = 3c4h (sequence i/o port) }
@@2:   mov     ax,0802h              { ah = 1000b (value for map mask reg)}
       cld
@@3:   out     dx,ax
{       push    CurBank}
       push    ax
       mov     cx,BPLine
       push    di
@@4:   lodsb
       mov     es:[di],al
       inc     di
{       jnz     @@4_1
       inc     CurBank
       push    cx
       push    ds
       push    CurBank
       mov     ds,SaveDs
       call    SetBank
       pop     ds
       pop     cx}
@@4_1: loop    @@4
       pop     di
       pop     ax
{       pop     CurBank}
       shr     ah,1
       jnz     @@3
       add     di,MemInc
       jnc     @@4_2
       inc     CurBank
       push    ds
       push    dx
       mov     dx,$3CE
       in      al,dx
       push    ax
       push    CurBank
       mov     ds,SaveDs
       call    SetBank
       mov     dx,$3CE
       pop     ax
       out     dx,al
       pop     dx
       pop     ds
@@4_2: dec     Count
       jnz     @@2
       mov     ds,SaveDS
       mov     dx,CurBank
       cmp     dx,OldBank
       je      @@exit
       push    OldBank
       call    SetBank
@@exit:
       call    ResetController16
end;

procedure PutBlock256(X,Y : integer; var Bitmap); assembler;
var
   SaveDS : word;
   MemInc : word;
   OldBank,CurBank : word;
   Count,BPLine : word;
asm
       mov     SaveDS,ds
       call    GetBank
       mov     OldBank,ax
       mov     CurBank,ax
       mov     ax,Y
       mov     di,X
@@0:   mov     dx,BytesPerLine
       mul     dx
       add     di,ax
       adc     dx,0
       cmp     dx,CurBank            { out of current window boundary? }
       je      @@1                    { no }
       push    dx
       mov     CurBank,dx
       call    SetBank               { move memory window to new position }
@@1:   mov     bx,BytesPerLine
{ move from buffer to video memory }
       mov     es,SegA000
       lds     si, Bitmap
       lodsw
       mov     BPLine,ax
       sub     bx,ax
       mov     MemInc,bx
       lodsw
       mov     Count,ax
       mov     cx,ax
@@2:   lodsb
       mov     es:[di],al
       inc     di
       jnz     @@2_1
       inc     CurBank
       push    cx
       push    ds
       push    CurBank
       mov     ds,SaveDs
       call    SetBank
       pop     ds
       pop     cx
@@2_1: loopnz  @@2
       add     di,MemInc
       jnc     @@2_2
       inc     CurBank
       push    ds
       push    CurBank
       mov     ds,SaveDs
       call    SetBank
       pop     ds
@@2_2: mov     cx,BPLine
       dec     Count
       jnz     @@2
       mov     ds,SaveDS
       push    OldBank
       call    SetBank
end;

procedure DrawMouseShape16(X,Y : integer; var Shape); assembler;
var
   DrawFirst,DrawMiddle,DrawLast : boolean;
   StartMask,EndMask : byte;
   Count,SaveDS : word;
   Curbank,OldBank : word;
   MemInc : word;
   Shift : word;
   Switch : boolean;
asm
       mov     SaveDS,ds
       xor     ax,ax
       test    Y,$8000
       je      @@1
       mov     ax,Y
       neg     ax
       mov     Y,0
@@1:   mov     bx,ax
       mov     ax,ScreenHeight
       sub     ax,Y
       cmp     ax,16
       jle     @@2
       mov     ax,16
@@2:   sub     ax,bx
       mov     Count,ax
       push    bx
       test    X,$8000
       je      @@4
       mov     cx,X
       neg     cx
       mov     X,0
       mov     ch,$FF
       shl     ch,cl
       mov     Shift,cx
       mov     DrawFirst,true
       mov     DrawLast,true
       test    cl,8
       je      @@3
       mov     DrawLast,false
@@3:   jmp     @@4_2
@@4:   mov     ax,X
       add     ax,16
       cmp     ax,ScreenWidth
       jge     @@4_1
       mov     al,true
       mov     DrawFirst,al
       mov     DrawMiddle,al
       mov     DrawLast,al
       jmp     @@4_2
@@4_1: mov     DrawFirst,true
       mov     DrawLast,false
       test    X,7
       je      @@4_2
       mov     ax,ScreenWidth
       sub     ax,X
       mov     cx,3
       shr     ax,cl
       mov     DrawMiddle,al
@@4_2:
       call    GetBank
       mov     OldBank,ax            { save current bank }
       mov     CurBank,ax
       mov     al,byte ptr SwitchBank
       mov     Switch,al
       mov     ax,Y
       mov     si,X
       mov     dx,BytesPerLine
       mov     MemInc,dx
       mul     dx                    { dx - start bank for drawing }
       shr     si,3
       add     si,ax
       adc     dx,0
       cmp     dx,CurBank            { out of current window boundary? }
       je      @@4_3                    { no }
       test    byte ptr Switch, true
       je      @@4_3
       push    dx
       mov     CurBank,dx
       call    SetBank               { move memory window to new position }
@@4_3:
{ set up graphics controller registers }
       mov     dx,$3CE               { graphics controller address reg port}
       mov     ax,$0A05              { write mode 2, read mode 1 }
       out     dx,ax
       mov     ax,3                  { read-modify-write bits }
       out     dx,ax
       mov     ax,7                  { color don't care for all planes }
       out     dx,ax
{       mov     ax,1
       out     dx,ax}
{ set up pointers }
       les     di,Shape
       pop     bx
       shl     bx,1
       add     di,bx
       mov     ds,SegA000
{ choose drawing routine }
       mov     cx,X
       test    cx,7
       jne     @@4_4
       jmp     @@DrawAligned
@@4_4: and     cl,7                  { calculate shift value and end mask }
       xor     cl,7
       inc     cl
       and     cl,7
       mov     ch,$FF
       shl     ch,cl
       mov     Shift,cx

@@DrawNonAligned:
       mov     cx,Shift
       mov     ax,es:[di]
       not     ax
       mov     bx,es:[di+32]
       add     di,2
       push    si
       test    DrawFirst,true
       je      @@5
       push    ax
       push    bx
       shr     ax,8
       shr     bx,8
       shl     ax,cl
       shl     bx,cl
       mov     al,8
       out     dx,ax
       and     byte ptr [si],0
       mov     ah,bh
       out     dx,ax
       and     byte ptr [si],$0F
       inc     si
       pop     bx
       pop     ax
@@5:   shl     ax,cl
       shl     bx,cl
       test    DrawMiddle,true
       je      @@6
       push    ax
       mov     al,8
       out     dx,ax
       and     byte ptr [si],0
       mov     ah,bh
       out     dx,ax
       and     byte ptr [si],$0F
       pop     ax
       inc     si
@@6:   test    DrawLast,true
       je      @@7
       mov     ah,al
       mov     al,8
       out     dx,ax
       and     byte ptr [si],0
       mov     ah,bl
       out     dx,ax
       and     byte ptr [si],$0F
@@7:   pop     si
       dec     Count
       jz      @@exit
       add     si,MemInc
       jnc     @@8
       push    dx
       in      al,dx
       push    ax
       push    ds
       mov     ds,SaveDS
       inc     CurBank
       push    CurBank
       call    SetBank
       pop     ds
       pop     ax
       pop     dx
       out     dx,al
@@8:  jmp     @@DrawNonAligned

@@DrawAligned:
       mov     ax,es:[di]
       not     ax
       mov     bx,es:[di+32]
       mov     cx,Shift
       or      cl,cl
       je      @@9
       shl     ax,cl
       shl     bx,cl
@@9:   add     di,2
       push    si
       test    DrawFirst,true
       je      @@11
       push    ax
       mov     al,8
       out     dx,ax
       and     byte ptr [si],0
       mov     ah,bh
       out     dx,ax
       and     byte ptr [si],$0F
       pop     ax
       inc     si
@@11:  test    DrawLast,true
       je      @@12
       mov     ah,al
       mov     al,8
       out     dx,ax
       and     byte ptr [si],0
       mov     ah,bl
       out     dx,ax
       and     byte ptr [si],$0F
@@12:  pop     si
       dec     Count
       jz      @@exit
       add     si,MemInc
       jnc     @@10
       push    dx
       in      al,dx
       push    ax
       push    ds
       mov     ds,SaveDS
       inc     CurBank
       push    CurBank
       call    SetBank
       pop     ds
       pop     ax
       pop     dx
       out     dx,al
@@10:  jmp     @@DrawAligned

@@exit:
       mov     ds,SaveDS
       test    Switch,true
       je      @@e1
       in      al,dx
       push    dx
       push    ax
       push    OldBank
       call    SetBank
       pop     ax
       pop     dx
       out     dx,al
@@e1:
       call    ResetController
end;

procedure DrawMouseShape256(X,Y : integer; var Shape); assembler;
var
   YCount : word;
   HorShift,LastX : word;
   SaveDS,MemInc : word;
   CurBank,OldBank : word;
asm
       mov     SaveDS,ds
       xor     ax,ax
       test    Y,$8000
       je      @@1
       mov     ax,Y
       neg     ax
       inc     ax
       mov     Y,0
@@1:   mov     bx,ax
       mov     ax,ScreenHeight
       sub     ax,Y
       cmp     ax,16
       jle     @@2
       mov     ax,16
@@2:   sub     ax,bx
       mov     YCount,ax
       xor     ax,ax
       test    X,$8000
       je      @@3
       mov     ax,X
       neg     ax
       inc     ax
       mov     X,0
@@3:   mov     HorShift,ax
       mov     ax,ScreenWidth
       sub     ax,X
       cmp     ax,16
       jg      @@3_1
{       jle     @@4}
       jmp     @@4
@@3_1: mov     ax,16
@@4:   {dec     ax}
       mov     LastX,ax
       push    bx
       call    GetBank
       mov     OldBank,ax
       mov     CurBank,ax
       mov     ax,Y
       mov     di,X
       mov     dx,BytesPerLine
       push    dx
       mul     dx
       add     di,ax
       adc     dx,0
       cmp     dx,CurBank
       je      @@5
       push    dx
       mov     CurBank,dx
       call    SetBank
@@5:   mov     es,SegA000
       pop     dx
       sub     dx,LastX
       add     dx,HorShift
       mov     MemInc,dx
       lds     si,Shape
       pop     bx
       shl     bx,1
       add     si,bx
       xor     bx,bx
       mov     bl,$0F
@@6:   mov     ax,ds:[si]
       mov     dx,ds:[si+32]
       mov     cx,HorShift
       or      cx,cx
       je      @@7
       shl     ax,cl
       shl     dx,cl
@@7:   mov     cx,LastX
       sub     cx,HorShift
@@8:   rol     ax,1
       jc      @@9
       mov     es:[di],bh
@@9:   rol     dx,1
       jnc     @@10
       mov     es:[di],bl
@@10:  inc     di
       jnz     @@11
       push    ax
       push    bx
       push    cx
       push    dx
       push    ds
       mov     ds,SaveDS
       inc     CurBank
       push    CurBank
       call    SetBank
       pop     ds
       pop     dx
       pop     cx
       pop     bx
       pop     ax
@@11:  loop    @@8
       dec     YCount
       jz      @@exit
       add     di,MemInc
       jnc     @@12
       push    bx
       push    ds
       mov     ds,SaveDS
       inc     CurBank
       push    CurBank
       call    SetBank
       pop     ds
       pop     bx
@@12:  add     si,2
       jmp     @@6
@@exit:
       mov     ds,SaveDS
       push    OldBank
       call    SetBank
end;

procedure Dumb;
begin
end;

procedure GetBiosPalette(HowMuch : word); near; assembler;
asm
       mov      ax,$1017
       xor      bx,bx
       mov      cx,HowMuch
       lea      dx,word ptr RGBPal256
       push     ds
       pop      es
       int      $10
end;

procedure SetupMethods16;
var
   i : word;
begin
   ConvertPixRow := ConvertPixRow16;
{   ConvertToDib := ConvertToDib16;}
   DrawChar := DrawChar16;
   ExtractImage := ExtractImage16;
   MovePixels := MovePixels16;
   SetController := SetController16;
   ResetController := ResetController16;
   GetBlock := GetBlock16;
   PutBlock := PutBlock16;
   DrawMouseShape := DrawMouseShape16;
   BitPerPlane := 1;
   Planes := 4;
   FalseMode := $11;
   CursorAreaSize := 48 * Planes + 4;
   GetBiosPalette(64);
   for i := 0 to 7 do MapColor[i] := i;
   MapColor[6] := 20;
   for i := 0 to 7 do MapColor[i+8] := 56 + i;
end;

procedure SetupMethods256;
var
   i : word;
begin
   ConvertPixRow := ConvertPixRow256;
{   ConvertToDib := ConvertToDib256;}
   DrawChar := DrawChar256;
   ExtractImage := ExtractImage256;
   MovePixels := MovePixels256;
   SetController := Dumb;
   ResetController := Dumb;
   GetBlock := GetBlock256;
   PutBlock := PutBlock256;
   DrawMouseShape := DrawMouseShape256;
   BitPerPlane := 8;
   Planes := 1;
   FalseMode := $13;
   CursorAreaSize := 260;   { 4 byte header + 256 bytes image }
{ read entire RGB palette }
   GetBiosPalette(256);
   for i := 0 to 15 do begin
      with Vga16Colors[i] do
         MapColor[i] := word(GetNearestColor(256,rgbRed,rgbGreen,rgbBlue));
   end;
end;

end.