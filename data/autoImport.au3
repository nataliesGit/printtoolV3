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
#include <ComboConstants.au3>


#Region ### START Koda GUI section ### Form=c:\_natalie_eigene\drucker luisen v3\data\assets\formular_guis\autoimport.kxf
$Form3 = GUICreate("AutoImport", 284, 128, 302, 218)
GUISetBkColor(0xFFFFFF)
$Label1 = GUICtrlCreateLabel("Auswahl der Schule", 40, 16, 98, 17)
$Combo1 = GUICtrlCreateCombo("Schulauswahl", 40, 48, 137, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$Button1 = GUICtrlCreateButton("Import", 184, 48, 75, 23)
$Label2 = GUICtrlCreateLabel("Importstatus", 40, 80, 61, 17)
$Label3 = GUICtrlCreateLabel("Datenstand: Januar 2018", 136, 104, 124, 17)
GUICtrlSetFont(-1, 6, 400, 0, "MS Sans Serif")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


Global $Schulen[]=["Luisenstrasse","Bergsonstrasse","Riesstrasse"]
populateCombo()



While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button1
			importData()
	EndSwitch
WEnd




func populateCombo()
	For $element IN $Schulen
	   GUICtrlSetData($Combo1, $element)
   Next
EndFunc



func importData()
	GUICtrlSetColor($Label2, 0x000000)
   Local $Database = @ScriptDir & "\raumpc.db" ;Location Of Database file
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
	$datei = @ScriptDir & "\ImportDateien\"&GUICtrlRead($Combo1)&".csv"
	if GUICtrlRead($Combo1) = "Schulauswahl" Then
		MsgBox(0, 'gewählte Datei',"keine Schule ausgewählt")
		Return
	EndIf
	GUICtrlSetData($Label2, "Import läuft")
	FileOpen($datei, 0)
;~ 	MsgBox(0, 'gewählte Datei',$datei)


	_SQLite_Exec(-1, "CREATE TABLE raumpc (Rechner,Raum);") ; CREATE a Table
	; loop through each line of the file
	For $i = 1 to _FileCountLines($datei)
			$line = FileReadLine($datei, $i)
			local $zeile = StringSplit( $line, ";")
			_SQLite_Exec(-1, "INSERT INTO raumpc(Rechner,Raum) VALUES ('" & $zeile[1] & "','" & $zeile[2] & "');") ; INSERT Data
;~ 			msgbox(0,'','the line ' & $i & ' is ' & $line)
	Next


	FileClose($datei)
	_SQLite_Close()
	_SQLite_Shutdown()
	GUICtrlSetData($Label2, "Import erfolgt")
	GUICtrlSetColor($Label2, 0x008000)


EndFunc


