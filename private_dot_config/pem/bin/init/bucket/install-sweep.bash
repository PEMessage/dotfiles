
install-sweep() {
    # Part 1
    # meta infomation
    # ------------------------------
    local version="1.0.0"
    local os="all"
    local arch="all"
    local lang="python"

    # Part 2
    # url and filename
    # These 3 in order
    # ------------------------------
    local url
    local url="https://github.com/PEMessage/sweep.py/archive/refs/tags/v${version}.zip"
    local filename="$(basename "${url}")"
    local filename_nosuffix="${filename%%.zip}"


    # Part3
    # install bin infomation
    # ------------------------------
    local bin_source_path="sweep.py-${version}/sweep.py"
    local bin_root="$CONF_ROOT/bin"
    local bin_target_dir="python3.bin"
    local bin_target_name="sweep"

    # Part4
    # other infomation
    # ------------------------------
    local tempdir="$(mktemp -d)"

    download_extract 
    copy_bin 
    clear_temp
}
