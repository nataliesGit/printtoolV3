#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=data\ico\print.ico
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#pragma compile(AutoItExecuteAllowed, True)

#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIFiles.au3>
#include <File.au3>
#include <SQLite.au3>
#include <SQLite.dll.au3>
#Include <Array.au3>
#include <GuiComboBox.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <StringConstants.au3>


;~ '''''''''''''''''''''''''''''''''''' Documentation ''''''''''''''''''''''''''''''''''''''''''''''''''''''
;~ 1.	Auslesen der /data/druckerTool.ini. In der 1. Zeile steht der Druckerserver. In der 2 Zeile eine 1 oder 0. 0 bedeutet, dass Daten importiert werden
;~		können und der Druckerserver eingestellt werden kann. Bei 1 ist das Menue "Einstellungen" ausgegraut.
;~ 2.	In Funktion "Global $drucker = DruckerDynamischEinlesen()" wird mit "net view \\druckerserver" eine Liste mit allen Druckerfreigaben eingelesen
;~ 3.	in der Funktion "RaeumeVonDBEinlesen()" wird eine Liste mit allen Räumen aus der Datenbank raumpc.db ausgelesen.
;~ 4.	populateRaum() reduziert die Liste der Räume auf diejenigen, in denen ein Drucker steht und trägt sie in die Dropdownliste (Combobox) ein
;~ 		Wann immer ein Raum aus der Dropdown-Liste (Combobox) ausgewählt wird, wird die Funktion populateDrucker() aufgerufen. Sie filtert alle verfügbaren Drucker
;~ 		mit StringInStr("string","substring") nach der ausgwählten Raumnummer, die ja in den Druckernamen vorhanden ist.
;~ 5. 	die Funktion raumVorbelegung() liest den Hostnamen des Rechners aus, und ermittelt, in welchem Raum dieser Host steht. Dadurch ist der richtige Raum schon voreingestellt.
;~ 		Sollte der Host nicht in der Datenbank stehen, findet keine Vorauswahl statt.

;~ bei import von Daten oder Setzen des Druckservers müssen folgende Funktionen aufgerufen werden:
;~ iniAuslesen()
;~ $drucker = DruckerDynamischEinlesen()
;~ RaeumeVonDBEinlesen()
;~ populateRaum()
;~ raumVorbelegung()

;~ Bei Auswahl des Menues Einstellungen "import Raum-PC Daten" wird /data/import.exe aufgerufen
;~ Bei Auswahl des Menues Einstelllungen "Druckserver einstellen" wird /data/printserver.exe aufgerufen

;~ '''''''''''''''''''''''''''''''''''' Ende Documentation ''''''''''''''''''''''''''''''''''''''''''''''''''''''


#Region ### START Koda GUI section ### Form=c:\_natalie_eigene\drucker luisen v3\data\assets\formular_guis\druckerverbinden.kxf
$Form1_1 = GUICreate("Clt2020", 236, 336, -1, -1)
$mAnzeige = GUICtrlCreateMenu("&Anzeige")
$mShowPrinters = GUICtrlCreateMenuItem("Verfügbare Drucker", $mAnzeige)
$connectedPrinters = GUICtrlCreateMenuItem("Verbundene Drucker", $mAnzeige)
$mOpenPrintServerDir = GUICtrlCreateMenuItem("Druckerserver Verzeichnis", $mAnzeige)
$removePrinter = GUICtrlCreateMenuItem("Manuell verbundene Drucker entfernen", $mAnzeige)
$mShowDB = GUICtrlCreateMenuItem("Datenbank-Inhalt", $mAnzeige)
$mhorizLine = GUICtrlCreateMenuItem("------------------------------------------", $mAnzeige)
$mClose = GUICtrlCreateMenuItem("Schliessen", $mAnzeige)

