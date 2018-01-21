unit UHeroes;

{$MODE Delphi}

interface

uses
  SysUtils, LCLIntf, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Buttons,Registry,Dialogs{, AppEvnts}, LResources;

type
  THeroesForm = class(TForm)
    BitBtn1: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    GroupBox1: TGroupBox;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl4: TLabel;
    lbl3: TLabel;
    lbl5: TLabel;
    Label4: TLabel;
    lblStep1: TLabel;
    lblStep2: TLabel;
    lblStep3: TLabel;
    lblStep4: TLabel;
    lblStep5: TLabel;
    lblTime1: TLabel;
    lblTime2: TLabel;
    lblTime3: TLabel;
    lblTime4: TLabel;
    lblTime5: TLabel;
    lblPlayer1: TLabel;
    lblPlayer2: TLabel;
    lblPlayer3: TLabel;
    lblPlayer4: TLabel;
    lblPlayer5: TLabel;
    ApplicationEvents1: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure ApplicationEvents1ShowHint(var HintStr: String;
      var CanShow: Boolean; var HintInfo: THintInfo);
  public
      Steps,TimeUsed,Players:array[1..5] of String;
  end;

const
   ROOT_KEY=HKEY_CURRENT_USER;
   SUB_KEY:String='Software\Puzzle\Heroes\';
var
  HeroesForm: THeroesForm;
  lblSteps,lblTime,lblPlayers:array[1..5] of TLabel;

implementation

uses UPuzzle;


function GameDone:Boolean;
begin
result:=(not PuzzleMainForm.TimerElapsed.Enabled) and (PuzzleMainForm.MoveCount>0);
end;

procedure LoadRegistryValues;
var
   reg:TRegistry;i:Integer;
begin
   reg:=TRegistry.Create;
   try
     with reg do begin
       RootKey:=ROOT_KEY;
       //LazyWrite:=false;
       for i:=1 to 5 do begin
         OpenKey(SUB_KEY + inttostr(i),true);
         HeroesForm.Steps[i]:=ReadString('Steps');
         if StrLen(PChar(HeroesForm.Steps[i]))=0 then begin
            WriteString('Steps',inttostr(i*40+Random(5)));
            HeroesForm.Steps[i]:=ReadString('Steps');
         end;
         HeroesForm.TimeUsed[i]:=ReadString('Time');
         if StrLen(PChar(HeroesForm.TimeUsed[i]))=0 then WriteString('Time','00:00:00');
         HeroesForm.Players[i]:=ReadString('Player');
         if StrLen(PChar(HeroesForm.Players[i]))=0 then WriteString('Player','未知');
         CloseKey;
       end;
     end;
   finally
      reg.Free;
   end;
end;

procedure UpdateHeroes(Position,Steps:Integer;TimeUsed,Player:String);
var
   reg:TRegistry;
begin
   reg:=TRegistry.Create;
   try
      with reg do begin
        RootKey:=ROOT_KEY;
        //LazyWrite:=false;
        OpenKey(SUB_KEY + inttostr(Position),true);
        WriteString('Player',Player);
        WriteString('Steps',inttostr(Steps));
        WriteString('Time',TimeUsed);
        CloseKey;
      end;
   finally
      reg.Free;
   end;
end;

procedure CheckHeroes;
var
   Step:Integer;
   Time,Player:String;
begin
   with PuzzleMainForm do begin
   Step:=MoveCount;
   Time:=Format('%s:%s:%s',[hh,mm,ss]);
   end;
   if (Step<=strtoint(HeroesForm.Steps[5])) and GameDone then begin
      Player:=InputBox('排列榜','输入姓名：    ','未知');
      if Step>strtoint(HeroesForm.Steps[4]) then begin
         UpdateHeroes(5,Step,Time,Player);
      end
      else if Step>strtoint(HeroesForm.Steps[3]) then begin
              UpdateHeroes(4,Step,Time,Player);
           end
      else if Step>strtoint(HeroesForm.Steps[2]) then begin
              UpdateHeroes(3,Step,Time,Player);
           end
      else if Step>strtoint(HeroesForm.Steps[1]) then begin
              UpdateHeroes(2,Step,Time,Player);
           end
      else begin
           UpdateHeroes(1,Step,Time,Player);
           end;
      LoadRegistryValues;
      end
   else
      if GameDone then
         MessageBox( PuzzleMainForm.Handle,
         '成绩不够理想,未能进入前五名!',
         PChar(Application.Title),MB_OK+MB_ICONEXCLAMATION);
end;

procedure InitLabels;
begin
   with HeroesForm do begin
     lblSteps[1]:=lblStep1;lblTime[1]:=lblTime1;lblPlayers[1]:=lblPlayer1;
     lblSteps[2]:=lblStep2;lblTime[2]:=lblTime2;lblPlayers[2]:=lblPlayer2;
     lblSteps[3]:=lblStep3;lblTime[3]:=lblTime3;lblPlayers[3]:=lblPlayer3;
     lblSteps[4]:=lblStep4;lblTime[4]:=lblTime4;lblPlayers[4]:=lblPlayer4;
     lblSteps[5]:=lblStep5;lblTime[5]:=lblTime5;lblPlayers[5]:=lblPlayer5;
   end;
end;

procedure ShowHeroes;
var i:integer;
begin
   for i:=1 to 5 do begin
      with HeroesForm do begin
      lblSteps[i].Caption:=Steps[i];
      lblTime[i].Caption:=TimeUsed[i];
      lblPlayers[i].Caption:=Players[i];
      end;
   end;
end;

procedure THeroesForm.FormCreate(Sender: TObject);
begin
   Randomize;
   self.Caption:=Application.Title+' 排列榜';
   InitLabels;
   LoadRegistryValues;
   CheckHeroes;
   ShowHeroes;
end;

procedure THeroesForm.BitBtn1Click(Sender: TObject);
begin
   Close;
end;

procedure THeroesForm.FormDeactivate(Sender: TObject);
begin
   close;
end;

procedure THeroesForm.ApplicationEvents1ShowHint(var HintStr: String;
  var CanShow: Boolean; var HintInfo: THintInfo);
begin
HintInfo.HintColor:=clAqua;
end;

initialization
  {$i UHeroes.lrs}
  {$i UHeroes.lrs}

end.
