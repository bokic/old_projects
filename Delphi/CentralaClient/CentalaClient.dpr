program CentalaClient;

{%ToDo 'CentalaClient.todo'}

uses
  Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  Pregled in 'Pregled.pas' {PregledForm},
  Analizi in 'Analizi.pas' {AnaliziForm},
  Opcii in 'Opcii.pas' {OpciiForm},
  AnaliziPoDenovi in 'AnaliziPoDenovi.pas' {AnaliziPoDenoviForm},
  PregledPrint in 'PregledPrint.pas' {PregledReport: TQuickRep},
  AnaliziPrint in 'AnaliziPrint.pas' {AnaliziReport: TQuickRep},
  Lozinka in 'Lozinka.pas' {LozinkaForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
