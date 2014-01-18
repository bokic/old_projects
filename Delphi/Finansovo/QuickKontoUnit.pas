unit QuickKontoUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids;

type
  TQuickKontoForm = class(TForm)
    StringGrid: TStringGrid;
    KontoEdit: TEdit;
    OpisEdit: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure KontoEditChange(Sender: TObject);
    procedure OpisEditChange(Sender: TObject);
    procedure KontoEditKeyPress(Sender: TObject; var Key: Char);
    procedure OpisEditKeyPress(Sender: TObject; var Key: Char);
    procedure StringGridKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  QuickKontoForm: TQuickKontoForm;

implementation

{$R *.DFM}

uses MainUnit;

procedure TQuickKontoForm.FormCreate(Sender: TObject);
begin
StringGrid.Cells[0,0]:='״טפנא';
StringGrid.Cells[1,0]:='ָלו';
StringGrid.ColWidths[1]:=275;
KontoEditChange(Sender);
end;

procedure TQuickKontoForm.KontoEditChange(Sender: TObject);
var Konta:PKPlanData;
    Count,C2:LongInt;
begin
C2:=0;
StringGrid.RowCount:=2;
StringGrid.Cells[0,1]:='';
StringGrid.Cells[1,1]:='';
If (MainForm.KPlanList.Count>0) Then
   For Count:=0 To MainForm.KPlanList.Count-1 Do
      Begin
      Konta:=MainForm.KPlanList.Items[Count];
      If ((Length(Konta.Konto)>=Length(KontoEdit.Text))And(Copy(Konta.Konto,1,Length(KontoEdit.Text))=KontoEdit.Text)) Then
         Begin
         Inc(C2);
         StringGrid.RowCount:=C2+1;
         StringGrid.Cells[0,C2]:=Konta.Konto;
         StringGrid.Cells[1,C2]:=Konta.Opis;
         End;
      End;
end;

procedure TQuickKontoForm.OpisEditChange(Sender: TObject);
var Konta:PKPlanData;
    Count,C2:LongInt;
begin
C2:=0;
StringGrid.RowCount:=2;
StringGrid.Cells[0,1]:='';
StringGrid.Cells[1,1]:='';
If (MainForm.KPlanList.Count>0) Then
   For Count:=0 To MainForm.KPlanList.Count-1 Do
      Begin
      Konta:=MainForm.KPlanList.Items[Count];
      If ((Length(Konta.Opis)>=Length(OpisEdit.Text))And(Copy(AnsiUpperCase(Konta.Opis),1,Length(OpisEdit.Text))=AnsiUpperCase(OpisEdit.Text))) Then
         Begin
         Inc(C2);
         StringGrid.RowCount:=C2+1;
         StringGrid.Cells[0,C2]:=Konta.Konto;
         StringGrid.Cells[1,C2]:=Konta.Opis;
         End;
      End;
end;

procedure TQuickKontoForm.KontoEditKeyPress(Sender: TObject;
  var Key: Char);
begin
If (Key=#13) Then
   StringGrid.SetFocus;
end;

procedure TQuickKontoForm.OpisEditKeyPress(Sender: TObject; var Key: Char);
begin
If (Key=#13) Then
   StringGrid.SetFocus;
end;

procedure TQuickKontoForm.StringGridKeyPress(Sender: TObject;
  var Key: Char);
begin
If (Key=#13) Then
   ModalResult:=idOK;
end;

end.
