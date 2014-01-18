{************************************************}
{   Extobj.pas                                   }
{   Graph Vision unit                            }
{   Basic objects extension                      }
{   Sergey E. Levov, Moscow,1992-1993            }
{   Last changes: 7 March 1995                   }
{************************************************}
unit ExtObj;

{$F+,O+,S-,D-}

interface

uses Objects, Memory;

type

{ TByteFlow object }

  PByteFlow = ^TByteFlow;
  TByteFlow = object(TObject)
     Size : word;
     Data : pointer;
     constructor Init(ASize: word; AData: Pointer);
     constructor Load(var S : TStream);
     destructor Done; virtual;
     procedure Store(var S : TStream);
  end;

{ TMouseCursor }

  PMouseCursor = ^TMouseCursor;
  TMouseCursor = object(TObject)
     Size : TPoint;
     HotSpot : TPoint;
     Shape : pointer;
     constructor Init(ASize,AHotSpot : TPoint; AndPlane,XorPlane : Pointer);
     constructor Load(var S : TStream);
     destructor Done; virtual;
     procedure MakeActive;
     procedure Store(var S : TStream);
     private
     function ShapeSize : word;
  end;

{ TSharedResourceCollection }

  PSharedResourceCollection = ^TSharedResourceCollection;
  TSharedResourceCollection = object(TStringCollection)
    procedure FreeItem(Item: Pointer); virtual;
    function KeyOf(Item: Pointer): Pointer; virtual;
  end;

{ TSharedResource object }

  PSharedResource = ^TSharedResource;
  TSharedResource = object(TObject)
    ResourceFile : PResourceFile;
    constructor Init(AResourceFile : PResourceFile);
    destructor Done; virtual;
    function Count: Integer;
    procedure Free(Key: String);
    function Get(Key: String): PObject;
    function KeyAt(I: Integer): String;
  private
    Index: TSharedResourceCollection;
  end;

{ Extended memory stream }

{$IFNDEF DPMI}
   PXmsStream = ^TXmsStream;
   TXmsStream = object(TStream)
      Size : LongInt;
      Position : LongInt;
      constructor Init(ALimit : LongInt);
      destructor Done; virtual;
      function GetPos : LongInt; virtual;
      function GetSize : LongInt; virtual;
      procedure Seek(Pos : LongInt); virtual;
      procedure Truncate; virtual;
      procedure Read(var Buf; Count : word); virtual;
      procedure Write(var Buf; Count : word); virtual;
   private
      Blocks : word;
      Handle : word;
   end;
{$ENDIF}

{ stream registration routine for additional objects }

procedure RegisterExtObj;

const

{ Standard resorces file }

  StdResource : PResourceFile = nil;
  StdSharedResource : PSharedResource = nil;

const

{ Stream registration records }

  RByteFlow: TStreamRec = (
    ObjType: 53;
    VmtLink: Ofs(TypeOf(TByteFlow)^);
    Load: @TByteFlow.Load;
    Store: @TbyteFlow.Store);

  RMouseCursor : TStreamRec = (
    ObjType: 54;
    VmtLink: Ofs(TypeOf(TMouseCursor)^);
    Load: @TMouseCursor.Load;
    Store: @TMouseCursor.Store);

implementation
{$IFDEF DPMI}
uses EventMan;
{$ELSE}
uses Eventman,XMS;
{$ENDIF}

{ TByteFlow methods }

constructor TByteFlow.Init(ASize : word; AData: Pointer);
begin
   TObject.Init;
   if AData <> nil then begin
      Size := ASize;
      Data := AData;
   end else Fail;
end;

destructor TByteFlow.Done;
begin
   if Data <> nil then FreeMem(Data,Size);
   TObject.Done;
end;

constructor TByteFlow.Load(var S : TStream);
begin
   if LowMemory then Fail;
   S.Read(Size,SizeOf(Size));
   Data := MemAlloc(Size);
   if Data <> nil then
      S.Read(Data^,Size);
end;

procedure TByteFlow.Store(var S: TStream);
begin
   S.Write(Size,SizeOf(Size));
   S.Write(Data^,Size);
end;

{ TMouseCursor methods }

constructor TMouseCursor.Init(ASize,AHotSpot : TPoint;
                         AndPlane,XorPlane : Pointer);
