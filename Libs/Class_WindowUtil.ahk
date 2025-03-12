/**
 * @Fileoverview Window utility functions for AutoHotkey
 * @Fileencoding UTF-8[dos]
 * @Requirements AutoHotkey v1.1.x. Not confirmed to work on v2.0 or newer.
 * @Installation
 *   #Include %A_ScriptDir%\AhkWindowUtil\Libs\Global_WindowMessages.ahk
 *   #Include %A_ScriptDir%\AhkWindowUtil\Libs\Class_WindowUtil.ahk
 * or copy into your code
 * @License MIT
 * @Links https://github.com/tuckn/AhkWindowUtil
 * @Author Tuckn
 * @Email tuckn333@gmail.com
 */

/**
 * @Class WindowUtil
 * @Description The WindowUtil object contains methods for parsing
 * @Note
 *   ahk_class is a name of window template type. not unique.
 *   ahk_id is a HWND. This is short for Handle to WiNDow(window handle ID).
 *   ahk_pid is a PID(process ID).
 * @Methods
 */
class WindowUtil
{
  savedDetectHidWin := A_DetectHiddenWindows
  savedTitleMatchMode := A_TitleMatchMode

  ; ============== HANDLE GETTER
  /**
   * @Method GetWindowHWNDs
   * @Description Get window handles. {{{
   * @Syntax winHwnd := WindowUtil.GetWindowHWNDs(...)
   * @Param {String} [WinTitle=""] Empty is as all windows
   * @Param {String} [winText=""]
   * @Param {String} [excludeTitle=""]
   * @Param {String} [hidingDetector="OFF"] See @Method SetModes
   * @Param {Number} [titleMatchMode=1] See @Method SetModes
   * @Return {Array}
   */
  class GetWindowHWNDs extends WindowUtil.Functor
  {
    Call(self, winTitle:=""
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      WindowUtil.SetModes(hidingDetector, titleMatchMode)

      ; Get a list of ahk_id(= window handle ID).
      WinGet, idsList, List,% winTitle,% winText,% excludeTitle

      winHwnds := []
      Loop, %idsList%
      {
        winHwnds.Insert(idsList%A_Index%)
      }

      WindowUtil.RestoreModes()
      Return winHwnds
    }
  } ; }}}

  /**
   * @Method GetProcessID
   * @Description Get s process ID {{{
   * @Syntax pId := WindowUtil.GetProcessID(...)
   *   When all parameters is empty, get the active window PID.
   * @Param See @Method GetWindowHWNDs
   * @Return {String}
   */
  class GetProcessID extends WindowUtil.Functor
  {
    Call(self, winTitle:=""
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      WindowUtil.SetModes(hidingDetector, titleMatchMode)

      ; Get the process ID. 複数ある場合は前面にあるものが優先される
      if (winTitle = "" && winText = "" && excludeTitle = "") {
        WinGet, pId, PID, A
      } else {
        WinGet, pId, PID, %winTitle%, %winText%, %excludeTitle%
      }

      WindowUtil.RestoreModes()
      Return pId
    }
  } ; }}}

  /**
   * @Method FindProcessName
   * @Description Find the process name {{{
   * @Syntax pId := WindowUtil.FindProcessName(ProcessName)
   * @Param {String} ProcessName
   * @Return {String} PID. if failed to get, return 0(False)
   */
  class FindProcessName extends WindowUtil.Functor
  {
    Call(self, processName)
    {
      ; Checks whether the specified process is present.
      Process, Exist, %processName%
      ; Sets ErrorLevel to the Process ID (PID) if a matching process exists
      pId :=  ErrorLevel
      Return pId
    }
  } ; }}}

  /**
   * @Method GetControlHwnd
   * @Description Get the control handle from the control name, window title. {{{
   * @Syntax winHwnd := WindowUtil.GetControlHwnd(...)
   * @Param {String} ctrlName
   * @Param Others parameters, See @Method GetWindowHWNDs
   * @Return {String}
   */
  class GetControlHwnd extends WindowUtil.Functor
  {
    Call(self, ctrlName, winTitle
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      WindowUtil.SetModes(hidingDetector, titleMatchMode)

      ctrlHwnd := 0x0
      exitCode := ErrorLevel

      ; Get a list of ahk_id(= window handle ID).
      WinGet, winIDs, List, %winTitle%, %winText%, %excludeTitle%
      Loop, %winIDs%
      {
        ; Get a ahk_id
        StringTrimRight, this_id, winIDs%A_Index%, 0

        ; Get a control IDs
        WinGet, controls, ControlList, ahk_id %this_id%
        Loop, Parse, controls, `n
        {
          if (InStr(A_LoopField, ctrlName) != 0) {
            ControlGet, ctrlHwnd, Hwnd,, %A_LoopField%, ahk_id %this_id%
            exitCode := ErrorLevel
            Break
          }
        }
        IfEqual, exitCode, %WN_ExitCodeOK%, Break

        ; Retry with regular expression matching(Slow)
        Loop, Parse, controls, `n
        {
          if (RegExMatch(A_LoopField, ctrlName) != 0) {
            ControlGet, ctrlHwnd, Hwnd,, %A_LoopField%, ahk_id %this_id%
            exitCode := ErrorLevel
            Break
          }
        }
        IfEqual, exitCode, %WN_ExitCodeOK%, Break
      }

      WindowUtil.RestoreModes()
      Return ctrlHwnd
    }
  } ; }}}

  /**
   * @Method GetWindowInfo
   * @Description Find window Hwnd which is matched args {{{
   * @Syntax winInfo := WindowUtil.GetWindowInfo(...)
   * @Param See @Method GetWindowHWNDs
   * @Return {Array} [{ hwnd, title }]
   */
  class GetWindowInfo extends WindowUtil.Functor
  {
    Call(self, winTitle:=""
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      WindowUtil.SetModes(hidingDetector, titleMatchMode)

      winHwnds := WindowUtil.GetWindowHWNDs(winTitle
          , winText, excludeTitle, hidingDetector, titleMatchMode)
      winInfo := []

      For key, winHwnd in winHwnds
      {
        WinGetTitle, winTitle, ahk_id %winHwnd%
        winInfo.Insert({ hwnd: winHwnd, title: winTitle })
      }

      WindowUtil.RestoreModes()
      Return winInfo
    }
  } ; }}}

  /**
   * @Method GetActiveWindowInfo
   * @Description Get a active window information {{{
   * @Return {Associative Array} .hwnd, .processName, .title, .winClass, ...
   */
  class GetActiveWindowInfo extends WindowUtil.Functor
  {
    Call(self)
    {
      savedCoordModeMouse := A_CoordModeMouse
      CoordMode, Mouse, Screen

      WinGet, winHwnd, ID, A ; Get a window HWND
      WinGet, processName, ProcessName, ahk_id %winHwnd%
      WinGetTitle, winTitle, ahk_id %winHwnd%
      WinGetClass, winClass, ahk_id %winHwnd%
      WinGetPos, winX, winY, winWidth, winHeight, ahk_id %winHwnd%
      ControlGetFocus, ctrlClass, ahk_id %winHwnd%
      ControlGetText, ctrlText, , ahk_id %winHwnd%
      WinGet, ctrlHwnds, ControlListHWND, A

      ; ; Debug
      ; ToolTip, Active window`nWinHWND: %winHwnd%`nWinName: %processName%`nWinTitle: %winTitle%`nClassName: %winClass%`nControlHWND: %ctrlHwnds%`nControlClassNN: %ctrlClass%`nControlText: %ctrlText%

      info := {}
      ; Window
      info.winHwnd := winHwnd ; "0x20ace"
      info.processName := processName ; "excel.exe"
      info.pId := WindowUtil.FindProcessName(processName)
      info.title := winTitle ; "Microsoft Visual Basic for Application..."
      info.winClass := winClass ; "wndclass_desked_gsk"
      info.winX := winX
      info.winY := winY
      info.winWidth := winWidth
      info.winHeight := winHeight
      ; Control
      info.ctrlClass := ctrlClass ; "VbaWindow1"
      info.ctrlText := ctrlText ; "hoge.xls - MnModule (コード)"
      info.ctrlHwnds := ctrlHwnds ; "0x10bb4"

      CoordMode, Mouse, %savedCoordModeMouse%
      Return info
    }
  } ; }}}

  /**
   * @Method GetWindowInfoUnderCursor
   * @Description Get window information under the cursor {{{
   * @Return {Associative Array}
   *   .curRelX:
   *   .curRelY:
   *   .hwnd: ex "0x20ace"
   *   .processName: ex "excel.exe"
   *   .title: ex "Microsoft Visual Basic for Application..."
   *   .winClass: ex "wndclass_desked_gsk"
   *   .ctrlHwnd: ex "0x10bb4"
   *   .ctrlClass: ex "VbaWindow1"
   *   .ctrlText  ;ex:"hoge.xls - MnModule (コード)"
   */
  class GetWindowInfoUnderCursor extends WindowUtil.Functor
  {
    Call(self)
    {
      savedCoordModeMouse := A_CoordModeMouse
      CoordMode, Mouse, Relative

      ; Get the Window HWND and Control HWND
      ; MouseGetPos https://www.autohotkey.com/docs/commands/MouseGetPos.htm
      MouseGetPos, curRelX, curRelY, winHwnd, ctrlHwnd, 3 ; Flag=3

      CoordMode, Mouse, Screen
      MouseGetPos, curAbsX, curAbsY, , ,3

      ; Test the Control HWND ID
      ; ControlにWM_NCHITTESTメッセージを送る wParam:なし、lParam:マウス座標
      lParam := (curAbsY << 16) | curAbsX
      SendMessage, %WM_NCHITTEST%, 0, %lParam%, , ahk_id %ctrlHwnd%

      ; 応答を待ちエラーならば,Controlの取得方法を変更してControlHWNDを再格納
      ; If ErrorLevel=%WN_SendMessageFAIL%
      if (ErrorLevel = "FAIL") {
        MouseGetPos, , , , ctrlHwnd, 2 ; Flag=2 -> Get Control HWND
      }

      ; Get ControlClassNN
      MouseGetPos, , , , ctrlClass, 0 ; Flag=0 -> Get Control Class Name

      ; Get othe window info.
      WinGet, processName, ProcessName, ahk_id %winHwnd%
      WinGetTitle, winTitle, ahk_id %winHwnd%
      WinGetClass, winClass, ahk_id %winHwnd%
      WinGetPos, winX, winY, winWidth, winHeight, ahk_id %winHwnd%
      ControlGetText, ctrlText, , ahk_id %ctrlHwnd%
      WinGet, ctrlHwnds, ControlListHWND, ahk_id %winHwnd%

      ; ; debug
      ; MsgBox, Cursor window Infomation`nX: %curRelX%`nY: %curRelY%`nWinHWND: %winHwnd%`nWinName: %processName%`nWinTitle: %winTitle%`nClassName: %winClass%`nControlHWND: %ctrlHwnd%`nControlClassNN: %ctrlClass%`nControlText: %ctrlText%

      info := {}
      ; Cursor
      info.curAbsX := curAbsX
      info.curAbsY := curAbsY
      info.curRelX := curRelX
      info.curRelY := curRelY
      ; Window
      info.winHwnd := winHwnd
      info.processName := processName
      info.pId := WindowUtil.FindProcessName(processName)
      info.winTitle := winTitle
      info.winClass := winClass
      info.winX := winX
      info.winY := winY
      info.winWidth := winWidth
      info.winHeight := winHeight
      ; Control
      info.ctrlClass := ctrlClass
      info.ctrlText := ctrlText
      info.ctrlHwnds := ctrlHwnds
      info.ctrlHwnd := ctrlHwnd

      CoordMode, Mouse, %savedCoordModeMouse%
      Return info
    }
  } ; }}}

  ; ============== CONTROL CONTROLLER
  /**
   * @Method PostMessageToControl
   * @Description Post the WM to the specified window {{{
   * @Link https://www.autohotkey.com/docs/commands/PostMessage.htm
   * @Param {String} wmMsg
   * @Param wParam
   * @Param lParam
   * @Param Others parameters, See @Method GetWindowHWNDs
   * @Return https://www.autohotkey.com/docs/commands/PostMessage.htm#ErrorLevel
   */
  class PostMessageToControl extends WindowUtil.Functor
  {
    Call(self, wmMsg, wParam, lParam, ctrl, winTitle
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      WindowUtil.SetModes(hidingDetector, titleMatchMode)

      PostMessage,% wmMsg,% wParam,% lParam,% ctrl,% winTitle
          ,% winText,% excludeTitle

      WindowUtil.RestoreModes()
      Return ErrorLevel
    }
  } ; }}}

  /**
   * @Method SendMessageToControl
   * @Description Send the WM to the specified window {{{
   * @Link https://www.autohotkey.com/docs/commands/PostMessage.htm
   * @Param {String} wmMsg
   * @Param wParam
   * @Param lParam
   * @Param Others parameters, See @Method GetWindowHWNDs
   * @Return https://www.autohotkey.com/docs/commands/PostMessage.htm#ErrorLevel
   */
  class SendMessageToControl extends WindowUtil.Functor
  {
    Call(self, wmMsg, wParam, lParam, ctrl, winTitle
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      WindowUtil.SetModes(hidingDetector, titleMatchMode)

      SendMessage,% wmMsg,% wParam,% lParam,% ctrl,% winTitle
          ,% winText,% excludeTitle

      WindowUtil.RestoreModes()
      Return ErrorLevel
    }
  } ; }}}

  /**
   * @Method SendMessageAsStr
   * @Description Send the specified string to the specified window {{{
   * @Link https://www.autohotkey.com/docs/commands/OnMessage.htm
   * @Param {String} wmMsg
   * @Param {String} strToSend Ex:"This is my password"
   * @Param {String} ctrl Either ClassNN (the classname and instance number of the control) or the control's text
   * Other parameters and return, See @Method GetWindowHWNDs
   * @Return https://www.autohotkey.com/docs/commands/PostMessage.htm#ErrorLevel
   */
  class SendMessageAsStr extends WindowUtil.Functor
  {
    Call(self, wmMsg, strToSend, ctrl, winTitle
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      ; Set up the structure's memory area.
      VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)

      ; First set the structure's cbData member to the size of the string,
      ; including its zero terminator:
      SizeInBytes := (StrLen(strToSend) + 1) * (A_IsUnicode ? 2 : 1)

      ; OS requires that this be done.
      NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)

      ; Set lpData to point to the string itself.
      NumPut(&strToSend, CopyDataStruct, 2*A_PtrSize)

      WindowUtil.SendMessageToControl(wmMsg, 0, &CopyDataStruct, ctrl, winTitle
          , winText, excludeTitle, hidingDetector, titleMatchMode)

      Return ErrorLevel
    }
  } ; }}}

  /**
   * @Method SetTextToControl
   * @Description Set the text to a window or control. {{{
   * @Link https://www.autohotkey.com/docs/commands/ControlSetText.htm
   * @Param {String} newText Ex:"This is my password"
   * @Param {String} ctrl Either ClassNN (the classname and instance number of the control) or the control's text
   * @Param Others parameters, See @Method GetWindowHWNDs
   * @Return {Number} 0:success
   */
  class SetTextToControl extends WindowUtil.Functor
  {
    Call(self, newText, ctrl, winTitle
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      WindowUtil.SetModes(hidingDetector, titleMatchMode)

      ControlSetText,% ctrl,% newText,% winTitle,% winText,% excludeTitle

      WindowUtil.RestoreModes()
      Return ErrorLevel
    }
  } ; }}}

  /**
   * @Method SendKeystrokes
   * @Description Sends simulated keystrokes to a window or control. {{{
   * @Link https://www.autohotkey.com/docs/commands/ControlSend.htm
   * @Param {String} keystrokes Ex:"This is my password{Enter}"
   * @Param {String} ctrl Either ClassNN (the classname and instance number of the control) or the control's text
   * @Param Others parameters, See @Method GetWindowHWNDs
   * @Return {Number} 0:success
   */
  class SendKeystrokes extends WindowUtil.Functor
  {
    Call(self, keystrokes, ctrl, winTitle
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      WindowUtil.SetModes(hidingDetector, titleMatchMode)

      ControlSend,% ctrl,% keystrokes,% winTitle,% winText,% excludeTitle

      if (ErrorLevel != 0) { ; IF error, retry
        ctrlHwnd := WindowUtil.GetControlHwnd(ctrl, winTitle
            , winText, excludeTitle, hidingDetector, titleMatchMode)
        ControlSend, , %keystrokes%, ahk_id %ctrlHwnd%
      }

      WindowUtil.RestoreModes()
      Return ErrorLevel
    }
  } ; }}}

  ; ============== WINDOW HANDLER
  /**
   * @Method ActivateWindow
   * @Description Activates the specified window {{{
   * @Param See @Method GetWindowHWNDs
   * @Return {}
   */
  class ActivateWindow extends WindowUtil.Functor
  {
    Call(self, winTitle
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      WindowUtil.SetModes(hidingDetector, titleMatchMode)

      ; Unhides the specified window.
      ; @Link https://www.autohotkey.com/docs/commands/WinShow.htm
      WinShow,% winTitle,% winText,% excludeTitle

      WinActivate,% winTitle,% winText,% excludeTitle

      WindowUtil.RestoreModes()
      Return
    }
  } ; }}}

  /**
   * @Method WaitForWindowAppeared {{{
   * @Param See @Method GetWindowHWNDs
   * @Return {String} Window HWND
   */
  class WaitForWindowAppeared extends WindowUtil.Functor
  {
    Call(self, winTitle, waitSec:=0
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      WindowUtil.SetModes(hidingDetector, titleMatchMode)

      WinWait, %winTitle%, %winText%, %waitSec%, %excludeTitle%

      if (ErrorLevel != 0) {
        MsgBox,% MB_IconStop, WinWait ErrorLevel: %ErrorLevel%
            , Waited for %waitSec% seconds, but "%winTitle%" is not appeared.
        winHwnd := 0
      } else {
      /**
        * @Function WinGet
        Retrieves the specified window's unique ID, process ID, process name, or
        a list of its controls. It can also retrieve a list of
        all windows matching the specified criteria.
        WinGet, OutputVar , Cmd, WinTitle, WinText, ExcludeTitle, ExcludeText
        * @Param {Cmd} ID, IDLast, PID, ProcessName, ProcessPath, Count, ...
        * @Link https://autohotkey.com/docs/commands/WinGet.htm
        */
        WinGet, winHwnd, ID, %winTitle%, %winText%, %excludeTitle%
      }

      WindowUtil.RestoreModes()
      Return winHwnd
    }
  } ; }}}

  /**
   * @Method WaitForWindowActivated {{{
   * @Param See @Method GetWindowHWNDs
   * @Return {String} Window HWND
   */
  class WaitForWindowActivated extends WindowUtil.Functor
  {
    Call(self, winTitle, waitSec:=0
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      WindowUtil.SetModes(hidingDetector, titleMatchMode)

      WinWaitActive, %winTitle%, %winText%, %waitSec%, %excludeTitle%
      if (ErrorLevel != 0) {
        MsgBox,% MB_IconStop, WinWait ErrorLevel: %ErrorLevel%
            , Waited for %waitSec% seconds, but "%winTitle%" is not activated.
      }

      WindowUtil.RestoreModes()
      Return
    }
  } ; }}}

  /**
   * @Method WaitForWindowExist {{{
   * @Param See @Method GetWindowHWNDs
   * @Return {String} Window HWND
   */
  class WaitForWindowExist extends WindowUtil.Functor
  {
    Call(self, winTitle, waitSec:=0
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      WindowUtil.SetModes(hidingDetector, titleMatchMode)

      winHwnds := WindowUtil.GetWindowHWNDs(winTitle, winText, excludeTitle)
      winHwnd := ""
      For key, val in winHwnds
      {
        winHwnd := val
        Break
      }

      if (winHwnd = "") {
        winHwnd := WindowUtil.WaitForWindowAppeared(winTitle, waitSec
            , winText, excludeTitle, hidingDetector, titleMatchMode)
      }

      WindowUtil.RestoreModes()
      Return winHwnd
    }
  } ; }}}

  /**
   * @FIXME Not working on Windows 10
   * @Method ActivateProcessFromTasktray
   * @Description タスクトレイも含めたプロセスをアクティブにする {{{
   * @Link http://d.hatena.ne.jp/centigrade/20080303/p1
   * @Return Window Hwnd ID
   */
  class ActivateProcessFromTasktray extends WindowUtil.Functor
  {
    Call(self, processName)
    {
      Process, Exist, %processName%
      processID := ErrorLevel

      if (processID == False) {
        Return False
      }

      ; The process has a window.
      WinGet, winHwnd, , ahk_pid %appPID%
      IfWinExist, ahk_id %winHwnd%
      {
        WinActivate
        Return winHwnd
      }

      ; Search in TaskTray.
      DetectHiddenWindows, On
      ;cnt := Tray_GetCount() ; *Require TaskTrayIcon.ahk
      rtn := False

      Loop, %cnt% {
        ; @FIXME Not working on Windows 10
        ; Tray_GetInfo(A_Index, winHwnd, uid, msg, icon)
        WinGet, pn, ProcessName, ahk_id %winHwnd%

        MsgBox, %msg% - %uid% - %winHwnd%
        if (pn = processName) {
          PostMessage, %msg%, %uid%, 0x203, , ahk_id %winHwnd%
          rtn := winHwnd
          Break
        }
      }
      DetectHiddenWindows, Off

      Return rtn
    }
  } ; }}}

  /**
   * @Method MinimizeWindow
   * @Description Collapse the specified window into the task bar. {{{
   * @Syntax WindowUtil.MinimizeWindow(...)
   * @Param See @Method GetWindowHWNDs
   * @Return
   */
  class MinimizeWindow extends WindowUtil.Functor
  {
    Call(self, winTitle
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      WindowUtil.SetModes(hidingDetector, titleMatchMode)

      WinMinimize, %winTitle%, %winText%, %excludeTitle%

      ; If a particular type of window does not respond correctly to WinMinimize,
      ; try using the following instead: 0x112=WM_SYSCOMMAND 0xF020=SC_MINIMIZE
      PostMessage, 0x112, 0xF020, , , %winTitle%, %winText%

      WindowUtil.RestoreModes()
      Return
    }
  } ; }}}

  /**
   * @Method MoveWindowUnderCursor
   * @Description 引数のキーを押している間、ウィンドウ位置がマウスに追従 {{{
   * @Param downKey [Win] is not work.
   */
  class MoveWindowUnderCursor extends WindowUtil.Functor
  {
    Call(self, downKey)
    {
      savedCoordModeMouse := A_CoordModeMouse
      CoordMode, Mouse, Screen

      MouseGetPos, startX, startY, winHwnd, winClass,
      WinGetPos, winX, winY, winW, winH, ahk_id %winHwnd%
      ; WinActivate, ahk_id %winHwnd%

      While GetKeyState(downKey, "P") {
        MouseGetPos, nowX, nowY
        ; ToolTip, %nowX% %nowY% ; Debug
        lenX := startX - nowX
        lenY := startY - nowY
        WinMove, ahk_id %winHwnd%, , winX - lenX, winY - lenY, ,
        Sleep, 20
      }

      CoordMode, Mouse, %savedCoordModeMouse%
      Return
    }
  } ; }}}

  /**
   * @Method ResizeWindowUnderCursor
   * @Description ウィンドウサイズ変更 {{{
   * @Param downKey [Win] is not work.
   */
  class ResizeWindowUnderCursor extends WindowUtil.Functor
  {
    Call(self, downKey)
    {
      savedCoordModeMouse := A_CoordModeMouse

      CoordMode, Mouse, Screen
      MouseGetPos, startX, startY, winHwnd, winClass,
      WinGetPos, winX, winY, winW, winH, ahk_id %winHwnd%
      ; WinActivate, ahk_id %winHwnd%

      While GetKeyState(downKey, "P") {
        MouseGetPos, nowX, nowY
        ; ToolTip, %nowX% %nowY% ; Debug
        lenX := startX - nowX
        lenY := startY - nowY

        if (GetKeyState("Shift", "P")) { ; From top-left
          WinMove, ahk_id %winHwnd%, , winX - lenX, winY - lenY
              , winW + lenX, winH + lenY
        } else { ; From bottom-right
          WinMove, ahk_id %winHwnd%, , , , winW - lenX, winH - lenY
          ; WinMove, A, , , , winW - lenX, winH - lenY
        }

        Sleep, 20
      }

      CoordMode, Mouse, %savedCoordModeMouse%
      Return
    }
  } ; }}}

  ; ============== CURSOR HANDLER
  /**
   * @Method MoveCursorToCaret
   * @Description マウスカーソルをキャレットの位置に移動させる {{{
   */
  class MoveCursorToCaret extends WindowUtil.Functor
  {
    Call(self)
    {
      /**
       * @Function CoordMode
       * @Description 各種座標の扱いをスクリーン上での絶対位置にするか
       *     アクティブウィンドウからの相対位置にするかを設定する
       * @Param Param1 ToolTip, Pixel, Mouse, Caret, Menu
       * @Param [Param2=Screen] Screen, Relative[default], Windows, Client
       */
      CoordMode, Mouse, Screen
      CoordMode, Caret, Screen

      if (A_CaretX != 0 && A_CaretY != 0) {
        MouseMove, %A_CaretX%, %A_CaretY%
      }

      ; 変更した座標取得方法をデフォルト(Relative)に戻す
      CoordMode, Mouse, Relative
      CoordMode, Caret, Relative
      Return
    }
  } ; }}}

  /**
   * @Method RightClickCaretCoord
   * @Description キャレットの座標で右クリック {{{
      キャレットが存在しない場合はCursorの位置
   */
  class RightClickCaretCoord extends WindowUtil.Functor
  {
    Call(self)
    {
      WindowUtil.MoveCursorToCaret()
      Send, {RButton}
      Return
    }
  } ; }}}

  /**
   * @Method DoubleClickCaretCoord
   * @Description キャレットの座標でダブルクリック {{{
      キャレットが存在しない場合はCursorの位置
   */
  class DoubleClickCaretCoord extends WindowUtil.Functor
  {
    Call(self)
    {
      WindowUtil.MoveCursorToCaret()
      Send, {LButton 2}
      Return
    }
  } ; }}}

  ; ============== OTHERS
  /**
   * @FIXME Not worked on Windows 10?
   * @Method ShowTooltip {{{
   */
  class ShowTooltip extends WindowUtil.Functor
  {
    Call(self, txt, msec)
    {
      ToolTip, %txt%
      SetTimer, RemoveToolTip, %msec%
      Return

      ; !!?? Global Label
      RemoveToolTip:
        SetTimer, RemoveToolTip, Off
        ToolTip
        Return
    }
  } ; }}}

  /**
   * @Method ShowTrayTip {{{
   */
  class ShowTrayTip extends WindowUtil.Functor
  {
    Call(self, txt, msec)
    {
      TrayTip, Timed TrayTip, %txt%
      SetTimer, RemoveTrayTip, %msec%
      Return

      ; !!?? Global Label
      RemoveTrayTip:
        SetTimer, RemoveTrayTip, Off
        TrayTip  ; バルーンヒントを消去
        Return
    }
  } ; }}}

  /**
   * @Method SetModes {{{
   * @Param {String} [hidingDetector="OFF"] Detect hidden windows
   * @Param {Number} [titleMatchMode=1] (1)start, (2)contain, (3)exactly match, (RegEx)
   */
  SetModes(hidingDetector:="OFF", titleMatchMode:=1)
  {
    this.savedDetectHidWin := A_DetectHiddenWindows
    if (hidingDetector = "OFF" || hidingDetector = 0 || hidingDetector = "") {
      DetectHiddenWindows, Off
    } else {
      DetectHiddenWindows, On
    }

    this.savedTitleMatchMode := A_TitleMatchMode
    if (titleMatchMode = "" || titleMatchMode = "START") {
      SetTitleMatchMode, 1
    } else if (titleMatchMode = 2 || titleMatchMode = "CONTAIN") {
      SetTitleMatchMode, 2
    } else if (titleMatchMode = 3 || titleMatchMode = "EXACTLY") {
      SetTitleMatchMode, 3
    } else if (titleMatchMode = "RegEx") {
      SetTitleMatchMode, RegEx
    }

    Return
  } ; }}}

  /**
   * @Method RestoreModes {{{
   */
  RestoreModes()
  {
    DetectHiddenWindows,% this.savedDetectHidWin
    SetTitleMatchMode,% this.savedTitleMatchMode
    Return
  } ; }}}

  class Functor
  {
    __Call(method, args*)
    {
    ; When casting to Call(), use a new instance of the "function object"
    ; so as to avoid directly storing the properties(used across sub-methods)
    ; into the "function object" itself.
      if (method == "")
        Return (new this).Call(args*)
      if (IsObject(method))
        Return (new this).Call(method, args*)
    }
  }
}

; vim:set foldmethod=marker commentstring=;%s :
