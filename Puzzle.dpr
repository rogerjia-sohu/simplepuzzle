program Puzzle;

uses
  Forms,
  UPuzzle in 'UPuzzle.pas' {PuzzleMainForm},
  UAboutBox in 'UAboutBox.pas' {AboutBox},
  UHeroes in 'UHeroes.pas' {HeroesForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Simple Puzzle Game';
  Application.CreateForm(TPuzzleMainForm, PuzzleMainForm);
  Application.Run;
end.
