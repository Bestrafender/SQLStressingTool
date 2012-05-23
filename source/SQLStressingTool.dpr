program SQLStressingTool;

uses
  Forms,
  MainFormUnit in 'MainFormUnit.pas' {MainForm},
  SQLThreadUnit in 'SQLThreadUnit.pas',
  ParamFormUnit in 'ParamFormUnit.pas' {ParamForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TParamForm, ParamForm);
  Application.Run;
end.
