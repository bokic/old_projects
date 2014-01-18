unit KnizenjeInsUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, Menus;

type
  TKnizenjeInsForm = class(TForm)
    Label1: TLabel;
    Date: TLabel;
    StringGrid: TStringGrid;
    ComboBox: TComboBox;
    DolziSuma: TStaticText;
    PobaruvaSuma: TStaticText;
    VnesNal: TButton;
    PopupMenu: TPopupMenu;
    Izmeni1: TMenuItem;
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StringGridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure ComboBoxChange(Sender: TObject);
    procedure StringGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure StringGridKeyPress(Sender: TObject; var Key: Char);
    procedure VnesNalClick(Sender: TObject);
    procedure StringGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PopupMenuPopup(Sender: TObject);
  private
    { Private declarations }
    OldVal:String;
    Old_Pos:LongInt;
    Ins:Boolean;
    IS_Grid_Sel:Boolean;
    procedure UpdateSaldo;
  public
    { Public declarations }
    procedure UpdateData(Nalog:Boolean);
  end;

var
  KnizenjeInsForm: TKnizenjeInsForm;

implementation

uses MainUnit,NovNalogUnit, QuickKomintentUnit, QuickKontoUnit;

{$R *.DFM}

procedure TKnizenjeInsForm.StringGridDrawCell(Sender: TObject; ACol,
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
   StringGrid.Canvas.Pen.Color:=clBtnFace;
   StringGrid.Canvas.Brush.Color:=clBtnFace;
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
StringGrid.Canvas.TextOut(Levo,Rect.Top+1,StringGrid.Cells[ACol,ARow]);
end;

procedure TKnizenjeInsForm.StringGridMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
Var
   CelLeft,CelTop, Count:LongInt;
   Kon:PKPlanData;
   Kom:PKomintentData;
   TSt,TSt2:String;
   Rect:TRect;
   TT:^THintWindow;
begin
Application.HintPause:=0;
StringGrid.MouseToCell(X, Y,CelLeft,CelTop);
Asm
push eax
mov eax, Application
add eax,$84 // Offset za FHintWindow promenlivata, se gleda vo Application.HideHint
mov TT,eax
pop eax
End;

Case CelLeft Of
   2:
   If(CelTop>0) Then
      For Count:=0 To MainForm.KPlanList.Count-1 Do
          Begin
          Kon:=MainForm.KPlanList.Items[Count];
          If (Kon.Konto=StringGrid.Cells[CelLeft,CelTop]) Then
             Begin
             Rect:=TT.CalcHintRect(integer(Kon.Opis[0]),Kon.Opis,nil);
             Rect.Top:=Rect.Top+Mouse.CursorPos.y+16;
             Rect.Bottom:=Rect.Bottom+Mouse.CursorPos.y+16;
             Rect.Left:=Rect.Left+Mouse.CursorPos.x;
             Rect.Right:=Rect.Right+Mouse.CursorPos.x;
             TT.ActivateHint(Rect,Kon.Opis);
             End;
          End
          Else
          TT.ReleaseHandle;
   7:
   If((StringGrid.Cells[CelLeft,CelTop]<>'')And(CelTop>0)) Then
      For Count:=0 To MainForm.KomintentList.Count-1 Do
         Begin
         Kom:=MainForm.KomintentList.Items[Count];
         TSt2:=StringGrid.Cells[CelLeft,CelTop];
         Str(Kom.Sifra,TSt);
         If (TSt=StringGrid.Cells[CelLeft,CelTop]) Then
            Begin
             Rect:=TT.CalcHintRect(integer(Kom.Ime[0]),Kom.Ime,nil);
             Rect.Top:=Rect.Top+Mouse.CursorPos.y+16;
             Rect.Bottom:=Rect.Bottom+Mouse.CursorPos.y+16;
             Rect.Left:=Rect.Left+Mouse.CursorPos.x;
             Rect.Right:=Rect.Right+Mouse.CursorPos.x;
             TT.ActivateHint(Rect,Kom.Ime);
            End;
         End
      Else
      TT.ReleaseHandle;
   Else
   TT.ReleaseHandle;
   End;
if(IS_Grid_Sel=False)Then
   Begin
   SetCapture(StringGrid.Handle);
   IS_Grid_Sel:=True;
   End;
if((X<0)Or(Y<0)Or(X>StringGrid.Width)Or(Y>StringGrid.Height))Then
   Begin
   TT.ReleaseHandle;
   ReleaseCapture;
   IS_Grid_Sel:=False;
   End;
end;

procedure TKnizenjeInsForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
Action:=caFree;
KnizenjeInsForm:=nil;
end;

procedure TKnizenjeInsForm.FormShow(Sender: TObject);
begin
StringGrid.Cells[0,0]:='Р.Б.';
StringGrid.ColWidths[0]:=30;
StringGrid.Cells[1,0]:='Опис';
StringGrid.ColWidths[1]:=100;
StringGrid.Cells[2,0]:='Конто';
StringGrid.ColWidths[2]:=50;
StringGrid.Cells[3,0]:='Датум';
StringGrid.ColWidths[3]:=60;
StringGrid.Cells[4,0]:='Валута';
StringGrid.ColWidths[4]:=60;
StringGrid.Cells[5,0]:='Должи';
StringGrid.ColWidths[5]:=90;
StringGrid.Cells[6,0]:='Побарува';
StringGrid.ColWidths[6]:=90;
StringGrid.Cells[7,0]:='Коминт.';
StringGrid.ColWidths[7]:=50;
Old_Pos:=1;
UpdateData(True);
OldVal:=StringGrid.Cells[1,1];
end;

procedure TKnizenjeInsForm.ComboBoxChange(Sender: TObject);
Var Count:LongInt;
    Nal:PNalogData;
begin
If (ComboBox.Items[ComboBox.ItemIndex]='') Then Exit;
Assert(MainForm.NalogList.Count>0);
Count:=0;
Repeat
Inc(Count);
Nal:=MainForm.NalogList.Items[Count-1];
Until((Nal.Opis=ComboBox.Items[ComboBox.ItemIndex])Or(MainForm.NalogList.Count=Count));
Assert(Nal.Opis=ComboBox.Items[ComboBox.ItemIndex]);
Date.Caption:='Датум на налогот: '+DateToStr(Nal^.Data);
StringGrid.Col:=1;StringGrid.Row:=1;
StringGrid.Enabled:=True;
UpdateData(False);
end;

procedure TKnizenjeInsForm.UpdateData(Nalog:Boolean);
Var Count,C,Val,Lop:LongInt;
   Nal:PNalogData;
   Kni:PKnigoData;
   Data:String;
   TSt:String;
   SDolzi,SPobaruva:Currency;
begin
If (Nalog)Then
   Begin
   TSt:=ComboBox.Text;
   ComboBox.Items.Clear;
   If (MainForm.NalogList.Count>0) Then
      For Count:=1 To MainForm.NalogList.Count Do
         Begin
         Nal:=MainForm.NalogList.Items[Count-1];
         ComboBox.Items.Add(Nal.Opis);
         End;
   If (TSt<>'')Then
      Begin
      For Count:=0 To ComboBox.Items.Count-1 Do
         Begin
         If (TSt=ComboBox.Items[Count]) Then
            ComboBox.ItemIndex:=Count;
         End;
      End;
   End;
If (ComboBox.Items[ComboBox.ItemIndex]='') Then// Proveruva dali ima selektirano nalog
   Exit;// Ako nema iskaca od procedurata
Assert(MainForm.NalogList.Count>0);// Proveruva dali ima podatoci od nalog bazata
Val:=-1;
Nal:=Nil;
For C:=0 To MainForm.NalogList.Count Do// Go naogja index-ot od nalog bazata
   Begin
   Nal:=MainForm.NalogList.Items[C];
   If (Nal.Opis=ComboBox.Items[ComboBox.ItemIndex])Then
      Begin
      Val:=C+1;
      Break;
      End;
   End;
Assert(Nal<>nil);// Proveruva dali Nal e validen
Assert(Nal.Opis=ComboBox.Items[ComboBox.ItemIndex]);// Proveruva dali go nashol index-ot
If (MainForm.KnigoList.Count=0) Then// Proveruva dali ima podatoci od knigo bazata
   Exit;
Count:=0;SDolzi:=0;SPobaruva:=0;
// Od Ovde
For C:=0 To MainForm.KnigoList.Count-1 Do// Broi kolku stavki ima selektiraniot nalog
   Begin
   Kni:=MainForm.KnigoList.Items[C];
   If (Kni.Nalog=Val) Then
      Begin
      Inc(Count);
      SDolzi:=SDolzi+Kni^.Dolzi;
      SPobaruva:=SPobaruva+Kni^.Pobaruva;
      End;
   End;
If (Count=0)Then// Ja menuva goleminata na grid-ot
   StringGrid.RowCount:=2
   Else
   StringGrid.RowCount:=Count+2;
Str(SDolzi:13:2,TSt);
DolziSuma.Caption:=TSt;
Str(SPobaruva:13:2,TSt);
PobaruvaSuma.Caption:=TSt;
If (Count>12)Then
   Begin
   DolziSuma.Top:=303;
   PobaruvaSuma.Top:=303;
   End
   Else
   Begin
   DolziSuma.Top:=303-((14-Count-1)*18);
   PobaruvaSuma.Top:=303-((14-Count-1)*18);
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
   DolziSuma.Font.Color:=clWindowText;
   PobaruvaSuma.Font.Color:=clWindowText;
   End
   Else
   Begin
   DolziSuma.Font.Color:=clRed;
   PobaruvaSuma.Font.Color:=clRed;
   End;
Lop:=-1;
If (Count>0)Then
   For C:=2 To StringGrid.RowCount-1 Do// Gi prenesuva podatocite od bazata vo grid-ot
      Begin
      Str(C-1,TSt);
      StringGrid.Cells[0,C-1]:=TSt;
      Repeat
      Inc(Lop);
      Kni:=MainForm.KnigoList.Items[Lop];
      Until(Kni^.Nalog=Val);
      StringGrid.Cells[1,C-1]:=Kni^.Naziv;
      StringGrid.Cells[2,C-1]:=Kni^.Konto;
      StringGrid.Cells[3,C-1]:=DateToStr(Kni^.Data);
      If (Kni^.Valuta=0) Then
         Data:=''
         Else
         Data:=DateToStr(Kni^.Valuta);
      StringGrid.Cells[4,C-1]:=Data;
      Str(Kni^.Dolzi:0:2,TSt);
      StringGrid.Cells[5,C-1]:=TSt;
      Str(Kni^.Pobaruva:0:2,TSt);
      StringGrid.Cells[6,C-1]:=TSt;
      If (Kni^.Komintent=0)Then
         StringGrid.Cells[7,C-1]:=''
         Else
         Begin
         Str(Kni^.Komintent,TSt);
         StringGrid.Cells[7,C-1]:=TSt;
         End
      End;
StringGrid.Cells[0,Count+1]:='';
StringGrid.Cells[1,Count+1]:='';
StringGrid.Cells[2,Count+1]:='';
StringGrid.Cells[3,Count+1]:='';
StringGrid.Cells[4,Count+1]:='';
StringGrid.Cells[5,Count+1]:='';
StringGrid.Cells[6,Count+1]:='';
StringGrid.Cells[7,Count+1]:='';
end;

procedure TKnizenjeInsForm.StringGridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
Var TSt:String;
begin
If ((StringGrid.Cells[1,StringGrid.RowCount-1]<>'')Or(StringGrid.Cells[2,StringGrid.RowCount-1]<>'')Or
   (StringGrid.Cells[3,StringGrid.RowCount-1]<>'')Or(StringGrid.Cells[4,StringGrid.RowCount-1]<>'')Or
   (StringGrid.Cells[5,StringGrid.RowCount-1]<>'')Or(StringGrid.Cells[6,StringGrid.RowCount-1]<>'')Or
   (StringGrid.Cells[7,StringGrid.RowCount-1]<>''))Then
   Begin
   Ins:=True;
   StringGrid.RowCount:=StringGrid.RowCount+1;
   
   StringGrid.Cells[0,StringGrid.Row+1]:='';
   StringGrid.Cells[1,StringGrid.Row+1]:='';
   StringGrid.Cells[2,StringGrid.Row+1]:='';
   StringGrid.Cells[3,StringGrid.Row+1]:='';
   StringGrid.Cells[4,StringGrid.Row+1]:='';
   StringGrid.Cells[5,StringGrid.Row+1]:='';
   StringGrid.Cells[6,StringGrid.Row+1]:='';
   StringGrid.Cells[7,StringGrid.Row+1]:='';

   Str(StringGrid.RowCount-2,TSt);
   StringGrid.Cells[0,StringGrid.RowCount-2]:=TSt;
   StringGrid.Cells[5,StringGrid.RowCount-2]:='0';
   StringGrid.Cells[6,StringGrid.RowCount-2]:='0';
   If (StringGrid.RowCount>14)Then
      Begin
      DolziSuma.Top:=303;
      PobaruvaSuma.Top:=303;
      End
      Else
      Begin
      DolziSuma.Top:=303-((15-StringGrid.RowCount)*18);
      PobaruvaSuma.Top:=303-((15-StringGrid.RowCount)*18);
      If (StringGrid.RowCount=0)Then
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
   End;
If ((Ins)And(Old_Pos<>aRow)) Then
   Begin
   CanSelect:=False;
   End
   Else
   Old_Pos:=ARow;
end;

procedure TKnizenjeInsForm.StringGridKeyPress(Sender: TObject; var Key: Char);
var
   Kni:PKnigoData;
   KPla:PKPlanData;
   Kom:PKomintentData;
   TSt:String;
   Count,TPos:LongInt;
   TEx:Extended;
   TInt:Integer;
   Err:Integer;
   Found:Boolean;
begin
If (Key=#13) Then
   Begin
   If (StringGrid.Col<7) Then
      Begin
      StringGrid.Col:=StringGrid.Col+1;
      StringGrid.EditorMode:=False;
      StringGrid.EditorMode:=True;
      End
      Else
      Begin
      If (StringGrid.Cells[2,StringGrid.Row]<>'')Then
         Begin
         If (MainForm.KPLanList.Count>0)Then  //Pregled na validnost na podatocite.
            Begin
            Found:=False;
            For Count:=0 To MainForm.KPLanList.Count-1 Do
               Begin
               KPla:=MainForm.KPLanList.Items[Count];
               If (KPla.Konto=StringGrid.Cells[2,StringGrid.Row])Then
                  Begin
                  Found:=True;
                  break;
                  End;
               End;
           If (Found=False) Then
               Begin
               Application.MessageBox('Нема податок за внесеното конто','Грешка!!');
               Exit;
               End;
            End
            Else
            Begin
            Application.MessageBox('Нема податоци во контниот план','Грешка!!');
            exit;
            End;
         If ((StringGrid.Cells[3,StringGrid.Row]<>'')Or((StringGrid.Cells[3,StringGrid.Row]='')And(StringGrid.Row<=1))) Then
            Begin
            If (StringGrid.Cells[3,StringGrid.Row]<>'') Then
               Begin
                  try
                  {$I-}
                  StrToDate(StringGrid.Cells[3,StringGrid.Row]);
                  {$I+}
                  except
                     on E: EConvertError do
                        Begin
                        Application.MessageBox('Полето "Датум" не содржи валиден датум','Грешка!!');
                        Exit;
                        End;
                  End;
               End
               Else
               Begin
               Application.MessageBox('Полето "Датум" мора да има вредност','Грешка!!');
               Exit;
               End;
            End;
         If (StringGrid.Cells[4,StringGrid.Row]<>'') Then
            Begin
               try
               {$I-}
               StrToDate(StringGrid.Cells[4,StringGrid.Row]);
               {$I+}
               except
                  on E: EConvertError do
                     Begin
                     Application.MessageBox('Полето "Валута" не содржи валиден датум','Грешка!!');
                     Exit;
                     End;
                End;
            End;
         {$R-}
         Val(StringGrid.Cells[5,StringGrid.Row],TEx,Err);
         {$R+}
         If (Err<>0) Then
            Begin
            Application.MessageBox('Полето "Должи" не содржи валидна вредност','Грешка!!');
            Exit;
            End;
         Str(TEx:0:2,TSt);
         StringGrid.Cells[5,StringGrid.Row]:=TSt;
         {$R-}
         Val(StringGrid.Cells[6,StringGrid.Row],TEx,Err);
         {$R+}
         If (Err<>0) Then
            Begin
            Application.MessageBox('Полето "Побарува" не содржи валидна вредност','Грешка!!');
            Exit;
            End;
         Str(TEx:0:2,TSt);
         StringGrid.Cells[6,StringGrid.Row]:=TSt;
         If (StringGrid.Cells[7,StringGrid.Row]<>'')Then
            Begin
            {$R-}
            Val(StringGrid.Cells[7,StringGrid.Row],TInt,Err);
            {$R+}
            If (Err<>0) Then
               Begin
               Application.MessageBox('Полето "Коминтент" не содржи валидна вредност','Грешка!!');
               Exit;
               End;
            If (MainForm.KomintentList.Count>0) Then
               Begin
               Found:=False;
               For Count:=0 To MainForm.KomintentList.Count-1 Do
                  Begin
                  Kom:=MainForm.KomintentList.Items[Count];
                  If (Kom.Sifra=TInt) Then
                     Begin
                     Found:=True;
                     Break;
                     End;
                  End;
               If (Found=False) Then
                  Begin
                  Application.MessageBox('Нема податок за внесениот коминтент','Грешка!!');
                  Exit;
                  End;
               End
               Else
               Begin
               Application.MessageBox('Нема податоци за коминтенти','Грешка!!');
               Exit;
               End;
            End;
         Count:=0;TPos:=0;
         If (Ins) Then
            Begin
            GetMem(Kni,SizeOf(KnigoData));
            Kni^.Nalog:=ComboBox.ItemIndex+1;
            MainForm.KnigoList.Add(Kni);
            End
            Else
            Repeat
            Kni:=MainForm.KnigoList.Items[TPos];
            If (Kni^.Nalog=ComboBox.ItemIndex+1) Then
               Inc(Count);
            Inc(TPos);
            Until(Count=StringGrid.Row);
         Kni^.Naziv:=StringGrid.Cells[1,StringGrid.Row];
         Kni^.Konto:=StringGrid.Cells[2,StringGrid.Row];
         Kni^.Data:=StrToDate(StringGrid.Cells[3,StringGrid.Row]);
         StringGrid.Cells[3,StringGrid.Row]:=DateToStr(Kni^.Data);
         If (StringGrid.Cells[4,StringGrid.Row]='') Then
            Kni^.Valuta:=0
            Else
            Begin
            Kni^.Valuta:=StrToDate(StringGrid.Cells[4,StringGrid.Row]);
            StringGrid.Cells[4,StringGrid.Row]:=DateToStr(Kni^.Valuta);
            End;
         Val(StringGrid.Cells[5,StringGrid.Row],TEx,Err);
         Str(TEx:0:2,TSt);
         StringGrid.Cells[5,StringGrid.Row]:=TSt;
         Kni^.Dolzi:=TEx;
         Val(StringGrid.Cells[6,StringGrid.Row],TEx,Err);
         Str(TEx:0:2,TSt);
         StringGrid.Cells[6,StringGrid.Row]:=TSt;
         Kni^.Pobaruva:=TEx;
         Val(StringGrid.Cells[7,StringGrid.Row],Kni^.Komintent,Err);
         MainForm.NeSnimeno:=True;
         If ((Ins)And(StringGrid.Row>1)And(StringGrid.Cells[1,StringGrid.RowCount-2]=''))Then
            StringGrid.Cells[1,StringGrid.RowCount-2]:=StringGrid.Cells[1,StringGrid.RowCount-3];
         Ins:=False;
         StringGrid.Col:=1;
         StringGrid.Row:=StringGrid.Row+1;
         UpdateSaldo;
         End;
      End;
   end;
If (Key=#27) Then
   If (Ins)Then
      Begin
      StringGrid.RowCount:=StringGrid.RowCount-1;
      StringGrid.Cells[0,StringGrid.Row]:='';
      StringGrid.Cells[1,StringGrid.Row]:='';
      StringGrid.Cells[2,StringGrid.Row]:='';
      StringGrid.Cells[3,StringGrid.Row]:='';
      StringGrid.Cells[4,StringGrid.Row]:='';
      StringGrid.Cells[5,StringGrid.Row]:='';
      StringGrid.Cells[6,StringGrid.Row]:='';
      StringGrid.Cells[7,StringGrid.Row]:='';
      Ins:=False;
      UpdateSaldo;
      End
      Else
      Begin
      End;
end;

procedure TKnizenjeInsForm.VnesNalClick(Sender: TObject);
Var VnNal:TVnesiNalog;
   NalRec:PNalogData;
   Datum:TDate;
begin
VnNal:=TVnesiNalog.Create(Self);
VnNal.Datum.Text:=DateToStr(Now());
If (VnNal.ShowModal=mrOK) Then
   Begin
   Datum:=StrToDate(VnNal.Datum.Text);
   GetMem(NalRec,SizeOf(NalogData));
   NalRec.Opis:=VnNal.NalogOpis.Text;
   NalRec.Data:=Datum;
   MainForm.NalogList.Add(NalRec);
   MainForm.NeSnimeno:=True;
   Date.Caption:='Датум на налогот: '+DateToStr(NalRec^.Data);
   ComboBox.ItemIndex:=ComboBox.Items.Add(NalRec^.Opis);
   UpdateData(True);
   Ins:=False;
   StringGrid.Enabled:=True;
   StringGrid.Row:=1;
   StringGrid.RowCount:=2;
   StringGrid.Cells[0,StringGrid.Row]:='';
   StringGrid.Cells[1,StringGrid.Row]:='';
   StringGrid.Cells[2,StringGrid.Row]:='';
   StringGrid.Cells[3,StringGrid.Row]:='';
   StringGrid.Cells[4,StringGrid.Row]:='';
   StringGrid.Cells[5,StringGrid.Row]:='';
   StringGrid.Cells[6,StringGrid.Row]:='';
   StringGrid.Cells[7,StringGrid.Row]:='';
   StringGrid.SetFocus;
   End;
VnNal.Free;
end;

procedure TKnizenjeInsForm.UpdateSaldo;
Var C1,C2:LongInt;
   Kni:PKnigoData;
   Nal:PNalogData;
   TSt:String;
   SDolzi,SPobaruva:Extended;
begin
SDolzi:=0;SPobaruva:=0;
If (MainForm.NalogList.Count>0) Then
   For C1:=0 To MainForm.NalogList.Count-1 Do
      Begin
      Nal:=MainForm.NalogList.Items[C1];
      If (Nal.Opis=ComboBox.Text) Then
         Begin
         If (MainForm.KnigoList.Count>0) Then
            For C2:=0 To MainForm.KnigoList.Count-1 Do
               Begin
               Kni:=MainForm.KnigoList.Items[C2];
               If (Kni.Nalog=C1+1) Then
                  Begin
                  SDolzi:=SDolzi+Kni.Dolzi;
                  SPobaruva:=SPobaruva+Kni.Pobaruva;
                  End;
               End;
         break;
         End;
      End;
Str(SDolzi:0:2,TSt);
DolziSuma.Caption:=TSt;
Str(SPobaruva:0:2,TSt);
PobaruvaSuma.Caption:=TSt;
If (StringGrid.RowCount>14)Then
   Begin
   DolziSuma.Top:=303;
   PobaruvaSuma.Top:=303;
   End
   Else
   Begin
   DolziSuma.Top:=303-((15-StringGrid.RowCount)*18);
   PobaruvaSuma.Top:=303-((15-StringGrid.RowCount)*18);
   End;
If (SDolzi=Spobaruva)Then
   Begin
   DolziSuma.Font.Color:=clWindowText;
   PobaruvaSuma.Font.Color:=clWindowText;
   End
   Else
   Begin
   DolziSuma.Font.Color:=clRed;
   PobaruvaSuma.Font.Color:=clRed;
   End;
end;
procedure TKnizenjeInsForm.StringGridKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
If ((Key=116)And(StringGrid.Col=7))Then
   Begin
   QuickKomintentForm:=TQuickKomintentForm.Create(Self);
   If (QuickKomintentForm.ShowModal=mrOk) Then
      Begin
      StringGrid.Cells[7,StringGrid.Row]:=QuickKomintentForm.StringGrid.Cells[0,QuickKomintentForm.StringGrid.Row];
      End;
   QuickKomintentForm.Close;
   End;
If ((Key=116)And(StringGrid.Col=2))Then
   Begin
   QuickKontoForm:=TQuickKontoForm.Create(Self);
   If (QuickKontoForm.ShowModal=mrOk) Then
      Begin
      StringGrid.Cells[2,StringGrid.Row]:=QuickKontoForm.StringGrid.Cells[0,QuickKontoForm.StringGrid.Row];
      End;
   QuickKontoForm.Close;
   End;
end;

procedure TKnizenjeInsForm.PopupMenuPopup(Sender: TObject);
begin
StringGrid.DefaultDrawing:=True;
//StringGrid.Options:=[goRowSelect];
end;

end.
