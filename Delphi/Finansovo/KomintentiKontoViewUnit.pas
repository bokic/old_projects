unit KomintentiKontoViewUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ComCtrls;

type
  TKomintentiKontoDocForm = class(TForm)
    OdDatum: TDateTimePicker;
    DoDatum: TDateTimePicker;
    StringGrid: TStringGrid;
    DolziSuma: TStaticText;
    PobaruvaSuma: TStaticText;
    Konto: TComboBox;
    Saldo: TStaticText;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormShow(Sender: TObject);
    procedure OdDatumKeyPress(Sender: TObject; var Key: Char);
    procedure DoDatumKeyPress(Sender: TObject; var Key: Char);
    procedure KontoKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateContains(FullData:Boolean);
  end;

var
  KomintentiKontoDocForm: TKomintentiKontoDocForm;

implementation

uses MainUnit;

{$R *.DFM}

procedure TKomintentiKontoDocForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
Action:=caFree;
KomintentiKontoDocForm:=nil;
end;

procedure TKomintentiKontoDocForm.StringGridDrawCell(Sender: TObject; ACol,
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
StringGrid.Canvas.TextRect(Rect,Levo,Rect.Top+1,StringGrid.Cells[ACol,ARow]);
end;

procedure TKomintentiKontoDocForm.FormShow(Sender: TObject);
begin
OdDatum.DateTime:=MainForm.OdDatum;
DoDatum.DateTime:=MainForm.DoDatum;
StringGrid.Cells[0,0]:='Р.Б.';
StringGrid.ColWidths[0]:=30;
StringGrid.Cells[1,0]:='Шифра';
StringGrid.ColWidths[1]:=60;
StringGrid.Cells[2,0]:='Коминтент';
StringGrid.ColWidths[2]:=180;
StringGrid.Cells[3,0]:='Должи';
StringGrid.ColWidths[3]:=90;
StringGrid.Cells[4,0]:='Побарува';
StringGrid.ColWidths[4]:=90;
StringGrid.Cells[5,0]:='Салдо';
StringGrid.ColWidths[5]:=90;
UpdateContains(True);
end;

procedure TKomintentiKontoDocForm.UpdateContains(FullData:Boolean);
Type
   PTempRec=^TempRec;
   TempRec=Record
      Komintent:Word;
      Dolzi:Currency;
      Pobaruva:Currency;
      End;
Var Count,Count2{,TInt},C{,C2}:LongInt;
//   Err:Integer;
   Kon:PKPlanData;
//   Nal:PNalogdata;
   Kni:PKnigoData;
   Kom:PKomintentData;
   TRec:PTempRec;
   TSt,TSt2:String;
   SDolzi,SPobaruva:Currency;
   Found:Boolean;
   TempList:TList;
begin
If ((MainForm.KnigoList.Count=0)Or(MainForm.KomintentList.Count=0)Or(MainForm.KPlanList.Count=0)) Then Exit;
TempList:=TList.Create;
try
If (FullData) Then
   Begin
   TSt2:=Konto.Text;
   Konto.Items.Clear;
   For C:=0 To MainForm.KPlanList.Count-1 Do
      Begin
      Kon:=MainForm.KPlanList.Items[C];
      Konto.Items.Add(Kon^.Konto+' - '+Kon^.Opis);
      End;
   End;
If (Konto.Text<>'') Then
   Begin
   TSt:=Copy(Konto.Text,1,6);
   If ((Length(TSt)=6)And(TSt[6]=' ')) Then
      Begin
      SetLength(TSt,5);
      If (TSt[5]=' ') Then
         SetLength(TSt,4);
      End;
   For Count:=0 to MainForm.KnigoList.Count-1 Do
      Begin
      Kni:=MainForm.KnigoList.Items[Count];
      Found:=False;
      If((Kni^.Data>=OdDatum.Date)And(Kni^.Data<=DoDatum.Date)And
         (Kni^.Konto=TSt)) Then
         Begin
         Count2:=0;
         If (TempList.Count>0) Then
            For Count2:= 0 To TempList.Count-1 Do
               Begin
               TRec:=TempList.Items[Count2];
               If (TRec^.Komintent=Kni^.Komintent) Then
                  Begin
                  TRec^.Dolzi:=TRec^.Dolzi+Kni^.Dolzi;
                  TRec^.Pobaruva:=TRec^.Pobaruva+Kni^.Pobaruva;
                  Found:=True;
                  Break;
                  End
                  Else
                  If (TRec^.Komintent>Kni^.Komintent) Then
                     Break;
               End;
         If (Found=False) Then
            Begin
            GetMem(TRec,SizeOf(TempRec));
            TRec^.Komintent:=Kni^.Komintent;
            TRec^.Dolzi:=Kni^.Dolzi;
            TRec^.Pobaruva:=Kni^.Pobaruva;
            TempList.Insert(Count2,TRec);
            End;
         End;
      End;

   SDolzi:=0;SPobaruva:=0;
   If (TempList.Count=0) Then
      Begin
      StringGrid.RowCount:=2;
      StringGrid.Cells[0,1]:='';
      StringGrid.Cells[1,1]:='';
      StringGrid.Cells[2,1]:='';
      StringGrid.Cells[3,1]:='';
      StringGrid.Cells[4,1]:='';
      StringGrid.Cells[5,1]:='';
      End
      Else
      Begin
      StringGrid.RowCount:=TempList.Count+1;
      For Count:=0 To TempList.Count-1 Do
         Begin
         TRec:=TempList.Items[Count];
         Str(Count+1,TSt);
         StringGrid.Cells[0,Count+1]:=TSt;
         Str(TRec^.Komintent,TSt);
         StringGrid.Cells[1,Count+1]:=TSt;
         For Count2:=0 To MainForm.KomintentList.Count -1 Do
            Begin
            Kom:=MainForm.KomintentList.Items[Count2];
            If (Kom^.Sifra=TRec^.Komintent) Then
               Begin
               StringGrid.Cells[2,Count+1]:=Kom^.Ime;
               Break;
               End;
            End;
         Str(TRec^.Dolzi:0:2,TSt);
         StringGrid.Cells[3,Count+1]:=TSt;
         Str(TRec^.Pobaruva:0:2,TSt);
         StringGrid.Cells[4,Count+1]:=TSt;
         Str(TRec^.Dolzi-TRec^.Pobaruva:0:2,TSt);
         StringGrid.Cells[5,Count+1]:=TSt;
         SDolzi:=SDolzi+TRec^.Dolzi;
         SPobaruva:=SPobaruva+TRec^.Pobaruva;
         End;
      End;
   Str(SDolzi:0:2,TSt);
   DolziSuma.Caption:=TSt;

   Str(SPobaruva:0:2,TSt);
   PobaruvaSuma.Caption:=TSt;

   Str(SDolzi-SPobaruva:0:2,TSt);
   Saldo.Caption:=TSt;
   End;

finally
If (TempList.Count>0)Then
   For Count:=0 To TempList.Count-1 Do
      FreeMem(TempList.Items[Count],SizeOf(TempRec));
TempList.Free;
end;
end;

procedure TKomintentiKontoDocForm.OdDatumKeyPress(Sender: TObject;
  var Key: Char);
begin
If (Key=#13) Then DoDatum.SetFocus;
end;

procedure TKomintentiKontoDocForm.DoDatumKeyPress(Sender: TObject;
  var Key: Char);
begin
If (Key=#13) Then Konto.SetFocus;
end;

procedure TKomintentiKontoDocForm.KontoKeyPress(Sender: TObject; var Key: Char);
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
