if !FileExist("..\Plugins\WDX\Autorun\autorun.cfg"){
MsgBox,你解压错地方了
ExitApp
}
open=
(
ShellExec "`%COMMANDER_PATH`%\TMD\TMD.exe"
)
FileRead,auto,..\Plugins\WDX\Autorun\autorun.cfg
if (InStr(auto,open)){
  MsgBox,自启打开`,想关掉手动关掉去哈哈哈
}
else{
  open:="`n" . open
  FileAppend,%open%,..\Plugins\WDX\Autorun\autorun.cfg
  MsgBox,自启成功
}
ExitApp