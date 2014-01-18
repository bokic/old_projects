Uses Crt, Dos;
const COM1INTR = $0C;
      COM1PORT = $3F8;
      COM2INTR = $0B;
      COM2PORT = $2F8;
      COM3INTR = $0C;
      COM3PORT = $3E8;
      COM4INTR = $0B;
      COM4PORT = $2E8;
var bytenum : word;
         combytes : array[0..2] of byte;
         x, y : longint;
         button1, button2 : boolean;
         MouseHandler :pointer;

procedure MyMouseHandler; Interrupt;
var dx, dy : integer;
var inbyte : byte;
begin

  { Get the port byte }
  inbyte := Port[COM1PORT];

  { Make sure we are properly "synched" }
  if (inbyte and 64) = 64 then bytenum := 0;

  { Store the byte and adjust bytenum }
  combytes[bytenum] := inbyte;
  inc(bytenum);

  { Have we received all 3 bytes? }
  if bytenum = 3 then
         begin
                { Yes, so process them }
                dx := (combytes[0] and 3) shl 6 + combytes[1];
                dy := (combytes[0] and 12) shl 4 + combytes[2];
                if dx >= 128 then dx := dx - 256;
                if dy >= 128 then dy := dy - 256;
                x := x + dx;
                y := y + dy;
                button1 := (combytes[0] And 32) <> 0;
                button2 := (combytes[0] And 16) <> 0;

                { And start on first byte again }
                bytenum := 0;
         end;

  { Acknowledge the interrupt }
  Port[$20] := $20;
end;

procedure InitMyDriver;
begin
  { Initialize the normal mouse handler }
  asm
         mov ax, 0
         int $33
  end;
  { Initialize some of the variables we'll be using }
  bytenum := 0;
  x := 0;
  y := 0;
  button1 := false;
  button2 := false;
  { Save the current mouse handler and set up our own }
  GetIntVec(COM1INTR, MouseHandler);
  SetIntVec(COM1INTR, Addr(MyMouseHandler));
end;

procedure CleanUpMyDriver;
begin
  SetIntVec(COM1INTR, MouseHandler);
end;

Begin
  ClrScr;
  InitMyDriver;
  while not keypressed do
         WriteLn(x : 5, y : 5, button1 : 7, button2 : 7);
  CleanUpMyDriver;
End.