; ==== Script Information ======================================================
; Name .........: UI.InstallerPage
; Description ..: An child window, passed to an Installer instance
; AHK Version ..: 2.* (Unicode 64-bit)
; Start Date ...: 08/15/2023
; OS Version ...: Windows 10
; Language .....: English - United States (en-US)
; Author .......: Austin Fishbaugh <austin.fishbaugh@gmail.com>
; Filename .....: InstallerPage.ahk
; ==============================================================================

; ==== Revision History ========================================================
; Revision 1 (08/15/2023)
; * Added This Banner
;
; ==== TO-DOs ==================================================================
; ==============================================================================

; UI.InstallerPage
class InstallerPage
{
    parent := Object()
    events := Object()
    controls := Map()
    guiObj := Object()
    height := 0
    width := 0
    options := ""
    built := false

    __New(parent, eventSink?)
    {
        this.parent := parent
        this.options := "-Border +OwnDialogs -SysMenu -Caption +ToolWindow +Parent" parent.hwnd
        if (IsSet(eventSink)) {
            this.events := eventSink
            this.guiObj := Gui(this.options, "", this.events)
        } else {
            this.guiObj := Gui(this.options, "", this)
        }
    }

    __Call(method, args)
    {
        if (this.guiObj is Gui && this.guiObj.hasMethod(method)) {
            if (args.Length) {
                return this.guiObj.%method%(args*)
            } else {
                return this.guiObj.%method%()
            }
        }
    }

    build()
    {
        this.built := true
    }

    getDimensions()
    {
        topBorderY := bottomBorderY := parentWidth := 0
        this.parent.controls["childAreaTop"].GetPos(unset, &topBorderY)
        this.parent.controls["childAreaBottom"].GetPos(unset, &bottomBorderY)
        this.parent.GetClientPos(unset, unset, &parentWidth)

        this.fullHeight := bottomBorderY - topBorderY
        this.fullWidth := parentWidth
        this.height := this.fullHeight - (this.parent.marginY * 2)
        this.width := this.fullWidth - (this.parent.marginX * 2)
    }

    show(options?)
    {
        this.getDimensions()
        if (!this.built) {
            this.build()
        }
        this.guiObj.Show('x0 y80 w' this.fullWidth " h" this.fullHeight)
        this.performActions()
    }

    performActions()
    {

    }

    validate()
    {
        return true
    }

    collect()
    {

    }
}