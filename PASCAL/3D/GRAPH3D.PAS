Unit Graph3D;
{$A+,B+,D+,E-,F+,G+,I+,L+,N+,O-,P-,Q+,R+,S+,T+,V-,X+,Y+}
{$M 16384,0,655360}
interface
Type
    PPoint = ^TPoint;
    TPoint = Record
    X:Integer;
    Y:Integer;
    End;

    TRect = Record
    A:TPoint;
    B:TPoint;
    End;

    P3DPoint = ^T3DPoint;
    T3DPoint = Record
    X,Y,Z:Real;
    End;

    P3DPoly = ^T3DPoly;
    T3DPoly = Record
    Point : Array [1..3] of Word;
    End;

    P_3DVertex = ^T_3DVertex;
    T_3DVertex = Record
    X,Y,Z:Real;
    Prev,Next:Pointer;
    End;

    P_3DPolygon = ^T_3DPolygon;
    T_3DPolygon = Record
    Prev,Next:Pointer;
    Point: array [1..3] of Word;
    End;

    PListVertex = ^TListVertex;
    TListVertex = object
    constructor Init; {}
    function Add(x1,y1,z1:Real):Word;
    procedure Clear;
    function Goto_Vertex(Num:Word):Boolean;
    function Search(x1,y1,z1:Real):Word;
    destructor Done;
    public
    Point:P_3DVertex;
    Count:Word;
    Pos:Word;
    End;

    PListPolygon = ^TListPolygon;
    TListPolygon = object
    constructor Init(PList:PListVertex);
    function Add(x1,y1,z1,x2,y2,z2,x3,y3,z3:Real):Word;
    procedure Clear;
    function Goto_Polygon(Num:Word):Boolean;
    function Search(T:P3DPoly):Word;
    function Search3D(P1,P2,P3:P3DPoint):Word;
    destructor Done;
    public
    List:PListVertex;
    Point:P_3DPolygon;
    Count:Word;
    Pos:Word;
    End;

    PElement = ^TElement;
    TElement = Object(TListpolygon)
    constructor Init(N:String;PL:PListVertex);
    private
    Name:String [10];
    End;

    PMesh = ^TMesh;
    TMesh = object
    Name:String [10];
    private
    ElementsList : array [0..15] of ^PElement;
    End;

    P3DWindow = ^T3DWindow;
    T3DWindow = object
    constructor Init(Wi,He:Word;Zo,LeA,ToA:Real);
    procedure D2dDraw(PList:PListPolygon);
    public
    Width:Word;
    Heigth:Word;
    Zoom:Real;
    LOffset:Real;
    TOffset:Real;
    Angle:Record
     Left:Real;
     Top:Real;
     End;
    End;

implementation
uses Graph;

constructor TListVertex.Init;
Begin
Point:=nil;
Pos:=0;
Count:=0;
End;

Function TListVertex.Add(x1,y1,z1:Real):Word;
Var N_Ver,T:P_3DVertex;
Begin
GetMem(N_Ver,SizeOf(T_3DVertex));
N_Ver^.X:=x1;N_Ver^.Y:=y1;N_Ver^.Z:=z1;
N_Ver^.Next:=nil;
If(Point=nil) Then
    Begin
    N_Ver^.Prev:=nil;
    Point:=N_Ver;
    Pos:=1;
    Inc(Count);
    End
    Else
    Begin
    T:=Point;
    If(T^.Next<>nil) Then
        repeat
        T:=T^.Next;
        until (T^.Next=nil);
    T^.Next:=N_Ver;
    N_Ver^.Prev:=T;
    N_Ver^.Next:=Nil;
    Inc(Count);
    End;
Add:=Count;
End;

procedure TListVertex.Clear;
Var P:Pointer;
Begin
If (Goto_Vertex(1)) Then
    Begin
    repeat
    P:=Point^.Next;
    FreeMem(Point,SizeOf(T_3DVertex));
    Point:=P;
    until (Point=nil);
    End;
Count:=0;
Pos:=0;
End;

function TListVertex.Goto_Vertex(Num:Word):Boolean;
Var T:Word;
Begin
If ((Count<Num)or(Num=0)) Then
   Begin
   Goto_Vertex:=False;
   Exit;
   End;
if (Num<>Pos) Then
   Begin
   If(Num<Pos) Then
       Begin
       For T:= 1 To Pos-Num Do
           Point:=Point^.Prev;
       End
       Else
       Begin
       For T:= 1 To Num-Pos Do
           Point:=Point^.Next;
       End;
   End;
Pos:=Num;
Goto_Vertex:=True;
End;

function TListVertex.Search(x1,y1,z1:Real):Word;
Var CP:Word;
    T:Word;
    TPoint:P_3DVertex;
Begin
CP:=Pos;
Search:=0;
For T:=1 To Count Do
    Begin
    Goto_Vertex(T);
    If((Point^.X=x1)AND(Point^.Y=y1)AND(Point^.Z=z1)) Then
        Begin
        Search:=T;
        Exit;
        End;
    End;
Goto_Vertex(CP);
End;

destructor TListVertex.Done;
Begin
Clear;
End;

constructor TListPolygon.Init(PList:PListVertex);
Begin
List:=PList;
Point:=nil;
count:=0;
pos:=0;
End;

function TListPolygon.Add(x1,y1,z1,x2,y2,z2,x3,y3,z3:Real):Word;
Label Kraj;
Var _Search:Boolean;
    Vert:Array [1..3] of T_3DVertex;
    P:T3DPoly;
    T:Byte;
    NPol:P_3DPolygon;
    TPol:P_3DPolygon;
