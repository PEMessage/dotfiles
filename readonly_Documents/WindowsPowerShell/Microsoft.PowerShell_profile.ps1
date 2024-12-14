# Alias and Basic Setting
# # =========================================

    Remove-Item alias:curl
    Set-Alias -Name l -Value ls

# PSReadline
# # =========================================

    Set-PSReadLineOption -EditMode Emacs

if (((Get-Module) | Where-Object { $_.Name -eq "PSReadLine" } ).Version.CompareTo([Version]"2.1.0") -gt 0) {
    # Tips: sudo powershell -Command ' Install-Module -Force PSReadline '
    Set-PSReadLineOption -PredictionSource History # 设置预测文本来源为历史记录
    Set-PSReadLineKeyHandler -Key "Ctrl+d" -Function MenuComplete # 设置 Ctrl+d 为菜单补全和 Intellisense
}




function Update-CommandHelp {
    param (
        [string]$CmdletName
    )

    # Get the command object
    $command = Get-Command -Name $CmdletName

    if ($command) {
        # Check if the source is a module and update help accordingly
        if ($command.Source ) {
            Write-Output "Updating help for cmdlet: $CmdletName"
            Write-Output ( "Updating module: " + "Update-Help -Module " + $command.Source )
            Update-Help -Module $command.Module
        } else {
            Write-Warning "$CmdletName does not appear to be a module-based cmdlet."
        }
    } else {
        Write-Error "Cmdlet '$CmdletName' not found."
    }
}



# Example usage:
# Update-CmdletHelp -CmdletName "Install-Module"



