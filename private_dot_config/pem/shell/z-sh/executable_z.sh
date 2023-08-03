# Copyright (c) 2009 rupa deadwyler. Licensed under the WTFPL license, Version 2

# maintains a jump-list of the directories you actually use
#
# INSTALL:
#     * put something like this in your .bashrc/.zshrc:
#         . /path/to/z.sh
#     * cd around for a while to build up the db
#     * PROFIT!!
#     * optionally:
#         set $_Z_CMD in .bashrc/.zshrc to change the command (default z).
#         set $_Z_DATA in .bashrc/.zshrc to change the datafile (default ~/.z).
#         set $_Z_MAX_SCORE lower to age entries out faster (default 9000).
#         set $_Z_NO_RESOLVE_SYMLINKS to prevent symlink resolution.
#         set $_Z_NO_PROMPT_COMMAND if you're handling PROMPT_COMMAND yourself.
#         set $_Z_EXCLUDE_DIRS to an array of directories to exclude.
#         set $_Z_OWNER to your username if you want use z while sudo with $HOME kept
#
# USE:
#     * z foo     # cd to most frecent dir matching foo
#     * z foo bar # cd to most frecent dir matching foo and bar
#     * z -r foo  # cd to highest ranked dir matching foo
#     * z -t foo  # cd to most recently accessed dir matching foo
#     * z -l foo  # list matches instead of cd
#     * z -e foo  # echo the best match, don't cd
#     * z -c foo  # restrict matches to subdirs of $PWD
#     * z -x      # remove the current directory from the datafile
#     * z -h      # show a brief help message

# EXTRA USAGE (z.sh-bookmark)
#     * z -m                                  # show all bookmark (notice: it will overwrite others option)
#                                             # example : `z -mlt` will equal to `z -m` looking forward to improve in futrue
#     * z --read-mark [path or bookmark name] # if given a path return its bookmark name , given bookmark name return path
#     * z --mark [bookmark name] [path]       # show all bookmark 
#     * z [bookmark]                          # jump to bookmark, NOTICE: your will need to type full bookmark name
# HANDY FUNCTION (z-mark)
#     * z-mark [bookmark name]                # mark $PWD with [bookmark name]
#     * z-mark                                # clean $PWD bookmark

[ -d "$HOME/.cache/z-sh" ] || {
    mkdir -p "$HOME/.cache/z-sh"
}
_Z_DATA="$HOME/.cache/z-sh/z-sh.history"

[ -d "${_Z_DATA:-$HOME/.z}" ] && {
    echo "ERROR: z.sh's datafile (${_Z_DATA:-$HOME/.z}) is a directory."
}

