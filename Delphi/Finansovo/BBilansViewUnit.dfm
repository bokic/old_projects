object BBilansDocForm: TBBilansDocForm
  Left = 213
  Top = 314
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1041#1088#1091#1090#1086' '#1073#1080#1083#1072#1085#1089
  ClientHeight = 321
  ClientWidth = 745
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
  object KlasaLabel: TLabel
    Left = 253
    Top = 11
    Width = 34
    Height = 13
    Caption = #1050#1083#1072#1089#1072':'
  end
  object StringGrid: TStringGrid
    Left = 0
    Top = 32
    Width = 743
    Height = 270
    BorderStyle = bsNone
    Color = clActiveBorder
    ColCount = 8
    DefaultRowHeight = 17
    FixedColor = clNone
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect, goThumbTracking]
    TabOrder = 3
    OnDblClick = StringGridDblClick
    OnDrawCell = StringGridDrawCell
  end
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
    OnKeyPress = DoDatumKeyPress
  end
  object Klasa: TComboBox
    Left = 288
    Top = 8
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 2
    OnKeyPress = KlasaKeyPress
    Items.Strings = (
      '0'
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9'
      '0..9')
  end
  object DolziSuma: TStaticText
    Left = 452
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 6
  end
  object PobaruvaSuma: TStaticText
    Left = 543
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 7
  end
  object PocPobaruvaSuma: TStaticText
    Left = 361
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 5
  end
  object PocDolziSuma: TStaticText
    Left = 270
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 4
  end
  object Saldo: TStaticText
    Left = 634
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 8
  end
end
