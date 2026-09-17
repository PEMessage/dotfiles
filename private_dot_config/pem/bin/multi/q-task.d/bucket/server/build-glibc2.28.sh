mkdir -p ~/src ~/.local/glibc-2.28
cd ~/src

wget https://ftp.gnu.org/gnu/glibc/glibc-2.28.tar.gz
tar xzf glibc-2.28.tar.gz

mkdir -p glibc-2.28-build && cd glibc-2.28-build
../glibc-2.28/configure --prefix=$HOME/.local/glibc-2.28 --disable-werror

make -j$(nproc)
make install
