unit ZListUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ComCtrls;

type
  TZListDocForm = class(TForm)
    OdDatum: TDateTimePicker;
    DoDatum: TDateTimePicker;
    StringGrid: TStringGrid;
    PocDolziSuma: TStaticText;
    PocPobaruvaSuma: TStaticText;
    DolziSuma: TStaticText;
    PobaruvaSuma: TStaticText;
    Saldo: TStaticText;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure DoDatumExit(Sender: TObject);
    procedure OdDatumKeyPress(Sender: TObject; var Key: Char);
    procedure DoDatumKeyPress(Sender: TObject; var Key: Char);
    procedure StringGridDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateData;
  end;

var
  ZListDocForm: TZListDocForm;

implementation

uses MainUnit, NovoKontoUnit;

{$R *.DFM}

procedure TZListDocForm.UpdateData;
Type
   PTempRec=^TempRec;
   TempRec=Record
      Konto:String[6];
      PocDolzi:Currency;
      PocPobaruva:Currency;
      Dolzi:Currency;
      Pobaruva:Currency;
      End;
Var Count,C:LongInt;
   Kon:PKPlanData;
   Nal:PNalogData;
   Kni:PKnigoData;
   TRec,TRec2:PTempRec;
   TSt,TSt2:String;
   SPocDolzi,SPocPobaruva,SDolzi,SPobaruva:Currency;
   KSPocDolzi,KSPocPobaruva,KSDolzi,KSPobaruva:Currency;
   Found:Boolean;
   TempList:TList;
begin
If (MainForm.KnigoList.Count=0) Then Exit;
TempList:=TList.Create;
try
For Count:=0 to MainForm.KnigoList.Count-1 Do
   Begin
   Kni:=MainForm.KnigoList.Items[Count];
   Found:=False;
   C:=0;
   If((Kni^.Data>=OdDatum.Date)And(Kni^.Data<=DoDatum.Date))Then
      Begin
      If (TempList.Count>0) Then
         For C:=0 to TempList.Count-1 Do
            Begin
            TRec:=TempList.Items[C];
            If (Copy(Kni^.Konto,1,3)=Copy(TRec^.Konto,1,3)) Then
               Begin
               Found:=True;
               Nal:=MainForm.NalogList.Items[Kni^.Nalog-1];
               If ((Nal^.Opis='   1/RD ')Or(Nal^.Opis='1/RD'))Then
                  Begin
                  TRec^.PocDolzi:=TRec^.PocDolzi+Kni^.Dolzi;
                  TRec^.PocPobaruva:=TRec^.PocPobaruva+Kni^.Pobaruva;
                  End;
               TRec^.Dolzi:=TRec^.Dolzi+Kni^.Dolzi;
               TRec^.Pobaruva:=TRec^.Pobaruva+Kni^.Pobaruva;
               Break;
               End;
            If (CompareStr(Copy(Kni^.Konto,1,3),Copy(TRec^.Konto,1,3))<0) Then
               Break;
            End;
      If (Found=False) Then
         Begin
         Nal:=MainForm.NalogList.Items[Kni^.Nalog-1];
         GetMem(TRec,SizeOf(TempRec));
         TRec^.Konto:=Copy(Kni^.Konto,1,3);
         If ((Nal^.Opis='   1/RD ')Or(Nal^.Opis='1/RD'))Then
            Begin
            TRec^.PocDolzi:=Kni^.Dolzi;
            TRec^.PocPobaruva:=Kni^.Pobaruva;
            End
            Else
            Begin
            TRec^.PocDolzi:=0;
            TRec^.PocPobaruva:=0;
            End;
         TRec^.Dolzi:=Kni^.Dolzi;
         TRec^.Pobaruva:=Kni^.Pobaruva;
         TempList.Insert(C,TRec);
         End;
      End;
   End;

SPocDolzi:=0;SPocPobaruva:=0;SDolzi:=0;SPobaruva:=0;
If (TempList.Count>0) Then
   For Count:=0 To TempList.Count-1 Do
      Begin
      TRec:=TempList.Items[Count];
      SPocDolzi:=SPocDolzi+TRec^.PocDolzi;
      SPocPobaruva:=SPocPobaruva+TRec^.PocPobaruva;
      SDolzi:=SDolzi+TRec^.Dolzi;
      SPobaruva:=SPobaruva+TRec^.Pobaruva;
      End;
Str(SPocDolzi:14:2,TSt);
PocDolziSuma.Caption:=TSt;
Str(SPocPobaruva:14:2,TSt);
PocPobaruvaSuma.Caption:=TSt;
Str(SDolzi:14:2,TSt);
DolziSuma.Caption:=TSt;
Str(SPobaruva:14:2,TSt);
PobaruvaSuma.Caption:=TSt;
Str(SDolzi-SPobaruva:15:2,TSt);
Saldo.Caption:=TSt;

