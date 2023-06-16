

# For file autocd to it's dir / accept stdin 
bcd()
{
    local location_path
    if [ "$1" = '-' ]; then
        location_path=`cat -`
    else
        location_path="$1"
    fi

    local pathtype
    pathtype=$( file $location_path | cut -d ' ' -f 2 )
    if [ "$pathtype" = "directory" ] ; then
        cd "$location_path"
        return
    else
        cd `dirname $location_path`
        return
    fi
}
