unit KontaInsUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids;

type
  TKontaInsForm = class(TForm)
    StringGrid: TStringGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure StringGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateData;
  end;

var
  KontaInsForm: TKontaInsForm;

implementation

{$R *.DFM}
Uses MainUnit, NovoKontoUnit;

procedure TKontaInsForm.FormShow(Sender: TObject);
begin
StringGrid.Cells[0,0]:='Р.Б.';
StringGrid.ColWidths[0]:=30;
StringGrid.Cells[1,0]:='Конто';
StringGrid.ColWidths[1]:=44;
StringGrid.Cells[2,0]:='Опис';
StringGrid.ColWidths[2]:=286;
UpdateData;
end;

procedure TKontaInsForm.UpdateData;
Var Count:LongInt;
   KPl:PKPlanData;
   TSt:String;
begin
If (MainForm.KPlanList.Count>0) Then
   Begin
   StringGrid.RowCount:=MainForm.KPlanList.Count+2;
   For Count:=0 To MainForm.KPlanList.Count-1 Do
      Begin
      KPl:=MainForm.KPlanList.Items[Count];
      Str(Count+1,TSt);
      StringGrid.Cells[0,Count+1]:=TSt;
      StringGrid.Cells[1,Count+1]:=KPl.Konto;
      StringGrid.Cells[2,Count+1]:=KPl.Opis;
      End;
   End
   Else
   StringGrid.RowCount:=2;
StringGrid.Cells[0,StringGrid.RowCount-1]:='';
StringGrid.Cells[1,StringGrid.RowCount-1]:='';
StringGrid.Cells[2,StringGrid.RowCount-1]:='';
end;

procedure TKontaInsForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
Action:=caFree;
KontaInsForm:=Nil;
end;

procedure TKontaInsForm.StringGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
Var// Count:LongInt;
//   Kni:PKnigoData;
   KPl:PKPlanData;
   TempKey:Word;
begin
TempKey:=Key;
If (TempKey=45) Then // Insert
      Begin
      SendMessage(StringGrid.Handle,WM_KEYDOWN,35,0);
      TempKey:=13
      End;
If ((TempKey=46)And(StringGrid.Cells[0,StringGrid.Row]<>'')) Then // Delete
   Begin
   // Treba proverka dali se koristi kontoto
   //If (Application.MessageBox('Дали навистина сакаш да го избришеш избраното конто?','Предупредување!!',MB_OKCANCEL)=IDOK)Then
   End;
If (TempKey=13) Then
   Begin
   VnesiKonto:=TVnesiKonto.Create(Self);
   If (StringGrid.Cells[0,StringGrid.Row]<>'')Then
      Begin // Edit
      VnesiKonto.KontoOpis.Enabled:=False;
      KPl:=MainForm.KPLanList.Items[StringGrid.Row-1];
      VnesiKonto.KontoOpis.Text:=KPl.Konto;
      VnesiKonto.OpisOpis.Text:=KPl.Opis;
      If (VnesiKonto.ShowModal=mrOk)Then
         Begin
         KPl.Opis:=VnesiKonto.OpisOpis.Text;
         MainForm.NeSnimeno:=True;
         UpdateData;
         End;
      End
      Else
      Begin // Insert
      If (VnesiKonto.ShowModal=mrOk)Then
         Begin
         GetMem(KPl,SizeOf(KPlanData));
         KPl.Konto:=VnesiKonto.KontoOpis.Text;
         KPl.Opis:=VnesiKonto.OpisOpis.Text;
         MainForm.KPLanList.Add(KPl);
         MainForm.KPLanList.Sort(MainUnit.SortKontaKonto);
         MainForm.NeSnimeno:=True;
         UpdateData;
         End;
      End;
   VnesiKonto.Release;
   End;
end;

procedure TKontaInsForm.StringGridDrawCell(Sender: TObject; ACol,
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
end.
