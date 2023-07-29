#Requires AutoHotkey v2.0
#NoTrayIcon

CmdRet(sCmd, callBackFunc := '', encoding := '') {
    static flags := [HANDLE_FLAG_INHERIT := 0x1, CREATE_NO_WINDOW := 0x8000000], STARTF_USESTDHANDLES := 0x100

    (encoding = '' && encoding := 'cp' . DllCall('GetOEMCP', 'UInt'))
    DllCall('CreatePipe', 'PtrP', &hPipeRead := 0, 'PtrP', &hPipeWrite := 0, 'Ptr', 0, 'UInt', 0)
    DllCall('SetHandleInformation', 'Ptr', hPipeWrite, 'UInt', flags[1], 'UInt', flags[1])

    STARTUPINFO := Buffer(size := A_PtrSize*9 + 4*8, 0)
    NumPut('UInt', size, STARTUPINFO)
    NumPut('UInt', STARTF_USESTDHANDLES, STARTUPINFO, A_PtrSize*4 + 4*7)
    NumPut('Ptr', hPipeWrite, 'Ptr', hPipeWrite, STARTUPINFO, size - A_PtrSize*2)

    PROCESS_INFORMATION := Buffer(A_PtrSize*2 + 4*2, 0)
    if !DllCall('CreateProcess', 'Ptr', 0, 'Str', sCmd, 'Ptr', 0, 'Ptr', 0, 'UInt', true, 'UInt', flags[2]
                               , 'Ptr', 0, 'Ptr', 0, 'Ptr', STARTUPINFO, 'Ptr', PROCESS_INFORMATION)
    {
        DllCall('CloseHandle', 'Ptr', hPipeRead)
        DllCall('CloseHandle', 'Ptr', hPipeWrite)
        throw OSError('CreateProcess is failed')
    }
    DllCall('CloseHandle', 'Ptr', hPipeWrite)
    temp := Buffer(4096, 0), output := ''
    while DllCall('ReadFile', 'Ptr', hPipeRead, 'Ptr', temp, 'UInt', 4096, 'UIntP', &size := 0, 'UInt', 0) {
        output .= stdOut := StrGet(temp, size, encoding)
        ( callBackFunc && callBackFunc(stdOut) )
    }
    DllCall('CloseHandle', 'Ptr', NumGet(PROCESS_INFORMATION, 'Ptr'))
    DllCall('CloseHandle', 'Ptr', NumGet(PROCESS_INFORMATION, A_PtrSize, 'Ptr'))
    DllCall('CloseHandle', 'Ptr', hPipeRead)
    return output
}





SetEnglish(){
    cur_imm_str := Trim(CmdRet("im-select-imm.exe"),"`r`n")
    cur_imm := StrSplit(cur_imm_str, ' ')
    if(cur_imm[1] == '1033'){
        return -1
    }
    if(cur_imm[1] == '2052'){
        if(not Mod(cur_imm[2],1024)){   ; Do not change(ret -1) cur_imm[1] == 0 
            return -1 
        } 
    } 
    CmdRet("im-select-imm.exe 1033")
    return cur_imm_str
}

SetOrigin(imm){
    if(imm == -1){
        return 0
    }
    cmd := "im-select-imm.exe " . imm
    CmdRet( cmd )
}

HotStr(str){
    imm := SetEnglish()
    Sleep 100
    Send str
    Sleep 100
    SetOrigin(imm)
}


#HotIf WinActive("ahk_exe chrome.exe") OR WinActive("ahk_exe edge.exe") 

:O:@q::{
    HotStr("1165739182@qq.com")
}

:O:@g::{
    HotStr("pemury233@gmail.com")
}

:O:@m::{
    HotStr("a39188569@outlook.com")
}
