CmdRet(sCmd, callBackFuncObj := "", encoding := "CP0")
{
   static HANDLE_FLAG_INHERIT := 0x00000001, flags := HANDLE_FLAG_INHERIT
       , STARTF_USESTDHANDLES := 0x100, CREATE_NO_WINDOW := 0x08000000
    hPipeRead := {Ptr : 0}
    hPipeWrite := {Ptr : 0}

   DllCall("CreatePipe", "PtrP", hPipeRead, "PtrP", hPipeWrite, "Ptr", 0, "UInt", 0)
   DllCall("SetHandleInformation", "Ptr", hPipeWrite, "UInt", flags, "UInt", HANDLE_FLAG_INHERIT)

   ;    VarSetCapacity(STARTUPINFO , siSize :=    A_PtrSize*4 + 4*8 + A_PtrSize*5, 0)
   siSize := A_PtrSize * 4 + 4 * 8 + A_PtrSize * 5
   STARTUPINFO := Buffer(siSize)
   NumPut("UPtr", siSize, STARTUPINFO)
   NumPut("UPtr", STARTF_USESTDHANDLES, STARTUPINFO, A_PtrSize * 4 + 4 * 7)
   NumPut("UPtr", hPipeWrite.Ptr, STARTUPINFO, A_PtrSize * 4 + 4 * 8 + A_PtrSize * 3)
   NumPut("UPtr", hPipeWrite.Ptr, STARTUPINFO, A_PtrSize * 4 + 4 * 8 + A_PtrSize * 4)
   
   PROCESS_INFORMATION := Buffer(A_PtrSize*2 + 4*2, 0) 


 
   try {
      DllCall("CreateProcess", "Ptr", 0, "Str", sCmd, "Ptr", 0, "Ptr", 0, "UInt", true, "UInt", CREATE_NO_WINDOW
                              , "Ptr", 0, "Ptr", 0, "Ptr", STARTUPINFO, "Ptr", PROCESS_INFORMATION )
   } catch OSError as err {
      DllCall("CloseHandle", "Ptr", hPipeRead)
      DllCall("CloseHandle", "Ptr", hPipeWrite)
      throw err
   }
   DllCall("CloseHandle", "Ptr", hPipeWrite)
;    VarSetCapacity(sTemp, 4096)
   sTemp := Buffer(4096)
   nSize := 0
   while( DllCall("ReadFile", "Ptr", hPipeRead, "Ptr", sTemp, "UInt", 4096, "UIntP", &nSize, "UInt", 0) ){
      

      sOutput .= stdOut := StrGet(sTemp, nSize, encoding)

      ( callBackFuncObj && callBackFuncObj.Call(stdOut) )
   }
   DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION,0,"UPtr"))
   DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION, A_PtrSize,"UPtr"))
   DllCall("CloseHandle", "Ptr", hPipeRead)
   ; if(sOutput) {
      Return sOutput
   ; } else {
   ;    throw Error("Fail GetValue")
   ; }
}

F1::{
   MsgBox(CmdRet("cmd /c help"))
}

