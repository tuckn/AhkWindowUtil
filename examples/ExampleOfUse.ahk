#Include %A_ScriptDir%\..\Desktop.ahk

Msgbox, 0x40, Hot Keys,% "[Ctrl] + [Shift] + 5: Get the active window info`n"
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

^+5::
  Msgbox, 0x40, PREPARE, Activate your window and click [OK]
  Sleep, 3000
  winInfo := Desktop.GetActiveWindowInfo()
  infoText := GetStringFromObject(winInfo)
  Msgbox, 0x40, Active the window info, %infoText%
  Return

^+6::
  Msgbox, 0x40, PREPARE, Hover on your window after clicked [OK]
  Sleep, 3000
  winInfo := Desktop.GetWindowInfoUnderCursor()
  infoText := GetStringFromObject(winInfo)
  Msgbox, 0x40, The window info under the cusor, %infoText%
  Return

^+7::
  Desktop.DoubleClickCaretCoord()
  Return

^+8::
  processName := "notepad.exe"
  waitSec := 10

  Msgbox, 0x40, Message
    , Wait %waitSec% sec for %processName% appeared. Start to click [OK]

  if (Desktop.WaitForProcessAppeared(processName, 10)) { ; 10 sec
    Msgbox, 0x40, Message, Find it!
  } else {
    Msgbox, 0x30, Message, Can't find it...
  }
  Return

^+9::
  winTitle := " PowerShell"
  waitSec := 10

  Msgbox, 0x40, Message
    , Wait %waitSec% sec for %winTitle% appeared. Start to click [OK]

  if (Desktop.WaitForWindowAppeared(winTitle, 10, , 2, True)) { ; 10 sec
    Msgbox, 0x40, Message, Find it!
  } else {
    Msgbox, 0x30, Message, Can't find it...
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
