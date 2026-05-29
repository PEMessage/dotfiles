- 💫 rename <path> and <commit-msg>

`git filter-repo --refs abc123..main --path-rename {{src/path}}:{{dest/path}} --message-callback 'return message.replace(b"{{orig_text}}", b"{{new_text}}")' `
