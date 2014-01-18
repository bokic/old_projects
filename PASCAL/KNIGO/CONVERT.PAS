Uses Dbase;

Var
	Create:PCreateFile;
	Nnew,Old,Konten:PDBase;
	T,T1:LongInt;
	TSt,TSt1:String[50];
	TLo:LongInt;
Begin
System.New(Create,Init('newknigo.dbf'));
Create^.Add('Nalog','N',4,0);
Create^.Add('Naziv','C',14,0);
Create^.Add('Konto','C',6,0);
Create^.Add('Komintent','N',5,0);
Create^.Add('Data' ,'D',8,0);
Create^.Add('Dava' ,'N',13,2);
Create^.Add('Zima' ,'N',13,2);
Dispose(Create,Done);

New(Old,Init('knigo.dbf'));
New(Nnew,Init('newknigo.dbf'));
New(Konten,Init('konten.dbf'));

If (Old^.RecCount>0)Then
        For T:=1 To Old^.RecCount Do
                Begin
					 Old^.GetDBRec(T);
					 Nnew^.MyReplace(2,Old^.MyFieldData(2));
					 TSt:=Old^.MyFieldData(3);
					 If ((Copy(TSt,1,4)='1200')Or(Copy(TSt,1,4)='2200'))Then
						Begin
						Nnew^.MyReplace(3,Copy(TSt,1,4));
						Nnew^.MyReplace(4,Copy(TSt,5,2));
						End
						Else
						Begin
						If (Tst[1]=' ') Then
							Tst[1]:='0';
						If (Tst[2]=' ') Then
							Tst[2]:='0';
						For T1:=1 To Konten^.RecCount Do
							Begin
							Konten^.GetDBRec(T1);
							TSt1:= Konten^.MyFieldData(1);
							End;
						Nnew^.MyReplace(3,TSt);
						Nnew^.MyReplace(4,'  ');
						End;
					 Nnew^.MyReplace(5,Old^.MyFieldData(4));
					 Nnew^.MyReplace(6,Old^.MyFieldData(5));
					 Nnew^.MyReplace(7,Old^.MyFieldData(6));
					 Nnew^.AppendCurrent;
					 End;
End.