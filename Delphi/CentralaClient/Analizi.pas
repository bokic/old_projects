unit Analizi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, ComCtrls, Grids, DBGrids, StdCtrls, DBCtrls, Buttons;

type
  TAnaliziForm = class(TForm)
    OdDatumLabel: TLabel;
    DoDatumLabel: TLabel;
    DBGrid: TDBGrid;
    OdDatum: TDateTimePicker;
    DoDatum: TDateTimePicker;
    DataSource: TDataSource;
    ADOQuery: TADOQuery;
    ADOConnection: TADOConnection;
    Prebaraj: TBitBtn;
    DBLookupComboBox: TDBLookupComboBox;
    CheckBox: TCheckBox;
    DataSource2: TDataSource;
    ADOTable: TADOTable;
    Pecati: TBitBtn;
    DenariBtn: TRadioButton;
    ImpulsiBtn: TRadioButton;
    ADOQueryLokal: TWideStringField;
    ADOQueryLokalni: TFloatField;
    ADOQueryNacionalni: TFloatField;
    ADOQueryInternacionalni: TFloatField;
    ADOQueryVkupno: TFloatField;
    ADOQueryDenLokalni: TCurrencyField;
    ADOQueryDenNacionalni: TCurrencyField;
    ADOQueryDenInternacionalni: TCurrencyField;
    ADOQueryDenVkupno: TCurrencyField;
    procedure FormShow(Sender: TObject);
    procedure PrebarajClick(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure DBLookupComboBoxClick(Sender: TObject);
    procedure PecatiClick(Sender: TObject);
    procedure DoDatumChange(Sender: TObject);
    procedure OdDatumChange(Sender: TObject);
    procedure ImpulsiBtnClick(Sender: TObject);
    procedure DenariBtnClick(Sender: TObject);
    procedure ADOQueryCalcFields(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AnaliziForm: TAnaliziForm;

implementation

uses MainUnit, AnaliziPrint;

{$R *.dfm}

procedure TAnaliziForm.FormShow(Sender: TObject);
var Query:TADOQuery;
    Date:TDateTime;
begin
if (MainForm.Denari=False)Then
    ImpulsiBtn.Checked:=True
    else
    DenariBtn.Checked:=True;

MainForm.Cursor:=crSQLWait;
try;
//AdoConnection.Close;
AdoConnection.ConnectionString:='Provider=Microsoft.Jet.OLEDB.4.0;Persist Security Info=False;Data Source='+MainForm.Path+'Centrala.mdb;Mode=Read';
AdoConnection.Open;
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

procedure TAnaliziForm.PrebarajClick(Sender: TObject);
Var TempList: TStrings;
begin
TempList:= TStringList.Create();
Prebaraj.Enabled:=False;
Cursor:=crSQLWait;
ADOQuery.Active:=False;
ADOQuery.Close;
ADOQuery.SQL.Clear;
if (CheckBox.Checked=True) Then
    Begin
    TempList.Add('SELECT MAIN.Lokal, Sum(IIf(Left$([TelefonskiBroj],1)<>"0",[Impulsi],0)) AS Lokalni, Sum(IIf(Left$([TelefonskiBroj],1)="0",IIf(Mid$([TelefonskiBroj],2,1)<>"0",[Impulsi],0),0)) AS Nacionalni,');
    TempList.Add('Sum(IIf(Left$([TelefonskiBroj],2)="00",[Impulsi],0)) AS Internacionalni, Sum(MAIN.Impulsi) AS Vkupno');
    TempList.Add('FROM Firmi INNER JOIN (Lokali INNER JOIN MAIN ON Lokali.Lokal = MAIN.Lokal) ON Firmi.ID = Lokali.Firma');
    TempList.Add('WHERE (((Firmi.Firma)="'+DBLookUpComboBox.Text+'")AND((Int(Vreme)>=OdDatum) AND (Int(Vreme)<=DoDatum)))');
    TempList.Add('GROUP BY MAIN.Lokal;');
    End
    Else
    Begin
    TempList.Add('SELECT MAIN.Lokal, Sum(IIf(Left$([TelefonskiBroj],1)<>"0",[Impulsi],0)) AS Lokalni, Sum(IIf(Left$([TelefonskiBroj],1)="0",IIf(Mid$([TelefonskiBroj],2,1)<>"0",[Impulsi],0),0)) AS Nacionalni,');
    TempList.Add('Sum(IIf(Left$([TelefonskiBroj],2)="00",[Impulsi],0)) AS Internacionalni, Sum(MAIN.Impulsi) AS Vkupno');
    TempList.Add('FROM Firmi INNER JOIN (Lokali INNER JOIN MAIN ON Lokali.Lokal = MAIN.Lokal) ON Firmi.ID = Lokali.Firma');
    TempList.Add('WHERE ((Int(Vreme)>=OdDatum) AND (Int(Vreme)<=DoDatum))');
    TempList.Add('GROUP BY MAIN.Lokal;');
    End;
ADOQuery.SQL.Text:=TempList.Text;
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
  DBGrid.Columns.Items[1].FieldName:='DenLokalni';
  DBGrid.Columns.Items[1].Alignment:=taRightJustify;
  DBGrid.Columns.Items[2].FieldName:='DenNacionalni';
  DBGrid.Columns.Items[2].Alignment:=taRightJustify;
  DBGrid.Columns.Items[3].FieldName:='DenInternacionalni';
  DBGrid.Columns.Items[3].Alignment:=taRightJustify;
  DBGrid.Columns.Items[4].FieldName:='DenVkupno';
  DBGrid.Columns.Items[4].Alignment:=taRightJustify;
  End
  Else
  Begin
  DBGrid.Columns.Items[1].FieldName:='Lokalni';
  DBGrid.Columns.Items[1].Alignment:=taCenter;
  DBGrid.Columns.Items[2].FieldName:='Nacionalni';
  DBGrid.Columns.Items[2].Alignment:=taCenter;
  DBGrid.Columns.Items[3].FieldName:='Internacionalni';
  DBGrid.Columns.Items[3].Alignment:=taCenter;
  DBGrid.Columns.Items[4].FieldName:='Vkupno';
  DBGrid.Columns.Items[4].Alignment:=taCenter;
  End;
ADOQuery.Active:=True;
Cursor:=crDefault;
if (ADOQuery.RecordCount>0) Then
   Pecati.Enabled:=True
   else
   Pecati.Enabled:=False;
Prebaraj.Enabled:=True;
end;

procedure TAnaliziForm.CheckBoxClick(Sender: TObject);
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

procedure TAnaliziForm.DBLookupComboBoxClick(Sender: TObject);
begin
Prebaraj.Enabled:=True;
Pecati.Enabled:=False;
end;

procedure TAnaliziForm.PecatiClick(Sender: TObject);
var TSt:String;
begin
AnaliziReport:= TAnaliziReport.Create(Self);
AnaliziReport.ADOQuery.Connection:=ADOConnection;
AnaliziReport.ADOQuery.SQL.Text:=ADOQuery.SQL.Text;
AnaliziReport.ADOQuery.Parameters:=ADOQuery.Parameters;
AnaliziReport.ADOQuery.Active:=True;
AnaliziReport.DataSet.Active:=True;
AnaliziReport.OdDatum.Caption:=DateToStr(OdDatum.DateTime);
AnaliziReport.DoDatum.Caption:=DateToStr(DoDatum.DateTime);
if (CheckBox.Checked) Then
    Begin
    AnaliziReport.QRLabelZaFirma.Enabled:=True;
    AnaliziReport.ZaFirma.Enabled:=True;
    AnaliziReport.ZaFirma.Caption:=DBLookupComboBox.Text;
    End
    Else
    Begin
    AnaliziReport.QRLabelZaFirma.Enabled:=False;
    AnaliziReport.ZaFirma.Enabled:=False;
    AnaliziReport.ZaFirma.Caption:='';
    End;
if (MainForm.Denari)Then
    Begin
    AnaliziReport.QRDBLokalni.DataField:='DenLokalni';
    AnaliziReport.QRDBNacionalni.DataField:='DenNacionalni';
    AnaliziReport.QRDBInternacionalni.DataField:='DenInternacionalni';
    AnaliziReport.QRDBVkupno.DataField:='DenVkupno';
    AnaliziReport.QRDBVkupno.Alignment:=taRightJustify;
    str(MainForm.DenariVal,TSt);
    AnaliziReport.QRExprLokalni.Expression:='Sum(ADOQuery.Lokalni) * '+ TSt;
    AnaliziReport.QRExprNacionalni.Expression:='Sum(ADOQuery.Nacionalni) * '+ TSt;
    AnaliziReport.QRExprInternacionalni.Expression:='Sum(ADOQuery.Internacionalni) * '+ TSt;
    AnaliziReport.QRExprVkupno.Expression:='Sum(ADOQuery.Vkupno) * '+ TSt;
    End
    Else
    Begin
    AnaliziReport.QRDBLokalni.DataField:='Lokalni';
    AnaliziReport.QRDBNacionalni.DataField:='Nacionalni';
    AnaliziReport.QRDBInternacionalni.DataField:='Internacionalni';
    AnaliziReport.QRDBVkupno.DataField:='Vkupno';
    End;
AnaliziReport.Preview;
AnaliziReport.Free;
end;

procedure TAnaliziForm.OdDatumChange(Sender: TObject);
begin
Pecati.Enabled:=False;
end;

procedure TAnaliziForm.DoDatumChange(Sender: TObject);
begin
Pecati.Enabled:=False;
end;

procedure TAnaliziForm.ImpulsiBtnClick(Sender: TObject);
begin
MainForm.Denari:=False;
Pecati.Enabled:=False;
end;

procedure TAnaliziForm.DenariBtnClick(Sender: TObject);
begin
MainForm.Denari:=True;
Pecati.Enabled:=False;
end;

procedure TAnaliziForm.ADOQueryCalcFields(DataSet: TDataSet);
begin
ADOQuery.Fields.Fields[5].Value:=ADOQuery.Fields.Fields[1].Value * MainForm.DenariVal;
ADOQuery.Fields.Fields[6].Value:=ADOQuery.Fields.Fields[2].Value * MainForm.DenariVal;
ADOQuery.Fields.Fields[7].Value:=ADOQuery.Fields.Fields[3].Value * MainForm.DenariVal;
ADOQuery.Fields.Fields[8].Value:=ADOQuery.Fields.Fields[4].Value * MainForm.DenariVal;
end;

end.
