unit MainFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Buttons, SQLThreadUnit, SyncObjs,
  TeEngine, Series, TeeProcs, Chart, Controls, DB, ADODB, ADOInt, OLEDB,
  ActiveX, ComObj, Menus, Character, DateUtils, VclTee.TeeGDIPlus;

type
  TThreadData = record
    ThreadNumber: integer;
    ThreadPeriod: integer;
    ThreadTick: Cardinal;
  end;

  PThreadData = ^TThreadData;

  TMainForm = class(TForm)
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    Label1: TLabel;
    Bevel1: TBevel;
    WindowsAuthenticationCheckBox: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    UsernameEdit: TEdit;
    PasswordEdit: TEdit;
    DatabaseComboBox: TComboBox;
    Bevel2: TBevel;
    Label4: TLabel;
    TestButton: TButton;
    Bevel3: TBevel;
    Label5: TLabel;
    Command: TMemo;
    ParseButton: TButton;
    ParamListView: TListView;
    EditButton: TButton;
    Histogram: TChart;
    DurationTimer: TTimer;
    Series1: TBarSeries;
    ServerComboBox: TComboBox;
    DBConnection: TADOConnection;
    MainMenu1: TMainMenu;
    Help1: TMenuItem;
    About1: TMenuItem;
    ConnectivityLabel: TLabel;
    Panel2: TPanel;
    Bevel4: TBevel;
    ExecuteButton: TBitBtn;
    StopButton: TBitBtn;
    DurationEdit: TEdit;
    Label7: TLabel;
    NumThreadsEdit: TEdit;
    Label6: TLabel;
    ProgressTimer: TTimer;
    Panel3: TPanel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    MinPeriodLabel: TLabel;
    MaxPeriodLabel: TLabel;
    AvgPeriodLabel: TLabel;
    Label12: TLabel;
    Bevel5: TBevel;
    Bevel6: TBevel;
    TransactionsLabel: TLabel;
    procedure ExecuteButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure DurationTimerTimer(Sender: TObject);
    procedure WindowsAuthenticationCheckBoxClick(Sender: TObject);
    procedure TestButtonClick(Sender: TObject);
    procedure DatabaseComboBoxDropDown(Sender: TObject);
    procedure ServerComboBoxDropDown(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure DatabaseComboBoxSelect(Sender: TObject);
    procedure ServerComboBoxChange(Sender: TObject);
    procedure ParseButtonClick(Sender: TObject);
    procedure EditButtonClick(Sender: TObject);
    procedure CommandChange(Sender: TObject);
    procedure ParamListViewDblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ProgressTimerTimer(Sender: TObject);
  private
    StartTick, EndTick: Cardinal;
    SQLParameters: TSQLParameters;
    LogFileName: string;
    Log: TStringList;
    FErrorMessage: String;
    FHalted: Boolean;
    FCallStop: Boolean;
    FMinPeriod: Integer;
    FMaxPeriod: Integer;
    procedure OnSQLThreadDone(Sender: TObject);
    procedure SetMinPeriod(const Value: Integer);
    procedure SetMaxPeriod(const Value: Integer);
  public
    NumThreads: integer;
    ThreadCount: integer;
    Threads: array of TSQLThread;
    PeriodValues: TThreadList;
    ThreadCriticalSection: TCriticalSection;
    ConnectionString: string;
    property MinPeriod: Integer read FMinPeriod write SetMinPeriod;
    property MaxPeriod: Integer read FMaxPeriod write SetMaxPeriod;
  end;

var
  MainForm: TMainForm;

implementation

uses ParamFormUnit;
{$R *.dfm}

procedure TMainForm.WindowsAuthenticationCheckBoxClick(Sender: TObject);
begin
  UsernameEdit.Enabled := not WindowsAuthenticationCheckBox.Checked;
  PasswordEdit.Enabled := not WindowsAuthenticationCheckBox.Checked;
  ConnectivityLabel.Visible := False;
end;

procedure TMainForm.About1Click(Sender: TObject);
var
  Msg: string;
begin
  Msg := 'SQL Stressing Tool'#13#10 +
    'All rights reserved: Eduardo Gamboa ©2008-2014'#13#10 +
    #9'eduardo@bestrafender.com'#13#10 + #13#10'Powered by Delphi XE7 32-bit';
  Application.MessageBox(PChar(Msg), 'About...', MB_ICONINFORMATION);
end;

procedure TMainForm.CommandChange(Sender: TObject);
begin
  SetLength(SQLParameters, 0);
  ParamListView.Clear;
end;

procedure TMainForm.DatabaseComboBoxDropDown(Sender: TObject);
var
  rs: _RecordSet;
begin
  ConnectionString := 'Provider=SQLOLEDB.1;';
  if WindowsAuthenticationCheckBox.Checked then
    ConnectionString := ConnectionString +
      'Integrated Security=SSPI;Persist Security Info=False;'
  else
    ConnectionString := ConnectionString + 'Password=' + PasswordEdit.Text +
      ';Persist Security Info=True;User ID=' + UsernameEdit.Text + ';';
  ConnectionString := ConnectionString + 'Data Source=' + ServerComboBox.Text +
    ';';
  DBConnection.ConnectionString := Self.ConnectionString;
  try
    try
      Screen.Cursor := crHourGlass;
      DBConnection.LoginPrompt := False;
      DBConnection.Open;
      rs := DBConnection.ConnectionObject.OpenSchema
        (adSchemaCatalogs, EmptyParam, EmptyParam);
      DatabaseComboBox.Clear;
      while not rs.EOF do
      begin
        DatabaseComboBox.Items.Add(VarToStr(rs.Fields['CATALOG_NAME'].Value));
        rs.MoveNext;
      end;
    finally
      Screen.Cursor := crDefault;
      DBConnection.Close;
    end;
  except
    on E: Exception do
    begin
      Application.MessageBox(PChar(E.Message), 'Error', MB_ICONHAND);
    end;
  end;
end;

procedure TMainForm.DatabaseComboBoxSelect(Sender: TObject);
var
  p: integer;
begin
  p := Pos('Initial Catalog=', ConnectionString);
  if p > 0 then
    ConnectionString := Copy(ConnectionString, 0, p - 1);
  ConnectionString := ConnectionString + 'Initial Catalog=' +
    DatabaseComboBox.Text;
  ConnectivityLabel.Visible := False;
end;

procedure TMainForm.DurationTimerTimer(Sender: TObject);
begin
  StopButton.Click;
end;

procedure TMainForm.EditButtonClick(Sender: TObject);
begin
  if ParamListView.Selected <> nil then
  begin
    ParamForm.ParamNameLabel.Caption := ParamListView.Selected.Caption;
    ParamForm.DataTypeComboBox.ItemIndex :=
      ParamForm.DataTypeComboBox.Items.IndexOf
      (ParamListView.Selected.SubItems[0]);
    ParamForm.DirectionComboBox.ItemIndex :=
      ParamForm.DirectionComboBox.Items.IndexOf
      (ParamListView.Selected.SubItems[1]);
    ParamForm.ValueComboBox.Text := ParamListView.Selected.SubItems[2];
    if ParamForm.ShowModal = idOk then
    begin
      ParamListView.Selected.SubItems[0] := ParamForm.DataTypeComboBox.Text;
      if ParamListView.Selected.SubItems[0] = 'String' then
        SQLParameters[ParamListView.Selected.Index].DataType := ftString
      else
        SQLParameters[ParamListView.Selected.Index].DataType := ftInteger;

      ParamListView.Selected.SubItems[1] := ParamForm.DirectionComboBox.Text;
      if ParamListView.Selected.SubItems[1] = 'Input' then
        SQLParameters[ParamListView.Selected.Index].Direction := pdInput
      else
        SQLParameters[ParamListView.Selected.Index].Direction := pdOutput;

      ParamListView.Selected.SubItems[2] := ParamForm.ValueComboBox.Text;
      SQLParameters[ParamListView.Selected.Index].Value :=
        ParamForm.ValueComboBox.Text;
    end;
  end
  else
    Application.MessageBox('No parameter selected.', 'Edit Parameter',
      MB_ICONINFORMATION);
end;

procedure TMainForm.ExecuteButtonClick(Sender: TObject);
var
  i, TempValue: integer;
  List: TList;
begin
  ProgressTimer.Enabled := True;
  Histogram.Series[0].Clear;
  StatusBar1.Panels[0].Text := '';
  StatusBar1.Panels[1].Text := '';
  StatusBar1.Panels[2].Text := '';
  Self.FErrorMessage := '';
  Self.FHalted := False;
  Self.FCallStop := False;

  Self.FMinPeriod := 0;
  Self.FMaxPeriod := 0;
  Self.MinPeriodLabel.Caption := '0';
  Self.MaxPeriodLabel.Caption := '0';
  Self.AvgPeriodLabel.Caption := '-';
  Self.TransactionsLabel.Caption := '-';

  for i := 0 to High(SQLParameters) do
  begin
    if not(SQLParameters[i].DataType in [ftInteger, ftString]) then
    begin
      Application.MessageBox('At least one parameter is of an unknown type',
        'Parameters', MB_ICONHAND);
      exit;
    end;
    if (SQLParameters[i].Value <> '<Random>') and
      (SQLParameters[i].DataType = ftInteger) and not TryStrToInt
      (SQLParameters[i].Value, TempValue) then
    begin
      Application.MessageBox
        (PChar('The value defined for the parameter ''' + SQLParameters[i]
            .Name + ''' is not valid.'), 'Parameters', MB_ICONHAND);
      exit;
    end;
  end;

  Panel1.Enabled := False;
  NumThreadsEdit.Enabled := False;
  DurationEdit.Enabled := False;

  ExecuteButton.Enabled := False;

  List := PeriodValues.LockList;
  for i := 0 to List.Count - 1 do
  begin
    Dispose(List[i]);
    List[i] := nil;
  end;
  PeriodValues.UnlockList;

  PeriodValues.Clear;
  DurationTimer.Interval := StrToInt(DurationEdit.Text) * 60000;

  NumThreads := StrToInt(NumThreadsEdit.Text);
  SetLength(Threads, NumThreads);

  for i := 0 to NumThreads - 1 do
  begin
    Histogram.Series[0].AddY(0);
  end;

  for i := 0 to NumThreads - 1 do
  begin
    Threads[i] := TSQLThread.Create(i, ConnectionString, Command.Text,
      SQLParameters); {Thread is created suspended}
    Threads[i].OnTerminate := OnSQLThreadDone;
  end;
  for i := 0 to NumThreads - 1 do
  begin
    Threads[i].Start; {Start thread}
  end;
  StatusBar1.Panels[1].Text := 'Start: ' + TimeToStr(Now);
  StopButton.Enabled := True;
  DurationTimer.Enabled := True;
  StartTick := GetTickCount;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: integer;
  List: TList;
begin
  List := PeriodValues.LockList;
  for i := 0 to List.Count - 1 do
  begin
    Dispose(List[i]);
    List[i] := nil;
  end;
  PeriodValues.UnlockList;
  FreeAndNil(PeriodValues);
  ThreadCriticalSection.Free;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if idNo = Application.MessageBox('Are you sure you want to exit?', 'Exit',
    MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON2) then
  begin
    CanClose := False;
    exit;
  end;
  ThreadCriticalSection.Acquire;
  if ThreadCount > 0 then
  begin
    Application.MessageBox(
      'Application cannot exit because there are threads still running.',
      'Exit', MB_ICONINFORMATION);
    CanClose := False;
  end;
  ThreadCriticalSection.Leave;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  StartDateTime: TDateTime;
begin
  ThreadCount := 0;
  PeriodValues := TThreadList.Create;
  Histogram.Series[0].Clear;
  ThreadCriticalSection := TCriticalSection.Create;

  Self.FMinPeriod := 0;
  Self.FMaxPeriod := 0;
  Self.MinPeriodLabel.Caption := '0';
  Self.MaxPeriodLabel.Caption := '0';
  Self.AvgPeriodLabel.Caption := '-';
  Self.TransactionsLabel.Caption := '-';

  ServerComboBox.Items.Clear;
  ServerComboBox.Text := '';
  WindowsAuthenticationCheckBox.Checked := False;
  UsernameEdit.Text := '';
  PasswordEdit.Text := '';
  DatabaseComboBox.Items.Clear;
  DatabaseComboBox.Text := '';
  Command.Text := '';
  ParamListView.Items.Clear;
  StartDateTime := Now;
  LogFileName := Format('%4d%.2d%.2d%.2d%.2d%.2d', [YearOf(StartDateTime),
    MonthOf(StartDateTime), DayOf(StartDateTime), HourOf(StartDateTime),
    MinuteOf(StartDateTime), SecondOf(StartDateTime)]) + '_Log.csv';
  Log := TStringList.Create;
  Log.Add('Threads,Duration,AverageTime');
end;

procedure TMainForm.ParamListViewDblClick(Sender: TObject);
begin
  if ParamListView.Selected <> nil then
    EditButton.Click;
end;

procedure TMainForm.ParseButtonClick(Sender: TObject);
var
  i: integer;
  DBCommand: TADOCommand;
begin
  ParamListView.Clear;

  DBConnection.ConnectionString := ConnectionString;
  DBConnection.Open;

  DBCommand := TADOCommand.Create(nil);
  DBCommand.Connection := DBConnection;
  DBCommand.CommandText := Command.Text;
  DBCommand.Parameters.ParseSQL(DBCommand.CommandText, True);

  SetLength(SQLParameters, DBCommand.Parameters.Count);

  for i := 0 to DBCommand.Parameters.Count - 1 do
  begin
    with ParamListView.Items.Add do
    begin
      Caption := DBCommand.Parameters[i].Name;
      SQLParameters[i].Name := DBCommand.Parameters[i].Name;

      SubItems.Add(FieldTypeNames[DBCommand.Parameters[i].DataType]);
      SQLParameters[i].DataType := DBCommand.Parameters[i].DataType;

      SubItems.Add(ParamDirectionNames[DBCommand.Parameters[i].Direction]);
      SQLParameters[i].Direction := DBCommand.Parameters[i].Direction;

      SubItems.Add('<Random>');
      SQLParameters[i].Value := '<Random>';
    end;
  end;

  DBConnection.Close;
end;

procedure TMainForm.ProgressTimerTimer(Sender: TObject);
begin
  StatusBar1.Panels[2].Text := 'Run: ' + TimeToStr(Now);
end;

procedure TMainForm.ServerComboBoxChange(Sender: TObject);
begin
  ConnectivityLabel.Visible := False;
end;

procedure TMainForm.ServerComboBoxDropDown(Sender: TObject);
var
  RSCon: ADORecordsetConstruction;
  Rowset: IRowset;
  SourcesRowset: ISourcesRowset;
  SourcesRecordset: _RecordSet;
  SourcesName, SourcesType: TField;

  function PtCreateADOObject(const ClassID: TGUID): IUnknown;
  var
    Status: HResult;
    FPUControlWord: Word;
  begin
      asm
        FNSTCW FPUControlWord
      end
    ;
    Status := CoCreateInstance(CLASS_Recordset, nil,
      CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER, IUnknown, Result);
      asm
        FNCLEX
        FLDCW FPUControlWord
      end
    ;
    OleCheck(Status);
  end;

begin
  Screen.Cursor := crHourGlass;
  ServerComboBox.Items.Clear;
  SourcesRecordset := PtCreateADOObject(CLASS_Recordset) as _RecordSet;
  RSCon := SourcesRecordset as ADORecordsetConstruction;
  SourcesRowset := CreateComObject(ProgIDToClassID('SQLOLEDB Enumerator'))
    as ISourcesRowset;
  OleCheck(SourcesRowset.GetSourcesRowset(nil, IRowset, 0, nil, IUnknown(Rowset)
      ));
  RSCon.Rowset := Rowset;
  with TADODataSet.Create(nil) do
    try
      Recordset := SourcesRecordset;
      SourcesName := FieldByName('SOURCES_NAME');
      SourcesType := FieldByName('SOURCES_TYPE');
      ServerComboBox.Items.BeginUpdate;
      try
        while not EOF do
        begin
          if (SourcesType.AsInteger = DBSOURCETYPE_DATASOURCE) and
            (SourcesName.AsString <> '') then
            ServerComboBox.Items.Add(SourcesName.AsString);
          Next;
        end;
      finally
        ServerComboBox.Items.EndUpdate;
      end;
    finally
      Free;
      Screen.Cursor := crDefault;
    end;
end;

procedure TMainForm.SetMaxPeriod(const Value: Integer);
begin
  if Value = FMaxPeriod then
    exit;
  if (Value > FMaxPeriod) then
    FMaxPeriod := Value;
  MaxPeriodLabel.Caption := IntToStr(FMaxPeriod);
end;

procedure TMainForm.SetMinPeriod(const Value: Integer);
begin
  if Value = FMinPeriod then
    exit;
  if (FMinPeriod = 0) or (Value < FMinPeriod) then
    FMinPeriod := Value;
  MinPeriodLabel.Caption := IntToStr(FMinPeriod);
end;

procedure TMainForm.StopButtonClick(Sender: TObject);
var
  i: integer;
begin
  ProgressTimer.Enabled := False;
  EndTick := GetTickCount;
  StatusBar1.Panels[2].Text := 'End: ' + TimeToStr(Now);
  StopButton.Enabled := False;
  DurationTimer.Enabled := False;
  { TODO : Change: Threads termination method }
  // while IsMultiThread do
  // begin
  //
  // end;

  for i := 0 to NumThreads - 1 do
  begin
    if Threads[i] <> nil then
      Threads[i].Terminate;
  end;
end;

procedure TMainForm.TestButtonClick(Sender: TObject);
begin
  DBConnection.ConnectionString := ConnectionString;
  try
    try
      Screen.Cursor := crHourGlass;
      DBConnection.LoginPrompt := False;
      DBConnection.Open;
      Application.MessageBox('Connection successful', 'Connectivity Test',
        MB_ICONINFORMATION);
      ConnectivityLabel.Visible := True;
    finally
      Screen.Cursor := crDefault;
      DBConnection.Close;
    end;
  except
    on E: Exception do
    begin
      Application.MessageBox(PChar(E.Message), 'Error', MB_ICONHAND);
    end;
  end;
end;

procedure TMainForm.OnSQLThreadDone(Sender: TObject);
var
  i: integer;
  Avg: Extended;
  List: TList;
  Tick: Cardinal;
  DataCount: integer;
begin
  // ThreadCriticalSection.Acquire;
  Dec(ThreadCount);

  if ThreadCount = 0 then
  begin
    Avg := 0;
    DataCount := 0;

    List := PeriodValues.LockList;
    for i := 0 to List.Count - 1 do
    begin
      Tick := TThreadData(List[i]^).ThreadTick;
      if (StartTick <= Tick) and (Tick <= EndTick) then
      begin
        Inc(DataCount);
        Avg := Avg + TThreadData(List[i]^).ThreadPeriod;
      end;
    end;
    Avg := Avg / DataCount;
    PeriodValues.UnlockList;

    Self.AvgPeriodLabel.Caption := Format('%.2f',[Avg]);
    Self.TransactionsLabel.Caption := Format('%.2f', [1000 * NumThreads / Avg]);

    Log.Add(NumThreadsEdit.Text + ',' + DurationEdit.Text + ',' + FloatToStr
        (Avg));
    Log.SaveToFile(LogFileName);
    Application.MessageBox(PChar('Tx Avg Duration (ms) : ' + FloatToStr(Avg)),
      'Execution finished', MB_ICONINFORMATION);
    Application.MessageBox(PChar('Avg Speed (Tx/s) : ' + FloatToStr
          (1000 * NumThreads / Avg)), 'Execution finished', MB_ICONINFORMATION);
    if Self.FHalted then
      Application.MessageBox(PChar(Self.FErrorMessage),
        'Terminated due to an exception.', MB_ICONHAND);
    Panel1.Enabled := True;
    NumThreadsEdit.Enabled := True;
    DurationEdit.Enabled := True;
    ExecuteButton.Enabled := True;
  end
  else if Self.FCallStop then
  begin
    Self.FCallStop := False;
    StopButton.Click;
  end;
  StatusBar1.Panels[0].Text := 'Tx: ' + IntToStr(ThreadCount)
    + '/' + NumThreadsEdit.Text;
  if (TSQLThread(Sender).ErrorMessage <> '') and not Self.FHalted then
  begin
    Self.FErrorMessage := TSQLThread(Sender).ErrorMessage;
    Self.FHalted := True;
    Self.FCallStop := True;
  end;
  // ThreadCriticalSection.Leave;
end;

end.
