unit Pregled;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, Grids, DBGrids, StdCtrls, ComCtrls, Buttons;

type
  TPregledForm = class(TForm)
    ADOTable: TADOTable;
    DataSource: TDataSource;
    DBGrid: TDBGrid;
    OdDatum: TDateTimePicker;
    OdDatumLabel: TLabel;
    DoDatumLabel: TLabel;
    DoDatum: TDateTimePicker;
    Filter: TBitBtn;
    Pecati: TBitBtn;
    ImpulsiBtn: TRadioButton;
    DenariBtn: TRadioButton;
    ADOTableID: TIntegerField;
    ADOTableRedBr: TIntegerField;
    ADOTableVreme: TDateTimeField;
    ADOTableLokal: TWideStringField;
    ADOTableTelefonskiBroj: TWideStringField;
    ADOTableImpulsi: TIntegerField;
    ADOTableSekundi: TIntegerField;
    ADOTableTip: TWideStringField;
    ADOTableZabeleski: TWideStringField;
    ADOTableDenari: TCurrencyField;
    procedure FormShow(Sender: TObject);
    function FormHelp(Command: Word; Data: Integer;
      var CallHelp: Boolean): Boolean;
    procedure FilterClick(Sender: TObject);
    procedure PecatiClick(Sender: TObject);
    procedure ImpulsiBtnClick(Sender: TObject);
    procedure DenariBtnClick(Sender: TObject);
    procedure ADOTableCalcFields(DataSet: TDataSet);
    procedure OdDatumChange(Sender: TObject);
    procedure DoDatumChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    DBaseStr: String;
  end;

var
  PregledForm: TPregledForm;

implementation

uses MainUnit, PregledPrint;

{$R *.dfm}

procedure TPregledForm.FormShow(Sender: TObject);
var Query:TADOQuery;
    Date:TDateTime;
begin
if (MainForm.Denari=False)Then
    ImpulsiBtn.Checked:=True
    else
    DenariBtn.Checked:=True;

MainForm.Cursor:=crSQLWait;
try
ADOTable.ConnectionString:='Provider=Microsoft.Jet.OLEDB.4.0;Persist Security Info=False;Data Source='+MainForm.Path+'Centrala.mdb;Mode=Read';
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
finally
MainForm.Cursor:=crDefault;
end;
end;

function TPregledForm.FormHelp(Command: Word; Data: Integer;
  var CallHelp: Boolean): Boolean;
begin
if (Data<=1024) then
    WinHelp(Application.Handle,'CentralaClient.hlp',HELP_CONTEXTPOPUP,Data);
CallHelp:=False;
FormHelp:=True;
end;

procedure TPregledForm.FilterClick(Sender: TObject);
begin
Filter.Enabled:=False;
Cursor:=crSQLWait;
ADOTable.Active:=False;
ADOTable.Filter:='(([Vreme]>='+ DateToStr(OdDatum.DateTime) +') AND ([Vreme]<' + DateToStr(DoDatum.DateTime+1)+'))';
ADOTable.Filtered:=True;
if (MainForm.Denari) Then
  Begin
  DBGrid.Columns.Items[3].Field:=ADOTable.Fields.Fields[9];
  DBGrid.Columns.Items[3].Title.Caption:='Денари';
  DBGrid.Columns.Items[3].Alignment:=taRightJustify;
  End
  Else
  Begin
  DBGrid.Columns.Items[3].Field:=ADOTable.Fields.Fields[5];
  DBGrid.Columns.Items[3].Title.Caption:='Импулси';
  DBGrid.Columns.Items[3].Alignment:=taCenter;
  End;
ADOTable.Active:=True;
Cursor:=crDefault;
if (ADOTable.RecordCount>0) Then
   Pecati.Enabled:=True
   else
   Pecati.Enabled:=False;
Filter.Enabled:=True;
end;

procedure TPregledForm.PecatiClick(Sender: TObject);
Var
   TSt:String;
begin
PregledReport:= TPregledReport.Create(Self);
PregledReport.DataSet.Active:=False;
if (DenariBtn.Checked=True) Then
   Begin
   PregledReport.QRLabelImpulsi.Caption:='Денари';
   PregledReport.QRDBImpulsi.DataField:='Denari';
   str(MainForm.DenariVal,TSt);
   PregledReport.QRSuma.Mask:='99999999999999999999';
   PregledReport.QRSuma.Expression:='Sum(ADOTable.Denari) * '+ TSt;
   End;
PregledReport.ADOTable.ConnectionString:=ADOTable.ConnectionString;
PregledReport.DataSet.Filter:=ADOTable.Filter;
PregledReport.DataSet.Filtered:=True;
PregledReport.DataSet.Active:=True;
PregledReport.OdDatum.Caption:=DateToStr(OdDatum.DateTime);
PregledReport.DoDatum.Caption:=DateToStr(DoDatum.DateTime);
PregledReport.Preview;
PregledReport.Free;
end;

procedure TPregledForm.ImpulsiBtnClick(Sender: TObject);
begin
MainForm.Denari:=False;
Pecati.Enabled:=False;
end;

procedure TPregledForm.DenariBtnClick(Sender: TObject);
begin
MainForm.Denari:=True;
Pecati.Enabled:=False;
end;

procedure TPregledForm.ADOTableCalcFields(DataSet: TDataSet);
begin
DataSet.FieldByName('Denari').Value:=DataSet.FieldByName('Impulsi').Value * MainForm.DenariVal;
end;

procedure TPregledForm.OdDatumChange(Sender: TObject);
begin
Pecati.Enabled:=False;
end;

procedure TPregledForm.DoDatumChange(Sender: TObject);
begin
Pecati.Enabled:=False;
end;

end.
