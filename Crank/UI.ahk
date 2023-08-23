; === Script Information =======================================================
; Name .........: Master UI parent class
; Description ..: Handles/houses most custom UI functionality
; AHK Version ..: 1.1.36.02 (Unicode 64-bit)
; Start Date ...: 04/09/2023
; OS Version ...: Windows 10
; Language .....: English - United States (en-US)
; Author .......: Austin Fishbaugh <austin.fishbaugh@gmail.com>
; Filename .....: UI.ahk
; ==============================================================================

; === Revision History =========================================================
; Revision 1 (04/09/2023)
; * Added This Banner
; * Update to not force certain widths on utility *Box methods
;
; Revision 2 (04/19/2023)
; * Update for ahk v2
;
; === TO-DOs ===================================================================
; ==============================================================================
class UI
{
    ; --- Sub-Classes ----------------------------------------------------------
    #Include UI/Base.ahk
    #Include UI/Dialogs.ahk
    #Include UI/Installer.ahk
    #Include UI/InstallerPage.ahk

    ; --- Utility methods ------------------------------------------------------

    /**
     * Disables a windows close button. 
     * The button still exists, but it becomes unclickable. This might only work
     * for windows using the +ToolWindow option.
     */

    static disableCloseButton(hwnd := "")
    {
        if (hWnd = "")
        {
            hWnd := WinExist("A")
        }
        hSysMenu := DllCall("GetSystemMenu", "Int", hWnd, "Int", FALSE)
        nCnt := DllCall("GetMenuItemCount", "Int", hSysMenu)
        DllCall("RemoveMenu", "Int", hSysMenu, "Uint", nCnt - 1, "Uint", "0x400")
        DllCall("RemoveMenu", "Int", hSysMenu, "Uint", nCnt - 2, "Uint", "0x400")
        DllCall("DrawMenuBar", "Int", hWnd)
    }

    /**
     * Creates a parent/child relationship between two windows. 
     * Works a little better for parent windows that aren't AHK created
     */
    static setParent(child_hwnd, parent_hwnd)
    {
        DllCall("SetParent", "Ptr", child_hwnd, "Ptr", parent_hwnd)
    }

    /**
     * Determines whether a control exists within a window
     */
    static controlExist(Control, WinTitle := "", WinText := "", ExcludeTitle := "", ExcludeText := "") {
        try {
            return ControlGetHwnd(Control, WinTitle, WinText, ExcludeTitle, ExcludeText)
        } catch {
            return false
        }
    }

    /**
     * Set the width/height of the client area, instead of the whole window.
     */
    static setClientPos(guiObj, x?, y?, width?, height?)
    {
        ; Account for exterior dimensions in width/height setting
        borderWidthX := SysGet(SM_CXBORDER := 5)
        borderWidthY := SysGet(SM_CYBORDER := 6)
        titleBarHeight := SysGet(SM_CYSIZE := 30)
        if (IsSet(width)) {
            width += borderWidthX * 2
        }
        if (IsSet(height)) {
            height += titleBarHeight + (borderWidthY * 2)
        }
        ; Set the position/dimensions
        guiObj.move(x?, y?, width?, height?)
    }
}