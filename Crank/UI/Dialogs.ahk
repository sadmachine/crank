; ==== Script Information ======================================================
; Name .........: UI.Dialogs
; Description ..: Parent class for dialog subclasses
; AHK Version ..: 2.0.2 (Unicode 64-bit)
; Start Date ...: 08/23/2023
; OS Version ...: Windows 10
; Language .....: English - United States (en-US)
; Author .......: Austin Fishbaugh <austin.fishbaugh@gmail.com>
; Filename .....: Dialogs.ahk
; ==============================================================================

; ==== Revision History ========================================================
; Revision 1 (08/23/2023)
; * Added This Banner
;
; ==== TO-DOs ==================================================================
; ==============================================================================
; ! IF THIS IS A SUBCLASS, DO NOT INCLUDE FILES HERE

; UI.Dialogs
class Dialogs
{
    #Include Dialogs/Base.ahk
    #Include Dialogs/Date.ahk
    #Include Dialogs/Dropdown.ahk
    #Include Dialogs/Number.ahk
    #Include Dialogs/Path.ahk
    #Include dialogs/String.ahk
}