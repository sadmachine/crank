; === Script Information =======================================================
; Name .........: Dropdown Dialog
; Description ..: Dialog for choosing a value from a selection
; AHK Version ..: 1.1.36.02 (Unicode 64-bit)
; Start Date ...: 04/13/2023
; OS Version ...: Windows 10
; Language .....: English - United States (en-US)
; Author .......: Austin Fishbaugh <austin.fishbaugh@gmail.com>
; Filename .....: Dropdown.ahk
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
; UI.Dialogs.Dropdown
class Dropdown extends UI.Dialogs.Base
{
    define()
    {
        if (!this.data.Has("choices")) {
            throw Error("ProgrammerException", A_ThisFunc, "this.data is missing required key 'choices'", A_LineFile, A_LineNumber)
        }
        selected := ""
        if (this.data.Has("selected") && this.data["selected"] != "") {
            selected := this.data["selected"]
        }
        choices := this.data["choices"]
        choiceString := ""
        lastChoiceIsSelected := false
        for n, choice in choices {
            lastChoiceIsSelected := false
            choiceString .= choice "|"
            if (choice == selected) {
                choiceString .= "|"
                lastChoiceIsSelected := true
            }
        }
        if (!lastChoiceIsSelected) {
            choiceString := RTrim(choiceString, "|")
        }
        this.addControl("DropDownList", "", choiceString)
    }
}