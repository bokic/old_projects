{************************************************}
{   Eventman.pas                                 }
{   Graph Vision unit                            }
{   Sergey E. Levov, Moscow,1992-1994            }
{   Portions copyright (c) 1990 by Borland Int.  }
{************************************************}

unit EventMan;

{$F+,S-,X+,D+,G+}
{$C FIXED PRELOAD PERMANENT}

interface

uses Objects,Graph;

{ ******** EVENT MANAGER ******** }

const

{ Event codes }

  evMouseDown = $0001;
  evMouseUp   = $0002;
  evMouseMove = $0004;
  evMouseAuto = $0008;
  evKeyDown   = $0010;
  evCommand   = $0100;
  evBroadcast = $0200;

{ Event masks }

  evNothing   = $0000;
  evMouse     = $000F;
  evKeyboard  = $0010;
  evMessage   = $FF00;

{ Extended key codes }

  kbEsc       = $011B;  kbAltSpace  = $0200;  kbCtrlIns   = $0400;
  kbShiftIns  = $0500;  kbCtrlDel   = $0600;  kbShiftDel  = $0700;
  kbBack      = $0E08;  kbCtrlBack  = $0E7F;  kbShiftTab  = $0F00;
  kbTab       = $0F09;  kbAltQ      = $1000;  kbAltW      = $1100;
  kbAltE      = $1200;  kbAltR      = $1300;  kbAltT      = $1400;
  kbAltY      = $1500;  kbAltU      = $1600;  kbAltI      = $1700;
  kbAltO      = $1800;  kbAltP      = $1900;  kbCtrlEnter = $1C0A;
  kbEnter     = $1C0D;  kbAltA      = $1E00;  kbAltS      = $1F00;
  kbAltD      = $2000;  kbAltF      = $2100;  kbAltG      = $2200;
  kbAltH      = $2300;  kbAltJ      = $2400;  kbAltK      = $2500;
  kbAltL      = $2600;  kbAltZ      = $2C00;  kbAltX      = $2D00;
  kbAltC      = $2E00;  kbAltV      = $2F00;  kbAltB      = $3000;
  kbAltN      = $3100;  kbAltM      = $3200;  kbF1        = $3B00;
  kbF2        = $3C00;  kbF3        = $3D00;  kbF4        = $3E00;
  kbF5        = $3F00;  kbF6        = $4000;  kbF7        = $4100;
  kbF8        = $4200;  kbF9        = $4300;  kbF10       = $4400;
  kbHome      = $4700;  kbUp        = $4800;  kbPgUp      = $4900;
  kbGrayMinus = $4A2D;  kbLeft      = $4B00;  kbRight     = $4D00;
  kbGrayPlus  = $4E2B;  kbEnd       = $4F00;  kbDown      = $5000;
  kbPgDn      = $5100;  kbIns       = $5200;  kbDel       = $5300;
  kbShiftF1   = $5400;  kbShiftF2   = $5500;  kbShiftF3   = $5600;
  kbShiftF4   = $5700;  kbShiftF5   = $5800;  kbShiftF6   = $5900;
  kbShiftF7   = $5A00;  kbShiftF8   = $5B00;  kbShiftF9   = $5C00;
  kbShiftF10  = $5D00;  kbCtrlF1    = $5E00;  kbCtrlF2    = $5F00;
  kbCtrlF3    = $6000;  kbCtrlF4    = $6100;  kbCtrlF5    = $6200;
  kbCtrlF6    = $6300;  kbCtrlF7    = $6400;  kbCtrlF8    = $6500;
  kbCtrlF9    = $6600;  kbCtrlF10   = $6700;  kbAltF1     = $6800;
  kbAltF2     = $6900;  kbAltF3     = $6A00;  kbAltF4     = $6B00;
  kbAltF5     = $6C00;  kbAltF6     = $6D00;  kbAltF7     = $6E00;
  kbAltF8     = $6F00;  kbAltF9     = $7000;  kbAltF10    = $7100;
  kbCtrlPrtSc = $7200;  kbCtrlLeft  = $7300;  kbCtrlRight = $7400;
  kbCtrlEnd   = $7500;  kbCtrlPgDn  = $7600;  kbCtrlHome  = $7700;
  kbAlt1      = $7800;  kbAlt2      = $7900;  kbAlt3      = $7A00;
  kbAlt4      = $7B00;  kbAlt5      = $7C00;  kbAlt6      = $7D00;
  kbAlt7      = $7E00;  kbAlt8      = $7F00;  kbAlt9      = $8000;
  kbAlt0      = $8100;  kbAltMinus  = $8200;  kbAltEqual  = $8300;
  kbCtrlPgUp  = $8400;  kbAltBack   = $0800;  kbNoKey     = $0000;

