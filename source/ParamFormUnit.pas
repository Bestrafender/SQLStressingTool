unit ParamFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TParamForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Bevel1: TBevel;
    Label1: TLabel;
    ParamNameLabel: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    DataTypeComboBox: TComboBox;
    DirectionComboBox: TComboBox;
    ValueComboBox: TComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ParamForm: TParamForm;

implementation

{$R *.dfm}

end.
