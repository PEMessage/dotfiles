#!/bin/sh
__PEM_TEMP_THIS_SCRIPT="${BASH_SOURCE[0]-$0}"
__PEM_TEMP_THIS_DIR="${__PEM_TEMP_THIS_SCRIPT%/*}"
# echo "$__PEM_TEMP_THIS_SCRIPT"
# echo "$__PEM_TEMP_THIS_DIR"


case "$PEM_Z_BACKEND" in
    fasd)
        export _FASD_BACKENDS="native viminfo"
        export _FASD_MAX=6000
        source "${__PEM_TEMP_THIS_DIR:-UNKNOW}/fasd"
        eval "$(fasd --init auto)"
    ;;
    NULL|*)
        # do nothing
    ;;
esac

unset __PEM_TEMP_THIS_SCRIP
unset __PEM_TEMP_THIS_DIR
