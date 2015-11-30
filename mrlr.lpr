// Copyright (C) 2015 Pavel V. Ozerski
// This software is licensed under GNU Lesser General Public license 3.
// See copying file

program mrlr;
{$APPTYPE GUI}
{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Unit1, Unit2
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMeaRuler_Form1, MeaRuler_Form1);
  Application.CreateForm(TMeaRuler_Form2, MeaRuler_Form2);
  Application.Run;
end.

