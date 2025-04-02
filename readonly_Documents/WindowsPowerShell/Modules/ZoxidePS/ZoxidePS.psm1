param(
    [string]$CdCommand = "Set-Location"
)



function script:__zoxide_bin {
    $encoding = [Console]::OutputEncoding
    try {
        [Console]::OutputEncoding = [System.Text.Utf8Encoding]::new()
        $result = zoxide @args
        return $result
    } finally {
        [Console]::OutputEncoding = $encoding
    }
}
# pwd based on zoxide's format.
function script:__zoxide_pwd {
    $cwd = Get-Location
    if ($cwd.Provider.Name -eq "FileSystem") {
        $cwd.ProviderPath
    }
}
# cd + custom logic based on the value of _ZO_ECHO.
function script:__zoxide_cd($dir, $literal) {
    $dir = if ($literal) {
        & $CdCommand -LiteralPath $dir -Passthru -ErrorAction Stop
    } else {
        if ($dir -eq '-' -and ($PSVersionTable.PSVersion -lt 6.1) -and ( $CdCommand -eq "Set-Location" )) {
            Write-Error "cd - is not supported below PowerShell 6.1. Please upgrade your version of PowerShell."
        }
        elseif ($dir -eq '+' -and ($PSVersionTable.PSVersion -lt 6.2) -and ( $CdCommand -eq "Set-Location" )) {
            Write-Error "cd + is not supported below PowerShell 6.2. Please upgrade your version of PowerShell."
        }
        else {
            & $CdCommand -Path $dir -Passthru -ErrorAction Stop
        }
    }
}
# =============================================================================
#
# Hook configuration for zoxide.
#
# Hook to add new entries to the database.
$script:__zoxide_oldpwd = __zoxide_pwd
function script:__zoxide_hook {
    $result = __zoxide_pwd
    if ($result -ne $global:__zoxide_oldpwd) {
        if ($null -ne $result) {
            zoxide add "--" $result
        }
        $global:__zoxide_oldpwd = $result
    }
}
# Initialize hook.
$script:__zoxide_hooked = (Get-Variable __zoxide_hooked -ErrorAction SilentlyContinue -ValueOnly)
if ($script:__zoxide_hooked -ne 1) {
    $script:__zoxide_hooked = 1
    $script:__zoxide_prompt_old = $function:prompt
    function global:prompt {
        if ($null -ne $__zoxide_prompt_old) {
            & $__zoxide_prompt_old
        }
        $null = __zoxide_hook
    }
}
# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#
# Jump to a directory using only keywords.
function script:__zoxide_z {
    if ($args.Length -eq 0) {
        __zoxide_cd ~ $true
    }
    elseif ($args.Length -eq 1 -and ($args[0] -eq '-' -or $args[0] -eq '+')) {
        __zoxide_cd $args[0] $false
    }
    elseif ($args.Length -eq 1 -and (Test-Path $args[0] -PathType Container)) {
        __zoxide_cd $args[0] $true
    }
    else {
        $result = __zoxide_pwd
        if ($null -ne $result) {
            $result = __zoxide_bin query --exclude $result "--" @args
        }
        else {
            $result = __zoxide_bin query "--" @args
        }
        if ($LASTEXITCODE -eq 0) {
            __zoxide_cd $result $true
        }
    }
}
# Jump to a directory using interactive search.
function script:__zoxide_zi {
    $result = __zoxide_bin query -i "--" @args
    if ($LASTEXITCODE -eq 0) {
        __zoxide_cd $result $true
    }
}


Set-Alias -Name z -Value __zoxide_z  -Scope Global
Set-Alias -Name zi -Value __zoxide_zi  -Scope Global
Export-ModuleMember -Function __zoxide_z, __zoxide_zi -Alias z, zi

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    # Set-Alias cd (Get-Alias cd).Definition -Scope Global  # 恢复原始别名
    Remove-Variable __zoxide_* -Scope Script -ErrorAction Ignore
}