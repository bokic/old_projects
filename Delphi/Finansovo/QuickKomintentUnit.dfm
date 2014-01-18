object QuickKomintentForm: TQuickKomintentForm
  Left = 291
  Top = 267
  BorderStyle = bsDialog
  Caption = 'I?aaa?oaa?a ia eiieioaioe'
  ClientHeight = 231
  ClientWidth = 378
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StringGrid: TStringGrid
    Left = 8
    Top = 40
    Width = 361
    Height = 183
    ColCount = 2
    DefaultRowHeight = 17
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    TabOrder = 2
    OnKeyPress = StringGridKeyPress
  end
  object SifraEdit: TEdit
    Left = 8
    Top = 8
    Width = 81
    Height = 21
    Hint = 'Prebaruvanje po sifra'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnChange = SifraEditChange
    OnKeyPress = SifraEditKeyPress
  end
  object ImeEdit: TEdit
    Left = 104
    Top = 8
    Width = 265
    Height = 21
    Hint = 'Prebaruvanje po ime na komintent'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnChange = ImeEditChange
    OnKeyPress = ImeEditKeyPress
  end
end
