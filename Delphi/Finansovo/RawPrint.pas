unit RawPrint;

interface
Uses WinSpool;
Type
   TRawPrint = class(TObject)
   public
   constructor Create(Printer,Caption:PChar);
   destructor Destroy; override;
   procedure Write(Data:Byte);
   procedure WriteStr(Str:String;LF:Boolean);
   private
   Handle:Cardinal;
   Open:Boolean;
   End;

implementation

uses Windows,Registry;

constructor TRawPrint.Create(Printer,Caption:PChar);
Const DataType:PChar='RAW';
Var DocInfo:_DOC_INFO_1;
begin
Open:=True;
If (OpenPrinter(Printer,Handle,Nil)) Then
   Begin
   DocInfo.pDocName:=Caption;
   DocInfo.pOutputFile:=nil;
   DocInfo.pDatatype:=DataType;
   If (StartDocPrinter(Handle,1,@DocInfo)<>0) Then
      Begin
      If (StartPagePrinter(Handle)=False) Then
         Begin
         EndDocPrinter(Handle);
         ClosePrinter(Handle);
         Open:=False;
         End;
      End
      Else
      Begin
      ClosePrinter(Handle);
      Open:=False;
      End
   End
   Else
   Open:=False;
end;

procedure TRawPrint.Write(Data:Byte);
Var Writen:Cardinal;
begin
If (Open) Then
   Begin
   WritePrinter(Handle,@Data,1,Writen);
   End;
end;

procedure TRawPrint.WriteStr(Str:String;LF:Boolean);
Const LineFeed:Array[1..2] Of Char=(#13,#10);
Var Writen:Cardinal;
begin
If (Open) Then
   Begin
   WritePrinter(Handle,@Str[1],Length(Str),Writen);
   If (LF) Then
      Begin
      WritePrinter(Handle,@LineFeed,2,Writen);
      End;
   End;
end;

destructor TRawPrint.Destroy;
begin
If (Open) Then
   Begin
   EndPagePrinter(Handle);
   EndDocPrinter(Handle);
   ClosePrinter(Handle);
   End;
end;
end.
