unit AnalitikaViewUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Grids;

type
  TAnalitikaDocForm = class(TForm)
    OdDatum: TDateTimePicker;
    DoDatum: TDateTimePicker;
    Konto: TComboBox;
    StringGrid: TStringGrid;
    DolziSuma: TStaticText;
    PobaruvaSuma: TStaticText;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure KontoChange(Sender: TObject);
    procedure OdDatumChange(Sender: TObject);
    procedure DoDatumChange(Sender: TObject);
    procedure KontoKeyPress(Sender: TObject; var Key: Char);
    procedure OdDatumKeyPress(Sender: TObject; var Key: Char);
    procedure DoDatumKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateData(Kont:Boolean);
  end;

var
  AnalitikaDocForm: TAnalitikaDocForm;

implementation
Uses MainUnit;
{$R *.DFM}

procedure TAnalitikaDocForm.UpdateData(Kont:Boolean);
Var Count,C,Lop:LongInt;
   Kon:PKPlanData;
   Nal:PNalogData;
   Kni:PKnigoData;
   TSt,TSt2:String;
   SDolzi,SPobaruva:Currency;
begin
If (Kont)Then
   Begin
   TSt:=Konto.Text;
   Konto.Items.Clear;
   If (MainForm.KPlanList.Count>0) Then
      For Count:=1 To MainForm.KPlanList.Count Do
         Begin
         Kon:=MainForm.KPlanList.Items[Count-1];
         Konto.Items.Add(Kon.Konto+' - '+Kon.Opis);
         End;
   If (TSt<>'')Then
      Begin
      For Count:=0 To Konto.Items.Count-1 Do
         Begin
         If (TSt=Konto.Items[Count]) Then
            Konto.ItemIndex:=Count;
         End;
      End;
   End;
If (Konto.Items[Konto.ItemIndex]='') Then// Proveruva dali ima selektirano nalog
   Exit;
Assert(MainForm.KPlanList.Count>0);// Proveruva dali ima podatoci od nalog bazata
Kon:=Nil;
For C:=0 To MainForm.KPlanList.Count Do// Go naogja index-ot od nalog bazata
   Begin
   Kon:=MainForm.KPlanList.Items[C];
   If (Kon.Konto+' - '+Kon.Opis=Konto.Items[Konto.ItemIndex])Then
      Break;
   End;
Assert(Kon<>nil);// Proveruva dali Nal e validen
Assert(MainForm.KnigoList.Count>0);// Proveruva dali ima podatoci od knigo bazata
Count:=0;
SDolzi:=0;SPobaruva:=0;
TSt2:=Kon.Konto;
For C:=0 To MainForm.KnigoList.Count-1 Do// Broi kolku stavki ima selektiraniot nalog
   Begin
   Kni:=MainForm.KnigoList.Items[C];
   If ((Kni.Konto=TSt2)And(Kni.Data>=OdDatum.Date)And(Kni.Data<=DoDatum.Date)) Then
      Begin
      Inc(Count);
      SDolzi:=SDolzi+Kni^.Dolzi;
      SPobaruva:=SPobaruva+Kni^.Pobaruva;
      End;
   End;
Str(SDolzi:13:2,TSt);
DolziSuma.Caption:=TSt;
Str(SPobaruva:13:2,TSt);
PobaruvaSuma.Caption:=TSt;
If (Count>13)Then
   Begin
   DolziSuma.Top:=303;
   PobaruvaSuma.Top:=303;
   DolziSuma.Visible:=True;
   PobaruvaSuma.Visible:=True;
   End
   Else
   Begin
   DolziSuma.Top:=303-((14-Count)*18);
   PobaruvaSuma.Top:=303-((14-Count)*18);
   If (Count=0)Then
      Begin
      DolziSuma.Visible:=False;
      PobaruvaSuma.Visible:=False;
      End
      Else
      Begin
      DolziSuma.Visible:=True;
      PobaruvaSuma.Visible:=True;
      End;
   End;
If (SDolzi=Spobaruva)Then
   Begin
   DolziSuma.Font.Color:=clWindowText;// Greshka
   PobaruvaSuma.Font.Color:=clWindowText;
   End
   Else
   Begin
   DolziSuma.Font.Color:=clRed;
   PobaruvaSuma.Font.Color:=clRed;
   End;
If (Count=0)Then// Ja menuva goleminata na grid-ot
   StringGrid.RowCount:=2
   Else
   StringGrid.RowCount:=Count+1;
