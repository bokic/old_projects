object NaloziDocForm: TNaloziDocForm
  Left = 218
  Top = 214
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1053#1072#1083#1086#1079#1080
  ClientHeight = 291
  ClientWidth = 496
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
  object StringGrid: TStringGrid
    Left = 0
    Top = 0
    Width = 491
    Height = 270
    BorderStyle = bsNone
    Color = clActiveBorder
    ColCount = 6
    DefaultRowHeight = 17
    FixedColor = clNone
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect, goThumbTracking]
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnDrawCell = StringGridDrawCell
  end
  object DolziSuma: TStaticText
    Left = 190
    Top = 271
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 1
  end
  object PobaruvaSuma: TStaticText
    Left = 281
    Top = 271
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 2
  end
  object SaldoSuma: TStaticText
    Left = 382
    Top = 271
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 3
  end
end
