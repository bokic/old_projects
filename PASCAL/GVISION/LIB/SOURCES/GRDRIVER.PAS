{************************************************}
{   GrDriver.pas                                 }
{   Graph Vision unit                            }
{   Sergey E. Levov, Moscow,1992-1994            }
{************************************************}

unit GrDriver;

{$X+,I-,S-,P-,G+,D+}

interface
uses Graph;


{$IFDEF DPMI}
type

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

const
   StandardVGA = 0;
   Vesa16      = 1;
   Vesa256     = 2;

{   VGA640x350  = VGAMED;}
   VGA640x480  = VGAHI;

   Vesa16_800x600  = 0;
   Vesa16_1024x768 = 1;
   Vesa16_1280x1024= 2;

   Vesa256_640x400 = 0;
   Vesa256_640x480 = 1;
   Vesa256_800x600 = 2;
   Vesa256_1024x768= 3;
   Vesa256_1280x1024=4;

var
   ViewPort : ViewPortType;

const
   DriverType : integer = StandardVGA;
   DriverMode : integer = VGAHI;
   VesaDriverNames : array[1..2] of string[20] = ('vesa16','');
   DriverPaths : array[0..2] of string = ('','','');
   Vesa16Modes : array[0..2] of integer =
                 (Vesa16_800x600,Vesa16_1024x768,Vesa16_1280x1024);
   Vesa256Modes : array[0..4] of integer =
                 (Vesa256_640x400,Vesa256_640x480,Vesa256_800x600,Vesa256_1024x768,Vesa256_1280x1024);
   RegisterProc : procedure = nil;

procedure InitVideo;
procedure DoneVideo;

{ miscellaneous }

procedure SetWriteMode(WriteMode : integer);
procedure DrawImage(X,Y : integer; var Bitmap; BitBlt : word);
procedure MoveBlock(X1,Y1,X2,Y2,DeltaX,DeltaY : integer);

implementation
uses Objects,LowGraph,Memory,Crt;

const
   DriverTable : array[0..2] of integer = (VGA,0,0);
   BiosModes16 : array[0..2] of word = ($102,$104,$106);
   BiosModes256: array[0..4] of word= ($100,$101,$103,$105,$107);

procedure WriteErrorMessage(Code : integer);
begin
   Writeln('Graphics error: ', GraphErrorMsg(Code));
end;

function ValidMode(Driver,Mode : integer) : integer;
begin
   ValidMode := grOk;
   case Driver of
      StandardVga :
         if Mode <> VGA640x480 then ValidMode := grInvalidMode;
      Vesa16 :
         if (Mode < Vesa16_800x600) or (Mode > Vesa16_1280x1024)
         then ValidMode := grInvalidMode;
      Vesa256 :
         if (Mode < Vesa256_640x400) or (Mode > Vesa256_1280x1024)
         then ValidMode := grInvalidMode;
      else
         ValidMode := grInvalidDriver;
   end;
end;

procedure InitVideo;
var
   DMode,DType,i : integer;
   BiosMode : word;
   ErrorCode : integer;
begin
   if ValidMode(DriverType,DriverMode) <> grOk then begin
      WriteErrorMessage(ErrorCode);
      Halt(1);
   end;
   for i := 1 to 2 do begin
      if VesaDriverNames[i] <> '' then
         DriverTable[i] := InstallUserDriver(VesaDriverNames[i],nil);
   end;
   ErrorCode := 0;
   if @RegisterProc <> nil then RegisterProc;
   case DriverType of
      Vesa16 : begin
                  DMode := Vesa16Modes[DriverMode];
                  BiosMode := BiosModes16[DriverMode];
               end;
      Vesa256: begin
                  DMode := Vesa256Modes[DriverMode];
                  BiosMode := BiosModes256[DriverMode];
               end;
      StandardVGA : DMode := DriverMode;
   else
      ErrorCode := grInvalidDriver;
   end;
   if ErrorCode = grOk then begin
      DType := DriverTable[DriverType];
      InitGraph(DType,DMode,DriverPaths[DriverType]);
      ErrorCode := GraphResult;
   end;
   if ErrorCode <> grOk then begin
      WriteErrorMessage(ErrorCode);
      Halt(1);
   end;
   if DriverType <> StandardVGA then GetVesaModeInfo(BiosMode);
   if DriverType <> Vesa256 then begin
      SetUpMethods16;
      if (DriverType = Vesa16) and (DMode > 0) then Switchbank := true;
   end else SetupMethods256;
   ScreenWidth := GetMaxX + 1;
   ScreenHeight := getMaxY + 1;
   BytesPerLine := (ScreenWidth * BitPerPlane) shr 3;
