unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Clipbrd, ExtCtrls, LCLIntf, LCLType, ComCtrls, ExtDlgs, SynEdit,
  SynMemo, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnCapture: TButton;
    btnAbout: TButton;
    btnPaste: TButton;
    btnConvert: TButton;
    btnCopy: TButton;
    Button1: TButton;
    btnResize: TButton;
    chkSize: TCheckBox;
    GroupBox1: TGroupBox;
    Image1: TImage;
    lblLength: TLabel;
    lblSize: TLabel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    lblJpegSettings: TLabel;
    Memo1: TMemo;
    OpenPictureDialog1: TOpenPictureDialog;
    ScrollBar1: TScrollBar;
    ScrollBar2: TScrollBar;
    Timer1: TTimer;
    TrackBar1: TTrackBar;
    procedure btnAboutClick(Sender: TObject);
    procedure btnCaptureClick(Sender: TObject);
    procedure btnPasteClick(Sender: TObject);
    procedure btnConvertClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure btnResizeClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LabeledEdit1Change(Sender: TObject);
    procedure LabeledEdit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LabeledEdit2Change(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure ScrollBar2Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 
const
 VERSION = '1.0.8.11';
var
  Form1: TForm1;
  movenow: boolean;
  mousepos: TPoint;
  imagepos: TPoint;
   Base64Digits8192: array [0..4095] of WORD;

  picWith, picHeight: integer;
implementation

uses capture;
{ TForm1 }

procedure Encode64Fast(fname: string);
var
  picfile : file;
  inbytes: array [0..2] of byte;
  outbuf : array[0..3] of char;
  tmp: word;
  result: integer;
  leidos: real;
  pos: integer;
begin
  AssignFile(picfile, fname);
  Reset(picfile,1);

  leidos:=0;
  //ahora procesamos
  Form1.Memo1.Text:='data:image/jpg;base64,';
  repeat
  inbytes[1]:=0;
  inbytes[2]:=0;
  BlockRead(picfile,inbytes,3,result);
  leidos:=leidos+result;

  pos:=inbytes[0];
  pos:=pos shl 8;
  pos:=pos or inbytes[1];
  pos:=pos shr 4;
  tmp:=Base64Digits8192[pos];
//  Form1.Memo1.Text:=Form1.Memo1.Text+chr(tmp shr 8)+chr(tmp and $00FF);

  pos:=inbytes[1];
  pos:=pos and $000F;
  pos:=pos shl 8;
  pos:=pos or inbytes[2];
  tmp:=Base64Digits8192[pos];
//  Form1.Memo1.Text:=Form1.Memo1.Text+chr(tmp shr 8)+chr(tmp and $00FF);


  until (result = 0);
  CloseFile(picfile);
end;

procedure Encode64(fname: string);
const
  B64Table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  //-_ en lugar de +/ para URLs según wikipedia menciona pero no funciona en Opera
var
  picfile : file;
  inbytes: array [0..2] of byte;
  outbuf : array[0..3] of char;
  result: integer;
  leidos: real;
  buffer: TStringStream;
begin
  AssignFile(picfile, fname);
  Reset(picfile,1);

  leidos:=0;
  //ahora procesamos
//  Form1.SynMemo1.Text:='data:image/png;base64,';
  buffer:=TStringStream.Create('');
  repeat
  inbytes[1]:=0;
  inbytes[2]:=0;
  BlockRead(picfile,inbytes,3,result);
  leidos:=leidos+result;

  form1.Invalidate;
//  outbuf[0] := B64Table[((Inbytes[0] and $FC)shr 2)+1];
  outbuf[0] := B64Table[(Inbytes[0] shr 2)+1];
  OutBuf[1] := B64Table[(((Inbytes[0] and $3) shl 4) or ((InBytes[1] and $F0) shr 4)) + 1];
  OutBuf[2] := B64Table[(((InBytes[1] and $F) shl 2) or ((InBytes[2] and $C0) shr 6)) + 1];
  OutBuf[3] := B64Table[(InBytes[2] and $3F) + 1];
//  Form1.Memo1.Text:=Form1.Memo1.Text+outbuf;
    buffer.Write(outbuf,4);
  until (result = 0);
//  Form1.Memo1.Lines.LoadFromStream(buffer);
    form1.Memo1.Text:= 'data:image/jpg;base64,'+buffer.DataString;
  buffer.Free;
  CloseFile(picfile);
end;



procedure TForm1.btnCaptureClick(Sender: TObject);
begin
//application.Minimize;
//application.ShowMainForm:=False;
Hide;
sleep(500);
Timer1.Enabled:=true;
end;

procedure TForm1.btnAboutClick(Sender: TObject);
begin

  MessageDlg('About','Pic2Base64 '+VERSION+#13#13
  +'Written by vhanla'#13
  +'http://apps.codigobit.info/',mtInformation,[mbOK],'');
end;

procedure TForm1.btnPasteClick(Sender: TObject);
begin
Image1.Picture.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfBitmap));
       picWith:=Image1.Picture.Width;
       picHeight:=Image1.Picture.Height;
       LabeledEdit1.Text:=IntToStr(picWith);
       LabeledEdit2.Text:=IntToStr(picHeight);
end;

procedure TForm1.btnConvertClick(Sender: TObject);
var
tmpfile: string;
jpg: TJPEGImage;
begin
//     Image1.Picture.SaveToFile();
tmpfile:=GetTempFileName(GetTempDir,'2b64');
tmpfile:=ExtractFileNameWithoutExt(tmpfile)+'.jpg';
//ShowMessage(tmpfile);
    jpg:=TJPEGImage.Create;
    try
       jpg.Assign(image1.Picture.Bitmap);
       jpg.CompressionQuality:=StrToIntDef(IntToStr(form1.TrackBar1.Position),100);
       jpg.SaveToFile(tmpfile);
    finally
    jpg.Free;
    end;
