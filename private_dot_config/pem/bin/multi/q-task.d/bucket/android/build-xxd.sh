

set -xe

wget https://raw.githubusercontent.com/vim/vim/refs/heads/master/src/xxd/xxd.c
aarch64-linux-gnu-gcc -static xxd.c -o xxd
rm xxd.c
