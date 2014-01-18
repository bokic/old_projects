object MainForm: TMainForm
  Left = 410
  Top = 198
  HelpType = htKeyword
  HelpKeyword = '100'
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsDialog
  Caption = #1062#1077#1085#1090#1088#1072#1083#1072' '#1082#1083#1080#1077#1085#1090' '#1074'1.2'
  ClientHeight = 297
  ClientWidth = 305
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnHelp = FormHelp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object EMail: TLabel
    Left = 145
    Top = 283
    Width = 158
    Height = 13
    Caption = #1048#1079#1088#1072#1073#1086#1090#1080#1083': '#1041#1072#1088#1073#1091#1083#1086#1074#1089#1082#1080' '#1041#1086#1088#1080#1089
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Pregled: TBitBtn
    Left = 64
    Top = 32
    Width = 177
    Height = 41
    HelpContext = 100
    Caption = '&'#1055#1088#1077#1075#1083#1077#1076
    TabOrder = 0
    OnClick = PregledClick
  end
  object Analizi: TBitBtn
    Left = 64
    Top = 80
    Width = 177
    Height = 41
    HelpContext = 101
    Caption = '&'#1040#1085#1072#1083#1080#1079#1072
    TabOrder = 1
    OnClick = AnaliziClick
  end
  object AnalizaPoDenovi: TBitBtn
    Left = 64
    Top = 128
    Width = 177
    Height = 41
    HelpContext = 102
    Caption = #1040'&'#1085#1072#1083#1080#1079#1072' '#1087#1086' '#1076#1077#1085#1086#1074#1080
    TabOrder = 2
    OnClick = AnalizaPoDenoviClick
  end
  object Opcii: TBitBtn
    Left = 64
    Top = 176
    Width = 177
    Height = 41
    HelpContext = 103
    Caption = '&'#1054#1087#1094#1080#1080
    TabOrder = 3
    OnClick = OpciiClick
  end
  object Izlez: TBitBtn
    Left = 64
    Top = 224
    Width = 177
    Height = 41
    HelpContext = 104
    Caption = '&'#1048#1079#1083#1077#1079
    TabOrder = 4
    OnClick = IzlezClick
  end
end
