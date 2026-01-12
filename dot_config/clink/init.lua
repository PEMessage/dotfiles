-- use `clink installscripts ~\.config\clink` to install enable
--
-- thanks to: https://github.com/vladimir-kotikov/clink-completions/blob/b935876eec2e4a2ac5ff895d4ce2a18053fcb9a0/.init.lua#L5
local parent_path = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]]

-- 1. basic settings
settings.set("autosuggest.hint", false)

