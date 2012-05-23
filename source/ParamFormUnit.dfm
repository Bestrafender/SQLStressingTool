object ParamForm: TParamForm
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsDialog
  Caption = 'Parameter Properties'
  ClientHeight = 166
  ClientWidth = 251
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 233
    Height = 121
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 64
    Top = 24
    Width = 37
    Height = 13
    Caption = 'Name : '
  end
  object ParamNameLabel: TLabel
    Left = 107
    Top = 24
    Width = 69
    Height = 13
    Caption = 'Param name : '
  end
  object Label3: TLabel
    Left = 38
    Top = 48
    Width = 63
    Height = 13
    Caption = 'Data Type  : '
  end
  object Label4: TLabel
    Left = 49
    Top = 72
    Width = 52
    Height = 13
    Caption = 'Direction : '
  end
  object Label5: TLabel
    Left = 65
    Top = 96
    Width = 36
    Height = 13
    Caption = 'Value : '
  end
  object BitBtn1: TBitBtn
    Left = 85
    Top = 135
    Width = 75
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 0
  end
  object BitBtn2: TBitBtn
    Left = 166
    Top = 135
    Width = 75
    Height = 25
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 1
  end
  object DataTypeComboBox: TComboBox
    Left = 107
    Top = 45
    Width = 102
    Height = 21
    Style = csDropDownList
    TabOrder = 2
    Items.Strings = (
      'String'
      'Integer')
  end
  object DirectionComboBox: TComboBox
    Left = 107
    Top = 69
    Width = 102
    Height = 21
    Style = csDropDownList
    TabOrder = 3
    Items.Strings = (
      'Input'
      'Output')
  end
  object ValueComboBox: TComboBox
    Left = 107
    Top = 93
    Width = 102
    Height = 21
    TabOrder = 4
    TextHint = '<Param Value>'
    Items.Strings = (
      '<Random>')
  end
end
