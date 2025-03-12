RunSnippetTest() {
  ; WindowInfo すべて取得
  winInfo := WindowUtil.GetWindowInfo()
  MsgBox,% DumpObjectToString(winInfo)
  ExitApp

  ; すべて取得
  hwnds := WindowUtil.GetWindowHWNDs()
  rtnStr := ""
  For key, val in hwnds
  {
    WinGetTitle, title,% "ahk_id" val
    rtnStr .= key ": " val " " title "`n"
  }
  MsgBox,% rtnStr

  ; 見た目通りのウィンドウHWNDを取得する
  hwnds := WindowUtil.GetWindowHWNDs("ahk_exe sakura.exe")
  rtnStr := ""
  For key, val in hwnds
  {
    WinGetTitle, title,% "ahk_id" val
    rtnStr .= key ": " val " " title "`n"
  }
  MsgBox,% rtnStr

  ; Hidden on 目に見えないGUIのHWNDもひってしまう
  hwnds := WindowUtil.GetWindowHWNDs("ahk_exe sakura.exe", "", "", "ON")
  rtnStr := ""
  For key, val in hwnds
  {
    WinGetTitle, title,% "ahk_id" val
    rtnStr .= key ": " val " " title "`n"
  }
  MsgBox,% rtnStr

  ExitApp

  ; KeePassのパスを入力 WILに注意 To use settext, ahk_id control ID
  errLv := WindowUtil.SetTextToControl("my_Password5`n", "", "ahk_id 0x351054")
  ; errLv := WindowUtil.SetTextToControl("my_Password5`n", "WindowsForms10.EDIT.app.0.30495d1_r6_ad11", "ahk_class WindowsForms10.Window.8.app.0.30495d1_r6_ad1")
  ; ctrl hwndは固定ではないので使いづらい
  ; errLv := WindowUtil.SendKeystrokes("hoge h {Enter}oge", "", "ahk_id 0x250bec")
  MsgBox,% errLv
  ExitApp


  ; KeePassのパスを入力 WILに注意 To use settext
  errLv := WindowUtil.SetTextToControl("my_Password1", "WindowsForms10.EDIT.app.0.30495d1_r6_ad11", "ahk_class WindowsForms10.Window.8.app.0.30495d1_r6_ad1")
  ; ctrl hwndは固定ではないので使いづらい
  ; errLv := WindowUtil.SendKeystrokes("hoge h {Enter}oge", "", "ahk_id 0x250bec")
  MsgBox,% errLv
  ExitApp

  ; KeePassのパスを入力 WILに注意 To use sendmessage
  errLv := WindowUtil.SendStrToWindow("my_Password2", "WindowsForms10.EDIT.app.0.30495d1_r6_ad11", "ahk_class WindowsForms10.Window.8.app.0.30495d1_r6_ad1")
  ; ctrl hwndは固定ではないので使いづらい
  ; errLv := WindowUtil.SendKeystrokes("hoge h {Enter}oge", "", "ahk_id 0x250bec")
  MsgBox,% errLv
  ExitApp


  ; KeePassのパスを入力 WILに注意 To use keystrokes
  errLv := WindowUtil.SendKeystrokes("{End}+{Home}{Del}my_Password3{Enter}", "WindowsForms10.EDIT.app.0.30495d1_r6_ad11", "ahk_class WindowsForms10.Window.8.app.0.30495d1_r6_ad1")
  ; ctrl hwndは固定ではないので使いづらい
  ; errLv := WindowUtil.SendKeystrokes("hoge h {Enter}oge", "", "ahk_id 0x250bec")
  MsgBox,% errLv
  ExitApp

  ; サクラエディタに入力
  errLv := WindowUtil.SendKeystrokes("hoge{Enter}foo bar", "SakuraView1681", "ahk_class TextEditorWindowWP168")
  ; ctrl hwndは固定ではないので使いづらい
  ; errLv := WindowUtil.SendKeystrokes("hoge h {Enter}oge", "", "ahk_id 0x250bec")
  MsgBox,% errLv
  ExitApp
}

DumpObjectToString(obj, indent="")
{
  newIndent .= indent . "  "
  rtnStr := "{`n"

  For k, v in obj
  {
    if(IsObject(v)) {
      rtnStr .= newIndent . k . ": " . DumpObjectToString(v, newIndent)
    } else {
      rtnStr .= newIndent . k . ": " . v . "`n"
    }
  }

  rtnStr .= indent . "}`n"

  Return rtnStr
}

MsgBox,% MB_IconInfo, Hot Keys,% "[Ctrl] + [Shift] + 5: Get the active window info`n"
  . "[Ctrl] + [Shift] + 6: Get the window info under the cursor`n"
  . "[Ctrl] + [Shift] + 7: Double click the coordinates of the caret`n"
  . "[Ctrl] + [Shift] + 8: Wait for notepad.exe of process name appeared`n"
  . "[Ctrl] + [Shift] + 9: Wait for ' PowerShell' of window title appeared`n"
  . "[Ctrl] + [Shift] + 0: Tooltip and TrayTip (Not worked?)`n"
  . "[F10] + LClicking and move the cusor: Move the window`n"
  . "[F10] + RClicking and move the cusor: Risize the window from bottom-right`n"
  . "[F10] + [Shift] + RClicking and move the cusor: Risize the window from top-left`n"
  . "`n"
  . "Exit to manage the trask tray"
