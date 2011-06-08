unit capture;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, LCLType, LCLIntf;

type

  { TForm2 }

  TForm2 = class(TForm)
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image1DblClick(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form2: TForm2; 

  Screenshot: TBitmap;
  MouseIsDown : Boolean;
  PDown, PActual: TPoint;
implementation
uses main;

{ TForm2 }

procedure TForm2.FormCreate(Sender: TObject);

begin
  Left:=0;
  Top:=0;
  BorderStyle:=bsNone;
  Width:=Screen.Width;
  Height:=Screen.Height;
  FormStyle:=fsStayOnTop;
  KeyPreview:=true;

  //let's create the snapshot bitmap
  Screenshot:=TBitmap.Create;
  Screenshot.Width:=Screen.Width;
  Screenshot.Height:=Screen.Height;

end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  Screenshot.Free;
end;

procedure TForm2.FormKeyPress(Sender: TObject; var Key: char);
begin
  if Key = chr(27) then
  begin
    close;
    form1.show;
  end;
end;

procedure TForm2.FormShow(Sender: TObject);
var
ScreenDC: HDC;

begin
ScreenDC:=GetDC(0);
  Image1.Picture.Bitmap.LoadFromDevice(ScreenDC);
  Screenshot.LoadFromDevice(ScreenDC);
  ReleaseDC(0,ScreenDC);
end;

procedure TForm2.Image1Click(Sender: TObject);
begin

end;

procedure TForm2.Image1DblClick(Sender: TObject);
begin
     MouseIsDown:=false;
  close;
    form1.show;
end;

procedure TForm2.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if Button = mbLeft then
begin
  Image1.Canvas.CopyRect(Screenshot.Canvas.ClipRect,Screenshot.Canvas, Screenshot.Canvas.ClipRect);
  PDown:=Point(X,Y);
  PActual:=Point(X,Y);
  MouseIsDown:=True;
  Image1.Canvas.DrawFocusRect(Rect(X,Y,X,Y));
end;
end;

procedure TForm2.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if MouseIsDown then
  begin
//  Image1.Canvas.CopyRect(Screenshot.Canvas.ClipRect,Screenshot.Canvas, Screenshot.Canvas.ClipRect);
       Image1.Canvas.DrawFocusRect(Rect(PDown.X,PDown.Y,PActual.X,PActual.Y));
       PActual:=Point(X,Y);
       Image1.Canvas.DrawFocusRect(Rect(PDown.X,PDown.Y,X,Y));
//       Image1.Canvas.TextOut(X,Y,'800x600');
  end;
end;

procedure TForm2.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   TmpBmp : TBitmap;
begin
if Button = mbLeft then
begin
  Image1.Canvas.DrawFocusRect(Rect(PDown.X,PDown.Y,PActual.X,PActual.Y));
  Image1.Canvas.DrawFocusRect(Rect(PDown.X,PDown.Y,X,Y));
  PActual:=Point(X,Y);
  MouseIsDown:=False;
end
else if Button = mbRight then
begin
//let's copy the processed
  Image1.Canvas.DrawFocusRect(Rect(PDown.X,PDown.Y,PActual.X,PActual.Y));
  TmpBmp:=TBitmap.Create;
  with TmpBmp do
  try
     Width:=round(abs(PActual.X-PDown.X));
     Height:=round(abs(PActual.Y-PDown.Y));
     BitBlt(Canvas.Handle,0,0,Width,Height,Image1.Canvas.Handle,PDown.X,PDown.Y,SRCCOPY);
     Form1.Image1.Picture.Bitmap.Assign(TmpBmp);
  finally
         Free;
  end;
  close;
  picWith:=form1.Image1.Picture.Width;
  picHeight:=form1.Image1.Picture.Height;
  form1.LabeledEdit1.Text:=inttostr(picWith);
  form1.LabeledEdit2.Text:=inttostr(picHeight);
  form1.Show;
end;
end;

initialization
  {$I capture.lrs}

end.

