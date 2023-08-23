; === Script Information =======================================================
; Name .........: Path Dialog
; Description ..: Dialog for asking for path data
; AHK Version ..: 1.1.36.02 (Unicode 64-bit)
; Start Date ...: 04/09/2023
; OS Version ...: Windows 10
; Language .....: English - United States (en-US)
; Author .......: Austin Fishbaugh <austin.fishbaugh@gmail.com>
; Filename .....: Path.ahk
; ==============================================================================

; === Revision History =========================================================
; Revision 1 (04/09/2023)
; * Added This Banner
; * Convenience and UI updates
; * Populate file/folder by default if a value is passed to the dialog
;
; Revision 2 (04/13/2023)
; * Add ability to convert drives E: - Z: to UNC paths
;
; Revision 3 (04/21/2023)
; * Update for ahk v2
;
; === TO-DOs ===================================================================
; ==============================================================================
; ! DO NOT INCLUDE DEPENDENCIES HERE, DO SO IN TOP-LEVEL PARENT
; UI.Dialogs.Path
class Path extends UI.Dialogs.Base
{
    static convertDrivesToUnc := true

    define()
    {
        if (!this.data.Has("pathType")) {
            throw Error("ProgrammerException", A_ThisFunc, "data.pathType is missing, must be one of ['file', 'folder', 'directory']", A_LineFile, A_LineNumber)
        }
        if (!InStr("file, folder, directory", this.data["pathType"])) {
            throw Error("ProgrammerException", A_ThisFunc, "data.pathType must be one of ['file', 'folder', 'directory']", A_LineFile, A_LineNumber)
        }

        userHome := EnvGet("USERPROFILE")
        this.pathType := this.data["pathType"]

        ; Generic option
        if (this.title == "") {
            this.title := this.data.Has("title") ? this.data.title : "Select a Folder"
        }

        ; Pathtype specific options
        if (this.pathType = "file") {
            if (this.data.Has("value")) {
                this.startingPath := this.data.value
            } else {
                this.defaultFileName := this.data.Has("defaultFilename") ? this.data.defaultFilename : ""
                this.startingFolder := this.data.Has("startingFolder") ? this.data.startingFolder : userHome
                this.startingPath := ""
                if (this.startingFolder != "") {
                    this.startingPath := this.startingFolder
                    if (this.defaultFilename != "") {
                        this.startingPath := RTrim(this.startingFolder, "\/") "\" LTrim(this.defaultFilename, "\/")
                    }
                }
            }
            this.filter := this.data.Has("filter") ? this.data.filter : ""
            this.dialogOptions := this.data.Has("dialogOptions") ? this.data.dialogOptions : 3
        } else {
            this.startingPath := this.data.Has("value") ? this.data.value : userHome
        }
    }

    SelectFolderEx(StartingFolder := "", Prompt := "", OwnerHwnd := 0, OkBtnLabel := "") {
        static OsVersion := DllCall("GetVersion", "UChar"),
            IID_IShellItem := 0,
            InitIID := IID_IShellItem := Buffer(16, 0) ; V1toV2: if 'IID_IShellItem' is a UTF-16 string, use 'VarSetStrCapacity(&IID_IShellItem, 16)'
            & DllCall("Ole32.dll\IIDFromString", "WStr", "{43826d1e-e718-42ee-bc55-a1e261c37bfe}", "Ptr", IID_IShellItem),
            Show := A_PtrSize * 3,
            SetOptions := A_PtrSize * 9,
            SetFolder := A_PtrSize * 12,
            SetTitle := A_PtrSize * 17,
            SetOkButtonLabel := A_PtrSize * 18,
            GetResult := A_PtrSize * 20

        SelectedFolder := ""
        if (OsVersion < 6) { ; IFileDialog requires Win Vista+, so revert to FileSelectFolder
            SelectedFolder := DirSelect("*" StartingFolder, 3, Prompt)
            return SelectedFolder
        }

        OwnerHwnd := DllCall("IsWindow", "Ptr", OwnerHwnd, "UInt") ? OwnerHwnd : 0
        if !(FileDialog := ComObject("{DC1C5A9C-E88A-4dde-A5A1-60F82A20AEF7}", "{42f85136-db7e-439c-85f1-e4075d135fc8}"))
            return ""
        VTBL := NumGet(FileDialog + 0, "UPtr")
        ; FOS_CREATEPROMPT | FOS_NOCHANGEDIR | FOS_PICKFOLDERS
        DllCall(NumGet(VTBL + SetOptions, "UPtr"), "Ptr", FileDialog, "UInt", 0x00002028, "UInt")
        if (StartingFolder != "")
            if !DllCall("Shell32.dll\SHCreateItemFromParsingName", "WStr", StartingFolder, "Ptr", 0, "Ptr", IID_IShellItem, "PtrP", &FolderItem)
                DllCall(NumGet(VTBL + SetFolder, "UPtr"), "Ptr", FileDialog, "Ptr", FolderItem, "UInt")
        if (Prompt != "")
            DllCall(NumGet(VTBL + SetTitle, "UPtr"), "Ptr", FileDialog, "WStr", Prompt, "UInt")
        if (OkBtnLabel != "")
            DllCall(NumGet(VTBL + SetOkButtonLabel, "UPtr"), "Ptr", FileDialog, "WStr", OkBtnLabel, "UInt")
        if (!DllCall(NumGet(VTBL + Show, "UPtr"), "Ptr", FileDialog, "Ptr", OwnerHwnd, "UInt")) {
            if !DllCall(NumGet(VTBL + GetResult, "UPtr"), "Ptr", FileDialog, "PtrP", &ShellItem, "UInt") {
                GetDisplayName := NumGet(NumGet(ShellItem + 0, "UPtr"), A_PtrSize * 5, "UPtr")
                if !DllCall(GetDisplayName, "Ptr", ShellItem, "UInt", 0x80028000, "PtrP", &StrPtr) { ; SIGDN_DESKTOPABSOLUTEPARSING
                    SelectedFolder := StrGet(StrPtr, "UTF-16"), DllCall("Ole32.dll\CoTaskMemFree", "Ptr", StrPtr)
                }
                ObjRelease(ShellItem)
            }
        }
        if (FolderItem) {
            ObjRelease(FolderItem)
        }
        ObjRelease(FileDialog)
        return SelectedFolder
    }

    prompt()
    {
        Loop {
            if (this.pathType = "file") {
                path := FileSelect(this.dialogOptions, this.startingPath, this.title, this.filter)
                if (InStr(FileExist(path), "D")) {
                    UI.MsgBox("You have selected a folder/directory, please select a file.")
                    Continue
                }
                canceled := (path == "" || path == [])
                if (this.convertDrivesToUnc) {
                    path := Path.convertToUnc(path)
                }
                result := { value: path, canceled: canceled }
                return result
            } else {
                path := this.SelectFolderEx(this.startingPath, this.title, this.parentHwnd)
                if (path != "" && !InStr(FileExist(path), "D")) {
                    UI.MsgBox("You have selected a file, please select a folder/directory.")
                    Continue
                }
                if (path == "") {
                    canceled := true
                }
                if (this.convertDrivesToUnc) {
                    path := Path.convertToUnc(path)
                }
                result := { value: path, canceled: canceled }
                return result
            }
        }

    }

}