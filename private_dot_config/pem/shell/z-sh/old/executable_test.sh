#!/usr/bin/env sh
# ntharg() {
#     shift $1
#     printf '%s\n' "$1"
# }
# LAST_ARG=`ntharg $# "$@"`
# echo $lastarg
# echo $LAST_ARG

_fasd_data="$(cat ~/.cache/fasd)"


bre0="$(printf %s\\n "$1" | sed 's/\([*\.\\\[]\)/\\\1/g
s@ @[^|]*@g;s/\$$/|/')"

echo "$bre"
bre='^[^|]*'"$bre0"'[^|/]*|'
bre_last='|[^|]*'"$bre0"'[^|]*$'

echo "$bre"
echo "$bre_last"
_ret="$(printf %s\\n "$_fasd_data" |  grep "\($bre\|$bre_last\)")"
# _ret_last="$(printf %s\\n "$_fasd_data" |  grep "$bre_last")"

echo "$_ret" "$_ret_last"

