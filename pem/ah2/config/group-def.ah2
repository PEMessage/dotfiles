; 整个 WinSpy 中文字都归于 Wintitle中, 
; 而且 WinTitle 内部还会进行解析, 以如下方式匹配, "[标题] [ahk_exe] [value] [ahk_id] [value] ... " 等进行解析

GroupAdd "chrome_base", "ahk_class Chrome_WidgetWin_1"
GroupAdd "vscode", "ahk_exe Code.exe"
GroupAdd "edge", "ahk_exe msedge.exe"

GroupAdd "ai_full", "ahk_exe Magpie.exe"
GroupAdd "ai_full", "ahk_exe LunaTranslator_main.exe"


#include "../lib/PE.ah2"

is_notion(){
    if ( WinActive("ahk_exe Notion.exe") ) {
        return true
    }
    if (not WinActive("ahk_group chrome_base") ){
        return false
    } 
    url := PE().GetUrl("A") 
    ; Msgbox url
    if InStr(url, 'notion.so') {
        return true
    }
    return false
}

; Debug
; F1::MsgBox is_notion()

