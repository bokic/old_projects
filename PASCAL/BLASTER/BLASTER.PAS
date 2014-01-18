{$A+,B-,D+,E-,F-,G+,I-,L+,N-,O-,R-,S-,X+}
{$M 16384,0,655360}
Unit Blaster;

Interface

CONST defaultvolume=31;    { full power =;) }
      IRQ_TABLE:array[0..15] of byte = ($08,$09,$0a,$0B,$0C,$0D,$0E,$0F,
                                        $70,$71,$72,$73,$74,$75,$76,$77);

    stereo_possible:Boolean=False; (* flag if stereo is possible on detected SB *)
    _16Bit_possible:Boolean=False; (* flag if 16bit play is possible on detected SB *)
    maxstereorate:word=0;          (* max stereo samplerate on detected SB *)
    maxmonorate:word=0;            (* max mono samplerate on detected SB *)

    Stereo:Boolean=False;       (* flag if stereo-play on/off *)
    _16Bit:Boolean=False;       (* flag if 16bit-play on/off *)
    SBNo:byte=0;                (* SoundBlaster typ (look some rows above) *)
    signeddata:boolean=False;   (* play signed data ? (only on SB16 possible) *)

    IRQ_No:Byte=5;              (* IRQ detected SB uses *)
    DSP_Addr:Word=$220;         (* Baseaddress detected SB uses *)
    DMA_Channel:Byte=1;         (* DMA channel for 8 Bit play *)
    DMA_16BitChannel:byte=5;    (* DMA channel for 16 Bit play *)

Procedure Forceto(typ,dma,dma16,irq:byte;dsp:word);     (* force to use these values for playing *)
Function UseBlasterEnv:boolean;                         (* use values set in enviroment BLASTER *)
Function DetectSoundblaster(prot:boolean):Boolean;      (* detects Soundblastercard *)

Function Detect_DSP_Addr(prot:boolean):Boolean;         (* detects DSP ADDR *)
Function Detect_DMA_Channel_IRQ(prot:boolean):Boolean;  (* detects DMA Channel,DSPIRQ *)
Function Get_BlasterVersion:Word;                       (* reads the detected soundblaster version *)

Procedure check_samplerate(var rate:word;var stereo:boolean); (* check min/max samplerate *)

Procedure set_DMAvalues(p:pointer;Length:word;autoinit:boolean);
  (* config DMAcontroller for different transfer modes *)
Procedure play_firstBlock(length:word);
  (* set the SBinterrupt to "interrupt" every "length" bytes
     the best way to use it, is to play the half buffersize and then
     write the new data in the allready played part
     - you have to setup DMA controller by calling set_DMAvalues *)
Procedure play_oneBlock(p:pointer;length:word);
  (* it's a play routine for playing only one buffer (NOT CONTINOUSLY
	  PLAYING ! - it does not work in that way on a SB16 !)
	  we use non autoinit mode here for all SBs...
	  this proc. setup DMA controller *)
Procedure Initblaster(var frequ:Word;stereoon,_16Biton:Boolean);
  (* set frequency and stereo/mono and 8/16 Bit mode *)

Procedure wr_mixerreg(reg,wert:byte);(* writes something to the mixing chip *)
Function  rd_mixerreg(reg:byte):byte;(* reads something from the mixing chip*)

Procedure set_ready_irq(p:pointer);
  (* set user irq - (irq if buffer ends !)
     attention look at my default irq !
     You need those two port commands you'll find there !
     And pay attention to 16bit/8bit mode on SB16 (different
     ackknowledgement ports) *)
Procedure stop_play;         (* stops playing ! *)
Procedure pause_play;        (* stops playing, but you can continue
										  with "continue_play" *)
Procedure continue_play;     (* continues playing after pause play *)
Procedure restore_irq;       (* restore old interrupt vector *)
Procedure set_sign(signed:boolean); (* sets flag to play signed data
					- does only work on SB16 (set it before start playing) *)
