DECLARE SUB SetPalette ()
DECLARE FUNCTION MIN% (Br1%, Br2%, Br3%, Br4%)
DECLARE FUNCTION MAX% (Br1%, Br2%, Br3%, Br4%)
DECLARE SUB Plazma (Xlg%, Ylg%, Xdd%, Ydd%)
DEFINT A-Z
SCREEN 13

SetPalette

PALETTE 0, 0

RANDOMIZE TIMER
PSET (1, 1), 1
PSET (1, 129), 128
PSET (129, 1), 128
PSET (129, 129), 175
PSET (257, 1), 128
PSET (257, 129), 1

CALL Plazma(1, 1, 257, 129)

FUNCTION MAX (Br1, Br2, Br3, Br4)

MaxBr = Br1
IF Br2 > MaxBr THEN MaxBr = Br2
IF Br3 > MaxBr THEN MaxBr = Br3
IF Br4 > MaxBr THEN MaxBr = Br4
MAX = MaxBr

END FUNCTION

FUNCTION MIN (Br1, Br2, Br3, Br4)

MinBr = Br1
IF Br2 < MinBr THEN MinBr = Br2
IF Br3 < MinBr THEN MinBr = Br3
IF Br4 < MinBr THEN MinBr = Br4
MIN = MinBr

END FUNCTION

SUB Plazma (Xlg, Ylg, Xdd, Ydd)
X1 = (Xlg + Xdd) / 2
Y1 = (Ylg + Ydd) / 2

PTlglg = POINT(Xlg, Ylg)
PTlgdd = POINT(Xlg, Ydd)
PTddlg = POINT(Xdd, Ylg)
PTdddd = POINT(Xdd, Ydd)
PTmin = MIN(PTlglg, PTlgdd, PTddlg, PTdddd)
PTmax = MAX(PTlglg, PTlgdd, PTddlg, PTdddd)

IF POINT(X1, Y1) = 0 THEN PSET (X1, Y1), (PTlglg + PTlgdd + PTddlg + PTdddd) / 4
IF POINT(Xlg, Y1) = 0 THEN PSET (Xlg, Y1), PTlglg + INT(RND * (PTlgdd - PTlglg))
IF POINT(Xdd, Y1) = 0 THEN PSET (Xdd, Y1), PTddlg + INT(RND * (PTdddd - PTddlg))
IF POINT(X1, Ylg) = 0 THEN PSET (X1, Ylg), PTlglg + INT(RND * (PTddlg - PTlglg))
IF POINT(X1, Ydd) = 0 THEN PSET (X1, Ydd), PTdddd + INT(RND * (PTlgdd - PTdddd))

IF ABS(X1 - Xlg) = 1 THEN EXIT SUB

'WHILE INKEY$ = "": WEND
CALL Plazma(Xlg, Ylg, X1, Y1)
CALL Plazma(Xlg, Ydd, X1, Y1)
CALL Plazma(Xdd, Ylg, X1, Y1)
CALL Plazma(Xdd, Ydd, X1, Y1)

END SUB

SUB SetPalette

FOR t = 0 TO 63

   PALETTE t, (t + 256& * (63 - t))
   PALETTE t + 64, (63 - t + 256& * 256& * t)
   PALETTE t + 128, ((256& * 256& * (63 - t) + 256& * t))

NEXT t

END SUB

