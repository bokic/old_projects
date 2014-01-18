unit KomintentKontoViewUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ComCtrls;

type
  TKomintentKontoDocForm = class(TForm)
    OdDatum: TDateTimePicker;
    DoDatum: TDateTimePicker;
    Komintent: TComboBox;
    StringGrid: TStringGrid;
    DolziSuma: TStaticText;
    PobaruvaSuma: TStaticText;
    Konto: TComboBox;
    Saldo: TStaticText;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure OdDatumKeyPress(Sender: TObject; var Key: Char);
    procedure DoDatumKeyPress(Sender: TObject; var Key: Char);
    procedure KomintentKeyPress(Sender: TObject; var Key: Char);
    procedure KontoKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateContains(FullData:Boolean);
  end;

var
  KomintentKontoDocForm: TKomintentKontoDocForm;

implementation

uses MainUnit;

{$R *.DFM}

procedure TKomintentKontoDocForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
Action:=caFree;
KomintentKontoDocForm:=nil;
end;

procedure TKomintentKontoDocForm.FormShow(Sender: TObject);
begin
OdDatum.DateTime:=MainForm.OdDatum;
DoDatum.DateTime:=MainForm.DoDatum;
StringGrid.Cells[0,0]:='Р.Б.';
StringGrid.ColWidths[0]:=30;
StringGrid.Cells[1,0]:='Налог';
StringGrid.ColWidths[1]:=60;
StringGrid.Cells[2,0]:='Нал.Датум';
StringGrid.ColWidths[2]:=60;
StringGrid.Cells[3,0]:='Опис';
StringGrid.ColWidths[3]:=180;
StringGrid.Cells[4,0]:='Датум';
StringGrid.ColWidths[4]:=60;
StringGrid.Cells[5,0]:='Должи';
StringGrid.ColWidths[5]:=90;
StringGrid.Cells[6,0]:='Побарува';
StringGrid.ColWidths[6]:=90;
StringGrid.Cells[7,0]:='Салдо';
StringGrid.ColWidths[7]:=90;
UpdateContains(True);
end;

