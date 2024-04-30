
    __PEM_Set_Add() {
        local name="$1"
        local value="$2"
        eval "local content=\"\$$name\""

        for x in $(echo $content) ;
        do
            if [ "$x" = "$value"  ] ; then
                return 0
            fi
        done
        eval "${name}=\"${content} ${value}\""

    }

    __PEM_NS_Set() {
        # set -x
        local nargs="$(( $# - 1 ))"
        local i=1
        local curname="PEM_NS"
        while [ "$i" -le "$nargs" ] ; do
            if [ "$i" -ne "$nargs" ] ; then
                local nextname="${curname}_${1}"
            else 
                local nextname="${curname}_${1}_LEAF"
            fi
            # eval "${curname}=\"\$${curname} ${nextname}\""
            __PEM_Set_Add "$curname" "$nextname"
            eval "curname=${nextname}"
            i=$((i + 1))
            shift
        done
        eval "${curname}=\"${1}\""
        # set +x
    }

    __PEM_NS_Get() {
        eval "echo \"\$${1}\""
    }

    __PEM_NS_Tree() {
        # set -x
        for x in $(__PEM_NS_Get ${1}) ;
        do
            case "$x" in
                *LEAF)
                    echo "$x"
                ;;
                *)
                    __PEM_NS_Tree "$x"
                ;;
            esac
        done
        # set +x
    }
