#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ico\printserver.ico
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
#Include <Array.au3>
#include <GUIConstantsEx.au3>
#include <StringConstants.au3>
#include <ComboConstants.au3>
#include <String.au3>

#Region ### START Koda GUI section ### Form=c:\_natalie_eigene\drucker luisen v3\data\formular_guis\printserver.kxf
$Form3_1 = GUICreate("Printserver", 252, 158, 284, 179)
$Label1 = GUICtrlCreateLabel("Printserver \\sc000000", 16, 16, 218, 17)
$Button1 = GUICtrlCreateButton("speichern", 160, 78, 75, 25)
$Combo1 = GUICtrlCreateCombo("Printserver", 16, 40, 217, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$Button2 = GUICtrlCreateButton("schliessen", 160, 112, 75, 25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

;~ https://www.autoitscript.com/forum/topic/49645-dictionary-object-in-autoit/    associative Arrays bzw. Dictionary
Global $Key, $Item, $Dictionary
; Create dictionary object
$Dictionary = ObjCreate("Scripting.Dictionary")

Global $handle_read
Global $printServer
readIni()
Global $Printservers[0]
readPrintserverFile()
populateCombo()


func readIni()
	$handle_read = FileOpen(@ScriptDir & "\druckerTool.ini", 0)
	If $handle_read = -1 Then
		MsgBox(0, @ScriptName, 'Datei konnte nicht geöffnet werden')
		Exit 1
	EndIf
  ; Read the fist line of the file using the handle returned by FileOpen.
    $printServer = FileReadLine($handle_read, 1)
	FileClose($handle_read)
	GUICtrlSetData($Label1,$printServer)
EndFunc

func readPrintserverFile()
;~ 	*************** leere zeilen löschen *************************
	$file = FileRead(@ScriptDir & "\printserver.txt")
;~ 	MsgBox(4096, "before", $file)
	$file = _StringReplaceBlank($file, 1)
;~ 	MsgBox(4096, "after", $file)
	FileDelete(@ScriptDir & "\printserver.txt")
	FileWrite(@ScriptDir & "\printserver.txt",$file)
;~ 	***************ende leere zeilen löschen **********************

	$handle_read = FileOpen(@ScriptDir & "\printserver.txt", 0)

	While 1    		; read each line from a file
		$line_read = FileReadLine($handle_read)
		ConsoleWrite($line_read & @CRLF)
		if StringInStr($line_read,";") then
			local $zeile = StringSplit( $line_read, ";")
			$Dictionary.Add ($zeile[1],$zeile[2])
			_ArrayAdd($Printservers, $zeile[1])
		Else
;~ 			MsgBox(4096, "PrinterServerFile", "falsches Format")
			ExitLoop
		EndIf
	WEnd
	FileClose($handle_read)
EndFunc

Func _StringReplaceBlank($sString, $sSpaces = "")
	If $sSpaces Then
		$sSpaces = "\s*"
	EndIf
	$sString = StringRegExpReplace($sString, "(?s)\r\n" & $sSpaces & "\r\n", @CRLF)
	If @extended Then
		Return SetError(0, @extended, $sString)
	EndIf
	Return SetError(1, 0, $sString)
EndFunc ;==>_StringReplaceBlank


func populateCombo()
	For $element IN $Printservers
	   GUICtrlSetData($Combo1, $element)
   Next
EndFunc


func writeServer2ini()
	$auswahl = GUICtrlRead($Combo1)
	if $auswahl = "Printserver" Then
		MsgBox(0, 'Info',"kein Printserver ausgewählt")
		Return
	EndIf
	GUICtrlSetData($Label1,$auswahl&" : "&$Dictionary.Item($auswahl))
;~ 	MsgBox(0, 'Auswahl',$auswahl)
	Local $sFileName = @ScriptDir & "\druckerTool.ini"
	_ReplaceStringInFile ( $sFileName, $printServer,$auswahl&":"&$Dictionary.Item($auswahl))
EndFunc


While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $Button1
			writeServer2ini()
		Case $Button2
			Exit
		Case $GUI_EVENT_CLOSE
			Exit

	EndSwitch
WEnd