Lop:=-1;
If (Count>0)Then
   For C:=2 To StringGrid.RowCount Do// Gi prenesuva podatocite od bazata vo grid-ot
      Begin
      Str(C-1,TSt);
      StringGrid.Cells[0,C-1]:=TSt;
      Repeat
      Inc(Lop);
      Assert(Lop<MainForm.KnigoList.Count,'Грешка 1000');
      Kni:=MainForm.KnigoList.Items[Lop];
      Until((Kni.Konto=TSt2)And(Kni.Data>=OdDatum.Date)And(Kni.Data<=DoDatum.Date));
      Assert(Kni.Nalog<=MainForm.NalogList.Count,'Грешка 1001');
      Nal:=MainForm.NalogList.Items[Kni.Nalog-1];
      StringGrid.Cells[1,C-1]:=Nal.Opis;
      StringGrid.Cells[2,C-1]:=DateToStr(Nal.Data);
      StringGrid.Cells[3,C-1]:=Kni^.Naziv;
      StringGrid.Cells[4,C-1]:=DateToStr(Kni^.Data);
      Str(Kni^.Dolzi:14:2,TSt);
      StringGrid.Cells[5,C-1]:=TSt;
      Str(Kni^.Pobaruva:14:2,TSt);
      StringGrid.Cells[6,C-1]:=TSt;
      End
   Else
   Begin
   StringGrid.Cells[0,1]:='';
   StringGrid.Cells[1,1]:='';
   StringGrid.Cells[2,1]:='';
   StringGrid.Cells[3,1]:='';
   StringGrid.Cells[4,1]:='';
   StringGrid.Cells[5,1]:='';
   StringGrid.Cells[6,1]:='';
   End;
end;

procedure TAnalitikaDocForm.FormShow(Sender: TObject);
begin
OdDatum.DateTime:=MainForm.OdDatum;
DoDatum.DateTime:=MainForm.DoDatum;
StringGrid.Cells[0,0]:='Р.Б.';
StringGrid.ColWidths[0]:=30;
StringGrid.Cells[1,0]:='Нал. Опис';
StringGrid.ColWidths[1]:=60;
StringGrid.Cells[2,0]:='Нал. Датум';
StringGrid.ColWidths[2]:=60;
StringGrid.Cells[3,0]:='Опис';
StringGrid.ColWidths[3]:=180;
StringGrid.Cells[4,0]:='Датум';
StringGrid.ColWidths[4]:=60;
StringGrid.Cells[5,0]:='Должи';
StringGrid.ColWidths[5]:=90;
StringGrid.Cells[6,0]:='Побарува';
StringGrid.ColWidths[6]:=90;
DolziSuma.Top:=303-((14-1)*18);
PobaruvaSuma.Top:=303-((14-1)*18);
UpdateData(True);
end;

procedure TAnalitikaDocForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
Action:=caFree;
AnalitikaDocForm:=nil;
end;

procedure TAnalitikaDocForm.StringGridDrawCell(Sender: TObject; ACol,
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
      1,2,3:Levo:=Rect.Left+2;
      else
         Levo:=Rect.Right-StringGrid.Canvas.TextWidth(StringGrid.Cells[ACol,ARow])-2;
      End;
StringGrid.Canvas.TextOut(Levo,Rect.Top+1,StringGrid.Cells[ACol,ARow]);
end;

procedure TAnalitikaDocForm.KontoChange(Sender: TObject);
begin
If (Konto.Text<>'') Then
   UpdateData(False);
end;

procedure TAnalitikaDocForm.OdDatumChange(Sender: TObject);
begin
If (Konto.Text<>'') Then
   UpdateData(False);
end;

procedure TAnalitikaDocForm.DoDatumChange(Sender: TObject);
begin
If (Konto.Text<>'') Then
   UpdateData(False);
end;

procedure TAnalitikaDocForm.KontoKeyPress(Sender: TObject; var Key: Char);
Var Count:LongInt;
   Found:Boolean;
begin
If (Key=#13)Then
   Begin
   Konto.Text:=UpperCase(Konto.Text);
   Found:=False;
   If (Konto.Items.Count>0)Then
      For Count:=0 To Konto.Items.Count-1 Do
         Begin
         If (Copy(Konto.Items.Strings[Count],1,Length(Konto.Text))=Konto.Text) Then
            Begin
            Konto.ItemIndex:=Count;
            KontoChange(Sender);
            StringGrid.SetFocus;
            Found:=True;
            break;
            End;
         End;
   If (Found=False) Then
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
      DolziSuma.Caption:='0.00';
      PobaruvaSuma.Caption:='0.00';
      DolziSuma.Top:=303-((14-1)*18);
      PobaruvaSuma.Top:=303-((14-1)*18);
      DolziSuma.Font.Color:=clWindowText;
      PobaruvaSuma.Font.Color:=clWindowText;
      End;
   End;
end;

procedure TAnalitikaDocForm.OdDatumKeyPress(Sender: TObject;
  var Key: Char);
begin
If (Key=#13) Then DoDatum.SetFocus;
end;

procedure TAnalitikaDocForm.DoDatumKeyPress(Sender: TObject;
  var Key: Char);
begin
If (Key=#13) Then Konto.SetFocus;
end;

end.
