; test:="一键将TC选中的文件夹添加到系统的path环境变量（注意：本命令能够处理包含空格、^及&等特殊字符的文件夹，但不能处理包含!字符的文件夹）"

; hlog()

; all:=delSymbol(test)
; hdbug(all)


; F11::Reload


delSymbol(content){
content := StrReplace(content,"：")
content := StrReplace(content,"（")
content := StrReplace(content,"、")
content := StrReplace(content,"^")
content := StrReplace(content,"&")
content := StrReplace(content,"，")
content := StrReplace(content,"!")
content := StrReplace(content,"）")
content := StrReplace(content,"，")
content := StrReplace(content,"_")
content := StrReplace(content," ")
content := StrReplace(content,"。")
content := StrReplace(content,"，")
content := StrReplace(content,"…")
content := StrReplace(content,"！")
content := StrReplace(content,"#")
content := StrReplace(content,"￥")
content := StrReplace(content,"&")
content := StrReplace(content,"*")
content := StrReplace(content,"【")
content := StrReplace(content,"】")
content := StrReplace(content,"{")
content := StrReplace(content,"}")
content := StrReplace(content,"+")
content := StrReplace(content,"-")
content := StrReplace(content,"=")
content := StrReplace(content,"《")
content := StrReplace(content,"》")
content := StrReplace(content,"<")
content := StrReplace(content,">")
content := StrReplace(content,"/")
content := StrReplace(content,"\")
content := StrReplace(content,"|")
content := StrReplace(content,";")
content := StrReplace(content,"'")
content := StrReplace(content,"·")
content := StrReplace(content,"~")
	Return Content
}