object AboutForm: TAboutForm
  Left = 377
  Top = 298
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1080
  ClientHeight = 88
  ClientWidth = 353
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Name: TLabel
    Left = 60
    Top = 17
    Width = 159
    Height = 13
    Caption = 'FKnigo '#1074#1077#1088#1079#1080#1112#1072' 1.3 (26-08-2004)'
  end
  object CopyRight: TLabel
    Left = 62
    Top = 43
    Width = 92
    Height = 13
    Caption = 'Copyright (C) 2000'
  end
  object Icon: TImage
    Left = 15
    Top = 30
    Width = 32
    Height = 32
    Picture.Data = {
      055449636F6E0000010001002020100000000000E80200001600000028000000
      2000000040000000010004000000000080020000000000000000000000000000
      0000000000000000000080000080000000808000800000008000800080800000
      80808000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000
      FFFFFF0000000000000000000000000000000000000000000000000000000000
      000000000000000B3B3B3B33330000BB3B3000000000B3B3B3B3333333030BB3
      3033000000033330000000000030BB0B3B3330000003333B8B8383333033BBBB
      3333300000003333333333330B3B3BB33B3B3B0000000B3B3B3333330B3B33B3
      BBB3330000B3B3B3B3B333330B3B333BBB333B0003333000000000000B3B33BB
      BBB3B3000300000B3B3B33330B3B333BB0B33B000030B3B3B3B3B3330B3B333B
      BBB3B30003033333333333330B33333BBB3B3B000003000B888383830BB33333
      333BB000000033330000000000B33B3333BB300000033000B3B3B3B3B0BB3333
      0BBB000000000B3B3B3B3B3B3B0BB33B3BB00000000033333333333333300B33
      3300000000003000BBB838383830003000000000000003333380000000000000
      0000000000003338000B3B3B3B3B3B000000000000000330B3B3B3B3B3B3B3B3
      3000000000000003333FFFFFF33333333300000000000003088BBBB3B3B3B300
      030000000000000033333BBBBB3B3B33300000000000000333B3B3BBBBB3B3B3
      3300000000000000333B3BBBBBBB333330000000000000000003B3B3BFFFFB00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FFFFFFFFFE003C1FF000000FE0000007C0000003C0000003C0000001
      C0000001800000010000000100000001000000010000000180000003C0000003
      C0000007E000000FE000001FE00000FFE00000FFE000007FF000003FF800001F
      FC00001FFC00001FFC00001FFE00003FFF00007FFFE003FFFFFFFFFFFFFFFFFF
      FFFFFFFF}
  end
  object Label1: TLabel
    Left = 222
    Top = 71
    Width = 122
    Height = 13
    Cursor = crHandPoint
    Caption = 'bokicsof@freemail.org.mk'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = Label1Click
  end
  object OK: TButton
    Left = 267
    Top = 8
    Width = 75
    Height = 22
    Cancel = True
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
end