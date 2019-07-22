#Include %A_ScriptDir%\AhkModules\AhkConstValues\Globals.ahk
#Include %A_ScriptDir%\..\Desktop.ahk


  ; KeePassのパスを入力 WILに注意 To use settext, ahk_id control ID
  errLv := Desktop.SetTextToControl("my_Password5`n", "", "ahk_id 0x361054")
  ; errLv := Desktop.SetTextToControl("my_Password5`n", "WindowsForms10.EDIT.app.0.30495d1_r6_ad11", "ahk_class WindowsForms10.Window.8.app.0.30495d1_r6_ad1")
  ; ctrl hwndは固定ではないので使いづらい
  ; errLv := Desktop.SendKeystrokes("hoge h {Enter}oge", "", "ahk_id 0x250bec")
  Msgbox,% errLv

  ; KeePassのパスを入力 WILに注意 To use settext
  errLv := Desktop.SetTextToControl("my_Password1", "WindowsForms10.EDIT.app.0.30495d1_r6_ad11", "ahk_class WindowsForms10.Window.8.app.0.30495d1_r6_ad1")
  ; ctrl hwndは固定ではないので使いづらい
  ; errLv := Desktop.SendKeystrokes("hoge h {Enter}oge", "", "ahk_id 0x250bec")
  Msgbox,% errLv

  ; KeePassのパスを入力 WILに注意 To use sendmessage
  errLv := Desktop.SendStrToWindow("my_Password2", "WindowsForms10.EDIT.app.0.30495d1_r6_ad11", "ahk_class WindowsForms10.Window.8.app.0.30495d1_r6_ad1")
  ; ctrl hwndは固定ではないので使いづらい
  ; errLv := Desktop.SendKeystrokes("hoge h {Enter}oge", "", "ahk_id 0x250bec")
  Msgbox,% errLv

  ; KeePassのパスを入力 WILに注意 To use keystrokes
  errLv := Desktop.SendKeystrokes("{End}+{Home}{Del}my_Password3", "WindowsForms10.EDIT.app.0.30495d1_r6_ad11", "ahk_class WindowsForms10.Window.8.app.0.30495d1_r6_ad1")
  ; ctrl hwndは固定ではないので使いづらい
  ; errLv := Desktop.SendKeystrokes("hoge h {Enter}oge", "", "ahk_id 0x250bec")
  Msgbox,% errLv

  ; サクラエディタに入力
  errLv := Desktop.SendKeystrokes("hoge{Enter}foo bar", "SakuraView1681", "ahk_class TextEditorWindowWP168")
  ; ctrl hwndは固定ではないので使いづらい
  ; errLv := Desktop.SendKeystrokes("hoge h {Enter}oge", "", "ahk_id 0x250bec")
  Msgbox,% errLv
  ExitApp

RunTest() {
  ; WindowInfo すべて取得
  winInfo := Desktop.GetWindowInfo()
  MsgBox,% GetStringFromObject(winInfo)
  ExitApp

  ; すべて取得
  hwnds := Desktop.GetWindowHwnds()
  rtnStr := ""
  For key, val in hwnds
  {
    WinGetTitle, title,% "ahk_id" val
    rtnStr .= key ": " val " " title "`n"
  }
  MsgBox,% rtnStr

  ; 見た目通りのウィンドウHWNDを取得する
  hwnds := Desktop.GetWindowHwnds("ahk_exe sakura.exe")
  rtnStr := ""
  For key, val in hwnds
  {
    WinGetTitle, title,% "ahk_id" val
    rtnStr .= key ": " val " " title "`n"
  }
  MsgBox,% rtnStr

  ; Hidden on 目に見えないGUIのHWNDもひってしまう
  hwnds := Desktop.GetWindowHwnds("ahk_exe sakura.exe", "", "", "ON")
  rtnStr := ""
  For key, val in hwnds
  {
    WinGetTitle, title,% "ahk_id" val
    rtnStr .= key ": " val " " title "`n"
  }
  MsgBox,% rtnStr

  ExitApp

  ; KeePassのパスを入力 WILに注意 To use settext, ahk_id control ID
  errLv := Desktop.SetTextToControl("my_Password5`n", "", "ahk_id 0x351054")
  ; errLv := Desktop.SetTextToControl("my_Password5`n", "WindowsForms10.EDIT.app.0.30495d1_r6_ad11", "ahk_class WindowsForms10.Window.8.app.0.30495d1_r6_ad1")
  ; ctrl hwndは固定ではないので使いづらい
  ; errLv := Desktop.SendKeystrokes("hoge h {Enter}oge", "", "ahk_id 0x250bec")
  Msgbox,% errLv
  ExitApp


  ; KeePassのパスを入力 WILに注意 To use settext
  errLv := Desktop.SetTextToControl("my_Password1", "WindowsForms10.EDIT.app.0.30495d1_r6_ad11", "ahk_class WindowsForms10.Window.8.app.0.30495d1_r6_ad1")
  ; ctrl hwndは固定ではないので使いづらい
  ; errLv := Desktop.SendKeystrokes("hoge h {Enter}oge", "", "ahk_id 0x250bec")
  Msgbox,% errLv
  ExitApp

  ; KeePassのパスを入力 WILに注意 To use sendmessage
  errLv := Desktop.SendStrToWindow("my_Password2", "WindowsForms10.EDIT.app.0.30495d1_r6_ad11", "ahk_class WindowsForms10.Window.8.app.0.30495d1_r6_ad1")
  ; ctrl hwndは固定ではないので使いづらい
  ; errLv := Desktop.SendKeystrokes("hoge h {Enter}oge", "", "ahk_id 0x250bec")
  Msgbox,% errLv
  ExitApp


  ; KeePassのパスを入力 WILに注意 To use keystrokes
  errLv := Desktop.SendKeystrokes("{End}+{Home}{Del}my_Password3{Enter}", "WindowsForms10.EDIT.app.0.30495d1_r6_ad11", "ahk_class WindowsForms10.Window.8.app.0.30495d1_r6_ad1")
  ; ctrl hwndは固定ではないので使いづらい
  ; errLv := Desktop.SendKeystrokes("hoge h {Enter}oge", "", "ahk_id 0x250bec")
  Msgbox,% errLv
  ExitApp

  ; サクラエディタに入力
  errLv := Desktop.SendKeystrokes("hoge{Enter}foo bar", "SakuraView1681", "ahk_class TextEditorWindowWP168")
  ; ctrl hwndは固定ではないので使いづらい
  ; errLv := Desktop.SendKeystrokes("hoge h {Enter}oge", "", "ahk_id 0x250bec")
  Msgbox,% errLv
  ExitApp
}

