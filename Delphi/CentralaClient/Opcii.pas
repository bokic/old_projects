unit Opcii;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TOpciiForm = class(TForm)
    GroupBox: TGroupBox;
    DBPath: TEdit;
    PathLabel: TLabel;
    StaraLozinka: TEdit;
    NovaLozinka1: TEdit;
    NovaLozinka2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Prebaraj: TBitBtn;
    Promeni: TBitBtn;
    Zapamti: TBitBtn;
    Label4: TLabel;
    Vrednost: TEdit;
    procedure FormShow(Sender: TObject);
    procedure PrebarajClick(Sender: TObject);
    procedure PromeniClick(Sender: TObject);
    procedure ZapamtiClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpciiForm: TOpciiForm;

implementation

{$R *.dfm}

uses MainUnit, Registry, ShlObj, ActiveX;

function SelectDirectory(out Directory: string): Boolean;
var
  WindowList: Pointer;
  BrowseInfo: TBrowseInfo;
  Buffer: PChar;
  RootItemIDList, ItemIDList: PItemIDList;
  ShellMalloc: IMalloc;
begin
  SelectDirectory := False;
  Directory := '';
  FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
  if (ShGetMalloc(ShellMalloc) = S_OK) and (ShellMalloc <> nil) then
  begin
    Buffer := ShellMalloc.Alloc(MAX_PATH);
    try
      RootItemIDList := nil;
      with BrowseInfo do
      begin
        hwndOwner := OpciiForm.Handle;
        pidlRoot := RootItemIDList;
        pszDisplayName := Buffer;
        lpszTitle := 'Select a Directory';
        ulFlags := BIF_RETURNONLYFSDIRS;
      end;
     WindowList := DisableTaskWindows(0);
      try
        ItemIDList := ShBrowseForFolder(BrowseInfo);
      finally
        EnableTaskWindows(WindowList);
      end;
      SelectDirectory :=  ItemIDList <> nil;
      if (Result) then
      begin
        ShGetPathFromIDList(ItemIDList, Buffer);
        ShellMalloc.Free(ItemIDList);
        Directory := Buffer;
      end;
    finally
      ShellMalloc.Free(Buffer);
    end;
  end;
end;

procedure TOpciiForm.FormShow(Sender: TObject);
Var Reg:TRegistry;
begin
Reg:=TRegistry.Create;
Reg.RootKey:=HKEY_LOCAL_MACHINE;
if (Reg.OpenKey('\Software\BokiCSoft\CentralaClient', False))Then
   Begin
   DBPath.Text:=Reg.ReadString('Path');
   Vrednost.Text:=Reg.ReadString('Impuls')
   End;
Reg.Free;
end;

procedure TOpciiForm.PrebarajClick(Sender: TObject);
var TSt: string;
begin
if (SelectDirectory(TSt)=True) then
    Begin
    DBPath.Text:=TSt;
    End;
end;

procedure TOpciiForm.PromeniClick(Sender: TObject);
Var Reg:TRegistry;
    TSt:String;
begin
Reg:=TRegistry.Create;
Reg.RootKey:=HKEY_LOCAL_MACHINE;
Reg.OpenKey('\Software\BokiCSoft\CentralaClient', True);
TSt:=Reg.ReadString('Password');
if (TSt<>StaraLozinka.Text) Then
    Begin
    Application.MessageBox('Старата лозинка не е точна..','Грешка',MB_OK);
    StaraLozinka.SetFocus;
    exit;
    End;
if (NovaLozinka1.Text<>NovaLozinka2.Text) Then
    Begin
    Application.MessageBox('Проверката за новата лозинка не е успешна..','Грешка',MB_OK);
    NovaLozinka1.SetFocus;
    exit;
    End;
Reg.WriteString('Password',NovaLozinka1.Text);
Application.MessageBox('Лозинката е успешно променета..','Информација',MB_OK);
StaraLozinka.Text:='';
NovaLozinka1.Text:='';
NovaLozinka2.Text:='';
end;

procedure TOpciiForm.ZapamtiClick(Sender: TObject);
Var
   Reg:TRegistry;
   Imp:Double;
   Err:Integer;
begin
Reg:=TRegistry.Create;
Reg.RootKey:=HKEY_LOCAL_MACHINE;
Reg.OpenKey('\Software\BokiCSoft\CentralaClient', True);
Reg.WriteString('Path',DBPath.Text);

MainForm.Path:=DBPath.Text;
if (MainForm.Path[0]>#0)Then
   Begin
   if ((MainForm.Path[1]='/')And(MainForm.Path[Length(MainForm.Path)]<>'/'))Then
      MainForm.Path:=MainForm.Path+'/';
   if ((MainForm.Path[1]<>'/')And(MainForm.Path[Length(MainForm.Path)]<>'\'))Then
      MainForm.Path:=MainForm.Path+'\';
   End;

if (Vrednost.Text<>'') Then
  Begin
  Val(Vrednost.Text,Imp,Err);
  if((Err<>0)Or(Imp=0))Then
    Begin
    Application.MessageBox('Вредноста во полето <Импулс> не е валидна..','Грешка',MB_OK);
    Vrednost.SetFocus;
    Reg.Free;
    Exit;
    End
    Else
    Reg.WriteString('Impuls',Vrednost.Text)
  End
  else
  Reg.DeleteValue('Impuls'); // Ne go brise, neznam zasto!!
Reg.Free;
Close;
end;

end.
