; === Script Information =======================================================
; Name .........: Path
; Description ..: Path Utilities
; AHK Version ..: 2.0.2 (Unicode 64-bit)
; Start Date ...: 08/04/2023
; OS Version ...: Windows 10
; Language .....: English - United States (en-US)
; Author .......: Austin Fishbaugh <austin.fishbaugh@gmail.com>
; Filename .....: Path.ahk
; ==============================================================================

; === Revision History =========================================================
; Revision 1 (08/04/2023)
; * Added This Banner
;
; === TO-DOs ===================================================================
; ==============================================================================
#Include Vendor/DriveMap.ahk

class Path
{

    static makeAbsolute(path)
    {
        global
        cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
        VarSetStrCapacity(&buf, cc * (1 ? 2 : 1)) ; V1toV2: if 'buf' is NOT a UTF-16 string, use 'buf := Buffer(cc*(A_IsUnicode?2:1))'
        DllCall("GetFullPathName", "str", path, "uint", cc, "str", buf, "ptr", 0, "uint")
        return buf
    }

    static parseDirectory(path)
    {
        SplitPath(path, , &dir)
        return dir
    }

    static parseFilename(path, extension := true)
    {
        if (extension) {
            SplitPath(path, &filename)
            return filename
        }
        SplitPath(path, , , , &filenameWithExtension)
        return filenameWithExtension
    }

    static parseExtension(path)
    {
        SplitPath(path, , , &extension)
        return extension
    }

    static parseDrive(path)
    {
        SplitPath(path, , , , , &drive)
        return drive
    }

    ; static isLocked(path) {
    ;     fileStatus := FileExist(path)
    ;     if (InStr("D", fileStatus) || fileStatus == "") {
    ;         throw Error("FilesystemException", A_ThisFunc, "'" path "' does not exist or is a directory", A_LineFile, A_LineNumber)
    ;     }

    ;     lockPath := path ".lock"
    ;     return (FileExist(lockPath) != "")
    ; }

    ; static createLock(path, waitPeriod := 200)
    ; {
    ;     if (!Lib.Path.registeredCleanup) {
    ;         cleanupMethod := ObjBindMethod(this, "_cleanup")
    ;         OnExit(cleanupMethod, -1)
    ;         OnError(cleanupMethod, -1)
    ;         Lib.Path.registeredCleanup := true
    ;     }
    ;     fileStatus := FileExist(path)
    ;     if (InStr("D", fileStatus) || fileStatus == "") {
    ;         throw Error("FilesystemException", A_ThisFunc, "'" path "' does not exist or is a directory", A_LineFile, A_LineNumber)
    ;     }

    ;     lockPath := path ".lock"
    ;     if (FileExist(lockPath)) {
    ;         if (waitPeriod == -1) {
    ;             return false
    ;         }
    ;         while (FileExist(lockPath)) {
    ;             Sleep(waitPeriod)
    ;         }
    ;     }
    ;     FileAppend("", lockPath)
    ;     Lib.Path.lockPaths[lockPath] := lockPath
    ;     FileSetAttrib("+H", lockPath)
    ;     return true
    ; }

    ; static freeLock(path)
    ; {
    ;     fileStatus := FileExist(path)
    ;     if (InStr("D", fileStatus) || fileStatus == "") {
    ;         throw Error("FilesystemException", A_ThisFunc, "'" path "' does not exist or is a directory", A_LineFile, A_LineNumber)
    ;     }

    ;     lockPath := path ".lock"
    ;     if (!FileExist(lockPath)) {
    ;         return false
    ;     }

    ;     FileDelete(lockPath)
    ;     Lib.Path.lockPaths.Delete(lockPath)
    ;     return true
    ; }

    static isType(path, pathType)
    {
        local exists
        exists := FileExist(path)
        return InStr(exists, pathType)
    }

    static concat(path1, path2)
    {
        return RTrim(path1, "/\") "\" LTrim(path2, "/\")
    }

    static normalize(path)
    {
        path := this.makeAbsolute(path)
        ; Standardize on backslashes for paths
        path := StrReplace(path, "/", "\")

        ; Directories should end in a backslash (easier to identify as a directory, not a file without an extension)
        if (this.isType(path, "D")) {
            path := RTrim(path, "\") "\"
        }

        return path
    }

    static parentOf(path)
    {
        path := this.normalize(path)
        return this.normalize(RegExReplace(path, "[^\\]+\\?$"))
    }

    static inUse(path)
    {
        path := this.normalize(path)
        directory := this.parseDirectory(path)
        filename := this.parseFilename(path)
        temporaryFile := this.concat(directory, "~$" filename)
        if (FileExist(temporaryFile)) {
            return true
        }
        try {
            size := FileGetsize(path)
            return false
        } catch OSError as e {
            return true
        }
    }

    ; static _cleanup()
    ; {
    ;     for index, path in Lib.Path.lockPaths {
    ;         FileDelete(path)
    ;     }
    ;     return 0
    ; }

    static convertToUnc(path)
    {
        SplitPath(path, , , , , &thisDrive)
        if (InStr(thisDrive, ":") && !InStr("A: B: C: D:", thisDrive)) {
            networkPath := DriveMap.get(thisDrive)
            if (networkPath != "") {
                path := SubStr(path, 3)
                path := DriveMap.get(thisDrive) . path
            }
        }
        return path
    }
}