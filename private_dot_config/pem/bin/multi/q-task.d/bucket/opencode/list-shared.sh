#!/usr/bin/env bash

SQL="
SELECT s.id, s.title, s.share_url, datetime(ss.time_created, 'unixepoch') AS share_time
FROM session s
JOIN session_share ss ON s.id = ss.session_id
ORDER BY ss.time_created DESC;
"

opencode db "$SQL" --format tsv | column -t -s $'\t'
