# AhkWinUtil

## Overview

**AhkWinUtil** is a collection of utility functions for window and control manipulation in AutoHotkey v1.1. It provides an easy-to-use API for tasks like retrieving window handles, process IDs, controls, activating or minimizing windows, and more.  
This library streamlines many WinXX commands by offering higher-level functions that manage hidden windows, title match modes, and error handling.

**Requirements**:  

- AutoHotkey v1.1.x (officially tested)  
- Not confirmed to work on AutoHotkey v2.0 or newer.

## Installation

1. **Download or Clone**  
   - Obtain this repository and place it in your desired directory (e.g., `AhkWinUtil`).
2. **Include the Class**  
   - In your script, add the following lines:

     ```ahk
     #Include %A_ScriptDir%\AhkWinUtil\Libs\Global_WindowMessages.ahk
     #Include %A_ScriptDir%\AhkWinUtil\Libs\Class_WinUtil.ahk
     ```

   - Or copy the contents directly into your own code if you prefer.
3. **Verify AutoHotkey Version**  
   - This library is intended for AutoHotkey v1.1.x. It has not been confirmed to work in v2.0 or higher.

## Usage

Once included, you can call methods via `WindowUtil.<MethodName>`:

- **`WindowUtil.GetWindowHWNDs(winTitle, winText, excludeTitle, hidingDetector, titleMatchMode)`**  
  Retrieves an array of window handles (`ahk_id`).  
- **`WindowUtil.GetProcessID(winTitle, ...)`**  
  Obtains the PID of the specified window, or the active window if no parameters are given.  
- **`WindowUtil.GetControlHwnd(ctrlName, winTitle, ...)`**  
  Finds the control handle of a given control name/class within a target window.  
- **`WindowUtil.WaitForWindowExist(winTitle, waitSec, ...)`**  
  Waits for a specific window to exist; can optionally time out.  
- **`WindowUtil.MinimizeWindow(winTitle, ...)`**  
  Minimizes a window using `WinMinimize` and a fallback `PostMessage` command.  
- **`WindowUtil.SendKeystrokes(keystrokes, ctrl, winTitle, ...)`**  
  Sends simulated keystrokes to a control or window.  
- **`WindowUtil.MoveWindowUnderCursor(downKey)`**  
  Allows the current window to be dragged/moved by holding a specified key while the mouse moves.  
- **`WindowUtil.SetModes(hidingDetector, titleMatchMode)`** & **`WindowUtil.RestoreModes()`**  
  Internally used to toggle `DetectHiddenWindows` and `SetTitleMatchMode` for a consistent environment.

## Examples

```ahk
#Include %A_ScriptDir%\AhkWinUtil\Libs\Global_WindowMessages.ahk
#Include %A_ScriptDir%\AhkWinUtil\Libs\Class_WinUtil.ahk

; Get all window handles
allHwnds := WindowUtil.GetWindowHWNDs()
MsgBox, % "Total windows found: " allHwnds.Length()

; Activate a specific window by title
WindowUtil.ActivateWindow("Untitled - Notepad")

; Send keystrokes to a Notepad window
WindowUtil.SendKeystrokes("Hello, world{Enter}", "", "Untitled - Notepad")

; Wait for a window to appear
someHwnd := WindowUtil.WaitForWindowExist("Chrome", 5)
if (someHwnd)
{
    MsgBox, "Chrome window found: " someHwnd
}
else
{
    MsgBox, "Chrome window not found within 5 seconds."
}
```

## License

This project is licensed under the [MIT License](./LICENSE). You are free to use, modify, and distribute it.

## Contact

- **Author**: Tuckn  
- **X (Twitter)**: [https://x.com/Tuckn333](https://x.com/Tuckn333)
