
function Run-Cmd {
    Write-Host Runing: $args
        & $args[0] @($args[1..$args.Length])
}


function Set-GitConfigGlobal {
    param (
            [string]$Key,
            [string]$Value
          )

        $curValue = "$(git config --global --get-all $Key)"

        if ($curValue -eq $Value) {
            # Already set
            return 
        } elseif (-not $curValue) {
            # Do nothing (equivalent to 'true' in bash)
        } else {
            Run-Cmd git config --global --unset-all $Key
        }
    Run-Cmd git config --global $Key $Value
}


Set-GitConfigGlobal branch.sort -committerdate
Set-GitConfigGlobal column.ui auto
Set-GitConfigGlobal fetch.writeCommitGraph true
Set-GitConfigGlobal log.date iso-local

Set-GitConfigGlobal alias.pk cherry-pick
Set-GitConfigGlobal alias.co checkout
Set-GitConfigGlobal alias.fw 'merge --ff-only'
Set-GitConfigGlobal alias.re 'remote -v'
Set-GitConfigGlobal alias.top 'rev-parse --show-toplevel'
Set-GitConfigGlobal alias.st 'status --short --branch'
Set-GitConfigGlobal alias.lg 'log --oneline --graph'