{ Keyboard state and shift masks }

  kbRightShift  = $0001;
  kbLeftShift   = $0002;
  kbCtrlShift   = $0004;
  kbAltShift    = $0008;
  kbScrollState = $0010;
  kbNumState    = $0020;
  kbCapsState   = $0040;
  kbInsState    = $0080;

{ Mouse button state masks }

  mbLeftButton  = $01;
  mbRightButton = $02;

type

{ Event record }

  PEvent = ^TEvent;
  TEvent = record
    What: Word;
    case Word of
      evNothing: ();
      evMouse: (
        Buttons: Byte;
        Double: Boolean;
        Where: TPoint);
      evKeyDown: (
        case Integer of
	  0: (KeyCode: Word);
          1: (CharCode: Char;
              ScanCode: Byte));
      evMessage: (
        Command: Word;
        case Word of
          0: (InfoPtr: Pointer);
          1: (InfoLong: Longint);
          2: (InfoWord: Word);
          3: (InfoInt: Integer);
          4: (InfoByte: Byte);
          5: (InfoChar: Char));
  end;

const

{ Initialized variables }

  ButtonCount: Byte = 0;
  MouseEvents: Boolean = False;
  MouseReverse: Boolean = False;
  DoubleDelay: Word = 8;
  RepeatDelay: Word = 8;
  Hot : TPoint = (X : 0; Y : 0);
  ShapeSize : TPoint = (X : 16; Y : 16);
  MouseShape : pointer = nil;

var

{ Uninitialized variables }

  MouseIntFlag: Byte;
  MouseButtons: Byte;
  MouseWhere: TPoint;

{ Event manager routines }

procedure InitEvents;
procedure DetectMouse;    {!!!}
procedure DoneEvents;
procedure ShowMouse;
procedure HideMouse;
function MouseInRect(Bounds : TRect) : boolean;
procedure GetMouseEvent(var Event: TEvent);
procedure GetKeyEvent(var Event: TEvent);
procedure SetExclusiveArea(Bounds : TRect);
procedure SetMouseCursor(HotSpot,Size : TPoint; Shape : pointer);
function GetShiftState: Byte;

{ ******** SYSTEM ERROR HANDLER ******** }
type

{ System error handler function type }

  TSysErrorFunc = function(ErrorCode: Integer; Drive: Byte): Integer;

{ Default system error handler routine }

function SystemError(ErrorCode: Integer; Drive: Byte): Integer;

const

{ Initialized variables }

  SaveInt09: Pointer = nil;
  SysErrorFunc: TSysErrorFunc = SystemError;
  CtrlBreakHit: Boolean = False;
  SaveCtrlBreak: Boolean = False;
  SysErrActive: Boolean = False;

{ System error handler routines }

procedure InitSysError;
procedure DoneSysError;

{ ******** UTILITY ROUTINES ******** }

const
   LatinOnly : boolean = true;

{ Keyboard support routines }

function GetAltChar(KeyCode: Word): Char;
function GetAltCode(Ch: Char): Word;
function GetCtrlChar(KeyCode: Word): Char;
function GetCtrlCode(Ch: Char): Word;
function CtrlToArrow(KeyCode: Word): Word;

{ String routines }

procedure FormatStr(var Result: String; Format: String; var Params);
procedure PrintStr(S: String);
function CStrLen(S: String): Integer;
procedure CStrToStr(Source : string; var Dest : string);

implementation
{$IFNDEF DPMI}
uses Dos,Crt,LowGraph,GrDriver;
{$ELSE}
uses Dos,Crt,WinApi,GrDriver,LowGraph;
{$ENDIF}
{ ******** EVENT MANAGER ******** }

const

