object NaloziInsForm: TNaloziInsForm
  Left = 220
  Top = 179
  ActiveControl = StringGrid
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1053#1072#1083#1086#1079#1080
  ClientHeight = 321
  ClientWidth = 312
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
    Left = 9
    Top = 8
    Width = 293
    Height = 306
    BorderStyle = bsNone
    Color = clActiveBorder
    ColCount = 4
    DefaultRowHeight = 17
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing, goRowSelect, goThumbTracking]
    TabOrder = 0
    OnDrawCell = StringGridDrawCell
    OnKeyDown = StringGridKeyDown
  end
end
