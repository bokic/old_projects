unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Sockets, XPMan;

type
  TMainForm = class(TForm)
    Address: TEdit;
    Send: TButton;
    TcpClient: TTcpClient;
    HostLabel: TLabel;
    UpSplitter: TSplitter;
    PortLabel: TLabel;
    Port: TEdit;
    PaintBox1: TPaintBox;
    PaintBox2: TPaintBox;
    SendText: TMemo;
    ReciveText: TMemo;
    Splitter1: TSplitter;
    XPManifest1: TXPManifest;
    procedure SendClick(Sender: TObject);
    procedure TcpClientError(Sender: TObject; SocketError: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.SendClick(Sender: TObject);
var TSt:string;
    Buf:TCaption;
    Count:Integer;
    Handle:Integer;
    PRead:Boolean;
    PWrite:Boolean;
    PExcept:Boolean;
begin
Send.Enabled:=false;
PRead:=False;PWrite:=False;PExcept:=False;
TCPClient.Select(@PRead,@PWrite,@PExcept,50);
if(PWrite=False) Then
   begin
   TCPClient.RemoteHost:=Address.Text;
   TCPClient.RemotePort:=Port.Text;
   TCPClient.Open;
   PWrite:=TCPClient.Connect();
   end;
PRead:=False;PWrite:=False;PExcept:=False;
TCPClient.Select(@PRead,@PWrite,@PExcept,50);
if(PWrite=False) Then
   begin
   TCPClient.Close;
   Send.Enabled:=true;
   exit;
   end;
ReciveText.Lines.Clear;
ReciveText.Update;
TCPClient.Sendln(SendText.Text);
//Sleep(1500);
Handle:=FileCreate('Dump'+Port.Text+'.txt',fmCreate);
Buf:='';
repeat
SetLength(TSt,255);
SetLength(TSt,TCPClient.ReceiveBuf(TSt[1],255));
if(Length(TSt)>0)Then
   begin
   FileWrite(Handle,TSt[1],Length(TSt));
   for Count:=1 to Length(TSt) do
      if (TSt[Count]=#0) Then
         TSt[Count]:=#32;
     Buf:=Buf+TSt;
     ReciveText.Text:=Buf;
     Update;
   end;
until(TCPClient.WaitForData(5000)=false);
TCPClient.Close;
Send.Enabled:=true;
FileClose(Handle);
end;

procedure TMainForm.TcpClientError(Sender: TObject; SocketError: Integer);
begin
ReciveText.Text:='Error';
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
TCPClient.Close;
TCPClient.Active:=False;
end;

end.
