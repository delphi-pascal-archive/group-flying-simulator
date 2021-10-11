object Form1: TForm1
  Left = 226
  Top = 132
  Width = 467
  Height = 422
  Caption = 'Group flying simulator'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnClick = FormClick
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 120
  TextHeight = 16
  object Timer1: TTimer
    Interval = 25
    OnTimer = Timer1Timer
    Left = 16
    Top = 16
  end
end
