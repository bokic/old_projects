{************************************************}
{   ImgView.pas                                  }
{   Graph Vision Demo unit                       }
{   Sergey E. Levov, Moscow,1992-1994            }
{************************************************}

unit ImgView;
{$X+,G+,I-,S-,F+,O+,D-}

interface

uses Objects, Grav, Images;

type

  PImageViewer = ^TImageViewer;
  TImageViewer = object(GraphScroller)
    Img : PImage;
    constructor Init(var Bounds: TRect; AHScrollBar,
      AVScrollBar: PGraphScrollBar; AImage : PImage);
    destructor Done; virtual;
    procedure Draw; virtual;
  end;

  PImageWindow = ^TImageWindow;
  TImageWindow = object(GraphWindow)
     Viewer : PImageViewer;
     constructor Init(var Bounds : TRect; ATitle : String; AImage : PImage);
     constructor Load(var S : TStream);
     procedure Store(var S : TStream);
     procedure SizeLimits(var Min,Max : TPoint); virtual;
  end;

  PBmpWindow = ^TBmpWindow;
  TBmpWindow = object(TImageWindow)
     FileName : FNameStr;
     constructor Init(var Bounds : TRect; AFileName : FNameStr);
     constructor Load(var S : TStream);
     procedure Store(var S : TStream);
  end;

  PPcxWindow = ^TPcxWindow;
  TPcxWindow = object(TImageWindow)
     FileName : FNameStr;
     constructor Init(var Bounds : TRect; AFileName : FNameStr);
     constructor Load(var S : TStream);
     procedure Store(var S : TStream);
  end;

implementation
uses Graph, ExtObj, GrApp, MsgBox;

{TImageViewer methods }

constructor TImageViewer.Init(var Bounds: TRect; AHScrollBar,
  AVScrollBar: PGraphScrollBar; AImage : PImage);
var
   R : TRect;
begin
  if AImage <> nil then begin
     R.Copy(Bounds);
     R.B.X := R.A.X + AImage^.Size.X;
     R.B.Y := R.A.Y + AImage^.Size.Y;
     Bounds.Intersect(R);
     GraphScroller.Init(Bounds, AHScrollBar, AVScrollBar);
     Img := AImage;
     GrowMode := gfGrowHiX + gfGrowHiY;
     with Img^.Size do SetLimit(X-1, Y-1);
  end else Fail;
end;

destructor TImageViewer.Done;
begin
   if Img <> nil then Dispose(Img,Done);
   GraphScroller.Done;
end;

procedure TImageViewer.Draw;
var
  P : TPoint;
begin
   P.X := -Delta.X;
   P.Y := -Delta.Y;
   if Img <> nil then DrawImg(P,Img,NormalPut);
end;

{ TImageWindow methods }

constructor TImageWindow.Init(var Bounds : TRect; ATitle : String; AImage : PImage);
var
   R,R1 : TRect;
   HScrollBar, VScrollBar: PGraphScrollBar;
   Min,Max : TPoint;
   V : PImageViewer;
begin
   GraphWindow.Init(Bounds,ATitle,wfMove + wfGrow + wfTitle+ wfFramed + wfZoom + wfClose);
   Options := Options or ofTileable;
   VScrollBar := StandardScrollBar(sbVertical+sbHandleKeyboard);
   HScrollBar := StandardScrollBar(sbHorizontal+sbHandleKeyboard);
   WorkSpace^.GetExtent(R);
   R.Grow(-1,-1);
   R1.Copy(R);
   V := New(PImageViewer,Init(R,HScrollBar,VScrollBar,AImage));
   if V <> nil then begin
      inc(Bounds.B.X, R.B.X-R1.B.X);
      if (Bounds.B.X - Bounds.A.X) < MinWinSize.X then
         inc(Bounds.B.X,MinWinSize.X - Bounds.B.X + Bounds.A.X);
      inc(Bounds.B.Y, R.B.Y-R1.B.Y);
      if (Bounds.B.Y - Bounds.A.Y) < MinWinSize.Y then
         inc(Bounds.B.Y,MinWinSize.Y - Bounds.B.Y + Bounds.A.Y);
      ChangeBounds(Bounds);
      Viewer := V;
      Insert(Viewer);
   end else Fail;
end;

constructor TImageWindow.Load(var S : TStream);
begin
   GraphWindow.Load(S);
   GetSubViewPtr(S,Viewer);
end;

procedure TImageWindow.Store(var S : TStream);
begin
   GraphWindow.Store(S);
   PutSubViewPtr(S,Viewer);
