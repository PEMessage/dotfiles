- 💫 mount ftp <host> to <dir>

`rclone mount :ftp: {{dir}} --ftp-host={{host}} --ftp-user={{user}} --ftp-pass=$(rclone obscure {{passwd}}) --read-only`
