unit NalogViewUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ExtCtrls;

type
  TNalogDocForm = class(TForm)
    StringGrid: TStringGrid;
    Label1: TLabel;
    ComboBox: TComboBox;
    Date: TLabel;
    DolziSuma: TStaticText;
    PobaruvaSuma: TStaticText;
    procedure FormShow(Sender: TObject);
    procedure ComboBoxChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StringGridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
    IS_Grid_Sel:Boolean;
  public
    { Public declarations }
    procedure UpdateData(Nalog:Boolean);
  end;

var
  NalogDocForm: TNalogDocForm;

implementation
Uses MainUnit;
{$R *.DFM}

procedure TNalogDocForm.FormShow(Sender: TObject);
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
UpdateData(True);
end;

procedure TNalogDocForm.ComboBoxChange(Sender: TObject);
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
UpdateData(False);
end;

procedure TNalogDocForm.UpdateData(Nalog:Boolean);
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
   Exit;
Assert(MainForm.NalogList.Count>0);// Proveruva dali ima podatoci od nalog bazata
Val:=-1;
//Nal:=Nil;
For C:=0 To MainForm.NalogList.Count Do// Go naogja index-ot od nalog bazata
   Begin
   Nal:=MainForm.NalogList.Items[C];
   If (Nal.Opis=ComboBox.Items[ComboBox.ItemIndex])Then
      Begin
      Val:=C+1;
      Break;
      End;
   End;
//Assert(Nal<>nil);// Proveruva dali Nal e validen
//Assert(Nal.Opis=ComboBox.Items[ComboBox.ItemIndex]);// Proveruva dali go nashol index-ot
Assert(MainForm.KnigoList.Count>0);// Proveruva dali ima podatoci od knigo bazata
Count:=0;
SDolzi:=0;SPobaruva:=0;
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
Str(SDolzi:13:2,TSt);
DolziSuma.Caption:=TSt;
Str(SPobaruva:13:2,TSt);
PobaruvaSuma.Caption:=TSt;
If (Count>13)Then
   Begin
   DolziSuma.Top:=303;
   PobaruvaSuma.Top:=303;
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
      Str(Kni^.Dolzi:14:2,TSt);
      StringGrid.Cells[5,C-1]:=TSt;
      Str(Kni^.Pobaruva:14:2,TSt);
      StringGrid.Cells[6,C-1]:=TSt;
      If (Kni^.Komintent=0)Then
         StringGrid.Cells[7,C-1]:=''
         Else
         Begin
         Str(Kni^.Komintent,TSt);
         StringGrid.Cells[7,C-1]:=TSt;
         End
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
   StringGrid.Cells[7,1]:='';
   End;
end;

procedure TNalogDocForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
Action:=caFree;
NalogDocForm:=nil;
end;

procedure TNalogDocForm.StringGridDrawCell(Sender: TObject; ACol,
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
StringGrid.Canvas.TextOut(Levo,Rect.Top+1,StringGrid.Cells[ACol,ARow]);
end;

procedure TNalogDocForm.StringGridMouseMove(Sender: TObject;
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
end.