var
   Bytes : word;
begin
   TObject.Init;
   Size := ASize;
   HotSpot := AHotSpot;
   Bytes := ShapeSize;
   Shape := MemAlloc(Bytes);
   Bytes := Bytes shr 1;
   Move(AndPlane^,Shape^,Bytes);
   Move(XorPlane^,PByteArray(Shape)^[Bytes],Bytes);
end;

constructor TMouseCursor.Load(var S : TStream);
begin
   S.Read(Size,SizeOf(TPoint) * 2);
   Shape := MemAlloc(ShapeSize);
   S.Read(Shape^,ShapeSize);
end;

destructor TMouseCursor.Done;
begin
   FreeMem(Shape,ShapeSize);
   TObject.Done;
end;

procedure TMouseCursor.MakeActive;
begin
   SetMouseCursor(HotSpot,Size,Shape);
end;

function TMouseCursor.ShapeSize : word;
begin
   ShapeSize := (Size.X shr 3) * Size.Y * 2;
end;

procedure TMouseCursor.Store(var S : TStream);
begin
   S.Write(Size,SizeOf(TPoint) shl 1);
   S.Write(Shape^,ShapeSize);
end;

{ internally used for TSharedResource }

type
  PSharedResourceItem = ^TSharedResourceItem;
  TSharedResourceItem = record
    Resource : PObject;
    Count : integer;
    Key: String;
  end;

{ TSharedResourceCollection }

procedure TSharedResourceCollection.FreeItem(Item: Pointer);
var
  Shared : PSharedresourceItem absolute Item;
begin
  if Shared^.Resource <> nil then Shared^.Resource^.Free;
  FreeMem(Shared, Length(Shared^.Key) +
    (SizeOf(TSharedResourceItem) - SizeOf(String) + 1));
end;

function TSharedResourceCollection.KeyOf(Item: Pointer): Pointer; assembler;
asm
	MOV	AX,Item.Word[0]
	MOV	DX,Item.Word[2]
	ADD	AX,OFFSET TSharedResourceItem.Key
end;


{ TSharedResource object }

constructor TSharedResource.Init(AResourceFile : PResourceFile);
begin
   TObject.Init;
   Index.Init(0,1);
   ResourceFile := AResourceFile;
end;

destructor TSharedResource.Done;
begin
   Index.Done;
   Dispose(ResourceFile,Done);
end;

function TSharedResource.Count: Integer;
begin
   Count := Index.Count;
end;

procedure TSharedResource.Free(Key: String);
var
   I : integer;
begin
   if Index.Search(@Key, I) then begin
      dec(PSharedResourceItem(Index.At(I))^.Count);
      if PSharedResourceItem(Index.At(i))^.Count <= 0
      then Index.Free(Index.At(I))
   end;
end;

function TSharedResource.Get(Key: String): PObject;
var
  I,J: Integer;
  P : PSharedResourceItem;
begin
  if not Index.Search(@Key, I) then begin
    J := Length(Key) + (SizeOf(TSharedResourceItem) - SizeOf(String) + 1);
    GetMem(P,J);
    P^.Key := Key;
    P^.Count := 1;
    P^.Resource := ResourceFile^.Get(Key);
    if P^.Resource <> nil then begin
       Index.AtInsert(I, P);
       Get := P^.Resource;
    end else begin
       Get := nil;
       FreeMem(P,j);
    end;
  end else begin
    inc(PSharedResourceItem(Index.At(I))^.Count);
    Get := PSharedResourceItem(Index.At(I))^.Resource;
  end;
end;

function TSharedResource.KeyAt(I: Integer): String;
begin
  KeyAt := PSharedResourceItem(Index.At(I))^.Key;
end;

{ TXmsStream methods }

{$IFNDEF DPMI }

constructor TXmsStream.Init(ALimit : LongInt);
begin
   TStream.Init;
   if not Xms_Initialized then begin
      Fail;
      Exit;
   end;
   Size := ALimit;
   Position := 0;
   Blocks := Alimit div Xms_BlockSize;
   if (ALimit mod Xms_BlockSize) <> 0 then inc(Blocks);
   Handle := Xms_GetMem(Blocks);
   if Xms_Status <> 0 then begin
      Blocks := 0;
      Error(stInitError,Xms_Status);
   end;