Procedure setvolume(vol:Byte);   (* what do you think ? *)
Procedure speaker_on;            (* Does not work on SB16 *)
Procedure speaker_off;
Procedure wr_dsp;
Procedure write_zaehler;         (* It's for 8 & 16 Bit mode to get the DMA counter *)
Function get_zaehler:word;      (* It's for 8 & 16 Bit mode to get the DMA counter *)
Function get_sample:Byte;
Implementation

Uses Dos,Crt;

{ Flags and variables for detect part : }
Const
    SB_Detect:Boolean=False;        { Flag if SB is detected }
    DSPIRQ_Detect:Boolean=False;    { Flag if IRQ number is detected }
    DSPADR_Detect:Boolean=False;    { Flag if Baseaddress is detected }
    DMACHN_Detect:Boolean=False;    { Flag if DMAchannel is detected }
    MIXER_Detect:Boolean=False;     { Flag if Mixerchip is detected }
    SBVersHi:Byte=0;                { Soundblaster version major }
    SBVersLo:Byte=0;                { Soundblaster version minor }

    check:byte=0;                   { for detecting }
	 savvect:pointer=nil;            {  "       "    }

{ Soundblaster handling : }

Function try_reset(p:word):Boolean;
Assembler;
Asm
 mov        bl,1
 mov        dx,p
 add        dx,6
 mov        al,1         { write 1 to port 2x6 }
 out        dx,al
 in         al,dx
 in         al,dx
 in         al,dx
 in         al,dx
 xor        al,al
 out        dx,al        { after 3,3 æs write 0 to port 2x6 }

{ And now check the answer }
 add        dx,8
 mov        si,200
@@readloop:
 mov        cx,0ffffh      { SB2.0/1.0 are that slow :( }
@@testl:                          { check for data available }
 in         al,dx
 dec        cx
 jz         @@not
 or         al,al
 jns        @@testl

 sub        dx,4
 in         al,dx        { read data comming through }
 cmp        al,0aah
 je         @@aSB
 add        dx,4
 dec        si
 jnz        @@readloop
@@not:
 mov        bl,0         { it's not a SB :( }
@@aSB:
 xor        ah,ah
 mov        al,bl
End;

Procedure wr_dsp;
Assembler;
Asm
 push      cx
 mov       ah,al
 mov       dx,dsp_addr
 add       dx,0Ch
 mov       cx,0ffffh
@@litl:
 in        al,dx
 dec       cx
 jz        @@ende
 or        al,al
 js        @@litl  { check bit 7 if we can write to port 2xC }
 mov       al,ah
 out       dx,al   { write it }
@@ende:
 pop       cx
End;

Function rd_dsp:byte;
Assembler;
Asm
 mov       dx,dsp_addr
 add       dx,0eh
 mov       cx,0ffffh
 @@litl:
 in        al,dx
 dec       cx
 jz        @@ende
 or        al,al
 jns       @@litl
 sub       dx,0eh-0ah
 in        al,dx
 xor       ah,ah
@@ende:
end;

Procedure speaker_off;
Assembler;
asm
 mov       al,0d3h
 call      wr_dsp
 push      220             { needs a bit time to switch it off }
 call 	  delay
End;


Procedure speaker_on;
Assembler;
Asm
 mov       al,0d1h
 call      wr_dsp
 push      110             { needs a bit time to switch it on }
 call 	  delay
End;

Procedure wr_mixerreg(reg,wert:byte);
Assembler;
Asm
 cmp       [SBNo],1
 je        @@nomixer                   { SB 1.0/1.5 has no mixer ! }
 cmp       SBNo,3
 je        @@nomixer                   { SB 2.0/2.5 has no mixer ! }
 mov       al,reg
 mov       dx,dsp_addr
 add       dx,4
 out       dx,al
 inc       dx
 in        al,dx
 mov       al,wert
 out       dx,al
@@nomixer:
End;

Function rd_mixerreg(reg:byte):byte;
Assembler;
Asm
 cmp       [SBNo],1
 je        @@nomixer                   { SB 1.0/1.5 has no mixer ! }
 cmp       SBNo,3
 je        @@nomixer                   { SB 2.0/2.5 has no mixer ! }
 mov     dx,dsp_addr
 add     dx,4
 mov     al,reg
 out     dx,al
 inc     dx
 in      al,dx
 xor     ah,ah
@@nomixer:
End;

Function loword(l:longint):word;
Assembler;
Asm
 mov         ax,word ptr(l)
End;

Function hiword(l:longint):word;
Assembler;
Asm
 mov         ax,word ptr(l+2)
End;

Procedure set_DMAvalues(p:pointer;Length:word;autoinit:boolean);
{ If you want to know more about how to setup DMA controller, please
  refer to our documentation SBLASTER.ZIP. }
Const pagetable:Array[0..7] of word = ($0087  { channel 0 },
                                       $0083  { channel 1 },
                                       $0081  { channel 2 <- not used by SB },
                                       $0082  { channel 3 },
                                       $008F  { channel 4 <- not used by SB },
                                       $008B  { channel 5 },
                                       $0089  { channel 6 },
                                       $008A  { channel 7 });
Begin
Asm
 cmp       [_16Bit],1      { setup 16bit DMA channels 4..7 is
									  ab bit different }
 je        @@higherDMA
									{ first the SBPRO stereo bugfix : }
 cmp       [stereo],0
 je        @@nostereo
 cmp       [sbNo],6
 jae       @@sbhigher
					 { well ... should be a SB PRO in stereo mode ... }
					 { let's send one byte ! }
 mov       al,10h
 call      wr_dsp
 mov       al,128   { nothin but silence ! }
 call      wr_dsp
@@sbhigher:
@@nostereo:
					 { convert pointer in realadress :
						dmapage*65536+dmaoffset = memsegment*16 + memoffset }
 mov       ax,word ptr(p+2)
 rol       ax,4
 mov       cl,al
 and       al,0f0h
 and       cl,0fh
 mov       di,ax         { cl:di - realadress ! }
 add       di,word ptr(p){ jas go dodadov }
 mov       bh,dma_channel { bh with dma_channel }
 mov       bl,bh
 shl       bl,1          { bl with dma_channel*2 }
 mov       ch,048h       { ch = 010010xx }
								 {     \| |+- read
										  | +- autoinit flag
										  +- singlemode }
 mov     al,[autoinit]
 shl     al,4
 or      ch,al              { set the autoinit flag }
 add     ch,dma_channel     { prepare for dma_channel }

 mov     al,4
 add     al,bh           { bh = dma_channel }
 out     0ah,al          { mask the channel }

 xor     al,al
 out     0ch,al          { clear flipflop }

 mov     al,ch           { ch = DMAmode }
 out     0bh,al          { set dmatransfer mode }
 mov     ax,di           { di = DMAbuffer offset }
 push    bx
 xor     bh,bh
 mov     dx,bx           { bx = 2*dma_channel }
 out     dx,al           { lower adress }
 mov     al,ah
 out     dx,al           { higer adress }
 mov     dx,word ptr (pagetable+bx)
 mov     al,cl           { cl = DMAbuffer page }
 out     dx,al           { data page }
 mov     dx,bx           { bx = 2*dma_channel }
 mov     ax,Length
 dec     ax
 inc     dx              { dx = write base count }
 out     dx,al           { write lower length }
 mov     al,ah
 out     dx,al           { write higer length }
 pop     bx
 mov     al,dma_channel
 out     0ah,al          { demask channel }
 jmp     @@endofsetauto
@@higherDMA:    { jump to here if 16bit DMA setup }
                { convert pointer in realadress : }
 mov       ax,word ptr(p+2)      { ax = segment of buffer }
 rol       ax,4                  { attention no offset ! }
 mov       cl,al
 and       al,0f1h
 and       cl,00eh
 xor       ax,1
 mov       di,ax                 { cl:di - realadress ! }

 mov     bh,dma_16Bitchannel     { bh with dma_channel }
 sub     bh,4                    { channel 4-7 to number 0-3 }
 mov     bl,bh
 shl     bl,2
 add     bl,0c0h       { bl = DMA adressport for current DMAchannel }
							  { bh = DMA16Bitchannel - 4  (0..3) }
 mov     ch,048h       { ch = 010010xx }
								{     \| |+-read
										 | +-autoinitflag
										 +-singlemode }
 mov     al,[autoinit]
 shl     al,4
 or      ch,al          { set the autoinitflag }
 add     ch,bh          { ch = command for DMAchannel # }

 mov     al,4
 add     al,bh           { bh = 16bitDMA_channel - 4 }
 out     0d4h,al         { mask the channel }
 xor     al,al
 out     0d8h,al         { clear flipflop }
 mov     al,ch           { ch = dmamode }
 out     0d6h,al         { set dmatransfer mode }
 mov     ax,di           { lower part of adress }
 push    bx
 xor     bh,bh           { bx now = c0h/c4h/c8h/cch (0..3) }
 mov     dx,bx           { bx = addressport for current channel }
 out     dx,al           { write lower adress }
 mov     al,ah
 out     dx,al           { write higer adress }
 mov     dl,dma_16Bitchannel
 xor     dh,dh
 mov     si,dx           { si = dma16Bitchannel }
 shl     si,1            { si - position in pagetable }
 mov     dx,word ptr (pagetable+si)
 mov     al,cl           { dmabuffer page }
 out     dx,al           { data page }
 mov     dx,bx           { old dx value ;) c0h/c4h/c8h/cch }
 mov     ax,Length
 dec     ax
 add     dx,2            { seperated by 2 -> dx now DMA base count }
 out     dx,al           { write lower length }
 mov     al,ah
 out     dx,al           { write higer length }
 pop     bx
 mov     al,bh
 out     0d4h,al         { demask channel }
@@endofsetauto:
  End;
End;

Function get_zaehler:word;
Assembler;
Asm
 cmp      [_16Bit],1
 je       @@get16
 xor      al,al
 out      0ch,al           { clear flipflop }
 mov      dl,dma_channel
 xor      dh,dh
 shl      dx,1
 inc      dx               { dx = channel * 2 + 1 = base counter }
 in       al,dx            { al = lower byte }
 mov      bl,al
 in       al,dx            { al = higher byte }
 mov      bh,al
 mov      ax,bx            { AX = high and low part together ;) - return that }
									{ bytes left to send = ax + 1 }
 jmp      @@endofget
@@get16:
 xor      al,al
 out      0d8h,al           { clear flipflop }
 mov      dl,dma_16Bitchannel
 xor      dh,dh
 sub      dl,4              { channel 4..7 to number 0..3 }
 shl      dx,2
 add      dx,0c2h           { dx = 0c2h + 4 * (channel-4) = 16bit base counter }
 in       al,dx             { AL = lower part }
 mov      bl,al
 in       al,dx             { AL = higher part }
 mov      bh,al
 mov      ax,bx             { AX = 16bit value ;) -
										number WORDS (!) left to send = ax + 1 }
@@endofget:
End;

Procedure write_zaehler;
Begin
writeLn(get_zaehler);
End;

Procedure play_firstBlock(length:word);
{ call this if you want to do continues play }
Begin
 Asm
 cmp       [SBNo],6
 je        @@sb16init          { use special commands on SB16 }

 mov       bl,90h              { DSP 90h - autoinit highspeed DMA }
 cmp       [SBNo],1
 jne       @@highspeed         { >SB1.0 use highspeed modes }
 { for SB1.0 : }
 mov       bl,1ch              { DSP 1Ch - autoinit normal DMA }
@@highspeed:
 mov       cx,length
 dec       cx
 mov       al,048h             { DSP 48h - setup DMA buffer size }
 call      wr_dsp
 mov       al,cl               { lower part of size }
 call      wr_dsp
 mov       al,ch               { higher part of size }
 call      wr_dsp
 mov       al,bl               { DSP command depends on SB }
 call      wr_dsp
 jmp       @@ende

@@sb16init:
 mov       cx,length
 dec       cx
 cmp       [_16Bit],1          { other command for 16bit play ... }
 je        @@play16Bit
 mov       al,0c6h             { DSP c6h - use 8bit autoinit }
 call      wr_dsp
 mov       al,signeddata
 shl       al,4                { 2nd command byte: bit 4 = 1 - signed data }
 cmp       [stereo],0
 je        @@nostereo
 or        al,020h             { 2nd command byte: bit 5 = 1 - stereo data }
@@nostereo:
 call      wr_dsp              { write 2nd command byte }
 mov       al,cl               { lower part of size }
 call      wr_dsp
 mov       al,ch               { higher part of size }
 call      wr_dsp
 jmp       @@ende
@@play16Bit:
 mov       al,0B6h             { DSP B6h - use 16bit autoinit }
 call      wr_dsp
 mov       al,signeddata
 shl       al,4                { 2nd command byte: bit 4 = 1 - signed data }
 cmp       [stereo],0
 je        @@nostereo2
 or        al,020h             { 2nd command byte: bit 5 = 1 - stereo data }
@@nostereo2:
 call      wr_dsp              { write 2nd command byte }
 mov       al,cl               { lower part of size }
 call      wr_dsp
 mov       al,ch               { higher part of size }
 call      wr_dsp
@@ende:
 End;
End;

Procedure play_oneBlock(p:pointer;length:word);
{ call this if you want to play only ONE (!) block - I'm sure you can do
  continues play with this proc. on SBs <SB16 (I have seen that often in
  other sources, but it'll definitly not work on a SB16 ! It'll cause
  'ticks' }
Begin
set_DMAvalues(p,length,false);
 Asm
 cmp       [SBNo],6
 je        @@sb16init          { use special commands on SB16 }

 mov       bl,91h              { DSP 91h - nonautoinit highspeed DMA }
 cmp       [SBNo],1
 je        @@highspeed         { >SB1.0 use highspeed mode }
 { On SB1.0 : }
 mov       bl,14h              { DSP 14h - nonautoinit normal DMA }
@@highspeed:
 mov       cx,length
 dec       cx
 mov       al,048h             { DSP 48h - setup DMA buffer size }
 call      wr_dsp
 mov       al,cl               { lower part of size }
 call      wr_dsp
 mov       al,ch               { higher part of size }
 call      wr_dsp
 mov       al,bl               { DSP command depends on SB }
 call      wr_dsp
 jmp       @@ende

@@sb16init:
 mov       cx,length
 dec       cx
 cmp       [_16Bit],1          { other command for 16bit play ... }
 je        @@play16Bit
 mov       al,0c2h             { DSP c2h - use 8bit nonautoinit }
 call      wr_dsp
 mov       al,signeddata
 shl       al,4                { 2nd command byte: bit 4 = 1 - signed data }
 cmp       [stereo],0
 je        @@nostereo
 or        al,020h             { 2nd command byte: bit 5 = 1 - stereo data }
@@nostereo:
 call      wr_dsp              { write 2nd command byte }
 mov       al,cl               { lower part of size }
 call      wr_dsp
 mov       al,ch               { higher part of size }
 call      wr_dsp
 jmp       @@ende
@@play16Bit:
 mov       al,0B2h             { DSP B2h - use 16bit nonautoinit }
 call      wr_dsp
 mov       al,signeddata
 shl       al,4                { 2nd command byte: bit 4 = 1 - signed data }
 cmp       [stereo],0
 je        @@nostereo2
 or        al,020h             { 2nd command byte: bit 5 = 1 - stereo data }
@@nostereo2:
 call      wr_dsp              { write 2nd command byte }
 mov       al,cl               { lower part of size }
 call      wr_dsp
 mov       al,ch               { higher part of size }
 call      wr_dsp
@@ende:
 End;
End;

Procedure SetTimeConst(tc:byte);
{ Setup samplerate with time constant, take this :
  TC = 256- TRUNC(1000000/SAMPLERATE) }
  begin
	 asm
      mov       al,040h
      call      wr_dsp
      mov       al,tc
      call      wr_dsp
    end;
  end;

Procedure Initblaster(Var frequ:Word;stereoon,_16Biton:boolean);
{ Initblaster does this :   1. check samplerates for its borders
                            2. Reset DSP chip
                            3. setup samplerate
                            4. setup stereo/mono mode
 if you want to play signed data on SB16, call 'set_sign' after Initblaster }

Var tc:byte;
Begin
{ first reset SB : }
 Asm
 mov    dx,dsp_addr
 add    dx,0eh
 in     al,dx
 inc    dx
 in     al,dx
 End;
stop_play;
{ Now init : }
check_samplerate(frequ,stereoon);
_16bit:=(SBNo=6) and _16Biton;
stereo:=stereoon;
{ calculate timeconstant - pay attention on SB PRO you have to setup
  2*samplerate in stereo mode (so call it byterate) - on SB16 not ! }
try_reset(dsp_addr);
If (sbno<6) Then
	Begin
	if (not stereo) Then
			 Begin
			 tc:=256-1000000 div frequ;
			 frequ:=1000000 div (256-tc);
			 End
		 Else
			 Begin
			 tc:=LongInt(256-1000000 div (2*frequ));
			 frequ:=(1000000 div (256-tc)) div 2;
			 End;
	asm
	{ on all normal SB's :) }
	mov      al,040h
	call     wr_dsp
	mov      al,tc
	call     wr_dsp
	End
  End
  Else
	Asm
	{ on SB16 }
	mov      al,041h
	call     wr_dsp
	les      di,Frequ
	mov      ax,es:[di]
	xchg     al,ah
	call     wr_dsp
	mov      al,ah
	call     wr_dsp
	End;
	 { setup stereo option on SB PRO - on SB16 it's set in DSP command }
If ((Stereo)and(SBNo<6)) Then
	wr_mixerreg($0e,rd_mixerreg($0e) or $02); { stereo option on (only SB PRO) }
If (SBNo in [2,4,5]) Then
	wr_mixerreg($0e,rd_mixerreg($0e) or $20); { filter option off (only SB PRO) }
If (SBNo<6) Then
	speaker_on;
End;

{ -------------- now the procedures for my old autodetection ------------- }
{ No comments about it - it's old ;)                                       }
Procedure irq2;
Interrupt;
Var a:byte;
Begin
check:=2;
port[$20]:=$20;
a:=port[dsp_addr+$0e];
End;

Procedure irq5;
Interrupt;
Var a:byte;
Begin
check:=5;
port[$20]:=$20;
a:=port[dsp_addr+$0e];
End;

Procedure irq7;
Interrupt;
Var a:byte;
Begin
check:=7;
port[$20]:=$20;
a:=port[dsp_addr+$0e];
End;

Procedure ready_irq;
Interrupt;
Var a:byte;
Begin
check:=1;
port[$20]:=$20;
a:=port[dsp_addr+$0e];
End;

Function hexword(w:word):String;
Const hex:String= '0123456789ABCDEF';
Begin
hexword:=hex[hi(w) div 16+1]+hex[hi(w) mod 16+1]+hex[lo(w) div 16+1]+hex[lo(w) mod 16+1];
End;

Function Detect_DSP_Addr(prot:boolean):Boolean;
Var p:word;
Begin
If (dspadr_detect) Then
	Begin
	detect_dsp_addr:=true;
	Exit;
	end;

If (prot) Then
	writeln('Now locating DSP-Adresse :'#13#10);
detect_dsp_addr:=false;
p:=$210;
While ((Not dspadr_detect) and (p<$290)) Do
	Begin
	If (prot) Then
		write(' Trying ',hexword(p),' .... ');
	dspadr_detect:=try_reset(p);
	If (Not dspadr_detect) Then
		begin
		inc(p,$10);
		If (prot) Then
			write('not ');
		End;
	If (prot) Then
		writeln('succesfull ');
	End;
If (Not dspadr_detect) Then
	exit;
dsp_addr:=p;
detect_dsp_addr:=true;
end;

Procedure reset_mixer;
Assembler;
Asm
 mov    dx,dsp_addr
 add    dx,4
 mov    al,0
 out    dx,al
 mov    cx,50
@@loop:
 loop @@loop
 inc    dx
 inc    al
 out    dx,al
End;

Function Detect_DMA_Channel_IRQ(prot:boolean):Boolean;
Const irqs:Array[1..3] of byte = (10,13,15); (* IRQ 2,5,7 *)
Var oldv:Array[1..3] of pointer;
    i,nr:byte;
    fr:word;
    ov1,ov2:byte;
Begin
 Asm
 cli
 mov al,0ffh
 out 0fh,al
 sti
 End;
If (dmachn_detect) Then
	Begin
	detect_DMA_Channel_irq:=true;
	exit;
	End;
If (prot) Then
	writeln(#13#10' Now locating DMA-channel and IRQ :'#13#10);
detect_dma_channel_irq:=False;
If (not dspadr_detect) Then
	exit;
For i:=1 To 3 Do
	Begin
	getintvec(irqs[i],oldv[i]);
	End;
setintvec(10,addr(irq2));
setintvec(13,addr(irq5));
setintvec(15,addr(irq7));
Detect_DMA_Channel_irq:=false;
port[$21]:=port[$21] and $5F;  { 01011111b = 05Fh }
nr:=0;
While ((nr<4)And(Not DMACHN_Detect)) Do
	Begin
	If (prot) Then
		write(' Trying Channel ',nr,' .... ');
	Check:=0;
	DMA_Channel:=nr;
	fr:=10000;
{        asm
			 mov al,dma_channel        { mask channel - means stop transfer }
{          or  al,$04 { Jas Go Dodadov }
{			 out 0ah,al
		  end;}
	stop_play;
	speaker_off;
	Initblaster(fr,false,false);
	play_oneblock(ptr(0,0),1);
	delay(10);
	DMACHN_Detect:=check<>0;
	If (Not DMACHN_Detect) Then
		Begin
		inc(nr);
		If (nr=2) Then
			nr:=3;
		If (prot) Then
			write('not ');
		End;
	If (prot) Then
		Begin
		write('sucessful');
		If (DMACHN_Detect) Then
			writeln(' with Interrupt ',IRQ_Table[check],' - IRQ ',check)
			Else
			writeln;
		End;
	End;
port[$21]:=port[$21] or $A0;  { 10100000b = 0A0h }
For i:=1 To 3 Do
	setintvec(irqs[i],oldv[i]);
If (Not dmachn_detect) Then
	exit;
Detect_DMA_Channel_irq:=True;
DSPIRQ_detect:=True;
IRQ_no:=Check;
try_reset(dsp_addr);
End;

Procedure Fix_blastertype;
Assembler;
Asm
 mov al,0E1h        { DSP E1h - get DSP version }
 call wr_dsp
 call rd_dsp
 mov sbversHi,al
 call rd_dsp
 mov sbversLo,al
end;

Function DetectSoundblaster(prot:boolean):Boolean;
Var T:Byte;
Begin
SBNo:=0;
DetectSoundblaster:=False;
SB_Detect:=False;
DSPIRQ_Detect:=False;
DSPADR_Detect:=False;
DMACHN_Detect:=False;
MIXER_Detect:=False;
stereo_possible:=False;
_16Bit_possible:=False;
STEREO:=False;_16Bit:=False;
If (Not Detect_DSP_Addr(prot)) Then
	Begin
	If (prot) Then
		writeln(' Can'#39't locate DSP-addresse ! ');
	Exit;
	End;
fix_blastertype;
If ((sbversHi<1)Or(sbversHi>4)) Then
	Begin
	If (prot) Then
		writeln(' Sorry, unknown DSP chip version on this base address detected.');
	SBno:=0;
	Exit;
	end;
{ for the first set SB1.0 - should work on all SBs }
SBNo:=1;
stereo_possible:=False;
_16Bit_possible:=False;
maxmonorate:=22050;
maxstereorate:=0;
stop_play;
If (sbversHi=4) Then
	Begin
	SBNo:=sbversHi;{Ovde}
	Case rd_mixerreg($80) of
		$01:Irq_No:=2;
		$02:Irq_No:=5;
		$04:Irq_No:=7;
		$08:Irq_No:=10;
		End;
	T:=rd_mixerreg($81);
	Case (T And $0F) of
		$01:DMA_Channel:=0;
		$02:DMA_Channel:=1;
		$08:DMA_Channel:=3;
		End;
	Case (T And $F0) of
		$20:DMA_16BitChannel:=5;
		$40:DMA_16BitChannel:=6;
		$80:DMA_16BitChannel:=7;
		End;
	End
	Else
	Begin
	If (Not Detect_DMA_Channel_irq(prot)) Then
		Begin
		If (prot) Then
			writeln(' Can'#39't locate DMA-channel and IRQ ! ');
		sbNo:=0;
		Exit;
		End;
	try_reset(dsp_addr);
	End;
{                              SBvers:
	SoundBlaster 1.0/1.5        1.xx
	SoundBlaster 2.0/2.5        2.xx
	SoundBlaster Pro/PRO3/PRO4  3.xx
	SoundBlaster 16/ASP         4.xx
}
Case sbversHi Of
		1: Begin
			SBNo:=1;stereo_possible:=False;_16Bit_possible:=False;
			  maxmonorate:=22050;maxstereorate:=0
			End;
		2: Begin
			  SBNo:=3;stereo_possible:=False;_16Bit_possible:=False;
			  maxmonorate:=44100;maxstereorate:=0
			End;
		3: Begin
			  SBNo:=2;stereo_possible:=True;_16Bit_possible:=False;
			  maxmonorate:=44100;maxstereorate:=22700
			End;
		4: Begin
			  SBNo:=6;stereo_possible:=True;_16Bit_possible:=True;
			  maxmonorate:=48000;maxstereorate:=48000
			End;
		Else
			Begin
			SBNo:=0;Exit
			End;
	 End;
DetectSoundblaster:=True;
End;

Function Get_BlasterVersion:Word;
Begin
Get_BlasterVersion:=word(SBVersHi)*256+SBVersLo;
End;

Procedure set_ready_irq(p:pointer);
Var b:byte;
Begin
check:=0;
getintvec(IRQ_Table[irq_no],savvect);
If (p=Nil) Then
	p:=addr(ready_irq);
setintvec(IRQ_Table[irq_no],p);
b:=1 shl irq_no;
b:=b or 04; { no changes for IRQ2 }
port[$21]:=port[$21] and not b; { masking ... }
End;

Procedure restore_irq;
Var b:byte;
Begin
b:=1 shl irq_no;
b:=b And Not 4; { no mask for IRQ2 }
port[$21]:=port[$21] or b;
setintvec(IRQ_Table[irq_no],savvect);
End;

Function ready:Boolean;
Begin
ready:=check>0;
End;

Procedure stop_play;
begin
{ for 16bit modes : }
 Asm
 mov   al,0d0h
 call  wr_dsp
 mov   al,0d9h
 call  wr_dsp
 mov   al,0d0h
 call  wr_dsp
 End;
 { for 8bit modes : }
 Asm
 mov   al,0d0h
 call  wr_dsp
 mov   al,0dah
 call  wr_dsp
 mov   al,0d0h
 call  wr_dsp
 End;
try_reset(dsp_addr);   { reset is the best way to make sure SB stops playing ! }
{    asm
		mov   al,dma_channel
{      or    al,$04   { Jas Go Dodadov }
{      out   0ah,al
	 end;}
End;

Procedure pause_play;
Begin
If (not _16bit) Then
	asm
	mov        al,0D0h
	call       wr_dsp
	End
	Else
	Asm
	mov        al,0D5h
	call       wr_dsp
	End
End;

Procedure continue_play;
Begin
If (Not _16bit) Then
	asm
	mov        al,0D4h
	call       wr_dsp
	End
	Else
	Asm
	mov        al,0D6h
	call       wr_dsp
	End
End;

Procedure set_sign(signed:boolean);
Begin
signeddata:=signed;
End;

Procedure setfilter(how:boolean);
Var b:byte;
Begin
b:=rd_mixerreg($0e);
If (how) Then { on }
	b:=b or $20
	Else
	b:=b And Not $20;
wr_mixerreg($0e,b); { switch the filter option }
End;

Procedure setvolume(vol:byte);
Var b:byte;
Begin
If (sbno<6) Then
	begin
	if (vol>=15) Then
		vol:=15;
	b:=vol;
	b:=b shl 4;        { the other side }
	vol:=b+vol;
	wr_mixerreg($22,vol);
	wr_mixerreg($04,vol);
	End
	Else
	Begin
	{ on SB16 the new mixer registers :) }
	wr_mixerreg($30,vol);  { master left }
	wr_mixerreg($31,vol);  { master right }
	wr_mixerreg($32,vol);  { Voice left }
	wr_mixerreg($33,vol);  { Voice right }
	End;
End;

Procedure Forceto(typ,dma,dma16,irq:byte;dsp:word);
Begin
SB_Detect:=True;
DSPIRQ_Detect:=True;
DSPADR_Detect:=True;
DMACHN_Detect:=True;
stereo:=False;
_16Bit:=False;

MIXER_detect:=typ>1;
stereo_possible:=typ in [2,4,5,6];
_16Bit_possible:= typ=6;
IRQ_No:=irq;
DSP_Addr:=dsp;
DMA_Channel:=DMA;
DMA_16BitChannel:=dma16;
SBNo:=typ;
Case typ of
	1: Begin maxmonorate:=22050;maxstereorate:=0 End;
	2: Begin maxmonorate:=44100;maxstereorate:=22050 End;
	3: Begin maxmonorate:=44100;maxstereorate:=0 End;
	4: Begin maxmonorate:=44100;maxstereorate:=22050 End;
	5: Begin maxmonorate:=44100;maxstereorate:=22050 End;
	6: Begin maxmonorate:=48000;maxstereorate:=48000 End;
	End;
End;

Function UseBlasterEnv:boolean;
Var s:String;
	 typ,dma,dma16,irq:byte;
	 dsp:word;

Function upstr(s:String):String;
Var t:String;
	i:byte;
Begin
t:='';
For i:=1 To length(s) Do
	t:=t+upcase(s[i]);
upstr:=t;
End;

Var count,i:byte;
	 u:String;
	 er:integer;
Begin
typ:=255;dma:=255;dma16:=255;irq:=255;dsp:=$ffff;
{ default values (totally crap), but if you get them after calling Use....}
{ you'll know that this value is not/wrong defined in the BLASTER env. }
UseBlasterEnv:=false;
s:=upstr(getenv('BLASTER'));
If (s='') Then
	Exit; { no chance :( }
count:=0;
{ SET BLASTER=A220 I? D? H? P??? T? }
i:=pos('T',s); { Soundblaster typ }
If (i>0) Then
	Begin
	u:=copy(s,i+1,1); { maybe for future blaster versions not right :( }
	val(u,typ,er);
	If (er=0) Then
		inc(count); { yeah we got this value ! }
	End;
i:=pos('D',s); { DMAchannel }
If (i>0) Then
	Begin
	u:=copy(s,i+1,1);
	Val(u,dma,er);
	If ((er=0) and (dma<4) and (dma<>2)) Then
		inc(count) { yeah we got it ! }
		Else
		dma:=255;
	End;
i:=pos('I',s); { IRQ number }
If i>0 Then
	Begin
	If (s[i+2]<>' ') Then
		u:=copy(s,i+1,2)
		Else
		u:=copy(s,i+1,1);
	val(u,irq,er);
	If ((er=0) And ((irq=2) or (irq=5) or (irq=7) or (irq=10))) Then
		inc(count)
		Else
		irq:=255;
	End;
i:=pos('H',s); { 16Bit DMAchannel }
If (i>0) Then
	Begin
	u:=copy(s,i+1,1);
	val(u,dma16,er);
	If ((er<>0) or (dma16<5) or (dma16>9)) Then
		dma16:=255;
		{ it does not matter if there's no value }
	End;
i:=pos('A',s); { DSPadress }
If (i>0) Then
	Begin
	u:=copy(s,i+1,3);
	val(u,dsp,er);
	dsp:=(dsp Div 100)*256+ ((dsp Div 10) Mod 10)*16 + dsp Mod 10;
	If ((er=0) And (dsp div 256 = 2) And (((dsp Mod 256) Div 16) in [2,3,4,5,6,7,8])) Then
		inc(count)
		Else
		dsp:=$ffff;
	End;
If (count=4) Then { we got all :) }
	forceto(typ,dma,dma16,irq,dsp)
	Else
	exit; { was not enough detectable }
UseBlasterEnv:=true;
End;

Procedure check_samplerate(var rate:word;var stereo:boolean);
Begin
stereo:=stereo And stereo_possible;
If (rate<5500) Then
	rate:=5500;
If (stereo) Then
	Begin
	If (rate>maxstereorate) Then
		rate:=maxstereorate;
	End
	Else
	If (rate>maxmonorate) Then
		rate:=maxmonorate;
End;

Function get_sample:Byte;
Assembler;
Asm
 mov dx,DSP_Addr
 cmp dx,0
 jne @OK
 mov al,$FF
 jmp @Kraj
@OK:
 add dx,$000C
@Loop1:
 in al,dx
 or al,al
 js @Loop1
 mov al,$0020
 out dx,al { Send the command }
 add dx,$0002

@Loop2:
 in al,dx
 or al,al
 jns @Loop2
 sub dx,$0004
 in al,dx
@Kraj:
End;


End.