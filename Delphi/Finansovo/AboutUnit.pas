unit AboutUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,ShellAPI;

type
  TAboutForm = class(TForm)
    OK: TButton;
    Name: TLabel;
    CopyRight: TLabel;
    Icon: TImage;
    Label1: TLabel;
    procedure Label1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation
{$R *.DFM}

procedure TAboutForm.Label1Click(Sender: TObject);
begin
ShellExecute(Self.ClientHandle,'open','mailto:bokicsof@freemail.org.mk','','',SW_SHOWNOACTIVATE);
end;

end.
