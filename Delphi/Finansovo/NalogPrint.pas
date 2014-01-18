unit NalogPrint;

interface

uses Windows, SysUtils, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, QuickRpt, QRCtrls;

type
  TNalogReport = class(TQuickRep)
    Opis: TQRLabel;
    OpisLabel: TQRLabel;
    DetailBand: TQRBand;
    PageFooterBand: TQRBand;
    SummaryBand: TQRBand;
    RB: TQRLabel;
    DatumNalog: TQRLabel;
    NalogBr: TQRLabel;
    Konto: TQRLabel;
    Datum: TQRLabel;
    Valuta: TQRLabel;
    Dolzi: TQRLabel;
    Pobaruva: TQRLabel;
    Komintent: TQRLabel;
    Linija1: TQRShape;
    RazdelnaLinija1: TQRShape;
    SPobaruva: TQRLabel;
    SDolzi: TQRLabel;
    Linija2: TQRShape;
    Linija3: TQRShape;
    Linija4: TQRShape;
    Linija5: TQRShape;
    Linija6: TQRShape;
    Linija7: TQRShape;
    Linija8: TQRShape;
    Linija9: TQRShape;
    RazdelnaLinija3: TQRShape;
    KontoLabel: TQRLabel;
    DatumLabel: TQRLabel;
    ValutaLabel: TQRLabel;
    DolziLabel: TQRLabel;
    PobaruvaLabel: TQRLabel;
    KomintentLabel: TQRLabel;
    RazdelnaLinija2: TQRShape;
    procedure PageHeaderBandBeforePrint(Sender: TQRCustomBand;
      var PrintBand: Boolean);
    procedure QuickRepNeedData(Sender: TObject; var MoreData: Boolean);
  private
  public
  end;

var
  NalogReport: TNalogReport;

implementation

uses NalogViewUnit;

{$R *.DFM}

procedure TNalogReport.PageHeaderBandBeforePrint(Sender: TQRCustomBand;
  var PrintBand: Boolean);
begin
NalogBr.Caption:=NalogDocForm.ComboBox.Text;
DatumNalog.Caption:=NalogDocForm.Date.Caption;
SDolzi.Caption:=NalogDocForm.DolziSuma.Caption;
SPobaruva.Caption:=NalogDocForm.PobaruvaSuma.Caption;
end;

procedure TNalogReport.QuickRepNeedData(Sender: TObject;
  var MoreData: Boolean);
var TSt:String;
begin
if(NalogDocForm.StringGrid.RowCount>RecordNumber+1)Then
  Begin
  Str(RecordNumber+1,TSt);
  RB.Caption:=TSt;
  Opis.Caption:=NalogDocForm.StringGrid.Cells[1,RecordNumber+1];
  Konto.Caption:=NalogDocForm.StringGrid.Cells[2,RecordNumber+1];
  Datum.Caption:=NalogDocForm.StringGrid.Cells[3,RecordNumber+1];
  Valuta.Caption:=NalogDocForm.StringGrid.Cells[4,RecordNumber+1];
  Dolzi.Caption:=NalogDocForm.StringGrid.Cells[5,RecordNumber+1];
  Pobaruva.Caption:=NalogDocForm.StringGrid.Cells[6,RecordNumber+1];
  Komintent.Caption:=NalogDocForm.StringGrid.Cells[7,RecordNumber+1];
  MoreData:=True;
  End
  Else
  MoreData:=False;
end;

end.
