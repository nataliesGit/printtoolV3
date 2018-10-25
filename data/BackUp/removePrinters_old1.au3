#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ico\del.ico
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3> ; Required for _ArrayDisplay only.

Global $PrServers[0],$PrResult[0]
readPrintserverFile()
listConnectedPrinters()
removePrinters()

func readPrintserverFile()
	$handle_read = FileOpen( @ScriptDir & "\printserver.txt", 0)
	If $handle_read = -1 Then
		MsgBox(0, @ScriptName, 'Datei konnte nicht geöffnet werden')
		Exit 1
	EndIf
	While 1
		$line_read = FileReadLine($handle_read)
		If @error Then ExitLoop
;~ 		StringSplitStringSplit Returns an array, by default the first element ($aArray[0]) contains the number of strings returned,
;~ 		the remaining elements ($aArray[1], $aArray[2], etc.) contain the delimited strings. If the flag parameter is set to
		local $zeile = StringSplit( $line_read, ";")
		_ArrayAdd($PrServers, $zeile[2])
	WEnd
	FileClose($handle_read)
;~ 	_ArrayDisplay($PrServers)
EndFunc

Func listConnectedPrinters()
	Local $sFilePath = @ScriptDir
    Local $iPID = Run(@ComSpec & ' /C wmic printer get name ', $sFilePath, @SW_HIDE, $STDOUT_CHILD)
    ; Wait until the process has closed using the PID returned by Run.
    ProcessWaitClose($iPID)
    ; Read the Stdout stream of the PID returned by Run. This can also be done in a while loop.
    Local $sOutput = StdoutRead($iPID)
    ; Use StringSplit to split the output of StdoutRead to an array. All carriage returns (@CRLF) are stripped and @CRLF (line feed) is used as the delimiter.
    Local $aArray = StringSplit(StringTrimRight(StringStripCR($sOutput), StringLen(@CRLF)), @CRLF)
    If @error Then
        MsgBox($MB_SYSTEMMODAL, "", "Error getting Printers")
    Else
;~         _ArrayDisplay($aArray)
    EndIf
	For $i = 0 To UBound($aArray) - 1
			For $k = 0 To UBound($PrServers) - 1
				if StringInStr ( $aArray[$i], $PrServers[$k],2) Then
					_ArrayAdd($PrResult, $aArray[$i])
				EndIf
			Next
	Next
		_ArrayDisplay($PrResult)
EndFunc

func removePrinters()
	For $l = 0 To UBound($PrResult) - 1
		local $tmp = '"'&$PrResult[$l]&'"'
		StringStripWS($PrResult[$l],2 )
		ConsoleWrite("$temp :"& $tmp &@CRLF)
		Local $command ="rundll32 printui.dll,PrintUIEntry /dn /n " &$tmp
;~ 		Run (@Comspec & " /c rundll32 printui.dll,PrintUIEntry /dn /n "&$command, "", @SW_Hide, 8)
		ConsoleWrite($command &@CRLF)
	Next
	if Ubound($PrResult) > 0 then
		MsgBox(0, "Verbundene Drucker", "Alle manuell verbundenen Drucker entfernt")
	Else
		MsgBox(0, "Verbundene Drucker", "Keine manuell verbundenen Drucker vorhanden")
	EndIf
EndFunc
