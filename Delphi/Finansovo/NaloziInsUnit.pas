unit NaloziInsUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids;

type
  TNaloziInsForm = class(TForm)
    StringGrid: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
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
  NaloziInsForm: TNaloziInsForm;

implementation

{$R *.DFM}
Uses MainUnit, NovNalogUnit;
procedure TNaloziInsForm.FormShow(Sender: TObject);
begin
StringGrid.Cells[0,0]:='Р.Б.';
StringGrid.ColWidths[0]:=30;
StringGrid.Cells[1,0]:='Име';
StringGrid.ColWidths[1]:=90;
StringGrid.Cells[2,0]:='Датум';
StringGrid.ColWidths[2]:=90;
StringGrid.Cells[3,0]:='Број';
StringGrid.ColWidths[2]:=90;
UpdateData;
end;

procedure TNaloziInsForm.UpdateData;
Var CountNal,CountKni,FoundStavki:LongInt;
   Nal:PNalogData;
   Kni:PKnigoData;
   TSt:String;
begin
If (MainForm.NalogList.Count>0) Then
   Begin
   StringGrid.RowCount:=MainForm.NalogList.Count+2;
   CountKni:=0;
   For CountNal:=0 To MainForm.NalogList.Count-1 Do
      Begin
      Nal:=MainForm.NalogList.Items[CountNal];
      Str(CountNal+1,TSt);
      StringGrid.Cells[0,CountNal+1]:=TSt;
      StringGrid.Cells[1,CountNal+1]:=Nal.Opis;
      TSt:=DateToStr(Nal.Data);
      StringGrid.Cells[2,CountNal+1]:=TSt;
      FoundStavki:=0;
      if(CountKni<MainForm.KnigoList.Count)Then
         Begin
         Kni:=MainForm.KnigoList.Items[CountKni];
         while(Kni^.Nalog=CountNal+1)Do
            Begin
            Inc(FoundStavki);
            Inc(CountKni);
            if(CountKni>=MainForm.KnigoList.Count)Then
               break;
            Kni:=MainForm.KnigoList.Items[CountKni];
            End;
         End;
      Str(FoundStavki,TSt);
      StringGrid.Cells[3,CountNal+1]:=TSt;
      End;
   End
   Else
   StringGrid.RowCount:=2;
StringGrid.Cells[0,StringGrid.RowCount-1]:='';
StringGrid.Cells[1,StringGrid.RowCount-1]:='';
StringGrid.Cells[2,StringGrid.RowCount-1]:='';
StringGrid.Cells[3,StringGrid.RowCount-1]:='';
end;

procedure TNaloziInsForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
Action:=caFree;
NaloziInsForm:=Nil;
end;

procedure TNaloziInsForm.StringGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
Var Count:LongInt;
   Kni:PKnigoData;
   Nal:PNalogData;
   TempKey:Word;
   Sel:TGridRect;
begin
TempKey:=Key;
If (TempKey=45) Then // Insert
      Begin
      SendMessage(StringGrid.Handle,WM_KEYDOWN,35,0);
      TempKey:=13
      End;
If ((TempKey=46)And(StringGrid.Cells[0,StringGrid.Row]<>'')) Then // Delete
   Begin
   If (Application.MessageBox('Дали навистина сакаш да го избришеш избраниот налог?','Предупредување!!',MB_OKCANCEL)=IDOK)Then
      Begin
      If (MainForm.KnigoList.Count>0) Then
         For Count := MainForm.KnigoList.Count-1 DownTo 0 Do
            Begin
            Kni:=MainForm.KnigoList.Items[Count];
            If (Kni.Nalog=StringGrid.Row) Then
               Begin
               MainForm.KnigoList.Delete(Count);
               FreeMem(Kni,SizeOf(KnigoData));
               End
               Else
               If (Kni^.Nalog>StringGrid.Row) Then
                  Dec(Kni^.Nalog);
            End;
      Nal:=MainForm.NalogList.Items[StringGrid.Row-1];
      MainForm.NalogList.Delete(StringGrid.Row-1);
      FreeMem(Nal,SizeOf(NalogData));
      MainForm.NeSnimeno:=True;
      UpdateData;
      End;
   End;
If (TempKey=13) Then
   If (StringGrid.Cells[0,StringGrid.Row]<>'')Then
      Begin
      VnesiNalog:=TVnesiNalog.Create(Self);
      VnesiNalog.NalogOpis.Text:=StringGrid.Cells[1,StringGrid.Row];
      VnesiNalog.Datum.Text:=StringGrid.Cells[2,StringGrid.Row];
      Sel:=StringGrid.Selection;// Selection Bug - Begin
      Sel.Left:=1;
      Sel.Right:=4;
      StringGrid.Selection:=Sel;// Selection Bug - End
      If (VnesiNalog.ShowModal=mrOk)Then
         Begin
         Nal:=MainForm.NalogList.Items[StringGrid.Row-1];
         Nal.Opis:=VnesiNalog.NalogOpis.Text;
         Nal.Data:=StrToDate(VnesiNalog.Datum.Text);
         MainForm.NeSnimeno:=True;
         UpdateData;
         End;
      VnesiNalog.Release;
      End
      Else
      Begin
      VnesiNalog:=TVnesiNalog.Create(Self);
      VnesiNalog.Datum.Text:=DateToStr(Now());
      If (VnesiNalog.ShowModal=mrOk)Then
         Begin
         GetMem(Nal,SizeOf(NalogData));
         Nal.Opis:=VnesiNalog.NalogOpis.Text;
         Nal.Data:=StrToDate(VnesiNalog.Datum.Text);
         MainForm.NalogList.Add(Nal);
         MainForm.NeSnimeno:=True;
         UpdateData;
         End;
      //StringGrid.Selection:=StringGrid.Selection;
      VnesiNalog.Release;
      End;
end;

procedure TNaloziInsForm.StringGridDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var Levo:Integer;
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
      1: Levo:=Rect.Left+2;
      else
         Levo:=Rect.Right-StringGrid.Canvas.TextWidth(StringGrid.Cells[ACol,ARow])-2;
      End;
StringGrid.Canvas.TextOut(Levo,Rect.Top+1,StringGrid.Cells[ACol,ARow]);
end;

end.
