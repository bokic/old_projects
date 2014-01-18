object VnesiNalog: TVnesiNalog
  Left = 257
  Top = 546
  BorderStyle = bsDialog
  Caption = #1042#1085#1077#1089#1080' '#1085#1072#1083#1086#1075
  ClientHeight = 106
  ClientWidth = 221
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LabelNalog: TLabel
    Left = 23
    Top = 24
    Width = 29
    Height = 13
    Caption = '&'#1054#1087#1080#1089':'
    FocusControl = NalogOpis
  end
  object Label2: TLabel
    Left = 16
    Top = 52
    Width = 36
    Height = 13
    Caption = '&'#1044#1072#1090#1091#1084':'
  end
  object NalogOpis: TEdit
    Left = 55
    Top = 21
    Width = 121
    Height = 21
    MaxLength = 8
    TabOrder = 0
    OnExit = NalogOpisExit
    OnKeyPress = NalogOpisKeyPress
  end
  object Datum: TEdit
    Left = 55
    Top = 48
    Width = 121
    Height = 21
    MaxLength = 10
    TabOrder = 1
    OnKeyPress = DatumKeyPress
  end
  object Vnesi: TButton
    Left = 72
    Top = 76
    Width = 75
    Height = 25
    Caption = '&'#1042#1085#1077#1089#1080
    Default = True
    TabOrder = 2
    OnClick = VnesiClick
  end
end
