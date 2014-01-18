object OpciiForm: TOpciiForm
  Left = 271
  Top = 244
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsDialog
  Caption = #1054#1087#1094#1080#1080
  ClientHeight = 209
  ClientWidth = 482
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PathLabel: TLabel
    Left = 23
    Top = 16
    Width = 95
    Height = 13
    Caption = '&'#1055#1072#1090#1077#1082#1072' '#1076#1086' '#1073#1072#1079#1072#1090#1072':'
    FocusControl = DBPath
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 11
    Top = 46
    Width = 105
    Height = 13
    Caption = '&'#1042#1088#1077#1076#1085#1086#1089#1090' '#1085#1072' '#1080#1084#1087#1091#1083#1089':'
  end
  object GroupBox: TGroupBox
    Left = 8
    Top = 72
    Width = 377
    Height = 129
    Caption = #1051#1086#1079#1080#1085#1082#1072
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object Label1: TLabel
      Left = 55
      Top = 28
      Width = 79
      Height = 13
      Caption = '&'#1057#1090#1072#1088#1072' '#1083#1086#1079#1080#1085#1082#1072':'
      FocusControl = StaraLozinka
    end
    object Label2: TLabel
      Left = 61
      Top = 59
      Width = 74
      Height = 13
      Caption = '&'#1053#1086#1074#1072' '#1051#1086#1079#1080#1085#1082#1072':'
      FocusControl = NovaLozinka1
    end
    object Label3: TLabel
      Left = 5
      Top = 91
      Width = 129
      Height = 13
      Caption = #1053'&'#1086#1074#1072' '#1083#1086#1079#1080#1085#1082#1072'('#1087#1088#1086#1074#1077#1088#1082#1072'):'
      FocusControl = NovaLozinka2
    end
    object StaraLozinka: TEdit
      Left = 136
      Top = 24
      Width = 146
      Height = 21
      PasswordChar = '*'
      TabOrder = 0
    end
    object NovaLozinka1: TEdit
      Left = 136
      Top = 56
      Width = 146
      Height = 21
      PasswordChar = '*'
      TabOrder = 1
    end
    object NovaLozinka2: TEdit
      Left = 136
      Top = 88
      Width = 146
      Height = 21
      PasswordChar = '*'
      TabOrder = 2
    end
    object Promeni: TBitBtn
      Left = 293
      Top = 16
      Width = 75
      Height = 105
      Caption = #1055'&'#1088#1086#1084#1077#1085#1080
      TabOrder = 3
      OnClick = PromeniClick
    end
  end
  object DBPath: TEdit
    Left = 120
    Top = 13
    Width = 285
    Height = 21
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object Prebaraj: TBitBtn
    Left = 413
    Top = 11
    Width = 60
    Height = 27
    Caption = '&'#1055#1088#1077#1073#1072#1088#1072#1112
    TabOrder = 3
    OnClick = PrebarajClick
  end
  object Zapamti: TBitBtn
    Left = 392
    Top = 48
    Width = 81
    Height = 153
    Caption = '&'#1047#1072#1087#1072#1084#1090#1080
    Default = True
    TabOrder = 4
    OnClick = ZapamtiClick
  end
  object Vrednost: TEdit
    Left = 120
    Top = 41
    Width = 113
    Height = 21
    TabOrder = 1
  end
end
