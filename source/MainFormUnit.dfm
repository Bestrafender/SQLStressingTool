object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'SQL Stressing Tool'
  ClientHeight = 574
  ClientWidth = 794
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 555
    Width = 794
    Height = 19
    Panels = <
      item
        Width = 75
      end
      item
        Width = 150
      end
      item
        Width = 150
      end
      item
        Width = 50
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 794
    Height = 257
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      794
      257)
    object Bevel3: TBevel
      Left = 271
      Top = 8
      Width = 516
      Height = 249
      Anchors = [akLeft, akTop, akRight]
      Shape = bsFrame
      ExplicitWidth = 506
    end
    object Bevel1: TBevel
      Left = 8
      Top = 8
      Width = 257
      Height = 249
      Shape = bsFrame
    end
    object Bevel2: TBevel
      Left = 24
      Top = 72
      Width = 227
      Height = 85
      Shape = bsFrame
    end
    object Label1: TLabel
      Left = 24
      Top = 24
      Width = 88
      Height = 13
      Caption = 'Server\Instance : '
    end
    object Label2: TLabel
      Left = 56
      Top = 106
      Width = 58
      Height = 13
      Caption = 'Username : '
    end
    object Label3: TLabel
      Left = 58
      Top = 128
      Width = 56
      Height = 13
      Caption = 'Password : '
    end
    object Label4: TLabel
      Left = 26
      Top = 163
      Width = 56
      Height = 13
      Caption = 'Database : '
    end
    object Label5: TLabel
      Left = 288
      Top = 24
      Width = 82
      Height = 13
      Caption = 'Command Text : '
    end
    object ConnectivityLabel: TLabel
      Left = 61
      Top = 217
      Width = 21
      Height = 19
      Caption = 'OK'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      Visible = False
    end
    object WindowsAuthenticationCheckBox: TCheckBox
      Left = 34
      Top = 80
      Width = 161
      Height = 17
      Caption = 'Use Windows Authentication'
      TabOrder = 1
      OnClick = WindowsAuthenticationCheckBoxClick
    end
    object UsernameEdit: TEdit
      Left = 120
      Top = 103
      Width = 123
      Height = 21
      TabOrder = 2
      Text = 'Edit1'
      TextHint = 'Username'
      OnChange = ServerComboBoxChange
    end
    object PasswordEdit: TEdit
      Left = 120
      Top = 125
      Width = 123
      Height = 21
      PasswordChar = '*'
      TabOrder = 3
      Text = 'Edit1'
      TextHint = 'Password'
      OnChange = ServerComboBoxChange
    end
    object DatabaseComboBox: TComboBox
      Left = 26
      Top = 182
      Width = 225
      Height = 21
      Style = csDropDownList
      TabOrder = 4
      OnDropDown = DatabaseComboBoxDropDown
      OnSelect = DatabaseComboBoxSelect
    end
    object TestButton: TButton
      Left = 136
      Top = 217
      Width = 107
      Height = 25
      Caption = 'Test connectivity'
      TabOrder = 5
      OnClick = TestButtonClick
    end
    object Command: TMemo
      Left = 288
      Top = 43
      Width = 475
      Height = 62
      Lines.Strings = (
        'INSERT INTO SAMPLES VALUES ('
        ':ID,'
        ':DESC)')
      ScrollBars = ssVertical
      TabOrder = 6
      OnChange = CommandChange
    end
    object ParseButton: TButton
      Left = 288
      Top = 111
      Width = 107
      Height = 25
      Caption = 'Parse parameters'
      TabOrder = 7
      OnClick = ParseButtonClick
    end
    object ParamListView: TListView
      Left = 288
      Top = 142
      Width = 394
      Height = 100
      Columns = <
        item
          AutoSize = True
          Caption = 'Param Name'
        end
        item
          AutoSize = True
          Caption = 'Data Type'
        end
        item
          AutoSize = True
          Caption = 'Direction'
        end
        item
          AutoSize = True
          Caption = 'Value'
        end>
      Items.ItemData = {
        05E10000000400000000000000FFFFFFFFFFFFFFFF03000000FFFFFFFF000000
        000750006100720061006D00200031000749006E007400650067006500720000
        0000000749006E0062006F0075006E00640000000000083C00520061006E0064
        006F006D003E000000000000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF00
        0000000750006100720061006D002000320000000000FFFFFFFFFFFFFFFF0000
        0000FFFFFFFF000000000750006100720061006D002000330000000000FFFFFF
        FFFFFFFFFF00000000FFFFFFFF000000000750006100720061006D0020003400
        FFFFFFFFFFFF}
      ReadOnly = True
      RowSelect = True
      TabOrder = 8
      ViewStyle = vsReport
      OnDblClick = ParamListViewDblClick
    end
    object EditButton: TButton
      Left = 688
      Top = 142
      Width = 73
      Height = 25
      Caption = 'Edit'
      TabOrder = 9
      OnClick = EditButtonClick
    end
    object ServerComboBox: TComboBox
      Left = 24
      Top = 45
      Width = 227
      Height = 21
      TabOrder = 0
      Text = 'ServerComboBox'
      TextHint = 'ServerName\Instance'
      OnChange = ServerComboBoxChange
      OnDropDown = ServerComboBoxDropDown
    end
  end
  object Histogram: TChart
    Left = 0
    Top = 313
    Width = 619
    Height = 242
    Legend.Visible = False
    Title.Text.Strings = (
      'TChart')
    Title.Visible = False
    BottomAxis.Visible = False
    LeftAxis.Title.Caption = 'Transaction duration (ms)'
    View3D = False
    Align = alLeft
    BevelOuter = bvLowered
    TabOrder = 2
    ColorPaletteIndex = 15
    object Series1: TBarSeries
      BarPen.Color = clRed
      BarPen.SmallDots = True
      Marks.Arrow.Visible = True
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Arrow.Visible = True
      Marks.Callout.Length = 8
      Marks.Visible = False
      Title = 'Tx Duration (ms)'
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Bar'
      YValues.Order = loNone
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 257
    Width = 794
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
    object Bevel4: TBevel
      Left = 8
      Top = 6
      Width = 779
      Height = 42
      Shape = bsFrame
    end
    object Label7: TLabel
      Left = 216
      Top = 19
      Width = 78
      Height = 13
      Caption = 'Duration (min) : '
    end
    object Label6: TLabel
      Left = 24
      Top = 19
      Width = 49
      Height = 13
      Caption = 'Threads : '
    end
    object ExecuteButton: TBitBtn
      Left = 481
      Top = 15
      Width = 138
      Height = 25
      Caption = 'Run'
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 0
      OnClick = ExecuteButtonClick
    end
    object StopButton: TBitBtn
      Left = 625
      Top = 15
      Width = 138
      Height = 25
      Caption = 'Stop'
      Enabled = False
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 1
      OnClick = StopButtonClick
    end
    object DurationEdit: TEdit
      Left = 300
      Top = 14
      Width = 107
      Height = 21
      NumbersOnly = True
      TabOrder = 2
      Text = '1'
      TextHint = 'Execution duration'
    end
    object NumThreadsEdit: TEdit
      Left = 79
      Top = 14
      Width = 107
      Height = 21
      NumbersOnly = True
      TabOrder = 3
      Text = '128'
      TextHint = 'Number of threads'
    end
  end
  object Panel3: TPanel
    Left = 619
    Top = 313
    Width = 175
    Height = 242
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 4
    object Bevel6: TBevel
      Left = 6
      Top = 97
      Width = 163
      Height = 56
      Shape = bsFrame
    end
    object Label8: TLabel
      Left = 16
      Top = 6
      Width = 133
      Height = 13
      Caption = 'Transaction duration (ms) : '
    end
    object Label9: TLabel
      Left = 16
      Top = 25
      Width = 30
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Min : '
    end
    object Label10: TLabel
      Left = 16
      Top = 44
      Width = 30
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Avg : '
    end
    object Label11: TLabel
      Left = 16
      Top = 63
      Width = 30
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Max : '
    end
    object MinPeriodLabel: TLabel
      Left = 52
      Top = 25
      Width = 6
      Height = 13
      Caption = '0'
    end
    object MaxPeriodLabel: TLabel
      Left = 52
      Top = 63
      Width = 6
      Height = 13
      Caption = '0'
    end
    object AvgPeriodLabel: TLabel
      Left = 52
      Top = 44
      Width = 4
      Height = 13
      Caption = '-'
    end
    object Label12: TLabel
      Left = 16
      Top = 110
      Width = 119
      Height = 13
      Caption = 'Transaction per second :'
    end
    object Bevel5: TBevel
      Left = 6
      Top = 0
      Width = 163
      Height = 91
      Shape = bsFrame
    end
    object TransactionsLabel: TLabel
      Left = 16
      Top = 129
      Width = 145
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = '-'
    end
  end
  object DurationTimer: TTimer
    Enabled = False
    OnTimer = DurationTimerTimer
    Left = 416
    Top = 56
  end
  object DBConnection: TADOConnection
    ConnectionTimeout = 0
    Left = 496
    Top = 56
  end
  object MainMenu1: TMainMenu
    Left = 352
    Top = 416
    object Help1: TMenuItem
      Caption = '&Help'
      object About1: TMenuItem
        Caption = 'About...'
        OnClick = About1Click
      end
    end
  end
  object ProgressTimer: TTimer
    Enabled = False
    OnTimer = ProgressTimerTimer
    Left = 584
    Top = 56
  end
end
