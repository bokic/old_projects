object KomintentDocForm: TKomintentDocForm
  Left = 211
  Top = 186
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1050#1086#1084#1080#1085#1090#1077#1085#1090
  ClientHeight = 322
  ClientWidth = 562
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
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
    Hint = #1054#1076' '#1076#1072#1090#1091#1084
    Date = 36772.812667129600000000
    Time = 36772.812667129600000000
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnKeyPress = OdDatumKeyPress
  end
  object DoDatum: TDateTimePicker
    Left = 128
    Top = 8
    Width = 97
    Height = 21
    Hint = #1044#1086' '#1076#1072#1090#1091#1084
    Date = 36772.812883912010000000
    Time = 36772.812883912010000000
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnKeyPress = DoDatumKeyPress
  end
  object Komintent: TComboBox
    Left = 240
    Top = 8
    Width = 297
    Height = 21
    Hint = #1050#1086#1084#1080#1085#1090#1077#1085#1090
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    Sorted = True
    TabOrder = 2
    OnChange = KomintentChange
    OnKeyPress = KomintentKeyPress
  end
  object StringGrid: TStringGrid
    Left = 0
    Top = 32
    Width = 561
    Height = 270
    BorderStyle = bsNone
    Color = clActiveBorder
    ColCount = 6
    DefaultRowHeight = 17
    FixedColor = clNone
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect, goThumbTracking]
    TabOrder = 3
    OnDrawCell = StringGridDrawCell
  end
  object DolziSuma: TStaticText
    Left = 270
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 4
  end
  object PobaruvaSuma: TStaticText
    Left = 361
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 5
  end
  object Saldo: TStaticText
    Left = 452
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 6
  end
end
