{$A+,B-,D-,E-,F-,G+,I-,L-,N-,O-,P-,Q+,R-,S-,T-,V+,X+,Y+}
{$M 16384,0,655360}
Uses Dos;
Var T:Text;
    Hour,Minute,Second,Hund:Word;
    Year, Month, Day, DOW:Word;
    Test,WR:String;
Begin
Assign(T,'c:\push.inf');
Append(T);
GetTime(Hour,Minute,Second,Hund);
GetDate(Year, Month, Day, DOW);
WR:='Date:';
Str(Day:2,Test);
If(Test[1]=' ')Then Test[1]:='0';
WR:=WR+Test+'-';
Str(Month:2,Test);
If(Test[1]=' ')Then Test[1]:='0';
WR:=WR+Test+'-';
Str(Year:4,Test);
If(Test[1]=' ')Then Test[1]:='0';
WR:=WR+Test+',Time:';
Str(Hour:2,Test);
If(Test[1]=' ')Then Test[1]:='0';
WR:=WR+Test+':';
Str(Minute:2,Test);
If(Test[1]=' ')Then Test[1]:='0';
WR:=WR+Test+':';
Str(Second:2,Test);
If(Test[1]=' ')Then Test[1]:='0';
WR:=WR+Test+':';
Str(Hund:2,Test);
If(Test[1]=' ')Then Test[1]:='0';
WR:=WR+Test;
WriteLn(T,WR);
Close(T);
End.