# Alias and Basic Setting
# # =========================================

    Remove-Item alias:curl
    Set-Alias -Name l -Value ls
    Function Invoke-ScoopRsync {
        & rsync.exe `
            -e "$HOME\scoop\apps\cwrsync\current\bin\ssh.exe -i $HOME\.ssh\id_rsa -o UserKnownHostsFile=$HOME\.ssh\known_hosts" `
            --progress -u `
            $args
    }
    Set-Alias -name rsync -Value Invoke-ScoopRsync

# PSReadline
# # =========================================

    Set-PSReadLineOption -EditMode Emacs

	if (((Get-Module) | Where-Object { $_.Name -eq "PSReadLine" } ).Version.CompareTo([Version]"2.1.0") -gt 0) {
		# Tips: sudo powershell -Command ' Install-Module -Force PSReadline '
		Set-PSReadLineOption -PredictionSource History # 设置预测文本来源为历史记录
        Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
		# Set-PSReadLineKeyHandler -Key "Ctrl+d" -Function MenuComplete # 设置 Ctrl+d 为菜单补全和 Intellisense
	}


 
# My Command
# # =========================================
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

# Env setup
# # =========================================
    $env:PATh += ";$HOME\Documents\Script\PS1;"
    # Get-ChildItem -path "$HOME\Documents\Script\PS1" -Filter *.ps1 |
    # Foreach-Object{
    #     $name = $_.Name
    #     $scptName = $_.Name -split ".ps1",0,"simplematch"
    #     $scptName = $scptName[0]
    #     new-alias $name $scptName
    # }

# Example usage:
# Update-CmdletHelp -CmdletName "Install-Module"

function Run-As {
    param (
        [Parameter(ValueFromRemainingArguments=$true)]
        [string]$Arguments
    )
	Start-Process powershell.exe -Verb RunAs -Args $Arguments
}
#Alias: My sudo
Set-Alias -Name msudo -Value Run-As

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
# Module List
Import-Module z



# Wsl port
function Add-WSLPortForwarding ($Port = '23333', $Protocol = 'TCP') {
	$WSLIP = wsl -- hostname -I
	$WSLIP = $WSLIP.Trim().split()[0]
	netsh interface portproxy add v4tov4 listenport=$Port connectaddress=$WSLIP connectport=$Port
	New-NetFirewallRule -DisplayName "Allow ${Protocol} Inbound Port ${Port}" -Direction Inbound -Action Allow -Protocol $Protocol -LocalPort $Port
}

# 移除 WSL 端口转发以及防火墙入站规则
function Remove-WSLPortForwarding ($Port = '23333', $Protocol = 'TCP') {
	netsh interface portproxy delete v4tov4 listenport=$Port
	Remove-NetFirewallRule -DisplayName "Allow ${Protocol} Inbound Port ${Port}"
}

if ( (Get-Command fzf -ErrorAction SilentlyCon ) -and ( Get-Command awk -ErrorAction SilentlyCont ) ) {
    # Credit: https://gist.github.com/nv-h/081684cee2505cd336e26c2660fc7541
    # Credit: https://github.com/kelleyma49/PSFzf
    function Invoke-FuzzyHistory($Query='') {
        # Pure powershell implent seen have bug? 
        # $seenCommands = New-Object System.Collections.Generic.HashSet[string]
        # $excludeCommands = @('ls', 'cd', 'clear', 'pwd')
        # $command = Get-Content (Get-PSReadlineOption).HistorySavePath |
        # ForEach-Object { $_.Trim() } |
        # ForEach-Object {
        #     if ($seenCommands.Add($_)) {
        #         $_
        #     }
        # } | fzf --tac "--query=${Query}" --color dark --no-sort
        $command = Get-Content (Get-PSReadlineOption).HistorySavePath |
            awk '!a[$0]++'  |
            fzf --tac "--query=${Query}" --color dark --no-sort

        if ($command) {
            return $command
        }
    }
    function Invoke-FzfPsReadlineHandlerHistory {
        $result = $null
        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadline]::GetBufferState([ref]$line, [ref]$cursor)

        $result = Invoke-FuzzyHistory -Query $line
        echo $result

        if (-not [string]::IsNullOrEmpty($result)) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, $result)
        }
    }
    Set-PSReadLineKeyHandler -Key Ctrl+r { Invoke-FzfPsReadlineHandlerHistory }
    Set-PSReadLineKeyHandler -Key Ctrl+q -Function ReverseSearchHistory
}

