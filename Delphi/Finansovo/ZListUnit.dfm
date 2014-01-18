object ZListDocForm: TZListDocForm
  Left = 312
  Top = 219
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1047#1072#1082#1083#1091#1095#1077#1085' '#1083#1080#1089#1090
  ClientHeight = 320
  ClientWidth = 744
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefaultPosOnly
  Visible = True
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object OdDatum: TDateTimePicker
    Left = 16
    Top = 8
    Width = 97
    Height = 21
    Date = 36772.812667129600000000
    Time = 36772.812667129600000000
    TabOrder = 0
    OnKeyPress = OdDatumKeyPress
  end
  object DoDatum: TDateTimePicker
    Left = 128
    Top = 8
    Width = 97
    Height = 21
    Date = 36772.812883912010000000
    Time = 36772.812883912010000000
    TabOrder = 1
    OnExit = DoDatumExit
    OnKeyPress = DoDatumKeyPress
  end
  object StringGrid: TStringGrid
    Left = 0
    Top = 32
    Width = 743
    Height = 270
    Hint = 'Test'
    BorderStyle = bsNone
    Color = clActiveBorder
    ColCount = 8
    DefaultRowHeight = 17
    FixedColor = clNone
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect, goThumbTracking]
    TabOrder = 2
    OnDblClick = StringGridDblClick
    OnDrawCell = StringGridDrawCell
  end
  object PocDolziSuma: TStaticText
    Left = 270
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 3
  end
  object PocPobaruvaSuma: TStaticText
    Left = 361
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 4
  end
  object DolziSuma: TStaticText
    Left = 452
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 5
  end
  object PobaruvaSuma: TStaticText
    Left = 543
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 6
  end
  object Saldo: TStaticText
    Left = 634
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 7
  end
end
