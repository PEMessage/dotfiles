#Requires AutoHotkey v2.0

MagpieMsg := DllCall("RegisterWindowMessage", "Str", "MagpieScalingChanged", "UInt")
active := false

OnMessage(MagpieMsg, MagpieMessageHandler)

MagpieMessageHandler(wParam, lParam, msg, hwnd) {
    global active
    if (wParam = 1) { ; Scaling started
        active := true
    }
    else if (wParam = 0) { ; Scaling ended
        active := false
    }
}

#HotIf WinExist("ahk_exe Magpie.exe") && active  
MButton::Send "{Ctrl down}"
MButton up::Send "{Ctrl up}"