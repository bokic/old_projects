object PregledForm: TPregledForm
  Left = 240
  Top = 47
  BorderIcons = [biSystemMenu, biMinimize, biMaximize, biHelp]
  BorderStyle = bsDialog
  Caption = #1055#1088#1077#1075#1083#1077#1076
  ClientHeight = 494
  ClientWidth = 445
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnHelp = FormHelp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object OdDatumLabel: TLabel
    Left = 64
    Top = 3
    Width = 54
    Height = 13
    Caption = #1054#1076' '#1044#1072#1090#1091#1084':'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object DoDatumLabel: TLabel
    Left = 304
    Top = 3
    Width = 53
    Height = 13
    Caption = #1044#1086' '#1044#1072#1090#1091#1084':'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object DBGrid: TDBGrid
    Left = 0
    Top = 52
    Width = 445
    Height = 405
    DataSource = DataSource
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [dgTitles, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
    ParentFont = False
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'Vreme'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Title.Alignment = taCenter
        Title.Caption = #1042#1088#1077#1084#1077
        Title.Font.Charset = RUSSIAN_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'Tahoma'
        Title.Font.Style = []
        Width = 125
        Visible = True
      end
      item
        Alignment = taCenter
        Expanded = False
        FieldName = 'Lokal'
        Title.Alignment = taCenter
        Title.Caption = #1051#1086#1082#1072#1083
        Title.Font.Charset = RUSSIAN_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'Tahoma'
        Title.Font.Style = []
        Width = 48
        Visible = True
      end
      item
        Alignment = taCenter
        Expanded = False
        FieldName = 'TelefonskiBroj'
        Title.Alignment = taCenter
        Title.Caption = #1058#1077#1083'. '#1073#1088#1086#1112
        Title.Font.Charset = RUSSIAN_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'Tahoma'
        Title.Font.Style = []
        Visible = True
      end
      item
        Alignment = taCenter
        Expanded = False
        FieldName = 'Denari'
        Title.Alignment = taCenter
        Title.Caption = #1048#1084#1087#1091#1083#1089#1080
        Title.Font.Charset = RUSSIAN_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'Tahoma'
        Title.Font.Style = []
        Visible = True
      end
      item
        Alignment = taCenter
        Expanded = False
        FieldName = 'Sekundi'
        Title.Alignment = taCenter
        Title.Caption = #1057#1077#1082#1091#1085#1076#1080
        Title.Font.Charset = RUSSIAN_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'Tahoma'
        Title.Font.Style = []
        Visible = True
      end>
  end
  object OdDatum: TDateTimePicker
    Left = 6
    Top = 18
    Width = 186
    Height = 21
    HelpContext = 501
    Date = 37365.442991203700000000
    Time = 37365.442991203700000000
    DateFormat = dfLong
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnChange = OdDatumChange
  end
  object DoDatum: TDateTimePicker
    Left = 254
    Top = 18
    Width = 186
    Height = 21
    HelpContext = 502
    Date = 37365.442991203700000000
    Time = 37365.442991203700000000
    DateFormat = dfLong
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnChange = DoDatumChange
  end
  object Filter: TBitBtn
    Left = 198
    Top = 16
    Width = 49
    Height = 25
    Caption = '&'#1060#1080#1083#1090#1077#1088
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = FilterClick
  end
  object Pecati: TBitBtn
    Left = 366
    Top = 464
    Width = 73
    Height = 25
    Caption = #1055'&'#1077#1095#1072#1090#1080
    Enabled = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnClick = PecatiClick
  end
  object ImpulsiBtn: TRadioButton
    Left = 8
    Top = 472
    Width = 105
    Height = 17
    Caption = #1042#1086' &'#1080#1084#1087#1091#1083#1089#1080
    Checked = True
    TabOrder = 5
    TabStop = True
    OnClick = ImpulsiBtnClick
  end
  object DenariBtn: TRadioButton
    Left = 112
    Top = 472
    Width = 105
    Height = 17
    Caption = #1042#1086' &'#1076#1077#1085#1072#1088#1080
    TabOrder = 6
    OnClick = DenariBtnClick
  end
  object ADOTable: TADOTable
    ConnectionString = 
      'Provider=Microsoft.Jet.OLEDB.4.0;Persist Security Info=False;Dat' +
      'a Source=Centrala.mdb;Mode=Read'
    CursorType = ctStatic
    Filtered = True
    LockType = ltReadOnly
    OnCalcFields = ADOTableCalcFields
    TableDirect = True
    TableName = 'Main'
    object ADOTableID: TIntegerField
      FieldName = 'ID'
    end
    object ADOTableRedBr: TIntegerField
      FieldName = 'RedBr'
    end
    object ADOTableVreme: TDateTimeField
      FieldName = 'Vreme'
    end
    object ADOTableLokal: TWideStringField
      FieldName = 'Lokal'
      Size = 10
    end
    object ADOTableTelefonskiBroj: TWideStringField
      FieldName = 'TelefonskiBroj'
    end
    object ADOTableImpulsi: TIntegerField
      FieldName = 'Impulsi'
    end
    object ADOTableSekundi: TIntegerField
      FieldName = 'Sekundi'
    end
    object ADOTableTip: TWideStringField
      FieldName = 'Tip'
      Size = 1
    end
    object ADOTableZabeleski: TWideStringField
      FieldName = 'Zabeleski'
      Size = 100
    end
    object ADOTableDenari: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'Denari'
      Calculated = True
    end
  end
  object DataSource: TDataSource
    AutoEdit = False
    DataSet = ADOTable
    Left = 32
  end
end
