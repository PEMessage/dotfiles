# Alias and Basic Setting
# # =========================================

    Remove-Item alias:curl
    Set-Alias -Name l -Value ls
    Function Invoke-ScoopRsync {
        & rsync.exe `
            -e "$HOME\scoop\apps\cwrsync\current\bin\ssh.exe -i $HOME\.ssh\id_rsa -o UserKnownHostsFile=$HOME\.ssh\known_hosts" `
            --checksum `
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
	}


# # =========================================
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
# WSL Relate
# # =========================================
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
                awk '!a[$0]++'   |
                # awk '!a[$0]++'  |
                fzf --scheme=history --tac "--query=${Query}" --color dark --height 10%

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


function Invoke-SerialTerminal {
    param (
        [string]$Port = ([System.IO.Ports.SerialPort]::GetPortNames() | Select-Object -First 1),
        [int]$BaudRate = 115200,
        [System.IO.Ports.Parity]$Parity = "None",
        [int]$DataBits = 8,
        [System.IO.Ports.StopBits]$StopBits = "One",
        [int]$ReadTimeout = 100,
        [switch]$EchoLocal,
        [switch]$NoInteractive
    )

    # Validate COM port exists
    $availablePorts = [System.IO.Ports.SerialPort]::GetPortNames()
    if ($Port -notin $availablePorts) {
        throw "COM port '$Port' is not available. Available ports: $($availablePorts -join ', ')"
    }

    try {
        $serialPort = New-Object System.IO.Ports.SerialPort $Port, $BaudRate, $Parity, $DataBits, $StopBits
        $serialPort.ReadTimeout = $ReadTimeout
        $serialPort.Open()
        
        if (-not $serialPort.IsOpen) {
            throw "Failed to open COM port $Port"
        }

        # Check if input is being piped
        $isPiped = $MyInvocation.ExpectingInput

        if ($isPiped) {
            # Binary mode - process piped input
            $input | ForEach-Object {
                $bytes = if ($_ -is [byte[]]) { $_ } else { [System.Text.Encoding]::ASCII.GetBytes($_) }
                $serialPort.Write($bytes, 0, $bytes.Length)
            }
        }
        elseif (-not $NoInteractive) {
            # Interactive terminal mode
            Write-Host "Serial Terminal - $Port @ $BaudRate baud (Press ESC to exit)"
            Write-Host "----------------------------------------"

            # Configure console for immediate key reading
            Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class ConsoleHelper {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr GetStdHandle(int nStdHandle);
    
    [DllImport("kernel32.dll")]
    public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);
    
    [DllImport("kernel32.dll")]
    public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);
    
    public const int STD_INPUT_HANDLE = -10;
    public const uint ENABLE_ECHO_INPUT = 0x0004;
    public const uint ENABLE_LINE_INPUT = 0x0002;
}
"@

            $handle = [ConsoleHelper]::GetStdHandle([ConsoleHelper]::STD_INPUT_HANDLE)
            $mode = 0
            [ConsoleHelper]::GetConsoleMode($handle, [ref]$mode) | Out-Null
            $newMode = $mode -band (-bnot [ConsoleHelper]::ENABLE_LINE_INPUT) -band (-bnot [ConsoleHelper]::ENABLE_ECHO_INPUT)
            [ConsoleHelper]::SetConsoleMode($handle, $newMode) | Out-Null

            try {
                while ($serialPort.IsOpen) {
                    # Read from serial port
                    try {
                        $incomingData = $serialPort.ReadExisting()
                        if ($incomingData.Length -gt 0) {
                            Write-Host -NoNewline $incomingData
                        }
                    }
                    catch [System.TimeoutException] {
                        # Expected timeout - continue
                    }
                    catch {
                        Write-Warning "Read error: $_"
                        break
                    }

                    # Check for keyboard input
                    if ([Console]::KeyAvailable) {
                        $key = [Console]::ReadKey($true)
                        
                        # Exit on ESC key
                        if ($key.Key -eq [ConsoleKey]::Escape) {
                            break
                        }
                        
                        # Handle Enter key
                        if ($key.Key -eq [ConsoleKey]::Enter) {
                            $serialPort.Write("`r`n")
                            if ($EchoLocal) {
                                Write-Host "`r`n" -NoNewline
                            }
                        }
                        # Handle backspace
                        elseif ($key.Key -eq [ConsoleKey]::Backspace) {
                            $serialPort.Write([char]8)
                            if ($EchoLocal) {
                                Write-Host "`b `b" -NoNewline
                            }
                        }
                        # Normal characters
                        else {
                            $serialPort.Write($key.KeyChar)
                            if ($EchoLocal) {
                                Write-Host $key.KeyChar -NoNewline
                            }
                        }
                    }

                    Start-Sleep -Milliseconds 1
                }
            }
            finally {
                # Restore console mode
                [ConsoleHelper]::SetConsoleMode($handle, $mode) | Out-Null
            }
        }
        else {
            # Non-interactive mode without pipe
            try {
                while ($serialPort.IsOpen) {
                    try {
                        $incomingData = $serialPort.ReadExisting()
                        if ($incomingData.Length -gt 0) {
                            Write-Host -NoNewline $incomingData
                        }
                    }
                    catch [System.TimeoutException] {
                        # Expected timeout - continue
                    }
                    catch {
                        Write-Warning "Read error: $_"
                        break
                    }
                    Start-Sleep -Milliseconds 1
                }
            }
            catch {
                Write-Error "Error: $_"
            }
        }
    }
    catch {
        Write-Error "Serial port error: $_"
    }
    finally {
        if ($serialPort -and $serialPort.IsOpen) {
            $serialPort.Close()
            $serialPort.Dispose()
        }
        if (-not $NoInteractive) {
            Write-Host "`nExiting..."
        }
    }
}
