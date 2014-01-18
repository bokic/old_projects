unit MainUnit;


interface

uses
  Windows, Messages, SysUtils, Classes, Printers, Graphics, Controls, Forms, Dialogs,
  ToolWin, ComCtrls, Menus, ActnList, ImgList, XPMan;

type
  PKnigoData=^KnigoData;
  KnigoData=Record
  RB:LongInt;
  Nalog:Word;
  Naziv:String[30];
  Konto:String[6];
  Data:TDate;
  Valuta:TDate;
  Dolzi:Currency;
  Pobaruva:Currency;
  Komintent:Word;
  End;

  PKomintentData=^KomintentData;
  KomintentData=Record
  Sifra:Word;   
  Ime:String[40];
  Adr:String[30];
  Mesto:String[10];
  Grad:String[5];
  Tel:String[12];
  Fax:String[12];
  Ziro:String[27];
  End;

  PKPlanData=^KPlanData;
  KPlanData=Record
  Konto:String[6];
  Opis:String[50];
  End;

  PNalogData=^NalogData;
  NalogData=Record
  Opis:String[8];
  Data:TDate;
  End;

  TMainForm = class(TForm)
    StatusBar: TStatusBar;
    ToolBar: TToolBar;
    MainMenu: TMainMenu;
    File1: TMenuItem;
    ActionList: TActionList;
    Insert1: TMenuItem;
    Documents: TMenuItem;
    Help: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    N1: TMenuItem;
    Print1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    About1: TMenuItem;
    Knizenje1: TMenuItem;
    Nalozi1: TMenuItem;
    Komitenti1: TMenuItem;
    Konta1: TMenuItem;
    Nalog: TMenuItem;
    Nalozi: TMenuItem;
    Analitika: TMenuItem;
    BBilans: TMenuItem;
    ZakluchenList: TMenuItem;
    N3: TMenuItem;
    KomitentKonto: TMenuItem;
    KomitentiKonto: TMenuItem;
    Komitent: TMenuItem;
    Import1: TMenuItem;
    N4: TMenuItem;
    New: TAction;
    Open: TAction;
    Save: TAction;
    SaveAs: TAction;
    Print: TAction;
    Import: TAction;
    DocNalog: TAction;
    ToolButton1: TToolButton;
    ImageList: TImageList;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    About: TAction;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    DocNalozi: TAction;
    DocAnalitika: TAction;
    DocBBilans: TAction;
    DocZList: TAction;
    InsKnizenje: TAction;
    InsNalozi: TAction;
    InsKomintenti: TAction;
    InsKonta: TAction;
    DocKomintent: TAction;
    DocKomintenKonto: TAction;
    DocKomintentiKonto: TAction;
    XPManifest: TXPManifest;
    procedure Exit1Click(Sender: TObject);
    procedure NewUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ImportUpdate(Sender: TObject);
    procedure ImportExecute(Sender: TObject);
    procedure DocNalogUpdate(Sender: TObject);
    procedure DocNalogExecute(Sender: TObject);
    procedure AboutUpdate(Sender: TObject);
    procedure OpenUpdate(Sender: TObject);
    procedure AboutExecute(Sender: TObject);
    procedure OpenExecute(Sender: TObject);
    procedure SaveUpdate(Sender: TObject);
    procedure SaveExecute(Sender: TObject);
    procedure NewExecute(Sender: TObject);
    procedure SaveAsUpdate(Sender: TObject);
    procedure SaveAsExecute(Sender: TObject);
    procedure DocNaloziUpdate(Sender: TObject);
    procedure DocNaloziExecute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure DocAnalitikaUpdate(Sender: TObject);
    procedure DocAnalitikaExecute(Sender: TObject);
    procedure DocBBilansUpdate(Sender: TObject);
    procedure DocBBilansExecute(Sender: TObject);
    procedure DocZListUpdate(Sender: TObject);
    procedure DocZListExecute(Sender: TObject);
    procedure DocKomintentUpdate(Sender: TObject);
    procedure DocKomintenKontoUpdate(Sender: TObject);
    procedure DocKomintentiKontoUpdate(Sender: TObject);
    procedure DocKomintentExecute(Sender: TObject);
    procedure DocKomintenKontoExecute(Sender: TObject);
    procedure DocKomintentiKontoExecute(Sender: TObject);
    procedure InsKnizenjeUpdate(Sender: TObject);
    procedure InsKnizenjeExecute(Sender: TObject);
    procedure InsNaloziExecute(Sender: TObject);
    procedure InsNaloziUpdate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure PrintUpdate(Sender: TObject);
    procedure PrintExecute(Sender: TObject);
    procedure InsKomintentiExecute(Sender: TObject);
    procedure InsKomintentiUpdate(Sender: TObject);
    procedure InsKontaExecute(Sender: TObject);
    procedure InsKontaUpdate(Sender: TObject);
  private
    KeybHook:HHOOK;
    Printer:String;
    procedure PrintExecuteOld(Sender: TObject);
  public
    KnigoList,KomintentList,KPLanList,NalogList:TList;
    OdDatum,DoDatum:TDate;
    JustOpen:Boolean;
    FileName:String;
    NeSnimeno:Boolean;
    GrafickoPeatene:Boolean;
  end;

function SortKnigoNalog(Item1, Item2: Pointer): Integer;
function SortKnigoKonto(Item1, Item2: Pointer): Integer;
function SortKnigoKomintent(Item1, Item2: Pointer): Integer;
function SortKomintentiSifra(Item1, Item2: Pointer): Integer;
function SortKomintentiIme(Item1, Item2: Pointer): Integer;
function SortKontaKonto(Item1, Item2: Pointer): Integer;
function SortKontaOpis(Item1, Item2: Pointer): Integer;

var
  MainForm: TMainForm;

implementation
uses Registry, RawPrint, ImportUnit, KnizenjeInsUnit, NaloziInsUnit,NalogViewUnit, NaloziViewUnit, AnalitikaViewUnit,
      BBilansViewUnit, ZListUnit, KomintentUnit, KomintentKontoViewUnit,
      KomintentiKontoViewUnit, AboutUnit, KomintentiInsUnit, KontaInsUnit,
  NalogPrint;
{$R *.DFM}

function SComp(Str1,Str2: String): Integer;
label Kraj;
var L,T,Ret:Integer;
Begin
L:=Length(Str1);
if(L>Length(Str2))Then
   L:=Length(Str2);
Ret:=0;
if(L>0)Then
   For T:=1 to L Do
      Begin
      if(Ord(Str1[T])>Ord(Str2[T]))Then
         Begin
         Ret:=1;
         goto Kraj;
         End;
      if(Ord(Str1[T])<Ord(Str2[T]))Then
         Begin
         Ret:=-1;
         goto Kraj;
         End;
      End;
if(Length(Str1)<>Length(Str2))Then
   if(Length(Str1)>Length(Str2))Then
      Ret:=1
      else
      Ret:=-1;
Kraj:
SComp:=Ret;
End;

function SortKnigoNalog(Item1, Item2: Pointer): Integer;
Begin
if (PKnigoData(Item1)^.Nalog<PKnigoData(Item2)^.Nalog)Then
   SortKnigoNalog:=-1
   else
   if (PKnigoData(Item1)^.Nalog>PKnigoData(Item2)^.Nalog)Then
      SortKnigoNalog:=1
      else
      if (PKnigoData(Item1)^.RB<PKnigoData(Item2)^.RB)Then
         SortKnigoNalog:=-1
         else
         if (PKnigoData(Item1)^.RB>PKnigoData(Item2)^.RB)Then
            SortKnigoNalog:=1
            else
            SortKnigoNalog:=0;
End;

function SortKnigoKonto(Item1, Item2: Pointer): Integer;
Begin
SortKnigoKonto:=SComp(PKnigoData(Item1)^.Konto,PKnigoData(Item2)^.Konto);
End;

function SortKnigoKomintent(Item1, Item2: Pointer): Integer;
Begin
if (PKnigoData(Item1)^.Komintent<PKnigoData(Item2)^.Komintent)Then
   SortKnigoKomintent:=-1
   else
   if (PKnigoData(Item1)^.Komintent>PKnigoData(Item2)^.Komintent)Then
      SortKnigoKomintent:=1
      else
      SortKnigoKomintent:=0;
End;

function SortKomintentiSifra(Item1, Item2: Pointer): Integer;
Begin
if (PKomintentData(Item1)^.Sifra<PKomintentData(Item2)^.Sifra)Then
   SortKomintentiSifra:=-1
   else
   if (PKomintentData(Item1)^.Sifra>PKomintentData(Item2)^.Sifra)Then
      SortKomintentiSifra:=1
      else
      SortKomintentiSifra:=0;
End;

function SortKomintentiIme(Item1, Item2: Pointer): Integer;
Begin
SortKomintentiIme:=SComp(PKomintentData(Item1)^.Ime,PKomintentData(Item2)^.Ime);
End;

function SortKontaKonto(Item1, Item2: Pointer): Integer;
Begin
SortKontaKonto:=SComp(PKPlanData(Item1)^.Konto,PKPlanData(Item2)^.Konto);
End;

function SortKontaOpis(Item1, Item2: Pointer): Integer;
Begin
SortKontaOpis:=SComp(PKPlanData(Item1)^.Opis,PKPlanData(Item2)^.Opis);
End;

function KeyboardProc(code:Integer;	// hook code
    wParam: WPARAM ;	// virtual-key code
    lParam: LPARAM  	// keystroke-message information
   ):LRESULT;
