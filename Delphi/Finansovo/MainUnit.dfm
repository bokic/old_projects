object MainForm: TMainForm
  Left = 150
  Top = 107
  HorzScrollBar.Increment = 61
  Caption = #1060#1080#1085#1072#1085#1089#1086#1074#1086' '#1050#1085#1080#1075#1086#1074#1086#1076#1089#1090#1074#1086' '#1074'1.3 - default.knw'
  ClientHeight = 425
  ClientWidth = 630
  Color = clAppWorkSpace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIForm
  KeyPreview = True
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TStatusBar
    Left = 0
    Top = 406
    Width = 630
    Height = 19
    Panels = <
      item
        Bevel = pbNone
        BiDiMode = bdLeftToRight
        ParentBiDiMode = False
        Text = #1057#1087#1088#1077#1084#1085#1086
        Width = 550
      end
      item
        Width = 29
      end
      item
        Width = 33
      end
      item
        Width = 36
      end
      item
        Bevel = pbNone
        Width = 50
      end>
    ExplicitTop = 386
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 630
    Height = 22
    Color = clBtnFace
    DrawingStyle = dsGradient
    GradientEndColor = clBtnShadow
    Images = ImageList
    ParentColor = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    Transparent = False
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Hint = #1053#1086#1074#1080' '#1087#1086#1076#1072#1090#1086#1094#1080
      Action = New
      ImageIndex = 0
    end
    object ToolButton2: TToolButton
      Left = 23
      Top = 0
      Hint = #1054#1090#1074#1072#1088#1072#1114#1077' '#1085#1072' '#1087#1086#1089#1090#1086#1077#1095#1082#1072' '#1076#1072#1090#1086#1090#1077#1082#1072
      Action = Open
      ImageIndex = 1
    end
    object ToolButton3: TToolButton
      Left = 46
      Top = 0
      Hint = #1057#1085#1080#1084#1072#1114#1077' '#1074#1086' '#1076#1072#1090#1086#1090#1077#1082#1072
      Action = Save
      ImageIndex = 2
    end
    object ToolButton4: TToolButton
      Left = 69
      Top = 0
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 3
      Style = tbsSeparator
    end
    object ToolButton5: TToolButton
      Left = 77
      Top = 0
      Hint = #1055#1077#1095#1072#1090#1077#1114#1077
      Action = Print
      ImageIndex = 3
    end
    object ToolButton6: TToolButton
      Left = 100
      Top = 0
      Width = 8
      Caption = 'ToolButton6'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object ToolButton7: TToolButton
      Left = 108
      Top = 0
      Hint = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1080
      Action = About
      ImageIndex = 4
    end
  end
  object MainMenu: TMainMenu
    Images = ImageList
    Top = 24
    object File1: TMenuItem
      Caption = '&'#1055#1086#1076#1072#1090#1086#1094#1080
      object New1: TMenuItem
        Action = New
        Caption = '&'#1053#1086#1074#1080
        ImageIndex = 0
        ShortCut = 16462
      end
      object Open1: TMenuItem
        Action = Open
        Caption = '&'#1054#1090#1074#1086#1088#1080
        ImageIndex = 1
        ShortCut = 16463
      end
      object Save1: TMenuItem
        Action = Save
        Caption = '&'#1057#1085#1080#1084#1080
        ImageIndex = 2
        ShortCut = 16467
      end
      object SaveAs1: TMenuItem
        Action = SaveAs
        Caption = #1057#1085#1080#1084#1080' &'#1087#1086#1076' '#1080#1084#1077'..'
        ImageIndex = 2
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Import1: TMenuItem
        Action = Import
        Caption = '&'#1048#1084#1087#1086#1088#1090
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object Print1: TMenuItem
        Action = Print
        Caption = '&'#1055#1077#1095#1072#1090#1077#1114#1077
        ImageIndex = 3
        ShortCut = 16464
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = '&'#1048#1079#1083#1077#1079
        OnClick = Exit1Click
      end
    end
    object Insert1: TMenuItem
      Caption = '&'#1042#1085#1077#1089#1091#1074#1072#1114#1077
      object Knizenje1: TMenuItem
        Action = InsKnizenje
        Caption = '&'#1050#1085#1080#1078#1077#1114#1077
      end
      object Nalozi1: TMenuItem
        Action = InsNalozi
        Caption = '&'#1053#1072#1083#1086#1079#1080
      end
      object Komitenti1: TMenuItem
        Action = InsKomintenti
        Caption = #1050#1086'&'#1084#1080#1085#1090#1077#1085#1090#1080
      end
      object Konta1: TMenuItem
        Action = InsKonta
        Caption = #1050'&'#1086#1085#1090#1072
      end
    end
    object Documents: TMenuItem
      Caption = '&'#1044#1086#1082#1091#1084#1077#1085#1090#1080
      object Nalog: TMenuItem
        Action = DocNalog
        Caption = '&'#1053#1072#1083#1086#1075
      end
      object Nalozi: TMenuItem
        Action = DocNalozi
        Caption = #1053#1072#1083#1086'&'#1079#1080
      end
      object Analitika: TMenuItem
        Action = DocAnalitika
        Caption = '&'#1040#1085#1072#1083#1080#1090#1080#1082#1072
      end
      object BBilans: TMenuItem
        Action = DocBBilans
        Caption = '&'#1041#1041#1080#1083#1072#1085#1089
      end
      object ZakluchenList: TMenuItem
        Action = DocZList
        Caption = '&'#1047#1072#1082#1083#1091#1095#1077#1085' '#1083#1080#1089#1090
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Komitent: TMenuItem
        Action = DocKomintent
        Caption = '&'#1050#1086#1084#1080#1085#1090#1077#1085#1090
      end
      object KomitentKonto: TMenuItem
        Action = DocKomintenKonto
        Caption = '&'#1050#1086#1084#1080#1085#1090#1077#1085#1090'-'#1050#1086#1085#1090#1086
      end
      object KomitentiKonto: TMenuItem
        Action = DocKomintentiKonto
        Caption = #1050'&'#1086#1084#1080#1085#1090#1077#1085#1090#1080'-'#1050#1086#1085#1090#1086
      end
    end
    object Help: TMenuItem
      Caption = #1055'&'#1086#1084#1086#1096
      object About1: TMenuItem
        Action = About
        Caption = '&'#1048#1085#1092#1086
        ImageIndex = 4
      end
    end
  end
  object ActionList: TActionList
    Left = 32
    Top = 24
    object New: TAction
      Caption = '&New'
      OnExecute = NewExecute
      OnUpdate = NewUpdate
    end
    object Open: TAction
      Caption = '&Open'
      OnExecute = OpenExecute
      OnUpdate = OpenUpdate
    end
    object Save: TAction
      Caption = '&Save'
      OnExecute = SaveExecute
      OnUpdate = SaveUpdate
    end
    object SaveAs: TAction
      Caption = 'Save &As'
      OnExecute = SaveAsExecute
      OnUpdate = SaveAsUpdate
    end
    object Import: TAction
      Caption = '&Import'
      OnExecute = ImportExecute
      OnUpdate = ImportUpdate
    end
    object Print: TAction
      Caption = '&Print'
      OnExecute = PrintExecute
      OnUpdate = PrintUpdate
    end
    object InsKnizenje: TAction
      Caption = 'InsKnizenje'
      OnExecute = InsKnizenjeExecute
      OnUpdate = InsKnizenjeUpdate
    end
    object InsNalozi: TAction
      Caption = 'InsNalozi'
      OnExecute = InsNaloziExecute
      OnUpdate = InsNaloziUpdate
    end
    object InsKomintenti: TAction
      Caption = 'InsKomintenti'
      OnExecute = InsKomintentiExecute
      OnUpdate = InsKomintentiUpdate
    end
    object InsKonta: TAction
      Caption = 'InsKonta'
      OnExecute = InsKontaExecute
      OnUpdate = InsKontaUpdate
    end
    object DocNalog: TAction
      Caption = '&Nalog'
      OnExecute = DocNalogExecute
      OnUpdate = DocNalogUpdate
    end
    object DocNalozi: TAction
      Caption = 'DocNalozi'
      OnExecute = DocNaloziExecute
      OnUpdate = DocNaloziUpdate
    end
    object DocAnalitika: TAction
      Caption = 'DocAnalitika'
      OnExecute = DocAnalitikaExecute
      OnUpdate = DocAnalitikaUpdate
    end
    object DocBBilans: TAction
      Caption = 'DocBBilans'
      OnExecute = DocBBilansExecute
      OnUpdate = DocBBilansUpdate
    end
    object DocZList: TAction
      Caption = 'DocZList'
      OnExecute = DocZListExecute
      OnUpdate = DocZListUpdate
    end
    object DocKomintent: TAction
      Caption = 'DocKomintent'
      OnExecute = DocKomintentExecute
      OnUpdate = DocKomintentUpdate
    end
    object DocKomintenKonto: TAction
      Caption = 'DocKomintenKonto'
      OnExecute = DocKomintenKontoExecute
      OnUpdate = DocKomintenKontoUpdate
    end
    object DocKomintentiKonto: TAction
      Caption = 'DocKomintentiKonto'
      OnExecute = DocKomintentiKontoExecute
      OnUpdate = DocKomintentiKontoUpdate
    end
    object About: TAction
      Caption = '&About'
      OnExecute = AboutExecute
      OnUpdate = AboutUpdate
    end
  end
  object ImageList: TImageList
    AllocBy = 1
    Left = 64
    Top = 24
    Bitmap = {
      494C010105000900040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000003000000001002000000000000030
      000000000000000000000000000000000000C6C6C600FFFFFF00DEDEDE00C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000C6C6C60000000000C6C6C60000000000C6C6C60000000000C6C6C600C6C6
      C600C6C6C60000000000C6C6C60000000000C6C6C600C6C6C600C6C6C6000000
      0000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60000000000C6C6C600C6C6
      C60000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C6008484840000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600000000000000000000000000C6C6C600C6C6C600C6C6
      C60000000000C6C6C600C6C6C60000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000C6C6C60000000000C6C6
      C600C6C6C600C6C6C60000000000C6C6C6000000000000000000C6C6C600C6C6
      C60000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60000000000C6C6
      C60000000000C6C6C600C6C6C600C6C6C60000000000C6C6C60000000000C6C6
      C600C6C6C600C6C6C60000000000C6C6C6000000000000000000C6C6C600C6C6
      C60000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60000000000C6C6
      C60000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600000000000000
      000000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF00DEDE
      DE00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600000000000000
      000000000000C6C6C600C6C6C600C6C6C600FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF00DEDE
      DE00C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C600C6C6C600848484000000
      0000FFFFFF00DEDEDE00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      000000000000C6C6C600C6C6C600C6C6C6000000000000000000C6C6C600C6C6
      C60000000000C6C6C600C6C6C60000000000C6C6C600C6C6C600848484000000
      0000FFFFFF00DEDEDE00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      000000000000C6C6C600C6C6C600C6C6C6000000000000000000C6C6C600C6C6
      C60000000000C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6
      C60000000000C6C6C600C6C6C6000000000000000000FFFFFF00DEDEDE00C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60000000000C6C6C6000000
      0000C6C6C600C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6
      C60000000000C6C6C600C6C6C60000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00DEDEDE00C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60000000000C6C6C6000000
      0000C6C6C600C6C6C600C6C6C60000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C60000000000000000000000
      0000C6C6C600C6C6C600C6C6C6000000000000000000C6C6C600C6C6C600C6C6
      C6000000000000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      840000000000FFFFFF00DEDEDE00C6C6C600C6C6C60000000000000000000000
      0000C6C6C600C6C6C600C6C6C6000000000000000000C6C6C600C6C6C600C6C6
      C6000000000000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      840000000000FFFFFF00DEDEDE00C6C6C600C6C6C600C6C6C600000000000000
      0000C6C6C600C6C6C6000000000000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C60000000000C6C6C600C6C6C60000000000C6C6C600C6C6C600000000000000
      0000C6C6C600C6C6C6000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C60000000000C6C6C600C6C6C60000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C60000000000C6C6C6000000
      0000C6C6C600C6C6C600C6C6C600C6C6C6000000000000000000000000000000
      0000C6C6C600C6C6C60000000000000000000000000000000000C6C6C6000000
      0000C6C6C6000000000000000000C6C6C600C6C6C60000000000C6C6C6000000
      0000C6C6C600C6C6C600C6C6C600C6C6C6000000000000000000000000000000
      0000C6C6C600C6C6C60000000000000000000000000000000000C6C6C6000000
      0000C6C6C6000000000000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C6000084840000848400008484000084
      840000848400008484000084840000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C600C6C6C600C6C6C6000000
      0000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C60084848400C6C6C60000000000C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C60084848400FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000000000000084840000848400FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000FFFFFF0000000000008484000084840000848400008484000084
      84000084840000848400008484000084840000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C60000000000C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C60000000000C6C6C600C6C6C6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C60000000000C6C6C60000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C60000000000C6C6C60000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C6008484840000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000FFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF0000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000FFFFFF0000FFFF00FFFFFF000000000000848400008484000084
      840000848400008484000084840000848400008484000084840000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000C6C6C600C6C6C6000000
      0000C6C6C600C6C6C600C6C6C6000000000000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C60000000000C6C6C6000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF0000000000000000000000
      000000000000000000000000000000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60000000000C6C6
      C600C6C6C600C6C6C600C6C6C6008484840000000000FFFFFF00DEDEDE00C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60000000000C6C6
      C600C6C6C600C6C6C600C6C6C6008484840000000000FFFFFF00DEDEDE00C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C6000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF0000000000000000000000
      000000000000000000000000000000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000FFFF00FFFFFF0000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF0000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C60000000000C6C6C6000000000000000000000000000000
      000000000000000000000000000000FFFF000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600C6C6C60000000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C60000000000C6C6C600C6C6C60000000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600000000000000000000000000000000000000
      000000000000000000000000000000FFFF000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600C6C6C600C6C6C6000000
      0000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000FFFF00FFFFFF0000FFFF000000000000000000000000000000
      000000000000000000000000000000FFFF000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF0000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000FFFFFF0000FFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000C6C6C600C6C6C600C6C6C600C6C6C6000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF0000000000000000000000
      000000000000000000000000000000000000C6C6C600C6C6C600C6C6C6000000
      0000C6C6C600C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60000000000C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000C6C6C600C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60000000000C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C6000000000000000000000000000000
      00000000000000000000000000000000000000FFFF0000FFFF00000000000000
      000000000000000000000000000000000000C6C6C600C6C6C60000000000C6C6
      C600C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6C60000000000C6C6
      C600C6C6C60000000000C6C6C60000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      000000FFFF000000000000000000000000000000000000FFFF0000FFFF000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C600FFFFFF00DEDEDE00C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60000000000C6C6
      C600C6C6C600C6C6C60000000000C6C6C6000000000000000000000000000000
      000000FFFF00000000000000000000000000000000000000000000FFFF000000
      00000000000000000000000000000000000000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000C6C6C600C6C6C600C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000C6C6C600C6C6C600C6C6C600C6C6C6000000000000000000000000000000
      000000FFFF0000FFFF0000000000000000000000000000FFFF0000FFFF000000
      000000000000000000000000000000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C6008484840000000000FFFFFF00DEDEDE00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      00000000000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF00000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C600C6C6C60000000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484840000000000FFFF
      FF00DEDEDE00C6C6C600C6C6C600C6C6C6000000000000000000000000000000
      0000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484840000000000FFFF
      FF00DEDEDE00C6C6C600C6C6C600C6C6C6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000084
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000084840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000008484000084
      8400008484000084840000848400008484000084840000848400008484000000
      0000000000000000000000000000000000000000000000000000008484000084
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000084840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00000000000084
      8400008484000084840000848400008484000084840000848400008484000084
      8400000000000000000000000000000000000000000000000000008484000084
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000084840000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF0000FFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000FFFF00FFFFFF000000
      0000008484000084840000848400008484000084840000848400008484000084
      8400008484000000000000000000000000000000000000000000008484000084
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000084840000000000000000000000000000000000000000000000
      0000000000000000000000000000848484008484840084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF00000000000084840000848400008484000084840000848400008484000084
      8400008484000084840000000000000000000000000000000000008484000084
      8400008484000084840000848400008484000084840000848400008484000084
      8400008484000084840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000084
      8400000000000000000000000000000000000000000000000000000000000000
      0000008484000084840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000084840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00000000000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000008484000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000084840000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000084840000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000300000000100010000000000800100000000000000000000
      000000000000000000000000FFFFFF0074696F6E275374727970655F66756E63
      537472427974655442797465547970656653697A65537472696F6E5374724275
      6F635F66756E63746F63537472416C6C6E65537472416C6C61696768742D6C69
      31537472327374726E6753747253747272657373746F7269746F72657353746F
      726F634E616D65733153746F72656450FFFF656450726F63FFFF50726F635374
      FE3F667353746F72FC1F6453746F7265FC1F72747973746FFE7F6F6D7050726F
      FC3F6E7353746F72FC3F6F7265436F6CFC3F6553746F7265FC1F666163657374
      F20F616765496E74E107726167655374E187697A696E6773E0076F707353746F
      F00F6753746F7073F81F6473746F7070FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFC001C007E003001F8031BFEBE003000F80310005E003000780317E31
      E003000380017E35E003000180010006E003000180017FEAE003001F8FF18014
      E003001F8FF1C00AE003001F8FF1E001E0038FF18FF1E007E007FFF98FF1F007
      E00FFF758FF5F003E01FFF8F8001F80300000000000000000000000000000000
      000000000000}
  end
  object OpenDialog: TOpenDialog
    FileName = '*.knw'
    Filter = #1060#1080#1085#1072#1085#1089#1086#1074#1086' '#1050#1085#1080#1075#1086#1074#1086#1076#1089#1090#1074#1086'|*.knw'
    Left = 96
    Top = 24
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'knw'
    Filter = #1060#1080#1085#1072#1085#1089#1086#1074#1086' '#1050#1085#1080#1075#1086#1074#1086#1076#1089#1090#1074#1086'|*.knw'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist]
    Left = 128
    Top = 24
  end
  object XPManifest: TXPManifest
    Left = 160
    Top = 24
  end
end