{ Event manager constants }

  EventQSize = 16;
  OldInt33h : pointer=nil;
  SaveCursorArea : pointer = nil;
  MouseVisFlag : integer = -1;
  ExcludeActive : boolean = false;
  MWhere : TPoint = (X : 0; Y : 0);
  DrawingInProgress : boolean = false;
var

{ Event manager variables }

  LastButtons: Byte;
  DownButtons: Byte;
  LastDouble: Boolean;
  LastWhere: TPoint;
  DownWhere: TPoint;
  DownTicks: Word;
  AutoTicks: Word;
  AutoDelay: Word;
  EventCount: Word;
  EventQHead: Word;
  EventQTail: Word;
  EventQueue: array[0..EventQSize - 1] of TEvent;
  EventQLast: record end;

var
  ShiftState: Byte absolute $40:$17;
  Ticks: Word absolute $40:$6C;
  VideoMode : byte absolute $40:$49;
  ExclRect : TRect;
{ Detect mouse driver }

procedure DetectMouse; assembler; {near}
asm
	MOV	AX,3533H
	INT	21H
	MOV	AX,ES
	OR	AX,BX
	JE	@@1
	XOR	AX,AX
	INT	33H
	OR	AX,AX
	JE	@@1
	PUSH	BX
	MOV	AX,4
	XOR	CX,CX
	XOR	DX,DX
	INT	33H
	POP	AX
@@1:	MOV	ButtonCount,AL
end;

{ Store event in GetMouseEvent and GetKeyEvent }

procedure StoreEvent; near; assembler;
asm
	MOV	DI,SP
	LES	DI,SS:[DI+8]
	CLD
	STOSW
	XCHG	AX,BX
	STOSW
	XCHG	AX,CX
	STOSW
	XCHG	AX,DX
	STOSW
end;

{ Get mouse state }
{ Out	BL = Button mask }
{	CX = X coordinate }
{	DX = Y coordinate }
{	DI = Timer ticks }

procedure GetMouseState; near; assembler;
asm
	CLI
	CMP	EventCount,0
	JNE	@@1
	MOV	BL,MouseButtons
	MOV	CX,MouseWhere.Word[0]
	MOV	DX,MouseWhere.Word[2]
	MOV	ES,Seg0040
	MOV	DI,ES:Ticks
	JMP	@@3
@@1:	MOV	SI,EventQHead
	CLD
	LODSW
	XCHG	AX,DI
	LODSW
	XCHG	AX,BX
	LODSW
	XCHG	AX,CX
	LODSW
	XCHG	AX,DX
	CMP	SI,OFFSET EventQLast
	JNE	@@2
	MOV	SI,OFFSET EventQueue
@@2:	MOV	EventQHead,SI
	DEC	EventCount
@@3:	STI
	CMP	MouseReverse,0
	JE	@@4
	MOV	BH,BL
	AND	BH,3
	JE	@@4
	CMP	BH,3
	JE	@@4
	XOR	BL,3
@@4:
end;

{$IFDEF DPMI}
{$L MousIrq.obp}
{$ELSE}
{$L MousIrq.obj}
{$ENDIF}

procedure HookMouseHardInt; external;
procedure RestoreMouseHardInt; external;
procedure SaveVideoRegs; external;
procedure RestoreVideoRegs; external;

procedure ShowMouseCursor; assembler;
asm
{ calculate coordinates }
        mov     ax,MWhere.Y
        sub     ax,Hot.Y
        jnc     @@1
        xor     ax,ax
@@1:    mov     bx,MWhere.X
        sub     bx,Hot.X
        push    bx
        push    ax
        jnc     @@2
        xor     bx,bx
{ save covered area }
@@2:    mov     dx,ScreenHeight
        sub     dx,ShapeSize.Y
        cmp     ax,dx
        jle     @@3
        mov     ax,dx
@@3:    mov     dx,ScreenWidth
        sub     dx,ShapeSize.X
        cmp     bx,dx
        jle     @@4
        mov     bx,dx
@@4:    push    bx
        push    ax
        push    ShapeSize.X
        push    ShapeSize.Y
        push    SaveCursorArea.word[2]
        push    SaveCursorArea.word[0]
        call    [GetBlock]
{ draw mouse shape }
{        push    ShapeSize.X
        push    ShapeSize.Y}
        push    MouseShape.word[2]
        push    MouseShape.word[0]
        call    [DrawMouseShape]
