#Requires AutoHotkey v2.0

#HotIf WinExist("ahk_exe Magpie.exe")
MButton::{
    Send "{Ctrl down}"
}

MButton up::{
    Send "{Ctrl up}"
}