$mSettings = GUICtrlCreateMenu("&Einstellungen")
$mSetPrinter = GUICtrlCreateMenuItem("Druckerserver einstellen", $mSettings)
$mImport = GUICtrlCreateMenuItem("Datenimport manuell", $mSettings)
$mImportAuto = GUICtrlCreateMenuItem("Datenimport automatisch", $mSettings)

$mInfo = GUICtrlCreateMenu("&Info")
$mUeberTool = GUICtrlCreateMenuItem("Über dieses Tool", $mInfo)
$mAutoitLink = GUICtrlCreateMenuItem("Autoit Webseite", $mInfo)
$mTutorial = GUICtrlCreateMenuItem("Anleitung", $mInfo)

GUISetCursor (0)
GUISetBkColor(0xC0C0C0)
$Combo1 = GUICtrlCreateCombo("- - - - - - - -", 11, 200, 213, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$Combo2 = GUICtrlCreateCombo("- - - - - - - -", 11, 248, 213, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$Button1 = GUICtrlCreateButton("Verbinden", 151, 280, 75, 25)
$ZURUECK = GUICtrlCreateButton("<", 186, 168, 19, 25)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetCursor (-1, 0)
$VOR = GUICtrlCreateButton(">", 207, 168, 19, 25)
$Label3 = GUICtrlCreateLabel("Raum", 14, 184, 32, 17)
$Label4 = GUICtrlCreateLabel("Drucker", 14, 232, 42, 17)
$Graphic2 = GUICtrlCreateGraphic(0, 0, 241, 41)
GUICtrlSetBkColor(-1, 0x800080)

$Pic1 = GUICtrlCreatePic(@ScriptDir & "\data\bilder\0"& Random(1, 9, 1)&".jpg", 0, 40, 236, 124)

$Label5 = GUICtrlCreateLabel("Drucker Client2020 verbinden", 16, 3, 206, 20)
GUICtrlSetFont(-1, 10, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x800080)
$Label1 = GUICtrlCreateLabel("-- Printserver --", 16, 23, 202, 17)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x800080)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

checkDatabase()

Global $printServer,$printServerName

Global $Printservers[0]
;~ Global $printerTypes[0]

Global $importBlocked
Global $removePrintersOnExit
iniAuslesen()
;~ $printerTypes=printerTypesAuslesen()
;~ printerTypesAuslesen()
;~ _ArrayDisplay($printerTypes)


Global $drucker = DruckerDynamischEinlesen()
Global $raeume[0]


Global $BilderZaehler = 0
Global $galeriestart = 0
Global $bilder[]=["00.jpg","01.jpg","02.jpg","03.jpg","04.jpg","05.jpg","06.jpg","07.jpg","08.jpg","09.jpg"]

;~ \\sc058503 - Riesstrasse
;~ \\sc005303 - Bergsonstrasse

RaeumeVonDBEinlesen()
populateRaum()
raumVorbelegung()

;~ func printerTypesAuslesen()
;~ 	$file = @ScriptDir & "\data\printertypes.ini"
;~ 	FileOpen($file, 0)
;~ 	For $i = 1 to _FileCountLines($file)
;~ 		$line = FileReadLine($file, $i)
;~ 		msgbox(0,'','the line ' & $i & ' is ' & $line)
;~ 		_ArrayAdd($printerTypes,$line)
;~ 	Next
;~ 	FileClose($file)
;~ 	return $printerTypes
;~ EndFunc

func iniAuslesen()
	$handle_read = FileOpen(@ScriptDir & "\data\druckerTool.ini", 0)
	If $handle_read = -1 Then
		MsgBox(0, @ScriptName, 'Datei konnte nicht geöffnet werden')
		Exit 1
	EndIf
	local $line = FileReadLine($handle_read, 1)
	local $zeilenTeil = StringSplit( $line, ":")
	$printServerName = $zeilenTeil[1]
	$printServer = $zeilenTeil[2]

	GUICtrlSetData($Label1,$printServerName&": "&$printServer)
	$importBlocked = FileReadLine($handle_read, 2)
	$removePrintersOnExit  = FileReadLine($handle_read, 3)
;~ 	ConsoleWrite("$importBlocked : " & $importBlocked & @CRLF)
;~ 	ConsoleWrite("$removePrintersOnExit : " & $removePrintersOnExit & @CRLF)
;~ 	MsgBox(0, @ScriptName, $printServer)
;~ 	MsgBox(0, @ScriptName, $importBlocked)
	if $importBlocked=1 then
		GuiCtrlSetState($mSettings, $GUI_DISABLE)
		GuiCtrlSetState($mTutorial, $GUI_DISABLE)
	endif
	FileClose($handle_read)
EndFunc


Func raumVorbelegung()
   Local $Database = @ScriptDir & "\data\raumpc.db"
   Local $aRow
   Local $pc = @ComputerName
;~    ConsoleWrite($pc)
   _SQLite_Startup()
   If @error Then
	  MsgBox($MB_SYSTEMMODAL, "SQLite Error", "SQLite3.dll Can't be Loaded!")
	  Exit -1
   EndIf

   Local $pcdb = _SQLite_Open($Database) ;wenn nicht existent, wird db erstellt
   If @error Then
	  MsgBox($MB_SYSTEMMODAL, "SQLite Error", "Can't open or create a permanent Database!")
	  Exit -1
   EndIf

  _SQLite_QuerySingleRow($pcdb, "select Raum from raumpc where upper(Rechner) = '" & $pc & "';" , $aRow)
ConsoleWrite($aRow[0]&@CRLF)
   if $aRow[0] <> "" then
	  _GUICtrlComboBox_SelectString ($combo1, $aRow[0])
	  populateDrucker()
   Else
	  GUICtrlSetData($combo1, "- - - - - - - -","- - - - - - - -")
   EndIf
_SQLite_Close()
_SQLite_Shutdown()

EndFunc


Func populateRaum()
   For $elR IN $raeume
	  For $elD IN $drucker
		 If StringInStr($elD,$elR) Then
			GUICtrlSetData($combo1, $elR)
		 EndIf
	  Next
   Next
EndFunc

Func populateDrucker()
   _GUICtrlComboBox_ResetContent($Combo2)
   $zimmer = GUICtrlRead($Combo1)
   For $element IN $drucker
    If StringInStr($element,$zimmer) Then
	   GUICtrlSetData($combo2, $element)
    EndIf
   Next
EndFunc

Func druckerVerbinden()
   $selPrinter = GUICtrlRead($combo2)
   if $selPrinter = "- - - - - - - -" or $selPrinter = "" Then
	   MsgBox($MB_SYSTEMMODAL, "Info", "kein Drucker ausgewaehlt")
	else
		$Path = $printServer&"\"&$selPrinter
		Run("C:\WINDOWS\EXPLORER.EXE /n,/e," & $Path)
	EndIf

EndFunc

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			delFile(@ScriptDir & "\data\tmp.txt")

			local $anzahlPrinters = AnzahlConnectedPrinters()+1
;~ 			MsgBox($MB_SYSTEMMODAL, "Anzahl Printers",$anzahlPrinters )
			if $removePrintersOnExit = 1 and $anzahlPrinters > 0 Then
				local $ans = removePrintersOnExit() ;~  1 ;OK  2 ;Cancel
				if $ans = 1 Then
					RunWait ("data\removePrinters.exe")
					Exit
				EndIf
			Else
				Exit
			EndIf
		Case $mClose
			delFile(@ScriptDir & "\data\tmp.txt")

			local $anzahlPrinters = AnzahlConnectedPrinters()+1
;~ 			MsgBox($MB_SYSTEMMODAL, "Anzahl Printers",$anzahlPrinters )
			if $removePrintersOnExit = 1 and $anzahlPrinters > 0 Then
				local $ans = removePrintersOnExit() ;~  1 ;OK  2 ;Cancel
				if $ans = 1 Then
					RunWait ("data\removePrinters.exe")
					Exit
				EndIf
			Else
				Exit
			EndIf
		 Case $Combo1
			populateDrucker()
		 Case $Button1
			druckerVerbinden()
		 Case $mOpenPrintServerDir
			$Path = $printServer&"\"
			Run("C:\WINDOWS\EXPLORER.EXE /n,/e," & $Path)
;~ 		 Case $mClose
;~ 			Exit
		Case $VOR
			Bildgalerie_vor()
		Case $ZURUECK
			Bildgalerie_zurueck()
		 Case $mUeberTool
			MsgBox(64, "Info", "Tool zum Verbinden mit einem beliebigen Drucker." & @CRLF & _
			"" & @CRLF & _
			"Zuvor muessen noch die Daten zu PCs und Raeumen importiert werden, sowie der Server mit den Druckerfreigaben eingetragen werden - siehe Menue Einstellungen -> Datenimport." & @CRLF & _
			"Dieses Tool wurde mit Autoit erstellt." & @CRLF & _
			""&@CRLF&@CRLF&@CRLF&"Natalie Scheuble, Januar 2018")
		Case $mAutoitLink
			Run(@ComSpec & " /c Start https://www.autoitscript.com/site/autoit/")
		Case $mImportAuto
			RunWait ("data\autoImport.exe")
			RestartScript()
		Case $mImport
			RunWait ("data\import.exe")
			RestartScript()
		Case $mSetPrinter
			RunWait ("data\printserver.exe")
			RestartScript()
		Case $mShowPrinters
			_ArrayDisplay($drucker, "Verfuegbare Drucker")
		Case $removePrinter
			RunWait ("data\removePrinters.exe")
		Case $connectedPrinters
;~ 			local $sCommandShowPrinter = 'wmic printer get name'
;~ 			Run(@ComSpec & " /k " & 'wmic printer get name', @WindowsDir, @SW_SHOW)
			listConnectedPrinters()
		Case $mShowDB
			Run ("data\anzeigeDB.exe")
		Case $mTutorial
			Run(@ComSpec & " /c Start https://youtu.be/np3En8HGgrY")
	EndSwitch
WEnd


Func RestartScript()
    If @Compiled = 1 Then
        Run( FileGetShortName(@ScriptFullPath))
    Else
        Run( FileGetShortName(@AutoItExe) & " " & FileGetShortName(@ScriptFullPath))
    EndIf
    Exit
EndFunc



Func RaeumeVonDBEinlesen()
	Local $Database = @ScriptDir & "\data\raumpc.db" ;Location Of Database file
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
  ; Query
	$iRval = _SQLite_GetTable(-1, "select distinct Raum from raumpc order by Raum;", $aResult, $iRows, $iColumns)
	If $iRval = $SQLITE_OK Then
		; $aResult sieht so aus:
		; [0]    = 8
		; [1]    = field2
		; [2]    = D401
		; [3]    = F215
		; d.h. die eigentlichen Daten sind ab $aResult[2]  - [0] ist die Anzahl Datensätze, [1] ist der Spaltenname
;~ 		_ArrayDisplay($aResult, "Query Result")
	Else
		MsgBox($MB_SYSTEMMODAL, "SQLite Error: " & $iRval, _SQLite_ErrMsg())
	EndIf
	For $i = 2 To UBound($aResult) - 1
		_ArrayAdd($raeume, $aResult[$i])
	Next
;~ 			_ArrayDisplay($raeume, "Query Result")
	_SQLite_Close()
	_SQLite_Shutdown()
EndFunc

;~ Func DruckerDynamischEinlesen()
;~ 	Local $pattern ='([Ky|Canon|Epson|HP|EPSON].{20,40}\S\d)'
;~ 	Local $druckerArrDynamisch[0]
;~ 	Local $testValueOld = ""
;~ 	Local $testValueNew = ""
;~ 	Local $sCommand = "net view \\sc029903"
;~ 	Local $sCommand = "net view " & $printServer
;~ 	ConsoleWrite($sCommand)
;~ 	Local $returnDrucker = _RunCmd ($sCommand)
;~ 	Global $aTempArray = StringRegExp($returnDrucker, $pattern, $STR_REGEXPARRAYGLOBALMATCH)
;~ 	For $i = 1 To UBound($aTempArray) - 1
;~ 		$testValueNew = $aTempArray[$i]
;~ 		if $testValueNew <> $testValueOld then _ArrayAdd($druckerArrDynamisch, $aTempArray[$i])
;~ 		$testValueOld = $aTempArray[$i]
;~ 	Next
;~ 	ConsoleWrite($returnDrucker)
;~ 	return $druckerArrDynamisch
;~ EndFunc

Func DruckerDynamischEinlesen()
	Local $druckerArrDynamisch[0]
	Local $testValueOld = ""
	Local $testValueNew = ""
	Local $sCommand = "net view " & $printServer

	Local $returnDrucker = _RunCmd ($sCommand)

	Local $file = FileOpen(@ScriptDir & "\data\tmp.txt", 2)
    If $file = -1 Then
        MsgBox($MB_SYSTEMMODAL, "", "An error occurred whilst writing the temporary file.")
        Return False
    EndIf
    FileWrite($file, $returnDrucker)
    FileSetPos($file, 0, $FILE_BEGIN)

	While 1
		local $tmp,$tmp2
		local $posDrucker
		; read each line from a file
		$line_read = FileReadLine($file)
		; exit the loop if end of file
		If @error Then ExitLoop
		if StringInStr ( $line_read, "Drucker") then
			$posDrucker = StringInStr ( $line_read, "Drucker")
;~ 			ConsoleWrite($posDrucker & @CRLF)
			$tmp = StringLeft ($line_read, $posDrucker -1 )
			$tmp2 = StringStripWS ( $tmp, 2 )
			_ArrayAdd($druckerArrDynamisch, $tmp2)
		EndIf

;~ 		For $i = 0 to UBound($printerTypes) -1
;~ 			if StringInStr ( $line_read, $printerTypes[$i]) Then
;~ 				$tmp = StringLeft ($line_read, 35 )
;~ 				$tmp2 = StringStripWS ( $tmp, 2 )
;~ 				ConsoleWrite($tmp2 & @CRLF)
;~ 				_ArrayAdd($druckerArrDynamisch, $tmp2)
;~ 			EndIf
;~ 		next
	WEnd







;~ 	While 1
;~ 		local $tmp,$tmp2
;~ 		$line = FileReadLine($file)
;~ 		For $i = 0 to UBound($printerTypes) -1
;~ 			if StringInStr ( $line, $printerTypes[$i]) Then
;~ 				$tmp = StringLeft ($line, 38 )
;~ 				$tmp2 = StringStripWS ( $tmp, 2 )
;~ 				_ArrayAdd($druckerArrDynamisch, $tmp2)
;~ 			EndIf
;~ 			ConsoleWrite($tmp2 & @CRLF)
;~ 		next
;~ 	ConsoleWrite($line & @CRLF)
;~ 	WEnd
;~ 	FileClose($file)
;~ 	$printerTypes
;~ 	_ArrayDisplay($druckerArrDynamisch)

;~ 	return $druckerArrDynamisch
	Local $test[2] = ["Org Item 0", "Org item 1"]

;~ 	delFile(@ScriptDir & "\data\tmp.txt")
	return $druckerArrDynamisch
;~ 	return $test
EndFunc

Func _RunCmd ($sCommand)
	 If StringLeft ($sCommand, 1) = " " Then $sCommand = " " & $sCommand
	 Local $nPid = Run (@Comspec & " /c" & $sCommand, "", @SW_Hide, 8), $sRet = ""
	 If @Error then Return "ERROR:" & @ERROR
		ProcessWait ($nPid)
	 While 1
		$sRet &= StdoutRead($nPID)
		If @error Or (Not ProcessExists ($nPid)) Then ExitLoop
	 WEnd
	 Return $sRet
EndFunc ; ==> _RunCmd

Func Bildgalerie_vor()
	if $galeriestart = 0 Then
		$galeriestart = 1
		GUICtrlSetImage ($Pic1, @ScriptDir & "\data\bilder\00.jpg")
	Else
		if $BilderZaehler < 9 Then
			GUICtrlSetState($ZURUECK, $GUI_show)
			$BilderZaehler += 1
			GUICtrlSetImage ($Pic1, @ScriptDir & "\data\bilder\0"&$BilderZaehler&".jpg")
			if $BilderZaehler = 9 then GUICtrlSetState($VOR, $GUI_hide)
		Else
			GUICtrlSetImage ($Pic1, @ScriptDir & "\data\bilder\0"&$BilderZaehler&".jpg")
		EndIf
	EndIf
EndFunc

Func Bildgalerie_zurueck()
		if $BilderZaehler > 0 Then
			GUICtrlSetState($VOR, $GUI_show)
			if $BilderZaehler = 1 then GUICtrlSetState($ZURUECK, $GUI_hide)
			$BilderZaehler -= 1
			GUICtrlSetImage ($Pic1, @ScriptDir & "\data\bilder\0"&$BilderZaehler&".jpg")
		Else
;~ 			GUICtrlSetState($ZURUECK, $GUI_hide)
			GUICtrlSetImage ($Pic1, @ScriptDir & "\data\bilder\0"&$BilderZaehler&".jpg")
		EndIf
EndFunc

Func listConnectedPrinters()
	Local $conPrinters=[0]
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
;~ 		nach \\ filtern
		For $i = 0 To UBound($aArray) - 1
			 If StringInStr($aArray[$i],"\\") Then
			_ArrayAdd($conPrinters, $aArray[$i])
			endif
		Next
		_ArrayDelete($conPrinters,0)
        ; Display the results.
        _ArrayDisplay($conPrinters)
    EndIf
EndFunc

Func AnzahlConnectedPrinters()
	Local $conPrinters=[0]
	Local $sFilePath = @ScriptDir
    Local $iPID = Run(@ComSpec & ' /C wmic printer get name ', $sFilePath, @SW_HIDE, $STDOUT_CHILD)
    ProcessWaitClose($iPID)
    Local $sOutput = StdoutRead($iPID)
    Local $aArray = StringSplit(StringTrimRight(StringStripCR($sOutput), StringLen(@CRLF)), @CRLF)
    If @error Then
        MsgBox($MB_SYSTEMMODAL, "", "Error getting Printers")
    Else
;~ 		nach \\ filtern
		For $i = 0 To UBound($aArray) - 1
			 If StringInStr($aArray[$i],"\\") Then
			_ArrayAdd($conPrinters, $aArray[$i])
			endif
		Next
		_ArrayDelete($conPrinters,0)
        ; Display the results.
		Local $AnzahlPrinters = Ubound($conPrinters) - 1
        return $AnzahlPrinters
    EndIf
EndFunc

Func checkDatabase()
	local $dbok = 0
	Local $Database = @ScriptDir & "\data\raumpc.db"
	if FileExists($Database) then $dbok = 1
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
	if $dbok = 0 then
		_SQLite_Exec(-1, "CREATE TABLE raumpc (Rechner,Raum);") ; CREATE a Table
	EndIf
	_SQLite_Close()
	_SQLite_Shutdown()
EndFunc

func delFile($f)
	If FileExists($f) Then
		fileDelete($f)
	EndIf
EndFunc

func removePrintersOnExit()
	$iMsgBoxAnswer = MsgBox(33,"Drucker entfernen?","Sobald das Tool geschlossen wird, werden alle manuell verbundenen Drucker entfernt")
	Select
		Case $iMsgBoxAnswer = 1 ;OK
		Case $iMsgBoxAnswer = 2 ;Cancel
	EndSelect
	return $iMsgBoxAnswer
EndFunc