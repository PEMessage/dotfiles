# Alias and Basic Setting
# # =========================================

    Remove-Item alias:curl
    Set-Alias -Name l -Value ls
    Set-Alias -Name nvi -Value nvim
    Function Invoke-ScoopRsync {
        & rsync.exe `
            -e "$HOME\scoop\apps\cwrsync\current\bin\ssh.exe -i $HOME\.ssh\id_rsa -o UserKnownHostsFile=$HOME\.ssh\known_hosts" `
            --ignore-times `
            --progress  $args
        return $?
    }
    # Set-Alias -name rsync -Value Invoke-ScoopRsync

# PSReadline
# # =========================================

    Set-PSReadLineOption -EditMode Emacs

	if (((Get-Module) | Where-Object { $_.Name -eq "PSReadLine" } ).Version.CompareTo([Version]"2.1.0") -gt 0) {
		# Tips: sudo powershell -Command ' Install-Module -Force PSReadline '
		Set-PSReadLineOption -PredictionSource History # 设置预测文本来源为历史记录
        Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
		# Set-PSReadLineKeyHandler -Key "Ctrl+d" -Function MenuComplete # 设置 Ctrl+d 为菜单补全和 Intellisense

        # fix color issue in wezterm
        # Set-PSReadLineOption -Colors @{ InlinePrediction = 'DarkGreen' }
        # DarkGray and also with Italics,
        #   3: This is the standard ANSI code for Italic
        #   90: This is the code for Bright Black
        Set-PSReadLineOption -Colors @{
            InlinePrediction = "$([char]0x1b)[3;90m"
        }
	}


# # =========================================
# Env setup
# # =========================================
    $env:PATh += ";$HOME\Documents\Script\PS1"
    $env:PATh += ";$HOME\.config\pem\bin;"
    # Get-ChildItem -path "$HOME\Documents\Script\PS1" -Filter *.ps1 |
    # Foreach-Object{
    #     $name = $_.Name
    #     $scptName = $_.Name -split ".ps1",0,"simplematch"
    #     $scptName = $scptName[0]
    #     new-alias $name $scptName
    # }


Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# # =========================================
# Module Import
# # =========================================
    Import-Module better-cd 
    if (Get-Command zoxide.exe -ErrorAction SilentlyCon ) {
        Import-Module ZoxidePS -ArgumentList "Set-LocationEx"  
        Set-Alias -Name cdd -Value z
    } else {
        # Import-Module z
    }
    Set-Alias -Name cd -Value Set-LocationEx -Option AllScope
    # Import-Module PwshComplete
    Import-Module misc

# # =========================================
# fzf
# # =========================================

    $has_fzf = $(Get-Command fzf -ErrorAction SilentlyCon )
    if ((Get-Command posh-fzf -ErrorAction SilentlyCon) -and ($has_fzf)) {
        Invoke-Expression (&posh-fzf init | Out-String)
        Set-PSReadLineKeyHandler -Key 'Ctrl+r' -ScriptBlock {
            $historyPath = (Get-PSReadLineOption).HistorySavePath
            $historyCommand = Invoke-PoshFzfStartProcess -FileName "posh-fzf" -Arguments @("history", $historyPath)
            if ($historyCommand) {
                [Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
                    Invoke-PoshFzfInsertUtf8 $historyCommand
            }
        }
    } elseif ($has_fzf) {
        Import-Module PSFzfHistory
        Set-FzfHistoryKeybind -Chord Ctrl+r
    } else {
        # nothing
    }


# # =========================================
# WSL Relate
# # =========================================
    # Wsl port
    function Add-WSLPortForwarding ($Port = '23333', $Protocol = 'TCP') {
        $WSLIP = wsl -- hostname -I
        $WSLIP = $WSLIP.Trim().split()[0]
        netsh interface portproxy add v4tov4 listenport=$Port connectaddress=$WSLIP connectport=$Port
        New-NetFirewallRule -DisplayName "Allow ${Protocol} Inbound Port ${Port}" -Direction Inbound -Action Allow -Protocol $Protocol -LocalPort $Port
    }

    # 移除 WSL 端口转发以及防火墙入站规则 #
    function Remove-WSLPortForwarding ($Port = '23333', $Protocol = 'TCP') {
        netsh interface portproxy delete v4tov4 listenport=$Port
        Remove-NetFirewallRule -DisplayName "Allow ${Protocol} Inbound Port ${Port}"
    }


# # =========================================
# Helper function
# # =========================================
function Add-ToPath {
    param(
            [string]$Directory = ""
         )

        if ($Directory -ne "") {
            $fullPath = (Get-Item $Directory).FullName
                Write-Host "Running:"
                Write-Host "`$env:PATH = `"$fullPath;`$env:PATH`""
                $env:PATH = "$fullPath;$env:PATH"
        }
        else {
            $currentDir = (Get-Location).Path
                Write-Host "Running:"
                Write-Host "`$env:PATH = `"$currentDir;`$env:PATH`""
                $env:PATH = "$currentDir;$env:PATH"
        }

    Write-Host "`nCurrent Path:"
        ($env:PATH -split ';' | Where-Object { $_ -ne '' } | Select-Object -First 5) -join "`n"
        Write-Host "..."
}
Set-Alias a2p Add-ToPath


# Example usage:
# Update-CmdletHelp -CmdletName "Install-Module"
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


function Run-As {
    param (
        [Parameter(ValueFromRemainingArguments=$true)]
        [string]$Arguments
    )
	Start-Process powershell.exe -Verb RunAs -Args $Arguments
}
#Alias: My sudo
Set-Alias -Name msudo -Value Run-As