@@exit:
end;

procedure HideMouseCursor; assembler;
asm
        mov     ax,MWhere.Y
        sub     ax,Hot.Y
        jnc     @@1
        xor     ax,ax
@@1:    mov     bx,MWhere.X
        sub     bx,Hot.X
        jnc     @@2
        xor     bx,bx
@@2:    mov     dx,ScreenHeight
        sub     dx,ShapeSize.Y
        cmp     ax,dx
        jle     @@3
        mov     ax,dx
@@3:    mov     dx,ScreenWidth
        sub     dx,ShapeSize.X
        cmp     bx,dx
        jle     @@4
        mov     bx,dx
@@4:    push    bx
        push    ax
        push    SaveCursorArea.word[2]
        push    SaveCursorArea.word[0]
        call    [PutBlock]
@@exit:
end;

procedure SetShape(HotX,HotY : integer; Shape : pointer);
begin
{   if SaveCursorArea = nil then GetMem(SaveCursorArea,CursorAreaSize);}
   if MouseVisFlag = 0 then begin
      if MouseShape <> nil then HideMouseCursor;
   end;
   Hot.X := HotX;
   Hot.Y := HotY;
   MouseShape := Shape;
(*   asm
   	push	ds
	lds	si,Shape
	les	di,Shape
	cld
        mov     ax,ShapeSize.X
        shr     ax,2          { /8 bits * 2 masks }
        mov     dx,ShapeSize.Y
        mul     dx
        mov     cx,ax
@@1:    lodsw
        xchg    ah,al
        stosw
        loop    @@1
	pop	ds
   end; *)
{   ShapeSize.X := 16;
   ShapeSize.Y := 16;}
   if (MouseVisFlag = 0) then begin
      ShowMouseCursor;
   end;
end;

function MouseInRect(Bounds : TRect) : boolean;
var
   Mouse : TRect;
begin
   if EmulateMouseCursor then Mouse.A := MWhere else Mouse.A := MouseWhere;
   Mouse.B := Mouse.A;
   with Mouse do begin
      inc(B.X,ShapeSize.X*2);
      inc(B.Y,ShapeSize.Y);
   end;
   with Hot do Mouse.Move(-X-8,-Y);   { -8! otherwise garbages screen (???)}
   Bounds.Intersect(Mouse);
   MouseInRect := not Bounds.Empty;
end;

procedure SetMousePos(X,Y : integer);
begin
    asm
        cmp     MouseVisFlag,0
        jl      @@1
	call	HideMouseCursor
@@1:    mov     ax,X
	mov     MWhere.X,ax
        mov     ax,Y
        mov     MWhere.Y,ax
   end;
   if MouseVisFlag = 0 then begin
      if not (ExcludeActive and MouseInRect(ExclRect)) then ShowMouseCursor
      else begin
         MouseVisFlag := -1;
         ExcludeActive := false;
      end;
   end;
end;

procedure SetExclude(XA,YA,XB,YB : integer);
begin
   ExclRect.Assign(XA,YA,XB,YB);
   ExcludeActive := true;
   if MouseInRect(ExclRect) and (MouseVisFlag = 0) then begin
      MouseVisFlag := -1;
      if MouseShape <> nil then HideMouseCursor;
      ExcludeActive := false;
   end;
end;

procedure MouseInt; far; assembler;
asm
	MOV	SI,SEG @DATA
	MOV	DS,SI
	MOV	SI,CX
	MOV	MouseButtons,BL
        cmp     EmulateMouseCursor,true
        jne      @@0
        test    ax,1
        je      @@0
        cmp     si,MouseWhere.X
        jne     @@0_0
        cmp     dx,MouseWhere.Y
        je      @@0
@@0_0:  cmp     MouseShape.word[2],0
        je      @@0
{        cmp     MouseVisFlag,0
        jl      @@0}
        cmp     DrawingInProgress,true
        je      @@0
        cli
        push    ax
        push    bx
        push    dx
        push    si
        push    si
        push    dx
        push    ds
        call    SaveVideoRegs
        pop     ds
        call    SetMousePos
        push    ds
        call    RestoreVideoRegs
        pop     ds
        pop     si
        pop     dx
        pop     bx
        pop     ax
        sti
{        jmp     @@0_1}
@@0:	MOV	MouseWhere.X,SI
	MOV	MouseWhere.Y,DX
