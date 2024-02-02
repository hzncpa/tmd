;*************************************  admin    ***********************
loop, %0%
{
	param := %A_Index% ; Fetch the contents of the variable whose name is contained in A_Index.
	params .= A_Space . param
}
ShellExecute := A_IsUnicode ? "shell32\ShellExecute":"shell32\ShellExecuteA"
if not A_IsAdmin
{
	if A_IsCompiled
		DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
	else
		DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)
	ExitApp
}
global TC_Quick_Command_update_version:="2.3.0" ;Version
global TC_Quick_Command_update_time:="2022.09.22" ;update date
global Showarr := {}
;*************************************   exec    ***********************
#SingleInstance Force
#MaxMem 640
#KeyHistory 0
#Persistent
SetBatchLines -1
DetectHiddenWindows On
SetWinDelay -1
SetControlDelay -1
SetWorkingDir %A_ScriptDir%
CoordMode, ToolTip, Screen
CoordMode, Caret , Screen
CoordMode, Mouse, Screen
ListLines Off
#Include %A_ScriptDir%
#Include <btt>
#Include <tc>
#Include <class_listbox>
; OnMessage(0x020A,"Mouse_MButton_W1")
; OnMessage(0x0201,"Mouse_LButton_D1")
;icon
Menu, Tray, Icon, tc.ico
;if ini change reload
time:=A_Now
#Persistent
SetTimer,re_index,3000

index:
	st:=class_EasyIni("settings.ini")	;Read settings
	for stkey,stv in st["settings"]
		%stkey%:=stv
	;*************************************  btt style     ***********************
	BttStyle := {Margin:10 ; If omitted, 5 will be used. Range 0-30.
		, TabStops:[50, 80, 100] ; If omitted, [50] will be used. This value must be an array.
		, TextColor:"0xff" . 预览字体颜色 ; ARGB
		, BackgroundColor:"0xff" . 预览背景颜色 ; ARGB
		, Font:预览字体名称 ; If omitted, ToolTip's Font will be used. Can specify the font file path.
		, FontSize:预览字体大小 ; If omitted, 12 will be used.
		, FontRender:5 ; If omitted, 5 will be used. Range 0-5.
	, FontStyle:"Regular"}
	Btt(启动词, 0, 0, ,"BttStyle")
	SetTimer, Gui_Destroy, -1000

	;************************************* keyboard ***********************
	; Hotkey,F10,reload                                                            ;重启脚本
	Hotkey, IfWinActive, ahk_class TTOTAL_CMD
		if (键盘呼出搜索框)
		Hotkey,% st.settings.键盘呼出搜索框, searchBar_keyboard	;快捷键激活搜索框by光标
	if (控件呼出搜索框)
		Hotkey,% st.settings.控件呼出搜索框, searchBar_control	;快捷键激活搜索框by控件
	if (鼠标呼出搜索框)
		Hotkey,% st.settings.鼠标呼出搜索框, searchBar_Mouse	;鼠标激活搜索框
	if (重复命令)
		Hotkey,% st.settings.重复命令,reexec ;重复上一条命令
	Hotkey, if, (WinActive("ahk_id " MyGuiHwnd) && (Showstr))
	Hotkey, Enter, exec		;防止误触可以改成下面的ctrl Enter执行
	; Hotkey, ^Enter, exec
	Hotkey, esc,Gui_Destroy
	Hotkey,% st.settings.复制全部内容, copy_all	;ctrl c copy all
	Hotkey,% st.settings.复制名字, copy_name	;ctrl 1复制em or cm name
	Hotkey,% st.settings.复制号码或命令, copy_num_cmd	;ctrl 2 copy cmd or num
	Hotkey,% st.settings.复制Menu, copy_menu	;ctrl 3 copy em or cm Menu
	Hotkey,% st.settings.开关预览,open_or_hide
	Hotkey,% st.settings.编辑em,edit_command
	Hotkey,% st.settings.ding命令,ding
	Hotkey, if

	;*************************************get the user and win ini path  ***********************
	