end;

procedure TImageWindow.SizeLimits(var Min,Max : TPoint);
var
   S : TPoint;
begin
   GraphWindow.SizeLimits(Min,Max);
   if Viewer <> nil then begin
      S := Viewer^.Img^.Size;
      if Flags and wfThickFrame <> 0 then begin
         inc(S.X,10); inc(S.Y,10);
      end else begin
         inc(S.X,4); inc(S.Y,4);
      end;
      if Caption <> nil then inc(S.Y,Caption^.Size.Y+1);
      inc(S.X,15);
      inc(S.Y,15);
      if S.X < Min.X then S.X := Min.X;
      if S.Y < Min.Y then S.Y := Min.Y;
      if Max.X > S.X then Max.X := S.X;
      if Max.Y > S.Y then Max.Y := S.Y;
   end;
end;

constructor TBmpWindow.Init(var Bounds : TRect; AFilename : FNameStr);
var
   Filter : PBmpFilter;
   Wait : PMouseCursor;
   Image : PImage;
   Failed : boolean;
begin
   Filter := New(PBmpFilter,Init);
   FileName := AFileName;
   Wait := PMouseCursor(StdSharedresource^.Get('WAIT'));
   if Wait <> nil then Wait^.MakeActive;
   inc(LockMouseCursor);
   Image := New(PImage,Import(AFileName,Filter));
   Failed := TImageWindow.Init(Bounds,AFileName,Image);
   dec(LockMouseCursor);
   Application^.ChangeMouseCursor;
   if Filter^.ErrorCode <> giOk then begin
      case Filter^.ErrorCode of
         giNoLoadMem:
            MessageBox(#13'Not enough memory for this operation.',nil, mfError + mfOkButton);
         giInvalidFormat:
            MessageBox(#13'Unknow file format', nil, mfError + mfOkButton);
         giIOError:
            MessageBox(#13'Error reading file '#13+FileName,nil,mfError + mfOkButton);
         giError:
            MessageBox(#13'Too many colors',nil,mfError + mfOkButton);
      end;
      Fail;
   end;
   Dispose(Filter,Done);
end;

constructor TBmpWindow.Load(var S : TStream);
var
   Filter : PFilter;
begin
   TImageWindow.Load(S);
   S.Read(FileName[0],SizeOf(Char));
   S.Read(Filename[1],Length(FileName));
   Filter := New(PBmpFilter,Init);
   Viewer^.Img := New(PImage,Import(FileName,Filter));
   Dispose(Filter,Done);
end;

procedure TBmpWindow.Store(var S : TStream);
begin
   TImageWindow.Store(S);
   S.Write(FileName,Length(FileName)+1);
end;

constructor TPcxWindow.Init(var Bounds : TRect; AFilename : FNameStr);
var
   Filter : PPcxFilter;
   Wait : PMouseCursor;
   Image : PImage;
begin
   Filter := New(PPcxFilter,Init);
   FileName := AFileName;
   Wait := PMouseCursor(StdSharedresource^.Get('WAIT'));
   if Wait <> nil then Wait^.MakeActive;
   inc(LockMouseCursor);
   Image := New(PImage,Import(AFileName,Filter)); 
   TImageWindow.Init(Bounds,AFileName,Image);
   dec(LockMouseCursor);
   Application^.ChangeMouseCursor;
   if Filter^.ErrorCode <> giOk then begin
      case Filter^.ErrorCode of
         giNoLoadMem:
            MessageBox(#13'Not enough memory for this operation.',nil, mfError + mfOkButton);
         giInvalidFormat:
            MessageBox(#13'Unknow file format', nil, mfError + mfOkButton);
         giIOError:
            MessageBox(#13'Error reading file '#13+FileName,nil,mfError + mfOkButton);
         giError:
            MessageBox(#13'Too many colors',nil,mfError + mfOkButton);
      end;
      Fail;
   end;
   Dispose(Filter,Done);
end;

constructor TPcxWindow.Load(var S : TStream);
var
   Filter : PFilter;
begin
   TImageWindow.Load(S);
   S.Read(FileName[0],SizeOf(Char));
   S.Read(Filename[1],Length(FileName));
   Filter := New(PPcxFilter,Init);
   Viewer^.Img := New(PImage,Import(FileName,Filter));
   Dispose(Filter,Done);
end;

procedure TPcxWindow.Store(var S : TStream);
begin
   TImageWindow.Store(S);
   S.Write(FileName,Length(FileName)+1);
end;

end.