MsgBox,% G_MsgIconInfo, Hot Keys,% "[Ctrl] + [Shift] + 5: Get the active window info`n"
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

^+3::
  winTitle := "ahk_exe sakura.exe"
  winHwnds := Desktop.GetWindowHwnds(winTitle)
  winHwndsText := GetStringFromObject(winHwnds)
  MsgBox,% G_MsgIconInfo,% "Example Class Desktop",% winTitle ":`n"winHwndsText

  ExitApp

^+4::
  strToSend := "This message from AutoHotkey"

  ctrl := Desktop.GetControlHwnd()
  ; ctrl := "Edit1"
  winTitle := "ahk_exe notepad.exe"

  Desktop.SendStrToWindow(strToSend, ctrl, winTitle)

  ExitApp

^+5::
  MsgBox,% G_MsgIconInfo, PREPARE, Activate your window and click [OK]
  Sleep, 3000
  winInfo := Desktop.GetActiveWindowInfo()
  infoText := GetStringFromObject(winInfo)
  MsgBox,% G_MsgIconInfo, Active the window info, %infoText%
  ExitApp

^+6::
  MsgBox,% G_MsgIconInfo, PREPARE, Hover on your window after clicked [OK]
  Sleep, 3000
  curInfo := Desktop.GetWindowInfoUnderCursor()
  infoText := GetStringFromObject(curInfo)
  MsgBox,% G_MsgIconInfo, The window info under the cusor, %infoText%
  Return

^+7::
  Desktop.DoubleClickCaretCoord()
  Return

^+8::
  processName := "notepad.exe"
  waitSec := 10

  MsgBox,% G_MsgIconInfo, Message
    , Wait %waitSec% sec for %processName% appeared. Start to click [OK]

  if (Desktop.WaitForProcessAppeared(processName, 10)) { ; 10 sec
    MsgBox,% G_MsgIconInfo, Message, Find it!
  } else {
    MsgBox,% G_MsgIconExclamation, Message, Can't find it...
  }
  Return

^+9::
  winTitle := " PowerShell"
  waitSec := 10

  MsgBox,% G_MsgIconInfo, Message
    , Wait %waitSec% sec for %winTitle% appeared. Start to click [OK]

  if (Desktop.WaitForWindowAppeared(winTitle, 10, , 2, True)) { ; 10 sec
    MsgBox,% G_MsgIconInfo, Message, Find it!
  } else {
    MsgBox,% G_MsgIconExclamation, Message, Can't find it...
  }
  Return

^+0::
  ; Not worked?
  Desktop.DisplayTooltip("test tool tip", 50)
  Desktop.DisplayTrayTip("test tray tip", 50)
  Return

F10 & LButton::
  Desktop.MoveWindowUnderCursor("F10")
  Return

F10 & RButton::
  Desktop.ResizeWindowUnderCursor("F10")
  Return

GetStringFromObject(obj, indent="")
{
  newIndent .= indent . "  "
  rtnStr := "{`n"

  For k, v in obj
  {
    if(IsObject(v)) {
      rtnStr .= newIndent . k . ": " . GetStringFromObject(v, newIndent)
    } else {
      rtnStr .= newIndent . k . ": " . v . "`n"
    }
  }

  rtnStr .= indent . "}`n"

  Return rtnStr
}
