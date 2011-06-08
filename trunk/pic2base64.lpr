program pic2base64;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, LResources, capture
  { you can add units after this };

{$IFDEF WINDOWS}{$R pic2base64.rc}{$ENDIF}
begin
  Application.Title:='Pic2Base64';
  {$I pic2base64.lrs}
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.

