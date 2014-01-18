program AddResrc;
{$X+}
uses Crt,dos,Objects,ExtObj,Images;
type
  PNewImage = ^TNewImage;
  TNewImage = object(TImage)
     Name : FNameStr;
     Filter : PBmpFilter;
     constructor Import(AName : FNameStr; AFilter : PFilter);
     destructor Done; virtual;
     procedure Store(var S: TStream);
  end;


const
  RNewImage: TStreamRec = (
    ObjType: 90;
    VmtLink: Ofs(TypeOf(TNewImage)^);
    Load: nil;
    Store: @TnewImage.Store);


constructor TNewImage.Import(AName : FNameStr; AFilter : PFilter);
begin
   TObject.Init;
   Filter := PBmpFilter(AFilter);
   Filter^.Open(AName);
end;

destructor TNewImage.Done;
begin
   Dispose(Filter,Done);
   TObject.Done;
end;

procedure TNewImage.Store(var S : TStream);
var
   DataSize : LongInt;
   CurPos : LongInt;
begin
   S.Put(Filter);
   with Filter^ do begin
      CurPos := Stream^.GetPos;
      DataSize := Stream^.GetSize;
      DataSize := DataSize - SizeOf(TBitmapFileHeader);
      Stream^.Seek(CurPos);
      if Header.biSize = SizeOf(TBitmapInfoHeader) then begin
         S.Write(Header,SizeOf(TBitmapInfoHeader));
         dec(DataSize,SizeOf(TBitmapInfoHeader));
      end else begin
         S.Write(Header,SizeOf(TBitmapCoreHeader));
         dec(DataSize,SizeOf(TBitmapCoreHeader));
      end;
      S.CopyFrom(Stream^,DataSize);
   end;
end;

var
  Ch : Char;
  i : integer;
  NewRsc : TresourceFile;
  Nam : PCollection;
  Filter : PBmpFilter;

procedure AddIcon;
var
  Name : string;
  nn : FNameStr;
  Filter : PBmpFilter;
  Img : PImage;
begin
  repeat
     write('Icon name: ');
     readln(Name);
     if Name <> '' then begin
         write('    image:');
         readln(nn);
         if nn <> '' then begin
           Img := New(PNewImage,Import(nn,New(PBmpFilter,Init)));
           NewRsc.Put(Img,Name);
           Dispose(Img,Done);
        end;
     end;
  until Name = '';
end;

procedure AddButton;
var
  Name : string;
  nn : FnameStr;
  Nam : PCollection;
  Filter : PBmpFilter;
begin
  repeat
     write('Button name: ');
     readln(Name);
     if Name <> '' then begin
        Nam := New(PCollection,Init(1,1));
        repeat
           write('    image:');
           readln(nn);
           if nn <> '' then begin
              Nam^.Insert(New(PNewImage,Import(nn,New(PBmpFilter,Init))));
           end;
        until nn='';
        NewRsc.Put(Nam,Name);
        Dispose(Nam,Done);
     end;
  until Name = '';
end;

procedure AddMouse;
var
   Name : string;
   nn : FNameStr;
   Mouse : PMouseCursor;
   Masks : array[0..31] of word;
   Hot : TPoint;
   Size : TPoint;
   S : PStream;
begin
   repeat
      write('Cursor name : ');
      readln(Name);
      if Name <> '' then begin
          write('   file name : ');
          readln(nn);
          if nn <> '' then begin
             S := New(PDosStream, Init(nn,stOpen));
             S^.Read(Size,SizeOf(TPoint));
             S^.read(Hot,SizeOf(TPoint));
             S^.Read(Masks,64);
             dispose(S,Done);
             Mouse := New(PMouseCursor,Init(Size,Hot,@Masks[0],@Masks[16]));
             NewRsc.Put(Mouse,Name);
             Dispose(Mouse,Done);
          end;
      end;
   until Name = '';
end;


var
   Choice : integer;

begin
  if ParamCount = 0 then Halt;
  NewRsc.Init(New(PDosStream,Init(ParamStr(1),stOpen)));
  RegisterObjects;
  RegisterExtObj;
  RegisterType(RBmpFilter);
  RegisterType(RNewImage);
  repeat
     Writeln('1. Add icon');
     Writeln('2. Add bitmap button');
     Writeln('3. Add mouse cursor');
     Writeln('4. Exit');
     Write('Choose : ');
     Readln(Choice);
     case Choice of
        1 : AddIcon;
        2 : AddButton;
        3 : AddMouse;
     end;
  until (Choice = 4);
  WRITELN(NewRsc.Count);
  for i := 0 to NewRsc.Count-1 do writeln(NewRsc.KeyAt(i));
  readln;
  NewRsc.done;
end.