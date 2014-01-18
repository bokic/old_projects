{************************************************}
{   GMsgBox.pas                                  }
{   Graph Vision unit                            }
{   Sergey E. Levov, Moscow,1992-1994            }
{   Portions copyright (c) 1990 by Borland Int.  }
{************************************************}

unit MsgBox;

{$F+,O+,X+,I-,S-,D-}

interface

uses Objects;

const

{ Message box classes }

  mfWarning      = $0000;       { Display a Warning box }
  mfError        = $0001;       { Dispaly a Error box }
  mfInformation  = $0002;       { Display an Information Box }
  mfConfirmation = $0003;       { Display a Confirmation Box }

  mfInsertInApp  = $0080;       { Insert message box into application }
                                { instead of the Desktop }

{ Message box button flags }

  mfYesButton    = $0100;       { Put a Yes button into the dialog }
  mfNoButton     = $0200;       { Put a No button into the dialog }
  mfOKButton     = $0400;       { Put an OK button into the dialog }
  mfCancelButton = $0800;       { Put a Cancel button into the dialog }

  mfYesNoCancel  = mfYesButton + mfNoButton + mfCancelButton;
                                { Standard Yes, No, Cancel dialog }
  mfOKCancel     = mfOKButton + mfCancelButton;
                                { Standard OK, Cancel dialog }

{ MessageBox displays the given string in a standard sized      }
{ dialog box. Before the dialog is displayed the Msg and Params }
{ are passed to FormatStr.  The resulting string is displayed   }
{ as a TStaticText view in the dialog.                          }

function MessageBox(const Msg: String; Params: Pointer; AOptions: Word): Word;

{ MessageBoxRec allows the specification of a TRect for the     }
{ message box to occupy.                                        }

function MessageBoxRect(var R: TRect; const Msg: String; Params: Pointer;
  AOptions: Word): Word;

{ InputBox displays a simple dialog that allows the user to     }
{ type in a string.                                             }

function InputBox(const Title, ALabel: String; var S: String;
  Limit: Byte): Word;

{ InputBoxRect is like InputBox but allows the specification of }
{ a rectangle.                                                  }

function InputBoxRect(var Bounds: TRect; const Title, ALabel: String;
  var S: String;  Limit: Byte): Word;


implementation

uses Memory, EventMan, GraV, Controls, GrApp, GFonts;

function MessageBox(const Msg: String; Params: Pointer;
  AOptions: Word): Word;
var
  R: TRect;
begin
  R.Assign(0, 0, 301, 208);
  if AOptions and mfInsertInApp = 0 then
     R.Move((Desktop^.Size.X - R.B.X) div 2, (Desktop^.Size.Y - R.B.Y) div 2)
  else R.Move((Application^.Size.X - R.B.X) div 2, (Application^.Size.Y - R.B.Y) div 2);
  MessageBox := MessageBoxRect(R, Msg, Params, AOptions);
end;

function MessageBoxRect(var R: TRect; const Msg: String; Params: Pointer;
  AOptions: Word): Word;
const
  ButtonName: array[0..3] of string =
    ('~Y~es', '~N~o', 'O~K~', '~C~ancel');
  Commands: array[0..3] of word =
    (cmYes, cmNo, cmOK, cmCancel);
  Titles: array[0..3] of string[11] =
    ('Warning','Error','Information','Confirm');
var
  I,J, X, ButtonCount: Integer;
  Dialog: PGraphDialog;
  Control: PGraphView;
  T: TRect;
  ButtonList: array[0..3] of PGraphView;
  S,S1: String;
 begin
  Dialog := New(PGraphDialog,
    Init(R, Titles[AOptions and $3]));
    S := Titles[AOptions and $3];
    for I := 1 to Length(S) do S[i] := UpCase(S[i]);
  with Dialog^ do
  begin
    R.Assign(14,13,275,107);
    Insert(New(PGraphGrayGroup,Init(R)));
    R.Assign(28,26,81,94);
    Control := New(PGraphStaticBitmap,Init(R,S));
    if Control <> nil then begin
      Insert(Control);
      R.Assign(93,26,268,94);
    end else R.Assign(28,26,268,94);
    FormatStr(S, Msg, Params^);
    Control := New(PGraphStaticText, Init(R, S, SystemFont,1));
    Insert(Control);
    X := -16;
    ButtonCount := 0;
    for I := 0 to 3 do
      if AOptions and ($0100 shl I) <> 0 then
      begin
        R.Assign(0,124,63,163);
        S1 := ButtonName[i];
        for j := 1 to Length(S1) do S1[j] := UpCase(S1[j]);
        Control := New(PGraphBitmapButton, Init(R, S1,
                   Commands[i],bfNormal+bfGrabFocus));
        if Control = nil then Control := New(PGraphtextButton,Init(R,ButtonName[i],
                       Commands[I],bfNormal+bfGrabFocus));
        Inc(X, Control^.Size.X + 16);
        ButtonList[ButtonCount] := Control;
        Inc(ButtonCount);
      end;
    X := (WorkSpace^.Size.X - X) shr 1;
    for I := 0 to ButtonCount - 1 do
    begin
      Control := ButtonList[I];
      Insert(Control);
      Control^.MoveTo(X, WorkSpace^.Size.Y - 56);
      Inc(X, Control^.Size.X + 16);
    end;
    SelectNext(False);
  end;
  if LowMemory then MessageBoxRect := cmCancel
  else begin
     if AOptions and mfInsertInApp = 0 then
        MessageBoxRect := DeskTop^.ExecView(Dialog)
     else MessageBoxRect := Application^.ExecView(Dialog);
  end;
  Dispose(Dialog, Done);
end;

function InputBox(const Title, ALabel: String; var S: String;
  Limit: Byte): Word;
var
  R: TRect;
begin
   InputBox := cmCancel;
end;

function InputBoxRect(var Bounds: TRect; const Title, ALabel: String;
  var S: String;  Limit: Byte): Word;
begin
  InputBoxRect := cmCancel;
end;

end.
