unit UAboutBox;

{$MODE Delphi}

interface

uses
  SysUtils, LCLIntf, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms,ShellAPI,Registry,Dialogs{, Explform}, LResources;

type
  TAboutBox = class(TForm)
    btnOK: TButton;
    btnSysInfo: TButton;
    btnBugReport: TButton;
    ImgIcon: TImage;
    lblAppName: TLabel;
    lblVersion: TLabel;
    lblMyInfo: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnSysInfoClick(Sender: TObject);
    procedure btnBugReportClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  end;

var
  AboutBox: TAboutBox;

implementation

uses UPuzzle;


function AlphaBlendWindow(hWnd:Cardinal;Value:Byte):Cardinal;stdcall;external 'PuzzleX.dll';
function GetMyInfo:Cardinal;stdcall;external 'PuzzleX.dll';
//function LoWord(Value:dword):Cardinal;stdcall;external 'PuzzleX.dll';
function IsNT:Boolean;stdcall;external 'PuzzleX.dll';
function OSMajor:Integer;stdcall;external 'PuzzleX.dll';
function OSMinor:Integer;stdcall;external 'PuzzleX.dll';
function OSBuild:Integer;stdcall;external 'PuzzleX.dll';
function BugReport:Cardinal;stdcall;external 'PuzzleX.dll';
function PlayMidi(Operation:PAnsiChar;FileName:PAnsiChar):Cardinal;stdcall;external 'PuzzleX.dll';

procedure TAboutBox.FormShow(Sender: TObject);
begin
    btnOK.SetFocus;
//    PlayMidi('Play','bgsound.mid');
end;

procedure TAboutBox.btnSysInfoClick(Sender: TObject);
const
  ROOT_KEY=HKEY_LOCAL_MACHINE;
  SUB_KEY:String='SOFTWARE\Microsoft\Shared Tools\MSInfo';
  KEY_NAME:String='Path';
var
  reg:TRegistry;
  SysInfoExe:PChar;
  fd:WIN32_FIND_DATA;
  hFind:Cardinal;
begin
   reg:=TRegistry.Create;
   try
      with reg do
      begin
         RootKey:=ROOT_KEY;
         OpenKeyReadOnly(SUB_KEY);
         SysInfoExe:=PChar(ReadString(KEY_NAME));
      end;
   finally
      reg.Free;
   end;

   hFind:=FindFirstFile(SysInfoExe,fd);
   try
      if hFind=INVALID_HANDLE_VALUE then
         ShowMessage('System Information is not available at this time.')
      else
         WinExec(SysInfoExe,SW_SHOWMAXIMIZED);
   finally
      FindClose(hFind);
   end;
end;

procedure TAboutBox.btnBugReportClick(Sender: TObject);
begin
     BugReport;
end;

procedure TAboutBox.FormCreate(Sender: TObject);
const
  MSWIN='Microsoft Windows ';
var
  osv,Win:String;
  Major,Minor,Build:Cardinal;
begin
    self.Caption:='¹ØÓÚ ' + Application.Title;
    ImgIcon.Picture:=TPicture(Application.Icon);
    lblAppName.Caption:=Application.Title;
//    Self.Color:=RGB(58,110,165);
    Major:=OSMajor;Minor:=OSMinor;Build:=OSBuild;
    if IsNT then
       case Major of
         3,4:Win:=MSWIN+'NT';
         5: if Minor=0 then Win:=MSWIN+'2000' else Win:=MSWIN+'XP';
       end
    else
       if Major=4 then
          case Minor of
            0: Win:=MSWIN+'95';
            10:Win:=MSWIN+'98';
            90:Win:=MSWIN+'ME';
          end;
    osv:=format('%s %d.%d Build %d',[Win,Major,Minor,Build]);
    lblVersion.Caption:=osv;
    lblMyInfo.Caption:=PChar(GetMyInfo);
    AlphaBlendWindow(Self.Handle,Random(100)+156);
end;

procedure TAboutBox.FormPaint(Sender: TObject);
var r:TRect;
begin
    r:=GetClientRect;
    Ellipse(GetDC(Handle),r.Left,r.Top,r.Right,btnOK.Top-2);
end;

procedure TAboutBox.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//    PlayMidi('Stop','bgsound.mid');
end;

initialization
  {$i UAboutBox.lrs}
  {$i UAboutBox.lrs}

end.
