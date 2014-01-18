object KnizenjeInsForm: TKnizenjeInsForm
  Left = 196
  Top = 199
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1050#1085#1080#1078#1077#1114#1077
  ClientHeight = 320
  ClientWidth = 553
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 4
    Top = 8
    Width = 49
    Height = 13
    Caption = #1053#1072#1083#1086#1075' '#1073#1088':'
    FocusControl = ComboBox
  end
  object Date: TLabel
    Left = 168
    Top = 8
    Width = 201
    Height = 13
    AutoSize = False
  end
  object StringGrid: TStringGrid
    Left = 0
    Top = 32
    Width = 553
    Height = 270
    BorderStyle = bsNone
    Color = clBtnFace
    ColCount = 8
    DefaultRowHeight = 17
    Enabled = False
    FixedColor = clNone
    RowCount = 2
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing, goAlwaysShowEditor, goThumbTracking]
    ParentFont = False
    ParentShowHint = False
    PopupMenu = PopupMenu
    ShowHint = False
    TabOrder = 1
    OnDrawCell = StringGridDrawCell
    OnKeyDown = StringGridKeyDown
    OnKeyPress = StringGridKeyPress
    OnMouseMove = StringGridMouseMove
    OnSelectCell = StringGridSelectCell
  end
  object ComboBox: TComboBox
    Left = 56
    Top = 5
    Width = 105
    Height = 21
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 13
    ParentFont = False
    TabOrder = 0
    OnChange = ComboBoxChange
  end
  object DolziSuma: TStaticText
    Left = 302
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 2
  end
  object PobaruvaSuma: TStaticText
    Left = 393
    Top = 303
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0.00'
    TabOrder = 3
  end
  object VnesNal: TButton
    Left = 424
    Top = 6
    Width = 75
    Height = 20
    Caption = '&'#1053#1086#1074' '#1085#1072#1083#1086#1075
    TabOrder = 4
    TabStop = False
    OnClick = VnesNalClick
  end
  object PopupMenu: TPopupMenu
    OnPopup = PopupMenuPopup
    object Izmeni1: TMenuItem
      Caption = '&Izbrishi'
    end
  end
end