begin
if (MainForm<>Nil) Then
   begin
   {set caps lock}
   if GetKeyState(VK_CAPITAL) <> 0 then
      MainForm.StatusBar.Panels[1].Text:='CAP'
      else
      MainForm.StatusBar.Panels[1].Text:='';
   {set num lock}
   if GetKeyState(VK_NUMLOCK) <> 0 then
      MainForm.StatusBar.Panels[2].Text:='NUM'
      else
      MainForm.StatusBar.Panels[2].Text:='';
   {set scroll lock}
   if GetKeyState(VK_SCROLL) <> 0 then
      MainForm.StatusBar.Panels[3].Text:='SCRL'
      else
      MainForm.StatusBar.Panels[3].Text:='';
   end;

if (Code < 0) then
   KeyboardProc := CallNextHookEx(MainForm.KeybHook,code,wParam,lParam)
   else
   KeyboardProc:=0;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
Close;
end;

procedure TMainForm.NewUpdate(Sender: TObject);
begin
If ((KnigoList.Count=0)And(KomintentList.Count=0)And
    (KPlanList.Count=0)And(NalogList.Count=0))Then
        (Sender as TAction).Enabled := False
        Else
        (Sender as TAction).Enabled := True;
end;

procedure TMainForm.FormCreate(Sender: TObject);
Var Registry:TRegistry;
begin
KeybHook:=SetWindowsHookEx(WH_KEYBOARD,@KeyboardProc,Cardinal(HInstance),0);

OdDatum:=Now();
DoDatum:=Now();

KnigoList:=TList.Create;
KomintentList:=TList.Create;
KPlanList:=TList.Create;
NalogList:=TList.Create;

If (ParamCount>0)Then
   Begin
   JustOpen:=True;
   OpenExecute(Self);
   JustOpen:=False;
   End;

