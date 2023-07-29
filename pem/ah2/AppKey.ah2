#Requires AutoHotkey v2.0

#include "lib\PE.ah2"
#include "config\group-def.ah2"



; Version: 2023.05.11.1
; https://gist.github.com/7cce378c9dfdaf733cb3ca6df345b140




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
        PE().HotStr("> 🖼️{Enter}",50)
    }
    :O:/c::{
        PE().HotStr("> 💻{Enter}``````",50)
    }
    :O:/n::{
        PE().HotStr("> 🗒️{Enter}",50)
    }
    :O:/t::{
        PE().HotStr("> 🤔{Enter}",50)
    }

#Hotif




; Debug Zone
; F12::{
;     global pe_m
;     x := pe_m.GetUrl("A")
;     MsgBox x
; }
