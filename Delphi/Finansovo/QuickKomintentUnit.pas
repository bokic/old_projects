unit QuickKomintentUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids;

type
  TQuickKomintentForm = class(TForm)
    StringGrid: TStringGrid;
    SifraEdit: TEdit;
    ImeEdit: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure SifraEditChange(Sender: TObject);
    procedure ImeEditChange(Sender: TObject);
    procedure SifraEditKeyPress(Sender: TObject; var Key: Char);
    procedure ImeEditKeyPress(Sender: TObject; var Key: Char);
    procedure StringGridKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  QuickKomintentForm: TQuickKomintentForm;

implementation

{$R *.DFM}

uses MainUnit;

procedure TQuickKomintentForm.FormCreate(Sender: TObject);
begin
StringGrid.Cells[0,0]:='״טפנא';
StringGrid.Cells[1,0]:='ָלו';
StringGrid.ColWidths[1]:=275;
SifraEditChange(Sender);
end;

procedure TQuickKomintentForm.SifraEditChange(Sender: TObject);
var Firmi:PKomintentData;
    TSt:String;
    Count,C2:LongInt;
begin
C2:=0;
StringGrid.RowCount:=2;
StringGrid.Cells[0,1]:='';
StringGrid.Cells[1,1]:='';
If (MainForm.KomintentList.Count>0) Then
   For Count:=0 To MainForm.KomintentList.Count-1 Do
      Begin
      Firmi:=MainForm.KomintentList.Items[Count];
      Str(Firmi.Sifra,TSt);
      If ((Length(TSt)>=Length(SifraEdit.Text))And(Copy(TSt,1,Length(SifraEdit.Text))=SifraEdit.Text)) Then
         Begin
         Inc(C2);
         StringGrid.RowCount:=C2+1;
         StringGrid.Cells[0,C2]:=TSt;
         StringGrid.Cells[1,C2]:=Firmi.Ime;
         End;
      End;
end;

procedure TQuickKomintentForm.ImeEditChange(Sender: TObject);
var Firmi:PKomintentData;
    TSt:String;
    Count,C2:LongInt;
begin
C2:=0;
StringGrid.RowCount:=2;
StringGrid.Cells[0,1]:='';
StringGrid.Cells[1,1]:='';
If (MainForm.KomintentList.Count>0) Then
   For Count:=0 To MainForm.KomintentList.Count-1 Do
      Begin
      Firmi:=MainForm.KomintentList.Items[Count];
      If ((Length(Firmi.Ime)>=Length(ImeEdit.Text))And(Copy(AnsiUpperCase(Firmi.Ime),1,Length(ImeEdit.Text))=AnsiUpperCase(ImeEdit.Text))) Then
         Begin
         Inc(C2);
         StringGrid.RowCount:=C2+1;
         Str(Firmi.Sifra,TSt);
         StringGrid.Cells[0,C2]:=TSt;
         StringGrid.Cells[1,C2]:=Firmi.Ime;
         End;
      End;
end;

procedure TQuickKomintentForm.SifraEditKeyPress(Sender: TObject;
  var Key: Char);
begin
If (Key=#13) Then
   StringGrid.SetFocus;
end;

procedure TQuickKomintentForm.ImeEditKeyPress(Sender: TObject;
  var Key: Char);
begin
If (Key=#13) Then
   StringGrid.SetFocus;
end;

procedure TQuickKomintentForm.StringGridKeyPress(Sender: TObject;
  var Key: Char);
begin
If (Key=#13) Then
   ModalResult:=idOK;
end;

end.
