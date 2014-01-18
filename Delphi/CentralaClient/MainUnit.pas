unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TMainForm = class(TForm)
    EMail: TLabel;
    Pregled: TBitBtn;
    Analizi: TBitBtn;
    AnalizaPoDenovi: TBitBtn;
    Opcii: TBitBtn;
    Izlez: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure PregledClick(Sender: TObject);
    procedure AnaliziClick(Sender: TObject);
    procedure AnalizaPoDenoviClick(Sender: TObject);
    procedure OpciiClick(Sender: TObject);
    procedure IzlezClick(Sender: TObject);
    function FormHelp(Command: Word; Data: Integer;
      var CallHelp: Boolean): Boolean;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    Denari:Boolean;
    DenariVal:Extended;
    Path:String;
    Lozinka:String;
  end;

var MainForm: TMainForm;

implementation
uses Pregled, Analizi,AnaliziPoDenovi, Opcii,Registry, Lozinka;

{$R *.dfm}

procedure TMainForm.FormShow(Sender: TObject);
Label GetLozinka;
Var Reg:TRegistry;
    TSt:String;
    TRegData:TRegDataInfo;
    Err:Integer;
begin
Reg:=TRegistry.Create;
Reg.RootKey:=HKEY_LOCAL_MACHINE;
Reg.OpenKey('\Software\BokiCSoft\CentralaClient', True);
Reg.GetDataInfo('Password',TRegData);
if(TRegData.RegData=rdString)Then
  TSt:=Reg.ReadString('Password')
  else
  TSt:='';
if (TSt<>'') Then
   Begin
   LozinkaForm:=TLozinkaForm.Create(Self);
   GetLozinka:
   if (LozinkaForm.ShowModal=idOK)Then
        begin
        if (LozinkaForm.Lozinka.Text<>TSt) Then
           Begin
           Application.MessageBox('Greshna lozinka','Greshka',MB_OK);
           goto GetLozinka;
           End;
        end
        else
        Application.Terminate;
   LozinkaForm.Free;
   End;

Reg.GetDataInfo('Path',TRegData);
if(TRegData.RegData=rdString)Then
  Path:=Reg.ReadString('Path');

if (MainForm.Path[0]>#0)Then
   Begin
   if ((MainForm.Path[1]='/')And(MainForm.Path[Length(MainForm.Path)]<>'/'))Then
      MainForm.Path:=MainForm.Path+'/';
   if ((MainForm.Path[1]<>'/')And(MainForm.Path[Length(MainForm.Path)]<>'\'))Then
      MainForm.Path:=MainForm.Path+'\';
   End;

Reg.GetDataInfo('Denari',TRegData);
if(TRegData.RegData=rdInteger)Then
  Denari:=Reg.ReadBool('Denari');
if (Reg.GetDataType('Impuls')=rdString)Then
  TSt:=Reg.ReadString('Impuls')
  else
  TSt:='1';
val(TSt,DenariVal,Err);
if(Err<>0)Then
  DenariVal:=1;
if (FileExists(MainForm.Path+'Centrala.mdb')=False) Then
    Begin
    Pregled.Enabled:=False;
    Analizi.Enabled:=False;
    AnalizaPoDenovi.Enabled:=False;
    End;

Reg.Free;
end;

procedure TMainForm.PregledClick(Sender: TObject);
begin
PregledForm:=TPregledForm.Create(Self);
PregledForm.ShowModal;
PregledForm.Free;
end;

procedure TMainForm.AnaliziClick(Sender: TObject);
begin
AnaliziForm:=TAnaliziForm.Create(Self);
AnaliziForm.ShowModal;
AnaliziForm.Free;
end;

procedure TMainForm.AnalizaPoDenoviClick(Sender: TObject);
begin
AnaliziPoDenoviForm:=TAnaliziPoDenoviForm.Create(Self);
AnaliziPoDenoviForm.ShowModal;
AnaliziPoDenoviForm.Free;
end;

procedure TMainForm.OpciiClick(Sender: TObject);
begin
OpciiForm:=TOpciiForm.Create(Self);
OpciiForm.ShowModal;
OpciiForm.Free;

if (FileExists(MainForm.Path+'Centrala.mdb')) Then
    Begin
    Pregled.Enabled:=True;
    Analizi.Enabled:=True;
    AnalizaPoDenovi.Enabled:=True;
    End
    Else
    Begin
    Pregled.Enabled:=False;
    Analizi.Enabled:=False;
    AnalizaPoDenovi.Enabled:=False;
    End;
end;

procedure TMainForm.IzlezClick(Sender: TObject);
begin
Close;
//Application.Terminate;
end;

function TMainForm.FormHelp(Command: Word; Data: Integer;
  var CallHelp: Boolean): Boolean;
begin
//if (Data<=1024) then
//    WinHelp(Application.Handle,'CentralaClient.hlp',HELP_CONTEXTPOPUP,Data);
//CallHelp:=False;
FormHelp:=True;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var Reg:TRegistry;
begin
Reg:=TRegistry.Create;
Reg.RootKey:=HKEY_LOCAL_MACHINE;
Reg.OpenKey('\Software\BokiCSoft\CentralaClient', True);
Reg.WriteBool('Denari',Denari);
Reg.Free;
end;

end.
