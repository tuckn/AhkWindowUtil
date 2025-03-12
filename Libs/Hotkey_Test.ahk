^+3::
  winTitle := "ahk_exe sakura.exe"
  winHwnds := WindowUtil.GetWindowHWNDs(winTitle)
  winHwndsText := DumpObjectToString(winHwnds)
  MsgBox,% MB_IconInfo,% "Example Class WindowUtil",% winTitle ":`n"winHwndsText
  Return

^+4::
  strToSend := "This message from AutoHotkey"

  ctrl := WindowUtil.GetControlHwnd()
  ; ctrl := "Edit1"
  winTitle := "ahk_exe notepad.exe"

  WindowUtil.SendStrToWindow(strToSend, ctrl, winTitle)
  Return

^+5::
  MsgBox,% MB_IconInfo, PREPARE, Activate your window and click [OK]
  Sleep, 3000
  winInfo := WindowUtil.GetActiveWindowInfo()
  infoText := DumpObjectToString(winInfo)
  MsgBox,% MB_IconInfo, Active the window info, %infoText%
  Return

^+6::
  MsgBox,% MB_IconInfo, PREPARE, Hover on your window after clicked [OK]
  Sleep, 3000
  curInfo := WindowUtil.GetWindowInfoUnderCursor()
  infoText := DumpObjectToString(curInfo)
  MsgBox,% MB_IconInfo, The window info under the cusor, %infoText%
  Return

^+7::
  WindowUtil.DoubleClickCaretCoord()
  Return

^+8::
  processName := "notepad.exe"
  waitSec := 10

  MsgBox,% MB_IconInfo, Message
    , Wait %waitSec% sec for %processName% appeared. Start to click [OK]

  if (WindowUtil.WaitForProcessAppeared(processName, 10)) { ; 10 sec
    MsgBox,% MB_IconInfo, Message, Find it!
  } else {
    MsgBox,% MB_IconExclamation, Message, Can't find it...
  }
  Return

^+9::
  winTitle := " PowerShell"
  waitSec := 10

  MsgBox,% MB_IconInfo, Message
    , Wait %waitSec% sec for %winTitle% appeared. Start to click [OK]

  if (WindowUtil.WaitForWindowAppeared(winTitle, 10, , 2, True)) { ; 10 sec
    MsgBox,% MB_IconInfo, Message, Find it!
  } else {
    MsgBox,% MB_IconExclamation, Message, Can't find it...
  }
  Return

^+0::
  ; Not worked?
  WindowUtil.ShowTooltip("test tool tip", 50)
  WindowUtil.ShowTrayTip("test tray tip", 50)
  Return

F10 & LButton::
  WindowUtil.MoveWindowUnderCursor("F10")
  Return

F10 & RButton::
  WindowUtil.ResizeWindowUnderCursor("F10")
  Return
