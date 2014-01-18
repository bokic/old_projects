unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, XPMan;

type
  PRecnikItem=^TRecnikItem;
  TRecnikItem=Record
    Link:LongInt;
    Zbor:String[50];
    End;
type
  TMainForm = class(TForm)
    ComboBox: TComboBox;
    LeftList: TListBox;
    RightList: TListBox;
    XPManifest1: TXPManifest;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LeftListClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Angliski,Bugarski:TList;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

function SComp(Str1,Str2: String): Integer;
label Kraj;
var L,T,Ret:Integer;
Begin
L:=Length(Str1);
if(L>Length(Str2))Then
   L:=Length(Str2);
Ret:=0;
if(L>0)Then
   For T:=1 to L Do
      Begin
      if(Ord(Str1[T])>Ord(Str2[T]))Then
         Begin
         Ret:=1;
         goto Kraj;
         End;
      if(Ord(Str1[T])<Ord(Str2[T]))Then
         Begin
         Ret:=-1;
         goto Kraj;
         End;
      End;
if(Length(Str1)<>Length(Str2))Then
   if(Length(Str1)>Length(Str2))Then
      Ret:=1
      else
      Ret:=-1;
Kraj:
SComp:=Ret;
End;

function SortString(Item1, Item2: Pointer): Integer;
Begin
SortString:=SComp(PRecnikItem(Item1)^.Zbor,PRecnikItem(Item2)^.Zbor);
End;

procedure TMainForm.FormCreate(Sender: TObject);
var
   InFile: TextFile;
   Item:PRecnikItem;
   TSt:String;
   Count:LongInt;
   Pos:Integer;
begin
Angliski:=TList.Create;
Bugarski:=TList.Create;

System.FileMode:=fmOpenRead;
System.Assign(InFile,'Recnik.dat');
System.Reset(InFile);
Count:=0;
While(System.Eof(InFile)=False) Do
   Begin
   System.Readln(InFile,TSt);
   GetMem(Item,sizeof(TRecnikItem));
   Item^.Link:=Count;
   Pos:=System.Pos(',',TSt);
   Item^.Zbor:=System.Copy(TSt,1,Pos-1);
   Angliski.Add(Item);
   TSt:=Copy(TSt,Pos+1,Length(TSt)-Pos);
   While(System.Pos('/',TSt)<>0) Do
      Begin
      GetMem(Item,sizeof(TRecnikItem));
      Item^.Link:=Count;
      Pos:=System.Pos('/',TSt);
      Item^.Zbor:=System.Copy(TSt,Pos+1,Length(TSt)-Pos);
      Bugarski.Add(Item);
      TSt:=System.Copy(TSt,Pos+1,Length(TSt)-Pos);
      End;
   GetMem(Item,sizeof(TRecnikItem));
   Item^.Link:=Count;
   Item^.Zbor:=TSt;
   Bugarski.Add(Item);
   Count:=Count+1;
   End;
System.CloseFile(InFile);
Angliski.Sort(SortString);
Bugarski.Sort(SortString);
SendMessage(LeftList.Handle,WM_SETREDRAW,0,0);
For Count:=1 To Bugarski.Count Do
   LeftList.AddItem(PRecnikItem(Bugarski.Items[Count-1])^.Zbor,TObject(PRecnikItem(Bugarski.Items[Count-1])^.Link));
SendMessage(LeftList.Handle,WM_SETREDRAW,1,0);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var C:Integer;
begin
for c:=0 to Angliski.Count-1 do
   freemem(Angliski.Items[c],sizeof(TRecnikItem));
Angliski.Free;
for c:=0 to Bugarski.Count-1 do
   freemem(Bugarski.Items[c],sizeof(TRecnikItem));
Bugarski.Free;
end;

procedure TMainForm.LeftListClick(Sender: TObject);
var
   Pos:LongInt;
   Count:LongInt;
begin
Pos:=Integer(LeftList.Items.Objects[LeftList.ItemIndex]);
RightList.Clear;
For Count:=0 to Angliski.Count-1 Do
   Begin
   if (PRecnikItem(Angliski.Items[Count]).Link=Pos) Then
      RightList.AddItem(PRecnikItem(Angliski.Items[Count]).Zbor,nil);
   End;
end;
end.
