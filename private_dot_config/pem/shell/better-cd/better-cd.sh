

# For file autocd to it's dir / accept stdin 
bcd()
{
    local location_path
    # if [ "$1" = '-' -o "$#" = 0 ]; then
    if [   "$#" = 0 -o "$1" = '--print'  ]; then
        location_path=$(</dev/stdin)
    else
        location_path="$1"
    fi

    local pathtype
    pathtype=$( file "$location_path" | cut -d ' ' -f 2 )

    # echo $pathtype
    
    if [ "$pathtype" != "directory" ] ; then
        location_path=`dirname "$location_path"`
    fi

    if [ "$1" = '--print' ] ; then
        echo "$location_path"
    else
        # cd "$location_path" > /dev/null 2&>1 
        cd "$location_path" 
    fi
    return 0
}

wcd () { cd "`wslpath "$1"`"; }
