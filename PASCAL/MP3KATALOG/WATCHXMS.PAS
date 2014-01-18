Unit WatchXMS;
Interface

Implementation
Uses Xms,Window,Crt;
Procedure ShowErrorDialog;Far;
Var Wind:PWindow;
    Ch:Char;
Begin
Wind:=CreateWindow('Greshka so XMS memoriskiot menagment',20,8,40,10,$1E);
Write('Greshka br. ',Xms.Xms_Status);
GotoXY(21,10);Write('Opis:');
GotoXY(21,11);
Case Xms.Xms_Status Of
     $80:Write('Funkcijata ne e vgradena.');
     $81:Write('Detektiran e VDISK.');
     $82:Write('A20 greshka.');
     $8E:Write('Greshka na drajverot.');
     $8F:Write('Nepovratena greshka na drajverot.');
     $90:Write('Ne postoi HMA.');
     $91:Write('HMA vekje e vo upotreba.');
     $92:Write('Parametarot /HMAMIN e golem.');
     $93:Write('HMA ne e alocirana.');
     $94:Write('A20 e aktivna.');
     $A0:Write('Cela prochirena memorija e alocirana.');
     $A1:Write('Nema slobodni upravuvachi.');
     $A2:Write('Upravuvachot ne e validen.');
     $A3:Write('Parametarot ''SourceHandle'' ne e validen.');
     $A4:Write('Parametarot ''SourceOffset'' ne e validen.');
     $A5:Write('Parametarot ''DestHandle'' ne e validen.');
     $A6:Write('Parametarot ''DestOffset'' ne e validen.');
     $A7:Write('Parametarot ''Length'' ne e validen.');
     $A8:Write('Memorisko preklopuvanje.');
     $A9:Write('''Parity'' greshka.');
     $AA:Write('Blokot ne e zakljuchen.');
     $AB:Write('Blokot e zakljuchen.');
     $AC:Write('Brojot na zakljuchuvanja e nad granicata.');
     $AD:Write('Zakljuchuvanjeto e neuspeshno.');
     $B0:Write('Pomal UMB e sloboden.');
     $B1:Write('Nema slobodni UMBs.');
     $B2:Write('Segmentot na UMB e nevaliden.');
     Else
         Write('Nepoznata greshka!!');
     End;
GotoXY(21,12);
Write('P - Prodolzi.');
GotoXY(21,13);
Write('I - Izlez.');
GotoXY(21,14);
Write('R - Proveri.');
Repeat
Ch:=UpCase(ReadKey);
Until ((Ch='I')Or(Ch='P')Or(Ch='R'));
DestroyWindow(Wind);
If (Ch='I')Then
   Halt;
If (Ch='R')Then
   Asm
   int 3
   End;
End;

Begin
Xms.Xms_Err_Addr:=@ShowErrorDialog;
End.