_z() {

    local datafile="${_Z_DATA:-$HOME/.z}"

    # if symlink, dereference
    [ -h "$datafile" ] && datafile=$(readlink "$datafile")

    # bail if we don't own ~/.z and $_Z_OWNER not set
    [ -z "$_Z_OWNER" -a -f "$datafile" -a ! -O "$datafile" ] && return

    _z_dirs () {
        [ -f "$datafile" ] || return

        local line
        while read line; do
            # only count directories
            [ -d "${line%%\|*}" ] && echo "$line"
        done < "$datafile"
        return 0
    }

    # add entries
    if [ "$1" = "--add" ]; then
        shift

        # $HOME and / aren't worth matching
        [ "$*" = "$HOME" -o "$*" = '/' ] && return

        # don't track excluded directory trees
        if [ ${#_Z_EXCLUDE_DIRS[@]} -gt 0 ]; then
            local exclude
            for exclude in "${_Z_EXCLUDE_DIRS[@]}"; do
                case "$*" in "$exclude"*) return;; esac
            done
        fi

        # maintain the data file
        local tempfile="$datafile.$RANDOM"
        local score=${_Z_MAX_SCORE:-9000}
        _z_dirs | awk -v path="$*" -v now="$(date +%s)" -v score=$score -F"|" '
            BEGIN {
                rank[path] = 1
                time[path] = now
                mark[path] = ""
            }
            $2 >= 1 || $4 != "" {
                # drop ranks below 1
                if( $1 == path ) {
                    rank[$1] = $2 + 1
                    time[$1] = now
                } else {
                    rank[$1] = $2
                    time[$1] = $3
                }
                mark[$1] = $4
                count += $2
            }
            END {
                if( count > score ) {
                    # aging
                    for( x in rank ) print x "|" 0.99*rank[x] "|" time[x] "|" mark[x]
                } else for( x in rank ) print x "|" rank[x] "|" time[x] "|" mark[x]
            }
        ' 2>/dev/null >| "$tempfile"
        # do our best to avoid clobbering the datafile in a race condition.
        if [ $? -ne 0 -a -f "$datafile" ]; then
            env rm -f "$tempfile"
        else
            [ "$_Z_OWNER" ] && chown $_Z_OWNER:"$(id -ng $_Z_OWNER)" "$tempfile"
            env mv -f "$tempfile" "$datafile" || env rm -f "$tempfile"
        fi

    elif [ "$1" = '--mark' ] ; then
        shift
        local mark_name="$1"
        shift

        local tempfile="$datafile.$RANDOM"
        local score=${_Z_MAX_SCORE:-9000}
        _z_dirs | awk -v path="$*" -v mark_name="$mark_name" -F"|" '
            {
                if( $1 == path ) {
                    rank[$1] = $2
                    time[$1] = $3
                    mark[$1] = mark_name
                } else {
                    rank[$1] = $2
                    time[$1] = $3
                    mark[$1] = $4
                }
            }
            END {
                if( count > score ) {
                    # aging
                    for( x in rank ) print x "|" 0.99*rank[x] "|" time[x] "|" mark[x]
                } else for( x in rank ) print x "|" rank[x] "|" time[x] "|" mark[x]
            } 
        ' 2>/dev/null >| "$tempfile"
        # do our best to avoid clobbering the datafile in a race condition.
        if [ $? -ne 0 -a -f "$datafile" ]; then
            env rm -f "$tempfile"
        else
            [ "$_Z_OWNER" ] && chown $_Z_OWNER:"$(id -ng $_Z_OWNER)" "$tempfile"
            env mv -f "$tempfile" "$datafile" || env rm -f "$tempfile"
        fi
    elif [ "$1" = '--read-mark' ] ; then
        shift
        [ -z "$*" ] && return 0

        _z_dirs | awk -v path_or_mark="$*" -F"|" '
            {
                if ( $1 == path_or_mark ) {
                    print "Mark:" $4
                    exit

                } 
                if ( $4 == path_or_mark ) {
                    print "Path:" $1
                    exit
                }
            }
        ' 2>/dev/null     

    # tab completion
    elif [ "$1" = "--complete" -a -s "$datafile" ]; then
        _z_dirs | awk -v q="$2" -F"|" '
            BEGIN {
                q = substr(q, 3)
                if( q == tolower(q) ) imatch = 1
                gsub(/ /, ".*", q)
            }
            {
                if( imatch ) {
                    if( tolower($1) ~ q ) print $1
                } else if( $1 ~ q ) print $1
            }
        ' 2>/dev/null



    else
        # list/go
        local echo fnd last list opt typ
        while [ "$1" ]; do case "$1" in
            --) while [ "$1" ]; do shift; fnd="$fnd${fnd:+ }$1";done;;
            -*) opt=${1:1}; while [ "$opt" ]; do case ${opt:0:1} in
                    c) fnd="^$PWD $fnd";;
                    e) echo=1;;
                    h) echo "${_Z_CMD:-z} [-cehlrtx] args" >&2; return;;
                    l) list=1;;
                    r) typ="rank";;
                    t) typ="recent";;
                    m) typ="mark";;
                    x) sed -i -e "\:^${PWD}|.*:d" "$datafile";;
                esac; opt=${opt:1}; done;;
             *) fnd="$fnd${fnd:+ }$1";;
        esac; last=$1; [ "$#" -gt 0 ] && shift; done
        [ "$fnd" -a "$fnd" != "^$PWD " ] || list=1

        # if we hit enter on a completion just go there
        case "$last" in
            # completions will always start with /
            /*) [ -z "$list" -a -d "$last" ] && builtin cd "$last" && return;;
        esac

        # no file yet
        [ -f "$datafile" ] || return

        if [ "$typ" = "mark" ]; then
           local temp=` _z_dirs | awk -F"|" '
                $4 != "" {
                    print  "Mark:" $4 "   |" $1
                }
            ' `
            echo $temp
            return 0

        fi

        local cd
        cd="$( < <( _z_dirs ) awk -v t="$(date +%s)" -v list="$list" -v typ="$typ" -v q="$fnd" -F"|" '
            function frecent(rank, time) {
                # relate frequency and time
                dx = t - time
                if( dx < 3600 ) return rank * 4
                if( dx < 86400 ) return rank * 2
                if( dx < 604800 ) return rank / 2
                return rank / 4
            }
            function output(matches, best_match, common) {
                # list or return the desired directory
                if( list ) {
                    if( common ) {
                        printf "%-10s %s\n", "common:", common > "/dev/stderr"
                    }
                    cmd = "sort -n -r >&2"
                    for( x in matches ) {
                        if( matches[x] ) {
                            printf "%-10s %s\n", matches[x], x | cmd
                        }
                    }
                } else {
                    if( common && !typ ) best_match = common
                    print best_match
                }
            }
            function matchpast(str, ere, thresh) {
                n = match(str, ere)
                if ( n <= 1 ) {
                    return 0
                }
                if (n + RLENGTH > thresh)
                    return 1
                return 0
            }
            
            function common(matches) {
                # find the common root of a list of matches, if it exists
                for( x in matches ) {
                    if( matches[x] && (!short || length(x) < length(short)) ) {
                        short = x
                    }
                }
                if( short == "/" ) return
                for( x in matches ) if( matches[x] && index(x, short) != 1 ) {
                    return
                }
                return short
            }
            BEGIN {
                gsub(" ", ".*", q)
                lhi_rank = hi_rank = ihi_rank = -9999999999
                match_mark = ""
            }
            {
                if ( q == $4 && $4 != "" ) {
                    is_match_mark = $1
                    next
                }
                n = split($1, broken, "/")
                # if (n == 1)
                #     threshhold = 0
                threshhold = length($1) - length(broken[n])

                if( typ == "rank" ) {
                    rank = $2
                } else if( typ == "recent" ) {
                    rank = $3 - t
                } else rank = frecent($2, $3)

                if ( matchpast($1,q,threshhold) ) {
                    # Last Match
                    lmatches[$1] = rank
                } else if( $1 ~ q ) {
                    matches[$1] = rank
                } else if( tolower($1) ~ tolower(q) ) {
                    imatches[$1] = rank
                }

                if( lmatches[$1] && lmatches[$1] > lhi_rank ) {
                    lbest_match = $1 
                    lhi_rank = lmatches[$1]
                } else if( matches[$1] && matches[$1] > hi_rank ) {
                    best_match = $1
                    hi_rank = matches[$1]
                } else if( imatches[$1] && imatches[$1] > ihi_rank ) {
                    ibest_match = $1
                    ihi_rank = imatches[$1]
                }
            }
            END {
                # prefer case sensitive
                if ( is_match_mark != "" ) {
                    print is_match_mark
                    exit
                } else if ( lbest_match ) {
                    output(lmatches, lbest_match, 0)
                    exit
                } else if( best_match ) {
                    output(matches, best_match, common(matches))
                    exit
                } else if( ibest_match ) {
                    output(imatches, ibest_match, common(imatches))
                    exit
                }
                exit(1)
            }
        ')"

        if [ "$?" -eq 0 ]; then
          if [ "$cd" ]; then
            if [ "$echo" ]; then echo "$cd"; else builtin cd "$cd"; fi
          fi
        else
          return $?
        fi
    fi
}

alias ${_Z_CMD:-z}='_z 2>&1'

[ "$_Z_NO_RESOLVE_SYMLINKS" ] || _Z_RESOLVE_SYMLINKS="-P"

if type compctl >/dev/null 2>&1; then
    # zsh
    [ "$_Z_NO_PROMPT_COMMAND" ] || {
        # populate directory list, avoid clobbering any other precmds.
        if [ "$_Z_NO_RESOLVE_SYMLINKS" ]; then
            _z_precmd() {
                (_z --add "${PWD:a}" &)
                : $RANDOM
            }
            _z_curdir() {
                echo "${PWD:a}"
            }
        else
            _z_precmd() {
                (_z --add "${PWD:A}" &)
                : $RANDOM
            }
            _z_curdir() {
                echo "${PWD:A}"
            }
        fi
        [[ -n "${precmd_functions[(r)_z_precmd]}" ]] || {
            precmd_functions[$(($#precmd_functions+1))]=_z_precmd
        }
    }
    _z_zsh_tab_completion() {
        # tab completion
        local compl
        read -l compl
        reply=(${(f)"$(_z --complete "$compl")"})
    }
    compctl -U -K _z_zsh_tab_completion _z
elif type complete >/dev/null 2>&1; then
    # bash
    # tab completion
    complete -o filenames -C '_z --complete "$COMP_LINE"' ${_Z_CMD:-z}
    [ "$_Z_NO_PROMPT_COMMAND" ] || {
        # populate directory list. avoid clobbering other PROMPT_COMMANDs.
        grep "_z --add" <<< "$PROMPT_COMMAND" >/dev/null || {
            PROMPT_COMMAND="$PROMPT_COMMAND"$'\n''(_z --add "$(command pwd '$_Z_RESOLVE_SYMLINKS' 2>/dev/null)" 2>/dev/null &);'
        }
        _z_curdir(){
            echo "$(command pwd '$_Z_RESOLVE_SYMLINKS' 2>/dev/null)"
        }
    }
fi

# Personal Alias Command

z-fzf(){ 

    _z_dirs(){
        [ -f "$datafile" ] || return

        local line
        while read line; do
            # only count directories
            [ -d "${line%%\|*}" ] && echo "$line"
        done < "$datafile"
        return 0
    }
    local datafile="${_Z_DATA:-$HOME/.z}"
    local fnd opt cmd
    while [ "$1" ]; do case "$1" in
        --) while [ "$1" ]; do shift; fnd="$fnd${fnd:+ }$1";done;;
        -*) opt=${1:1}; while [ "$opt" ]; do case ${opt:0:1} in
                t)cmd='t';;
                r)cmd='r';;
                m)cmd='m';;
                d)cmd='d';;
            esac; opt=${opt:1}; done;;
         *) fnd="$fnd${fnd:+ }$1";;
    esac; last=$1; [ "$#" -gt 0 ] && shift; done

    if [ "$cmd" = d ] ; then
        [ -n "$fnd" ] &&  _z  "$fnd" && return
        local temp=` _z -l 2>&1 | awk '{print $2}' | fzf  --no-sort | sed -e "s@^~@${HOME}@g" `
        cd "$temp"

    elif [ "$cmd" = t -o "$cmd" = r ] ; then
        [ -n "$fnd" ] &&  _z -"$cmd" "$fnd" && return
        local temp=` _z -l"$cmd" 2>&1 | awk '{print $2}' | fzf  --no-sort | sed -e "s@^~@${HOME}@g" `
        cd "$temp"

    elif [ "$cmd" = 'm' ] ; then
        local temp=` _z -lm 2>&1 | fzf --no-sort | awk -F'|' '{print $2}' | sed -e "s@^~@${HOME}@g" `
        cd "$temp"

    else
        return 1 
    fi



    # if [ -n "$fnd" ] ; then
    #     _z -"$cmd" "$fnd"
    #
    #     return
    # elif [ ! -z "$cmd" ]; then
    #     local temp=` _z -l"$cmd" 2>&1 | awk '{print $2}' | fzf  --no-sort | sed -e "s@^~@${HOME}@g" `
    #     cd "$temp"
    # else
    #     local temp=` _z -lt 2>&1 | awk '{print $2}' | fzf --no-sort | sed -e "s@^~@${HOME}@g" `
    #     cd "$temp"
    # fi
}
# zr(){
#     local temp=` _z -lt 2>&1 | fzf | awk '{print $2}' | sed -e "s@^~@${HOME}@g" `
#     cd "$temp"
# }

z-mark(){
    local mark_name
    local prompt_message
    local local_dir=`_z_curdir`
    if [ -z $1 ] ; then
        mark_nane=''
        prompt_message='Clean the mark'
    else
        mark_name="$1"
        prompt_message="Mark to $mark_name"
    fi
    # echo $local_dir
    _z --mark "$mark_name" "$local_dir"
    echo "$local_dir -> $prompt_message "

}
alias cdt='z-fzf -t '
alias cdr='z-fzf -r '
alias cdd='z-fzf -d '
alias cdm='z-fzf -m '
alias md='z-mark '


