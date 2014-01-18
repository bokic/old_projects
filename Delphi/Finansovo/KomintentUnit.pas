unit KomintentUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ComCtrls;

type
  TKomintentDocForm = class(TForm)
    OdDatum: TDateTimePicker;
    DoDatum: TDateTimePicker;
    Komintent: TComboBox;
    StringGrid: TStringGrid;
    DolziSuma: TStaticText;
    PobaruvaSuma: TStaticText;
    Saldo: TStaticText;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure KomintentChange(Sender: TObject);
    procedure OdDatumKeyPress(Sender: TObject; var Key: Char);
    procedure DoDatumKeyPress(Sender: TObject; var Key: Char);
    procedure KomintentKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateContains(FullData:Boolean);
  end;

var
  KomintentDocForm: TKomintentDocForm;

implementation
Uses MainUnit;
{$R *.DFM}

procedure TKomintentDocForm.FormShow(Sender: TObject);
begin
OdDatum.DateTime:=MainForm.OdDatum;
DoDatum.DateTime:=MainForm.DoDatum;
StringGrid.Cells[0,0]:='Р.Б.';
StringGrid.ColWidths[0]:=30;
StringGrid.Cells[1,0]:='Конто';
StringGrid.ColWidths[1]:=60;
StringGrid.Cells[2,0]:='Опис';
StringGrid.ColWidths[2]:=180;
StringGrid.Cells[3,0]:='Должи';
StringGrid.ColWidths[3]:=90;
StringGrid.Cells[4,0]:='Побарува';
StringGrid.ColWidths[4]:=90;
StringGrid.Cells[5,0]:='Салдо';
StringGrid.ColWidths[5]:=90;
UpdateContains(True);
end;

procedure TKomintentDocForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
Action:=caFree;
KomintentDocForm:=nil;
end;

procedure TKomintentDocForm.StringGridDrawCell(Sender: TObject; ACol,
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

procedure TKomintentDocForm.UpdateContains(FullData:Boolean);
Type
   PTempRec=^TempRec;
   TempRec=Record
      Konto:String[6];
      Dolzi:Currency;
      Pobaruva:Currency;
      End;
Var Count,Count2,C:LongInt;
   Err:Integer;
   Kon:PKPlanData;
   Kni:PKnigoData;
   Kom:PKomintentData;
   TRec,TRec2:PTempRec;
   TSt,TSt2:String;
   SDolzi,SPobaruva:Currency;
   Found:Boolean;
   TempList:TList;
begin
If ((MainForm.KnigoList.Count=0)Or(MainForm.KomintentList.Count=0)) Then Exit;
TempList:=TList.Create;
try
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
      If (TSt2=TSt+' - '+Kom.Ime) Then
         Komintent.ItemIndex:=Komintent.Items.Add(TSt+' - '+Kom.Ime)
         Else
         Komintent.Items.Add(TSt+' - '+Kom.Ime);
      End;
   End;
If (Komintent.Text<>'') Then
   Begin
   //TempList:=TList.Create;
   For Count:=0 to MainForm.KnigoList.Count-1 Do
      Begin
      Kni:=MainForm.KnigoList.Items[Count];
      Found:=False;
      Val(Copy(Komintent.Text,1,6),C,Err);
      If((Kni^.Data>=OdDatum.Date)And(Kni^.Data<=DoDatum.Date)And
         (Kni^.Komintent=C))Then
         Begin
         If (TempList.Count>0)Then
            For Count2:=0 To TempList.Count-1 Do
               Begin
               TRec:=TempList.Items[Count2];
               If (TRec.Konto=Kni^.Konto) Then
                  Begin
                  Found:=True;
                  TRec.Dolzi:=TRec.Dolzi+Kni^.Dolzi;
                  TRec.Pobaruva:=TRec.Pobaruva+Kni^.Pobaruva;
                  break;
                  End;
               End;
         If (Found=False)Then
            Begin
            GetMem(TRec,SizeOf(TempRec));
            TRec.Konto:=Kni.Konto;
            TRec.Dolzi:=Kni.Dolzi;
            TRec.Pobaruva:=Kni.Pobaruva;
            If (TempList.Count=0) Then
               TempList.Add(TRec)
               Else
               For Count2:=0 To TempList.Count-1 Do
                  Begin
                  TRec2:=TempList.Items[Count2];
                  If (CompareStr(TRec.Konto,TRec2.Konto)<1) Then
                     Begin
                     TempList.Insert(Count2,TRec);
                     Break;
                     End;
                  If (Count2=TempList.Count-1) Then
                     TempList.Add(TRec);
                  End;
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
         StringGrid.Cells[1,Count+1]:=TRec^.Konto;
         For Count2:=0 To MainForm.KPLanList.Count -1 Do
            Begin
            Kon:=MainForm.KPLanList.Items[Count2];
            If (Kon^.Konto=TRec^.Konto) Then
               Begin
               StringGrid.Cells[2,Count+1]:=Kon^.Opis;
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

procedure TKomintentDocForm.KomintentChange(Sender: TObject);
begin
If (Komintent.ItemIndex>=0) Then
   UpdateContains(False);
end;

procedure TKomintentDocForm.OdDatumKeyPress(Sender: TObject;
  var Key: Char);
begin
If (Key=#13) Then DoDatum.SetFocus;
end;

procedure TKomintentDocForm.DoDatumKeyPress(Sender: TObject;
  var Key: Char);
begin
If (Key=#13) Then Komintent.SetFocus;
end;

procedure TKomintentDocForm.KomintentKeyPress(Sender: TObject; var Key: Char);
Var Count:LongInt;
   TSt:String;
   TInt:LongInt;
   Err:Integer;
begin
If (Key=#13)Then
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
               KomintentChange(Sender);
               StringGrid.SetFocus;
               break;
               End;
            End;
         End;
   End;
end;

end.
