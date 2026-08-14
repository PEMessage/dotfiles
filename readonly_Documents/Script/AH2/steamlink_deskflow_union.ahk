#Requires AutoHotkey v2.0
Persistent

global DeskflowPath := ""

; 每秒检测一次
SetTimer(CheckSteamLink, 1000)

CheckSteamLink() {
    global DeskflowPath

    ; 检查 steam_monitor.exe 是否在运行
    if (ProcessExist("steam_monitor.exe")) {
        pid := ProcessExist("deskflow.exe")
        if (pid) {
            ; 获取当前 deskflow.exe 的完整路径并保存
            DeskflowPath := GetProcessPath(pid)
            ; 强制终止进程
            ProcessClose(pid)
        }
        pid := ProcessExist("deskflow-core.exe")
        if (pid) {
            ProcessClose(pid)
        }
        pid := ProcessExist("deskflow-daemon.exe")
        if (pid) {
            ProcessClose(pid)
        }
    } else {
        ; steam_monitor 已退出，检查 deskflow 是否已消失
        if (!ProcessExist("deskflow.exe")) {
            ; 优先用之前记录的完整路径恢复启动
            if (DeskflowPath && FileExist(DeskflowPath)) {
                Run(DeskflowPath, ,"Hide")
            } else {
                ; 兜底：从 PATH 环境变量启动
                Run("deskflow.exe", ,"Hide")
            }
        }
    }
}

; ==============================================
; 通过 PID 获取进程完整路径 (v2 版)
; ==============================================
GetProcessPath(PID) {
    ; 打开进程句柄 (权限: PROCESS_QUERY_INFORMATION | PROCESS_VM_READ)
    hProcess := DllCall("OpenProcess", "UInt", 0x0400 | 0x0010, "Int", 0, "UInt", PID, "Ptr")
    if (!hProcess)
        return ""

    ; v2 使用 Buffer 对象替代 VarSetCapacity
    buf := Buffer(260 * 2)   ; 宽字符缓冲区
    size := 260

    success := DllCall("QueryFullProcessImageName", "Ptr", hProcess, "UInt", 0, "Ptr", buf.Ptr, "UInt*", size, "UInt")
    DllCall("CloseHandle", "Ptr", hProcess)

    if (success)
        return StrGet(buf, size, "UTF-16")  ; v2 的字符串解码
    return ""
}
