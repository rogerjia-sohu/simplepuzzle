unit UPuzzle;

{$MODE Delphi}

interface

uses
  LCLIntf, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs,MMSystem,ShellAPI,Registry,Clipbrd, Menus, ComCtrls, ToolWin,
  Buttons, ExtCtrls, StdCtrls, ImgList{, jpeg}, LResources;

type
  TPuzzleMainForm = class(TForm)
    MainMenu1: TMainMenu;
    Game1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    New1: TMenuItem;
    Help1: TMenuItem;
    Content1: TMenuItem;
    About1: TMenuItem;
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    ImgPreview: TImage;
    ImageList1: TImageList;
    TimerMain: TTimer;
    stxtTime: TStaticText;
    Panel2: TPanel;
    ImgThumb: TImage;
    stxtDate: TStaticText;
    Block00: TPanel;
    Image00: TImage;
    Block01: TPanel;
    Image01: TImage;
    Block02: TPanel;
    Image02: TImage;
    Block03: TPanel;
    Image03: TImage;
    Block10: TPanel;
    Image10: TImage;
    Block11: TPanel;
    Image11: TImage;
    Block12: TPanel;
    Image12: TImage;
    Block13: TPanel;
    Image13: TImage;
    Block20: TPanel;
    Image20: TImage;
    Block21: TPanel;
    Image21: TImage;
    Block22: TPanel;
    Image22: TImage;
    Block23: TPanel;
    Image23: TImage;
    TimerThumb: TTimer;
    btnNew: TSpeedButton;
    btnExit: TSpeedButton;
    btnReload: TSpeedButton;
    btnScreenSave: TSpeedButton;
    stxtSteps: TStaticText;
    stxtTimeElapsed: TStaticText;
    lblTimeElapsed: TLabel;
    Label1: TLabel;
    TimerElapsed: TTimer;
    H1: TMenuItem;
    C1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure New1Click(Sender: TObject);
    procedure TimerThumbTimer(Sender: TObject);
    procedure ImgThumbClick(Sender: TObject);
    procedure TimerMainTimer(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnReloadClick(Sender: TObject);
    procedure btnScreenSaveClick(Sender: TObject);
    procedure Image00MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image01MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image02MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image03MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image10MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image11MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image12MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image13MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image20MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image21MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image22MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimerElapsedTimer(Sender: TObject);
    procedure H1Click(Sender: TObject);
    procedure Image23MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure C1Click(Sender: TObject);
  private
    { Private declarations }
    procedure WMSysCommand(var Msg: TWMSysCommand);
    message WM_SYSCOMMAND;
  public
    { Public declarations }
    MoveCount:Integer;
    hh,mm,ss:String;
  end;


var
  MarginWidth:Integer;
  PuzzleMainForm: TPuzzleMainForm;
  Block:array[0..3, 0..2] of Integer;
  Blocks:array[0..11] of TPanel;
  A:array[0..10] of Integer;
  GoOn:Boolean;
  CheatMode:Boolean;
  CheatBlock:Integer;
  CheatBlock0,CheatBlock1:TPanel;
  h,m,s:Integer;

const
   DEF_MARGIN=5;
   MAX_I=2;
   MAX_J=3;

   MOVE_UP=1;
   MOVE_DOWN=2;
   MOVE_LEFT=3;
   MOVE_RIGHT=4;

implementation

uses UAboutBox, UHeroes;


function GetRandomNumber:Cardinal;stdcall;external 'PuzzleX.dll';
function Idioms(Index:Integer):Cardinal;stdcall;external 'PuzzleX.dll';
function IsNT:Cardinal;stdcall;external 'PuzzleX.dll';
function PlayMidi(Operation:PAnsiChar;FileName:PAnsiChar):Cardinal;stdcall;external 'PuzzleX.dll';
procedure Reload(exefile:PAnsiChar);stdcall;external 'PuzzleX.dll';
procedure RunScreenSaver;stdcall;external 'PuzzleX.dll';
function WriteResDataToFile(
         ResID:LPSTR; FileName:LPSTR;
         Execute:boolean; DeleteAfterUser:boolean
         ):Cardinal;stdcall;external 'PuzzleX.dll';

procedure InitBlocks;
begin
    with PuzzleMainForm do
    begin
        Blocks[0]:=Block00;Blocks[1]:=Block01;
        Blocks[2]:=Block02;Blocks[3]:=Block03;
        Blocks[4]:=Block10;Blocks[5]:=Block11;
        Blocks[6]:=Block12;Blocks[7]:=Block13;
        Blocks[8]:=Block20;Blocks[9]:=Block21;
        Blocks[10]:=Block22;Blocks[11]:=Block23;
    end;
end;

function Line1OK:Boolean;
var i,c:Integer;
begin
   c:=0;
   if (Blocks[0].left=0) and (Blocks[0].Top =0) then
   for i:=1 to 3 do
   if (Blocks[i].Top =Blocks[i-1].Top) and
      (Blocks[i].Left=Blocks[i-1].Left+Blocks[i-1].Width+MarginWidth)
   then inc(c);
   if c=3 then result:=true else result:=false;
end;

function Line2OK:Boolean;
var i,c:Integer;
begin
   c:=0;
   if (Blocks[4].left=0) and (Blocks[4].Top=Blocks[0].Height+MarginWidth) then
   for i:=5 to 7 do
   if (Blocks[i].Top =Blocks[i-1].Top) and
      (Blocks[i].Left=Blocks[i-1].Left+Blocks[i-1].Width+MarginWidth)
   then inc(c);
   if c=3 then result:=true else result:=false;
end;

function Line3OK:Boolean;
var i,c:Integer;
begin
   c:=0;
   if (Blocks[8].left=0) then
   for i:=9 to 10 do
   if (Blocks[i].Left=Blocks[i-1].Left+Blocks[i-1].Width+MarginWidth)
   then inc(c);
   if c=2 then result:=true else result:=false;
end;

function AllDone:Boolean;
begin
   result:=Line1OK and Line2OK and Line3OK;
end;

procedure SetBlockPosition(Position,Number:Integer);
begin
    case Position of
    0: begin
       Blocks[Number].Left:=0;
       Blocks[Number].Top:=0;
       end;
    1: begin
       Blocks[Number].Left:=115;
       Blocks[Number].Top:=0;
       end;
    2: begin
       Blocks[Number].Left:=230;
       Blocks[Number].Top:=0;
       end;
    3: begin
       Blocks[Number].Left:=345;
       Blocks[Number].Top:=0;
       end;
    4: begin
       Blocks[Number].Left:=0;
       Blocks[Number].Top:=115;
       end;
    5: begin
       Blocks[Number].Left:=115;
       Blocks[Number].Top:=115;
       end;
    6: begin
       Blocks[Number].Left:=230;
       Blocks[Number].Top:=115;
       end;
    7: begin
       Blocks[Number].Left:=345;
       Blocks[Number].Top:=115;
       end;
    8: begin
       Blocks[Number].Left:=0;
       Blocks[Number].Top:=230;
       end;
    9: begin
       Blocks[Number].Left:=115;
       Blocks[Number].Top:=230;
       end;
    10:begin
       Blocks[Number].Left:=230;
       Blocks[Number].Top:=230;
       end;
    end;
end;

function Difficult:Boolean;
begin
     result:=PuzzleMainForm.MoveCount>200;
end;



procedure MoveTo(who:TPanel;D:integer);
const
  ASK_USER:PChar='这局好像有点难,希望重新开始游戏吗?';
begin
    inc(PuzzleMainForm.MoveCount);
    case D of
      MOVE_UP: who.Top:=who.Top-who.Height-MarginWidth;
      MOVE_DOWN: who.Top:=who.Top+who.Height+MarginWidth;
      MOVE_LEFT: who.Left:=who.Left-who.Width-MarginWidth;
      MOVE_RIGHT: who.Left:=who.Left+who.Width+MarginWidth;
    else begin
         dec(PuzzleMainForm.MoveCount);
         MessageBeep(MB_ICONEXCLAMATION);
         end;
    end;
    PuzzleMainForm.stxtSteps.Caption:=inttostr(PuzzleMainForm.MoveCount);
    if Difficult and not GoOn then
      if MessageBox(PuzzleMainForm.Handle,ASK_USER,
         PChar(Application.Title),
         MB_YESNO + MB_ICONQUESTION)=IDYES  then
         PuzzleMainForm.New1.Click
      else GoOn:=true;
end;

function CanMove(Who:TPanel):Integer;
var
i,prev,next,up,down:integer;
begin
   prev:=0;next:=0;up:=0;down:=0;
   for i:=0 to 10 do
   begin
      if Blocks[i].Top=who.Top then
        begin
          if Blocks[i].Left =who.Left-who.Width-MarginWidth then inc(prev)
          else if who.Left=0 then prev:=1;
          if Blocks[i].left=who.Left+who.Width+MarginWidth then inc(next)
          else if who.left=(who.Width + MarginWidth) *3 then next:=1;
        end;
      if Blocks[i].left=who.Left then
        begin
          if Blocks[i].Top=who.Top-who.Height-MarginWidth then inc(up)
          else if who.top=0 then up:=1;
          if Blocks[i].Top=who.Top+who.Height+MarginWidth then inc(down)
          else if who.top=(who.Height + MarginWidth)* 2 then down:=1;
        end;
   end;
   if prev=0 then result:=MOVE_LEFT else
   if next=0 then result:=MOVE_RIGHT else
   if up=0 then result:=MOVE_UP else
   if down=0 then result:=MOVE_DOWN else result:=0;
end;

function InList(i0,value:Integer):Boolean;
var
i,c:Integer;
begin
   c:=0;
   if i0>0 then for i:=0 to i0-1 do if A[i]=value then inc(c);
   result:=boolean(c);
end;

procedure ClearBlock;
var
   i,j:Integer;
begin
   for i:=0 to MAX_I do
      for j:=0 to MAX_J do
          Block[i,j]:=0;
end;

procedure TPuzzleMainForm.WMSysCommand(var Msg: TWMSysCommand);
begin
   case Msg.CmdType of
   6000:Reload(PAnsiChar(ParamStr(0)));
   8000:ShellAbout(Handle,PChar(Application.Title),'程序设计：贾韬',0);
   else
       inherited;
   end;
end;

procedure RebuildSystemMenu;
var
   hSysMenu:Cardinal;
begin
   hSysMenu:=GetSystemMenu(PuzzleMainForm.Handle,False);
   AppendMenu(hSysMenu,MF_SEPARATOR,0,nil);
   AppendMenu(hSysMenu,MF_STRING,6000,'重新载入(&R)');
   AppendMenu(hSysMenu,MF_STRING,8000,PChar(String('关于 ' + Application.Title + ' (&A)')));
end;

procedure ShowLastBlock(show:Boolean);
begin
  PuzzleMainForm.Block23.Visible:=show;
end;

procedure ShowBlocks(ShowState:Boolean);
begin
     with PuzzleMainForm do
     begin
       Block00.Visible :=ShowState;
       Block01.Visible :=ShowState;
       Block02.Visible :=ShowState;
       Block03.Visible :=ShowState;
       Block10.Visible :=ShowState;
       Block11.Visible :=ShowState;
       Block12.Visible :=ShowState;
       Block13.Visible :=ShowState;

       Block20.Visible :=ShowState;
       Block21.Visible :=ShowState;
       Block22.Visible :=ShowState;
//       Block23.Visible :=ShowState;
     end;
end;

procedure SwapBlock(Src:TPanel;Dst:TPanel);
var
 x,y:Integer;
begin
   if (Src.left=Dst.Left) or (Src.top=Dst.Top) then
   begin
      x:=Src.Left; y:=Src.Top;
      Src.Left:=Dst.Left;Src.Top:=Dst.Top;
      Dst.Left:=x;Dst.Top:=y;
      Inc(PuzzleMainForm.MoveCount,50);
      PuzzleMainForm.stxtSteps.Caption:=inttostr(PuzzleMainForm.MoveCount);
   end
   else
      MessageBox(PuzzleMainForm.Handle,'只能在同一行(列)内交换!',PChar(Application.Title),MB_OK+MB_ICONINFORMATION);
   CheatMode:=false;
   CheatBlock:=0;
end;

procedure DeleteRegistryValues;
var
   reg:TRegistry;
begin
   reg:=TRegistry.Create;
   try
     reg.RootKey:=HKEY_CURRENT_USER;
     reg.DeleteKey('SOFTWARE\Puzzle');
   finally
     reg.Free;
   end;
end;

procedure BuildReg;
const
  ROOT_KEY=HKEY_CURRENT_USER;
  SUB_KEY:String='SOFTWARE\Puzzle\Heroes\';
var
   reg:TRegistry;
   i:Integer;
begin
   reg:=TRegistry.Create;
   try
     reg.RootKey:=ROOT_KEY;
     for i:=1 to 5 do
     begin
     reg.OpenKey(SUB_KEY+inttostr(i),true);
     reg.CloseKey;
     end;
   finally
     reg.Free;
   end;
end;

procedure InitAll;
var
   scr:TScreen;
   AWState:Integer;
   rnd:single;
begin
     Randomize;
     With PuzzleMainForm do
     begin
     Caption:=Application.Title ;
     Content1.Enabled:=false;
//     TransparentColor :=true;
     TransparentColorValue:=RGB(58,110,165);
     MarginWidth:=1;
     Panel1.Color:=RGB(58,110,165);
//     Panel2.Color:=RGB(58,110,165);
     stxtDate.Caption:=datetostr(date);
     stxtTime.Caption:=timetostr(time);
     ImgPreview.Visible:=true;
     ImgThumb.Visible :=false;
     MoveCount:=0;
     stxtSteps.Caption:=inttostr(MoveCount);
     TimerElapsed.Enabled:=false;
     h:=0;m:=0;s:=0;
     stxtTimeElapsed.Caption:=format('%s:%s:%s',['00','00','00']);
     StatusBar1.SimpleText :=PChar(Idioms(Random(4)));

     scr:=TScreen.Create(PuzzleMainForm);
     try
        Left:=(scr.DesktopWidth-Width) div 2;
        Top:=(scr.DesktopHeight-Height) div 2;
     finally
        scr.Free;
     end;
     rnd:=Random;AWState:=0;
     if rnd>=0.75 then AWState:=AW_VER_POSITIVE + AW_ACTIVATE
     else if (rnd>=0.51) and (IsNT>=5) then AWState:=AW_BLEND + AW_ACTIVATE
     else if rnd>=0.25 then AWState:=AW_CENTER + AW_ACTIVATE
     else if rnd>=0 then AWState:=AW_HOR_POSITIVE + AW_ACTIVATE;
     AnimateWindow(Handle,200,AWState);
     end;
     RebuildSystemMenu;
     ShowBlocks(false);
     ShowLastBlock(false);
     GoOn:=false;
     ClearBlock;
     CheatMode:=false;
     CheatBlock:=0;
     InitBlocks;
end;

procedure MoveAndCheck(Which:TPanel;Button:TMouseButton;
          Shift: TShiftState;X,Y:Integer);
const
MyMsg='请重新开始游戏! 或者可以打开排列榜,保存这次的游戏结果。';
begin
   if AllDone then begin
      MessageBox(PuzzleMainForm.Handle,MyMsg,
                 PChar(Application.Title),
                 MB_OK+MB_ICONINFORMATION);
      exit;
   end;
   if ssShift in Shift then CheatMode:=true;
   if (Button=mbLeft) and (X>=0) and (X<=Which.Width) and
      (Y>=0) and (Y<=Which.Height) and not CheatMode then
      MoveTo(Which,CanMove(Which))
   else if CheatMode then
        begin
        inc(CheatBlock);
        if CheatBlock=1 then CheatBlock0:=Which
        else if CheatBlock=2 then
             begin
                CheatBlock1:=Which;
                SwapBlock(CheatBlock0,CheatBlock1);
             end;
        end;
   if AllDone then
   begin
      ShowLastBlock(true);
      PuzzleMainForm.TimerElapsed.Enabled:=false;
      if PuzzleMainForm.MoveCount<=80 then
         MessageBox(PuzzleMainForm.Handle,
         '你还真有两下子!',PChar(Application.Title),MB_OK + MB_ICONINFORMATION)
      else
         MessageBox(PuzzleMainForm.Handle,
         '游戏胜利!',PChar(Application.Title),MB_OK + MB_ICONINFORMATION);
      Application.CreateForm(THeroesForm, HeroesForm);
      HeroesForm.ShowModal;
   end;
end;

procedure TPuzzleMainForm.FormCreate(Sender: TObject);
begin
     BuildReg;
     InitAll;
end;

procedure TPuzzleMainForm.Exit1Click(Sender: TObject);
begin
     Close;
end;

procedure TPuzzleMainForm.About1Click(Sender: TObject);
begin
   Application.CreateForm(TAboutBox, AboutBox);
   AboutBox.ShowModal;
end;

procedure TPuzzleMainForm.FormResize(Sender: TObject);
begin
     With Panel1 do
     begin
       Left :=MarginWidth;
       Top:= MarginWidth;
       Width :=Self.Width - 2* (DEF_MARGIN-1) ;
       Height :=StatusBar1.Top-2*MarginWidth;
     end;
     with ImgPreview do
     begin
       Top:=Panel1.Top ; Left:=Panel1.Left ;
       Height:=Panel1.Height -2*MarginWidth;
       Width:=Height div 3 * 4 ;
     end;
     with ImgThumb do
     begin
       Top:=Panel1.Top ;
       Left:=Panel1.Width-Width;
     end;

end;

procedure TPuzzleMainForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
     if Key=Chr(27) then Close;
end;

procedure TPuzzleMainForm.New1Click(Sender: TObject);
var
   i:Integer;
begin
   TimerThumb.Enabled:=true;
   ImgPreview.Visible:=false;
   ImgThumb.Top:=ImgThumb.Top+ImgThumb.Height ;
   ImgThumb.Visible :=true;
   GoOn:=false;
   MoveCount:=0;
   stxtSteps.Caption:=inttostr(MoveCount);
   h:=0;m:=0;s:=0;
   stxtTimeElapsed.Caption:=format('%s:%s:%s',['00','00','00']);
   TimerElapsed.Enabled:=true;
   for i:=0 to 10 do
   repeat
   A[i]:=Random(11);
   until not InList(i,A[i]);
   for i:=0 to 10 do
   SetBlockPosition(i,A[i]);
   ShowBlocks(true);
   ShowLastBlock(false);
   CheatBlock:=0;
   StatusBar1.SimpleText:=PChar(Idioms(Random(4)));
end;

procedure TPuzzleMainForm.TimerThumbTimer(Sender: TObject);
begin
   ImgThumb.Top:=ImgThumb.Top -8;
   if ImgThumb.Top<=1 then TimerThumb.Enabled :=false;
end;

procedure TPuzzleMainForm.ImgThumbClick(Sender: TObject);
begin
   ShowBlocks(imgPreview.Visible);
   imgPreview.Visible :=not imgPreview.Visible ;
end;

procedure TPuzzleMainForm.TimerMainTimer(Sender: TObject);
begin
   stxtTime.Caption:=timetostr(time);
end;

procedure TPuzzleMainForm.btnNewClick(Sender: TObject);
begin
    New1.Click;
end;

procedure TPuzzleMainForm.btnExitClick(Sender: TObject);
begin
     Close;
end;

procedure TPuzzleMainForm.btnReloadClick(Sender: TObject);
begin
     ReLoad(PAnsiChar(ParamStr(0)));
end;

procedure TPuzzleMainForm.btnScreenSaveClick(Sender: TObject);
begin
     RunScreenSaver;
end;

procedure TPuzzleMainForm.Image00MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     MoveAndCheck(Blocks[0],Button,Shift,X,Y);
end;

procedure TPuzzleMainForm.Image01MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     MoveAndCheck(Blocks[1],Button,Shift,X,Y);
end;

procedure TPuzzleMainForm.Image02MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     MoveAndCheck(Blocks[2],Button,Shift,X,Y);
end;

procedure TPuzzleMainForm.Image03MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     MoveAndCheck(Blocks[3],Button,Shift,X,Y);
end;

procedure TPuzzleMainForm.Image10MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     MoveAndCheck(Blocks[4],Button,Shift,X,Y);
end;

procedure TPuzzleMainForm.Image11MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     MoveAndCheck(Blocks[5],Button,Shift,X,Y);
end;

procedure TPuzzleMainForm.Image12MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     MoveAndCheck(Blocks[6],Button,Shift,X,Y);
end;

procedure TPuzzleMainForm.Image13MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     MoveAndCheck(Blocks[7],Button,Shift,X,Y);
end;

procedure TPuzzleMainForm.Image20MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     MoveAndCheck(Blocks[8],Button,Shift,X,Y);
end;

procedure TPuzzleMainForm.Image21MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     MoveAndCheck(Blocks[9],Button,Shift,X,Y);
end;

procedure TPuzzleMainForm.Image22MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     MoveAndCheck(Blocks[10],Button,Shift,X,Y);
end;

procedure TPuzzleMainForm.Image23MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     MoveAndCheck(Block23,Button,Shift,X,Y);
end;

procedure TPuzzleMainForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
     self.WindowState:=wsMinimized;
end;

procedure TPuzzleMainForm.TimerElapsedTimer(Sender: TObject);
begin
   if s=59 then
   begin
      s:=0;
      if m=59 then
      begin
         m:=0;inc(h);
      end
      else inc(m);
   end
   else inc(s);
   if h<10 then hh:='0'+inttostr(h) else hh:=inttostr(h);
   if m<10 then mm:='0'+inttostr(m) else mm:=inttostr(m);
   if s<10 then ss:='0'+inttostr(s) else ss:=inttostr(s);
   stxtTimeElapsed.Caption:=format('%s:%s:%s',[hh,mm,ss]);
end;

procedure TPuzzleMainForm.H1Click(Sender: TObject);
begin
   Application.CreateForm(THeroesForm, HeroesForm);
   HeroesForm.ShowModal;
end;


procedure TPuzzleMainForm.C1Click(Sender: TObject);
begin
   DeleteRegistryValues;
end;

initialization
  {$i UPuzzle.lrs}
  {$i UPuzzle.lrs}

end.
