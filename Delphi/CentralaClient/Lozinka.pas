unit Lozinka;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TLozinkaForm = class(TForm)
    LozinkaLabel: TLabel;
    Lozinka: TEdit;
    LozinkaBitBtn: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LozinkaForm: TLozinkaForm;

implementation

{$R *.dfm}

end.
