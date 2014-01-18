object ImportForm: TImportForm
  Left = 210
  Top = 126
  BorderStyle = bsDialog
  Caption = #1048#1084#1087#1086#1088#1090
  ClientHeight = 134
  ClientWidth = 240
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object DirectoryListBox: TDirectoryListBox
    Left = 8
    Top = 8
    Width = 145
    Height = 97
    ItemHeight = 16
    TabOrder = 0
    OnChange = DirectoryListBoxChange
  end
  object DriveComboBox: TDriveComboBox
    Left = 8
    Top = 112
    Width = 145
    Height = 19
    TabOrder = 1
    OnChange = DriveComboBoxChange
  end
  object Import: TButton
    Left = 160
    Top = 8
    Width = 75
    Height = 121
    Caption = '&'#1048#1084#1087#1086#1088#1090
    Default = True
    TabOrder = 2
    OnClick = ImportClick
  end
end
