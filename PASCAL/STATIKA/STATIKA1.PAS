Program Statika1;

Procedure Adjust(var Inp,Out:Extended;Count:Byte);
Var T:String;
         Err:Integer;
Begin
Str(Inp:0:Count,T);
Val(T,Out,Err);
if (Out=0) Then Out:=0; { Radi glupo ponashanje na Borland }
End;

Label 1;
Var l,m,mmax,zmax,p,a,b,Ta,Tb,z,TOut:Extended;
Begin
Write('P=');ReadLn(p);
Write('L=');ReadLn(l);
a:=p/2;b:=p/2;
WriteLn('A=',a:0:4,',B=',b:0:4);
Ta:=a;Tb:=a-p;
WriteLn('Ta=',Ta:0:4,',Tb=',Tb:0:4);
z:=0;
1:
If (Z<=(l/2)) Then
        m:=a*z
        else
        m:=a*z-p*(z-l/2);
Adjust(m,TOut,4);
WriteLn('Z=',z:0:4,',M=',TOut:0:4);
z:=z+(l/10);
Adjust(z,TOut,4);
If (TOut<=l) Then Goto 1;
Zmax:=l/2;
MMax:=A*ZMax;
WriteLn('ZMax=',ZMax:0:4,',MMax=',MMax:0:4);
End.