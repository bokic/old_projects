object MainForm: TMainForm
  Left = 192
  Top = 107
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1041#1098#1083#1075#1072#1088#1089#1082#1080' '#1088#1077#1095#1085#1080#1082
  ClientHeight = 261
  ClientWidth = 395
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ComboBox: TComboBox
    Left = 0
    Top = 8
    Width = 385
    Height = 21
    ItemHeight = 13
    TabOrder = 0
  end
  object LeftList: TListBox
    Left = 8
    Top = 40
    Width = 185
    Height = 211
    ItemHeight = 13
    TabOrder = 1
    OnClick = LeftListClick
  end
  object RightList: TListBox
    Left = 200
    Top = 40
    Width = 185
    Height = 211
    ItemHeight = 13
    TabOrder = 2
  end
  object XPManifest1: TXPManifest
  end
end
