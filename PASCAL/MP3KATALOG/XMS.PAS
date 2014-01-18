{************************************************}
{   Xms.pas                                      }
{   Graph Vision unit                            }
{   XMS support                                  }
{   Sergey E. Levov, Moscow,1992-1994            }
{************************************************}

Unit Xms;

Interface

Const
	XMS_Initialized : boolean = false;

Var
	Xms_Addr : pointer;
        Xms_Err_Addr : pointer;
	Xms_Status : byte;

Const
	Xms_BlockSize = 1024;

{ basic XMS - related procedures }

Function Xms_Init : boolean;
Function Xms_MemAvail : word;
Function Xms_MaxAvail : word;
Function Xms_GetMem(Size : word) : word;
Procedure Xms_FreeMem(Handle : word);
Procedure Xms_MoveMem(Source : pointer; SHandle : word;
          Dest  : pointer; DHandle : word;
          Count : LongInt);
Procedure Xms_ResizeMem(Handle,Size : word);

Implementation

Function Xms_Init : boolean;
Assembler;
Asm
		mov     ax,$4300        {Get Install State function}
		int     $2F             {call to XMS driver}
		cmp     al,$80          {XMS driver installed?}
		je      @@1             {no}
		xor     bx,bx
		mov     es,bx
		mov     ax,bx
		mov     byte ptr Xms_Status,$80
		jmp     @@2
@@1:
		mov     ax,$4310        {Get XMM Dispatch Addr func}
		int     $2F
		xor     ax,ax
		mov     byte ptr Xms_Status,al
		inc     ax
@@2:
		mov     Xms_Addr.word[0],bx
		mov     Xms_Addr.word[2],es
End;

Function Xms_MemAvail : word;
Assembler;
Asm
		mov     ah,8
		call    [Xms_Addr]
		mov     byte ptr Xms_Status,bl  { save status code }
		mov     ax,dx                   { dx - total free ext mem (in K bytes!)}
                cmp     bl,0                    { Error Code }
                je      @Ok
                cmp     word ptr ds:[Xms_Err_Addr],0
                jne     @Err
                cmp     word ptr ds:[Xms_Err_Addr+2],0
                jne     @Err
                jmp     @Ok
                @Err:
                les     si,ds:[Xms_Err_Addr]
                call    [Xms_Err_Addr]
                @Ok:
End;

Function Xms_MaxAvail : word;
Assembler;
asm
		mov     ah,8
		call    [Xms_Addr]
		mov     byte ptr Xms_Status,bl
                push    ax                      { Error Code }
                cmp     bl,0
                je      @Ok
                cmp     word ptr ds:[Xms_Err_Addr],0
                jne     @Err
                cmp     word ptr ds:[Xms_Err_Addr+2],0
                jne     @Err
                jmp     @Ok
                @Err:
                call    [Xms_Err_Addr]
                @Ok:
                pop     ax
End;

Function Xms_GetMem(Size : word) : word;
Assembler;
Asm
		mov     ah,9
		mov     dx,Size         { in K bytes! }
		call    [Xms_Addr]
		or      ax,ax           { error? }
		je      @@1             { yes }
		xor     bl,bl           { clear error code for any case }
		mov     ax,dx
@@1:
		mov     byte ptr Xms_Status,bl
                push    ax                      { Error Code }
                cmp     bl,0
                je      @Ok
                cmp     word ptr ds:[Xms_Err_Addr],0
                jne     @Err
                cmp     word ptr ds:[Xms_Err_Addr+2],0
                jne     @Err
                jmp     @Ok
                @Err:
                call    [Xms_Err_Addr]
                @Ok:
                pop     ax
End;

Procedure Xms_FreeMem(Handle : word);
Assembler;
Asm
		mov      ah,$A
		mov      dx,Handle
		call     [Xms_Addr]
		or       ax,ax
		je       @@1
		xor      bx,bx
@@1:
		mov      byte ptr Xms_Status,bl
                cmp     bl,0                    { Error Code }
                je      @Ok
                cmp     word ptr ds:[Xms_Err_Addr],0
                jne     @Err
                cmp     word ptr ds:[Xms_Err_Addr+2],0
                jne     @Err
                jmp     @Ok
                @Err:
                call    [Xms_Err_Addr]
                @Ok:
End;

Procedure Xms_MoveMem(Source : pointer; SHandle : word;
							 Dest  : pointer; DHandle : word;
							 Count : LongInt);
Assembler;
Asm
		mov     ax,Source.word[0]
		xchg    ax,Dest.word[0]
		mov     Source.word[0],ax
		mov     ax,Source.word[2]
		xchg    ax,Dest.word[2]
		mov     Source.word[2],ax
		mov     ax,SHandle
		xchg    ax,DHandle
		mov     SHandle,ax
		lea     si,Count
		push    ds
		pop     es
		push    ss
		pop     ds
		mov     ah,$B
		call    es:[Xms_Addr]
		push    es
		pop     ds
		or      ax,ax
		je      @@1
		xor     bx,bx
@@1:
		mov     byte ptr Xms_Status,bl
                cmp     bl,0                    { Error Code }
                je      @Ok
                cmp     word ptr ds:[Xms_Err_Addr],0
                jne     @Err
                cmp     word ptr ds:[Xms_Err_Addr+2],0
                jne     @Err
                jmp     @Ok
                @Err:
                call    [Xms_Err_Addr]
                @Ok:
End;

Procedure Xms_ResizeMem(Handle,Size : word);
Assembler;
Asm
		mov     ah,$F
		mov     dx,Handle
		mov     bx,Size
		call    [Xms_Addr]
		or      ax,ax
		je      @@1
		xor     bx,bx
@@1:
		mov     byte ptr Xms_Status,bl
                cmp     bl,0                    { Error Code }
                je      @Ok
                cmp     word ptr ds:[Xms_Err_Addr],0
                jne     @Err
                cmp     word ptr ds:[Xms_Err_Addr+2],0
                jne     @Err
                jmp     @Ok
                @Err:
                call    [Xms_Err_Addr]
                @Ok:
End;

Begin
Xms_Initialized := Xms_Init;
End.