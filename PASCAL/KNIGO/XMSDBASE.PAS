Unit Xmsdbase;
interface
Uses DBase,Xms;
Type
    PXmsDBase = ^TXmsDBase;
    TXmsDBase = Object(TDBase)
    private
    XmsHandle : Word;
    XmsRecLen : Word;
    public
    Constructor Init(FName: String);
    Procedure AppendCurrent;virtual;
    Procedure AppendBlankAt(Rec:LongInt);virtual;{Ova}
    Procedure AppendCurrentAt(Rec:LongInt);virtual;{Ova}
    Procedure Save;virtual;
    Procedure Pack;virtual;
    Procedure Zap;virtual;
    Procedure GetDbRec(_RecNo: LongInt);virtual;
    Destructor Done;virtual;
    End;

Implementation
Constructor TXMSdbase.Init(FName: String);
Var T:LongInt;
Begin
inherited init(FName);
if(Error=0)Then
	Begin
	XmsRecLen:=RecordLen;
	If (XmsRecLen And 1<>0)Then
	   Inc(XmsRecLen);
	If (RecordNo>0)Then
	   Begin
	   XmsHandle:=Xms_GetMem((LongInt(XmsRecLen*RecordNo) div 1024)+1);
	   For T:= 1 to RecordNo Do
		   Begin
		   inherited GetDBRec(T);
		   Xms_MoveMem(@Recor,0,pointer((T-1)*XmsRecLen),XmsHandle,XmsRecLen);
		   End;
	   End
	   Else
	   XmsHandle:=$FFFF;
	End;
End;

Procedure TXMSdbase.AppendCurrent;
Begin
If (RecCount=0)Then
   XmsHandle:=Xms_GetMem((RecordLen div 1024)+1);
inherited AppendCurrent;
If ((RecordNo*XmsRecLen)/1024<>((RecordNo-1)*XmsRecLen)/1024) Then
   Xms_ResizeMem(XmsHandle,(RecordNo*XmsRecLen div 1024)+1);
Xms_MoveMem(@Recor,0,pointer((RecordNo-1)*XmsRecLen),XmsHandle,XmsRecLen);
End;

Procedure TXMSdbase.AppendBlankAt(Rec:LongInt);{Ova}
Begin
If (RecCount=0)Then
   XmsHandle:=Xms_GetMem((XmsRecLen div 1024)+1);
End;

Procedure TXMSdbase.AppendCurrentAt(Rec:LongInt);{Ova}
Begin
If (RecCount=0)Then
   XmsHandle:=Xms_GetMem((XmsRecLen div 1024)+1);
End;

Procedure TXMSdbase.Save;
Begin
inherited Save;
Xms_MoveMem(@Recor,0,pointer((RecordPos-1)*XmsRecLen),XmsHandle,XmsRecLen);
End;

Procedure TXMSdbase.Pack;
Label Kraj;
Var Rp,Wp,T:LongInt;
Begin
If (RecordNo = 0) Then
   Goto Kraj;
Wp := 1;
T := RecordNo;
For Rp:= 1 To RecordNo Do
    Begin
    GetDbRec(Rp);
    If (Recor[0] = 42) Then
       T := T - 1;
    If ((Rp <> Wp)And(Recor[0] = 32)) Then
       Begin
       Xms_MoveMem(@Recor,0,pointer((Wp-1)*XmsRecLen),XmsHandle,XmsRecLen);
{       Er := SeekF(Handle, HeaderSize + (Wp - 1) * RecordLen);
       Er := WriteF(Handle, @Recor, RecordLen);}
       End;
    If (Recor[0] = 32) Then
       Inc(Wp);
    End;
If (RecordNo <> T) Then
     Begin
{     Er := SeekF(Handle, HeaderSize + (Wp) * RecordLen);
     Er := WriteF(Handle, Nil, 0);}
     Xms_ResizeMem(XmsHandle,(Wp * XmsRecLen div 1024)+1);
     inherited Pack;
     End;
Kraj:
End;

Procedure TXMSdbase.Zap;
Begin
If (RecordNo>0)Then
   Begin
   Xms_FreeMem(XmsHandle);
   XmsHandle:=$FFFF;
   End;
inherited Zap;
End;

Procedure TXMSdbase.GetDbRec(_RecNo: LongInt);
Label Kraj;
Begin
If (To_Save) Then
   Begin
   Save;
   To_Save:=False;
   End;
If ((_RecNo < 1)Or(_RecNo > RecordNo)) Then
   Begin
   Error := 88;
   Goto Kraj;
   End;
Xms_MoveMem(pointer((_RecNo-1)*XmsRecLen),XmsHandle,@Recor,0,XmsRecLen);
RecordPos := _RecNo;
Kraj:
End;

Destructor TXMSdbase.Done;
Begin
If (RecordNo>0)Then
   Xms_FreeMem(XmsHandle);
inherited Done;
End;
End.