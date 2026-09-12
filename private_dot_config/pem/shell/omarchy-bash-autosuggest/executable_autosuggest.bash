# omarchy-bash-autosuggest: load the module from ~/.local/lib when present.
# Silently does nothing when it is missing.
[[ $- == *i* ]] || return 0
[[ -n $BASH_VERSION ]] || return 0

for _oba_so in "$HOME"/.local/lib/omarchy_autosuggest*.so; do
    [[ -r $_oba_so ]] || continue
      enable -f "$_oba_so" omarchy_autosuggest 2>/dev/null
      omarchy_autosuggest enable 2>/dev/null
      omarchy_autosuggest limit 8192 2>/dev/null
      break
done
unset _oba_so