Registry:=TRegistry.Create;
Registry.RootKey:=HKEY_CURRENT_CONFIG;
Registry.OpenKey('\System\CurrentControlSet\Control\Print\Printers\',False);
Printer:=Registry.ReadString('Default');
Registry.Free;

Registry:=TRegistry.Create;
Registry.RootKey:=HKEY_CLASSES_ROOT;
//if (Registry.OpenKey('.knw',False)=False) Then
   Begin
   Registry.RootKey:=HKEY_CLASSES_ROOT;
   If Registry.OpenKey('\.knw',True) Then
      Registry.WriteString('','FinansovoKnigovodstvo.Document');
   If Registry.OpenKey('\FinansovoKnigovodstvo.Document',True) Then
      Registry.WriteString('','Finansovo Knigovodstvo by BokiCSoft');
   If Registry.OpenKey('\FinansovoKnigovodstvo.Document\DefaultIcon',True) Then
      Registry.WriteString('',ParamStr(0)+',0');
   If Registry.OpenKey('\FinansovoKnigovodstvo.Document\shell\open\command',True) Then
      Registry.WriteString('','"'+ParamStr(0)+'" "%1"');
   End;
Registry.Free;

StatusBar.Panels.Items[4].Bevel:=pbNone;

GrafickoPeatene:=True;

LoadKeyboardLayout('0000042F',KLF_ACTIVATE);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
if (KeybHook <> 0) then
   UnhookWindowsHookEx(KeybHook);

NewExecute(Sender);

KnigoList.Free;
KomintentList.Free;
KPlanList.Free;
NalogList.Free;
end;

procedure TMainForm.ImportUpdate(Sender: TObject);
begin
If ((KnigoList.Count=0)And(KomintentList.Count=0)And
    (KPlanList.Count=0)And(NalogList.Count=0))Then
        (Sender as TAction).Enabled := True
        Else
        (Sender as TAction).Enabled := False;
end;

procedure TMainForm.ImportExecute(Sender: TObject);
Var
   ImportForm:TImportForm;
   ImportFile:File;
   Count,T:Longint;
   TExt:Extended;
   TWord,Day,Month,Year:Word;
   Err:Integer;
   TKData:^KnigoData;
   TKPlan:^KPlanData;
   TNalog:^NalogData;
   TKomintent:^KomintentData;
   ImportStr,DirSt,TSt:String;
   Found:Boolean;
begin
Application.ProcessMessages;

ImportForm:=TImportForm.Create(Self);
if (ImportForm.ShowModal = idOK) then
   begin
   DirSt:=ImportForm.DirectoryListBox.Directory;
   If (DirSt[Length(DirSt)]<>'\') Then
      DirSt:=DirSt+'\';
   Application.ProcessMessages;
   Cursor:=crHourGlass;
   System.Assign(ImportFile,DirSt+'knigo.dbf');
   FileMode:=fmOpenRead;
   System.Reset(ImportFile,1);
   System.Seek(ImportFile,4);
   System.BlockRead(ImportFile,Count,4);
   MainForm.StatusBar.Panels[0].Text:='Èìïîğòèğàì..';
   Application.ProcessMessages;
   For T:=1 To Count Do
      Begin
      System.Seek(ImportFile,$122+((T-1)*74));
      SetLength(ImportStr,73);
      System.BlockRead(ImportFile,ImportStr[1],73);
      System.GetMem(TKData,SizeOf(KnigoData));

      TSt:=Copy(ImportStr,1,5);
      Val(TSt,TWord,Err);
      TKData^.Nalog:=TWord;

      TSt:=Copy(ImportStr,6,14);
      If (TSt[14]=' ') Then
         Repeat
         SetLength(TSt,Length(TSt)-1);
         Until(TSt='')Or(TSt[Length(TSt)]<>' ');
      TKData^.Naziv:=TSt;

      TSt:=Copy(ImportStr,20,6);
      If (TSt[6]=' ') Then
         Repeat
         SetLength(TSt,Length(TSt)-1);
         Until(TSt='')Or(TSt[Length(TSt)]<>' ');
      TKData^.Konto:=TSt;

      Val(Copy(ImportStr,26,4),TWord,err);
      If (TWord>=1900) Then
        Begin
        Year:=TWord;
        Val(Copy(ImportStr,30,2),Month,err);
        Val(Copy(ImportStr,32,2),Day,err);
        TKData^.Data:=EncodeDate(Year,Month,Day);
        End
        Else
        TKData^.Data:=0;
      If (TKData^.Data<OdDatum) Then
         OdDatum:=TKData^.Data;
      If (TKData^.Data>DoDatum) Then
         DoDatum:=TKData^.Data;
      Val(Copy(ImportStr,34,4),TWord,err);
      If (TWord>=1900) Then
        Begin
        Year:=TWord;
        Val(Copy(ImportStr,38,2),Month,err);
        Val(Copy(ImportStr,40,2),Day,err);
        TKData^.Valuta:=EncodeDate(Year,Month,Day);
        End
        Else
        TKData^.Valuta:=0;
      Val(Copy(ImportStr,42,13),TExt,err);
      TKData^.Dolzi:=TExt;
      Val(Copy(ImportStr,55,13),TExt,err);
      TKData^.Pobaruva:=TExt;
      TSt:=Copy(ImportStr,68,1)+Copy(ImportStr,70,4);//TSt:=Copy(ImportStr,69,5);
      If (TSt='     ')Then
         TKData^.Komintent:=0
         Else
         Val(TSt,TKData^.Komintent,Err);
      If ((TKData^.Konto<>'0')Or(TKData^.Dolzi<>0)Or(TKData^.Dolzi<>0))Then
         KnigoList.Add(TKData);
      End;
   System.Close(ImportFile);
   System.Assign(ImportFile,DirSt+'kplan.dbf');
   FileMode:=fmOpenRead;
   System.Reset(ImportFile,1);
   System.Seek(ImportFile,4);
   System.BlockRead(ImportFile,Count,4);
   For T:=1 To Count Do
      Begin
      System.Seek(ImportFile,$62+((T-1)*57));
      SetLength(ImportStr,56);
      System.BlockRead(ImportFile,ImportStr[1],56);
      System.GetMem(TKPlan,SizeOf(KPlanData));
      TSt:=Copy(ImportStr,1,6);
      If (TSt[Length(TSt)]=' ') Then
         Repeat
         SetLength(TSt,Length(TSt)-1);
         Until(TSt='')Or(TSt[Length(TSt)]<>' ');
      TKPlan^.Konto:=TSt;
      TSt:=Copy(ImportStr,7,57);
      If (TSt[Length(TSt)]=' ') Then
         Repeat
         SetLength(TSt,Length(TSt)-1);
         Until(TSt='')Or(TSt[Length(TSt)]<>' ');
      TKPlan^.Opis:=TSt;
      KPlanList.Add(TKPlan);
      End;
   System.Close(ImportFile);
   System.Assign(ImportFile,DirSt+'nalog.dbf');
   FileMode:=fmOpenRead;
   System.Reset(ImportFile,1);
   System.Seek(ImportFile,4);
   System.BlockRead(ImportFile,Count,4);
   For T:=1 To Count Do
      Begin
      System.Seek(ImportFile,$62+((T-1)*17));
      SetLength(ImportStr,16);
      System.BlockRead(ImportFile,ImportStr[1],16);
      System.GetMem(TNalog,SizeOf(NalogData));
      NalogList.Add(TNalog);
      TSt:=Copy(ImportStr,1,8);
      If (TSt[Length(TSt)]=' ') Then
         Repeat
         SetLength(TSt,Length(TSt)-1);
         Until(TSt='')Or(TSt[Length(TSt)]<>' ');

      If ((Length(TSt)>0)And(TSt[1]=' ')) Then
         Repeat
         TSt:=Copy(TSt,2,Length(TSt)-1);
         Until(TSt='')Or(TSt[1]<>' ');

      TNalog^.Opis:=TSt;
      Val(Copy(ImportStr,9,4),TWord,err);
      If (TWord>1900) Then
        Begin
        Year:=TWord;
        Val(Copy(ImportStr,13,2),Month,err);
        Val(Copy(ImportStr,15,2),Day,err);
        TNalog^.Data:=EncodeDate(Year,Month,Day);
        End
        Else
        TNalog^.Data:=0;
      End;
   System.Close(ImportFile);
   System.Assign(ImportFile,DirSt+'firmi.dbf');
   FileMode:=fmOpenRead;
   System.Reset(ImportFile,1);
   System.Seek(ImportFile,4);
   System.BlockRead(ImportFile,Count,4);
   For T:=1 To Count Do
      Begin
      System.Seek(ImportFile,$122+((T-1)*143));
      SetLength(ImportStr,142);
      System.BlockRead(ImportFile,ImportStr[1],142);
      System.GetMem(TKomintent,SizeOf(KomintentData));
      KomintentList.Add(TKomintent);
      TSt:=Copy(ImportStr,1,1)+Copy(ImportStr,3,4);
      Val(Copy(ImportStr,1,1)+Copy(ImportStr,3,4),TWord,err);
      TKomintent.Sifra:=TWord;
      TSt:=Copy(ImportStr,7,40);
      If (TSt[Length(TSt)]=' ') Then
         Repeat
         SetLength(TSt,Length(TSt)-1);
         Until(TSt='')Or(TSt[Length(TSt)]<>' ');
      TKomintent^.Ime:=TSt;
      TSt:=Copy(ImportStr,47,30);
      If (TSt[Length(TSt)]=' ') Then
         Repeat
         SetLength(TSt,Length(TSt)-1);
         Until(TSt='')Or(TSt[Length(TSt)]<>' ');
      TKomintent^.Adr:=TSt;
      TSt:=Copy(ImportStr,77,10);
      If (TSt[Length(TSt)]=' ') Then
         Repeat
         SetLength(TSt,Length(TSt)-1);
         Until(TSt='')Or(TSt[Length(TSt)]<>' ');
      TKomintent^.Mesto:=TSt;
      TSt:=Copy(ImportStr,87,5);
      If (TSt[Length(TSt)]=' ') Then
         Repeat
         SetLength(TSt,Length(TSt)-1);
         Until(TSt='')Or(TSt[Length(TSt)]<>' ');
      TKomintent^.Grad:=TSt;
      TSt:=Copy(ImportStr,92,12);
      If (TSt[Length(TSt)]=' ') Then
         Repeat
         SetLength(TSt,Length(TSt)-1);
         Until(TSt='')Or(TSt[Length(TSt)]<>' ');
      TKomintent^.Tel:=TSt;
      TSt:=Copy(ImportStr,104,12);
      If (TSt[Length(TSt)]=' ') Then
         Repeat
         SetLength(TSt,Length(TSt)-1);
         Until(TSt='')Or(TSt[Length(TSt)]<>' ');
      TKomintent^.Fax:=TSt;
      TSt:=Copy(ImportStr,116,27);
      If (TSt[Length(TSt)]=' ') Then
         Repeat
         SetLength(TSt,Length(TSt)-1);
         Until(TSt='')Or(TSt[Length(TSt)]<>' ');
      TKomintent^.Ziro:=TSt;
      End;
   System.Close(ImportFile);
   NeSnimeno:=True;
   End;
ImportForm.Release;

MainForm.StatusBar.Panels[0].Text:='Ãè ïğîâåğóâàì ïîäàòîöèòå..';
Application.ProcessMessages;

if (KnigoList.Count > 0) then
   for Count:=0 to KnigoList.Count-1 do
      begin
      TKData:=KnigoList.Items[Count];
      If (TKData.Nalog>NalogList.Count)Then
         Application.MessageBox('Èìà ïîäàòîöè çà íåïîñòîå÷êè íàëîã..','Ïğåäóïğåäóâàœå..');
      Found:=False;
      If (KPlanList.Count>0) Then
         For T:= 0 To KPlanList.Count-1 Do
            Begin
            TKPlan:=KPlanList.Items[T];
            If (TKdata.Konto=TKPlan.Konto) Then
               Begin
               Found:=True;
               break;
               End;
            End;
      If (Found=False) Then
         Application.MessageBox('Èìà ïîäàòîöè çà íåïîñòîå÷êî êîíòî..','Ïğåäóïğåäóâàœå..');
      Found:=False;
      If (TKData.Komintent=0)Then
         Found:=True;
      If ((TKData.Komintent>0)And(KomintentList.Count>0)) Then
         For T:= 0 To KomintentList.Count-1 Do
            Begin
            TKomintent:=KomintentList.Items[T];
            If (TKomintent.Sifra=TKData.Komintent) Then
               Begin
               Found:=True;
               break;
               End;
            End;
      If (Found=False) Then
         Application.MessageBox('Èìà ïîäàòîöè çà íåïîñòîå÷êè êîìèíòåíò..','Ïğåäóïğåäóâàœå..');
      End;
MainForm.StatusBar.Panels[0].Text:='Ñïğåìíî';
MainForm.Repaint;
Cursor:=crDefault;
end;

procedure TMainForm.DocNalogUpdate(Sender: TObject);
begin
If (KnigoList.Count=0)Then
   (Sender as TAction).Enabled := False
   Else
   (Sender as TAction).Enabled := True;
end;

procedure TMainForm.DocNalogExecute(Sender: TObject);
begin
MainForm.Update;
If (NalogDocForm=nil) Then
   NalogDocForm:=TNalogDocForm.Create(Self)
   Else
   NalogDocForm.Show;
end;

procedure TMainForm.AboutUpdate(Sender: TObject);
begin
(Sender as TAction).Enabled := True;
end;

procedure TMainForm.OpenUpdate(Sender: TObject);
begin
(Sender as TAction).Enabled := True;
end;
procedure TMainForm.AboutExecute(Sender: TObject);
Var About:TAboutForm;
begin
MainForm.Update;
About:=TAboutForm.Create(Self);
About.ShowModal;
About.Release;
end;

procedure TMainForm.OpenExecute(Sender: TObject);
Type
  TIndex=Array[0..0]of LongInt;
  PIndex=^TIndex;
Var
   Kni:PKnigoData;
   Kom:PKomintentData;
   Nal:PNalogData;
   KPl:PKPlanData;
   CKni,CKom,CNal,CKPl:LongInt;
   OpenFile:File;
   TSt,CurrentDir:String;
   Count,T:LongInt;
   P:Pointer;
   P_Index:PIndex;
   Resu:Word;
begin
MainForm.Update;
T:=0;
If(NeSnimeno)Then
   Begin
   Resu:=MessageDlg('Äàòîòåêàòà íå å ñî÷óâàíà, äàëè äà ¼à ñî÷óâàì?',mtWarning, [mbYes, mbNo,mbCancel], 0);
   If (Resu=mrYes)Then
      SaveExecute(Sender);
   If ((NeSnimeno)And(Resu=2)) Then
      Exit;
   End;
CurrentDir:=GetCurrentDir;
LoadKeyboardLayout('00000409',KLF_ACTIVATE);
If ((JustOpen=False)And(OpenDialog.Execute=False)) Then
   Begin
   LoadKeyboardLayout('0000042F',KLF_ACTIVATE);
   Exit;
   End
   Else
   LoadKeyboardLayout('0000042F',KLF_ACTIVATE);
MainForm.Update;
OdDatum:=Now();
DoDatum:=Now();
Cursor:=crHourGlass;
SetCurrentDir(CurrentDir);
NewExecute(self);
IF (JustOpen) Then
   Begin
   TSt:='';
   For Count:=1 To ParamCount Do
      If (Count=1) Then
         TSt:=TSt+ParamStr(Count)
         Else
         TSt:=TSt+' '+ParamStr(Count);
   OpenDialog.FileName:=TSt;
   End;
System.Assign(OpenFile,OpenDialog.FileName);
FileMode:=fmOpenRead;
Reset(OpenFile,1);
SetLength(TSt,14);
BlockRead(OpenFile,TSt[1],14);
If (TSt<>'BB file header')Then
   Begin
   MessageDlg('Äàòîòåêàòà íå å îä îâî¼ ïğîãğàì.',mtError	, [mbOk], 0);
   System.CloseFile(OpenFile);
   Cursor:=crDefault;
   Exit;
   End;
BlockRead(OpenFile,CKni,4);
BlockRead(OpenFile,CKom,4);
BlockRead(OpenFile,CKPl,4);
BlockRead(OpenFile,CNal,4);
getmem(P_Index,CNal*4);
fillchar(P_Index^,CNal*4,0);
If (CKni>0)Then
   For Count:=1 To CKni Do
      Begin
      GetMem(Kni,SizeOf(KnigoData));
      KnigoList.Add(Kni);
      BlockRead(OpenFile,Kni^.Nalog,2);
      if (Kni^.Nalog>CNal)Then
         Begin
         freemem(P_Index,CNal*4);
         NewExecute(self);
         MessageDlg('Èìà ïîäàòîöè çà íåïîñòîå÷êè íàëîã.',mtError, [mbOk],0);
         System.CloseFile(OpenFile);
         Cursor:=crDefault;
         exit;
         End;
      {$R-}
      Kni^.RB:=P_Index^[Kni^.Nalog-1];
      Inc(P_Index^[Kni^.Nalog-1]);
      {$R+}
      BlockRead(OpenFile,T,1);
      If(T>0)Then
         Begin
         SetLength(Kni^.Naziv,T);
         BlockRead(OpenFile,Kni^.Naziv[1],T);
         End
         Else
         Kni^.Naziv:='';
      BlockRead(OpenFile,T,1);
      If(T>0)Then
         Begin
         SetLength(Kni^.Konto,T);
         BlockRead(OpenFile,Kni^.Konto[1],T);
         End
         Else
         Kni^.Konto:='';
      BlockRead(OpenFile,Kni^.Data,SizeOf(Kni^.Data));
      If (Kni^.Data<OdDatum) Then
         OdDatum:=Kni^.Data;
      If (Kni^.Data>DoDatum) Then
         DoDatum:=Kni^.Data;
      BlockRead(OpenFile,Kni^.Valuta,SizeOf(Kni^.Valuta));
      P:=@Kni^.Dolzi;
      BlockRead(OpenFile,P^,8);
      P:=@Kni^.Pobaruva;
      BlockRead(OpenFile,P^,8);
      Blockread(OpenFile,Kni^.Komintent,2);
      End;
freemem(P_Index,CNal*4);
If (CKom>0)Then
   For Count:=1 To CKom Do
      Begin
      GetMem(Kom,SizeOf(KomintentData));
      KomintentList.Add(Kom);
      BlockRead(OpenFile,Kom^.Sifra,2);
      BlockRead(OpenFile,T,1);
      If(T>0)Then
         Begin
         SetLength(Kom^.Ime,T);
         BlockRead(OpenFile,Kom^.Ime[1],T)
         End
         else
         Kom^.Ime:='';
      BlockRead(OpenFile,T,1);
      If(T>0)Then
         Begin
         SetLength(Kom^.Adr,T);
         BlockRead(OpenFile,Kom^.Adr[1],T)
         End
         else
         Kom^.Adr:='';
      BlockRead(OpenFile,T,1);
      If(T>0)Then
         Begin
         SetLength(Kom^.Mesto,T);
         BlockRead(OpenFile,Kom^.Mesto[1],T)
         End
         else
         Kom^.Mesto:='';
      BlockRead(OpenFile,T,1);
      If(T>0)Then
         Begin
         SetLength(Kom^.Grad,T);
         BlockRead(OpenFile,Kom^.Grad[1],T)
         End
         else
         Kom^.Grad:='';
      BlockRead(OpenFile,T,1);
      If(T>0)Then
         Begin
         SetLength(Kom^.Tel,T);
         BlockRead(OpenFile,Kom^.Tel[1],T)
         End
         else
         Kom^.Tel:='';
      BlockRead(OpenFile,T,1);
      If(T>0)Then
         Begin
         SetLength(Kom^.Fax,T);
         BlockRead(OpenFile,Kom^.Fax[1],T)
         End
         else
         Kom^.Fax:='';
      BlockRead(OpenFile,T,1);
      If(T>0)Then
         Begin
         SetLength(Kom^.Ziro,T);
         BlockRead(OpenFile,Kom^.Ziro[1],T)
         End
         else
         Kom^.Ziro:='';
        End;
If (CKPl>0)Then
   For Count:=1 To CKPl Do
      Begin
      GetMem(KPl,SizeOf(KPlanData));
      KPlanList.Add(KPl);
      BlockRead(OpenFile,T,1);
      If(T>0)Then
         Begin
         SetLength(KPl^.Konto,T);
         BlockRead(OpenFile,KPl^.Konto[1],T)
         End
         else
         KPl^.Konto:='';
      BlockRead(OpenFile,T,1);
      If(T>0)Then
         Begin
         SetLength(KPl^.Opis,T);
         BlockRead(OpenFile,KPl^.Opis[1],T)
         End
         else
         KPl^.Opis:='';
      End;
If (CNal>0)Then
   For Count:=1 To CNal Do
      Begin
      GetMem(Nal,SizeOf(NalogData));
      NalogList.Add(Nal);
      BlockRead(OpenFile,T,1);
      If(T>0)Then
         Begin
         SetLength(Nal^.Opis,T);
         BlockRead(OpenFile,Nal^.Opis[1],T)
         End
         else
         Nal^.Opis:='';
      BlockRead(OpenFile,Nal^.Data,SizeOf(Nal^.Data));
      End;
If (Not EOF(OpenFile))Then
   Begin
   MessageDlg('Äàòîòåêàòà íå å ïğî÷èòàíà äî êğà¼.',mtWarning, [mbOk],0);
   End;
System.Close(OpenFile);
FileName:=OpenDialog.FileName;
MainForm.Caption:='Ôèíàíñîâî Êíèãîâîäñòâî â1.3 - '+FileName;
NeSnimeno:=False;
KnigoList.Sort(SortKnigoNalog);
KomintentList.Sort(SortKomintentiSifra);
KPlanList.Sort(SortKontaKonto);
Cursor:=crDefault;
end;

procedure TMainForm.SaveUpdate(Sender: TObject);
begin
If (NeSnimeno)Then
   (Sender as TAction).Enabled := True
   Else
   (Sender as TAction).Enabled := False;
end;

procedure TMainForm.SaveExecute(Sender: TObject);
Var
   Kni:PKnigoData;
   Kom:PKomintentData;
   Nal:PNalogData;
   KPl:PKPlanData;
   SaveFile:File;
   TSt:String;
   Count,T:LongInt;
   P:Pointer;
begin
MainForm.Update;
Cursor:=crHourGlass;
If (FileName='')Then
   Begin
   SaveDialog.FileName:='default.knw';
   LoadKeyboardLayout('00000409',KLF_ACTIVATE);
   If (SaveDialog.Execute=False) Then
      Begin
      LoadKeyboardLayout('0000042F',KLF_ACTIVATE);
      Exit;
      End
      Else
      LoadKeyboardLayout('0000042F',KLF_ACTIVATE);
   FileName:=SaveDialog.FileName;
   End;
System.Assign(SaveFile,FileName);
ReWrite(SaveFile,1);
TSt:='BB file header';
try
BlockWrite(SaveFile,TSt[1],14);
Count:=KnigoList.Count;
BlockWrite(SaveFile,Count,4);
Count:=KomintentList.Count;
BlockWrite(SaveFile,Count,4);
Count:=KPlanList.Count;
BlockWrite(SaveFile,Count,4);
Count:=NalogList.Count;
BlockWrite(SaveFile,Count,4);
If (KnigoList.Count>0)Then
   For Count:=1 To KnigoList.Count Do
      Begin
      Kni:=KnigoList.Items[Count-1];
      BlockWrite(SaveFile,Kni^.Nalog,2);
      T:=Length(Kni^.Naziv);
      BlockWrite(SaveFile,T,1);
      If(T>0)Then
         BlockWrite(SaveFile,Kni^.Naziv[1],T);
      T:=Length(Kni^.Konto);
      BlockWrite(SaveFile,T,1);
      If(T>0)Then
         BlockWrite(SaveFile,Kni^.Konto[1],T);
      BlockWrite(SaveFile,Kni^.Data,SizeOf(Kni^.Data));
      BlockWrite(SaveFile,Kni^.Valuta,SizeOf(Kni^.Valuta));
      P:=@Kni^.Dolzi;
      BlockWrite(SaveFile,P^,8);
      P:=@Kni^.Pobaruva;
      BlockWrite(SaveFile,P^,8);
      BlockWrite(SaveFile,Kni^.Komintent,2);
        End;
If (KomintentList.Count>0)Then
   For Count:=1 To KomintentList.Count Do
      Begin
      Kom:=KomintentList.Items[Count-1];
      BlockWrite(SaveFile,Kom^.Sifra,2);
      T:=Length(Kom^.Ime);
      BlockWrite(SaveFile,T,1);
      If(T>0)Then
         BlockWrite(SaveFile,Kom^.Ime[1],T);
      T:=Length(Kom^.aDR);
      BlockWrite(SaveFile,T,1);
      If(T>0)Then
         BlockWrite(SaveFile,Kom^.Adr[1],T);
      T:=Length(Kom^.Mesto);
      BlockWrite(SaveFile,T,1);
      If(T>0)Then
         BlockWrite(SaveFile,Kom^.Mesto[1],T);
      T:=Length(Kom^.Grad);
      BlockWrite(SaveFile,T,1);
      If(T>0)Then
         BlockWrite(SaveFile,Kom^.Grad[1],T);
      T:=Length(Kom^.Tel);
      BlockWrite(SaveFile,T,1);
      If(T>0)Then
         BlockWrite(SaveFile,Kom^.Tel[1],T);
      T:=Length(Kom^.Fax);
      BlockWrite(SaveFile,T,1);
      If(T>0)Then
         BlockWrite(SaveFile,Kom^.Fax[1],T);
      T:=Length(Kom^.Ziro);
      BlockWrite(SaveFile,T,1);
      If(T>0)Then
         BlockWrite(SaveFile,Kom^.Ziro[1],T);
      End;
If (KPlanList.Count>0)Then
   For Count:=1 To KPlanList.Count Do
      Begin
      KPl:=KPlanList.Items[Count-1];
      T:=Length(KPl^.Konto);
      BlockWrite(SaveFile,T,1);
      If(T>0)Then
         BlockWrite(SaveFile,KPl^.Konto[1],T);
      T:=Length(KPl^.Opis);
      BlockWrite(SaveFile,T,1);
      If(T>0)Then
         BlockWrite(SaveFile,KPl^.Opis[1],T);
      End;
If (NalogList.Count>0)Then
   For Count:=1 To NalogList.Count Do
      Begin
      Nal:=NalogList.Items[Count-1];
      T:=Length(Nal^.Opis);
      BlockWrite(SaveFile,T,1);
      If(T>0)Then
         BlockWrite(SaveFile,Nal^.Opis[1],T);
      BlockWrite(SaveFile,Nal^.Data,SizeOf(Nal^.Data));
      End;
MainForm.Caption:='Ôèíàíñîâî Êíèãîâîäñòâî â1.3 - '+FileName;
NeSnimeno:=False;
finally
   System.Close(SaveFile);
   Cursor:=crDefault;
   end;
end;

procedure TMainForm.NewExecute(Sender: TObject);
Var
   T:LongInt;
   Resu:Word;
begin
MainForm.Update;
If(NeSnimeno)Then
   Begin
   Resu:=MessageDlg('Äàòîòåêàòà íå å ñî÷óâàíà, äàëè äà ¼à ñî÷óâàì?',mtWarning, [mbYes, mbNo,mbCancel], 0);
   If (Resu=mrYes)Then
      SaveExecute(Sender);
   //If ((NeSnimeno)And(Resu=2)) Then
      //Exit;
   End;
if (KnizenjeInsForm<>nil)Then
   Begin
   KnizenjeInsForm.Free;
   KnizenjeInsForm:=nil;
   End;
if (NaloziInsForm<>nil)Then
   Begin
   NaloziInsForm.Free;
   NaloziInsForm:=nil;
   End;
if (KomintentInsForm<>nil)Then
   Begin
   KomintentInsForm.Free;
   KomintentInsForm:=nil;
   End;
if (KontaInsForm<>nil)Then
   Begin
   KontaInsForm.Free;
   KontaInsForm:=nil;
   End;
if (NalogDocForm<>nil)Then
   Begin
   NalogDocForm.Free;
   NalogDocForm:=nil;
   End;
if (NaloziDocForm<>nil)Then
   Begin
   NaloziDocForm.Free;
   NaloziDocForm:=nil;
   End;
if (AnalitikaDocForm<>nil)Then
   Begin
   AnalitikaDocForm.Free;
   AnalitikaDocForm:=nil;
   End;
if (BBilansDocForm<>nil)Then
   Begin
   BBilansDocForm.Free;
   BBilansDocForm:=nil;
   End;
if (ZListDocForm<>nil)Then
   Begin
   ZListDocForm.Free;
   ZListDocForm:=nil;
   End;
if (KomintentDocForm<>nil)Then
   Begin
   KomintentDocForm.Free;
   KomintentDocForm:=nil;
   End;
if (KomintentKontoDocForm<>nil)Then
   Begin
   KomintentKontoDocForm.Free;
   KomintentKontoDocForm:=nil;
   End;
if (KomintentiKontoDocForm<>nil)Then
   Begin
   KomintentiKontoDocForm.Free;
   KomintentiKontoDocForm:=nil;
   End;
If (KnigoList.Count>0)Then
   For T:=KnigoList.Count DownTo 1 Do
      System.FreeMem(KnigoList.Items[T-1],SizeOf(KnigoData));
KnigoList.Clear;

If (KomintentList.Count>0)Then
   For T:=KomintentList.Count DownTo 1 Do
      System.FreeMem(KomintentList.Items[T-1],SizeOf(KomintentData));
KomintentList.Clear;

If (KPlanList.Count>0)Then
   For T:=KPlanList.Count DownTo 1 Do
      System.FreeMem(KPlanList.Items[T-1],SizeOf(KPlanData));
KPlanList.Clear;

If (NalogList.Count>0)Then
   For T:=NalogList.Count DownTo 1 Do
      System.FreeMem(NalogList.Items[T-1],SizeOf(NalogData));
NalogList.Clear;

NeSnimeno:=False;
Caption:='Ôèíàíñîâî Êíèãîâîäñòâî â1.3 - default.knw';
FileName:='';

end;

procedure TMainForm.SaveAsUpdate(Sender: TObject);
begin
If ((KnigoList.Count=0)And(KomintentList.Count=0)And
    (KPlanList.Count=0)And(NalogList.Count=0))Then
        (Sender as TAction).Enabled := False
        Else
        (Sender as TAction).Enabled := True;
end;

procedure TMainForm.SaveAsExecute(Sender: TObject);
begin
MainForm.Update;
SaveDialog.FileName:=FileName;
LoadKeyboardLayout('00000409',KLF_ACTIVATE);
If (SaveDialog.Execute=False) Then
   Begin
   LoadKeyboardLayout('0000042F',KLF_ACTIVATE);
   Exit;
   End
   Else
   LoadKeyboardLayout('0000042F',KLF_ACTIVATE);
FileName:=SaveDialog.FileName;
SaveExecute(Sender);
MainForm.Caption:='Ôèíàíñîâî Êíèãîâîäñòâî â1.3 - '+FileName;
MainForm.Update;
end;

procedure TMainForm.DocNaloziUpdate(Sender: TObject);
begin
If (KnigoList.Count=0)Then
   (Sender as TAction).Enabled := False
   Else
   (Sender as TAction).Enabled := True;
end;

procedure TMainForm.DocNaloziExecute(Sender: TObject);
begin
MainForm.Update;
If (NaloziDocForm=nil) Then
   NaloziDocForm:=TNaloziDocForm.Create(Self)
   Else
   NaloziDocForm.Show;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
StatusBar.Panels[0].Width:=MainForm.Width-124;
end;

procedure TMainForm.DocAnalitikaUpdate(Sender: TObject);
begin
If ((KnigoList.Count=0)Or(KPlanList.Count=0))Then
   (Sender as TAction).Enabled := False
   Else
   (Sender as TAction).Enabled := True;
end;

procedure TMainForm.DocAnalitikaExecute(Sender: TObject);
begin
MainForm.Update;
If (AnalitikaDocForm=nil) Then
   AnalitikaDocForm:=TAnalitikaDocForm.Create(Self)
   Else
   AnalitikaDocForm.Show;
end;

procedure TMainForm.DocBBilansUpdate(Sender: TObject);
begin
If ((KnigoList.Count=0)Or(KPlanList.Count=0))Then
   (Sender as TAction).Enabled := False
   Else
   (Sender as TAction).Enabled := True;
end;

procedure TMainForm.DocBBilansExecute(Sender: TObject);
begin
MainForm.Update;
If (BBilansDocForm=nil) Then
   BBilansDocForm:=TBBilansDocForm.Create(Self)
   Else
   BBilansDocForm.Show;
end;

procedure TMainForm.DocZListUpdate(Sender: TObject);
begin
If ((KnigoList.Count=0)Or(KPlanList.Count=0))Then
   (Sender as TAction).Enabled := False
   Else
   (Sender as TAction).Enabled := True;
end;

procedure TMainForm.DocZListExecute(Sender: TObject);
begin
MainForm.Update;
If (ZListDocForm=nil) Then
   ZListDocForm:=TZListDocForm.Create(Self)
   Else
   ZListDocForm.Show;
end;

procedure TMainForm.DocKomintentUpdate(Sender: TObject);
begin
If ((KnigoList.Count=0)Or(KPlanList.Count=0))Then
   (Sender as TAction).Enabled := False
   Else
   (Sender as TAction).Enabled := True;
end;

procedure TMainForm.DocKomintenKontoUpdate(Sender: TObject);
begin
If ((KnigoList.Count=0)Or(KPlanList.Count=0))Then
   (Sender as TAction).Enabled := False
   Else
   (Sender as TAction).Enabled := True;
end;

procedure TMainForm.DocKomintentiKontoUpdate(Sender: TObject);
begin
If ((KnigoList.Count=0)Or(KPlanList.Count=0))Then
   (Sender as TAction).Enabled := False
   Else
   (Sender as TAction).Enabled := True;
end;

procedure TMainForm.DocKomintentExecute(Sender: TObject);
begin
MainForm.Update;
If (KomintentDocForm=nil) Then
   KomintentDocForm:=TKomintentDocForm.Create(Self)
   Else
   KomintentDocForm.Show;
end;

procedure TMainForm.DocKomintenKontoExecute(Sender: TObject);
begin
MainForm.Update;
If (KomintentKontoDocForm=nil) Then
   KomintentKontoDocForm:=TKomintentKontoDocForm.Create(Self)
   Else
   KomintentKontoDocForm.Show;
end;

procedure TMainForm.DocKomintentiKontoExecute(Sender: TObject);
begin
MainForm.Update;
If (KomintentiKontoDocForm=nil) Then
   KomintentiKontoDocForm:=TKomintentiKontoDocForm.Create(Self)
   Else
   KomintentiKontoDocForm.Show;
end;

procedure TMainForm.InsKnizenjeUpdate(Sender: TObject);
begin
(Sender as TAction).Enabled := True;
end;

procedure TMainForm.InsKnizenjeExecute(Sender: TObject);
begin
MainForm.Update;
If (KnizenjeInsForm=nil) Then
   KnizenjeInsForm:=TKnizenjeInsForm.Create(Self)
   Else
   KnizenjeInsForm.SetFocus;
end;

procedure TMainForm.InsNaloziExecute(Sender: TObject);
begin
MainForm.Update;
If (NaloziInsForm=nil) Then
   NaloziInsForm:=TNaloziInsForm.Create(Self)
   Else
   NaloziInsForm.SetFocus;
end;

procedure TMainForm.InsNaloziUpdate(Sender: TObject);
begin
(Sender as TAction).Enabled := True;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
Var Result:Word;
begin
Result:=0;
if (NeSnimeno)Then
   Begin
   Result:=Application.MessageBox('Äàòîòåêàòà íå å ñî÷óâàíà, äàëè äà ¼à ñî÷óâàì?','Ïğàøàœå!!',MB_OKCANCEL);
   If (Result=IDOK) Then
      SaveExecute(Sender);
   End;
if ((NeSnimeno)And(Result=IDOK))Then
   CanClose:=False
   Else
   CanClose:=True;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
 if GetKeyState(VK_CAPITAL) <> 0 then
  MainForm.StatusBar.Panels[1].Text:='CAP'
 else
  MainForm.StatusBar.Panels[1].Text:='';
 {set num lock}
 if GetKeyState(VK_NUMLOCK) <> 0 then
  MainForm.StatusBar.Panels[2].Text:='NUM'
 else
  MainForm.StatusBar.Panels[2].Text:='';
 {set scroll lock}
 if GetKeyState(VK_SCROLL) <> 0 then
  MainForm.StatusBar.Panels[3].Text:='SCRL'
 else
  MainForm.StatusBar.Panels[3].Text:='';
end;

procedure TMainForm.PrintUpdate(Sender: TObject);
var Print:TPrinter;
begin
if (Screen.ActiveForm<>Nil) then
   if ((Screen.ActiveForm.ClassName='TNalogDocForm')or
      (Screen.ActiveForm.ClassName='TNaloziDocForm')or
      (Screen.ActiveForm.ClassName='TAnalitikaDocForm')or
      (Screen.ActiveForm.ClassName='TBBilansDocForm')or
      (Screen.ActiveForm.ClassName='TZListDocForm')or
      (Screen.ActiveForm.ClassName='TKomintentDocForm')or
      (Screen.ActiveForm.ClassName='TKomintentKontoDocForm')or
      (Screen.ActiveForm.ClassName='TKomintentiKontoDocForm')) then
      begin
      Print:=TPrinter.Create();
      if (Print.Printers.Count=0) then
         (Sender as TAction).Enabled := False
         else
         (Sender as TAction).Enabled := True;
      Print.Free;
      end
      else
      (Sender as TAction).Enabled := False
   else
   (Sender as TAction).Enabled := False;
end;

procedure TMainForm.PrintExecuteOld(Sender: TObject);
Function FormString(St:String;Len:Byte;Left:Boolean):String;
Var Count:Byte;
   TSt:String;
Begin
If (Length(St)<Len) Then
   Begin
   If (Left)Then
      Begin
      TSt:=St;
      For Count:=1 To Len-Length(St) Do
         TSt:=TSt+' ';
      End
      Else
      Begin
      TSt:='';
      For Count:=1 To Len-Length(St) Do
         TSt:=TSt+' ';
      TSt:=TSt+St;
      End;
   FormString:=TSt;
   End
   Else
   If (Left)Then
      FormString:=Copy(St,1,Len)
      Else
      FormString:=Copy(St,Length(St)-Len+1,Len);
End;
var
   TSt:String;
   Pr:TPrinter;
   RawPrint:TRawPrint;
   Count:LongInt;
   KontoDolzi,KontoPobaruva:String;
   PrintDialog:TPrintDialog;
begin
PrintDialog:=TPrintDialog.Create(self);
If (PrintDialog.Execute=False)Then
   Exit;

Pr:=Printers.Printer;
Printer:=Pr.Printers.Strings[Pr.PrinterIndex];
if (Pos(' on ',Printer) > 0) then
   Printer:=Copy(Printer,1,Pos(' on ',Printer)-1);

if (Screen.ActiveForm.ClassName='TNalogDocForm') Then
   if (TNalogDocForm(Screen.ActiveForm).StringGrid.Cells[0,1]<>'') then
      begin
      RawPrint:=TRawPrint.Create(PChar(Printer),'Finansovo Knigovodstvo - Nalog');
      RawPrint.WriteStr('Nalog za knizenje broj: '+
      NalogDocForm.ComboBox.Text+', '+
      NalogDocForm.Date.Caption,True);
      RawPrint.WriteStr('Pecateno na den '+DateTimeToStr(Now()),True);
      RawPrint.WriteStr('',True);
      RawPrint.WriteStr('                                                          ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·',True);
      RawPrint.WriteStr('                                                          º    KONTO    º             IZNOS             º',True);
      RawPrint.WriteStr('ÖÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÒÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶',True);
      RawPrint.WriteStr('º RB º         OPIS                 º  DATUM   º  VALUTA  º DOLZIºPOBARUº     DOLZI     º   POBARUVA    º',True);
      RawPrint.WriteStr('ÇÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄ×ÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄ·',True);
      For Count:=0 To (NalogDocForm.StringGrid.RowCount)-2 Do
        Begin
         TSt:='';
         If (NalogDocForm.StringGrid.Cells[5,Count+1]='0.00') Then
            KontoDolzi:='      '
            Else
            KontoDolzi:=FormString(NalogDocForm.StringGrid.Cells[2,Count+1],6,True);
         If (NalogDocForm.StringGrid.Cells[6,Count+1]='0.00') Then
            KontoPobaruva:='      '
            Else
            KontoPobaruva:=FormString(NalogDocForm.StringGrid.Cells[2,Count+1],6,True);
         RawPrint.WriteStr('º'+
         FormString(NalogDocForm.StringGrid.Cells[0,Count+1],4,False)+'º'+
         FormString(NalogDocForm.StringGrid.Cells[1,Count+1],30,True)+'º'+
         FormString(NalogDocForm.StringGrid.Cells[3,Count+1],10,True)+'º'+
         FormString(NalogDocForm.StringGrid.Cells[4,Count+1],10,True)+'º'+
         KontoDolzi+'º'+KontoPobaruva+'º'+
         FormString(NalogDocForm.StringGrid.Cells[5,Count+1],15,False)+'º'+
         FormString(NalogDocForm.StringGrid.Cells[6,Count+1],15,False)+'º'+
         FormString(NalogDocForm.StringGrid.Cells[7,Count+1],5,False)+'º',True);
         End;
      RawPrint.WriteStr('ÓÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄĞÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄ½',True);
      RawPrint.WriteStr('                                                                        º'+
      FormString(NalogDocForm.DolziSuma.Caption,15,False)+'º'+
      FormString(NalogDocForm.PobaruvaSuma.Caption,15,False)+'º',True);
      RawPrint.WriteStr('                                                                        ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½',True);
      RawPrint.Write(12);
      RawPrint.Destroy;
      Exit;
      End;
If ((Screen.ActiveForm.ClassName='TNaloziDocForm')And
   (TNaloziDocForm(Screen.ActiveForm).StringGrid.Cells[0,1]<>'')) Then
   Begin
   RawPrint:=TRawPrint.Create(PChar(Printer),'Finansovo Knigovodstvo - Nalozi');
   RawPrint.WriteStr('Dokument po nalozi',True);
   RawPrint.WriteStr('Pecateno na den '+DateTimeToStr(Now()),True);
   RawPrint.WriteStr('ÖÄÄÄÄÒÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·',True);
   RawPrint.WriteStr('º RB ºNAL OPISºNALOGDATUMº     DOLZI     º   POBARUVA    º      SALDO     º',True);
   RawPrint.WriteStr('ÇÄÄÄÄ×ÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶',True);
   For Count:=0 To (TNaloziDocForm(Screen.ActiveForm).StringGrid.RowCount)-2 Do
      Begin
      TSt:='';
      RawPrint.WriteStr('º'+
      FormString(TNaloziDocForm(Screen.ActiveForm).StringGrid.Cells[0,Count+1],4,False)+'º'+
      FormString(TNaloziDocForm(Screen.ActiveForm).StringGrid.Cells[1,Count+1],8,True)+'º'+
      FormString(TNaloziDocForm(Screen.ActiveForm).StringGrid.Cells[2,Count+1],10,True)+'º'+
      FormString(TNaloziDocForm(Screen.ActiveForm).StringGrid.Cells[3,Count+1],15,False)+'º'+
      FormString(TNaloziDocForm(Screen.ActiveForm).StringGrid.Cells[4,Count+1],15,False)+'º'+
      FormString(TNaloziDocForm(Screen.ActiveForm).StringGrid.Cells[5,Count+1],16,False)+'º'
      ,True);
      End;
   RawPrint.WriteStr('ÓÄÄÄÄĞÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶',True);
   RawPrint.WriteStr('                         º'+
   FormString(TNaloziDocForm(Screen.ActiveForm).DolziSuma.Caption,15,False)+'º'+
   FormString(TNaloziDocForm(Screen.ActiveForm).PobaruvaSuma.Caption,15,False)+'º'+
   FormString(TNaloziDocForm(Screen.ActiveForm).SaldoSuma.Caption,16,False)+'¶',True);
   RawPrint.WriteStr('                         ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½',True);
   RawPrint.Write(12);
   RawPrint.Destroy;
   End;
If ((Screen.ActiveForm.ClassName='TAnalitikaDocForm') And
   (TAnalitikaDocForm(Screen.ActiveForm).StringGrid.Cells[0,1]<>'')) Then
   Begin
   RawPrint:=TRawPrint.Create(PChar(Printer),'Finansovo Knigovodstvo - Analitika');
   RawPrint.WriteStr('Analiticka kartica za konto '+
   TAnalitikaDocForm(Screen.ActiveForm).Konto.Text,True);
   RawPrint.WriteStr('Od datum '+
   DateToStr(TAnalitikaDocForm(Screen.ActiveForm).OdDatum.DateTime)+', do datum '+
   DateToStr(TAnalitikaDocForm(Screen.ActiveForm).DoDatum.DateTime),True);
   RawPrint.WriteStr('Pecateno na den '+DateTimeToStr(Now()),True);
   RawPrint.WriteStr('ÖÄÄÄÄÒÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·',True);
   RawPrint.WriteStr('º RB ºNAL OPISºNALOGDATUMº         OPIS                 º  DATUM   º     DOLZI     º   POBARUVA    º',True);
   RawPrint.WriteStr('ÇÄÄÄÄ×ÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶',True);
   For Count:=0 To (TAnalitikaDocForm(Screen.ActiveForm).StringGrid.RowCount)-2 Do
      Begin
      TSt:='';
      RawPrint.WriteStr('º'+
      FormString(TAnalitikaDocForm(Screen.ActiveForm).StringGrid.Cells[0,Count+1],4,False)+'º'+
      FormString(TAnalitikaDocForm(Screen.ActiveForm).StringGrid.Cells[1,Count+1],8,True)+'º'+
      FormString(TAnalitikaDocForm(Screen.ActiveForm).StringGrid.Cells[2,Count+1],10,True)+'º'+
      FormString(TAnalitikaDocForm(Screen.ActiveForm).StringGrid.Cells[3,Count+1],30,True)+'º'+
      FormString(TAnalitikaDocForm(Screen.ActiveForm).StringGrid.Cells[4,Count+1],10,True)+'º'+
      FormString(TAnalitikaDocForm(Screen.ActiveForm).StringGrid.Cells[5,Count+1],15,False)+'º'+
      FormString(TAnalitikaDocForm(Screen.ActiveForm).StringGrid.Cells[6,Count+1],15,False)+'º'
      ,True);
      End;
   RawPrint.WriteStr('ÓÄÄÄÄĞÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶',True);
   RawPrint.WriteStr('                                                                   º'+
   FormString(TAnalitikaDocForm(Screen.ActiveForm).DolziSuma.Caption,15,False)+'º'+
   FormString(TAnalitikaDocForm(Screen.ActiveForm).PobaruvaSuma.Caption,15,False)+'º',True);
   RawPrint.WriteStr('                                                                   ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½',True);
   RawPrint.Write(12);
   RawPrint.Destroy;
   End;
If ((Screen.ActiveForm.ClassName='TBBilansDocForm') And
   (TBBilansDocForm(Screen.ActiveForm).StringGrid.Cells[0,1]<>'')) Then
   Begin
   RawPrint:=TRawPrint.Create(PChar(Printer),'Finansovo Knigovodstvo - BrutoBilans');
   If (TBBilansDocForm(Screen.ActiveForm).Klasa.ItemIndex=10) Then
        RawPrint.WriteStr('BrutoBilans',True)
        Else
        RawPrint.WriteStr('BrutoBilans za klasa '+TBBilansDocForm(Screen.ActiveForm).Klasa.Text,True);
   RawPrint.WriteStr('Od datum '+
   DateToStr(TBBilansDocForm(Screen.ActiveForm).OdDatum.DateTime)+', do datum '+
   DateToStr(TBBilansDocForm(Screen.ActiveForm).DoDatum.DateTime),True);
   RawPrint.WriteStr('Pecateno na den '+DateTimeToStr(Now()),True);
   RawPrint.WriteStr('ÖÄÄÄÄÒÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·',True);
   RawPrint.WriteStr('º RB ºKONTO º         OPIS                 º   POC.DOLZI   º POC.POBARUVA  º     DOLZI     º   POBARUVA    º      SALDO     º',True);
   RawPrint.WriteStr('ÇÄÄÄÄ×ÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶',True);
   For Count:=0 To (TBBilansDocForm(Screen.ActiveForm).StringGrid.RowCount)-2 Do
      Begin
      TSt:='';
      RawPrint.WriteStr('º'+
      FormString(TBBilansDocForm(Screen.ActiveForm).StringGrid.Cells[0,Count+1],4,False)+'º'+
      FormString(TBBilansDocForm(Screen.ActiveForm).StringGrid.Cells[1,Count+1],6,True)+'º'+
      FormString(TBBilansDocForm(Screen.ActiveForm).StringGrid.Cells[2,Count+1],30,True)+'º'+
      FormString(TBBilansDocForm(Screen.ActiveForm).StringGrid.Cells[3,Count+1],15,False)+'º'+
      FormString(TBBilansDocForm(Screen.ActiveForm).StringGrid.Cells[4,Count+1],15,False)+'º'+
      FormString(TBBilansDocForm(Screen.ActiveForm).StringGrid.Cells[5,Count+1],15,False)+'º'+
      FormString(TBBilansDocForm(Screen.ActiveForm).StringGrid.Cells[6,Count+1],15,False)+'º'+
      FormString(TBBilansDocForm(Screen.ActiveForm).StringGrid.Cells[7,Count+1],16,False)+'º'
      ,True);
      End;
   RawPrint.WriteStr('ÓÄÄÄÄĞÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶',True);
   RawPrint.WriteStr('                                           º'+
   FormString(TBBilansDocForm(Screen.ActiveForm).PocDolziSuma.Caption,15,False)+'º'+
   FormString(TBBilansDocForm(Screen.ActiveForm).PocPobaruvaSuma.Caption,15,False)+'º'+
   FormString(TBBilansDocForm(Screen.ActiveForm).DolziSuma.Caption,15,False)+'º'+
   FormString(TBBilansDocForm(Screen.ActiveForm).PobaruvaSuma.Caption,15,False)+'º'+
   FormString(TBBilansDocForm(Screen.ActiveForm).Saldo.Caption,16,False)+'º'
   ,True);
   RawPrint.WriteStr('                                           ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½',True);
   RawPrint.Write(12);
   RawPrint.Destroy;
   End;
If ((Screen.ActiveForm.ClassName='TZListDocForm') And
   (TZListDocForm(Screen.ActiveForm).StringGrid.Cells[0,1]<>'')) Then
   Begin
   RawPrint:=TRawPrint.Create(PChar(Printer),'Finansovo Knigovodstvo - Zalkucen List');
   RawPrint.WriteStr('Zalkucen List',True);
   RawPrint.WriteStr('Od datum '+
   DateToStr(TZListDocForm(Screen.ActiveForm).OdDatum.DateTime)+', do datum '+
   DateToStr(TZListDocForm(Screen.ActiveForm).DoDatum.DateTime),True);
   RawPrint.WriteStr('Pecateno na den '+DateTimeToStr(Now()),True);
   RawPrint.WriteStr('ÖÄÄÄÄÒÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·',True);
   RawPrint.WriteStr('º RB ºKONTO º         OPIS                 º   POC.DOLZI   º POC.POBARUVA  º     DOLZI     º   POBARUVA    º      SALDO     º',True);
   RawPrint.WriteStr('ÇÄÄÄÄ×ÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶',True);
   For Count:=0 To (TZListDocForm(Screen.ActiveForm).StringGrid.RowCount)-2 Do
      Begin
      TSt:='';
      RawPrint.WriteStr('º'+
      FormString(TZListDocForm(Screen.ActiveForm).StringGrid.Cells[0,Count+1],4,False)+'º'+
      FormString(TZListDocForm(Screen.ActiveForm).StringGrid.Cells[1,Count+1],6,True)+'º'+
      FormString(TZListDocForm(Screen.ActiveForm).StringGrid.Cells[2,Count+1],30,True)+'º'+
      FormString(TZListDocForm(Screen.ActiveForm).StringGrid.Cells[3,Count+1],15,False)+'º'+
      FormString(TZListDocForm(Screen.ActiveForm).StringGrid.Cells[4,Count+1],15,False)+'º'+
      FormString(TZListDocForm(Screen.ActiveForm).StringGrid.Cells[5,Count+1],15,False)+'º'+
      FormString(TZListDocForm(Screen.ActiveForm).StringGrid.Cells[6,Count+1],15,False)+'º'+
      FormString(TZListDocForm(Screen.ActiveForm).StringGrid.Cells[7,Count+1],16,False)+'º'
      ,True);
      End;
   RawPrint.WriteStr('ÓÄÄÄÄĞÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶',True);
   RawPrint.WriteStr('                                           º'+
   FormString(TZListDocForm(Screen.ActiveForm).PocDolziSuma.Caption,15,False)+'º'+
   FormString(TZListDocForm(Screen.ActiveForm).PocPobaruvaSuma.Caption,15,False)+'º'+
   FormString(TZListDocForm(Screen.ActiveForm).DolziSuma.Caption,15,False)+'º'+
   FormString(TZListDocForm(Screen.ActiveForm).PobaruvaSuma.Caption,15,False)+'º'+
   FormString(TZListDocForm(Screen.ActiveForm).Saldo.Caption,16,False)+'º'
   ,True);
   RawPrint.WriteStr('                                           ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½',True);
   RawPrint.Write(12);
   RawPrint.Destroy;
   End;
If ((Screen.ActiveForm.ClassName='TKomintentDocForm') And
   (TKomintentDocForm(Screen.ActiveForm).StringGrid.Cells[0,1]<>'')) Then
   Begin
   RawPrint:=TRawPrint.Create(PChar(Printer),'Finansovo Knigovodstvo - Komintent');
   RawPrint.WriteStr('Specifikacija za komintent '+
   (TKomintentDocForm(Screen.ActiveForm).Komintent.Text),True);
   RawPrint.WriteStr('Od datum '+
   DateToStr(TKomintentDocForm(Screen.ActiveForm).OdDatum.DateTime)+', do datum '+
   DateToStr(TKomintentDocForm(Screen.ActiveForm).DoDatum.DateTime),True);
   RawPrint.WriteStr('Pecateno na den '+DateTimeToStr(Now()),True);
   RawPrint.WriteStr('ÖÄÄÄÄÒÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·',True);
   RawPrint.WriteStr('º RB ºKONTO º         OPIS                 º     DOLZI     º   POBARUVA    º      SALDO     º',True);
   RawPrint.WriteStr('ÇÄÄÄÄ×ÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶',True);
   For Count:=0 To (TKomintentDocForm(Screen.ActiveForm).StringGrid.RowCount)-2 Do
      Begin
      TSt:='';
      RawPrint.WriteStr('º'+
      FormString(TKomintentDocForm(Screen.ActiveForm).StringGrid.Cells[0,Count+1],4,False)+'º'+
      FormString(TKomintentDocForm(Screen.ActiveForm).StringGrid.Cells[1,Count+1],6,True)+'º'+
      FormString(TKomintentDocForm(Screen.ActiveForm).StringGrid.Cells[2,Count+1],30,True)+'º'+
      FormString(TKomintentDocForm(Screen.ActiveForm).StringGrid.Cells[3,Count+1],15,False)+'º'+
      FormString(TKomintentDocForm(Screen.ActiveForm).StringGrid.Cells[4,Count+1],15,False)+'º'+
      FormString(TKomintentDocForm(Screen.ActiveForm).StringGrid.Cells[5,Count+1],16,False)+'º'
      ,True);
      End;
   RawPrint.WriteStr('ÓÄÄÄÄĞÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶',True);
   RawPrint.WriteStr('                                           º'+
   FormString(TKomintentDocForm(Screen.ActiveForm).DolziSuma.Caption,15,False)+'º'+
   FormString(TKomintentDocForm(Screen.ActiveForm).PobaruvaSuma.Caption,15,False)+'º'+
   FormString(TKomintentDocForm(Screen.ActiveForm).Saldo.Caption,16,False)+'º'
   ,True);
   RawPrint.WriteStr('                                           ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½',True);
   RawPrint.Write(12);
   RawPrint.Destroy;
   End;
If ((Screen.ActiveForm.ClassName='TKomintentKontoDocForm') And
   (TKomintentKontoDocForm(Screen.ActiveForm).StringGrid.Cells[0,1]<>'')) Then
   Begin
   RawPrint:=TRawPrint.Create(PChar(Printer),'Finansovo Knigovodstvo - KomintentKonto');
   RawPrint.WriteStr('Komintent kartica za konto '+TKomintentKontoDocForm(Screen.ActiveForm).Konto.Text,True);
   RawPrint.WriteStr('Komintent '+TKomintentKontoDocForm(Screen.ActiveForm).Komintent.Text,True);
   RawPrint.WriteStr('Od datum '+
   DateToStr(TKomintentKontoDocForm(Screen.ActiveForm).OdDatum.DateTime)+', do datum '+
   DateToStr(TKomintentKontoDocForm(Screen.ActiveForm).DoDatum.DateTime),True);
   RawPrint.WriteStr('Pecateno na den '+DateTimeToStr(Now()),True);
   RawPrint.WriteStr('ÖÄÄÄÄÒÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·',True);
   RawPrint.WriteStr('º RB ºNAL OPISºNALOGDATUMº         OPIS                 º  DATUM   º     DOLZI     º   POBARUVA    º     SALDO      º',True);
   RawPrint.WriteStr('ÇÄÄÄÄ×ÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶',True);
   For Count:=0 To (TKomintentKontoDocForm(Screen.ActiveForm).StringGrid.RowCount)-2 Do
      Begin
      TSt:='';
      RawPrint.WriteStr('º'+
      FormString(TKomintentKontoDocForm(Screen.ActiveForm).StringGrid.Cells[0,Count+1],4,False)+'º'+
      FormString(TKomintentKontoDocForm(Screen.ActiveForm).StringGrid.Cells[1,Count+1],8,True)+'º'+
      FormString(TKomintentKontoDocForm(Screen.ActiveForm).StringGrid.Cells[2,Count+1],10,True)+'º'+
      FormString(TKomintentKontoDocForm(Screen.ActiveForm).StringGrid.Cells[3,Count+1],30,True)+'º'+
      FormString(TKomintentKontoDocForm(Screen.ActiveForm).StringGrid.Cells[4,Count+1],10,True)+'º'+
      FormString(TKomintentKontoDocForm(Screen.ActiveForm).StringGrid.Cells[5,Count+1],15,False)+'º'+
      FormString(TKomintentKontoDocForm(Screen.ActiveForm).StringGrid.Cells[6,Count+1],15,False)+'º'+
      FormString(TKomintentKontoDocForm(Screen.ActiveForm).StringGrid.Cells[7,Count+1],16,False)+'º'
      ,True);
      End;
   RawPrint.WriteStr('ÓÄÄÄÄĞÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶',True);
   RawPrint.WriteStr('                                                                   º'+
   FormString(TKomintentKontoDocForm(Screen.ActiveForm).DolziSuma.Caption,15,False)+'º'+
   FormString(TKomintentKontoDocForm(Screen.ActiveForm).PobaruvaSuma.Caption,15,False)+'º'+
   FormString(TKomintentKontoDocForm(Screen.ActiveForm).Saldo.Caption,16,False)+'º'
   ,True);
   RawPrint.WriteStr('                                                                   ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½',True);
   RawPrint.Write(12);
   RawPrint.Destroy;
   End;
If ((Screen.ActiveForm.ClassName='TKomintentiKontoDocForm') And
   (TKomintentiKontoDocForm(Screen.ActiveForm).StringGrid.Cells[0,1]<>'')) Then
   Begin
   RawPrint:=TRawPrint.Create(PChar(Printer),'Finansovo Knigovodstvo - KomintentiKonto');
   RawPrint.WriteStr('Specifikacija po Komintenti za Konto '+
   (TKomintentiKontoDocForm(Screen.ActiveForm).Konto.Text),True);
   RawPrint.WriteStr('Od datum '+
   DateToStr(TKomintentiKontoDocForm(Screen.ActiveForm).OdDatum.DateTime)+', do datum '+
   DateToStr(TKomintentiKontoDocForm(Screen.ActiveForm).DoDatum.DateTime),True);
   RawPrint.WriteStr('Pecateno na den '+DateTimeToStr(Now()),True);
   RawPrint.WriteStr('ÖÄÄÄÄÒÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·',True);
   RawPrint.WriteStr('º RB ºSIFRA º        KOMINTENT             º     DOLZI     º   POBARUVA    º      SALDO     º',True);
   RawPrint.WriteStr('ÇÄÄÄÄ×ÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶',True);
   For Count:=0 To (TKomintentiKontoDocForm(Screen.ActiveForm).StringGrid.RowCount)-2 Do
      Begin
      TSt:='';
      RawPrint.WriteStr('º'+
      FormString(TKomintentiKontoDocForm(Screen.ActiveForm).StringGrid.Cells[0,Count+1],4,False)+'º'+
      FormString(TKomintentiKontoDocForm(Screen.ActiveForm).StringGrid.Cells[1,Count+1],6,False)+'º'+
      FormString(TKomintentiKontoDocForm(Screen.ActiveForm).StringGrid.Cells[2,Count+1],30,True)+'º'+
      FormString(TKomintentiKontoDocForm(Screen.ActiveForm).StringGrid.Cells[3,Count+1],15,False)+'º'+
      FormString(TKomintentiKontoDocForm(Screen.ActiveForm).StringGrid.Cells[4,Count+1],15,False)+'º'+
      FormString(TKomintentiKontoDocForm(Screen.ActiveForm).StringGrid.Cells[5,Count+1],16,False)+'º'
      ,True);
      End;
   RawPrint.WriteStr('ÓÄÄÄÄĞÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶',True);
   RawPrint.WriteStr('                                           º'+
   FormString(TKomintentiKontoDocForm(Screen.ActiveForm).DolziSuma.Caption,15,False)+'º'+
   FormString(TKomintentiKontoDocForm(Screen.ActiveForm).PobaruvaSuma.Caption,15,False)+'º'+
   FormString(TKomintentiKontoDocForm(Screen.ActiveForm).Saldo.Caption,16,False)+'º'
   ,True);
   RawPrint.WriteStr('                                           ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½',True);
   RawPrint.Write(12);
   RawPrint.Destroy;
   End;
end;

procedure TMainForm.PrintExecute(Sender: TObject);
begin
if (GrafickoPeatene<>True)Then
   Begin
   PrintExecuteOld(Sender);
   exit;
   End;
If (Screen.ActiveForm.ClassName='TNalogDocForm')Then
   If (TNalogDocForm(Screen.ActiveForm).StringGrid.Cells[0,1]<>'') Then
      Begin
      NalogReport:=TNalogReport.Create(self);
      NalogReport.Preview;
      NalogReport.Free;
      End;
If (Screen.ActiveForm.ClassName='TNaloziDocForm')Then
   If (TNaloziDocForm(Screen.ActiveForm).StringGrid.Cells[0,1]<>'') Then
      Begin
      End;
If (Screen.ActiveForm.ClassName='TAnalitikaDocForm')Then
   If (TAnalitikaDocForm(Screen.ActiveForm).StringGrid.Cells[0,1]<>'') Then
      Begin
      End;
If ((Screen.ActiveForm.ClassName='TBBilansDocForm') And
   (TBBilansDocForm(Screen.ActiveForm).StringGrid.Cells[0,1]<>'')) Then
   Begin
   End;
If ((Screen.ActiveForm.ClassName='TZListDocForm') And
   (TZListDocForm(Screen.ActiveForm).StringGrid.Cells[0,1]<>'')) Then
   Begin
   End;
If ((Screen.ActiveForm.ClassName='TKomintentDocForm') And
   (TKomintentDocForm(Screen.ActiveForm).StringGrid.Cells[0,1]<>'')) Then
   Begin
   End;
If ((Screen.ActiveForm.ClassName='TKomintentKontoDocForm') And
   (TKomintentKontoDocForm(Screen.ActiveForm).StringGrid.Cells[0,1]<>'')) Then
   Begin
   End;
If ((Screen.ActiveForm.ClassName='TKomintentiKontoDocForm') And
   (TKomintentiKontoDocForm(Screen.ActiveForm).StringGrid.Cells[0,1]<>'')) Then
   Begin
   End;
end;

procedure TMainForm.InsKomintentiExecute(Sender: TObject);
begin
MainForm.Update;
If (KomintentInsForm=nil) Then
   KomintentInsForm:=TKomintentInsForm.Create(Self)
   Else
   KomintentInsForm.SetFocus;
end;

procedure TMainForm.InsKomintentiUpdate(Sender: TObject);
begin
(Sender as TAction).Enabled := True;
end;

procedure TMainForm.InsKontaExecute(Sender: TObject);
begin
MainForm.Update;
If (KontaInsForm=nil) Then
   KontaInsForm:=TKontaInsForm.Create(Self)
   Else
   KontaInsForm.SetFocus;
end;

procedure TMainForm.InsKontaUpdate(Sender: TObject);
begin
(Sender as TAction).Enabled := True;
end;
end.
