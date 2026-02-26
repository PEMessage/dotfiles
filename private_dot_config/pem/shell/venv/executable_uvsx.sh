
# Expand from this oneline version
# Thanks to: https://github.com/astral-sh/uv/issues/6637#issuecomment-2584434822
# uv venv main.venv && uv export --script main.py | uv pip install -r - -p main.venv && uv run -p main.venv -- python -c "import anyio; print(anyio)"
uvsx() {
    local script="$1"
    shift
    script_dir="$(dirname "$script")"
    script_name="$(basename "$script" .py)"
    script_env="$script_dir/.inline_meta_$script_name.venv"

    if [ ! -f "$script" ] ; then
        echo "[Err]: file not exist"
        exit 1
    fi

    if [ ! -d "$script_env" ] ; then
        uv venv "$script_env"
        uv export --script "$script" |  uv pip install -r - -p "$script_env"
    fi
    (
        . "$script_env/bin/activate" && "$@"
    )
}


uvnvi() {
    local script="$1"
    shift
    uvsx "$script" nvim "$script" "$@"
}
