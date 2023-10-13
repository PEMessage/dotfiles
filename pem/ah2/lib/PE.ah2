#Requires AutoHotkey v2.0

#include "UIAutomation.ah2"
; -------- PE Class Start -------------
class PE {   ; Pure Function Class(Just like a namespace)
; -------- PE Class Start -------------


; Closeure Zone
    Init_toggle(init_value := 0){
        x := {}
        Read(){ 
            return this.value 
        }
        Write(value){
            this.value := value
        }
        Toggle(){
            if (this.value == 0) {
                this.value := 1
            } else {
                this.value := 0
            }
        }
        x.value := init_value
        x.Read := Read
        x.Write := Write
        x.Toggle := Toggle
        return x
    }

; CmdRet
; From https://www.autohotkey.com/boards/viewtopic.php?t=118203&p=524607
    CmdRet(sCmd, callBackFunc := '', encoding := '') {
        static flags := [HANDLE_FLAG_INHERIT := 0x1, CREATE_NO_WINDOW := 0x8000000], STARTF_USESTDHANDLES := 0x100

        (encoding = '' && encoding := 'cp' . DllCall('GetOEMCP', 'UInt'))
        DllCall('CreatePipe', 'PtrP', &hPipeRead := 0, 'PtrP', &hPipeWrite := 0, 'Ptr', 0, 'UInt', 0)
        DllCall('SetHandleInformation', 'Ptr', hPipeWrite, 'UInt', flags[1], 'UInt', flags[1])

        STARTUPINFO := Buffer(size := A_PtrSize * 9 + 4 * 8, 0)
        NumPut('UInt', size, STARTUPINFO)
        NumPut('UInt', STARTF_USESTDHANDLES, STARTUPINFO, A_PtrSize * 4 + 4 * 7)
        NumPut('Ptr', hPipeWrite, 'Ptr', hPipeWrite, STARTUPINFO, size - A_PtrSize * 2)

        PROCESS_INFORMATION := Buffer(A_PtrSize * 2 + 4 * 2, 0)
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
            (callBackFunc && callBackFunc(stdOut))
        }
        DllCall('CloseHandle', 'Ptr', NumGet(PROCESS_INFORMATION, 'Ptr'))
        DllCall('CloseHandle', 'Ptr', NumGet(PROCESS_INFORMATION, A_PtrSize, 'Ptr'))
        DllCall('CloseHandle', 'Ptr', hPipeRead)
        return output
    }

; Im-select-Imm
; Only depend on this.CmdRet
    SetEnglish(){
        cur_imm_str := Trim(this.CmdRet("im-select-imm.exe"),"`r`n")
        cur_imm := StrSplit(cur_imm_str, '-')
        if(cur_imm[1] == '1033'){
            return -1
        }
        ; if(cur_imm[1] == '2052'){
        ;     if(not Mod(cur_imm[2],1024)){   ; Do not change(ret -1) cur_imm[1] == 0 
        ;         return -1 
        ;     } 
        ; } 
        this.CmdRet("im-select-imm.exe 2052-0")
        return cur_imm_str
    }

    SetOrigin(imm){
        if(imm == -1){
            return 0
        }
        cmd := "im-select-imm.exe " . imm
        this.CmdRet( cmd )
    }
    
    HotStr(str, delay := A_KeyDelay) {
        imm := this.SetEnglish()

        store_delay := A_KeyDelay
        SetKeyDelay delay

        Sleep 200
        Send str

        SetKeyDelay store_delay
        this.SetOrigin(imm)
    }


; GetUrl Depend on UIAutomation.ah2
; Version: 2023.05.11.1
; https://gist.github.com/7cce378c9dfdaf733cb3ca6df345b140
    GetUrl(WinTitle*) {
        active := WinExist("A")
        Target := WinExist(WinTitle*)
        wClass := WinGetClass()
        root := UIA.ElementFromHandle(Target)
        static eCondition := UIA.PropertyCondition({ ControlType: "Edit" })
        ; Gecko family
        if (wClass ~= "Mozilla") {
            edit := root.FindFirst(eCondition)
            return edit.GetCurrentPropertyValue(UIA.Property.ValueValue)
        }
        ; Chromium-based, active
        if (active = Target) {
            static dCondition := UIA.PropertyCondition({ ControlType: "Document" })
            edit := root.FindFirst(dCondition)
            return edit.GetCurrentPropertyValue(UIA.Property.ValueValue)
        }
        ; Chromium-based, inactive
        static tCondition := UIA.PropertyCondition({ ControlType: "ToolBar" })
        toolBar := root.FindFirst(tCondition)
        edit := toolBar.FindFirst(eCondition)
        url := edit.GetCurrentPropertyValue(UIA.Property.ValueValue)
        wTitle := WinGetTitle()
        ; Google Chrome
        if (InStr(wTitle, "- Google Chrome") && url && !(url ~= "^\w+:")) {
            static mCondition := UIA.PropertyCondition({ ControlType: "MenuItem" })
            menuItem := toolBar.FindFirst(mCondition)
            rect := menuItem.CurrentBoundingRectangle
            w := rect.right - rect.left, h := rect.bottom - rect.top
            url := "http" (w > h * 2 ? "" : "s") "://" url
        }
        ; Microsoft Edge
        static edge := "- Microsoft" Chr(0x200b) " Edge" ; Zero-width space
        if (InStr(wTitle, edge) && url && !(url ~= "^\w+:"))
            url := "http://" url
        return url
    }




; -------- PE Class End -------------
}
; -------- PE Class End -------------

