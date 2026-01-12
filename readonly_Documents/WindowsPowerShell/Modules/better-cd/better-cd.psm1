function Set-LocationEx {
    [CmdletBinding(DefaultParameterSetName='Path')]
    param(
        [Parameter(ParameterSetName='Path', Position=0, ValueFromPipeline=$true, ValueFromRemainingArguments=$true)]
        [string]$Path,

        [Parameter(ParameterSetName='LiteralPath', ValueFromPipelineByPropertyName=$true)]
        [Alias('PSPath')]
        [string]$LiteralPath,

        [Parameter(ParameterSetName='Stack')]
        [switch]$Stack,


        [Parameter(ParameterSetName='Help')]
        [Alias('?')]
        [switch]$Help,

        [switch]$PassThru,

        [switch]$UseTransaction
    )
    
    # 初始化目录栈（如果不存在）
    if (-not (Test-Path variable:global:DirectoryStack)) {
        $global:DirectoryStack = New-Object System.Collections.ArrayList
        $global:DirectoryStack.Add((Get-Location).Path) | Out-Null
    }

    # 处理帮助请求
    if ($Help) {
        Write-Host "Usage: Set-LocationEx [-Path] <location>"
        Write-Host "       Set-LocationEx -<n> (n is a number)"
        Write-Host "       Set-LocationEx - (go to previous directory)"
        Write-Host "       Set-LocationEx -- (show directory stack)"
        Write-Host "       All other parameters are forwarded to Set-Location"
        return
    }

    # 处理 "--" 显示目录栈
    if ($Stack -or $Path -eq "--") {
        Write-Host "Directory stack:"
        for ($i = 0; $i -lt $global:DirectoryStack.Count; $i++) {
            Write-Host " $i`t$($global:DirectoryStack[$i])"
        }
        return
    }

    # 处理 "-" 返回上一个目录
    if ($Path -eq "-") {
        if ($global:DirectoryStack.Count -gt 1) {
            $current = $global:DirectoryStack[0]
            $prev = $global:DirectoryStack[1]
            
            # 更新目录栈
            $global:DirectoryStack.RemoveAt(1)
            $global:DirectoryStack.Insert(0, $prev)
            
            Set-Location -LiteralPath $prev 
            Write-Host "Switched to: $prev"
        } else {
            Write-Warning "No previous directory in stack"
        }
        return
    }

    # 处理 "-n" 跳转到目录栈中的第n个目录
    if ($Path -match "^-(\d+)$") {
        $index = [int]$Matches[1]
        if ($index -ge 0 -and $index -lt $global:DirectoryStack.Count) {
            $target = $global:DirectoryStack[$index]
            
            # 更新目录栈：将目标目录移到栈顶
            $global:DirectoryStack.RemoveAt($index)
            $global:DirectoryStack.Insert(0, $target)
            
            Set-Location -LiteralPath $target 
            Write-Host "Switched to: $target"
        } else {
            Write-Warning "Invalid stack index: $index (max $($global:DirectoryStack.Count-1))"
        }
        return
    }

    # 默认情况：转发给 Set-Location
    try {
        # 确定要使用的参数集
        $params = @{}
        if ($PSCmdlet.ParameterSetName -eq 'LiteralPath') {
            $params['LiteralPath'] = $LiteralPath
        } elseif ($Path) {
            $params['Path'] = $Path
        }

        # 添加其他参数
        foreach ($key in $PSBoundParameters.Keys) {
            if ($key -notin 'Path', 'LiteralPath', 'Stack', 'Help', 'PassThru') {
                $params[$key] = $PSBoundParameters[$key]
            }
        }

        # 执行目录切换
        # echo $PassThru
        $newLocation = Set-Location @params -PassThru

        if ($newLocation) {
            $resolvedPath = $newLocation.Path
            
            # 检查是否已经在栈中
            $existingIndex = $global:DirectoryStack.IndexOf($resolvedPath)
            if ($existingIndex -ne -1) {
                $global:DirectoryStack.RemoveAt($existingIndex)
            }
            
            # 添加到栈顶
            $global:DirectoryStack.Insert(0, $resolvedPath)
            
            # 限制栈大小（保持16个条目）
            while ($global:DirectoryStack.Count -gt 16) {
                $global:DirectoryStack.RemoveAt(16)
            }
        }
        if ($PassThru) {
            return $newLocation
        }
    }
    catch {
        Write-Error "Failed to change directory: $_"
    }
}
