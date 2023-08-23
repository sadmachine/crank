; === Script Information =======================================================
; Name .........: Types.OrderedMap
; Description ..: A Map implementation which keeps ordering of keys
; AHK Version ..: 2.0.2 (Unicode 64-bit)
; Start Date ...: 08/01/2023
; OS Version ...: Windows 10
; Language .....: English - United States (en-US)
; Author .......: Austin Fishbaugh <austin.fishbaugh@gmail.com>
; Filename .....: OrderedMap.ahk
; ==============================================================================

; === Revision History =========================================================
; Revision 1 (08/01/2023)
; * Added This Banner
;
; === TO-DOs ===================================================================
; ==============================================================================

; ! DO NOT INCLUDE DEPENDENCIES HERE, DO SO IN TOP-LEVEL PARENT
; Types.OrderedMap
class OrderedMap
{

    class Enum {
        currentKeyIndex := 1
        _map := Map()
        _order := Array()

        __New(mapObj, order)
        {
            this._map := mapObj
            this._order := order
        }

        Call(&OutputVar1, &OutputVar2)
        {
            if (this.currentKeyIndex > this._map.Count) {
                return 0
            }
            curKey := this._order[this.currentKeyIndex]
            curVal := this._map[curKey]
            OutputVar1 := curKey
            OutputVar2 := curVal
            this.currentKeyIndex++
            return 1
        }
    }

    _map := Map()
    _order := Array()
    _keyCount := 1

    __Item[name]
    {
        get {
            return this._map[name]
        }
        set {
            this._map[name] := value
            this._order.push(name)
            this._keyCount++
        }
    }

    __New(keyVals*)
    {
        UNDEFINED := "_____UNDEFINED_____"
        key := UNDEFINED
        val := UNDEFINED
        if (Mod(keyVals.Length, 2) != 0) {
            throw Error(
                "ArgumentError", A_ThisFunc,
                "The number of arguments passed must be even, and represent (key, value) pairs.",
                A_LineFile, A_LineNumber
            )
        }

        for index, keyVal in keyVals {
            if (Mod(A_Index, 2) == 0) {
                val := keyVal
            } else {
                key := keyVal
            }
            if (key != UNDEFINED && val != UNDEFINED) {
                this._map[key] := val
                this._order.push(key)
                this._keyCount++
                key := UNDEFINED
                val := UNDEFINED
            }
        }
    }

    __Call(name, params*)
    {
        return this._map.%name%(params)
    }

    __Enum(NumberOfVars) {
        thisEnum := OrderedMap.Enum(this._map, this._order)
        enumMethod := ObjBindMethod(thisEnum, "Call")
        return enumMethod
    }
}