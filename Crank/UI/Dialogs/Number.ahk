; === Script Information =======================================================
; Name .........: Number Dialog
; Description ..: Dialog for entering number values
; AHK Version ..: 1.1.36.02 (Unicode 64-bit)
; Start Date ...: 04/13/2023
; OS Version ...: Windows 10
; Language .....: English - United States (en-US)
; Author .......: Austin Fishbaugh <austin.fishbaugh@gmail.com>
; Filename .....: Number.ahk
; ==============================================================================

; === Revision History =========================================================
; Revision 1 (04/13/2023)
; * Added This Banner
;
; Revision 2 (04/21/2023)
; * Update for ahk v2
;
; === TO-DOs ===================================================================
; ==============================================================================
; ! DO NOT INCLUDE DEPENDENCIES HERE, DO SO IN TOP-LEVEL PARENT
; UI.Dialogs.Number
class Number extends UI.Dialogs.Base
{
    define()
    {
        if (!this.data.has("min") || !this.data.has("max")) {
            throw Error("ProgrammerException", A_ThisFunc, "Either 'min' or 'max' is not defined", A_LineFile, A_LineNumber)
        }
        options := "Range" this.data["min"] "-" this.data["max"]
        this.addControl("Edit")
        this.addControl("UpDown", options, 0)
    }
}