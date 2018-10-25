#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ico\list.ico
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <MsgBoxConstants.au3>
#include <File.au3>
#include <SQLite.au3>
#include <SQLite.dll.au3>
#include <Array.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#Region ### START Koda GUI section ### Form=C:\_natalie_eigene\Drucker Luisen V3\AnzeigeDB.kxf
$Form4 = GUICreate("Anzeige Datenbank-Inhalt", 311, 465, 367, 194)
GUISetIcon("ico\list.ico", -1)
$Edit1 = GUICtrlCreateEdit("", 40, 0, 225, 457)
GUICtrlSetData(-1, "---")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

anzeigeDB()

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit

	EndSwitch
WEnd


func anzeigeDB()
	Local $Database = "data\raumpc.db" ;Location Of Database file
	Local $aResult, $iRows, $iColumns, $iRval
	  _SQLite_Startup()
	   If @error Then
		  MsgBox($MB_SYSTEMMODAL, "SQLite Error", "SQLite3.dll Can't be Loaded!")
		  Exit -1
	   EndIf
	   Local $pcdb = _SQLite_Open($Database) ; open database, ensure the database (.db) exists.
	   If @error Then
		  MsgBox($MB_SYSTEMMODAL, "SQLite Error", "Can't open or create a permanent Database!")
		  Exit -1
	   EndIf
	$iRval = _SQLite_GetTable2d ($pcdb, "select * from raumpc;", $aResult, $iRows, $iColumns)
	If $iRval = $SQLITE_OK Then
;~ 		_SQLite_Display2DResult($aResult)
;~ 		MsgBox("", "Array", _ArrayToString($aResult, @TAB))
		GUICtrlSetData($Edit1,_ArrayToString($aResult, @TAB))
	Else
	MsgBox(16, "SQLite Error: " & $iRval, _SQLite_ErrMsg ())
		_SQLite_Close()
		_SQLite_Shutdown()
	EndIf
EndFunc