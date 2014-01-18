program FKnigo;

uses 
  Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  ImportUnit in 'ImportUnit.pas' {ImportForm},
  NalogViewUnit in 'NalogViewUnit.pas' {NalogDocForm},
  AboutUnit in 'AboutUnit.pas' {AboutForm},
  NaloziViewUnit in 'NaloziViewUnit.pas' {NaloziDocForm},
  AnalitikaViewUnit in 'AnalitikaViewUnit.pas' {AnalitikaDocForm},
  BBilansViewUnit in 'BBilansViewUnit.pas' {BBilansDocForm},
  ZListUnit in 'ZListUnit.pas' {ZListDocForm},
  KomintentUnit in 'KomintentUnit.pas' {KomintentDocForm},
  KomintentKontoViewUnit in 'KomintentKontoViewUnit.pas' {KomintentKontoDocForm},
  KomintentiKontoViewUnit in 'KomintentiKontoViewUnit.pas' {KomintentiKontoDocForm},
  KnizenjeInsUnit in 'KnizenjeInsUnit.pas' {KnizenjeInsForm},
  NaloziInsUnit in 'NaloziInsUnit.pas' {NaloziInsForm},
  NovNalogUnit in 'NovNalogUnit.pas' {VnesiNalog},
  QuickKomintentUnit in 'QuickKomintentUnit.pas' {QuickKomintentForm},
  QuickKontoUnit in 'QuickKontoUnit.pas' {QuickKontoForm},
  RawPrint in 'RawPrint.pas',
  KontaInsUnit in 'KontaInsUnit.pas' {KontaInsForm},
  KomintentiInsUnit in 'KomintentiInsUnit.pas' {KomintentInsForm},
  NalogPrint in 'NalogPrint.pas' {NalogReport: TQuickRep},
  NovoKontoUnit in 'NovoKontoUnit.pas' {VnesiKonto};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
