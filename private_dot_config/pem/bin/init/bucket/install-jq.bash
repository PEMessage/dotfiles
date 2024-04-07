install-jq() {
    # Part 1
    # meta infomation
    # ------------------------------
    local version="1.7.1"
    local os="$CONF_OS"
    local arch="$CONF_ARCH"
    local lang="rust"

    # Part 2
    # url and filename
    # These 3 in order
    # ------------------------------
    local url
    if [ "$os" = "linux" ] && [ "$arch" = "x86_64" ] ; then 
        local url="https://github.com/jqlang/jq/releases/download/jq-${version}/jq-${os}-amd64"
    else
        echo "[Err]: not support os or arch"
        return 1
    fi
    
    local filename="$(basename "${url}")"
    local filename_nosuffix="${filename}"
    local skip_extract="true"

    # Part3
    # install bin infomation
    # ------------------------------
    local bin_source_path="${filename}"
    local bin_root="$CONF_ROOT/bin"
    local bin_target_dir="arch/$os-$arch/$lang.d"
    local bin_target_name="jq"

    # Part4
    # other infomation
    # ------------------------------
    local tempdir="$(mktemp -d)"

    download_extract &&
    copy_bin 
    clear_temp

}
