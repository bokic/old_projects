unit ImportUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl;

type
  TImportForm = class(TForm)
    DirectoryListBox: TDirectoryListBox;
    DriveComboBox: TDriveComboBox;
    Import: TButton;
    procedure DriveComboBoxChange(Sender: TObject);
    procedure ImportClick(Sender: TObject);
    procedure DirectoryListBoxChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ImportForm: TImportForm;

implementation

{$R *.DFM}

procedure TImportForm.DriveComboBoxChange(Sender: TObject);
begin
DirectoryListBox.Drive:=DriveComboBox.Drive;
end;

procedure TImportForm.ImportClick(Sender: TObject);
begin
ModalResult:=idOK;
end;

procedure TImportForm.DirectoryListBoxChange(Sender: TObject);
Var TSt:String;
begin
TSt:=DirectoryListBox.Directory;
If (TSt[Length(TSt)]<>'\') Then
   TSt:=TST+'\';
If((FileExists(TSt+'knigo.dbf'))
   And(FileExists(TSt+'nalog.dbf'))
   And(FileExists(TSt+'kplan.dbf'))
   And(FileExists(TSt+'firmi.dbf'))
   )Then
      Import.Enabled:=True
      Else
      Import.Enabled:=False;
end;

procedure TImportForm.FormShow(Sender: TObject);
begin
DirectoryListBoxChange(Sender);
end;

end.
