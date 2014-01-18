unit KomintentiInsUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids;

type
  TKomintentInsForm = class(TForm)
    StringGrid: TStringGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StringGridKeyPress(Sender: TObject; var Key: Char);
    procedure StringGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure StringGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    InsertGrid:Boolean;
  public
    { Public declarations }
    procedure UpdateData;
  end;

var
  KomintentInsForm: TKomintentInsForm;

implementation

uses MainUnit;

{$R *.DFM}

procedure TKomintentInsForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
Action:=caFree;
KomintentInsForm:=Nil;
end;

procedure TKomintentInsForm.FormShow(Sender: TObject);
begin
StringGrid.Cells[0,0]:='Р.Б.';
StringGrid.ColWidths[0]:=30;
StringGrid.Cells[1,0]:='Шифра';
StringGrid.ColWidths[1]:=80;
StringGrid.Cells[2,0]:='Коминтент';
StringGrid.ColWidths[2]:=344;
UpdateData;
end;

procedure TKomintentInsForm.UpdateData;
Var Count:LongInt;
   Kom:PKomintentData;
   TSt:String;
begin
If (MainForm.KomintentList.Count>0) Then
   Begin
   StringGrid.RowCount:=MainForm.KomintentList.Count+2;
   For Count:=0 To MainForm.KomintentList.Count-1 Do
      Begin
      Kom:=MainForm.KomintentList.Items[Count];
      Str(Count+1,TSt);
      StringGrid.Cells[0,Count+1]:=TSt;
      Str(Kom.Sifra,TSt);
      StringGrid.Cells[1,Count+1]:=TSt;
      StringGrid.Cells[2,Count+1]:=Kom.Ime;
      End;
   End
   Else
   StringGrid.RowCount:=2;
StringGrid.Cells[0,StringGrid.RowCount-1]:='';
StringGrid.Cells[1,StringGrid.RowCount-1]:='';
StringGrid.Cells[2,StringGrid.RowCount-1]:='';
end;

procedure TKomintentInsForm.StringGridDrawCell(Sender: TObject; ACol,
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
      1,2:Levo:=Rect.Left+2;
      else
         Levo:=Rect.Right-StringGrid.Canvas.TextWidth(StringGrid.Cells[ACol,ARow])-2;
      End;
StringGrid.Canvas.TextOut(Levo,Rect.Top+1,StringGrid.Cells[ACol,ARow]);
end;

procedure TKomintentInsForm.StringGridKeyPress(Sender: TObject;
  var Key: Char);
label Clean;
var Kom:PKomintentData;
    Sel:TGridRect;
    C,Err:Integer;
    Sifra:Word;
    Inserted:Boolean;
begin
if(Key=#13)Then
   if (goEditing in StringGrid.Options)Then
      Begin
      if (StringGrid.Col=1)Then
         Begin
         StringGrid.Col:=2;
         End
         else
         Begin
         if(InsertGrid=True)Then
            Begin
            StringGrid.Options:=[goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,goDrawFocusSelected,goRowSelect,goThumbTracking];
            Inserted:=True;
            Val(StringGrid.Cells[1,StringGrid.Row],Sifra,Err);
            if(Err<>0) Then
                  Begin
                  Application.MessageBox('Невалидна шифра за коминтент','Грешка!!',MB_OK);
                  goto Clean;
                  End;
            for C:=0 to MainForm.KomintentList.Count-1 Do
               Begin
               Kom:=MainForm.KomintentList.Items[C];
               if(Kom^.Sifra=Sifra)Then
                  Begin
                  Application.MessageBox('Внесениот коминтент веќе постои','Грешка!!',MB_OK);
                  goto Clean;
                  End;
               End;
            if(Inserted)Then
               Begin
               System.GetMem(Kom,SizeOf(KomintentData));
               System.FillChar(Kom^,SizeOf(KomintentData),0);
               Kom^.Sifra:=Sifra;
               Kom^.Ime:=StringGrid.Cells[2,StringGrid.Row];
               MainForm.KomintentList.Add(Kom);
               MainForm.NeSnimeno:=True;
               MainForm.KomintentList.Sort(SortKomintentiSifra);
               UpdateData;
               StringGrid.Row:=StringGrid.RowCount-1;
               End;
            InsertGrid:=False;
            End
            Else
            Begin
            StringGrid.Options:=[goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,goDrawFocusSelected,goRowSelect,goThumbTracking];
            Kom:=MainForm.KomintentList.Items[StringGrid.Row-1];
            Kom.Ime:=StringGrid.Cells[2,StringGrid.Row];
            MainForm.NeSnimeno:=True;
            End;
         End;
      End
      Else
      Begin
      StringGrid.Options:=[goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,goDrawFocusSelected,goThumbTracking];
      Sel:=StringGrid.Selection;// Selection Bug - Begin
      if(StringGrid.Row+1=StringGrid.RowCount)Then
         Begin
         StringGrid.Col:=1;
         InsertGrid:=True;
         Sel.Left:=1;
         Sel.Right:=1;
         End
         Else
         Begin
         StringGrid.Col:=2;
         Sel.Left:=2;
         Sel.Right:=2;
         End;
      StringGrid.Selection:=Sel;// Selection Bug - End
      StringGrid.EditorMode:=False;// Edit Bug
      StringGrid.Options:=[goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,goDrawFocusSelected,goEditing,goThumbTracking];
      End;
if((Key=#27)And(goEditing in StringGrid.Options))Then
   Begin
   StringGrid.Options:=[goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,goDrawFocusSelected,goRowSelect,goThumbTracking];
   if (InsertGrid=False)Then
      Begin
      Kom:=MainForm.KomintentList.Items[StringGrid.Row-1];
      StringGrid.Cells[2,StringGrid.Row]:=Kom.Ime;
      End
      Else
      Begin
      Clean:
      StringGrid.Cells[1,StringGrid.Row]:='';
      StringGrid.Cells[2,StringGrid.Row]:='';
      InsertGrid:=False;
      End;
   End;
end;

procedure TKomintentInsForm.StringGridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
if ((goEditing in StringGrid.Options)And((ARow<>StringGrid.Row)Or(ACol<StringGrid.Col)))Then
   CanSelect:=False;
end;

procedure TKomintentInsForm.StringGridKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
if(Key=45)Then // 45 = Insert
   Begin
   PostMessage(StringGrid.Handle,WM_KEYDOWN,35,0); // 35 = End
   PostMessage(StringGrid.Handle,WM_KEYDOWN,13,0); // 13 = Enter
   End;
end;
end.
