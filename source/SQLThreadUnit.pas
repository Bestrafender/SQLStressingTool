unit SQLThreadUnit;

interface

uses
  Windows, Classes, SysUtils, Forms, ADODB, DB;

const
  ParamDirectionNames: array [TParameterDirection] of string =
    ('Unknown', 'Input', 'Output', 'InputOutput', 'ReturnValue');

type

  TSQLParameter = record
    Name: string;
    DataType: TFieldType;
    Direction: TParameterDirection;
    Value: string;
  end;

  TSQLParameters = array of TSQLParameter;

  TSQLThread = class(TThread)
  private
    FErrorMessage: String;
    { Private declarations }
  protected
    ThreadNumber: integer;
    Period: integer;
    DBConnection: TADOConnection;
    DBCommand: TADOCommand;
    SQLParameters: TSQLParameters;
    CommandText: String;
    TxStartTick: DWord;
    procedure Execute; override;
    procedure UpdateSpeed;
    procedure UpdateThreadCount;
  public
    constructor Create(AThreadNumber: integer; AConnectionString: string;
      ACommand: string; AParameters: TSQLParameters); reintroduce;
    destructor Destroy; override;
    property ErrorMessage: String read FErrorMessage;
  end;

implementation

uses
  MainFormUnit;

constructor TSQLThread.Create(AThreadNumber: integer;
  AConnectionString: string; ACommand: string; AParameters: TSQLParameters);
begin
  inherited Create(True);
  Self.FreeOnTerminate := True;

  Randomize;
  Period := 0;
  Self.ThreadNumber := AThreadNumber;
  Self.FErrorMessage := '';

  DBConnection := TADOConnection.Create(nil);
  DBConnection.ConnectionTimeout := 60; (* 1 min *)
  DBConnection.ConnectionString := AConnectionString;
  DBConnection.LoginPrompt := False;
  DBConnection.Open;

  CommandText := ACommand;

  SQLParameters := Copy(AParameters, 0, Length(AParameters));

  MainForm.ThreadCriticalSection.Acquire;
  Inc(MainForm.ThreadCount);
  MainForm.ThreadCriticalSection.Leave;
  Synchronize(UpdateThreadCount);
end;

destructor TSQLThread.Destroy;
begin
  DBConnection.Free;
  inherited;
end;

procedure TSQLThread.Execute;
var
  i: integer;
  GUID: TGUID;
begin
  try
    DBCommand := TADOCommand.Create(nil);
    try
      DBCommand.CommandTimeout := 600; (* 10 mins *)
      DBCommand.Connection := DBConnection;
      DBCommand.CommandText := CommandText;
      DBCommand.Parameters.ParseSQL(CommandText, True);
      while not Self.Terminated do
      begin
        for i := 0 to High(SQLParameters) do
        begin
          if (SQLParameters[i].Value = '<Random>') and
            (SQLParameters[i].Direction = TParameterDirection.pdInput) then
          begin
            if SQLParameters[i].DataType = ftInteger then
            begin
              DBCommand.Parameters.ParamByName(SQLParameters[i].Name)
                .Value := Round(Random(65535));
            end
            else
            begin
              CreateGUID(GUID);
              DBCommand.Parameters.ParamByName(SQLParameters[i].Name).Value :=
                GUIDToString(GUID);
            end;
          end
          else
          begin
            DBCommand.Parameters.ParamByName(SQLParameters[i].Name).Value :=
              SQLParameters[i].Value;
          end;
        end;

        TxStartTick := GetTickCount;

        DBCommand.Connection.BeginTrans;
        DBCommand.Execute;
        DBCommand.Connection.CommitTrans;

        Period := GetTickCount - TxStartTick;

        Synchronize(UpdateSpeed);
      end;

    finally
      DBCommand.Free;
      DBConnection.Close;
    end;
  except
    on E: Exception do
    begin
      Self.FErrorMessage := Format
        ('[ %d ] - %s', [Self.ThreadNumber, E.Message]);
      Self.Terminate;
    end;
  end;
end;

procedure TSQLThread.UpdateSpeed;
var
  ThreadData: PThreadData;
begin
  ThreadData := New(PThreadData);
  ThreadData^.ThreadNumber := ThreadNumber;
  ThreadData^.ThreadPeriod := Period;
  ThreadData^.ThreadTick := TxStartTick;
  MainForm.PeriodValues.Add(ThreadData);
  MainForm.Histogram.Series[0].YValue[ThreadNumber] := Period;
  MainForm.MinPeriod := Period;
  MainForm.MaxPeriod := Period;
  // MainForm.StatusBar1.Panels[2].Text := 'Run: ' + TimeToStr(Now);
end;

procedure TSQLThread.UpdateThreadCount;
begin
  MainForm.StatusBar1.Panels[0].Text := 'Tx: ' + IntToStr(MainForm.ThreadCount)
    + '/' + MainForm.NumThreadsEdit.Text;
  //Application.ProcessMessages;
end;

end.
