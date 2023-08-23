; ==== Script Information ======================================================
; Name .........: UI.Installer
; Description ..: A generalized installer class for building program installers
; AHK Version ..: 2.0.2 (Unicode 64-bit)
; Start Date ...: 08/15/2023
; OS Version ...: Windows 10
; Language .....: English - United States (en-US)
; Author .......: Austin Fishbaugh <austin.fishbaugh@gmail.com>
; Filename .....: Installer.ahk
; ==============================================================================

; ==== Revision History ========================================================
; Revision 1 (08/15/2023)
; * Added This Banner
;
; ==== TO-DOs ==================================================================
; ==============================================================================
; ! IF THIS IS A SUBCLASS, DO NOT INCLUDE FILES HERE
; UI.Installer
class Installer extends UI.Base
{
    class EventHandler
    {
        parentObj := Object()

        __New(parentObj)
        {
            this.parentObj := parentObj
        }

        btnNext(GuiCtrlObj, Info)
        {
            page := this.parentObj.pages[this.parentObj.currentPageIndex]
            if (page.validate()) {
                this.parentObj.pages[this.parentObj.currentPageIndex].collect()
                this.parentObj.buildNextPage()
            }
        }

        btnPrev(GuiCtrlObj, Info)
        {
            page := this.parentObj.pages[this.parentObj.currentPageIndex]
            if (page.validate()) {
                this.parentObj.pages[this.parentObj.currentPageIndex].collect()
                this.parentObj.buildPrevPage()
            }
        }

        btnFinish(GuiCtrlObj, Info)
        {
            ExitApp
        }

        btnCancel(GuiCtrlObj, Info)
        {
            result := MsgBox("Are you sure you'd like to cancel the installation?", "Cancel", "YesNo Icon?")
            if (result == "Yes") {
                ExitApp
            }
        }
    }

    controls := Map()
    data := Map()
    pages := Array()
    events := Object()

    logoPath := ""
    versionStr := ""
    currentPageIndex := 1

    __New(title, versionStr, logoPath, options := "+OwnDialogs")
    {
        this.events := UI.Installer.EventHandler(this)

        this.versionStr := versionStr
        this.logoPath := logoPath

        super.__New(title, options, this.events)
        this.build()
    }

    registerPages()
    {

    }

    build()
    {
        this.registerPages()
        this.SetFont("s9", "Segoe UI")
        this.controls["childAreaTop"] := this.Add("Text", "x1 y80 w480 h2 +0x10")
        this.Add("Picture", "x16 y8 w64 h64 +BackgroundTrans +AltSubmit", this.logoPath)
        this.SetFont("s16", "Segoe UI")
        this.Add("Text", "x104 y16 w306 h32", this.title)
        this.SetFont("s9 cGreen", "Segoe UI")
        this.Add("Text", "x106 y40 w304 h23 +0x200", "Version " this.versionStr)
        this.SetFont("s9", "Segoe UI")
        this.controls["childAreaBottom"] := this.Add("Text", "x1 y320 w480 h2 +0x10")

        this.controls["btnPrev"] := this.Add("Button", "x200 y328 w59 h23 +BackgroundTrans", "< &Prev")
        this.controls["btnNext"] := this.Add("Button", "x264 y328 w59 h23 +BackgroundTrans", "&Next >")
        this.controls["btnFinish"] := this.Add("Button", "x344 y328 w59 h23 +BackgroundTrans", "&Finish")
        this.controls["btnCancel"] := this.Add("Button", "x408 y328 w59 h23 +BackgroundTrans", "&Cancel")

        this.controls["btnPrev"].onEvent("Click", "btnPrev")
        this.controls["btnNext"].onEvent("Click", "btnNext")
        this.controls["btnFinish"].onEvent("Click", "btnFinish")
        this.controls["btnCancel"].onEvent("Click", "btnCancel")

        this.SetFont("s9 cNavy", "Segoe UI")
        this.controls["pageCount"] := this.Add("Text", "x392 y56 w81 h23 +0x200 +0x1", "Page x / y")
        super.build()
    }

    registerPage(index, page)
    {
        this.pages.InsertAt(index, page)
    }

    buildPage(pageIndex := "")
    {
        if (!this._built) {
            this.build()
        }
        if (pageIndex == "") {
            pageIndex := this.currentPageIndex
        }
        if (pageIndex < 1) {
            pageIndex := 1
        } else if (pageIndex > this.pages.Length) {
            pageIndex := this.pages.Length
        }

        this.pages[this.currentPageIndex].Hide()
        this.currentPageIndex := pageIndex
        this._updateButtonStates()
        this.pages[pageIndex].Show()
        this._updatePageCount()
    }

    buildNextPage()
    {
        this.buildPage(this.currentPageIndex + 1)
    }

    buildPrevPage()
    {
        this.buildPage(this.currentPageIndex - 1)
    }

    show()
    {
        super.Show("w480 h360")
        this.buildPage()
    }

    disable(controlKey) 
    {
        this.controls[controlKey].Opt("+Disabled")
    }

    enable(controlKey) 
    {
        this.controls[controlKey].Opt("-Disabled")
    }

    _updateButtonStates()
    {
        if (this.currentPageIndex == 1) {
            this.controls["btnPrev"].Opt("+Disabled")
        } else {
            this.controls["btnPrev"].Opt("-Disabled")
        }

        if (this.currentPageIndex == this.pages.Length) {
            this.controls["btnNext"].Opt("+Disabled")
            this.controls["btnFinish"].Opt("-Disabled")
        } else {
            this.controls["btnNext"].Opt("-Disabled")
            this.controls["btnFinish"].Opt("+Disabled")
        }
    }

    _updatePageCount()
    {
        pageCountStr := "Page " this.currentPageIndex " / " this.pages.Length
        this.controls['pageCount'].Text := pageCountStr
    }
}