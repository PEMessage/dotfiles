#
# +++++++++++++++++++++++++++++++++++++++++++
# File: Microsoft.PowerShell_profile.ps1
# Author: PEMessage
# Description: This is my $PROFILE configuration
# Last Modified: 2022-11-29 Tue 12:02 AM 
# +++++++++++++++++++++++++++++++++++++++++++
#

# 1. Scoop Auto Install
# ===========================================

    # if( $( &{scoop info} 2>&1 ) -is [System.Management.Automation.ErrorRecord])
    # {
    #     # $PEScoopURL = "get.scoop.sh"
    #     $PEScoopURL = "https://ghproxy.com/https://raw.githubusercontent.com/scoopinstaller/install/master/install.ps1"
    #     # grab the version string from the error message
    #     Write-Output "Auto Install scoop"
    #
    #     Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
    #     Invoke-RestMethod $PEScoopURL | Invoke-Expression
    # }
    # else 
    # {
    #     # otherwise return as is
    # }


# Alias and Basic Setting
# =========================================

    Set-PSReadLineOption -EditMode Emacs

    # PSReadline 2.1 or higher
    Set-PSReadLineOption -PredictionSource History # 设置预测文本来源为历史记录
    Set-PSReadLineKeyHandler -Key "Ctrl+d" -Function MenuComplete # 设置 Ctrl+d 为菜单补全和 Intellisense


    Remove-Item alias:curl 
    Set-Alias -Name pnp -Value pnpm
    
    # Set-Alias -Name spf -Value '. $PROFILE'


# Third Part Feature
# =========================================
    Import-Module z # $($PROFILE | bcd)/Module/z

    Invoke-Expression (&scoop-search --hook)
    Invoke-Expression (&starship init powershell)

# Function Zone
# =========================================
    # Use fzf as cd
    function fcd($dir = ''){
        Set-Location $dir
        $TEMP = fzf
        $TEMP = dirname $TEMP
        Set-Location $TEMP
    }
    function wherecd($cmd = '') {
        $Loc = whereis $cmd
        if($Loc){
            Write-Output $("The Location is:"+$Loc ) 
            $Loc = Split-Path $Loc -Parent
            Write-Output $("Set Location to:"+$Loc ) 
            Set-Location $Loc
        } else {
            Write-Output "No Such CMD or Shell Internal"
        }
    
    }

    function bcd($cmd = '', [Parameter(ValueFromPipeline)]$input) {
        if($cmd -eq ''){
            # Write-Output $input 
            $path_arg = $input | Out-String -Stream 
            # Input 默认是对象，需要转换字符串
            # Out-String 默认添加回车需要转换
        } elseif($cmd -eq '--print') {
            $path_arg = $input | Out-String -Stream 
        } else {
            $path_arg = $cmd
        }

        if (Test-Path -Path $path_arg -PathType Leaf) {
            # Write-Output "$path_arg is a file"
            $path_arg = Split-Path -Parent $path_arg
        } 
        elseif (Test-Path -Path $path_arg -PathType Container) {
            # Write-Output "$path is a directory"
        }
        else {
            return 
        }

        if ($cmd -eq '--print') {
            Write-Output $path_arg
        } else {
            Set-Location $path_arg
        }
        return 
    }
    function zz(){
        z -l | fzf | bcd
    }
    


# Alias
# =========================================