end;

destructor TXmsStream.Done;
begin
   Xms_FreeMem(Handle);
end;

function TXmsStream.GetPos : LongInt;
begin
   GetPos := Position;
end;

function TXmsStream.GetSize : LongInt;
begin
   GetSize := Size;
end;

procedure TXmsStream.Seek(Pos : LongInt);
begin
{   if Status = stOK then begin
      if Pos >= Size then Error(stReadError,Pos)}
{      else} Position := Pos;
{   end;}
end;

procedure TXmsStream.Truncate;
var
   B : word;
begin
   if Status = stOK then begin
      B := Position div Xms_BlockSize;  {***}
      if (Position mod Xms_BlockSize) <> 0 then inc(B);  {***}
      Xms_ResizeMem(Handle,B);
      if Xms_Status <> 0 then Error(stError,Xms_Status)
      else begin
         Size := Position;
         Blocks := B;
      end;
   end;
end;

procedure TXmsStream.Read(var Buf; Count : word);
var
  ByteBuf : array [0..1] of byte;
begin
   if Status = stOK then begin
      if (Position + Count) > Size then begin
         FillChar(Buf,Count,#0);
         Error(stReadError,Xms_Status);
      end else begin
        if Odd(Position) then begin
           Xms_MoveMem(pointer(Position and $FFFFFFFE),Handle,@ByteBuf,0,2);
           Byte(Buf) := ByteBuf[Position and 1];
           inc(Position);
           dec(Count);
           asm
              inc    Buf.word[0]
           end;
        end;
        Xms_MoveMem(pointer(Position),Handle,@Buf,0,LongInt(Count and $FFFE));
        if Odd(Count) then begin
           Xms_MoveMem(pointer(Position + LongInt(Count-1)),Handle,@ByteBuf,0,2);
           asm
              les     di,Self
              mov     di,es:[di].Position.word[0]
              and     di,1
              mov     al,ByteBuf.byte[di]
              les     di,Buf
              mov     bx,Count
              dec     bx
              mov     es:[di+bx],al
           end;
        end;
        if Xms_Status <> 0 then Error(stReadError,Xms_Status)
        else inc(Position,Count);
      end;
   end;
end;

procedure TXmsStream.Write(var Buf; Count : word);
var
   NS : LongInt;
   B : word;
   ByteBuf : array[0..1] of byte absolute B;
begin
   if Status = stOK then begin
      NS := Position + LongInt(Count);
      B := NS div Xms_BlockSize;
      if (NS mod Xms_BlockSize) <> 0 then inc(B);
      if B > Blocks then begin
         Xms_ResizeMem(Handle,B);
         if Xms_Status <> 0 then begin
            Error(stWriteError,Xms_Status);
            Exit;
         end;
         Blocks := B;
      end;
      if NS > Size then Size := NS;
      if Odd(Position) then begin
         Xms_MoveMem(pointer(Position and $FFFFFFFE),Handle,@ByteBuf,0,2);
         ByteBuf[Position and 1] := byte(Buf);
         Xms_MoveMem(@ByteBuf,0,pointer(Position and $FFFFFFFE),Handle,2);
         dec(Count);
         inc(Position);
         asm
            inc    Buf.word[0]
         end;
      end;
      Xms_MoveMem(@Buf,0,pointer(Position),Handle,LongInt(Count and $FFFE));
      if Odd(Count) then begin
         NS := Position + LongInt(Count-1);
         Xms_MoveMem(pointer(NS and $FFFFFFFE),Handle,@ByteBuf,0,2);
         asm
            les    di,Buf
            mov    bx,Count
            dec    bx
            mov    al,es:[di+bx]
            mov    di,NS.word[0]
            and    di,1
            mov    ByteBuf.byte[di],al
         end;
         Xms_MoveMem(@ByteBuf,0,pointer(NS and $FFFFFFFE),Handle,2);
      end;
      if Xms_Status <> 0 then Error(stWriteError,Xms_Status)
      else inc(Position,Count);
   end;
end;
{$ENDIF}

{ Additional objects registration procedure }

procedure RegisterExtObj;
begin
  RegisterType(RByteFlow);
  RegisterType(RMouseCursor);
end;

end.