//una vez salvado la imagen procedemos a convertirlo en base 64
form1.Cursor:=crHourGlass;
if FileSize(tmpfile)<=50000 then
Encode64(tmpfile)
else if (FileSize(tmpfile)>50000) and (Form1.chkSize.Checked) then
Encode64(tmpfile)
else form1.Memo1.Text:='This picture is too big to use as base64 - '+FloatToStr(FileSize(tmpfile))+' bytes.';
Form1.Cursor:=crDefault;
lblSize.Caption:='Size: '+IntToStr(FileSize(tmpfile))+' bytes';
lblLength.Caption:='Length:'#13+IntToStr(length(Memo1.text))+' bytes.';
end;

procedure TForm1.btnCopyClick(Sender: TObject);
begin
//  SynEdit1.CopyToClipboard;
  Clipboard.Open;
  Clipboard.AsText:=Memo1.Text;
  Clipboard.Close;
end;

procedure TForm1.btnResizeClick(Sender: TObject);
var
   rszBMP : TBitmap;
begin
     rszBMP:=TBitmap.Create;
     try
      rszBMP.Width:=StrToInt(LabeledEdit1.Text);
      rszBMP.Height:=StrToInt(LabeledEdit2.Text);
      rszBMP.Canvas.Brush.Color:=clWhite;
      rszBMP.Canvas.FillRect(Rect(0,0,rszBMP.Width,rszBMP.Height));
      rszBMP.Canvas.StretchDraw(Rect(0,0,rszBMP.Width,rszBMP.Height),image1.Picture.Bitmap);
      image1.Picture.Bitmap.Assign(rszBMP);
     finally
     rszBMP.Free;
     end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
  begin
       Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
       picWith:=Image1.Picture.Width;
       picHeight:=Image1.Picture.Height;
       LabeledEdit1.Text:=IntToStr(picWith);
       LabeledEdit2.Text:=IntToStr(picHeight);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
const
  Base64Digits = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
var
 j,k:integer;
 W: WORD;
 tmp: WORD;
begin
BorderStyle:=bsSingle;
  TrackBar1.Position:=70;
     for j:=0 to 63 do
     begin
          for k:=0 to 63 do
          begin
            W:=WORD(Base64Digits[k+1]) shl 8;
           // Memo1.Text:=Memo1.Text+Base64Digits[k+1];
            W:= W or  WORD(Base64Digits[j+1]);
           // Memo1.Text:=Memo1.Text+Base64Digits[j+1];
            Base64Digits8192[(j*64)+k]:=W;
            tmp:=W;
/////util///            Memo1.Text:=Memo1.Text+chr(W shr 8)+chr(tmp and $00FF);
          end;
     end;

//     ShowMessage(IntToStr(SizeOf(Base64Digits8192)));
//     Memo1.Text:=chr(Base64Digits8192[0]) ;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin

end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if (Image1.Width<GroupBox1.Width) and (Image1.Height<GroupBox1.Height)
   then exit;
   movenow:=true;
   mousepos.X:=X;
   mousepos.Y:=Y;
   imagepos.X:=Image1.Left;
   imagepos.Y:=Image1.Top;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
mx,my: integer;
begin
   if not movenow then exit;
   if ssLeft in Shift then
   begin
    if ScrollBar1.Visible then
    begin
      mx:=X-mousepos.X;
      Image1.Left:=max(ScrollBar1.Width-Image1.Width,min(0,imagepos.X+mx));
      ScrollBar1.Position:=-Image1.Left;
      imagepos.X:=Image1.Left;
    end;
    if ScrollBar2.Visible then
    begin
      my:= Y- mousepos.Y;
      Image1.Top:=max(ScrollBar2.Height-Image1.Height,min(0,imagepos.Y+my));
      ScrollBar2.Position:=-Image1.Top;
      imagepos.Y:=Image1.Top;
    end;
   end;
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  movenow:=False;
end;

procedure TForm1.LabeledEdit1Change(Sender: TObject);
begin
//300/200=1.5*200=300
if (length(LabeledEdit1.Text)>0) and (LabeledEdit1.Focused)then
   LabeledEdit2.Text:=inttostr(trunc(picHeight/picWith*StrToInt(LabeledEdit1.Text)));
end;

procedure TForm1.LabeledEdit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
numbers: set of '0'..'9';
begin
numbers:=['0'..'9'];
  if (chr(key) in numbers) or (key = VK_BACK) or (key = VK_DELETE)
  or (key = VK_LEFT) or (key = VK_RIGHT) or (key = VK_HOME) or (key = VK_END)
  or (key = VK_TAB) then
  begin

  end
  else key:=0;
end;

procedure TForm1.LabeledEdit2Change(Sender: TObject);
begin
  if (length(LabeledEdit2.Text)>0) and LabeledEdit2.Focused then
   LabeledEdit1.Text:=inttostr(trunc(picWith/picHeight*StrToInt(LabeledEdit2.Text)));
end;

procedure TForm1.ScrollBar1Change(Sender: TObject);
begin
  Image1.Left:=-ScrollBar1.Position;
end;

procedure TForm1.ScrollBar2Change(Sender: TObject);
begin
  Image1.Top:=-ScrollBar2.Position;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
     timer1.Enabled:=false;
//     Application.Restore;
     Form2.Show;
end;

initialization
  {$I main.lrs}

end.

