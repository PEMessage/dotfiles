
install-neofetch() {
    # Part 1
    # meta infomation
    # ------------------------------
    local version="master"
    local os="all"
    local arch="all"
    local lang="bash"

    # Part 2
    # url and filename
    # These 3 in order
    # ------------------------------
    local url
    local url="https://github.com/dylanaraps/neofetch/blob/${version}/neofetch"
    local filename="$(basename "${url}")"
    local filename_nosuffix="${filename%%.*}"
    local skip_extract="true"


    # Part3
    # install bin infomation
    # ------------------------------
    local bin_source_path="$filename"
    local bin_root="$CONF_ROOT/bin"
    local bin_target_dir="common/$lang.d"
    local bin_target_name="$filename_nosuffix"

    # Part4
    # other infomation
    # ------------------------------
    local tempdir="$(mktemp -d)"

    download_extract 
    copy_bin 
    clear_temp
}
