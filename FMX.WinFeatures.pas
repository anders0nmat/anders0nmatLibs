unit FMX.WinFeatures;

interface

uses Windows, Classes, FMX.Types, Messages, ShellApi, SysUtils, FMX.Menus;

type

  TFMXTrayIcon = class
  public
    const WM_TRAYICON = WM_USER + $64;
  private
  type
    TTrayAction = (Add = NIM_ADD, Modify = NIM_MODIFY, Delete = NIM_DELETE);
    TStandardIcon = (siNONE = 0, siAPPLICATION = 32512, siHAND = 32513, siQUESTION = 32514,
                     siEXCLAMATION = 32515, siASTERISK = 32516, siWINLOGO = 32517,
                     siSHIELD = 32518, siWARNING = siEXCLAMATION, siERROR = siHAND, siINFORMATION = siASTERISK);
  var
    fData: TNotifyIconData;
    fVisible: Boolean;
    fIcon: String;
    fHint: String;
    fHandle: HWND;
    fPopupMenu: TCustomPopupMenu;
    fStandardIcon: TStandardIcon;


    fOnClick: TNotifyEvent;
    fOnDblClick: TNotifyEvent;

    procedure WMTrayIcon(var Message: TMessage);

    procedure SetTray(Action: TTrayAction);
    procedure SetHint(const Value: String);
    procedure SetIcon(const Value: String);
    procedure SetVisible(const Value: Boolean);
    procedure SetStandardIcon(const Value: TStandardIcon);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Show;
    procedure Hide;

    property Visible: Boolean read fVisible write SetVisible;
    property Icon: String read fIcon write SetIcon;
    property StandardIcon: TStandardIcon read fStandardIcon write SetStandardIcon;
    property Hint: String read fHint write SetHint;
    property PopupMenu: TCustomPopupMenu read fPopupMenu write fPopupMenu;

    property OnClick: TNotifyEvent read fOnClick write fOnClick;
    property OnDblClick: TNotifyEvent read fOnDblClick write fOnDblClick;
  end;

procedure HideOnTaskbar(Handle: HWND);
procedure ShowOnTaskbar(Handle: HWND);

implementation

{$REGION 'DEF'}

procedure HideOnTaskbar(Handle: HWND);
begin
  ShowWindow(Handle, SW_HIDE);
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
end;

procedure ShowOnTaskbar(Handle: HWND);
begin
  ShowWindow(Handle, SW_HIDE);
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) and (not WS_EX_TOOLWINDOW));
  ShowWindow(Handle, SW_SHOW);
end;

{$ENDREGION}

{$REGION 'TFMXTrayIcon'}

constructor TFMXTrayIcon.Create;
begin
  fHandle := AllocateHWnd(WMTrayIcon);
  fHint := '';
  fVisible := false;

  with fData do
  begin
    cbSize := SizeOf;
    Wnd := fHandle;
    uID := 1;
    uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
    uCallbackMessage := WM_TRAYICON;
    //hIcon := LoadIcon(HInstance, PChar(fIcon));
    StrPCopy(szTip, fHint);
    StandardIcon := siAPPLICATION;
  end;
end;

destructor TFMXTrayIcon.Destroy;
begin
  SetTray(Delete);
  DeallocateHWnd(fHandle);
end;

procedure TFMXTrayIcon.Hide;
begin
  if fVisible <> false then
    Visible := false;
end;

procedure TFMXTrayIcon.SetHint(const Value: String);
begin
  if Value <> fHint then
  begin
    fHint := Value;
    StrPCopy(fData.szTip, fHint);
    SetTray(Modify);
  end;
end;

procedure TFMXTrayIcon.SetIcon(const Value: String);
begin
  if Value <> fIcon then
  begin
    fIcon := Value;
    fStandardIcon := siNONE;
    fData.hIcon := LoadIcon(HInstance, PChar(fIcon));
    SetTray(Modify);
  end;
end;

procedure TFMXTrayIcon.SetStandardIcon(const Value: TStandardIcon);
begin
  if Value <> fStandardIcon then
  begin
    fStandardIcon := Value;
    fData.hIcon := LoadIcon(0, MakeIntResource(Ord(fStandardIcon)));
    SetTray(Modify);
  end;
end;

procedure TFMXTrayIcon.SetTray(Action: TTrayAction);
begin
  Shell_NotifyIcon(Ord(Action), @fData);
end;

procedure TFMXTrayIcon.SetVisible(const Value: Boolean);
begin
  if Value <> fVisible then
  begin
    fVisible := Value;
    if fVisible then
      SetTray(Add)
    else
      SetTray(Delete);
  end;
end;

procedure TFMXTrayIcon.Show;
begin
  if fVisible <> true then
    Visible := true;
end;

procedure TFMXTrayIcon.WMTrayIcon(var Message: TMessage);
var
  p: TPoint;
begin
  if Message.Msg = WM_TRAYICON then
  begin
    case Message.LParam of
    WM_LBUTTONUP:
      begin
        if Assigned(fOnClick) then
          fOnClick(Self);
      end;
    WM_RBUTTONUP:
      begin
        if Assigned(fPopupMenu) then
        begin
          GetCursorPos(p);
          fPopupMenu.Popup(p.X, p.Y);
        end;
      end;
    WM_LBUTTONDBLCLK, WM_MBUTTONDBLCLK, WM_RBUTTONDBLCLK:
      begin
        if Assigned(fOnDblClick) then fOnDblClick(Self);
      end;
    end;
  end
  else
    Message.Result := DefWindowProc(fHandle, Message.Msg, Message.WParam, Message.LParam);
end;

{$ENDREGION}

end.
