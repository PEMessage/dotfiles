
install-reverse-hexdump() {
    # Part 1
    # meta infomation
    # ------------------------------
    local version="master"
    local os="all"
    local arch="all"
    local lang="sh"

    # Part 2
    # url and filename
    # These 3 in order
    # ------------------------------
    local url
    local url="https://raw.githubusercontent.com/mfleetwo/reverse-hexdump/$version/reverse-hexdump.sh"
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
