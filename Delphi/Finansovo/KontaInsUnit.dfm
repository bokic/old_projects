object KontaInsForm: TKontaInsForm
  Left = 266
  Top = 184
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1050#1086#1085#1090#1072
  ClientHeight = 301
  ClientWidth = 392
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
  object StringGrid: TStringGrid
    Left = 6
    Top = 8
    Width = 378
    Height = 288
    BorderStyle = bsNone
    Color = clActiveBorder
    ColCount = 3
    DefaultRowHeight = 17
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing, goRowSelect, goThumbTracking]
    TabOrder = 0
    OnDrawCell = StringGridDrawCell
    OnKeyDown = StringGridKeyDown
  end
end
