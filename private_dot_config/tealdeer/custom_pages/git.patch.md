- 💫 refresh date
`git commit --amend --date="$(date --rfc-email -d -0hours)"`

- 💫 refresh date (batch mode)
`git rebase -i --exec 'git commit --amend --no-edit --date="$(date --rfc-email -d -0hours)"' {{commit}}`

