object AnaliziPoDenoviForm: TAnaliziPoDenoviForm
  Left = 259
  Top = 44
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsSingle
  Caption = #1040#1085#1072#1083#1080#1079#1080' '#1087#1086' '#1076#1077#1085#1086#1074#1080
  ClientHeight = 487
  ClientWidth = 472
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
    Left = 336
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
  object DBChart: TDBChart
    Left = 8
    Top = 72
    Width = 457
    Height = 377
    BackWall.Brush.Color = clWhite
    BackWall.Brush.Style = bsClear
    BottomWall.Brush.Color = clWhite
    BottomWall.Pen.Color = clSilver
    LeftWall.Brush.Color = clSilver
    LeftWall.Pen.Color = clSilver
    PrintProportional = False
    Title.Font.Charset = RUSSIAN_CHARSET
    Title.Font.Color = clBlue
    Title.Font.Height = -11
    Title.Font.Name = 'Tahoma'
    Title.Font.Style = []
    Title.Text.Strings = (
      #1042#1088#1077#1084#1077#1085#1089#1082#1080' '#1076#1080#1072#1075#1088#1072#1084' '#1085#1072' '#1090#1088#1086#1096#1086#1082'.')
    Chart3DPercent = 5
    LeftAxis.Title.Caption = #1048#1084#1087#1091#1083#1089#1080
    LeftAxis.Title.Font.Charset = RUSSIAN_CHARSET
    LeftAxis.Title.Font.Color = clBlack
    LeftAxis.Title.Font.Height = -11
    LeftAxis.Title.Font.Name = 'Tahoma'
    LeftAxis.Title.Font.Style = []
    Legend.Visible = False
    View3D = False
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 4
    OnDblClick = DBChartDblClick
    object Series1: TLineSeries
      Marks.ArrowLength = 8
      Marks.Visible = False
      DataSource = ADOQuery
      SeriesColor = clRed
      Title = 'Main'
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.Visible = False
      XValues.DateTime = True
      XValues.Name = 'X'
      XValues.Multiplier = 1.000000000000000000
      XValues.Order = loAscending
      XValues.ValueSource = 'Datum'
      YValues.DateTime = False
      YValues.Name = 'Y'
      YValues.Multiplier = 1.000000000000000000
      YValues.Order = loNone
      YValues.ValueSource = 'Vkupno'
    end
  end
  object OdDatum: TDateTimePicker
    Left = 8
    Top = 18
    Width = 185
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
    Left = 280
    Top = 18
    Width = 185
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
    TabOrder = 1
    OnChange = DoDatumChange
  end
  object Prebaraj: TBitBtn
    Left = 200
    Top = 16
    Width = 73
    Height = 25
    Caption = '&'#1055#1088#1077#1073#1072#1088#1072#1112
    Default = True
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    OnClick = PrebarajClick
  end
  object Pecati: TBitBtn
    Left = 392
    Top = 457
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
  object DBLookupComboBox: TDBLookupComboBox
    Left = 192
    Top = 48
    Width = 145
    Height = 21
    Enabled = False
    KeyField = 'Firma'
    ListField = 'Firma'
    ListSource = DataSource2
    TabOrder = 3
    OnClick = DBLookupComboBoxClick
  end
  object CheckBox: TCheckBox
    Left = 117
    Top = 48
    Width = 68
    Height = 17
    Alignment = taLeftJustify
    Caption = '&'#1047#1072' '#1060#1080#1088#1084#1072
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = CheckBoxClick
  end
  object DenariBtn: TRadioButton
    Left = 112
    Top = 465
    Width = 105
    Height = 17
    Caption = #1042#1086' &'#1076#1077#1085#1072#1088#1080
    TabOrder = 7
    OnClick = DenariBtnClick
  end
  object ImpulsiBtn: TRadioButton
    Left = 8
    Top = 465
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
      
        'SELECT Round([Vreme]) AS Datum, Sum(MAIN.Impulsi) AS Vkupno FROM' +
        ' MAIN GROUP BY Round([Vreme]);')
    Left = 32
    object ADOQueryDatum: TDateTimeField
      FieldName = 'Datum'
    end
    object ADOQueryVkupno: TFloatField
      FieldName = 'Vkupno'
    end
    object ADOQueryDenVkupno: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'DenVkupno'
      Calculated = True
    end
  end
  object ADOConnection: TADOConnection
    ConnectionString = 
      'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=Centrala.mdb;Mode=R' +
      'ead;Persist Security Info=False'
    LoginPrompt = False
    Mode = cmRead
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
