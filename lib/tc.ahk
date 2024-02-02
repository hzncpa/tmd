; #IfWinActive, ahk_class TTOTAL_CMD
; ^8::
; ControlGetText, test, TPathPanel2, ahk_exe TOTALCMD.EXE
; if (RegExMatch(test, "\\>.+"))
;    PostMessage,1075, 312, 0, , ahk_class TTOTAL_CMD
; Else
;     TC_EMC("em_showAV")
; Return


; #IfWinActive
TC_CM(num,param:=""){
SendMessage 1075,%num%,%param%, ,ahk_class TTOTAL_CMD
return 1
}

TC_EMC( cmd, wID="ahk_class TTOTAL_CMD", activateWin=FALSE, showMsg=FALSE ) {
	TC_Activate( wID, activateWin, showMsg, cmd )
	TC_SendWMCopyData( "EM", cmd, params:="", wID )
	Return
}


TC_CD@( wID, src="", trg="", params="", activateWin=TRUE ) {
	if( activateWin )
		WinActivate, % ( wID+0 ? "ahk_id " wID : wID )
	TC_SendWMCopyData( "CD", cmd:=(src " `r" trg " "), params, wID )
	Return
}

TC_Activate( byRef wID, activateWin=TRUE, showMsg=TRUE, cmd="" ) {
	wID:=QueryWinID(wID, TRUE)
	if(!activateWin )
		Return FALSE
	if( showMsg )
		MsgBox,,%A_ThisFunc%, % "Activating TC" ( cmd ? ", for command: " cmd "`n" : "`n"), 1
	WinActivate, ahk_id %wID%
	Return TRUE
}

QueryWinID( aWin="A", canExist=FALSE, winText="", notTitle="", notText="" ) {
	if( !(retVal:=WinActiveA( aWin, winText, notTitle, notText )) )
		retVal:=( !canExist ? 0 : WinExistA( aWin, winText, notTitle, notText ))
	Return retVal
}

WinActiveA( aWin="", winText="", notTitle="", notText="" ) {
	Return WinActive( (aWin+0 ? "ahk_id " aWin : aWin), winText, notTitle, notText )
}

WinExistA( aWin="", winText="", notTitle="", notText="" ) {
	Return WinExist( (aWin+0 ? "ahk_id " aWin : aWin), winText, notTitle, notText )
}

; TC_CD(src := "", target := ""){
; 	srcLen := StrLen(src), tgtLen := StrLen(target)
; 	cmd := srcLen ? src "`r" (tgtLen ? target : "") 
; 		:  "`r" target
; 	; clipboard := cmd
; 	TC_SendWMCopyData( "CD", cmd, "", "ahk_class TTOTAL_CMD" )
; }


;;
;; AutoHotkey_L Function
;;     cmdType: "CD" or "EM"
;;     cmd(1): name of user command, e.g. em_FOO
;;     cmd(2): formatted string with path's to CD to,
;;                  e.g. "C:\`rC:\Users"
;;     addParams: for CD only, e.g. ST, S, T

TC_SendWMCopyData( cmdType, byRef cmd, byRef addParams="", aWin="A" ) {
	aWin := (aWin+0) ? aWin : WinExist(aWin)
	; aWin := aWin ? aWin : WinExist("ahk_class TTOTAL_CMD")
	
	Critical

	VarSetCapacity( CopyDataStruct, A_PtrSize * 3 )
	if( A_IsUnicode )
	{
		VarSetCapacity( cmdA, StrPut(cmd, "cp0") + 1)
		Loop, % StrLen(cmd)
			NumPut( Asc(SubStr(cmd, A_Index, 1)), cmdA, A_Index - 1, "Char")
		NumPut( 0, cmdA, StrLen(cmd), "Char")  ; Add the '\0' char to the end of the string and terminate it, otherwise, changes are that unwanted char present.
	}
	NumPut( Asc(SubStr(cmdType,1,1)) + 256 * Asc(SubStr(cmdType,2,1)), CopyDataStruct )
	NumPut( StrLen(cmd) + (cmdType="CD" ? 5 : 1), CopyDataStruct, A_PtrSize )
	NumPut((A_IsUnicode ? &cmdA : &cmd), CopyDataStruct, A_PtrSize * 2)
	NumPut( &cmdA, CopyDataStruct, A_PtrSize * 2)


	Loop, % (cmdType=="CD" ? 2 : 0)
		NumPut( Asc(SubStr(addParams, A_Index, 1)), (A_IsUnicode ? cmdA : cmd), (StrLen(cmd) + A_Index), "Char" )
	SendMessage, 0x4A,, &CopyDataStruct,, ahk_id %aWin%
	Return
}