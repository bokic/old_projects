unit NaloziViewUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls;

type
  TNaloziDocForm = class(TForm)
    StringGrid: TStringGrid;
    DolziSuma: TStaticText;
    PobaruvaSuma: TStaticText;
    SaldoSuma: TStaticText;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateData();
  end;

var
  NaloziDocForm: TNaloziDocForm;

implementation

uses MainUnit;

{$R *.DFM}

procedure TNaloziDocForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
Action:=caFree;
NaloziDocForm:=nil;
end;

procedure TNaloziDocForm.FormShow(Sender: TObject);
begin
StringGrid.Cells[0,0]:='Р.Б.';
StringGrid.ColWidths[0]:=30;
StringGrid.Cells[1,0]:='Опис';
StringGrid.ColWidths[1]:=100;
StringGrid.Cells[2,0]:='Датум';
StringGrid.ColWidths[2]:=60;
StringGrid.Cells[3,0]:='Должи';
StringGrid.ColWidths[3]:=90;
StringGrid.Cells[4,0]:='Побарува';
StringGrid.ColWidths[4]:=90;
StringGrid.Cells[5,0]:='Салдо';
StringGrid.ColWidths[5]:=100;
UpdateData;
end;

procedure TNaloziDocForm.UpdateData();
Var Count,Count2,C,C2:LongInt;
   Nal:PNalogData;
   Kni:PKnigoData;
   TSt:String;
   SDolzi,SPobaruva,SaldoDolzi,SaldoPobaruva:Currency;
begin
IF ((MainForm.NalogList.Count>0)And(MainForm.KnigoList.Count>0)) Then
   Begin
   C:=0;
   For Count:=1 To MainForm.NalogList.Count Do
      For Count2:=1 To MainForm.KnigoList.Count Do
         Begin
         Kni:=MainForm.KnigoList.Items[Count2-1];
         If (Kni.Nalog=Count)Then
            Begin
            Inc(C);
            Break;
            End;
         End;
   If (C=0) Then
      Begin
      End
      Else
      Begin
      StringGrid.RowCount:=C+1;
      C2:=0;
      SaldoDolzi:=0;
      SaldoPobaruva:=0;
      SendMessage(StringGrid.Handle,WM_SETREDRAW,0,0);
      For Count:=1 To MainForm.NalogList.Count Do
         Begin
         C:=0;
         SDolzi:=0;
         SPobaruva:=0;
         For Count2:=1 To MainForm.KnigoList.Count Do
            Begin
            Kni:=MainForm.KnigoList.Items[Count2-1];
            If (Kni.Nalog=Count)Then
               Begin
               SDolzi:=SDolzi+Kni.Dolzi;
               SPobaruva:=SPobaruva+Kni.Pobaruva;
               Inc(C);
               End;
            End;
         If (C>0)Then
            Begin
            Inc(C2);
            Str(C2,TSt);
            StringGrid.Cells[0,C2]:=TSt;
            Nal:=MainForm.NalogList.Items[Count-1];
            StringGrid.Cells[1,C2]:=Nal.Opis;
            StringGrid.Cells[2,C2]:=DateToStr(Nal^.Data);
            Str(SDolzi:13:2,TSt);
            StringGrid.Cells[3,C2]:=TSt;
            Str(SPobaruva:13:2,TSt);
            StringGrid.Cells[4,C2]:=TSt;
            Str(SDolzi-SPobaruva:13:2,TSt);
            StringGrid.Cells[5,C2]:=TSt;
            SaldoDolzi:=SaldoDolzi+SDolzi;
            SaldoPobaruva:=SaldoPobaruva+SPobaruva;
            End;
         End;
      SendMessage(StringGrid.Handle,WM_SETREDRAW,1,0);
      Str(SaldoDolzi:14:2,TSt);
      DolziSuma.Caption:=TSt;
      Str(SaldoPobaruva:14:2,TSt);
      PobaruvaSuma.Caption:=TSt;
      Str(SaldoDolzi-SaldoPobaruva:14:2,TSt);
      SaldoSuma.Caption:=TSt;
      Count:=MainForm.NalogList.Count;
      If (Count>13)Then
         Begin
         DolziSuma.Top:=271;
         PobaruvaSuma.Top:=271;
         End
         Else
         Begin
         DolziSuma.Top:=271-((14-Count)*18);
         PobaruvaSuma.Top:=271-((14-Count)*18);
         SaldoSuma.Top:=271-((14-Count)*18);
         If (Count=0)Then
            Begin
            DolziSuma.Visible:=False;
            PobaruvaSuma.Visible:=False;
            SaldoSuma.Visible:=False;
            End
            Else
            Begin
            DolziSuma.Visible:=True;
            PobaruvaSuma.Visible:=True;
            SaldoSuma.Visible:=True;
            End;
         End;
      End;
   End;
end;

procedure TNaloziDocForm.StringGridDrawCell(Sender: TObject; ACol,
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
      1:Levo:=Rect.Left+2;
      else
         Levo:=Rect.Right-StringGrid.Canvas.TextWidth(StringGrid.Cells[ACol,ARow])-2;
      End;
StringGrid.Canvas.TextOut(Levo,Rect.Top+1,StringGrid.Cells[ACol,ARow]);
end;

end.
