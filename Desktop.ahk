/**
 * @Updated 2019/06/22
 * @Fileoverview Desktop manager for AutoHotkey
 * @Fileencodeing UTF-8[dos]
 * @Requirements AutoHotkey (v1.0.46+ or v2.0-a+)
 *  https://github.com/tuckn/AhkConstValues
 * @Installation
 *   Use #Include %A_ScriptDir%\AhkDesktopManager\Desktop.ahk or copy into your code
 * @License MIT
 * @Links https://github.com/tuckn/AhkDesktopManager
 * @Author Tuckn
 * @Email tuckn333+github@gmail.com
 */

/**
 * @Class Desktop
 * @Discription The Desktop object contains methods for parsing
 * @Note
 *   ahk_class is a name of window template type. not unique.
 *   ahk_id is a HWND. This is short for Hnandle to WiNDow(window handle ID).
 *   ahk_pid is a PID(process ID).
 * @Methods
 */
class Desktop
{
  savedDetectHidWin := A_DetectHiddenWindows
  savedTitleMatchMode := A_TitleMatchMode

  ; ============== HANDLE GETTER
  /**
   * @Method GetWindowHwnds
   * @Description Get window handles. {{{
   * @Syntax winHwnd := Desktop.GetWindowHwnds(...)
   * @Param {String} [WinTitle=""] Empty is as all windows
   * @Param {String} [winText=""]
   * @Param {String} [excludeTitle=""]
   * @Param {String} [hidingDetector="OFF"] See @Method SetModes
   * @Param {Number} [titleMatchMode=1] See @Method SetModes
   * @Return {Array}
   */
  class GetWindowHwnds extends Desktop.Functor
  {
    Call(self, winTitle:=""
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      Desktop.SetModes(hidingDetector, titleMatchMode)

      ; Get a list of ahk_id(= window handle ID).
      WinGet, idsList, List,% winTitle,% winText,% excludeTitle

      winHwnds := []
      Loop, %idsList%
      {
        winHwnds.Insert(idsList%A_Index%)
      }

      Desktop.RestoreModes()
      Return winHwnds
    }
  } ; }}}

  /**
   * @Method GetProcessID
   * @Description Get s process ID {{{
   * @Syntax pId := Desktop.GetProcessID(...)
   *   When all parameters is empty, get the active window PID.
   * @Param See @Method GetWindowHwnds
   * @Return {String}
   */
  class GetProcessID extends Desktop.Functor
  {
    Call(self, winTitle:=""
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      Desktop.SetModes(hidingDetector, titleMatchMode)

      ; Get the process ID. 複数ある場合は前面にあるものが優先される
      if (winTitle = "" && winText = "" && excludeTitle = "") {
        WinGet, pId, PID, A
      } else {
        WinGet, pId, PID, %winTitle%, %winText%, %excludeTitle%
      }

      Desktop.RestoreModes()
      Return pId
    }
  } ; }}}

  /**
   * @Method FindProcessName
   * @Description Find the process name {{{
   * @Syntax pId := Desktop.FindProcessName(ProcessName)
   * @Param {String} ProcessName
   * @Return {String} PID. if failed to get, return 0(False)
   */
  class FindProcessName extends Desktop.Functor
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
   * @Syntax winHwnd := Desktop.GetControlHwnd(...)
   * @Param {String} ctrlName
   * @Param Others parameters, See @Method GetWindowHwnds
   * @Return {String}
   */
  class GetControlHwnd extends Desktop.Functor
  {
    Call(self, ctrlName, winTitle
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      Desktop.SetModes(hidingDetector, titleMatchMode)

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
        IfEqual, exitCode, %G_ExitCodeOK%, Break

        ; Retry with regular expression matching(Slow)
        Loop, Parse, controls, `n
        {
          if (RegExMatch(A_LoopField, ctrlName) != 0) {
            ControlGet, ctrlHwnd, Hwnd,, %A_LoopField%, ahk_id %this_id%
            exitCode := ErrorLevel
            Break
          }
        }
        IfEqual, exitCode, %G_ExitCodeOK%, Break
      }

      Desktop.RestoreModes()
      Return ctrlHwnd
    }
  } ; }}}

  /**
   * @Method GetWindowInfo
   * @Description Find window Hwnd which is matched args {{{
   * @Syntax winInfo := Desktop.GetWindowInfo(...)
   * @Param See @Method GetWindowHwnds
   * @Return {Array} [{ hwnd, title }]
   */
  class GetWindowInfo extends Desktop.Functor
  {
    Call(self, winTitle:=""
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      Desktop.SetModes(hidingDetector, titleMatchMode)

      winHwnds := Desktop.GetWindowHwnds(winTitle
          , winText, excludeTitle, hidingDetector, titleMatchMode)
      winInfo := []

      For key, winHwnd in winHwnds
      {
        WinGetTitle, winTitle, ahk_id %winHwnd%
        winInfo.Insert({ hwnd: winHwnd, title: winTitle })
      }

      Desktop.RestoreModes()
      Return winInfo
    }
  } ; }}}

  /**
   * @Method GetActiveWindowInfo
   * @Description Get a active window information {{{
   * @Return {Associative Array} .hwnd, .processName, .title, .winClass, ...
   */
  class GetActiveWindowInfo extends Desktop.Functor
  {
    Call(self)
    {
      savedCoordModeMouse := A_CoordModeMouse
      CoordMode, Mouse, Screen

      winInfo := {}
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

      ; Window
      winInfo.winHwnd := winHwnd ; "0x20ace"
      winInfo.processName := processName ; "excel.exe"
      winInfo.pId := Desktop.FindProcessName(processName)
      winInfo.title := winTitle ; "Microsoft Visual Basic for Application..."
      winInfo.winClass := winClass ; "wndclass_desked_gsk"
      winInfo.winX := winX
      winInfo.winY := winY
      winInfo.winWidth := winWidth
      winInfo.winHeight := winHeight
      ; Control
      winInfo.ctrlClass := ctrlClass ; "VbaWindow1"
      winInfo.ctrlText := ctrlText ; "hoge.xls - MnModule (コード)"
      winInfo.ctrlHwnds := ctrlHwnds ; "0x10bb4"

      CoordMode, Mouse, %savedCoordModeMouse%
      Return winInfo
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
  class GetWindowInfoUnderCursor extends Desktop.Functor
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
      ; If ErrorLevel=%G_SendMessageFAIL%
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

      ; Cursor
      curInfo := {}
      curInfo.curAbsX := curAbsX
      curInfo.curAbsY := curAbsY
      curInfo.curRelX := curRelX
      curInfo.curRelY := curRelY
      ; Window
      curInfo.winHwnd := winHwnd
      curInfo.processName := processName
      curInfo.pId := Desktop.FindProcessName(processName)
      curInfo.winTitle := winTitle
      curInfo.winClass := winClass
      curInfo.winX := winX
      curInfo.winY := winY
      curInfo.winWidth := winWidth
      curInfo.winHeight := winHeight
      ; Control
      curInfo.ctrlClass := ctrlClass
      curInfo.ctrlText := ctrlText
      curInfo.ctrlHwnds := ctrlHwnds
      curInfo.ctrlHwnd := ctrlHwnd

      CoordMode, Mouse, %savedCoordModeMouse%
      Return curInfo
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
   * @Param Others parameters, See @Method GetWindowHwnds
   * @Return https://www.autohotkey.com/docs/commands/PostMessage.htm#ErrorLevel
   */
  class PostMessageToControl extends Desktop.Functor
  {
    Call(self, wmMsg, wParam, lParam, ctrl, winTitle
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      Desktop.SetModes(hidingDetector, titleMatchMode)

      PostMessage,% wmMsg,% wParam,% lParam,% ctrl,% winTitle
          ,% winText,% excludeTitle

      Desktop.RestoreModes()
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
   * @Param Others parameters, See @Method GetWindowHwnds
   * @Return https://www.autohotkey.com/docs/commands/PostMessage.htm#ErrorLevel
   */
  class SendMessageToControl extends Desktop.Functor
  {
    Call(self, wmMsg, wParam, lParam, ctrl, winTitle
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      Desktop.SetModes(hidingDetector, titleMatchMode)

      SendMessage,% wmMsg,% wParam,% lParam,% ctrl,% winTitle
          ,% winText,% excludeTitle

      Desktop.RestoreModes()
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
   * Other parameters and return, See @Method GetWindowHwnds
   * @Return https://www.autohotkey.com/docs/commands/PostMessage.htm#ErrorLevel
   */
  class SendMessageAsStr extends Desktop.Functor
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

      Desktop.SendMessageToControl(wmMsg, 0, &CopyDataStruct, ctrl, winTitle
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
   * @Param Others parameters, See @Method GetWindowHwnds
   * @Return {Number} 0:success
   */
  class SetTextToControl extends Desktop.Functor
  {
    Call(self, newText, ctrl, winTitle
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      Desktop.SetModes(hidingDetector, titleMatchMode)

      ControlSetText,% ctrl,% newText,% winTitle,% winText,% excludeTitle

      Desktop.RestoreModes()
      Return ErrorLevel
    }
  } ; }}}

  /**
   * @Method SendKeystrokes
   * @Description Sends simulated keystrokes to a window or control. {{{
   * @Link https://www.autohotkey.com/docs/commands/ControlSend.htm
   * @Param {String} keystrokes Ex:"This is my password{Enter}"
   * @Param {String} ctrl Either ClassNN (the classname and instance number of the control) or the control's text
   * @Param Others parameters, See @Method GetWindowHwnds
   * @Return {Number} 0:success
   */
  class SendKeystrokes extends Desktop.Functor
  {
    Call(self, keystrokes, ctrl, winTitle
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      Desktop.SetModes(hidingDetector, titleMatchMode)

      ControlSend,% ctrl,% keystrokes,% winTitle,% winText,% excludeTitle

      if (ErrorLevel != 0) { ; IF error, retry
        ctrlHwnd := Desktop.GetControlHwnd(ctrl, winTitle
            , winText, excludeTitle, hidingDetector, titleMatchMode)
        ControlSend, , %keystrokes%, ahk_id %ctrlHwnd%
      }

      Desktop.RestoreModes()
      Return ErrorLevel
    }
  } ; }}}

  ; ============== WINDOW HANDLER
  /**
   * @Method ActivateWindow
   * @Description Activates the specified window {{{
   * @Param See @Method GetWindowHwnds
   * @Return {}
   */
  class ActivateWindow extends Desktop.Functor
  {
    Call(self, winTitle
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      Desktop.SetModes(hidingDetector, titleMatchMode)

      ; Unhides the specified window.
      ; @Link https://www.autohotkey.com/docs/commands/WinShow.htm
      WinShow,% winTitle,% winText,% excludeTitle

      WinActivate,% winTitle,% winText,% excludeTitle

      Desktop.RestoreModes()
      Return
    }
  } ; }}}

  /**
   * @Method WaitForWindowAppeared {{{
   * @Param See @Method GetWindowHwnds
   * @Return {String} Window HWND
   */
  class WaitForWindowAppeared extends Desktop.Functor
  {
    Call(self, winTitle, waitSec:=0
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      Desktop.SetModes(hidingDetector, titleMatchMode)

      WinWait, %winTitle%, %winText%, %waitSec%, %excludeTitle%

      if (ErrorLevel != 0) {
        MsgBox,% G_MsgIconStop, WinWait ErrorLevel: %ErrorLevel%
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

      Desktop.RestoreModes()
      Return winHwnd
    }
  } ; }}}

  /**
   * @Method WaitForWindowActivated {{{
   * @Param See @Method GetWindowHwnds
   * @Return {String} Window HWND
   */
  class WaitForWindowActivated extends Desktop.Functor
  {
    Call(self, winTitle, waitSec:=0
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      Desktop.SetModes(hidingDetector, titleMatchMode)

      WinWaitActive, %winTitle%, %winText%, %waitSec%, %excludeTitle%
      if (ErrorLevel != 0) {
        MsgBox,% G_MsgIconStop, WinWait ErrorLevel: %ErrorLevel%
            , Waited for %waitSec% seconds, but "%winTitle%" is not activated.
      }

      Desktop.RestoreModes()
      Return
    }
  } ; }}}

  /**
   * @Method WaitForWindowExisting {{{
   * @Param See @Method GetWindowHwnds
   * @Return {String} Window HWND
   */
  class WaitForWindowExisting extends Desktop.Functor
  {
    Call(self, winTitle, waitSec:=0
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      Desktop.SetModes(hidingDetector, titleMatchMode)

      winHwnds := Desktop.GetWindowHwnds(winTitle, winText, excludeTitle)
      winHwnd := ""
      For key, val in winHwnds
      {
        winHwnd := val
        Break
      }

      if (winHwnd = "") {
        winHwnd := Desktop.WaitForWindowAppeared(winTitle, winSec
            , winText, excludeTitle, hidingDetector, titleMatchMode)
      }

      Desktop.RestoreModes()
      Return winHwnd
    }
  } ; }}}

  /**
   * @FIXME Not working on Windows 10
   * @Method ActivateProcessFormTasktray
   * @Description タスクトレイも含めたプロセスをアクティブにする {{{
   * @Link http://d.hatena.ne.jp/centigrade/20080303/p1
   * @Return Window Hwnd ID
   */
  class ActivateProcessFormTasktray extends Desktop.Functor
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
   * @Syntax Desktop.MinimizeWindow(...)
   * @Param See @Method GetWindowHwnds
   * @Return
   */
  class MinimizeWindow extends Desktop.Functor
  {
    Call(self, winTitle
        , winText:="", excludeTitle:="", hidingDetector:="OFF", titleMatchMode:=1)
    {
      Desktop.SetModes(hidingDetector, titleMatchMode)

      WinMinimize, %winTitle%, %winText%, %excludeTitle%

      ; If a particular type of window does not respond correctly to WinMinimize,
      ; try using the following instead: 0x112=WM_SYSCOMMAND 0xF020=SC_MINIMIZE
      PostMessage, 0x112, 0xF020, , , %winTitle%, %winText%

      Desktop.RestoreModes()
      Return
    }
  } ; }}}

  /**
   * @Method MoveWindowUnderCursor
   * @Description 引数のキーを押している間、ウィンドウ位置がマウスに追従 {{{
   * @Param downKey [Win] is not work.
   */
  class MoveWindowUnderCursor extends Desktop.Functor
  {
    Call(self, downKey)
    {
      savedCoordModeMouse := A_CoordModeMouse
      CoordMode, Mouse, Screen

      MouseGetPos, startX, startY, winHwnd, winClass,
      WinGetPos, winX, winY, winW, winH, ahk_id %winHwnd%
      WinActivate, ahk_id %winHwnd%

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
  class ResizeWindowUnderCursor extends Desktop.Functor
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
  class MoveCursorToCaret extends Desktop.Functor
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
   * @Method DoubleClickCaretCoord
   * @Description キャレットの位置をダブルクリック {{{
       キャレットが存在しない場合はCursorの位置
   */
  class DoubleClickCaretCoord extends Desktop.Functor
  {
    Call(self)
    {
      Desktop.MoveCursorToCaret()
      Send, {LButton 2}
      Return
    }
  } ; }}}

  ; ============== OTHERS
  /**
   * @FIXME Not worked on Windows 10?
   * @Method DisplayTooltip {{{
   */
  class DisplayTooltip extends Desktop.Functor
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
   * @Method DisplayTrayTip {{{
   */
  class DisplayTrayTip extends Desktop.Functor
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
