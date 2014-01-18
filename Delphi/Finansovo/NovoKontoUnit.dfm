object VnesiKonto: TVnesiKonto
  Left = 319
  Top = 534
  BorderStyle = bsDialog
  Caption = #1042#1085#1077#1089#1080' '#1082#1086#1085#1090#1086
  ClientHeight = 106
  ClientWidth = 221
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LabelKonto: TLabel
    Left = 27
    Top = 20
    Width = 33
    Height = 13
    Caption = '&'#1050#1086#1085#1090#1086':'
    FocusControl = KontoOpis
  end
  object LabelOpis: TLabel
    Left = 32
    Top = 52
    Width = 29
    Height = 13
    Caption = '&'#1054#1087#1080#1089':'
    FocusControl = OpisOpis
  end
  object KontoOpis: TEdit
    Left = 64
    Top = 16
    Width = 121
    Height = 21
    MaxLength = 6
    TabOrder = 0
  end
  object OpisOpis: TEdit
    Left = 64
    Top = 48
    Width = 121
    Height = 21
    MaxLength = 50
    TabOrder = 1
  end
  object Insert: TButton
    Left = 88
    Top = 77
    Width = 75
    Height = 25
    Caption = '&'#1042#1085#1077#1089#1080
    Default = True
    ModalResult = 1
    TabOrder = 2
    OnClick = InsertClick
  end
end