;************form caps***********************************************
COMMANDER_PATH := % GF_GetSysVar("COMMANDER_PATH")
WinGet,TcExeFullPath,ProcessPath,ahk_class TTOTAL_CMD
if !TcExeFullPath ;没tc在运行
{
	if A_Is64bitOS {
		if FileExist(A_WorkingDir . "\" . "TOTALCMD64.EXE") {
			TcExeFullPath := % A_WorkingDir . "\" . "TOTALCMD64.EXE"
			COMMANDER_PATH := % A_WorkingDir
			COMMANDER_NAME := "TOTALCMD64.EXE"
			COMMANDER_EXE := COMMANDER_PATH . "\" . "TOTALCMD64.EXE"
			EnvSet,COMMANDER_PATH, %COMMANDER_PATH%
		} else if FileExist(A_WorkingDir . "\" . "TOTALCMD.EXE") {
			TcExeFullPath := % A_WorkingDir . "\" . "TOTALCMD.EXE"
			COMMANDER_PATH := % A_WorkingDir
			COMMANDER_EXE := COMMANDER_PATH . "\" . "TOTALCMD.EXE"
			EnvSet,COMMANDER_PATH, %COMMANDER_PATH%
		} else{
			;toolTip 当前目录下没Totalcmd程序
			;sleep 2000
			;tooltip
		}
	}
	else {
		if FileExist(A_WorkingDir . "\" . "TOTALCMD.EXE") {
			TcExeFullPath := A_WorkingDir . "\" . "TOTALCMD.EXE"
			COMMANDER_PATH := % A_WorkingDir
			EnvSet,COMMANDER_PATH, %COMMANDER_PATH%
		} else {
			;toolTip 当前目录下没Totalcmd程序
			;sleep 2000
			;tooltip
		}
	}
}
else{ ;有tc在运行
	if(COMMANDER_PATH == A_WorkingDir) {
	EnvSet,COMMANDER_PATH, %COMMANDER_PATH%
}
else if !COMMANDER_PATH ;但脚本先启动，比如随系统自启动，所以并没有COMMANDER_PATH变量
{
	WinGet,TcExeName,ProcessName,ahk_class TTOTAL_CMD
	StringTrimRight, COMMANDER_PATH, TcExeFullPath, StrLen(TcExeName)+1
	EnvSet,COMMANDER_PATH, %COMMANDER_PATH%
}
}
;*********************************************************************
if (!wincmd路径){
if (FileExist(COMMANDER_PATH "\wincmd.ini"))
    wincmd路径:=COMMANDER_PATH "\wincmd.ini"
else if (FileExist(appdata "\ghisler\wincmd.ini") )
    wincmd路径:=appdata "\ghisler\wincmd.ini"
else{
    MsgBox,wincmd路径没填且不在常见路径
    run "settings.ini"
    ExitApp
}
}

if (!usercmd路径){
if (FileExist(COMMANDER_PATH "\usercmd.ini"))
    usercmd路径:=COMMANDER_PATH "\usercmd.ini"
else if (FileExist(appdata "\ghisler\usercmd.ini") )
    usercmd路径:=appdata "\ghisler\usercmd.ini"
else{
    MsgBox,usercmd路径没填且不在常见路径
    run "settings.ini"
    ExitApp
}
}

;*************************************  ***********************
	usercmd:=class_EasyIni(usercmd路径)
	win:=class_EasyIni(wincmd路径)
	cm:=class_EasyIni("cm.ini")
	if (LanguageEM!="")
		tz:=class_EasyIni(LanguageEM)
	if (tz)
		usercmd.merge(tz)
	if (shortcuts路径!="")
		sc:=class_EasyIni(shortcuts路径)
	else{
		if (win.FindKeys("Shortcuts","RedirectSection").1="RedirectSection"){
			sc:=class_EasyIni(str2env(win.Shortcuts.RedirectSection))
			sc_sigh:="re"
		}
		else
			sc_sigh:="win" ;win and re
	}

;tcmatch path

