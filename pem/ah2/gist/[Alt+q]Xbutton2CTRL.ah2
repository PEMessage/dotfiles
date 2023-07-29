; full_command_line := DllCall("GetCommandLine", "str")

; if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
; {
;     try
;     {
;         if A_IsCompiled
;             Run '*RunAs "' A_ScriptFullPath '" /restart'
;         else
;             Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
;     }
;     ExitApp
; }

xb_enable := 1
!q::
{
    global xb_enable
    if xb_enable == 1
    {
        xb_enable := 0
        TrayTip "Xbut1 -> Ctrl Disabled", "", 0x10 ;  0x10 -> mute
    } else {
        xb_enable := 1
        TrayTip "Xbut1 -> Ctrl Enabled", "", 0x10
    }
    Sleep 1300
    TrayTip
    
}

#HotIf xb_enable == 1
XButton1::
{
    Send "{Ctrl down}"
    return
}
XButton1 up::
{
    Send "{Ctrl up}" 
    return  
}
#HotIf 
