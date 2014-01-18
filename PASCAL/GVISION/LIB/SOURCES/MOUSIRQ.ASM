	TITLE	MOUSIRQ

	LOCALS	@@

; Version equates

    IFDEF _DPMI_
DPMIVersion	EQU	1
    ELSE
DPMIVersion	EQU	0
    ENDIF

; Double word record

w0		EQU	(WORD PTR 0)
w2		EQU	(WORD PTR 2)

    IF DPMIVersion

; DPMI interrupt vector number

DPMI		EQU	31H

; DPMI function codes

dpmiAllocDesc	EQU	0000H		;Allocate descriptor
dpmiFreeDesc	EQU	0001H		;Free descriptor
dpmiGetProtInt	EQU	0204H		;Get protected mode interrupt vector
dpmiSetProtInt	EQU	0205H		;Set protected mode interrupt vector

    ENDIF
; Data segment

_DATA		SEGMENT WORD PUBLIC 'DATA'

    IF DPMIVersion

	EXTRN	SelectorInc:WORD
	EXTRN	Seg0040:WORD
	EXTRN	RealModeRegs:BYTE

    ENDIF

VectNo          db      0       ;vector to be replaced

TempSel         dw      ?

_DATA		ENDS

; Data group

DGROUP		GROUP	_DATA

; Code segment

MOUSEIRQ_TEXT	SEGMENT	BYTE PUBLIC 'CODE'

	ASSUME	CS:MOUSEIRQ_TEXT,DS:DGROUP

	PUBLIC	HookMouseHardInt
	PUBLIC	RestoreMouseHardInt
        PUBLIC  SaveVideoRegs 
        PUBLIC  RestoreVideoRegs

; CS-based variable

OldHardInt	dd	0	;Save old mouse hardware int vector

SaveRegs	db      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

HookMouseHardInt proc FAR
        push    bx
        mov     ax,24h            ;get mouse hardware info
        int     33h
        cmp     ax,0FFFh          ;error?
        je      @@2               ;yes
        pop     ax
        cmp     bx,ax             ;check for some old drivers
        je      @@2
        cmp     cl,1
        je      @@2               ;mouse irq is undefined
        mov     al,cl
        add     al,8              ;convert irq to vector no
        mov     VectNo,al         ;save vector no
        push    ax
   IF DPMIVersion
        mov     ax,dpmiAllocDesc
        mov     cx,1
        int     DPMI
        mov     TempSel,ax
        mov     ax,cs
        add     ax,SelectorInc
        pop	bx
        mov     es,ax
        mov     ax,dpmiGetProtInt       ;get vector
        int     DPMI
        mov     di, offset OldHardInt   ;save it
        mov     es:[di],dx
        mov     es:[di+2],cx
        mov     cx,cs
        mov     dx,offset MouseHardInt  ;set new vector
        mov     ax,dpmiSetProtInt
        int     DPMI
   ELSE
        mov     ah,35h            ;get vector;
        int     21h
        mov     si, offset OldHardInt
        mov     cs:[si],bx
        mov     cs:[si+2],es
        pop     ax
        mov     ah,25h          ;set vector func
        push    ds              ;save ds
        push    cs
        pop     ds
        mov     dx, offset MouseHardInt
        int     21h             ;set vector
        pop     ds
   ENDIF
        mov     ax,1
@@1:	retf
@@2:    xor     ax,ax
        jmp     @@1
HookMouseHardInt endp

; Restore mouse hardware int vector

RestoreMouseHardInt proc FAR
        mov     al, VectNo
        or      al,al
        je      @@1
        push    ds
        mov	si,offset OldHardInt
   IF DPMIVersion
        push    cs
        pop     ds
        mov     dx,[si]
        mov     cx,[si+2]
        mov     bl,al
        mov     ax,dpmiSetProtInt
        int     DPMI
        pop	ds
        mov     ax,dpmiFreeDesc
        mov	bx,TempSel
        int     DPMI
   ELSE
        mov     dx,cs:[si]
        mov	di,cs:[si+2]
        mov     ds,di
        mov     ah,25h                  ;restore old vector
        int     21h
	pop	ds
   ENDIF
@@1:    retf
RestoreMouseHardInt endp

SaveVideoRegs proc FAR
        pushf
        cli
        mov	ax,cs
   IF DPMIVersion
        mov	dx, SEG DGROUP
        mov	ds,dx
        add	ax,SelectorInc
   ENDIF
        mov	es,ax
        mov     si, offset cs:SaveRegs
        mov     dx,03CCh
        in      al,dx
        mov     es:[si],al
        inc     si
        mov     dx,03CAh
        in      al,dx
        mov     es:[si],al
        inc     si
        mov     dx,03C4h
        in      al,dx
        push    ax
        xor     ax,ax
@@0:    out     dx,al
        inc     dx
        xchg    ah,al
        in      al,dx
        xchg    al,ah
        mov     es:[si],ah
        inc     si
        inc     al
        dec     dx
        cmp     al,5
        jle     @@0
        pop     ax
        mov     es:[si],al
        inc     si
	mov	dx,03CEh
        in      al,dx
        push    ax
	xor	ax,ax
@@1:    out	dx,al
        inc	dx
        xchg	ah,al
        in	al,dx
        xchg	al,ah
        mov	es:[si],ah
        inc	al
	inc	si
	dec	dx
	cmp	al,8
	jle	@@1
        pop     ax
        mov     es:[si],al
        sti
        popf
        retf
SaveVideoRegs endp

RestoreVideoRegs proc FAR
        pushf
        cli
        mov	ax,cs
   IF DPMIVersion
        mov	dx, SEG DGROUP
        mov	ds,dx
        add	ax,SelectorInc
   ENDIF
        mov	es,ax
        mov     si,offset cs:SaveRegs
        mov     dx,03C2h
        mov     al,es:[si]
        out     dx,al
        inc     si
        mov     dx,03CAh
        mov     al,es:[si]
        out     dx,al
        inc     si
        mov     dx,03C4h
        xor     ax,ax
@@2:    mov     ah,es:[si]
        out     dx,ax
        inc     si
        inc     al
        cmp     al,5
        jle     @@2
        mov     al,es:[si]
        inc     si
        out     dx,al
	mov	dx,03CEh
        xor	ax,ax
@@3:	mov	ah,es:[si]
	out	dx,ax
	inc	si
	inc	al
        cmp	al,8
	jle	@@3
        mov     al,es:[si]
        out     dx,al
        sti
        popf
	retf
RestoreVideoregs endp

MouseHardInt:
        push    ds
        push    es
        push    ax
        push    dx
        push    si
        pushf
	cli
        call    SaveVideoRegs 
        call    OldHardInt              ;call old interrupt handler
        call    RestoreVideoRegs
	sti
        pop     si
        pop     dx
        pop     ax
        pop     es
        pop     ds
        iret

MOUSEIRQ_TEXT	ENDS

	END
