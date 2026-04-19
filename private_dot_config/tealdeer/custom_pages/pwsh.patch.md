- 💫 clean all empty dir
`Get-ChildItem -Recurse -Directory | Where-Object { $_.GetFileSystemInfos().Count -eq 0 } | Remove-Item`

- 💫 mv all zipfile to zip_dir
`Get-ChildItem -Recurse -File | Where-Object { $_.Name -like '*.zip' } | mv -Destination .\zip_dir\`

- 💫 support utf-8 output(pipe to other program)
`$OutputEncoding = [console]::OutputEncoding = [Text.Encoding]::UTF8`

- 💫 remove empty dir
`Get-ChildItem -Directory -Recurse | Where-Object { $_.GetFileSystemInfos().Count -eq 0 } | Remove-Item`

- 💫 `ip link` for windows
`Get-NetIPInterface`
