function Get-RecentItem {
    param(
        [int]$n = 1,

        [Alias('File')]
        [switch]$f,  # Files only

        [Alias('Directory')]
        [switch]$d    # Directories only
    )

    $items = Get-ChildItem | Where-Object {
        if ($f) { -not $_.PSIsContainer }
        elseif ($d) { $_.PSIsContainer }
        else { $true }
    } | Sort-Object LastWriteTime -Descending

    if ($items.Count -eq 0) {
        Write-Error "No items found matching the specified filter."
        return
    }
    if ($n -lt 1 -or $n -gt $items.Count) {
        Write-Error "Invalid input. Please enter a number between 1 and $($items.Count)"
        return
    }

    $items[$n - 1]
}
Set-Alias -Name ttt -Value Get-RecentItem
Export-ModuleMember -Alias ttt -Function Get-RecentItem


function Edit-File {
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string]$Path,

        [Parameter(ValueFromPipeline)]
        [object]$InputObject
    )

    begin {
        # 1. First try $env:EDITOR if set
        $editor = if ($env:EDITOR) { 
            $env:EDITOR 
        } else {
            "code"
        }
    }


    process {
        # echo $editor
        # Handle pipeline input
        if ($null -ne $InputObject) {
            # If input is a Path object (like from Get-ChildItem)
            if ($InputObject.PSObject.Properties['Path'] -or $InputObject.PSObject.Properties['FullName']) {
                $Path = if ($InputObject.Path) { $InputObject.Path } else { $InputObject.FullName }
            }
            # If input is a string path
            elseif ($InputObject -is [string] -and (Test-Path $InputObject)) {
                $Path = $InputObject
            }
            # Otherwise treat as stdin content
            else {
                $InputObject | & $editor "-"
                return
            }
        }

        # Handle direct path parameter
        if ($Path -and (Test-Path $Path)) {
            & $editor $Path
        }
        # No path provided and no pipeline input - open empty editor
        elseif (-not $Path -and -not $InputObject) {
            & $editor
        }
        else {
            Write-Error "Invalid path or input: $Path"
        }
    }
}
Set-Alias -Name edit -Value Edit-File
Export-ModuleMember -Alias edit -Function Edit-File