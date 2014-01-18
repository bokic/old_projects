{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}
Uses SVga;
Begin
SetMode(SVGA6448);
LoadWriteBank(3);
Circle(50,80,40,3);
readln;
ExitGraphics;
End.
