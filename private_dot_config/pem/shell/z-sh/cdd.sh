

dm(){
    local mark_name
    local prompt_message
    local local_dir=`pwd`
    if [ -z $1 ] ; then
        mark_nane='EMPTY'
        prompt_message='Clean the mark'
    else
        mark_name="$1"
        prompt_message="Mark to $mark_name"
    fi
    # echo $local_dir
    fasd --mark  "$local_dir" "$mark_name"
    echo "$local_dir -> $prompt_message "
}

zfzf(){

}
