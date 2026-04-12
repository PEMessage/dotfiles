- 💫 Forward <remote> -> <local> port
`ssh -R {{7890}}:{{localhost}}:{{7890}} {{username}}@{{remote_host}}`

- 💫 remote::1234 -> local -> TARGET::5678
`ssh -R {{1234}}:{{TARGET}}:{{5678}} {{username}}@{{remote_host}}`

- 💫 local::1234 -> remote -> TARGET::5678
`ssh -L {{1234}}:{{TARGET}}:{{5678}} {{username}}@{{remote_host}}`

- 💫 fix ssh cjk not display for windows
`cmd /c "chcp 65001 > nul && cls && ssh {{user}}@{{host}}"`