@@0_1:	TEST	AX,11110B
	JE	@@2
	CMP	EventCount,EventQSize
	JE	@@2
	MOV	ES,Seg0040
	MOV	AX,ES:Ticks
	MOV	DI,EventQTail
	PUSH	DS
	POP	ES
	CLD
	STOSW
	XCHG	AX,BX
	STOSW
	XCHG	AX,SI
	STOSW
	XCHG	AX,DX
	STOSW
	CMP	DI,OFFSET EventQLast
	JNE	@@1
	MOV	DI,OFFSET EventQueue
@@1:	MOV	EventQTail,DI
	INC	EventCount
@@2:	MOV	MouseIntFlag,1
end;

procedure NewInt33h; far; assembler;
asm
        cli
        pushf
        cld
        or      ax,ax           { reset mouse? }
        jne     @@1
        cmp     MouseVisFlag,ax
        jl      @@0
        cmp     MouseShape.word[2],0
        je      @@0
        inc     DrawingInProgress
        call    HideMouseCursor { yes - hide cursor }
        xor     ax,ax
        mov     DrawingInProgress,al
@@0:    mov     MouseVisFlag,$FFFF
{        mov     MWhere.X,ax
        mov     MWhere.Y,ax}
        mov     ExcludeActive,al
        jmp     @@10            { and call old int 33h handler }
@@1:    cmp     ax,1            { show mouse? }
        jne     @@2
        mov     ExcludeActive,false
        cmp     MouseShape.word[2],0
        je      @@21
        cmp     MouseVisFlag,0
        je      @@21
        inc     MouseVisFlag
        cmp     MouseVisFlag,0
        jne     @@21
        inc     DrawingInProgress
        call    ShowMouseCursor
        dec     DrawingInProgress
        jmp     @@21
@@2:    cmp     ax,2            { hide mouse? }
        jne     @@3
        cmp     MouseShape.word[2],0
        je      @@21
        cmp     MouseVisFlag,0
        jl      @@2_1
        inc     DrawingInProgress
        call    HideMouseCursor
        dec     DrawingInProgress
@@2_1:  dec     MouseVisFlag
        jmp     @@21
@@3:    cmp     ax,9            { set mouse shape? }
        jne     @@4
        push    bx
        push    cx
        push    es
        push    dx
        inc     DrawingInProgress
        call    SetShape
        dec     DrawingInProgress
        jmp     @@21
@@4:    cmp     ax,$10
        jne     @@10
        push    cx
        push    dx
        push    si
        push    di
        inc     DrawingInProgress
        call    SetExclude
        dec     DrawingInProgress
        jmp     @@21
@@10:   pushf
        call    dword ptr [OldInt33h]    {call old interrupt handler}
@@21:   sti
        popf
        iret
end;

procedure HookInt33h;
begin
   GetIntVec($33,OldInt33h);
   SetIntVec($33,@NewInt33h);
   if SaveCursorArea = nil then GetMem(SaveCursorArea,CursorAreaSize);
end;

procedure RestoreInt33h;
begin
   SetIntVec($33,OldInt33h);
end;

procedure InitEvents; assembler;
var
   HoldMode : byte;
asm
{ try to fix problem with mouse cursor under VESA modes }
@@0_0:   cmp     EmulateMouseCursor,true
        jne     @@0_1
        mov     es,Seg0040
        mov     al,es:VideoMode
        mov     HoldMode,al
        mov     al,FalseMode
        mov     es:VideoMode,al
{ now mouse should recognize current mode as graphic }
@@0_1:  call    DetectMouse
	XOR	AX,AX
	CMP	AL,ButtonCount
	JE	@@2
	MOV	DownButtons,AL
	MOV	LastDouble,AL
	MOV	EventCount,AX
	MOV	AX,OFFSET DS:EventQueue
	MOV	EventQHead,AX
	MOV	EventQTail,AX
	MOV	AX,3
	INT	33H
	XCHG	AX,CX
	MOV	MouseButtons,BL
	MOV	MouseWhere.X,AX
        Mov     MWhere.X,ax
        mov     MWhere.Y,ax
	MOV	MouseWhere.Y,DX
	MOV	LastButtons,BL
	MOV	LastWhere.X,AX
	MOV	LastWhere.Y,DX
	MOV	AX,12
	MOV	CX,0FFFFH
	MOV	DX,OFFSET CS:MouseInt
	PUSH	CS
	POP	ES
	INT	33H
	MOV	MouseEvents,1
 {restore actual video mode flag and set max & min position}
        cmp     EmulateMouseCursor,true
        jne     @@0_2
        mov     es,Seg0040
        mov     al,HoldMode
        mov     es:VideoMode,al
        call    GetMaxX
        xor     cx,cx
        mov     dx,ax
        mov     ax,7
        int     $33
        push    ax
        call    GetMaxY
        mov     dx,ax
        xor     cx,cx
        pop     ax
        inc     ax
        int     $33
