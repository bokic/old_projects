object MainForm: TMainForm
  Left = 205
  Top = 177
  Caption = 'BokiC HTTP Server tester.. v1.0'
  ClientHeight = 375
  ClientWidth = 536
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object HostLabel: TLabel
    Left = 164
    Top = 20
    Width = 25
    Height = 13
    Caption = '&Host:'
    FocusControl = Address
  end
  object UpSplitter: TSplitter
    Left = 0
    Top = 105
    Width = 536
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object PortLabel: TLabel
    Left = 175
    Top = 44
    Width = 22
    Height = 13
    Caption = '&Port:'
    FocusControl = Port
  end
  object PaintBox1: TPaintBox
    Left = 0
    Top = 0
    Width = 536
    Height = 105
    Align = alTop
  end
  object PaintBox2: TPaintBox
    Left = 0
    Top = 244
    Width = 536
    Height = 131
    Align = alClient
  end
  object Splitter1: TSplitter
    Left = 0
    Top = 241
    Width = 536
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object Address: TEdit
    Left = 192
    Top = 16
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'localhost'
  end
  object Send: TButton
    Left = 216
    Top = 72
    Width = 75
    Height = 25
    Caption = '&Send'
    TabOrder = 2
    OnClick = SendClick
  end
  object Port: TEdit
    Left = 200
    Top = 40
    Width = 105
    Height = 21
    TabOrder = 1
    Text = '80'
  end
  object SendText: TMemo
    Left = 0
    Top = 108
    Width = 536
    Height = 133
    Align = alTop
    Lines.Strings = (
      'GET /PHP-PROEKT/test.pl HTTP/1.1'
      'Accept: */*'
      'Accept-Language: mk'
      'Accept-Encoding: gzip, deflate'
      'User-Agent: Mozilla/4.0'
      'Host: localhost:81'
      'Connection: Keep-Alive')
    ScrollBars = ssBoth
    TabOrder = 3
  end
  object ReciveText: TMemo
    Left = 0
    Top = 244
    Width = 536
    Height = 131
    Align = alClient
    ScrollBars = ssBoth
    TabOrder = 4
  end
  object TcpClient: TTcpClient
    RemotePort = '80'
    OnError = TcpClientError
  end
  object XPManifest1: TXPManifest
    Left = 32
  end
end