If (TempList.Count>13)Then
   Begin
   PocDolziSuma.Top:=303;
   PocPobaruvaSuma.Top:=303;
   DolziSuma.Top:=303;
   PobaruvaSuma.Top:=303;
   Saldo.Top:=303;
   End
   Else
   Begin
   PocDolziSuma.Top:=303-((12-TempList.Count)*18);
   PocPobaruvaSuma.Top:=303-((12-TempList.Count)*18);
   DolziSuma.Top:=303-((12-TempList.Count)*18);
   PobaruvaSuma.Top:=303-((12-TempList.Count)*18);
   Saldo.Top:=303-((12-TempList.Count)*18);
   If (TempList.Count=0)Then
      Begin
      PocDolziSuma.Visible:=False;
      PocPobaruvaSuma.Visible:=False;
      DolziSuma.Visible:=False;
      PobaruvaSuma.Visible:=False;
      Saldo.Visible:=False;
      End
      Else
      Begin
      PocDolziSuma.Visible:=True;
      PocPobaruvaSuma.Visible:=True;
      DolziSuma.Visible:=True;
      PobaruvaSuma.Visible:=True;
      Saldo.Visible:=True;
      End;
   End;
If (TempList.Count=0) Then
   Begin
   StringGrid.RowCount:=2;
   StringGrid.Cells[0,1]:='';
   StringGrid.Cells[1,1]:='';
   StringGrid.Cells[2,1]:='';
   StringGrid.Cells[3,1]:='';
   StringGrid.Cells[4,1]:='';
   StringGrid.Cells[5,1]:='';
   StringGrid.Cells[6,1]:='';
   StringGrid.Cells[7,1]:='';
   Exit;
   End;
SPocDolzi:=0;SPocPobaruva:=0;SDolzi:=0;SPobaruva:=0;
KSPocDolzi:=0;KSPocPobaruva:=0;KSDolzi:=0;KSPobaruva:=0;
Count:=0;
TRec:=TempList.Items[0];
TSt:=TRec^.Konto;
Repeat
TRec:=TempList.Items[Count];

If (Copy(TSt,1,1)<>Copy(TRec^.Konto,1,1)) Then
   Begin
   TSt2:=TRec^.Konto;
   GetMem(TRec2,SizeOf(TempRec));
   TRec2^.Konto:=Copy(TSt,1,1);
   TRec2^.PocDolzi:=SPocDolzi;SPocDolzi:=0;
   TRec2^.PocPobaruva:=SPocPobaruva;SPocPobaruva:=0;
   TRec2^.Dolzi:=SDolzi;SDolzi:=0;
   TRec2^.Pobaruva:=SPobaruva;SPobaruva:=0;
   TempList.Insert(Count,TRec2);
   Inc(Count);
   TSt:=TSt2;
   End
   Else
   TSt:=TRec^.Konto;
SPocDolzi:=SPocDolzi+TRec^.PocDolzi;
SPocPobaruva:=SPocPobaruva+TRec^.PocPobaruva;
SDolzi:=SDolzi+TRec^.Dolzi;
SPobaruva:=SPobaruva+TRec^.Pobaruva;
KSPocDolzi:=KSPocDolzi+TRec^.PocDolzi;
KSPocPobaruva:=KSPocPobaruva+TRec^.PocPobaruva;
KSDolzi:=KSDolzi+TRec^.Dolzi;
KSPobaruva:=KSPobaruva+TRec^.Pobaruva;
Inc(Count);
Until(TempList.Count=Count);

GetMem(TRec2,SizeOf(TempRec));
TRec2^.Konto:=Copy(TSt,1,1);
TRec2^.PocDolzi:=SPocDolzi;//SPocDolzi:=0;
TRec2^.PocPobaruva:=SPocPobaruva;//SPocPobaruva:=0;
TRec2^.Dolzi:=SDolzi;//SDolzi:=0;
TRec2^.Pobaruva:=SPobaruva;//SPobaruva:=0;
TempList.Insert(Count,TRec2);

StringGrid.RowCount:=TempList.Count+1;
For Count:=0 To TempList.Count-1 Do
   Begin
   Str(Count+1,TSt);
   StringGrid.Cells[0,Count+1]:=TSt;
   TRec:=TempList.Items[Count];
   StringGrid.Cells[1,Count+1]:=TRec^.Konto;
   If (MainForm.KPlanList.Count>0) Then
      For C:=0 To MainForm.KPlanList.Count-1 Do
         Begin
         Kon:=MainForm.KPlanList.Items[C];
         If (Kon^.Konto=TRec^.Konto) Then
            Begin
            StringGrid.Cells[2,Count+1]:=Kon^.Opis;
            break;
            End;
         End;
   Str(TRec^.PocDolzi:14:2,TSt);
   StringGrid.Cells[3,Count+1]:=TSt;
   Str(TRec^.PocPobaruva:14:2,TSt);
   StringGrid.Cells[4,Count+1]:=TSt;

   Str(TRec^.Dolzi:14:2,TSt);
   StringGrid.Cells[5,Count+1]:=TSt;
   Str(TRec^.Pobaruva:14:2,TSt);
   StringGrid.Cells[6,Count+1]:=TSt;
   Str(TRec^.Dolzi-TRec^.Pobaruva:15:2,TSt);
   StringGrid.Cells[7,Count+1]:=TSt;
   End;