Begin
Add:=0;
_Search:=True;
With Vert[1] Do Begin x:=x1;y:=y1;z:=z1 End;
With Vert[2] Do Begin x:=x2;y:=y2;z:=z2 End;
With Vert[3] Do Begin x:=x3;y:=y3;z:=z3 End;
For T:=1 to 3 Do
    Begin
    With Vert[T] Do P.Point[T]:= List^.Search(x,y,z);
    If (P.Point[T]=0)Then
       Begin
       With Vert[T] Do P.Point[T]:=List^.Add(x,y,z);
       _Search:=False;
       End;
    End;
If (_Search) Then
   Begin
   Add:=TListPolygon.Search(@P);
    Asm
    Cmp ax,0
    jne Kraj
    End;
   End;
New(NPol);
move(P,NPol^.Point,6);
NPol^.Next:=nil;
If(Point=nil) Then
    Begin
    NPol^.Prev:=nil;
    Point:=NPol;
    Pos:=1;
    Inc(Count);
    End
    Else
    Begin
    TPol:=Point;
    If(TPol^.Next<>nil) Then
        repeat
        TPol:=TPol^.Next;
        until (TPol^.Next=nil);
    TPol^.Next:=NPol;
    NPol^.Prev:=TPol;
    NPol^.Next:=Nil;
    Inc(Count);
    End;
Add:=Count;
Kraj:
End;

procedure TListPolygon.Clear;
Var P:Pointer;
Begin
If (Goto_Polygon(1)) Then
    Begin
    repeat
    P:=Point^.Next;
    FreeMem(Point,SizeOf(T_3DVertex));
    Point:=P;
    until (Point=nil);
    End;
Count:=0;
Pos:=0;
List^.Clear;
End;

function TListPolygon.Goto_Polygon(Num:Word):Boolean;
Var T:Word;
Begin
If ((Count<Num)or(Num=0)) Then
   Begin
   Goto_Polygon:=False;
   Exit;
   End;
if (Num<>Pos) Then
   Begin
   If(Num<Pos) Then
       Begin
       For T:= 1 To Pos-Num Do
           Point:=Point^.Prev;
       End
       Else
       Begin
       For T:= 1 To Num-Pos Do
           Point:=Point^.Next;
       End;
   End;
Pos:=Num;
Goto_Polygon:=True;
End;

function TListPolygon.Search(T:P3DPoly):Word;
Var CP:Word;
    _T:Word;
    TPoint:P_3DPolygon;
Begin
CP:=Pos;
Search:=0;
For _T:=1 To Count Do
    Begin
    Goto_Polygon(_T);
    If((Point^.Point[1]=T^.Point[1])AND
       (Point^.Point[2]=T^.Point[2])AND
       (Point^.Point[3]=T^.Point[3])) Then
        Begin
        Search:=_T;
        Exit;
        End;
    End;
Goto_Polygon(CP);
End;

Function TListPolygon.Search3D(P1,P2,P3:P3DPoint):Word;
Begin

End;

destructor TListPolygon.Done;
Begin
Clear;
Dispose(List,Done);
End;

constructor TElement.Init(N:String;PL:PListVertex);
Begin
Name:=N;
Inherited Init(PL);
End;

constructor T3DWindow.Init(Wi,He:Word;Zo,LeA,ToA:Real);
Begin
Width:=Wi;
Heigth:=He;
Zoom:=Zo;
With Angle Do
     Begin
     Left:=LeA;
     Top:=ToA;
     End;
End;

procedure T3DWindow.D2dDraw(PList:PListPolygon);

function GetX(X,Y,Z:Real):integer;
Var T:Real;
    R:Real;
Begin
T:=(((Cos(Angle.Left*PI/180)*X)
            -(Sin(Angle.Left*PI/180)*Y))
            *Zoom+LOffset);
R:=T;
GetX:=Round(R);
{GetX:=Round(((Cos(Angle.Left*PI/180)*X)
            -(Sin(Angle.Left*PI/180)*Y))
            *Zoom+LOffset);}
End;
function GetY(X,Y,Z:Real):integer;
Var T:Real;
    R:Real;
Begin
T:=((((Sin(Angle.Left*PI/180)*X)
              +(Cos(Angle.Left*PI/180)*Y))
              *Cos(Angle.Top*PI/180))
             -(Cos(Angle.Top*PI/180)*Z))*Zoom+TOffset;
R:=T;
GetY:=Round(R);
{GetY:=Round(((((Sin(Angle.Left*PI/180)*X)+
(Cos(Angle.Left*PI/180)*Y))*Cos(Angle.Top*PI/180))-(Cos(Angle.Top*PI/180)*Z))*Zoom+TOffset);}
End;
Var TLop:P_3DVertex;
    tx,ty,tz:integer;
    Lop:Word;
    N:Byte;
Begin
If PList^.Count=0 Then Exit;
For Lop:=1 To PList^.Count Do
    Begin
    PList^.Goto_Polygon(Lop);
    For N:=1 to 3 Do
        Begin
        If(PList^.List^.Goto_Vertex(PList^.Point^.Point[N]))Then
            Begin
            With PList^.List^.Point^ Do
                If(N=1)Then
                     Begin
                     MoveTo(GetX(X,Y,Z),GetY(X,Y,Z));
                     TLop:=PList^.List^.Point;
                     End
                    Else
                    LineTo(GetX(X,Y,Z),GetY(X,Y,Z));
            End
            Else Halt(13);
        End;
    With TLop^ Do Lineto(GetX(X,Y,Z),GetY(X,Y,Z));
    End;
End;
End.