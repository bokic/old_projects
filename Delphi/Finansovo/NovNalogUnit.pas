unit NovNalogUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TVnesiNalog = class(TForm)
    NalogOpis: TEdit;
    LabelNalog: TLabel;
    Label2: TLabel;
    Datum: TEdit;
    Vnesi: TButton;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure NalogOpisKeyPress(Sender: TObject; var Key: Char);
    procedure DatumKeyPress(Sender: TObject; var Key: Char);
    procedure VnesiClick(Sender: TObject);
    procedure NalogOpisExit(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    OldNal:String;
  public
    { Public declarations }
  end;

var
  VnesiNalog: TVnesiNalog;

implementation

{$R *.DFM}

Uses MainUnit;

procedure TVnesiNalog.FormKeyPress(Sender: TObject; var Key: Char);
begin
if (Key=#27) Then
   Begin
   Application.HandleMessage;
   ModalResult:=mrCancel;
   End;
end;

procedure TVnesiNalog.NalogOpisKeyPress(Sender: TObject; var Key: Char);
begin
If ((Key=#13)And(NalogOpis.Text<>'')) Then
   Datum.SetFocus;
end;

procedure TVnesiNalog.DatumKeyPress(Sender: TObject; var Key: Char);
begin
If (Key=#13) Then
   Begin
      try
      {$I-}
      StrToDate(Datum.Text);
      {$I+}
      except
      on E: EConvertError do
         Begin
         Application.MessageBox('Внесете валиден датум','Грешка');
         Exit;
         End;
      End;
   Vnesi.SetFocus;
   End;
end;

procedure TVnesiNalog.VnesiClick(Sender: TObject);
Var Count,C2:LongInt;
   Nal:PNalogData;
   TSt,DodTSt:String;
   TInt:LongInt;
   Err:Integer;
   Found:Boolean;
begin
If (NalogOpis.Text='') Then
   Begin
   Application.MessageBox('Внесете име на налогот','Грешка',IDOK);
   NalogOpis.SetFocus;
   Exit;
   End;
NalogOpis.Text:=AnsiUpperCase(NalogOpis.Text);
If (MainForm.NalogList.Count>0)And(OldNal<>NalogOpis.Text) Then
   Begin
   For Count:=0 To MainForm.NalogList.Count-1 Do
      Begin
      Nal:=MainForm.NalogList.Items[Count];
      If (Nal.Opis=NalogOpis.Text) Then
         Begin
         Application.MessageBox('Таков налог веќе постои!!','Грешка',IDOK);
         TSt:='';
         For C2:=1 To Length(NalogOpis.Text) Do // Go navoga sledoto slobodno ime
            Begin
            If ((NalogOpis.Text[C2]>='0')And(NalogOpis.Text[C2]<='9'))Then
               Begin
               TSt:=TSt+NalogOpis.Text[C2];
               End
               Else
               Break;
            End;
         If (TSt<>'') Then
            Begin
            Val(TSt,TInt,Err);
            If (Err<>0) Then
               Begin
               Application.MessageBox('Сопствена(НовНалог 101) грешка, известете го програмерот!!','Грешка',IDOK);
               Exit;
               End;
            DodTSt:=Copy(NalogOpis.Text,Length(TSt)+1,Length(NalogOpis.Text)-Length(TSt));
            Repeat
            Inc(TInt);
            Found:=False;
            Str(TInt,TSt);
            TSt:=TSt+DodTSt;
            For C2:=0 To MainForm.NalogList.Count-1 Do
               Begin
               Nal:=MainForm.NalogList.Items[C2];
               If (Nal.Opis=TSt) Then
                  Begin
                  Found:=True;
                  Break;
                  End;
               End;
            Until(Found=False);
            NalogOpis.Text:=TSt;
            End;
         NalogOpis.SetFocus;
         Exit;
         End;
      End;
   End;
ModalResult:=mrOk;
end;

procedure TVnesiNalog.NalogOpisExit(Sender: TObject);
begin
NalogOpis.Text:=AnsiUpperCase(NalogOpis.Text);
NalogOpis.Refresh;
end;

procedure TVnesiNalog.FormShow(Sender: TObject);
begin
OldNal:=NalogOpis.Text;
end;
end.
