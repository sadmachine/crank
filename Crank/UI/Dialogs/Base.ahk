; === Script Information =======================================================
; Name .........: Base Dialog
; Description ..: Base Dialog for all other dialogs to inherit from
; AHK Version ..: 1.1.36.02 (Unicode 64-bit)
; Start Date ...: 04/09/2023
; OS Version ...: Windows 10
; Language .....: English - United States (en-US)
; Author .......: Austin Fishbaugh <austin.fishbaugh@gmail.com>
; Filename .....: Base.ahk
; ==============================================================================

; === Revision History =========================================================
; Revision 1 (04/09/2023)
; * Added This Banner
; * Update to auto set control text to data.value, if it exists + no text given
;
; Revision 2 (04/21/2023)
; * Update for ahk v2
;
; === TO-DOs ===================================================================
; ==============================================================================
; ! DO NOT INCLUDE DEPENDENCIES HERE, DO SO IN TOP-LEVEL PARENT
; UI.Dialogs.Base
class Base extends UI.Base
{
    data := ""
    addedControls := []
    controls := []
    output := Map()

    __New(title, data := Map())
    {
        this.data := data
        randomNum := Random()
        options := "-SysMenu +AlwaysOnTop"

        super.__New(title, options, this)
    }

    addControl(controlType, options := "", text := "")
    {
        ; If text was not passed in, and our data has a "value" key, use that for text
        if (text == "" && this.data.Has("value")) {
            text := this.data.value
        }

        this.controls.push({ controlType: controlType, options: options, text: text })
    }

    prompt(promptMessage := "")
    {
        Global
        this.define()
        this.ApplyFont()

        text := promptMessage || this.title

        this.Add("Text", unset, text)

        for n, control in this.controls {
            if (n == 1) {
                this.mainControl := this.Add(control.controlType, control.options, control.text)
            } else {
                this.Add(control.controlType, control.options, control.text)
            }
        }

        SaveButton := this.Add("Button", "xm Default", "Save")
        CancelButton := this.Add("Button", "x+10", "Cancel")

        SaveButton.OnEvent("Click", "SubmitEvent")
        CancelButton.OnEvent("Click", "CancelEvent")
        this.OnEvent("Close", "CancelEvent")

        this.Show("xCenter yCenter")
        WinWaitClose(this.title)

        return this.output
    }

    SubmitEvent(guiCtrlObj, info)
    {
        this.Submit()
        resultValue := this.mainControl.Text
        this.output := { value: resultValue, canceled: false }
    }

    CancelEvent(guiCtrlObj, info)
    {
        this.Destroy()
        this.output := { value: "", canceled: true }
    }

    getOutput() {
        return this.output
    }
}