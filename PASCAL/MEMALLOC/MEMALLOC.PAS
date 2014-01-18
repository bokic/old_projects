Unit MemAlloc;

{ Purpose is to provide the ability to create (destroy) dynamic variables  }
{ without needing to reserve heap space at compile time.                   }

Interface

Function Malloc(Var Ptr; Size : Word) : Word;
{ Allocate free memory and return a pointer to it.  The amount of memory      }
{ requested from DOS is calculated as (Size/4)+1 paragraphs.  If the          }
{ allocation is successful, the untyped VAR parameter Ptr will be populated   }
{ with the address of the allocated memory block, and the function will return}
{ a zero result.  Should the request to DOS fail, Ptr will be populated with  }
{ the value NIL, and the function will return the appropriate DOS error code. }

Function Dalloc(Var Ptr) : Word;
{ Deallocate the memory pointed to by the untyped VAR parameter Ptr           }

Function DosMemAvail : LongInt;
{ Return the size of the largest contiguous chuck of memory available for use }

{ --------------------------------------------------------------------------- }

Implementation

{ --------------------------------------------------------------------------- }

Function Malloc(Var Ptr; Size : Word) : Word;
Begin
   Inline(
     $8B/$46/<SIZE/         {            mov         ax,[bp+<Size]}
     $B9/$04/$00/           {            mov         cx,4}
     $D3/$E8/               {            shr         ax,cl}
     $40/                   {            inc         ax}
     $89/$C3/               {            mov         bx,ax}
     $B4/$48/               {            mov         ah,$48}
     $CD/$21/               {            int         $21             ;Allocate memory}
     $72/$07/               {            jc          AllocErr        ;If any errors ....}
     $C7/$46/$FE/$00/$00/   {NoErrors:   mov word    [bp-2],0        ;Return 0 for successful allocation}
     $EB/$05/               {            jmp short   Exit}
     $89/$46/$FE/           {AllocErr:   mov         [bp-2],ax       ;Return error code}
     $31/$C0/               {            xor         ax,ax           ;Store a NIL value into the ptr}
     $C4/$7E/<PTR/          {Exit:       les         di,[bp+<Ptr]    ;Address of pointer into es:di}
     $50/                   {            push        ax              ;Save the Segment part}
     $31/$C0/               {            xor         ax,ax           ;Offset is always 0}
     $FC/                   {            cld                         ;Make sure direction is upward}
     $AB/                   {            stosw                       ;Store offset of memory block}
     $58/                   {            pop         ax              ;Get back segment part}
     $AB);                  {            stosw                       ;Store segment of memory block}
   
End {Malloc};

{ --------------------------------------------------------------------------- }

Function Dalloc(Var Ptr) : Word;
Begin
   If Pointer(Ptr) <> NIL then begin
      Inline(
        $B4/$49/               {            mov         ah,$49}
        $C4/$7E/<PTR/          {            les         di,[bp+<Ptr]}
        $26/$C4/$3D/           {        es: les         di,[di]}
        $CD/$21/               {            int         $21}
        $72/$02/               {            jc          Exit}
        $31/$C0/               {NoError:    xor         ax,ax}
        $89/$46/$FE);          {Exit:       mov         [bp-2],ax}
      Pointer(Ptr) := NIL;
   end {if}
   else
      Dalloc := 0;
End {Dealloc};

{ --------------------------------------------------------------------------- }

Function DosMemAvail : LongInt;
Begin
   Inline(
     $BB/$FF/$FF/           {         mov         bx,$FFFF}
     $B4/$48/               {         mov         ah,$48}
     $CD/$21/               {         int         $21}
     $89/$D8/               {         mov         ax,bx}
     $B9/$10/$00/           {         mov         cx,16}
     $F7/$E1/               {         mul         cx}
     $89/$46/$FC/           {         mov         [bp-4],ax}
     $89/$56/$FE);          {         mov         [bp-2],dx}
end {DosMemAvail};

End {Unit MemAlloc}.

