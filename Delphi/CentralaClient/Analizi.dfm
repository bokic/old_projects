object AnaliziForm: TAnaliziForm
  Left = 277
  Top = 47
  HelpContext = 100
  BorderIcons = [biSystemMenu, biMinimize, biMaximize, biHelp]
  BorderStyle = bsDialog
  Caption = #1040#1085#1072#1083#1080#1079#1072
  ClientHeight = 490
  ClientWidth = 445
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object OdDatumLabel: TLabel
    Left = 64
    Top = 3
    Width = 54
    Height = 13
    Caption = #1054#1076' '#1044#1072#1090#1091#1084':'
    Font.Charset = DEFAULT_CHARSET
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
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object DBGrid: TDBGrid
    Left = 0
    Top = 80
    Width = 445
    Height = 373
    HelpContext = 504
    DataSource = DataSource
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [dgTitles, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
    ParentFont = False
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    Columns = <
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
        Width = 87
        Visible = True
      end
      item
        Alignment = taCenter
        Expanded = False
        FieldName = 'Lokalni'
        Title.Alignment = taCenter
        Title.Caption = #1051#1086#1082#1072#1083#1085#1080
        Title.Font.Charset = RUSSIAN_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'Tahoma'
        Title.Font.Style = []
        Width = 80
        Visible = True
      end
      item
        Alignment = taCenter
        Expanded = False
        FieldName = 'Nacionalni'
        Title.Alignment = taCenter
        Title.Caption = #1053#1072#1094#1080#1086#1085#1072#1083#1085#1080
        Title.Font.Charset = RUSSIAN_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'Tahoma'
        Title.Font.Style = []
        Width = 80
        Visible = True
      end
      item
        Alignment = taCenter
        Expanded = False
        FieldName = 'Internacionalni'
        Title.Alignment = taCenter
        Title.Caption = #1048#1085#1090#1077#1088#1085#1072#1094#1080#1086#1085'.'
        Title.Font.Charset = RUSSIAN_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'Tahoma'
        Title.Font.Style = []
        Width = 80
        Visible = True
      end
      item
        Alignment = taCenter
        Expanded = False
        FieldName = 'Vkupno'
        Title.Alignment = taCenter
        Title.Caption = #1042#1082#1091#1087#1085#1086
        Title.Font.Charset = RUSSIAN_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'Tahoma'
        Title.Font.Style = []
        Width = 98
        Visible = True
      end>
  end
  object OdDatum: TDateTimePicker
    Left = 0
    Top = 18
    Width = 186
    Height = 21
    HelpContext = 501
    Date = 37365.442991203700000000
    Time = 37365.442991203700000000
    DateFormat = dfLong
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnChange = OdDatumChange
  end
  object DoDatum: TDateTimePicker
    Left = 259
    Top = 18
    Width = 186
    Height = 21
    HelpContext = 502
    Date = 37365.442991203700000000
    Time = 37365.442991203700000000
    DateFormat = dfLong
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnChange = DoDatumChange
  end
  object Prebaraj: TBitBtn
    Left = 188
    Top = 16
    Width = 69
    Height = 25
    Caption = '&'#1055#1088#1077#1073#1072#1088#1072#1112
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = PrebarajClick
  end
  object DBLookupComboBox: TDBLookupComboBox
    Left = 192
    Top = 48
    Width = 145
    Height = 21
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    KeyField = 'Firma'
    ListField = 'Firma'
    ListSource = DataSource2
    ParentFont = False
    TabOrder = 4
    OnClick = DBLookupComboBoxClick
  end
  object CheckBox: TCheckBox
    Left = 117
    Top = 48
    Width = 68
    Height = 17
    Alignment = taLeftJustify
    Caption = '&'#1047#1072' '#1060#1080#1088#1084#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    OnClick = CheckBoxClick
  end
  object Pecati: TBitBtn
    Left = 366
    Top = 460
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
    TabOrder = 6
    OnClick = PecatiClick
  end
  object DenariBtn: TRadioButton
    Left = 112
    Top = 468
    Width = 105
    Height = 17
    Caption = #1042#1086' &'#1076#1077#1085#1072#1088#1080
    TabOrder = 7
    OnClick = DenariBtnClick
  end
  object ImpulsiBtn: TRadioButton
    Left = 8
    Top = 468
    Width = 105
    Height = 17
    Caption = #1042#1086' &'#1080#1084#1087#1091#1083#1089#1080
    Checked = True
    TabOrder = 8
    TabStop = True
    OnClick = ImpulsiBtnClick
  end
  object DataSource: TDataSource
    DataSet = ADOQuery
    Left = 64
  end
  object ADOQuery: TADOQuery
    Connection = ADOConnection
    CursorType = ctStatic
    OnCalcFields = ADOQueryCalcFields
    Parameters = <>
    SQL.Strings = (
      
        'SELECT MAIN.Lokal, Sum(IIf(Left$([TelefonskiBroj],1)<>'#39'0'#39',[Impul' +
        'si],0)) AS Lokalni, Sum(IIf(Left$([TelefonskiBroj],1)='#39'0'#39',IIf(Mi' +
        'd$([TelefonskiBroj],2,1)<>'#39'0'#39',[Impulsi],0),0)) AS Nacionalni, Su' +
        'm(IIf(Left$([TelefonskiBroj],2)='#39'00'#39',[Impulsi],0)) AS Internacio' +
        'nalni, Sum(MAIN.Impulsi) AS Vkupno'
      
        'FROM Firmi INNER JOIN (Lokali INNER JOIN MAIN ON Lokali.Lokal = ' +
        'MAIN.Lokal) ON Firmi.ID = Lokali.Firma'
      'GROUP BY MAIN.Lokal;')
    Left = 32
    object ADOQueryLokal: TWideStringField
      FieldName = 'Lokal'
      Size = 10
    end
    object ADOQueryLokalni: TFloatField
      FieldName = 'Lokalni'
    end
    object ADOQueryNacionalni: TFloatField
      FieldName = 'Nacionalni'
    end
    object ADOQueryInternacionalni: TFloatField
      FieldName = 'Internacionalni'
    end
    object ADOQueryVkupno: TFloatField
      FieldName = 'Vkupno'
    end
    object ADOQueryDenLokalni: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'DenLokalni'
      Calculated = True
    end
    object ADOQueryDenNacionalni: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'DenNacionalni'
      Calculated = True
    end
    object ADOQueryDenInternacionalni: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'DenInternacionalni'
      Calculated = True
    end
    object ADOQueryDenVkupno: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'DenVkupno'
      Calculated = True
    end
  end
  object ADOConnection: TADOConnection
    ConnectionString = 
      'Provider=Microsoft.Jet.OLEDB.4.0;Persist Security Info=False;Dat' +
      'a Source=Centrala.mdb;Mode=Read'
    LoginPrompt = False
    Provider = 'Microsoft.Jet.OLEDB.4.0'
  end
  object DataSource2: TDataSource
    DataSet = ADOTable
    Left = 64
    Top = 48
  end
  object ADOTable: TADOTable
    Connection = ADOConnection
    CursorType = ctStatic
    LockType = ltReadOnly
    TableDirect = True
    TableName = 'Firmi'
    Left = 32
    Top = 48
  end
end