end;

procedure DoneVideo;
begin
   CloseGraph;
end;

procedure SetWriteMode(WriteMode : integer);
const
  Modes : array[0..3] of byte = (0,$18,$10,$8);
begin
   Mode := Modes[WriteMode];
   Graph.SetWriteMode(WriteMode);
end;

function Adjust(var R : TRect) : boolean;
var
   V,R1 : TRect;
begin
   Adjust := false;
   with ViewPort do R.Move(X1,Y1);
   if not ViewPort.Clip then V.Assign(0,0,ScreenWidth,ScreenHeight)
   else with ViewPort do V.Assign(X1,Y1,X2+1,Y2+1);
   R1.Copy(R);
   R.Intersect(V);
   Adjust := not R1.Equals(R);
end;

procedure MoveBlock(X1,Y1,X2,Y2,DeltaX,DeltaY : integer);
var
   R : TRect;
begin
   if (DeltaX = 0) and (DeltaY = 0) then Exit;
   GetViewSettings(ViewPort);
   R.Assign(X1,Y1,X2+1,Y2+1);
   R.Move(DeltaX,DeltaY);
   Adjust(R);
   if not R.Empty then begin
      R.Move(-DeltaX,-DeltaY);
      with R do MovePixels(A.X,A.Y,B.X-1,B.Y-1,DeltaX,DeltaY);
   end;
end;

procedure DrawImage(X,Y : integer; var Bitmap; BitBlt : word);
var
   P : pointer;
   S : word;
   X1,X2,Y1,Y2 : integer;
   Nx1,Nx2,Ny1,Ny2 : integer;
   NeedClip : boolean;
begin
   GetViewSettings(ViewPort);
   with ViewPort do begin
      inc(X,X1);
      inc(Y,Y1);
      if not Clip then begin
         X1 := 0;
         Y1 := 0;
         X2 := ScreenWidth - 1;
         Y2 := ScreenHeight - 1;
      end;
   end;
   X1 := X;
   Y1 := Y;
   X2 := X + LongRec(Bitmap).Lo;
   Y2 := Y + LongRec(Bitmap).Hi;
   Nx1 := X1;
   Ny1 := Y1;
   NX2 := X2;
   Ny2 := Y2;
   NeedClip := false;
   with ViewPort do begin
      if Ny2 > Y2 then begin
         Ny2 := Y2;
         NeedClip := true;
      end;
      if Ny1 < Y1 then begin
         Ny1 := Y1;
         NeedClip := true;
      end;
   end;
   if (Ny2-Ny1+1) = 0 then Exit;
   with ViewPort do begin
      if Nx2 > X2 then begin
         Nx2 := X2;
         NeedClip := true;
      end;
      if Nx1 < X1 then begin
         Nx1 := X1;
         NeedClip := true;
      end;
   end;
   if NeedClip then begin
      if (Ny2 < Ny1) or (Nx2 < NX1) then Exit;
      S := ImageSize(Nx1,Ny1,Nx2,Ny2);
      P := MemAlloc(S);
      if P = nil then Exit;
      ExtractImage(Nx1-X1,Ny1-Y1,NX2-X1,Ny2-Y1,Bitmap,P^);
      with ViewPort do PutImage(Nx1-X1,Ny1-Y1,P^,BitBlt);
      FreeMem(P,S);
   end else with ViewPort do PutImage(Nx1-X1,NY1-Y1,Bitmap,BitBlt);
end;

var
  SaveExit: Pointer;

{$F+}
procedure ExitVideo;
begin
  DoneVideo;
  ExitProc := SaveExit;
end;
{$F-}

begin
  SaveExit := ExitProc;
  ExitProc := @ExitVideo;
end.