@@0_2:  xor     ax,ax
        mov     al,EmulateMouseCursor
        push    ax
        inc     ax
        INT     33H
        pop     ax
@@0:    or      ax,ax
        jz      @@1
        call    HookInt33h
        jmp     @@2
@@1:    call    HookMouseHardInt
        or      ax,ax
        jnz     @@2
        mov     EmulateMouseCursor,true
        jmp     @@0_0
@@2:
end;

procedure DoneEvents; assembler;
asm
	CMP	ButtonCount,0
	JE	@@2
	CMP	MouseEvents,0
	JE	@@1
        MOV     AX,2
        INT     33H
	MOV	AX,12
	XOR	CX,CX
	MOV	DX,CX
	MOV	ES,CX
	INT	33H
        cmp     EmulateMouseCursor,true
        jne     @@0
        call    RestoreInt33h
{        call    ShowMouse}
        jmp     @@1
@@0:    call    RestoreMouseHardInt
@@1:	MOV	MouseEvents,0
@@2:
end;

procedure ShowMouse; assembler;
asm
	CMP	ButtonCount,0
	JE	@@1
	PUSH	AX
	MOV	AX,1
	INT	33H
	POP	AX
@@1:
end;

procedure HideMouse; assembler;
asm
	CMP	ButtonCount,0
	JE	@@1
	PUSH	AX
	MOV	AX,2
	INT	33H
	POP	AX
@@1:
end;

procedure SetExclusiveArea(Bounds : TRect); assembler;
asm
        les     di,Bounds
        mov     cx,es:[di].TRect.A.X
        mov     dx,es:[di].TRect.A.Y
        mov     si,es:[di].TRect.B.X
        mov     di,es:[di].TRect.B.Y
        mov     ax,$10
        int     $33
end;

procedure SetMC(HotSpot,Size : TPoint; Shape : pointer); assembler;
asm
         mov    ax,$9
         mov    bx,HotSpot.X
         mov    cx,HotSpot.Y
         mov    dx,Shape.word[0]
         mov    es,Shape.word[2]
         int    $33
end;

procedure SetMouseCursor(HotSpot,Size : TPoint; Shape : pointer);

