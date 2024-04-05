
install-fzf() {
    # Part 1
    # meta infomation
    # ------------------------------
    local version="0.49.0"
    local os="$CONF_OS"
    local arch="$CONF_ARCH"
    local lang="go"

    # Part 2
    # url and filename
    # These 3 in order
    # ------------------------------
    local url
    if [ "$os" = "linux" ] && [ "$arch" = "x86_64" ] ; then
        local url="https://github.com/junegunn/fzf/releases/download/${version}/fzf-${version}-${os}_amd64.tar.gz"
    else
        echo "[Err]: not support os or arch"
        return 1
    fi
    local filename="$(basename "${url}")"
    local filename_nosuffix="${filename%%.tar.gz}"


    # Part3
    # install bin infomation
    # ------------------------------
    local bin_source_path="fzf"
    local bin_root="$CONF_ROOT/bin"
    local bin_target_dir="$lang.$os-$arch"
    local bin_target_name="fzf"

    # Part4
    # other infomation
    # ------------------------------
    local tempdir="$(mktemp -d)"

    download_extract &&
    copy_bin 
    clear_temp
}
