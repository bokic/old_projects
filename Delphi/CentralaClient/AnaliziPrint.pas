unit AnaliziPrint;

interface

uses Windows, SysUtils, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, QuickRpt, QRCtrls, DB, ADODB;

type
  TAnaliziReport = class(TQuickRep)
    ADOQuery: TADOQuery;
    ColumnHeaderBand: TQRBand;
    DetailBand: TQRBand;
    SummaryBand: TQRBand;
    PageFooterBand: TQRBand;
    QRSysData: TQRSysData;
    QRLabelListing: TQRLabel;
    QRLabelOdDatum: TQRLabel;
    OdDatum: TQRLabel;
    DoDatum: TQRLabel;
    QRLabelDoDatum: TQRLabel;
    QRLabelZaFirma: TQRLabel;
    ZaFirma: TQRLabel;
    QRShapeLinija: TQRShape;
    QRDBLokal: TQRDBText;
    QRDBLokalni: TQRDBText;
    QRDBNacionalni: TQRDBText;
    QRDBInternacionalni: TQRDBText;
    QRDBVkupno: TQRDBText;
    QRShapeLinijaVkupno: TQRShape;
    QRExprLokalni: TQRExpr;
    QRExprNacionalni: TQRExpr;
    QRExprInternacionalni: TQRExpr;
    QRExprVkupno: TQRExpr;
    QRLabelSumaVkupno: TQRLabel;
    QRLabelLokalni: TQRLabel;
    QRLabelInternacionalni: TQRLabel;
    QRLabelNacionalni: TQRLabel;
    QRLabelVkupno: TQRLabel;
    QRLabelLokal: TQRLabel;
    ADOQueryDenLokalni: TCurrencyField;
    ADOQueryDenNacionalni: TCurrencyField;
    ADOQueryDenInternacionalni: TCurrencyField;
    ADOQueryDenVkupno: TCurrencyField;
    ADOQueryLokal: TWideStringField;
    ADOQueryLokalni: TFloatField;
    ADOQueryNacionalni: TFloatField;
    ADOQueryInternacionalni: TFloatField;
    ADOQueryVkupno: TFloatField;
    procedure ADOQueryCalcFields(DataSet: TDataSet);
    procedure QRExprLokalniPrint(sender: TObject; var Value: String);
    procedure QRExprNacionalniPrint(sender: TObject; var Value: String);
    procedure QRExprInternacionalniPrint(sender: TObject;
      var Value: String);
    procedure QRExprVkupnoPrint(sender: TObject; var Value: String);
    procedure QuickRepBeforePrint(Sender: TCustomQuickRep;
      var PrintReport: Boolean);
  private

  public

  end;

var
  AnaliziReport: TAnaliziReport;

implementation

uses MainUnit,Analizi;

{$R *.DFM}

procedure TAnaliziReport.ADOQueryCalcFields(DataSet: TDataSet);
begin
ADOQuery.Fields.FieldByName('DenLokalni').Value:=ADOQuery.Fields.FieldByName('Lokalni').Value * MainForm.DenariVal;
ADOQuery.Fields.FieldByName('DenNacionalni').Value:=ADOQuery.Fields.FieldByName('Nacionalni').Value * MainForm.DenariVal;
ADOQuery.Fields.FieldByName('DenInternacionalni').Value:=ADOQuery.Fields.FieldByName('Internacionalni').Value * MainForm.DenariVal;
ADOQuery.Fields.FieldByName('DenVkupno').Value:=ADOQuery.Fields.FieldByName('Vkupno').Value * MainForm.DenariVal;
end;

procedure TAnaliziReport.QRExprLokalniPrint(sender: TObject; var Value: String);
Type MyChar=Array[0..30] of Char;
var Point:Pointer;
    Size:^Integer;
    TSt:String;
    PCh:^MyChar;
    Count:Integer;
begin
if (AnaliziForm.DenariBtn.Checked=True) Then
   Begin
   TSt:=CurrToStrF(QRExprLokalni.Value.dblResult,ffCurrency,2)+#0;
   CopyMemory(@Point,@Value,4);
   Size:=Pointer(LongInt(Point)-4);
   PCh:=Point;
   for Count:=0 To Length(TSt)-1 Do
   PCh[Count]:=TSt[Count+1];
      Size^:=Length(TSt)-1;
   End;
end;

procedure TAnaliziReport.QRExprNacionalniPrint(sender: TObject; var Value: String);
Type MyChar=Array[0..30] of Char;
var Point:Pointer;
    Size:^Integer;
    TSt:String;
    PCh:^MyChar;
    Count:Integer;
begin
if (AnaliziForm.DenariBtn.Checked=True) Then
   Begin
   TSt:=CurrToStrF(QRExprNacionalni.Value.dblResult,ffCurrency,2)+#0;
   CopyMemory(@Point,@Value,4);
   Size:=Pointer(LongInt(Point)-4);
   PCh:=Point;
   for Count:=0 To Length(TSt)-1 Do
      PCh[Count]:=TSt[Count+1];
   Size^:=Length(TSt)-1;
   End;
end;

procedure TAnaliziReport.QRExprInternacionalniPrint(sender: TObject; var Value: String);
Type MyChar=Array[0..30] of Char;
var Point:Pointer;
    Size:^Integer;
    TSt:String;
    PCh:^MyChar;
    Count:Integer;
begin
if (AnaliziForm.DenariBtn.Checked=True) Then
   Begin
   TSt:=CurrToStrF(QRExprInternacionalni.Value.dblResult,ffCurrency,2)+#0;
   CopyMemory(@Point,@Value,4);
   Size:=Pointer(LongInt(Point)-4);
   PCh:=Point;
   for Count:=0 To Length(TSt)-1 Do
      PCh[Count]:=TSt[Count+1];
   Size^:=Length(TSt)-1;
   End;
end;

procedure TAnaliziReport.QRExprVkupnoPrint(sender: TObject; var Value: String);
Type MyChar=Array[0..30] of Char;
var Point:Pointer;
    Size:^Integer;
    TSt:String;
    PCh:^MyChar;
    Count:Integer;
begin
if (AnaliziForm.DenariBtn.Checked=True) Then
   Begin
   TSt:=CurrToStrF(QRExprVkupno.Value.dblResult,ffCurrency,2)+#0;
   CopyMemory(@Point,@Value,4);
   Size:=Pointer(LongInt(Point)-4);
   PCh:=Point;
   for Count:=0 To Length(TSt)-1 Do
      PCh[Count]:=TSt[Count+1];
   Size^:=Length(TSt)-1;
   End;
end;

procedure TAnaliziReport.QuickRepBeforePrint(Sender: TCustomQuickRep;
  var PrintReport: Boolean);
begin
if (AnaliziForm.ImpulsiBtn.Checked=True) Then
   Begin
   QRExprLokalni.Mask:='';
   QRExprNacionalni.Mask:='';
   QRExprInternacionalni.Mask:='';
   QRExprVkupno.Mask:='';
   End;
end;

end.