if (!dllPath || !FileExist(dllPath)){
	Loop Files,%com%\*.dll,R
		{
		if (A_LoopFileName="tcmatch.dll"){
			st.settings.dllPath:=dllPath :=A_LoopFileFullPath
			st.settings.MatchFileW:=MatchFileW :=A_LoopFileDir "\TCMatch\MatchFileW"
			st.save()
			}
		}
}

if (!FileExist(dllPath)){
	MsgBox,没有32位的tcmtach`,群里下个吧哈哈哈
	ExitApp
}
OnMessage(0x5555, "MsgMonitor")
return

MsgMonitor(wParam, lParam, msg){
		WinGetClass, cls, A
		if( cls = "TTOTAL_CMD" )
			Gosub, searchBar_keyboard
}

match_cm_arr:
	for sec,kv in cm{
		if (cm[sec]["Menu"]!="" && !RegExMatch(cm[sec]["Menu"],隐藏菜单规则)){
			cm_want_all:=sec " " cm[sec]["Menu"]
			cm_num:=cm_want_all . cm[sec]["num"]
			Query:=RegExReplace(Query,"^:") ;del c:
			if (InStr(Query," ")){
				Query_cm_arr := StrSplit(Query, " ")
				for query_a,query_b in Query_cm_arr{
					if (!TCMatch(cm_num,query_b)){
						find_cm_sign := false
						break
					}
					if (TCMatch(cm_num,query_b))
						find_cm_sign := true
				}
				if (find_cm_sign = true)
					Showarr.Push(cm_want_all)
			}else{
				if (TCMatch(cm_num,Query))
					Showarr.Push(cm_want_all)
			}
		}

	}

return

match_em_arr:
	For k,v in usercmd
	{
		if (usercmd[k]["Menu"]!="" && !RegExMatch(usercmd[k]["Menu"],隐藏菜单规则)){
			em_want_all:=k " " usercmd[k]["Menu"]
			; if \s spilt Query to arr
			if (InStr(Query," ")){
				Query_em_arr := StrSplit(Query, " ")
				for a,b in Query_em_arr{
					if (!TCMatch(em_want_all,b)){
						find_em_sign := false
						break
					}
					if (TCMatch(em_want_all,b))
						find_em_sign := true
				}
				if (find_em_sign = true)
					Showarr.Push(em_want_all)
			}else{
				if (TCMatch(em_want_all,Query)){
					Showarr.Push(em_want_all)
				}
			}
		}

	}
return

reload:
	Reload
return

Refresh:
	Showstr :=cm_mode_sigh:= ""
	Showarr := {}
	ControlGetText, Query, , ahk_id %SSK%
	if (Query!=""){
		;first try to match cm
		if (RegExMatch(Query, "^:")){ ;the sigh of match cm
			cm_mode_sigh:=1
			gosub match_cm_arr
			gosub update_listbox
			return
		}
		cm_mode_sigh:=0			;then we match em
		gosub match_em_arr
		gosub update_listbox
		if (焦点从零开始=1){
			if (CListBox.GetCurrentSel(LIST)=1)
				GuiControl, ss:Choose, command,0
		}
	}else if (Query=""){
				Showarr.Push(st.history.last A_Space "**the last command**")
			for k,v in st.ding{
				Showarr.Push(k A_Space v)
			}
			gosub update_listbox
		}
return

update_listbox:
	GuiControl, ss:, -Redraw, Command
	For Showstrk,Showstrv in Showarr
	{
		Showstr .= "|" Showstrk " " Showstrv
		n := A_Index
	}
	; Showstr := (Query) ? Showstr : ""
	gosub updateList
	GuiControl, ss:, +Redraw, Command
return

Preview: ;remove preview
	if (A_GuiEvent = "DoubleClick")
		gosub exec
	Gui, ss:Submit, NoHide
	if (显示预览=1){
	gosub cmem_preview
	btt_which(预览位置)
	}
return

btt_which(which){
	global
	if (which="右")
		btt_pos := Btt(Bttstr, xpos+列表宽度+5, ypos, ,"BttStyle")
	else if (which="左")
		btt_pos := Btt(Bttstr, xpos-btt_pos.w, ypos, ,"BttStyle")
	Else if (which="上")
		btt_pos := Btt(Bttstr, xpos, ypos-250, ,"BttStyle"), btt_pos := Btt(Bttstr, xpos, ypos-btt_pos.h, ,"BttStyle")
return
}

shortcuts_search:
if (sc_sigh="re"){
	for sec,kv in sc{
		for k,v in sc[sec]{
			if (v=command){
				gosub v_command
				Return
			}
		}
	}
	shortcuts:="null"
}else if (sc_sigh="win"){
	for k,v in win.Shortcuts{
			if (v=command){
				gosub v_command
				Return
			}
	}
	for k,v in win.ShortcutsWin{
			if (v=command){
				gosub v_command
			}
			Return
	}
	shortcuts:="null"
}
return

v_command:
shortcuts:=""
shortcuts:=RegExReplace(k, "^A\+","Alt+")
shortcuts:=RegExReplace(shortcuts, "^C\+","Ctrl+")
shortcuts:=RegExReplace(shortcuts, "^CS\+","Ctrl+Shift+")
shortcuts:=RegExReplace(shortcuts, "^AS\+","Alt+Shift+")
shortcuts:=RegExReplace(shortcuts, "^CA\+","Ctrl+Alt+")
shortcuts:=RegExReplace(shortcuts, "^CAS\+","Ctrl+Alt+Shift+")
shortcuts:=RegExReplace(shortcuts, "^S\+","Shift+")
return

cmem_preview:
	arr_command:=StrSplit(command, " ")
	command:=arr_command[2] , Bttstr :=""
    if (RegExMatch(command, "^cm")){
    	cm_num:=cm[command]["num"]
        cm_menu:=cm[command]["Menu"]
        gosub shortcuts_search
	    Bttstr=
	    (
[%command%]
num=%cm_num%
menu=%cm_menu%
shortcuts=%shortcuts%
	    )
    }else if (RegExMatch(command, "^em")){
        em_menu:=usercmd[command]["Menu"]
        em_cmd:=usercmd[command]["cmd"]
        em_param:=usercmd[command]["param"]
        em_button:=usercmd[command]["button"]
        gosub shortcuts_search
        Bttstr=
        (
[%command%]
cmd=%em_cmd%
menu=%em_menu%
param=%em_param%
button=%em_button%
shortcuts=%shortcuts%
	    )
    }
return


searchBar:
	gosub Gui_Destroy
	Gui, ss:Margin, 0, 0
	Gui, ss:-Caption +Border
	Gui, ss:+AlwaysOnTop -DPIScale +ToolWindow +HwndMyGuiHwnd +E0x02000000 +E0x00080000
	Gui, ss:Font, s%字体大小%, %字体名称%
	Gui, ss:Add, Edit, gRefresh vsearchBar HwndSSK w%列表宽度% -E0x200
	SetEditCueBanner(SSK,搜索框提示)
	Gui, ss:Font, s%字体大小%, %字体名称%
	Gui, ss:Add, ListBox, hwndLIST h0 vCommand -HScroll -E0x200 w%列表宽度% gPreview

	Gui ss:+LastFound ; Make the Gui window the last found window for use by the line below.
	GuiControl, ss:Move, Command, h0
	ControlColor(SSK, MyGuiHwnd, "0x" 搜索框背景颜色, "0x" 字体颜色)
	ControlColor(LIST, MyGuiHwnd, "0x" 列表背景颜色, "0x" 字体颜色)
	xpos:=ypos:=""
	; switchime(1) ;测试输入法切英文
return
shellMessage(wParam, lParam) { ;接受系统窗口回调消息, 第一次是实时，第二次是保障
	if ( wParam=1 || wParam=32772 || wParam=5 || wParam=4) {
		WinGetClass, cls, A
		if( cls != "TTOTAL_CMD" )
			gosub Gui_Destroy
	}
}

show_hook: ;add windows hook
	xpos:=xpos+搜索框右移 , ypos:=ypos+搜索框下移
	Gui, ss:show, AutoSize x%xpos% y%ypos%
	if (输入法英文)
		switchime(1)
	if (窗口切换自动关闭=1){
		Gui ss:+LastFound
		hWnd := WinExist()
		DllCall( "RegisterShellHookWindow", UInt,hWnd )
		MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
		OnMessage( MsgNum, "ShellMessage" )
		; shellMessage(1,1)
	}
return




searchBar_keyboard:
	gosub searchBar
	PostMessage,1075, 2914, 0, , ahk_class TTOTAL_CMD
	Sleep 50
	MouseGetPos,xpos,ypos
	gosub show_hook
	gosub Refresh
return
searchBar_control:
	gosub searchBar
	ControlGetFocus,TLB,ahk_class TTOTAL_CMD
	ControlGetPos,xpos,ypos,wn,,%TLB%,ahk_class TTOTAL_CMD
	gosub show_hook
	gosub Refresh
return
searchBar_Mouse:
	gosub searchBar
	MouseGetPos,xpos,ypos
	gosub show_hook
	gosub Refresh
return

go_preview:
	GuiControl, ss:Choose, command, % ChooseRow
	gosub Preview
return
choose_number(number:="",which:=""){
	global
	if (number!=0){
		ChooseRow:=number
		GuiControl, ss:Choose, command, % ChooseRow
	Sleep 50
	gosub Preview
	if (数字直接执行=1)
		gosub exec
	}else{
		if (which="up")
			ChooseRow := (ChooseRow > 1) ? ChooseRow - 1 : ChooseRow
		else if(which="down")
			ChooseRow := (ChooseRow < n) ? ChooseRow + 1 : ChooseRow
		else if(which="home")
			ChooseRow :=1
		else if(which="end")
			endLine:="" , ChooseRow :=CListBox.GetCount(LIST)
		GuiControl, ss:Choose, command, % ChooseRow
	Sleep 50
	gosub Preview
	}
return
}

open_or_hide:
	if (st["settings"]["显示预览"]=0){
		gosub open_preview
		; gosub go_preview
	}
	else
		gosub hide_preview
return

hide_preview:
	显示预览:=0
	st["settings"]["显示预览"]:=0
	st.save()
	btt()
return
open_preview:
	显示预览:=1
	st["settings"]["显示预览"]:=1
	st.save()
return

ssGuiEscape:
ssGuiClose:
Gui_Destroy:
	Btt()
	Gui, ss:Destroy
return

copy_all:
	Clipboard:="" , Clipboard:=Bttstr
	tips(Bttstr)
return
copy_name:
	Clipboard:="" ,Clipboard:=command
	tips(command)
return
copy_num_cmd:
	if (cm_mode_sigh!=1){
		Clipboard:="" , Clipboard:=em_cmd
		tips(em_cmd)
	}
	else{
		Clipboard:="" , Clipboard:=cm_num
		tips(cm_num)
	}
return
copy_menu:
	if (cm_mode_sigh!=1){
		Clipboard:="" , Clipboard:=em_menu
		tips("em_menu")
	}
	else{
		Clipboard:="" , Clipboard:=cm_menu
		tips("cm_menu")
	}
return

exec:
	gosub Gui_Destroy
	if (cm_mode_sigh!=1){
		TC_EMC(command)
		st.history.em:=1
		st.history.last:=command
}
	else{
		PostMessage,1075,%cm_num%, 0, , ahk_class TTOTAL_CMD
		st.history.last:=cm_num
		st.history.em:=0
}
	st.save()
	gosub Gui_Destroy
	WinActivate ahk_class TTOTAL_CMD
return

reexec:
recmd:=st.history.last
if (st.history.em==1){
	TC_EMC(recmd)
}else if (st.history.em==0){
		PostMessage,1075,%recmd%, 0, , ahk_class TTOTAL_CMD
}
return

tips(text){
	MouseGetPos,xa,ya
	Btt(text,xa,ya,,"BttStyle")
	Sleep 500
	btt_which(预览位置)
return
}

ding:
if (st.FindKeys("ding",command).1=command){
	st.RemoveKey("ding",command)
}else{
	if (RegExMatch(command, "^cm")){
		st["ding"][command]:=cm[command]["menu"]
	}else if (RegExMatch(command, "^em")){
		st["ding"][command]:=usercmd[command]["menu"]
	}
}
st.save()
return


edit_command:
	if (指定编辑器){
		gosub Gui_Destroy
		MouseGetPos,xa,ya
		Btt("打开编辑器",xa,ya, ,"BttStyle")
		SetTimer, Gui_Destroy, -1000
		try
			Run %指定编辑器% %usercmd路径%
		Catch e
			run notepad %usercmd路径%
	}
return

#If (WinActive("ahk_id " MyGuiHwnd) && (Showstr))
	#If
	#If (WinExist("ahk_id " MyGuiHwnd))
	#If

#If (WinActive("ahk_id " MyGuiHwnd) && (Showstr))
!1::choose_number(1)
!2::choose_number(2)
!3::choose_number(3)
!4::choose_number(4)
!5::choose_number(5)
!6::choose_number(6)
!7::choose_number(7)
!8::choose_number(8)
!9::choose_number(9)
up::choose_number(0,"up")
Down::choose_number(0,"down")
home::choose_number(0,"home")
end::choose_number(0,"end")
Left::btt_which("左")
right::btt_which("右")

F1::choose_number(1)
F2::choose_number(2)
F3::choose_number(3)
F4::choose_number(4)
F5::choose_number(5)
F6::choose_number(6)
F7::choose_number(7)
F8::choose_number(8)
F9::choose_number(9)
F10::choose_number(10)
F11::choose_number(11)
F12::choose_number(12)
#If

updateList:
	GuiControl, ss:, Command, % (Showstr) ? Showstr : ""
	if (是否显示所有em=0)
		ListN := ((n < 最大显示行) ? n : 最大显示行) * CListBox.GetItemHeight(LIST)
	else
		ListN := n * CListBox.GetItemHeight(LIST)
	ListN := !(Showstr) ? 0 : ListN
	GuiControl, ss:Move, Command, % "h" ListN
	ChooseRow := 1
	GuiControl, ss:Choose, command, % ChooseRow
	gosub Preview
	Gui, ss:show, AutoSize
	if !(Showstr) {
		Btt()
		GuiControl, ss:, Command, |
	}
return

re_index:
	FileGetTime,last_user, %usercmd路径%, M
	if (last_user-time>0){
		time:=last_user
		gosub index
		return
	}
	FileGetTime,last_st,settings.ini, M
	if (last_st-time>0){
		time:=last_st
		gosub index
		return
	}

	if (tz){
		FileGetTime,last_tz, %LanguageEM%, M
		if (last_tz-time>0){
			time:=last_tz
			gosub index
			return
		}
	}
	if (sc){
		sc_path:=str2env(win.Shortcuts.RedirectSection)
		FileGetTime,last_sc, %sc_path%, M
		if (last_sc-time>0){
			time:=last_sc
			gosub index
			return
		}
	}
	if (win){
		FileGetTime,last_sc, %wincmd路径%, M
		if (last_sc-time>0){
			time:=last_sc
			gosub index
			return
		}
	}
return

ControlColor(Control, Window, bc := "", tc := "", Redraw := True) {
	local a := {}
	a["c"] := Control
	a["g"] := Window
	a["bc"] := (bc == "") ? "" : (((bc & 255) << 16) + (((bc >> 8) & 255) << 8) + (bc >> 16))
	a["tc"] := (tc == "") ? "" : (((tc & 255) << 16) + (((tc >> 8) & 255) << 8) + (tc >> 16))

	CC_WindowProc("Set", a, "", "")

	if (Redraw) {
		WinSet Redraw,, ahk_id %Control%
	}
}
CC_WindowProc(hWnd, uMsg, wParam, lParam) {
	local tc, bc, a
	static Win := {}
	; Critical

	if uMsg Between 0x132 And 0x138 ; WM_CTLCOLOR(MsgBox|Edit|LISTBOX|BTN|DLG|SCROLLBAR|static)
	if (Win[hWnd].HasKey(lParam)) {
		if (tc := Win[hWnd, lParam, "tc"]) {
			DllCall("gdi32.dll\SetTextColor", "Ptr", wParam, "UInt", tc)
		}

		if (bc := Win[hWnd, lParam, "bc"]) {
			DllCall("gdi32.dll\SetBkColor", "Ptr", wParam, "UInt", bc)
		}

		return Win[hWnd, lParam, "Brush"] ; return the HBRUSH to notify the OS that we altered the HDC.
	}

	if (hWnd == "Set") {
		a := uMsg
		Win[a.g, a.c] := a

		if ((Win[a.g, a.c, "tc"] == "") && (Win[a.g, a.c, "bc"] == "")) {
			Win[a.g].Remove(a.c, "")
		}

		if (!Win[a.g, "WindowProcOld"]) {
			Win[a.g,"WindowProcOld"] := DllCall("SetWindowLong" . (A_PtrSize == 8 ? "Ptr" : "")
			, "Ptr", a.g, "Int", -4, "Ptr", RegisterCallback("CC_WindowProc", "", 4), "UPtr")
		}

		if (Win[a.g, a.c, "bc"] != "") {
			Win[a.g, a.c, "Brush"] := DllCall("gdi32.dll\CreateSolidBrush", "UInt", a.bc, "UPtr")
		}

		return
	}

return DllCall("CallWindowProc", "Ptr", Win[hWnd, "WindowProcOld"], "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

SetEditCueBanner(HWND, Cue) { ; requires AHL_L
	Static EM_SETCUEBANNER := (0x1500 + 1)
Return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue)
}
str2env(str){ ;full path
    if (!RegExMatch(str,"%(.+)%"))
        return str
    else{
    EnvGet, OutputVar,% RegExReplace(str, "%(.+)%(.+)","$1")
    return OutputVar . RegExReplace(str, "%(.+)%(.+)","$2")
    }
}

TCMatchOn(dllPath = "") {
    if(g_TCMatchModule)
        return g_TCMatchModule
	g_TCMatchModule := DllCall("LoadLibrary", "Str", dllPath, "Ptr")
    return g_TCMatchModule
}

TCMatchOff() {
    DllCall("FreeLibrary", "Ptr", g_TCMatchModule)
    g_TCMatchModule := ""
}

TCMatch(aHaystack, aNeedle) {
	global
	static  g_TCMatchModule
	; MatchFileW := (A_PtrSize == 8 ) ? "TCMatch64\MatchFileW" : "TCMatch\MatchFileW"
	; dllPath := A_ScriptDir "\Lib\tcmatch\" ((A_PtrSize == 8 ) ? "TCMatch64" : "TCMatch") ".dll"
	; MatchFileW :=A_ScriptDir "\Lib\tcmatch\TCMatch\MatchFileW"
	; dllPath := A_ScriptDir "\Lib\tcmatch\TCMatch"
	g_TCMatchModule := TCMatchOn(dllPath)
    Return DllCall(MatchFileW, "WStr", aNeedle, "WStr", aHaystack)
}

GF_GetSysVar(sys_var_name)
{
	EnvGet, sv,% sys_var_name
	return % sv
}
switchime(ime := "A")
{
	if (ime = 1)
		DllCall("SendMessage", UInt, WinActive("A"), UInt, 80, UInt, 1, UInt, DllCall("LoadKeyboardLayout", Str,"00000804", UInt, 1))
	else if (ime = 0)
		DllCall("SendMessage", UInt, WinActive("A"), UInt, 80, UInt, 1, UInt, DllCall("LoadKeyboardLayout", Str,, UInt, 1))
	else if (ime = "A")
		Send, #{Space}
}

