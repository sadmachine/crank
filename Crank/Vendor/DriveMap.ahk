; ======================================================================================================================
; Namespace:      DriveMap
; Function:       Add, delete, or query network shares mapped to local drives.
; AHK version:    AHK 1.1.13.01
; Tested on:      Win XP SP3 - AHK A32/U32 (Win 7 - AHK A32/U32 by HotKeyIt, THX)
; Version:        1.0.00.00/2013-11-04/just me
; ======================================================================================================================
class DriveMap {
   ;--------------------------------------------------------------------------------------------------------------------
   Static MinDL := "D" ; minimum drive letter
   Static MaxDL := "Z" ; maximum drive letter
   Static ERROR_BAD_DEVICE := 1200 ; system error code
   ;--------------------------------------------------------------------------------------------------------------------
   __New(P*) {
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Method:         Add      -  Makes a connection to a network resource and redirects a local device to the resource.
   ; Parameter:      Drive    -  Drive letter to be mapped to the share followed by a colon (e.g. "Z:")
   ;                             or "*" to map an unused drive letter.
   ;                 Share    -  A null-terminated string that specifies the remote network name.
   ;                 Optional ------------------------------------------------------------------------------------------
   ;                 User     -  A string that specifies a user name for making the connection.
   ;                             If omitted or explicitely set empty, the function uses the name of the user running
   ;                             the current process.
   ;                 Pass     -  A string that specifies a password for making the connection.
   ;                             If omitted or explicitely set to "`n", the function uses the current default password
   ;                             associated with the user specified by the User parameter.
   ;                             If Pass is an empty string, the function does not use a password.
   ; Return Values:  Drive letter followed by a colon on success, otherwise an empty string.
   ;                 ErrorLevel contains the system error code, if any.
   ; MSDN:           WNetAddConnection2 -> http://msdn.microsoft.com/en-us/library/aa385413%28v=vs.85%29.aspx
   ;                 NETRESOURCE        -> http://msdn.microsoft.com/en-us/library/aa385353%28v=vs.85%29.aspx
   ; -------------------------------------------------------------------------------------------------------------------
   Add(Drive, Share, User := "", Pass := "`n") {
      static RESOURCETYPE_DISK := 0x00000001
      static Flags := 0x04 ; CONNECT_TEMPORARY
      static offType := 4, offLocal := 16, offRemote := offLocal + A_PtrSize ; NETRESOURCE offsets

      ErrorLevel := 0
      if ((Drive != "*") && !RegExMatch(Drive, "i)^[" . This.MinDL . "-" . This.MaxDL . "]:$")) { ; invalid drive
         ErrorLevel := This.ERROR_BAD_DEVICE
         return ""
      }

      DriveList := DriveGetList()
      Loop StrLen(DriveList) { ; check whether the share is already mapped
         DL := SubStr(DriveList, (A_Index)<1 ? (A_Index)-1 : (A_Index), 1) . ":"
         if (This.Get(DL) = Share)
            return DL
      }

      ; Automatic drive mapping by leaving drive empty doesn't work on Win XP, so we have to use the asterisk
      ; and do it manually
      if (drive = "*") { ; try to find an unused drive letter
         DL := Ord(This.MaxDL)
         while (DL >= Ord(This.MinDL)) {
            if (!InStr(DriveList, Chr(DL))) {
               drive := Chr(DL) . ":"
               break
            }
            DL--
         }
         if (drive = "*") { ; drive is still '*', i.e. the share cannot be mapped to a drive letter
            ErrorLevel := This.ERROR_BAD_DEVICE
            return ""
         }
      }
      NR := Buffer((4 * 4) + (A_PtrSize * 4), 0) ; NETRESOURCE structure ; V1toV2: if 'NR' is a UTF-16 string, use 'VarSetStrCapacity(&NR, (4 * 4) + (A_PtrSize * 4))'
      NumPut("UInt", RESOURCETYPE_DISK, NR, offType)
      NumPut("Ptr", &drive, NR, offLocal)
      NumPut("Ptr", &share, NR, offRemote)
      PtrPass := Pass = "`n" ? 0 : &Pass
      PtrUser := User = "" ? 0 : &User
      if (Result := DllCall("Mpr.dll\WNetAddConnection2", "Ptr", NR, "Ptr", PtrPass, "Ptr", PtrUser, "UInt", Flags, "UInt")) {
         ErrorLevel := Result
         return ""
      }
      return drive
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Method:         Del      -  removes an existing drive mapping to a network share.
   ; Parameter:      Drive    -  drive letter of the mapped local drive followed by a colon (e.g. "Z:").
   ;                 Optional ------------------------------------------------------------------------------------------
   ;                 Force    -  specifies whether the disconnection should occur if there are open files or jobs
   ;                             on the connection. Values: True/False
   ; Return Values:  True on success, otherwise False.
   ;                 ErrorLevel contains the system error code, if any.
   ; MSDN:           WNetCancelConnection2 -> http://msdn.microsoft.com/en-us/library/aa385427%28v=vs.85%29.aspx
   ; -------------------------------------------------------------------------------------------------------------------
   Del(Drive, Force := False) {
      ErrorLevel := 0
      If !RegExMatch(Drive, "i)^[" . This.MinDL . "-" . This.MaxDL . "]:$") { ; invalid drive
         ErrorLevel := This.ERROR_BAD_DEVICE
         Return False
      }
      If (Result := DllCall("Mpr.dll\WNetCancelConnection2", "Str", Drive, "UInt", 0, "UInt", !!Force, "UInt")) {
         ErrorLevel := Result
         Return False
      }
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Method:         Get      -  retrieves the name of the network share associated with the local drive.
   ; Parameter:      Drive    -  drive letter to get the network name for followed by a colon (e.g. "Z:").
   ; Return Values:  The name of the share on success, otherwise an empty string.
   ;                 ErrorLevel contains the system error code, if any.
   ; MSDN:           WNetGetConnection() -> http://msdn.microsoft.com/en-us/library/aa385453%28v=vs.85%29.aspx
   ; -------------------------------------------------------------------------------------------------------------------
   Get(Drive) {
      Static Length := 512
      ErrorLevel := 0
      If !RegExMatch(Drive, "i)^[" . This.MinDL . "-" . This.MaxDL . "]:$") { ; invalid drive
         ErrorLevel := This.ERROR_BAD_DEVICE
         Return ""
      }
      Share := Buffer(Length * 2, 0) ; V1toV2: if 'Share' is a UTF-16 string, use 'VarSetStrCapacity(&Share, Length * 2)'
      If (Result := DllCall("Mpr.dll\WNetGetConnection", "Str", Drive, "Str", Share, "UIntP", &Length, "UInt")) {
         ErrorLevel := Result
         Return ""
      }
      Return Share
   }
}