{$IFDEF DPMI}
var
   CallBack : TRealRegs;
   RealModeSel : pointer;
   RealModeSeg : pointer;
   Result : LongInt;
{$ENDIF}
begin
{$IFDEF DPMI}
   if not EmulateMouseCursor then begin
      Result := GlobalDosAlloc(64);
      PtrRec(RealModeSel).Seg := LongRec(Result).Lo;
      PtrRec(RealModeSel).Ofs := 0;
      PtrRec(RealModeSeg).Seg := LongRec(Result).Hi;
      PtrRec(RealModeSeg).Ofs := 0;
      Move(Shape^,RealModeSel^,64);
      FillChar(CallBack,SizeOf(TRealRegs),#0);
      with CallBack do begin
         LongRec(RealEAX).Lo := $9;
         LongRec(RealEBX).Lo := HotSpot.X;
         LongRec(RealECX).Lo := HotSpot.Y;
         LongRec(RealEDX).Lo := PtrRec(RealModeSeg).Ofs;
         RealES := PtrRec(RealModeSeg).Seg;
      end;
      asm
         mov    ax,$0300
         mov    bx,$33
         xor    cx,cx
         lea    di,CallBack
         push   ss
         pop    es
         int    $31
      end;
      GlobalDosFree(PtrRec(realModeSel).Seg);
   end else
{$ENDIF}
   asm
         mov    ax,$9
         mov    bx,HotSpot.X
         mov    cx,HotSpot.Y
         mov    dx,Shape.word[0]
         mov    es,Shape.word[2]
         int    $33
   end;
   if not  EmulateMouseCursor then begin
      ShapeSize := Size;
      Hot := HotSpot;
      MouseShape := Shape;
   end;
end;

procedure GetMouseEvent(var Event: TEvent); assembler;
asm
	CMP	MouseEvents,0
	JE	@@2
	CALL	GetMouseState
	MOV	BH,LastDouble
	MOV	AL,LastButtons
	CMP	AL,BL
	JE	@@1
	OR	AL,AL
	JE	@@3
	OR	BL,BL
	JE	@@5
	MOV	BL,AL
@@1:	CMP	CX,LastWhere.X
	JNE	@@6
	CMP	DX,LastWhere.Y
	JNE	@@6
	OR	BL,BL
	JE	@@2
	MOV	AX,DI
	SUB	AX,AutoTicks
	CMP	AX,AutoDelay
	JAE	@@7
@@2:	XOR	AX,AX
	MOV	BX,AX
	MOV	CX,AX
	MOV	DX,AX
	JMP	@@9
@@3:	MOV	BH,0
	CMP	BL,DownButtons
	JNE	@@4
	CMP	CX,DownWhere.X
	JNE	@@4
	CMP	DX,DownWhere.Y
	JNE	@@4
	MOV	AX,DI
	SUB	AX,DownTicks
	CMP	AX,DoubleDelay
	JAE	@@4
	MOV	BH,1
@@4:	MOV	DownButtons,BL
	MOV	DownWhere.X,CX
	MOV	DownWhere.Y,DX
	MOV	DownTicks,DI
	MOV	AutoTicks,DI
	MOV	AX,RepeatDelay
	MOV	AutoDelay,AX
	MOV	AX,evMouseDown
	JMP	@@8
@@5:	MOV	AX,evMouseUp
	JMP	@@8
@@6:	MOV	AX,evMouseMove
	JMP	@@8
@@7:	MOV	AutoTicks,DI
	MOV	AutoDelay,1
	MOV	AX,evMouseAuto
@@8:    MOV	LastButtons,BL
	MOV	LastDouble,BH
	MOV	LastWhere.X,CX
	MOV	LastWhere.Y,DX
@@9:	CALL	StoreEvent
end;

procedure GetKeyEvent(var Event: TEvent); assembler;
asm
	MOV	AH,1
	INT	16H
	MOV	AX,0
	MOV	BX,AX
	JE	@@1
	MOV	AH,0
	INT	16H
	XCHG	AX,BX
	MOV	AX,evKeyDown
@@1:	XOR	CX,CX
	MOV	DX,CX
	CALL	StoreEvent
end;

function GetShiftState: Byte; assembler;
asm
	MOV	ES,Seg0040
	MOV	AL,ES:ShiftState
end;

{ ******** SYSTEM ERROR HANDLER ******** }

{$IFDEF DPMI}
{$L SYSINT.OBP}
{$ELSE}
{$L SYSINT.OBJ}
{$ENDIF}

{ System error handler routines }

procedure InitSysError; external;
procedure DoneSysError; external;

{$V-}

function SystemError(ErrorCode: Integer; Drive: Byte): Integer;
var
  C: Word;
  P: Pointer;
  S: string[63];
  B: array[0..79] of Word;
begin
  SystemError := 1;
end;

{$V+}


{ ******** UTILITY ROUTINES ******** }

{ Keyboard support routines }

const

  AltCodes1: array[$10..$32] of Char =
    'QWERTYUIOP'#0#0#0#0'ASDFGHJKL'#0#0#0#0#0'ZXCVBNM';

  AltCodes2: array[$78..$83] of Char =
    '1234567890-=';
  AltCodesCyr : array[$10..$34] of Char =
    'âñìäÖçÉòôáïö'#0#0'îõÇÄèêéãÑÜù'#0#0#0'üóëåàíúÅû';

function GetAltChar(KeyCode: Word): Char;
begin
  GetAltChar := #0;
  if Lo(KeyCode) = 0 then
    case Hi(KeyCode) of
      $02: GetAltChar := #240;
      $10..$34:
         begin
            if LatinOnly then begin
               if Hi(KeyCode) <= $32 then
                  GetAltChar := AltCodes1[Hi(KeyCode)];
            end else GetAltChar := AltCodesCyr[Hi(KeyCode)];
         end;
      $78..$83: GetAltChar := AltCodes2[Hi(KeyCode)];
    end;
end;

function GetAltCode(Ch: Char): Word;
var
  I: Word;
begin
  GetAltCode := 0;
  if Ch = #0 then Exit;
  Ch := UpCase(Ch);
  if Ch = #240 then
  begin
    GetAltCode := $0200;
    Exit;
  end;
  for I := $10 to $32 do
    if AltCodes1[I] = Ch then
    begin
      GetAltCode := I shl 8;
      Exit;
    end;
  for I := $78 to $83 do
    if AltCodes2[I] = Ch then
    begin
      GetAltCode := I shl 8;
      Exit;
    end;
end;

function GetCtrlChar(KeyCode: Word): Char;
begin
  GetCtrlChar := #0;
  if (Lo(KeyCode) <> 0) and (Lo(KeyCode) <= Byte('Z') - Byte('A') + 1) then
    GetCtrlChar := Char(Lo(KeyCode) + Byte('A') - 1);
end;

function GetCtrlCode(Ch: Char): Word;
begin
  GetCtrlCode := GetAltCode(Ch) or (Byte(UpCase(Ch)) - Byte('A') + 1);
end;


function CtrlToArrow(KeyCode: Word): Word;
const
  NumCodes = 10;
  CtrlCodes: array[0..NumCodes-1] of Char = ^S^D^E^X^A^F^G^V^R^C;
  ArrowCodes: array[0..NumCodes-1] of Word =
    (kbLeft, kbRight, kbUp, kbDown, kbHome, kbEnd, kbDel, kbIns,
     kbPgUp, kbPgDn);
var
  I: Integer;
begin
  CtrlToArrow := KeyCode;
  for I := 0 to NumCodes - 1 do
    if WordRec(KeyCode).Lo = Byte(CtrlCodes[I]) then
    begin
      CtrlToArrow := ArrowCodes[I];
      Exit;
    end;
end;

{ String formatting routine }

{$L FORMAT}

procedure FormatStr(var Result: String; Format: String; var Params);
external {FORMAT};

procedure PrintStr(S: String); assembler;
asm
	PUSH	DS
        LDS	SI,S
	CLD
	LODSB
	XOR	AH,AH
        XCHG	AX,CX
        MOV	AH,40H
        MOV	BX,1
        MOV	DX,SI
        INT	21H
        POP	DS
end;


function CStrLen(S: String): Integer; assembler;
asm
	LES	DI,S
	MOV	CL,ES:[DI]
	INC	DI
	XOR	CH,CH
	MOV	BX,CX
        JCXZ    @@2
	MOV	AL,'~'
        CLD
@@1:	REPNE	SCASB
	JNE	@@2
	DEC	BX
	JMP	@@1
@@2:	MOV	AX,BX
end;

procedure CStrToStr(Source : string; var Dest : string); assembler;
asm
        mov     dx,ds
        lds     si,Source
        cld
        lodsb
        mov     cl,al
        xor     ch,ch
        mov     bx,cx
        jcxz    @@4
        les     di,Dest
        inc     di
@@1:    lodsb
        cmp     al,'~'
        je      @@2
        stosb
        jmp     @@3
@@2:    dec     bl
@@3:    loop    @@1
@@4:    les     di,Dest
        mov     es:[di],bl
        mov     ds,dx
end;

{ Eventman unit initialization and shutdown }

var
  SaveExit: Pointer;

procedure ExitDrivers;
var
   S : word;
begin
  DoneSysError;
  DoneEvents;
  if EmulateMouseCursor then begin
     if SaveCursorArea <> nil then begin
         FreeMem(SaveCursorArea,CursorAreaSize);
     end;
  end;
  ExitProc := SaveExit;
end;

begin
  SaveExit := ExitProc;
  ExitProc := @ExitDrivers;
end.
