#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ico\db.ico
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>

#include <WinAPIFiles.au3>
#include <File.au3>
#include <SQLite.au3>
#include <SQLite.dll.au3>
#Include <Array.au3>
#include <GUIConstantsEx.au3>
#include <StringConstants.au3>

#Region ### START Koda GUI section ### Form=c:\_natalie_eigene\drucker luisen v3\data\assets\formular_guis\import.kxf
$Form2 = GUICreate("Import", 430, 151, 290, 222)
GUISetBkColor(0xFFFFFF)
$Label1 = GUICtrlCreateLabel("Datenimport Format: 2-spaltige csv-Datei (Rechner;Raum)", 40, 16, 276, 17)
$Button1 = GUICtrlCreateButton("Import", 320, 96, 83, 25)
$Button2 = GUICtrlCreateButton("....", 40, 48, 27, 25)
$Label2 = GUICtrlCreateLabel("Dateiauswahl", 80, 56, 324, 19)
$importstatus = GUICtrlCreateLabel("", 80, 96, 4, 4)
GUICtrlSetColor(-1, 0x008000)
$Button3 = GUICtrlCreateButton("Beispieldatei", 320, 16, 83, 25)
$Label3 = GUICtrlCreateLabel("Importstatus", 80, 104, 197, 17)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###



Global $sFileOpenDialog
Global $importStatus = 0

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button2
			 selectFile()
		Case $Button1
			importcsv()
		Case $Button3
			beispielNotepad()
	EndSwitch
WEnd

Func beispielNotepad()
	$_Run = "notepad.exe " & "beispiel.txt"
;~ 	ConsoleWrite ( "$_Run : " & $_Run & @Crlf )   zu testzwecken
	Run ( $_Run, @ScriptDir, @SW_SHOWDEFAULT )
EndFunc

Func selectFile()
	Local Const $sMessage = "Auswahl der csv Datei"
;~ 	Local $sFileOpenDialog = FileOpenDialog($sMessage, @WindowsDir & "\", "CSV Datei (*.csv)", $FD_FILEMUSTEXIST)
$sFileOpenDialog = FileOpenDialog($sMessage,@ScriptDir & "\", "CSV Datei (*.csv)", $FD_FILEMUSTEXIST)
	if StringLen($sFileOpenDialog) > 55 then
		GUICtrlSetData($Label2, "..... "&StringRight($sFileOpenDialog, 55))
	Else
		GUICtrlSetData($Label2,$sFileOpenDialog)
	EndIf
EndFunc

;~ Func import()
;~ 	ProgressOn("Progress Bar", "Datenimport", "Daten werden importiert...")
;~ 	 For $i = 0 To 100
;~ 		ProgressSet($i)
;~ 		Sleep(2)
;~ 	 Next

;~ 	 ProgressSet(100, "Abgeschlossen")
;~ 	 Sleep(750)
;~ 	 ProgressOff()
;~ 	 importcsv()
;~ EndFunc

Func  importcsv()
	GUICtrlSetData($Label3, "Import läuft")
   Local $Database = @ScriptDir & "\raumpc.db" ;Location Of Database file
;~    benenne existierende db in 'raumpc_old' um, da sie neu kreiert wird (automatisch durch sqlite_startup()
   if FileExists($Database) then FileDelete ( $Database )

   _SQLite_Startup()
   If @error Then
	  MsgBox($MB_SYSTEMMODAL, "SQLite Error", "SQLite3.dll Can't be Loaded!")
	  Exit -1
   EndIf

   Local $pcdb = _SQLite_Open($Database) ; open database, ensure the database (.db) was exist.
   If @error Then
	  MsgBox($MB_SYSTEMMODAL, "SQLite Error", "Can't open or create a permanent Database!")
	  Exit -1
   EndIf



	; open file to read and store the handle
	$handle_read = FileOpen($sFileOpenDialog, 0)

;~ 	FileGetSize ( "filename" ) um Fortschrittsbalken zu implementieren
;~ 	MsgBox(0, @ScriptName, FileGetSize ( $sFileOpenDialog ))

	; check the handle is valid
	If $handle_read = -1 Then
		; show warning and exit with code 1
		MsgBox(0, @ScriptName, 'Datei konnte nicht geöffnet werden')
		Exit 1
	EndIf
	_SQLite_Exec(-1, "CREATE TABLE raumpc (Rechner,Raum);") ; CREATE a Table
	; loop through each line of the file
	While 1
		; read each line from a file
		$line_read = FileReadLine($handle_read)
		; exit the loop if end of file
		If @error Then ExitLoop
		; show the line read (just for testing)
;~ 		MsgBox(0, 'Line read', $line_read)

;~ 		StringSplitStringSplit Returns an array, by default the first element ($aArray[0]) contains the number of strings returned,
;~ 		the remaining elements ($aArray[1], $aArray[2], etc.) contain the delimited strings. If the flag parameter is set to
		if StringInStr($line_read,";") then
			$importStatus = 0
			local $zeile = StringSplit( $line_read, ";")
;~ 			MsgBox(0, 'pc', $zeile[1])
;~ 			MsgBox(0, 'raum',$zeile[2])
;~ 			_SQLite_QuerySingleRow($pcdb, "select field1 from raumpc where field2 = '" & $pc & "';" , $aRow)  Beispiel für sql statement mit variable
			_SQLite_Exec(-1, "INSERT INTO raumpc(Rechner,Raum) VALUES ('" & $zeile[1] & "','" & $zeile[2] & "');") ; INSERT Data
		Else
			$importStatus = 1
			GUICtrlSetData($Label3, "Importstatus")
			GUICtrlSetColor($Label3, 0x000000)
			MsgBox($MB_SYSTEMMODAL, "Importformat","Importdatei hat falsches Format!")

			ExitLoop
		EndIf
	WEnd

	; close the file handle for read
	FileClose($handle_read)

_SQLite_Close()
_SQLite_Shutdown()
if $importStatus = 0 then
	GUICtrlSetData($Label3, "Import abgeschlossen")
	GUICtrlSetColor($Label3, 0x008000)
EndIf

EndFunc