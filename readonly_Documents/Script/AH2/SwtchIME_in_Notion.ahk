#Requires AutoHotkey v2.0


#SingleInstance Force
Persistent()

SetTitleMatchMode(2)  ; Match partial window titles
LastActiveWindow := ""

; Check focus every 100ms
SetTimer(CheckWindowFocus, 500)

CheckWindowFocus() {
    global LastActiveWindow

    try {
        currentTitle := WinGetTitle("A")
        currentExe := WinGetProcessName("A")

        if (LastActiveWindow != currentTitle) {
            ; Windows Terminal focused
            if (currentExe = "WindowsTerminal.exe" || InStr(currentTitle, "Windows Terminal")) {
                RunWait('im-select-imm.exe 1033',, "Hide")
            }
            ; Microsoft Edge focused
            else if (currentExe = "notion.exe" || InStr(currentTitle, "notion")) {
                RunWait('im-select-imm.exe -d 30 2052 1',, "Hide")
            }
            else if (currentExe = "msedge.exe") {
                RunWait('im-select-imm.exe -d 30 2052 1',, "Hide")
            }

            LastActiveWindow := currentTitle
        }
    }
}

; No exit hotkey - use Task Manager to end the script
