/**
 * @Fileoverview Window Messages for AutoHotkey
 * @Fileencoding UTF-8[dos]
 * @Requirements AutoHotkey v1.1.x. Not confirmed to work on v2.0 or newer.
 * @Installation
 *   #Include %A_ScriptDir%\AhkWindowUtil\Libs\Global_WindowMessages.ahk
 * @License MIT
 * @Links https://github.com/tuckn/AhkWindowUtil
 * @Author Tuckn
 * @Email tuckn333@gmail.com
 */

Global WN_ExitCodeOK := 0
Global WN_ExitCodeERR := 1
; MsgBox Buttons
Global MB_BtnOk := 0x0 ; default
Global MB_BtnOC := 0x1
Global MB_BtnARI := 0x2
Global MB_BtnYNC := 0x3
Global MB_BtnYN := 0x4
Global MB_BtnRC := 0x5
Global MB_BtnCTAC := 0x6
; MsgBox Icon
Global MB_IconStop := 0x10
Global MB_IconQuestion := 0x20
Global MB_IconExclamation := 0x30
Global MB_IconInfo := 0x40

Global WN_TrayTipIconNone := 0
Global WN_TrayTipIconInfo := 0x1
Global WN_TrayTipIconWarning := 0x2
Global WN_TrayTipIconError := 0x3
Global WN_TrayTipNoSound := 0x10

Global WN_SendMessageFAIL := 0xFFFFFFFF ; 32と64で異なる？64は-1？

Global WN_NotActivate := "NA"

; Windows Messages
Global WM_NULL := 0x0000 ; 効果をもたないメッセージ
Global WM_MOVE := 0x0003 ; ウィンドウの移動
Global WM_SIZE := 0x0005 ; ウィンドウサイズ変更
Global WM_ACTIVATE := 0x0006 ; ウィンドウのアクティブ化・非アクティブ化
Global WM_SETTEXT := 0x000C ; ウィンドウタイトルやコントロールのテキストを設定
Global WM_GETTEXT := 0x000D ; ウィンドウタイトルやコントロールのテキストを取得
Global WM_GETTEXTLENGTH := 0x000E ; ウィンドウタイトルやコントロールのテキストのサイズを取得
Global WM_COPYDATA := 0x004A
Global WM_NOTIFY := 0x004E ; コモンコントロールからの通知
Global WM_CONTEXTMENU := 0x007B ; コンテキストメニューを表示するために受け取る通知
Global WM_GETICON := 0x007F ; ウィンドウのアイコンを取得
Global WM_MENUSELECT := 0x011F ; メニューアイテムが選択された
Global WM_SETFONT := 0x0030 ; コントロールのフォントを設定
Global WM_GETFONT := 0x0031 ; コントロールのフォントを取得
;   Keyboard Events
Global WM_KEYDOWN := 0x0100 ; 非システムキーが押された
Global WM_KEYUP := 0x0101 ; 押されていた非システムキーが離された
Global WM_CHAR := 0x0102 ; キーボードからの文字の入力

Global WM_COMMAND := 0x0111 ; メニューアイテムの選択・コントロールからの通知
Global WM_SYSCOMMAND := 0x0112 ; システムメニューアイテム選択
Global WM_VSCROLL := 0x0115 ; Scroll
;   Mouse Events
Global WM_MOUSEMOVE := 0x0200
Global WM_LBUTTONDOWN := 0x0201
Global WM_LBUTTONUP := 0x0202
Global WM_LBUTTONDBLCLK := 0x0203
Global WM_RBUTTONDOWN := 0x0204
Global WM_RBUTTONUP := 0x0205
Global WM_RBUTTONDBLCLK := 0x0206
Global WM_MBUTTONDOWN := 0x0207
Global WM_MBUTTONUP := 0x0208
Global WM_MBUTTONDBLCLK := 0x0209
Global WM_DROPFILES := 0x0233 ; ファイルがドロップされた
;   Events on EditControl
Global WM_CUT := 0x0300
Global WM_COPY := 0x0301
Global WM_PASTE := 0x0302
Global WM_CLEAR := 0x0303
Global WM_UNDO := 0x0304

Global WM_USER := 0x0400 ; アプリケーション定義メッセージの先頭
Global SB_SETPARTS := 0x0404 ; StatusBar
Global WM_NCHITTEST := 0x84 ; Test Control HWND

; vim:set foldmethod=marker commentstring=;%s :
