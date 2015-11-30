// Copyright (C) 2015 Pavel V. Ozerski
// This software is licensed under GNU Lesser General Public license 3.
// See copying file
unit Unit1;
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons;
type
  TMemoStruct = class
    Memo: TMemo;
    Text: TStaticText;
    PlusBtn: TButton;
    constructor Create;
    destructor Destroy; override;
  end;

  { TMeaRuler_Form1 }

  TMeaRuler_Form1 = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    MemoPlusBtn: TButton;
    CancelLineButton: TButton;
    Button2: TButton;
    DefaultMemoButton: TButton;
    AngleModeCheckBox: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    AngleRGroup: TRadioGroup;
    MemoMinusBtn: TButton;
    StaticText1: TStaticText;
    Timer1: TTimer;
    procedure AngleModeCheckBoxChange(Sender: TObject);
    procedure AngleRGroupClick(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DefaultMemoButtonClick(Sender: TObject);
    procedure CancelLineButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure MemoMinusBtnClick(Sender: TObject);
    procedure MemoPlusBtnClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    Memos: array of TMemoStruct;
    DataIsDegrees: boolean;
    AngleRGroupPrevIndex: integer;
    procedure WriteXY(x, y: integer);
    procedure ButtonsOff;
    { public declarations }
  end;

var
  MeaRuler_Form1: TMeaRuler_Form1;

implementation

uses
  LCLIntf, LCLType, clipbrd, unit2;

{$R *.lfm}


{ TMeaRuler_Form1 }
procedure TMeaRuler_Form1.WriteXY(x, y: integer);
begin
  Label1.Caption := IntToStr(x) + ',' + IntToStr(y);
end;


procedure TMeaRuler_Form1.Button1Click(Sender: TObject);
begin
  MeaRuler_Form2.AngleCounter := 0;
  Label2.Caption:='';
  Hide;
  Button1.Enabled := false;
  Button2.Enabled := true;
  ButtonsOff;
  Timer1.Enabled := true;
end;

procedure TMeaRuler_Form1.Button10Click(Sender: TObject);
var
  max, i, x: integer;
  s: ansistring;
  procedure TryToAppend(var s: ansistring; M: array of TMemo; Idx: integer);
  var
    i: integer;
  begin
    for i := low(M) to high(M) do
      begin
        if Idx < M[i].Lines.Count then
          s := s + M[i].Lines[Idx];
        if i < high(M) then
          s := s + #9;
      end;
    while s <> '' do
      begin
        if s[length(s)] = #9 then
          delete(s, length(s), 1)
        else
          break;
      end;
    if s <> '' then
      s := s + #10;
  end;
var
  mm: array of TMemo;
begin
  SetLength(mm, 1);
  mm[0] := Memo1;
  for i := 0 to Length(Memos) - 1 do
    if Assigned(Memos[i]) then
      begin
        max := length(mm);
        SetLength(mm, max + 1);
        mm[max] := Memos[i].Memo;
      end;
  max := 0;
  for i := 0 to ControlCount - 1 do
    if Controls[i] is TMemo then
      begin
        x := TMemo(Controls[i]).Lines.Count;
        if x > max then
          max := x;
      end;
  s := '';
  for i := 0 to Max - 1 do
    TryToAppend(s, mm, i);
  Clipboard.AsText := s;
end;

procedure TMeaRuler_Form1.AngleModeCheckBoxChange(Sender: TObject);
var
  AngleCheckBoxWasChecked: boolean;
begin
  AngleCheckBoxWasChecked := AngleModeCheckBox.Checked;
  AngleRGroup.Enabled := AngleCheckBoxWasChecked;
end;

procedure TMeaRuler_Form1.AngleRGroupClick(Sender: TObject);
var
  s: string;
  i: integer;
  x: double;
begin
  if AngleRGroupPrevIndex <> AngleRGroup.ItemIndex then
    begin
      AngleRGroupPrevIndex := AngleRGroup.ItemIndex;
      if (Label2.Caption <> '0,00') and DataIsDegrees then
        begin
          s := Label2.Caption;
          if s <> '' then
            begin
              for i := 1 to length(s) do
                if s[i] = ',' then
                  begin
                    s[i] := '.';
                    break;
                  end;
              val(s, x, i);
              if i = 0 then
                begin
                  x := 360 - x;
                  str(x:0:2, s);
                  for i := 1 to length(s) do
                    if s[i] = '.' then
                      begin
                        s[i] := ',';
                        break;
                      end;
                    Label2.Caption := s;
                end;
            end;
        end;
    end;
end;

procedure TMeaRuler_Form1.ButtonsOff;
var
  i: integer;
begin
  DefaultMemoButton.Enabled := false;
  for i := 0 to ControlCount - 1 do
    if Controls[i] is TButton then
      if TButton(Controls[i]).Tag > 0 then
        TButton(Controls[i]).Enabled := false;
end;

procedure TMeaRuler_Form1.Button11Click(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to ControlCount - 1 do
    if Controls[i] is TMemo then
      TMemo(Controls[i]).Clear
    else if Controls[i] is TStaticText then
      TStaticText(Controls[i]).Caption := '0';
  Label2.Caption := '';
  ButtonsOff;
end;

procedure TMeaRuler_Form1.Button2Click(Sender: TObject);
begin
  MeaRuler_Form2.Hide;
  Button2.Enabled := false;
  Button1.Enabled := true;
end;

procedure TMeaRuler_Form1.DefaultMemoButtonClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to ControlCount - 1 do
    if controls[i] is TMemo then
      if Controls[i].Tag = TControl(Sender).Tag then
        begin
          TMemo(controls[i]).Append(Label2.Caption);
          Memo1Change(controls[i]);
          Label2.Caption:='';
          ButtonsOff;
          break;
        end;
end;

procedure TMeaRuler_Form1.CancelLineButtonClick(Sender: TObject);
begin
  MeaRuler_Form2.CancelLine;
end;

procedure TMeaRuler_Form1.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
var
  i: integer;
begin
  for i := 0 to length(Memos) - 1 do
    if assigned(Memos[i]) then
      Memos[i].Destroy;
end;

procedure TMeaRuler_Form1.FormCreate(Sender: TObject);
begin
  AngleRGroupPrevIndex := 0;
  DataIsDegrees := false;
  Memos := nil;
end;

procedure TMeaRuler_Form1.Memo1Change(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to ControlCount - 1 do
    if Controls[i] is TStaticText then
      if Controls[i].Tag = TControl(Sender).Tag then
        TStaticText(Controls[i]).Caption := IntToStr(TMemo(Sender).Lines.Count);
end;

procedure TMeaRuler_Form1.MemoMinusBtnClick(Sender: TObject);
var
  m: TMemoStruct;
  L: integer;
begin
  L := length(Memos);
  if L <= 1 then
    MemoMinusBtn.Enabled := false;
  if L = 0 then
    exit;
  dec(L);
  m := Memos[L];
  SetLength(Memos, L);
  m.Destroy;
end;

procedure TMeaRuler_Form1.MemoPlusBtnClick(Sender: TObject);
var
  x: integer;
begin
  x := length(Memos);
  SetLength(Memos, x + 1);
  Memos[x] := TMemoStruct.Create;
  MemoMinusBtn.Enabled := true;
end;

procedure TMeaRuler_Form1.Timer1Timer(Sender: TObject);
begin
  sleep(700);
  if not Visible then
    begin
      Timer1.Enabled:=false;
      MeaRuler_Form2.Show;
    end;
end;

constructor TMemoStruct.Create;
var
  i: integer;
  PrevMemo: TMemo;
  PrevTag: integer;
  PrevText: TStaticText;
  PrevPlusBtn: TButton;
begin
  PrevTag := -1;
  for i := 0 to MeaRuler_Form1.ControlCount - 1 do
    if MeaRuler_Form1.Controls[i] is TMemo then
      begin
        TMemo(MeaRuler_Form1.Controls[i]).Anchors := [akTop, akLeft, akBottom];
        if TMemo(MeaRuler_Form1.Controls[i]).Tag > PrevTag then
          begin
            PrevMemo := TMemo(MeaRuler_Form1.Controls[i]);
            PrevTag := TMemo(MeaRuler_Form1.Controls[i]).Tag;
          end
      end
    else if MeaRuler_Form1.Controls[i] is TStaticText then
      TStaticText(MeaRuler_Form1.Controls[i]).Anchors := [akTop,akLeft]
    else if MeaRuler_Form1.Controls[i] is TButton then
      begin
        if (TButton(MeaRuler_Form1.Controls[i]).Name = 'DefaultMemoButton') or
           (TButton(MeaRuler_Form1.Controls[i]).Tag > 0) then
          TButton(MeaRuler_Form1.Controls[i]).Anchors := [akLeft,akBottom];
      end;


  Memo := TMemo.Create(Mearuler_Form1);
  Memo.Left := PrevMemo.Left + PrevMemo.Width - 1;
  Memo.Width := PrevMemo.Width;
  Memo.Top := PrevMemo.Top;
  Memo.Height := PrevMemo.Height;
  Memo.TabOrder := PrevMemo.TabOrder + 1;
  Memo.Tag := PrevMemo.Tag + 1;
  Memo.ScrollBars := PrevMemo.ScrollBars;
  Memo.ParentFont := PrevMemo.ParentFont;
  Memo.Font.Height := PrevMemo.Font.Height;
  Memo.OnChange := @MeaRuler_Form1.Memo1Change;
  Mearuler_Form1.Width := Mearuler_Form1.Width + Memo.Width - 1;

  Text := TStaticText.Create(MeaRuler_Form1);
  Text.Tag := Memo.Tag;
  for i := 0 to MeaRuler_Form1.ControlCount - 1 do
    if MeaRuler_Form1.Controls[i] is TStaticText then
      if TStaticText(MeaRuler_Form1.Controls[i]).Tag = PrevMemo.Tag then
        begin
          PrevText := TStaticText(MeaRuler_Form1.Controls[i]);
          break;
        end;
  Text.Top := PrevText.Top;
  Text.Height := PrevText.Height;
  Text.Width := PrevText.Width;
  Text.Left := PrevText.Left + (Memo.Left - PrevMemo.Left);
  Text.TabOrder := PrevText.TabOrder + 1;
  Text.Caption := PrevText.Caption;

  PlusBtn := TButton.Create(MeaRuler_Form1);
  PlusBtn.Tag := Memo.Tag;
  if PlusBtn.Tag = 1 then
    PrevPlusBtn := Mearuler_Form1.DefaultMemoButton
  else
    for i := 0 to MeaRuler_Form1.ControlCount - 1 do
      if MeaRuler_Form1.Controls[i] is TButton then
        if TButton(MeaRuler_Form1.Controls[i]).Tag = PrevMemo.Tag then
          begin
            PrevPlusBtn := TButton(MeaRuler_Form1.Controls[i]);
            break;
          end;
  PlusBtn.Top := PrevPlusBtn.Top;
  PlusBtn.Height := PrevPlusBtn.Height;
  PlusBtn.Width := PrevPlusBtn.Width;
  PlusBtn.Left := PrevPlusBtn.Left + (Memo.Left - PrevMemo.Left);
  PlusBtn.TabOrder := PrevPlusBtn.TabOrder + 1;
  PlusBtn.Caption := PrevPlusBtn.Caption;
  PlusBtn.Enabled := PrevPlusBtn.Enabled;
  PlusBtn.OnClick := PrevPlusBtn.OnClick;

  Memo.Parent := Mearuler_Form1;
  Text.Parent := Mearuler_Form1;
  PlusBtn.Parent := Mearuler_Form1;

  for i := 0 to MeaRuler_Form1.ControlCount - 1 do
    if MeaRuler_Form1.Controls[i] is TMemo then
      TMemo(MeaRuler_Form1.Controls[i]).Anchors := [akTop, akRight, akBottom]
    else if MeaRuler_Form1.Controls[i] is TStaticText then
      TStaticText(MeaRuler_Form1.Controls[i]).Anchors := [akTop,akRight]
    else if MeaRuler_Form1.Controls[i] is TButton then
      begin
        if (TButton(MeaRuler_Form1.Controls[i]).Name = 'DefaultMemoButton') or
           (TButton(MeaRuler_Form1.Controls[i]).Tag > 0) then
          TButton(MeaRuler_Form1.Controls[i]).Anchors := [akRight,akBottom];
      end;
end;

destructor TMemoStruct.Destroy;
var
  w: integer;
  i: integer;
begin
  w := Memo.Width;
  Memo.Free;
  Text.Free;
  PlusBtn.Free;

  for i := 0 to MeaRuler_Form1.ControlCount - 1 do
    if MeaRuler_Form1.Controls[i] is TMemo then
      TMemo(MeaRuler_Form1.Controls[i]).Anchors := [akTop, akLeft, akBottom]
    else if MeaRuler_Form1.Controls[i] is TStaticText then
      TStaticText(MeaRuler_Form1.Controls[i]).Anchors := [akTop,akLeft]
    else if MeaRuler_Form1.Controls[i] is TButton then
      begin
        if (TButton(MeaRuler_Form1.Controls[i]).Name = 'DefaultMemoButton') or
           (TButton(MeaRuler_Form1.Controls[i]).Tag > 0) then
          TButton(MeaRuler_Form1.Controls[i]).Anchors := [akLeft,akBottom];
      end;

  MeaRuler_Form1.MemoPlusBtn.Anchors := [akTop,akLeft];
  MeaRuler_Form1.MemoMinusBtn.Anchors := [akTop,akLeft];

  MeaRuler_Form1.Width := MeaRuler_Form1.Width - w + 1;
  MeaRuler_Form1.MemoPlusBtn.Left := MeaRuler_Form1.MemoPlusBtn.Left - w;
  MeaRuler_Form1.MemoMinusBtn.Left := MeaRuler_Form1.MemoMinusBtn.Left - w;

  MeaRuler_Form1.MemoPlusBtn.Anchors := [akTop,akRight];
  MeaRuler_Form1.MemoMinusBtn.Anchors := [akTop,akRight];

  for i := 0 to MeaRuler_Form1.ControlCount - 1 do
    if MeaRuler_Form1.Controls[i] is TMemo then
      TMemo(MeaRuler_Form1.Controls[i]).Anchors := [akTop, akRight, akBottom]
    else if MeaRuler_Form1.Controls[i] is TStaticText then
      TStaticText(MeaRuler_Form1.Controls[i]).Anchors := [akTop,akRight]
    else if MeaRuler_Form1.Controls[i] is TButton then
      begin
        if (TButton(MeaRuler_Form1.Controls[i]).Name = 'DefaultMemoButton') or
           (TButton(MeaRuler_Form1.Controls[i]).Tag > 0) then
          TButton(MeaRuler_Form1.Controls[i]).Anchors := [akRight,akBottom];
      end;
end;

end.
