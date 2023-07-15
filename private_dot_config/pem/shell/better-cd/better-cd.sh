

# For file autocd to it's dir / accept stdin 
bcd()
{
    local location_path
    if [ "$1" = '-' ]; then
        location_path=$(</dev/stdin)
    else
        location_path="$1"
    fi

    local pathtype
    pathtype=$( file "$location_path" | cut -d ' ' -f 2 )

    # echo $pathtype
    
    if [ "$pathtype" = "directory" ] ; then
        cd "$location_path"
        return 0
    else
        location_path=`dirname "$location_path"`
        cd "$location_path" > /dev/null 2&>1 
        return 0
    fi
}