procedure TKomintentKontoDocForm.StringGridDrawCell(Sender: TObject; ACol,
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
      1,2,3,4:Levo:=Rect.Left+2;
      else
         Levo:=Rect.Right-StringGrid.Canvas.TextWidth(StringGrid.Cells[ACol,ARow])-2;
      End;
StringGrid.Canvas.TextRect(Rect,Levo,Rect.Top+1,StringGrid.Cells[ACol,ARow]);
end;

procedure TKomintentKontoDocForm.UpdateContains(FullData:Boolean);
Var Count,{Count2,}TInt,C{,C2}:LongInt;
   Err:Integer;
   Kon:PKPlanData;
   Nal:PNalogdata;
   Kni:PKnigoData;
   Kom:PKomintentData;
   TSt,TSt2:String;
   SDolzi,SPobaruva:Currency;
//   Found:Boolean;
//   TempList:TList;
begin
If ((MainForm.KnigoList.Count=0)Or(MainForm.KomintentList.Count=0)Or(MainForm.KPlanList.Count=0)) Then Exit;
If (FullData) Then
   Begin
   TSt2:=Komintent.Text;
   If (Komintent.Items.Count>0) Then
      For Count:= Komintent.Items.Count-1 DownTo 0 Do
         Komintent.Items.Delete(Count);
   For C:=0 To MainForm.KomintentList.Count-1 Do
      Begin
      Kom:=MainForm.KomintentList.Items[C];
      Str(Kom.Sifra:6,TSt);
      If (TSt[1]=' ') Then TSt[1]:='0';
      If (TSt[2]=' ') Then TSt[2]:='0';
      If (TSt[3]=' ') Then TSt[3]:='0';
      If (TSt[4]=' ') Then TSt[4]:='0';
      If (TSt[5]=' ') Then TSt[5]:='0';
      If (TSt[6]=' ') Then TSt[6]:='0';
      Komintent.Items.Add(TSt+' - '+Kom.Ime);
      End;
   For C:=0 To MainForm.KPlanList.Count-1 Do
      Begin
      Kon:=MainForm.KPlanList.Items[C];
      Konto.Items.Add(Kon^.Konto + ' - '+ Kon.Opis);
      End;
   End;
Count:=1;
For C:=0 To MainForm.KnigoList.Count-1 Do
   Begin
   Kni:=MainForm.KnigoList.Items[C];
   //TInt:=$10000;
   Val(Copy(Komintent.Text,1,6),TInt,Err);
   TSt:=Copy(Konto.Text,1,6);
   If ((Length(TSt)=6)And(TSt[6]=' ')) Then
      Begin
      SetLength(TSt,5);
      If (TSt[5]=' ') Then
         SetLength(TSt,4);
      End;
   If((Kni^.Data>=OdDatum.Date)And(Kni^.Data<=DoDatum.Date)And
   (Kni^.Komintent=TInt)And(Kni^.Konto=TSt)) Then
      Inc(Count);
   End;
If (Count<2)Then Inc(Count);
StringGrid.RowCount:=Count;

Count:=1;
SDolzi:=0;SPobaruva:=0;
StringGrid.Cells[0,1]:='';StringGrid.Cells[1,1]:='';
StringGrid.Cells[2,1]:='';StringGrid.Cells[3,1]:='';
StringGrid.Cells[4,1]:='';StringGrid.Cells[5,1]:='';
StringGrid.Cells[6,1]:='';StringGrid.Cells[7,1]:='';
For C:=0 To MainForm.KnigoList.Count-1 Do
   Begin
   Kni:=MainForm.KnigoList.Items[C];
   //TInt:=$10000;
   Val(Copy(Komintent.Text,1,6),TInt,Err);
   TSt:=Copy(Konto.Text,1,6);
   If ((Length(TSt)=6)And(TSt[6]=' ')) Then
      Begin
      SetLength(TSt,5);
      If (TSt[5]=' ') Then
         Begin
         SetLength(TSt,4);
         End
      End;
   If((Kni^.Data>=OdDatum.Date)And(Kni^.Data<=DoDatum.Date)And
   (Kni^.Komintent=TInt)And(Kni^.Konto=TSt)) Then
      Begin
      Inc(Count);
      Nal:=MainForm.NalogList.Items[Kni^.Nalog-1];
      Str(Count-1,TSt);
      StringGrid.Cells[0,Count-1]:=TSt;
      StringGrid.Cells[1,Count-1]:=Nal^.Opis;
      StringGrid.Cells[2,Count-1]:=DateToStr(Nal^.Data);
      StringGrid.Cells[3,Count-1]:=Kni^.Naziv;
      StringGrid.Cells[4,Count-1]:=DateToStr(Kni^.Data);
      Str(Kni^.Dolzi:0:2,TSt);
      StringGrid.Cells[5,Count-1]:=TSt;
      Str(Kni^.Pobaruva:0:2,TSt);
      StringGrid.Cells[6,Count-1]:=TSt;
      Str(Kni^.Dolzi-Kni^.Pobaruva:0:2,TSt);
      StringGrid.Cells[7,Count-1]:=TSt;
      SDolzi:=SDolzi+Kni^.Dolzi;
      SPobaruva:=SPobaruva+Kni^.Pobaruva;
      End;
   End;
Str(SDolzi:0:2,TSt);
DolziSuma.Caption:=TSt;
Str(SPobaruva:0:2,TSt);
PobaruvaSuma.Caption:=TSt;
Str(SDolzi-SPobaruva:0:2,TSt);
Saldo.Caption:=TSt;
end;

procedure TKomintentKontoDocForm.OdDatumKeyPress(Sender: TObject;
  var Key: Char);
begin
If (Key=#13) Then DoDatum.SetFocus;
end;

procedure TKomintentKontoDocForm.DoDatumKeyPress(Sender: TObject;
  var Key: Char);
begin
If (Key=#13) Then Komintent.SetFocus;
end;

procedure TKomintentKontoDocForm.KomintentKeyPress(Sender: TObject; var Key: Char);
Var Count:LongInt;
   TSt:String;
   TInt:LongInt;
   Err:Integer;
begin
If (Key=#13) Then
   Begin
   Komintent.Text:=UpperCase(Komintent.Text);
   If (Komintent.Items.Count>0)Then
      For Count:=0 To Komintent.Items.Count-1 Do
         Begin
         Val(Komintent.Text,TInt,Err);
         If ((Err=0)And(TInt>=0)) Then
            Begin
            Str(TInt:6,TSt);
            If (TSt[1]=' ') Then TSt[1]:='0';
            If (TSt[2]=' ') Then TSt[2]:='0';
            If (TSt[3]=' ') Then TSt[3]:='0';
            If (TSt[4]=' ') Then TSt[4]:='0';
            If (TSt[5]=' ') Then TSt[5]:='0';
            If (TSt[6]=' ') Then TSt[6]:='0';
            If (Copy(Komintent.Items.Strings[Count],1,6)=TSt) Then
               Begin
               Komintent.ItemIndex:=Count;
               Konto.SetFocus;
               break;
               End;
            End;
         End;
   End;
end;

procedure TKomintentKontoDocForm.KontoKeyPress(Sender: TObject; var Key: Char);
Var Count:LongInt;
begin
If (Key=#13)Then
   Begin
   Konto.Text:=UpperCase(Konto.Text);
   If (Konto.Items.Count>0)Then
      For Count:=0 To Konto.Items.Count-1 Do
         Begin
         If (Copy(Konto.Items.Strings[Count],1,Length(Konto.Text))=Konto.Text) Then
            Begin
            Konto.ItemIndex:=Count;
            StringGrid.SetFocus;
            UpdateContains(False);
            break;
            End;
         End;
   End;
end;

end.
