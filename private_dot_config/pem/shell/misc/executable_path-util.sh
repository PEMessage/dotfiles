#!/bin/sh


# Add current dir to PATH
# a2p() {
#     if [ "$1" != "" ] ; then
#         echo "Runing:"
#         echo "export PATH=\"$(readlink -f "$1"):\$PATH\""
#         export PATH="$(readlink -f "$1"):$PATH"
#     else
#         echo "Runing:"
#         echo "export PATH=\"$(pwd):\$PATH\""
#         export PATH="$(pwd):$PATH"
#     fi
#     echo
#     echo "Current Path:"
#     echo $PATH | tr ':' '\n' | grep -v '^$' | head -n5
#     echo '...'
# }
a2p() {
    local mode="PATH"
    local var_name="PATH"
    local description="PATH"
    local var_type="POSIX"
    local target_dir=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --lib|--ld)
                mode="LIBRARY"
                var_name="LD_LIBRARY_PATH"
                description="LD_LIBRARY_PATH"
                var_type="POSIX"
                shift
                ;;
            --pkg|--pkgconfig)
                mode="PKGCONFIG"
                var_name="PKG_CONFIG_PATH"
                description="PKG_CONFIG_PATH"
                var_type="POSIX"
                shift
                ;;
            --func|--fpath)
                mode="FPATH"
                var_name="fpath"
                description="fpath (zsh function path)"
                var_type="ARRAY"
                shift
                ;;
            -*)
                echo "Unknown option: $1"
                echo "Use --help for usage information"
                return 1
                ;;
            *)
                target_dir="$1"
                shift
                ;;
        esac
    done

    # Determine target directory
    if [ -n "$target_dir" ]; then
        if [ -d "$target_dir" ]; then
            target_dir="$(readlink -f "$target_dir")"
        else
            echo "Error: Directory '$target_dir' does not exist"
            return 1
        fi
    else
        target_dir="$(pwd)"
    fi

    # Validate directory
    if [ ! -d "$target_dir" ]; then
        echo "Error: Invalid directory '$target_dir'"
        return 1
    fi

    # Handle based on variable type
    if [ "$var_type" = "ARRAY" ]; then
        # Array type variables (e.g., fpath in zsh)
        local dir_exists=0
        local existing_entry
        eval "for existing_entry in \"\${$var_name[@]}\"; do [ \"\$existing_entry\" = \"$target_dir\" ] && dir_exists=1; done"
        
        if [ "$dir_exists" -eq 0 ]; then
            eval "$var_name=(\"$target_dir\" \${$var_name[@]})"
        fi
        
        echo "Running:"
        echo
        echo "$var_name=(\"$target_dir\" \$$var_name)"
        
        # Show current entries
        echo
        echo "Current $description:"
        echo
        eval 'printf  "%s\n" "${'"$var_name""[@]}\" |  head -n5"
        local line_count
        eval "line_count=\${#${var_name}[@]}"
        if [ "$line_count" -gt 5 ]; then
            echo "..."
        fi
        echo "($line_count total entries)"
    else
        # POSIX type: colon-separated path variables
        local current_value
        eval "current_value=\"\$$var_name\""
        
        # Add directory if not already present
        if [ -z "$current_value" ]; then
            export "$var_name"="$target_dir"
        elif [[ ":$current_value:" != *":$target_dir:"* ]]; then
            export "$var_name"="$target_dir:$current_value"
        fi
        
        echo "Running:"
        echo
        echo "export $var_name=\"$target_dir:\$$var_name\""
        
        # Show current entries
        echo
        echo "Current $description:"
        echo
        eval "echo \$$var_name" | tr ':' '\n' | grep -v '^$' | head -n5
        local line_count
        line_count=$(eval "echo \$$var_name" | tr ':' '\n' | grep -v '^$' | wc -l)
        if [ "$line_count" -gt 5 ]; then
            echo "..."
        fi
        echo "($line_count total entries)"
    fi
}

# Optional: Create aliases for convenience
alias a2p-lib='a2p --lib'
alias a2p-pkg='a2p --pkgconfig'
alias a2p-func='a2p --fpath'



# in order use - in function name, using ksh style declare
function q-activate() {
    local current_dir="$PWD"
    local found=0

    while [ "$current_dir" != "/" ]; do
        if [ -d "$current_dir/.venv" ]; then
            found=1
            break
        fi
        current_dir=$(dirname "$current_dir")
    done

    if [ "$found" -eq 0 ]; then
        echo "No .venv directory found in any parent directory"
        return 1
    else
        source "$current_dir/.venv/bin/activate"
    fi
}
