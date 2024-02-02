Class CListBox
{
	/*
		新增（追加）listbox项
		HWND：ListBox控件句柄
		Text：要追加字符
		成功返回总行数否则返回false
	*/
	Add(HWND,Text){
		Static LB_ADDSTRING := 0x0180
		VarSetCapacity(String,StrPut(Text,"utf-16")*4),StrPut(Text, &String, "utf-16")
		Index:=DllCall("User32\SendMessage", "Ptr", HWND, "UInt", LB_ADDSTRING, "Ptr", 0, "Ptr", &String)+1
		Count:=this.GetCount(HWND),this.SetCurSel(HWND, Count)
		Return Count=Index?Count:False
	}
	/*
		指定位置插入listbox项
		HWND：ListBox控件句柄
		Pos：指定插入的行号，Pos=0时追加插入
		Text：要追加字符
		成功返回行号否则返回false
	*/
	Insert(HWND,Text,Pos:=1){
		Static LB_INSERTSTRING := 0x0181
		VarSetCapacity(String,StrPut(Text,"utf-16")*4),StrPut(Text, &String, "utf-16")
		Index:=DllCall("User32\SendMessage", "Ptr", HWND, "UInt", LB_INSERTSTRING, "UInt", Pos-1, "Ptr", &String)+1
		if (Index>=Pos)
			this.SetCurSel(HWND, Index)
		Return Index>=Pos?Index:False
	}
	/*
		获取listbox总行数
		成功返回总行数
	*/
	GetCount(HWND){
		Static LB_GETCOUNT := 0x018B
		Return DllCall("User32.dll\SendMessage", "Ptr", HWND, "UInt", LB_GETCOUNT, "Ptr", 0, "Ptr", 0, "Ptr") 
	}
	/*
		删除listbox指定行
		HWND：ListBox控件句柄
		Pos：指定删除的行号
		成功返回True否则返回false
	*/
	Delete(HWND,Pos){
		Static LB_DELETESTRING := 0x0182
		i:=this.GetCount(HWND)
		Index:=DllCall("User32\SendMessage", "Ptr", HWND, "UInt", LB_DELETESTRING, "UInt", Pos-1, "Ptr", 0, "Ptr")
		Count:=this.GetCount(HWND)
		Return Index=Count&&Count<i?True:False
	}
	; 删除listbox所有项
	DeleteAll(HWND){
		Static LB_RESETCONTENT := 0x0184
		Return DllCall("User32\SendMessage", "Ptr", HWND, "UInt", LB_RESETCONTENT, "Ptr", 0, "Ptr", 0, "Ptr")
	}
	; 删除listbox指定条目，成功返回True否则返回false
	DeleteItem(HWND,Text){
		Pos:=this.GetItemPos(HWND, Text),Index:=this.Delete(HWND,Pos)
		Return Index?True:False
	}
	/*
		修改指定行的字符串，Pos=0时视为追加新字符串
		HWND：ListBox控件句柄
		Pos：要修改的指定行
		Text：要替换的新字符
		成功返回True否则返回false
	*/
	Modify(HWND,Pos,Text){
		Status:=this.Delete(HWND,Pos)
		Index:=this.Insert(HWND,Text,Pos)
		Return Index=Pos?True:False
	}
	/*
		获取listbox指定行的字符串
		HWND：ListBox控件句柄
		Pos：要修改的指定行
		成功返回字符串反之为空
	*/
	GetText(HWND,Pos){
		Static LB_GETTEXTLEN := 0x018A
		Static LB_GETTEXT := 0x0189
		len:=DllCall("User32\SendMessage", "Ptr", HWND, "UInt", LB_GETTEXTLEN, "UInt", Pos-1, "Ptr", 0, "Ptr")
		VarSetCapacity(Text, Len << !!A_IsUnicode, 0)
		DllCall("User32\SendMessage", "Ptr", HWND, "UInt", LB_GETTEXT, "UInt", Pos-1, "Ptr", &Text)
		Return StrGet(&Text, Len)
	}
	/*
		获取listbox全部字符串项
		HWND：ListBox控件句柄
		separator：指定分割符
		成功返回字符串反之为空
	*/
	GetAllItem(HWND,separator:="|"){
		ControlGet, GETALLTEXT, List , Count, , ahk_id%HWND%
		Return StrReplace(Trim(GETALLTEXT,"`r`n"),"`n",separator)
	}
	/*
		根据指定字符串项获取在listbox中的位置（在第几行）
		HWND：ListBox控件句柄
		Text：要匹配的字符
		成功返回位置（行号）
	*/
	GetItemPos(HWND, Text) {
		Static LB_FINDSTRINGEXACT := 0x01A2
		VarSetCapacity(String,StrPut(Text,"utf-16")*4),StrPut(Text, &String, "utf-16")
		Index:=DllCall("User32\SendMessage", "Ptr", HWND, "UInt", LB_FINDSTRINGEXACT, "UInt", -1, "Ptr", &String)+1
		Count:=this.GetCount(HWND)
		Return Count&&Index?Index:False
	}
	;返回选中的高亮项行号（单选）
	GetCurrentSel(HWND) {
		Static LB_GETCURSEL := 0x0188
		Return DllCall("User32\SendMessage", "Ptr", HWND, "UInt", LB_GETCURSEL, "UInt", 0, "Ptr")+1
	}
	;选中listbox列表中的指定条目，返回行号
	SelectString(HWND, Text) {
		;;Static LB_SELECTSTRING := 0x018C
		;;VarSetCapacity(String,StrPut(Text,"utf-16")*4),StrPut(Text, &String, "utf-16")
		;;Return DllCall("User32\SendMessage", "Ptr", HWND, "UInt", LB_SELECTSTRING, "UInt", -1, "Ptr", &String)+1
		if Index:=this.GetItemPos(HWND, Text){
			Return this.SetCurSel(HWND, Index)
		}Else
			Return False
	}
	SelectAllItem(HWND){
		Static LB_SETSEL := 0x0185
		PostMessage, 0x0185, 1, -1, , ahk_id%HWND%
		Return DllCall("User32\PostMessage", "Ptr", HWND, "UInt", LB_SETSEL, "UInt", 1, "UInt",-1)+1
	}
	;选中listbox列表中的指定行
	SetCurSel(HWND, Index){
		Static LB_SETCURSEL := 0x0186
		Return DllCall("User32\SendMessage", "Ptr", HWND, "UInt", LB_SETCURSEL, "UInt", Index-1, "Ptr", 0, "Ptr")+1
	}
	;设置listbox行高
	SetItemHeight(HWND, Height) {
		Static LB_SETITEMHEIGHT := 0x01A0
		
		Return DllCall("User32\SendMessage", "Ptr", HWND, "UInt", LB_SETITEMHEIGHT, "UInt", -1, "UInt", Height, "Ptr")+1
	}
	;获取listbox行高
	GetItemHeight(HWND) {
		Static LB_GETITEMHEIGHT := 0x01A1
		Return DllCall("User32\SendMessage", "Ptr", HWND, "UInt", LB_GETITEMHEIGHT, "UInt", 0, "UInt", 0, "Ptr")
	}
}