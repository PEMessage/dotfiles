#Requires AutoHotkey v2.0

#include "lib\PE.ah2"
#include "config\group-def.ah2"

RunAdmin() {
    full_command_line := DllCall("GetCommandLine", "str")

    if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
    {
        try
        {
            if A_IsCompiled
                Run '*RunAs "' A_ScriptFullPath '" /restart'
            else
                Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
        }
        ExitApp
    }
}


RunAdmin()

; Version: 2023.05.11.1
; https://gist.github.com/7cce378c9dfdaf733cb3ca6df345b140


#Hotif WinActive("ahk_exe YuanShen.exe")
    Xbutton1::{
        Send "f"
        Sleep 100
        Send "f"
        Sleep 100
        Send "f"
    }
#Hotif

#Hotif WinActive("ahk_exe Notion.exe")
    ; Emacs like
    ^w::Send "^+{Left}{BackSpace}"
    !f::Send "^{Right}"
    !b::Send "^{Left}"

    ; Vim like
    ^j::Send "{Down}"
    ^k::Send "{Up}"
    ^h::Send "^{Right}"
    ^l::Send "^{Left}"

    ; Join
    ^n::Send "{End}{Del}"

    ; Command 1 2 3 4
    :O:/p::{
        PE().HotStr("{Home}> 🖼️{Enter}",50)
    }
    :O:/c::{
        PE().HotStr("{Home}> 💻{Enter}``````",50)
    }
    :O:/n::{
        PE().HotStr("{Home}> 🗒️{Enter}",50)
    }
    :O:/t::{
        PE().HotStr("{Home}> 🤔{Enter}",50)
    }
    ; Sub Full angle to half angle
    :O:/v::{
        A_Clipboard := ""
        Send "^a^x"
        ClipWait 5
        clip_text := PE().SubSign(A_Clipboard)
        SendText clip_text
    }
#Hotif

#HotIf WinExist("ahk_group ai_full")
    XButton1::Send "{Ctrl down}"
    XButton1 up::Send "{Ctrl up}"
#HotIf



+F15::{
    path := A_ScriptDir . "\lib\nircmd.exe "
    args := "muteappvolume focused 2"
    ; MsgBox path
    Run( path . args )
}

; Debug Zone
; F12::{
;     global pe_m
;     x := pe_m.GetUrl("A")
;     MsgBox x
; }
