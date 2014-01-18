unit AnaliziPoDenovi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, TeeProcs, TeEngine, Chart, DbChart, DB, ADODB,
  StdCtrls, Buttons, ComCtrls, Series, DBCtrls;

type
  TAnaliziPoDenoviForm = class(TForm)
    DBChart: TDBChart;
    OdDatumLabel: TLabel;
    DoDatumLabel: TLabel;
    OdDatum: TDateTimePicker;
    DoDatum: TDateTimePicker;
    Prebaraj: TBitBtn;
    DataSource: TDataSource;
    ADOQuery: TADOQuery;
    ADOConnection: TADOConnection;
    Pecati: TBitBtn;
    DBLookupComboBox: TDBLookupComboBox;
    DataSource2: TDataSource;
    ADOTable: TADOTable;
    CheckBox: TCheckBox;
    Series1: TLineSeries;
    DenariBtn: TRadioButton;
    ImpulsiBtn: TRadioButton;
    ADOQueryVkupno: TFloatField;
    ADOQueryDenVkupno: TCurrencyField;
    ADOQueryDatum: TDateTimeField;
    procedure PecatiClick(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure PrebarajClick(Sender: TObject);
    procedure DBLookupComboBoxClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DBChartDblClick(Sender: TObject);
    procedure OdDatumChange(Sender: TObject);
    procedure DoDatumChange(Sender: TObject);
    procedure ImpulsiBtnClick(Sender: TObject);
    procedure DenariBtnClick(Sender: TObject);
    procedure ADOQueryCalcFields(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AnaliziPoDenoviForm: TAnaliziPoDenoviForm;

implementation

uses TeePrevi, MainUnit;

{$R *.dfm}

procedure TAnaliziPoDenoviForm.PecatiClick(Sender: TObject);
begin
ChartPreview(Self,dbChart);
end;

procedure TAnaliziPoDenoviForm.CheckBoxClick(Sender: TObject);
begin
if (CheckBox.State=cbChecked) Then
    Begin
    ADOTable.Active:=True;
    DBLookupComboBox.Enabled:=True;
    if (DBLookupComboBox.Text='') Then
        Prebaraj.Enabled:=False
        Else
        Prebaraj.Enabled:=True;
    End
    else
    Begin
    DBLookupComboBox.Enabled:=False;
    ADOTable.Active:=False;
    Prebaraj.Enabled:=True;
    End;
Pecati.Enabled:=False;
end;

procedure TAnaliziPoDenoviForm.PrebarajClick(Sender: TObject);
begin
Prebaraj.Enabled:=False;
Cursor:=crSQLWait;
ADOQuery.Active:=False;
ADOQuery.SQL.Clear;
if (CheckBox.Checked) Then
    Begin
    ADOQuery.SQL.Text:='SELECT Int([Vreme]) AS Datum, Sum(MAIN.Impulsi) AS Vkupno FROM (Firmi INNER JOIN Lokali ON Firmi.ID = Lokali.Firma) INNER JOIN MAIN ON Lokali.Lokal = MAIN.Lokal WHERE (((Firmi.Firma)="'+DBLookUpComboBox.Text+'")AND((Int(Vreme)>=OdDatum) AND (Int(Vreme)<=DoDatum))) GROUP BY Int([Vreme]);';
    DBChart.Title.Text.Text:='Временски диаграм на трошок за '+DBLookupComboBox.Text+'.';
    End
    Else
    Begin
    ADOQuery.SQL.Text:='SELECT Int([Vreme]) AS Datum, Sum(MAIN.Impulsi) AS Vkupno FROM MAIN WHERE((Int(Vreme)>=OdDatum) AND (Int(Vreme)<=DoDatum)) GROUP BY Int([Vreme]);';
    DBChart.Title.Text.Text:='Временски диаграм на трошок.';
    End;

ADOQuery.Parameters.Clear;
with ADOQuery.Parameters.AddParameter do
    begin
    DataType := ftDate;
    Name := 'OdDatum';
    Value := Int(OdDatum.Date);
    end;
with ADOQuery.Parameters.AddParameter do
    begin
    DataType := ftDate;
    Name := 'DoDatum';
    Value := Int(DoDatum.Date);
    end;

if (MainForm.Denari) Then
  Begin
  DBChart.LeftAxis.Title.Caption:='Денари';
  DBChart.SeriesList.Series[0].YValues.ValueSource:='DenVkupno';
  End
  Else
  Begin
  DBChart.LeftAxis.Title.Caption:='Импулси';
  DBChart.SeriesList.Series[0].YValues.ValueSource:='Vkupno';
  End;
ADOQuery.Open;
Cursor:=crDefault;
if (ADOQuery.RecordCount>0) Then
   Pecati.Enabled:=True
   else
   Pecati.Enabled:=False;
Prebaraj.Enabled:=True;
end;

procedure TAnaliziPoDenoviForm.DBLookupComboBoxClick(Sender: TObject);
begin
Prebaraj.Enabled:=True;
Pecati.Enabled:=False;
end;

procedure TAnaliziPoDenoviForm.FormShow(Sender: TObject);
var Query:TADOQuery;
    Date:TDateTime;
begin
if (MainForm.Denari=False)Then
    ImpulsiBtn.Checked:=True
    else
    DenariBtn.Checked:=True;

MainForm.Cursor:=crSQLWait;
try;
AdoConnection.ConnectionString:='Provider=Microsoft.Jet.OLEDB.4.0;Persist Security Info=False;Data Source='+MainForm.Path+'Centrala.mdb;Mode=Read';
ADOQuery.Parameters.Clear;
Query:=TADOQuery.Create(Self);
Query.ConnectionString:='Provider=Microsoft.Jet.OLEDB.4.0;Persist Security Info=False;Data Source='+MainForm.Path+'Centrala.mdb;Mode=Read';
Query.SQL.Add('SELECT Main.Vreme AS Vreme FROM Main ORDER BY Main.Vreme;');
Query.Active:=True;
if (Query.RecordCount>0) Then
   Begin
   Query.First;
   Date:=Query.FieldByName('Vreme').Value;
   OdDatum.Date:=Int(Date);
   Query.Last;
   Date:=Query.FieldByName('Vreme').Value;
   DoDatum.Date:=Int(Date);
   End
   Else
   Begin
   OdDatum.Date:=Now;
   DoDatum.Date:=Now;
   End;
Query.Free;
finally;
MainForm.Cursor:=crDefault;
end;
end;

procedure TAnaliziPoDenoviForm.DBChartDblClick(Sender: TObject);
begin
DBChart.UndoZoom;
end;

procedure TAnaliziPoDenoviForm.OdDatumChange(Sender: TObject);
begin
Pecati.Enabled:=False;
end;

procedure TAnaliziPoDenoviForm.DoDatumChange(Sender: TObject);
begin
Pecati.Enabled:=False;
end;

procedure TAnaliziPoDenoviForm.ImpulsiBtnClick(Sender: TObject);
begin
MainForm.Denari:=False;
end;

procedure TAnaliziPoDenoviForm.DenariBtnClick(Sender: TObject);
begin
MainForm.Denari:=True;
end;

procedure TAnaliziPoDenoviForm.ADOQueryCalcFields(DataSet: TDataSet);
begin
DataSet.FieldByName('DenVkupno').Value:=DataSet.FieldByName('Vkupno').Value * MainForm.DenariVal;
end;

end.
