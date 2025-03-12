function Run-Cmd {
    # Write-Host Runing: $args
    & $args[0] @($args[1..$args.Length])
}


# Define color codes for console output
$GREEN = [Console]::ForegroundColor = "Green"
$STOP = [Console]::ResetColor()

# Get the source path from chezmoi
$gitpath = chezmoi source-path
$GIT = ("git" , "-C", "$gitpath")

# Parse arguments
foreach ($arg in $args) {
    if ($arg -eq "-d") {
        # Set-Location $temp
        chezmoi re-add
        Run-cmd @GIT add .
        Run-cmd @GIT diff --staged
        exit 0
    }
}

# Re-add all tracked files with chezmoi
Write-Host "${GREEN}INFO${STOP}: chezmoi re-add all trackfile"
# Set-Location ~
chezmoi re-add

# Add files to the source repository
Write-Host "${GREEN}INFO${STOP}: Add File to source"
# Set-Location $temp
Run-cmd @GIT add .

# Prompt for commit message
if (-not $args) {
    $MEG = "Update time: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
} else {
    $MEG = $args -join " "
}

Write-Host
Write-Host "${GREEN}INFO${STOP}: Are you sure commit with this change?"
Write-Host
Run-cmd @GIT status --short --branch
Write-Host
Write-Host "${GREEN}Commit message${STOP}:"
Write-Host "    $MEG"
Write-Host

# Confirm commit
while ($true) {
    $input = Read-Host "Are you sure to commit? (y) to continue"
    if ($input -eq "y") {
        break
    }
}

Write-Host
Write-Host "${GREEN}INFO${STOP}: OK, now commit"
Write-Host
Run-cmd @GIT commit -m "$MEG"
Run-cmd @GIT log HEAD -n1 --stat --oneline

Write-Host
Write-Host "${GREEN}INFO${STOP}: Push to git"
Write-Host

# Confirm push
while ($true) {
    $input = Read-Host "Are you sure to push? (y) to continue"
    if ($input -eq "y") {
        break
    }
}

Write-Host
Write-Host "${GREEN}INFO${STOP}: OK, now push"
Write-Host
Run-cmd @GIT push

