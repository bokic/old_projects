unit NovoKontoUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TVnesiKonto = class(TForm)
    LabelKonto: TLabel;
    KontoOpis: TEdit;
    LabelOpis: TLabel;
    OpisOpis: TEdit;
    Insert: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure InsertClick(Sender: TObject);
  private
    { Private declarations }
    OldKonto:String;
  public
    { Public declarations }
  end;

var
  VnesiKonto: TVnesiKonto;

implementation

uses MainUnit;

{$R *.dfm}

procedure TVnesiKonto.FormShow(Sender: TObject);
begin
OldKonto:=KontoOpis.Text;
end;

procedure TVnesiKonto.FormKeyPress(Sender: TObject; var Key: Char);
begin
if (Key=#27) Then
   Begin
   Application.HandleMessage;
   ModalResult:=mrCancel;
   End;
end;

procedure TVnesiKonto.InsertClick(Sender: TObject);
Var Count:LongInt;
   KPl:PKPlanData;
begin
If (KontoOpis.Text='') Then
   Begin
   Application.MessageBox('Внесете шифра на конто','Грешка',IDOK);
   KontoOpis.SetFocus;
   Exit;
   End;
If (MainForm.KPlanList.Count>0)And(OldKonto<>KontoOpis.Text) Then
   Begin
   For Count:=0 To MainForm.KPlanList.Count-1 Do
      Begin
      KPl:=MainForm.KPlanList.Items[Count];
      If (KPl.Opis=KontoOpis.Text) Then
         Begin
         Application.MessageBox('Такво конто веќе постои!!','Грешка',IDOK);
         Exit;
         End;
      End;
   End;
end;
end.
