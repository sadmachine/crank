; === Script Information =======================================================
; Name .........: SimpleAdoDbConnection
; Description ..: Creates a basic, queryable connection using ADODB.Connection
; AHK Version ..: 2.0.2 (Unicode 64-bit)
; Start Date ...: 08/05/2023
; OS Version ...: Windows 10
; Language .....: English - United States (en-US)
; Author .......: Austin Fishbaugh <austin.fishbaugh@gmail.com>
; Filename .....: SimpleAdoDbConnection.ahk
; ==============================================================================

; === Revision History =========================================================
; Revision 1 (08/05/2023)
; * Added This Banner
;
; === TO-DOs ===================================================================
; ==============================================================================
class SimpleAdoDbConnection
{
    connectionStr := ""
    connectionObj := Object()

    __New(connectionStr)
    {
        this.connectionStr := connectionStr
        this.connectionObj := ComObject("ADODB.Connection")
        this.connectionObj.ConnectionTimeout := 3 ; Allow 3 seconds to connect to the server.
        this.connectionObj.CursorLocation := 3 ; Use a client-side cursor server.
        this.connectionObj.CommandTimeout := 900 ; A generous 15 minute timeout on the actual SQL statement.
        this.connectionObj.Open(this.connectionStr) ; open the connection.
    }

    query(qStr, outputType := "Object")
    {
        qStr := RTrim(qStr)
        qStr := RTrim(qStr, ';') ';'
        return this.connectionObj.execute(qStr)
    }
}