finally
If (TempList.Count>0)Then
   For Count:=0 To TempList.Count-1 Do
      FreeMem(TempList.Items[Count],SizeOf(TempRec));
TempList.Free;
end;
end;

procedure TZListDocForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
Action:=caFree;
ZListDocForm:=nil;
end;

procedure TZListDocForm.FormShow(Sender: TObject);
begin
OdDatum.DateTime:=MainForm.OdDatum;
DoDatum.DateTime:=MainForm.DoDatum;
StringGrid.Cells[0,0]:='Р.Б.';
StringGrid.ColWidths[0]:=30;
StringGrid.Cells[1,0]:='Конто';
StringGrid.ColWidths[1]:=60;
StringGrid.Cells[2,0]:='Опис';
StringGrid.ColWidths[2]:=180;
StringGrid.Cells[3,0]:='Поч.Должи';
StringGrid.ColWidths[3]:=90;
StringGrid.Cells[4,0]:='Поч.Побарува';
StringGrid.ColWidths[4]:=90;
StringGrid.Cells[5,0]:='Должи';
StringGrid.ColWidths[5]:=90;
StringGrid.Cells[6,0]:='Побарува';
StringGrid.ColWidths[6]:=90;
StringGrid.Cells[7,0]:='Салдо';
StringGrid.ColWidths[7]:=90;
UpdateData;
end;

procedure TZListDocForm.StringGridDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
Var Levo:Integer;
begin
If (((State=[gdSelected])Or(State=[gdSelected,gdFocused]))And(StringGrid.DefaultDrawing=True))Then
   Begin
   StringGrid.Canvas.Pen.Color:=clHighlight;
   StringGrid.Canvas.Brush.Color:=clHighlight;
   End
   Else
   Begin
   StringGrid.Canvas.Pen.Color:=clActiveBorder;
   StringGrid.Canvas.Brush.Color:=clActiveBorder;
   End;
StringGrid.Canvas.Rectangle(Rect);
If (ARow=0)Then
   Begin
   Levo:=Rect.Left+(Rect.Right-Rect.Left-StringGrid.Canvas.TextWidth(StringGrid.Cells[ACol,ARow])) div 2;
   End
   Else
   Case ACol Of
      1,2:Levo:=Rect.Left+2;
      else
         Levo:=Rect.Right-StringGrid.Canvas.TextWidth(StringGrid.Cells[ACol,ARow])-2;
      End;
//StringGrid.Canvas.TextOut(Levo,Rect.Top+1,StringGrid.Cells[ACol,ARow]);
StringGrid.Canvas.TextRect(Rect,Levo,Rect.Top+1,StringGrid.Cells[ACol,ARow]);
end;

procedure TZListDocForm.DoDatumExit(Sender: TObject);
begin
UpdateData;
end;

procedure TZListDocForm.OdDatumKeyPress(Sender: TObject; var Key: Char);
begin
If (Key=#13) Then DoDatum.SetFocus;
end;

procedure TZListDocForm.DoDatumKeyPress(Sender: TObject; var Key: Char);
begin
If (Key=#13) Then StringGrid.SetFocus;
end;

procedure TZListDocForm.StringGridDblClick(Sender: TObject);
var TSt:String;
   C:Integer;
   KPl:PKPlanData;
begin
TSt:=StringGrid.Cells[1,StringGrid.Row];
for c:=0 to MainForm.KPLanList.Count - 1 do
   begin
   KPl:=MainForm.KPLanList.Items[c];
   if(KPl.Konto=TSt)Then
      exit;
   end;
NovoKontoUnit.VnesiKonto:=TVnesiKonto.Create(self);
NovoKontoUnit.VnesiKonto.KontoOpis.Text:=TSt;
NovoKontoUnit.VnesiKonto.KontoOpis.Enabled:=False;
if((NovoKontoUnit.VnesiKonto.ShowModal=mrOk)And(Length(NovoKontoUnit.VnesiKonto.OpisOpis.Text)>0)) Then
   Begin
   GetMem(KPl,SizeOf(KPlanData));
   KPl.Konto:=TSt;
   KPl.Opis:=NovoKontoUnit.VnesiKonto.OpisOpis.Text;
   MainForm.KPLanList.Add(KPl);
   MainForm.KPLanList.Sort(SortKontaKonto);
   MainForm.NeSnimeno:=True;
   UpdateData;
   End;
NovoKontoUnit.VnesiKonto.Free;
end;

end.
