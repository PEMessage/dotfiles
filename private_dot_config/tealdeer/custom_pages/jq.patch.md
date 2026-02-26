- 💫 [PATHS, value] pair list

`{{cat data.json}} | jq -c 'paths as $p | [$p, getpath($p)]'`

- 💫 [PATHS, value] that match {expr}

`{{cat data.json}} | jq -c 'paths as $p | {{select($p | contains( ["presets"]) and contains(["model"]) )}} | [$p, getpath($p)] '`

- 💫 recovry [PATHS, value] to normal json

` jq -s 'reduce .[] as $item ({}; setpath($item[0]; $item[1]))'`
