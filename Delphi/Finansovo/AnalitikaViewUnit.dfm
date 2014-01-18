object AnalitikaDocForm: TAnalitikaDocForm
  Left = 199
  Top = 102
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1040#1085#1072#1083#1080#1090#1080#1082#1072
  ClientHeight = 320
  ClientWidth = 593
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Visible = True
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object OdDatum: TDateTimePicker
    Left = 16
    Top = 4
    Width = 97
    Height = 21
    Date = 36772.812667129600000000
    Time = 36772.812667129600000000
    TabOrder = 0
    OnChange = OdDatumChange
    OnKeyPress = OdDatumKeyPress
  end
  object DoDatum: TDateTimePicker
    Left = 128
    Top = 4
    Width = 97
    Height = 21
    Date = 36772.812883912010000000
    Time = 36772.812883912010000000
    TabOrder = 1
    OnChange = DoDatumChange
    OnKeyPress = DoDatumKeyPress
  end
  object Konto: TComboBox
    Left = 240
    Top = 4
    Width = 329
    Height = 21
    ItemHeight = 13
    Sorted = True
    TabOrder = 2
    OnChange = KontoChange
    OnKeyPress = KontoKeyPress
  end
  object StringGrid: TStringGrid
    Left = 0
    Top = 29
    Width = 592
    Height = 270
    BorderStyle = bsNone
    Color = clBtnFace
    ColCount = 7
    DefaultRowHeight = 17
    FixedColor = clNone
    RowCount = 2
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect, goThumbTracking]
    ParentFont = False
    TabOrder = 3
    OnDrawCell = StringGridDrawCell
  end
  object DolziSuma: TStaticText
    Left = 392
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 4
    Visible = False
  end
  object PobaruvaSuma: TStaticText
    Left = 483
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 5
    Visible = False
  end
end
