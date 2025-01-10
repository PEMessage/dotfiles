
# Envsetup
# ========================
#$DEBUG = $true

if ($env:PEM_ADB_CMD) {
    $ADB_CMD = "$env:PEM_ADB_CMD"
} else {
    $ADB_CMD = "adb"
}

# Helper
# ========================
function Run-Cmd {
    Write-Host Runing: $args
    if ($DEBUG -eq $true) {
        return
    }
    & $args[0] @($args[1..$args.Length])
}

function Run-Eval {
    Write-Host Runing: $args 
    if ($DEBUG -eq $true) {
        return
    }
    Invoke-Expression ($args -join ' ')
}
function Convert-UnixPath2Winwdos() {
    return ($args[0].Split("/") -join '\')
}

function Get-Dirname() {
    return (Split-Path -Path "$args[0]" -Parent)
}


# Main
# ========================
function Push-BuildToDevice {
    param (
        [string]$RsyncBase,
        [string]$LocalBase,
        [string[]]$Files
    )

    Write-Host "Rsync base is $RsyncBase"
    Write-Host "Local base is $LocalBase"
    Write-Host "Files to be push base is $Files"

    foreach ($file in $Files) {
        $wfile = "$(Convert-UnixPath2Winwdos $file)"
        $localdir = "$LocalBase\$(Get-Dirname $wfile)"
        
        Run-Eval "New-Item -Path '$localdir' -ItemType Directory -Force"
        Run-Eval "Invoke-ScoopRsync '$RsyncBase/$file' '$LocalBase/$file'"
        Run-Cmd $ADB_CMD push "$LocalBase\$wfile" "/$file"

    }

}

 Push-BuildToDevice @args

# Example call to the function
# $myString = "apple"
# $myList = @("banana", "apple", "orange")


