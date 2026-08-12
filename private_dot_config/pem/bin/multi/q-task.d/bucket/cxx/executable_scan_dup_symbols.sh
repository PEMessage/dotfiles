#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# scan_dup_symbols.sh
#
# Finds global symbols that are DEFINED in more than one shared library
# among a given set of .so files.  A name defined in two DSOs is a
# symbol-interposition / ODR hazard: the dynamic linker keeps only the
# first-loaded definition and silently redirects the other library to it.
#
# It reads the dynamic symbol table (.dynsym) directly with `nm -D`, so no
# recompilation and no sanitizer is needed -- release binaries work too.
#
# Structured as small functions that take inputs via arguments/stdin and
# produce output on stdout, with no module-level state.
# ---------------------------------------------------------------------------
set -u

# ---------------------------------------------------------------------------
# usage:  print how to call the tool, then exit 1
# ---------------------------------------------------------------------------
usage() {
    cat <<'EOF'
usage: scan_dup_symbols.sh [-v] <lib1.so> [lib2.so ...]
  -v  also report weak symbols (W/V), usually benign
EOF
    exit 1
}

# ---------------------------------------------------------------------------
# collect_symbols  <types> <lib...>
#   input : list of shared libraries (arguments)
#   output: one line per global defined symbol: "name type file"
#   keeps : only DEFINED (`--defined-only`) GLOBAL (uppercase type) symbols
#           of the given types; symbol versions (e.g. `foo@@VER`) are stripped
# ---------------------------------------------------------------------------
collect_symbols() {
    local types="$1"
    shift
    for lib in "$@"; do
        [ -f "$lib" ] || { echo "skip missing: $lib" >&2; continue; }
        nm -D --defined-only "$lib" \
            | awk -v types="[$types]" -v lib="$lib" '
                NF >= 3 && $2 ~ types {
                    name = $3; sub(/@.*/, "", name)
                    print name, $2, lib
                }'
    done
}

# ---------------------------------------------------------------------------
# find_duplicate_names
#   input : "name type file" lines on stdin
#   output: names that appear on more than one line (i.e. in more than one lib)
# ---------------------------------------------------------------------------
find_duplicate_names() {
    cut -d' ' -f1 | sort | uniq -d
}

# ---------------------------------------------------------------------------
# print_symbol_legend
#   output: meaning of the nm type letters
# ---------------------------------------------------------------------------
print_symbol_legend() {
    echo "symbol types (upper case = global, lower case = local):"
    echo "  T  defined function (text)"
    echo "  B  uninitialized global data (BSS)"
    echo "  D  initialized global data"
    echo "  R  read-only data (.rodata)"
    echo "  W  weak function (inline/template instantiations; usually benign)"
    echo "  V  weak object (vtable / typeinfo; usually benign)"
}

# ---------------------------------------------------------------------------
# report_duplicates  <symbols> <duplicate_names> <num_libs> <weak>
#   input : the collected (name type file) lines and the duplicate names
#   output: one block per duplicate name, then a summary and the legend
# ---------------------------------------------------------------------------
report_duplicates() {
    local symbols="$1"
    local duplicate_names="$2"
    local num_libs="$3"
    local weak="$4"

    echo "== duplicate defined global symbols across $num_libs file(s) =="
    if [ -z "$duplicate_names" ]; then
        echo "  (none)"
        return 0
    fi

    printf '%s\n' "$duplicate_names" | while IFS= read -r name; do
        echo "--- $name ---"
        printf '%s\n' "$symbols" | grep "^$name " | sed 's/^/    /'
        echo
    done

    echo "total duplicate names: $(printf '%s\n' "$duplicate_names" | wc -l)"
    echo
    print_symbol_legend
    [ "$weak" -eq 0 ] && echo "note: only strong symbols (T/B/D/R) reported; weak (W/V) shown with -v."
}

# ---------------------------------------------------------------------------
# main  <args...>
#   pipeline: collect_symbols -> find_duplicate_names -> report_duplicates
# ---------------------------------------------------------------------------
main() {
    local weak=0
    if [ "${1:-}" = "-v" ]; then
        weak=1
        shift
    fi
    local libs=("$@")
    [ "${#libs[@]}" -eq 0 ] && usage

    local types="TDBR"          # strong symbols: the real hazard
    [ "$weak" -eq 1 ] && types="TDBRWV"

    local symbols duplicate_names
    symbols="$(collect_symbols "$types" "${libs[@]}")"
    duplicate_names="$(printf '%s\n' "$symbols" | find_duplicate_names)"

    report_duplicates "$symbols" "$duplicate_names" "${#libs[@]}" "$weak"
}

main "$@"
