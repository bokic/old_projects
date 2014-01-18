object NalogDocForm: TNalogDocForm
  Left = 212
  Top = 180
  ActiveControl = ComboBox
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1053#1072#1083#1086#1075
  ClientHeight = 321
  ClientWidth = 553
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefaultPosOnly
  Scaled = False
  Visible = True
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 135
    Top = 8
    Width = 49
    Height = 13
    Caption = #1053#1072#1083#1086#1075' '#1073#1088':'
    FocusControl = ComboBox
  end
  object Date: TLabel
    Left = 296
    Top = 8
    Width = 201
    Height = 13
    AutoSize = False
  end
  object StringGrid: TStringGrid
    Left = 0
    Top = 32
    Width = 553
    Height = 270
    BorderStyle = bsNone
    Color = clActiveBorder
    ColCount = 8
    DefaultRowHeight = 17
    FixedColor = clNone
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect, goThumbTracking]
    ParentShowHint = False
    ShowHint = False
    TabOrder = 0
    OnDrawCell = StringGridDrawCell
    OnMouseMove = StringGridMouseMove
  end
  object ComboBox: TComboBox
    Left = 184
    Top = 5
    Width = 105
    Height = 21
    ItemHeight = 13
    MaxLength = 8
    Sorted = True
    TabOrder = 1
    OnChange = ComboBoxChange
  end
  object DolziSuma: TStaticText
    Left = 302
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 2
  end
  object PobaruvaSuma: TStaticText
    Left = 393
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 3
  end
end
