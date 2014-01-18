unit PregledPrint;

interface

uses Windows, SysUtils, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, QuickRpt, QRCtrls, DB, ADODB;

type
  TPregledReport = class(TQuickRep)
    DetailBand: TQRBand;
    SummaryBand: TQRBand;
    QRLabelSuma: TQRLabel;
    QRDBVreme: TQRDBText;
    QRDBLokal: TQRDBText;
    QRDBTelBr: TQRDBText;
    ADOTable: TADOTable;
    QRDBImpulsi: TQRDBText;
    QRDBSekundi: TQRDBText;
    ColumnHeaderBand: TQRBand;
    QRLabelListing: TQRLabel;
    QRLabelVreme: TQRLabel;
    QRLabelLokal: TQRLabel;
    QRLabelTelefonskiBroj: TQRLabel;
    QRLabelImpulsi: TQRLabel;
    QRLabelSekundi: TQRLabel;
    QRShapeLinija: TQRShape;
    QRShapeSumaLinija: TQRShape;
    QRSuma: TQRExpr;
    PageFooterBand: TQRBand;
    QRSysData: TQRSysData;
    QRLabelOdDatum: TQRLabel;
    QRLabelDoDatum: TQRLabel;
    OdDatum: TQRLabel;
    DoDatum: TQRLabel;
    ADOTableVreme: TDateTimeField;
    ADOTableLokal: TWideStringField;
    ADOTableTelefonskiBroj: TWideStringField;
    ADOTableImpulsi: TIntegerField;
    ADOTableSekundi: TIntegerField;
    ADOTableDenari: TCurrencyField;
    procedure QRSumaPrint(sender: TObject; var Value: String);
    procedure ADOTableCalcFields(DataSet: TDataSet);
  private

  public

  end;

var
  PregledReport: TPregledReport;

implementation

uses Pregled, MainUnit;

{$R *.DFM}

procedure TPregledReport.QRSumaPrint(sender: TObject; var Value: String);
Type MyChar=Array[0..30] of Char;
var Point:Pointer;
    Size:^Integer;
    TSt:String;
    PCh:^MyChar;
    Count:Integer;
begin
if (PregledForm.ImpulsiBtn.Checked=True) Then
   Exit;
TSt:=CurrToStrF(QRSuma.Value.dblResult,ffCurrency,2)+#0;
CopyMemory(@Point,@Value,4);
Size:=Pointer(LongInt(Point)-4);
PCh:=Point;
for Count:=0 To Length(TSt)-1 Do
  PCh[Count]:=TSt[Count+1];
Size^:=Length(TSt)-1;
end;
procedure TPregledReport.ADOTableCalcFields(DataSet: TDataSet);
begin
ADOTable.Fields.FieldByName('Denari').Value:=ADOTable.Fields.FieldByName('Impulsi').Value * MainForm.DenariVal;
end;

end.
