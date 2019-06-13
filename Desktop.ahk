/**
 * @Updated 2019/06/13
 * @Fileoverview Desktop manager for AutoHotkey
 * @License MIT
 * @Fileencodeing UTF-8[dos]
 * @Requirements AutoHotkey (v1.0.46+ or v2.0-a+)
 * @Installation
 *   Use #Include %A_ScriptDir%\AhkDesktopManager\Desktop.ahk or copy into your code
 * @Links Tuckn https://github.com/tuckn/AhkDesktopManager
 * @Email tuckn333@gmail.com
 */

Global EXIT_CODE_OK := 0
Global EXIT_CODE_ERR := 1
Global WM_NCHITTEST := 0x84
Global G_MsgIconStop := 0x10
Global G_SendMessageFAIL = 0xFFFFFFFF ; 32と64で異なる？64は-1？

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
  /**
   * @Method GetActiveWindowInfo
   * @Description Get a active window information {{{
   * @Return {Associative Array} .hwnd, .processName, .title, .winClass, ...
   */
  class GetActiveWindowInfo extends Desktop.Functor
  {
    Call(self)
    {
      winInfo := {}

      WinGet, winHwnd, ID, A ; Get a window HWND
      WinGet, processName, ProcessName, ahk_id %winHwnd%
      WinGetTitle, winTitle, ahk_id %winHwnd%
      WinGetClass, winClass, ahk_id %winHwnd%
      ControlGetFocus, ctrlClass, ahk_id %winHwnd%
      ControlGetText, ctrlText, , ahk_id %winHwnd%
      WinGet, ctrlHwnds, ControlListHWND, A
      ; ; 重そうだし、取得しても使用しない可能性が高いのでスキップ
      ; ; 取得したControl IDの最初だけ格納する
      ; Loop, Parse, ctrlHwnds, `n, `r
      ; {
      ;   ctrlName := A_LoopField
      ;   Break
      ;   ; MsgBox, 4, , File number %A_Index% is %A_LoopField%.`n`nContinue?
      ;   ; IfMsgBox, No, Break
      ; }

      ; ; Debug
      ; ToolTip, Active window`nWinHWND: %winHwnd%`nWinName: %processName%`nWinTitle: %winTitle%`nClassName: %winClass%`nControlHWND: %ctrlHwnds%`nControlClassNN: %ctrlClass%`nControlText: %ctrlText%

      ; Window
      winInfo.hwnd := winHwnd ; "0x20ace"
      winInfo.processName := processName ; "excel.exe"
      winInfo.title := winTitle ; "Microsoft Visual Basic for Application..."
      winInfo.winClass := winClass ; "wndclass_desked_gsk"
      ; Control
      winInfo.ctrlClass := ctrlClass ; "VbaWindow1"
      winInfo.ctrlText := ctrlText ; "hoge.xls - MnModule (コード)"
      winInfo.ctrlHwnds := ctrlHwnds ; "0x10bb4"

      Return winInfo
    }
  } ; }}}

  /**
   * @Method GetWindowInfoUnderCursor
   * @Description Get window information under the cursor {{{
   * @Return {Associative Array}
   *   .cursorX:
   *   .cursorY:
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
      winInfo := {}
      ; Get the Window HWND and Control HWND
      ; MouseGetPos https://www.autohotkey.com/docs/commands/MouseGetPos.htm
      MouseGetPos, cursorX, cursorY, winHwnd, ctrlHwnd, 3 ; Flag=3

      ; Test the Control HWND ID
      ; ControlにWM_NCHITTESTメッセージを送る wParam:なし、lParam:マウス座標
      lParam := (cursorY << 16) | cursorX
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
      ControlGetText, ctrlText, , ahk_id %ctrlHwnd%
      WinGet, ctrlHwnds, ControlListHWND, ahk_id %winHwnd%

      ; ; debug
      ; Msgbox, Cursor window Infomation`nX: %cursorX%`nY: %cursorY%`nWinHWND: %winHwnd%`nWinName: %processName%`nWinTitle: %winTitle%`nClassName: %winClass%`nControlHWND: %ctrlHwnd%`nControlClassNN: %ctrlClass%`nControlText: %ctrlText%

      ; Cursor
      winInfo.cursorX := cursorX
      winInfo.cursorY := cursorY
      ; Window
      winInfo.hwnd := winHwnd
      winInfo.processName := processName
      winInfo.title := winTitle
      winInfo.winClass := winClass
      ; Control
      winInfo.ctrlClass := ctrlClass
      winInfo.ctrlText := ctrlText
      winInfo.ctrlHwnds := ctrlHwnds
      winInfo.ctrlHwnd := ctrlHwnd

      Return winInfo
    }
  } ; }}}

  /**
   * @Method GetControlHwnd
   * @Description Get the control handle from the control name, window title. {{{
   * @Syntax winHwnd := Desktop.GetControlHwnd(...)
   * @Param {String} ctrlName
   * @Param {String} WinTitle
   * @Param {String} [winText=""]
   * @Param {String} [excludeTitle=""]
   * @Return {String}
   */
  class GetControlHwnd extends Desktop.Functor
  {
    Call(self, ctrlName, winTitle, winText="", excludeTitle="")
    {
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
        IfEqual, exitCode, %EXIT_CODE_OK%, Break

        ; Retry with regular expression matching(Slow)
        Loop, Parse, controls, `n
        {
          if (RegExMatch(A_LoopField, ctrlName) != 0) {
            ControlGet, ctrlHwnd, Hwnd,, %A_LoopField%, ahk_id %this_id%
            exitCode := ErrorLevel
            Break
          }
        }
        IfEqual, exitCode, %EXIT_CODE_OK%, Break
      }

      Return ctrlHwnd
    }
  } ; }}}

  /**
   * @Method FindWindowHwnds
   * @Description Find window Hwnd which is matched args {{{
   * @Syntax winHwnds := Desktop.FindWindowHwnds(...)
   * @Param {String} WinTitle
   * @Param {String} [winText=""]
   * @Param {String} [excludeTitle=""]
   * @Return {Array} [{ hwnd, title }]
   */
  class FindWindowHwnds extends Desktop.Functor
  {
    Call(self, winTitle, winTxt="", excludeTitle="")
    {
      info := []

      tmpDetectHid := A_DetectHiddenText
      DetectHiddenWindows, On

      ; Get windows Hwnd IDs.
      WinGet, winIds, List, %winTitle%, %winText%, %excludeTitle%
      Loop, %winIds%
      {
        ; Get ahk_id
        StringTrimRight, this_id, winIds%A_Index%, 0
        ; Get title
        WinGetTitle, thisTitle, ahk_id %this_id%
        info.Insert({ hwnd: this_id, title: thisTitle })
        ; titles .= "ahk_id " . this_id . ": [" . thisTitle . "]`n"; Debug
      }

      ; Msgbox, %titles% ; Debug
      DetectHiddenWindows, %tmpDetectHid%
      Return info
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

        Msgbox, %msg% - %uid% - %winHwnd%
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
   * @Param {String} WinTitle
   * @Param {String} [winText=""]
   * @Param {String} [excludeTitle=""]
   * @Return
   */
  class MinimizeWindow extends Desktop.Functor
  {
    Call(self, winTitle, winTxt="", excludeTitle="")
    {
      WinMinimize, %winTitle%, %winText%, %excludeTitle%

      ; If a particular type of window does not respond correctly to WinMinimize,
      ; try using the following instead: 0x112=WM_SYSCOMMAND 0xF020=SC_MINIMIZE
      PostMessage, 0x112, 0xF020, , , %winTitle%, %winText%
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

      CoordMode, Mouse, Relative
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

      CoordMode, Mouse, Relative
      Return
    }
  } ; }}}

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

  /**
   * @Method WaitForProcessAppeared {{{
   */
  class WaitForProcessAppeared extends Desktop.Functor
  {
    Call(self, pname, waitSec=0, showErr=False)
    {
      WinWait, ahk_exe %pname%, , %waitSec% ; wait up

      if (ErrorLevel) {
        if (showErr) {
          MsgBox,% G_MsgIconStop, WinWait ErrorLevel: %ErrorLevel%
              , Waited for %waitSec% seconds, but "%pname%" is not found.
        }
        Return False
      }

      Return True
    }
  } ; }}}

  /**
   * @Method WaitForWindowAppeared {{{
   * @Param {Number} [matchMode=1] (1)start, (2)contain, (3)exactly match, (RegEx)
   * @Param {} False or A Window HWND
   * @Return {String} Window HWND
   */
  class WaitForWindowAppeared extends Desktop.Functor
  {
    Call(self, winTitle, waitSec=0, excludeTitle="", matchMode=1, showErr=False)
    {
      tmpMatchMode := A_TitleMatchMode
      SetTitleMatchMode, %matchMode%

      WinWait, %winTitle%, , %waitSec%, %excludeTitle%

      if (ErrorLevel) {
        if (showErr) {
          MsgBox,% G_MsgIconStop, WinWait ErrorLevel: %ErrorLevel%
              , Waited for %waitSec% seconds, but "%winTitle%" is not found.
        }
        Return False
      }

     /**
       * @Function WinGet
       Retrieves the specified window's unique ID, process ID, process name, or
       a list of its controls. It can also retrieve a list of
       all windows matching the specified criteria.
       WinGet, OutputVar , Cmd, WinTitle, WinText, ExcludeTitle, ExcludeText
      * @Param {Cmd} ID, IDLast, PID, ProcessName, ProcessPath, Count, ...
      * @Link https://autohotkey.com/docs/commands/WinGet.htm
      */
      WinGet, winHwnd, ID, %winTitle%, , %excludeTitle%

      SetTitleMatchMode, %tmpMatchMode%
      Return winHwnd
    }
  } ; }}}

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
