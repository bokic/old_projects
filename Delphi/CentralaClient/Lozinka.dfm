object LozinkaForm: TLozinkaForm
  Left = 298
  Top = 257
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = #1042#1085#1077#1089#1080' '#1083#1086#1079#1080#1085#1082#1072
  ClientHeight = 108
  ClientWidth = 280
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object LozinkaLabel: TLabel
    Left = 41
    Top = 48
    Width = 46
    Height = 13
    Caption = #1051#1086#1079#1080#1085#1082#1072':'
  end
  object Lozinka: TEdit
    Left = 89
    Top = 45
    Width = 121
    Height = 21
    PasswordChar = '*'
    TabOrder = 0
  end
  object LozinkaBitBtn: TBitBtn
    Left = 104
    Top = 72
    Width = 75
    Height = 25
    Caption = '&'#1042#1085#1077#1089#1080
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
