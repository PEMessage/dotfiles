# Waydroid
# WSl custom kernel
# https://gist.github.com/oleksis/eb6d2f1cd2a6946faefb139aa0e38c35
# https://github.com/waydroid/waydroid/issues/217
# https://www.youtube.com/watch?v=SfK4PBcFq0w
# Powershell shutdown & remove config
# wsl --shutdown
# rm /mnt/c/Users/user/.wslconfig

# install dependencies
# sudo apt install -y git bc build-essential flex bison libssl-dev libelf-dev dwarves libncurses-dev
# sudo apt install -y aria2
# cd ~

#kernelver="WSL2-Linux-Kernel-4.19.121-microsoft-standard"
#kernellink="https://github.com/microsoft/WSL2-Linux-Kernel/archive/${kernelver}.tar.gz"
#kernelver="5.15.79.1"
kernelver="5.15.167.4"
kernellinkname="linux-msft-wsl-${kernelver}"
kerneldir="WSL2-Linux-Kernel-linux-msft-wsl-${kernelver}"
#kernellink="https://github.com/microsoft/WSL2-Linux-Kernel/archive/${kernellinkname}.tar.gz"
kernellink="https://github.com/microsoft/WSL2-Linux-Kernel/archive/refs/tags/${kernellinkname}.tar.gz"
#kernellink="https://github.com/microsoft/WSL2-Linux-Kernel/archive/refs/tags/${kernellinkname}.zip"

# download and extract
if [ ! -f ${kerneldir}.tar.gz ] ; then
    aria2c -x 10 $kernellink
#https://github.com/microsoft/WSL2-Linux-Kernel/archive/refs/tags/linux-msft-wsl-5.15.79.1.zip
#https://github.com/microsoft/WSL2-Linux-Kernel/archive/linux-msft-wsl-5.15.79.1.tar.gz
fi
tar -xf ${kerneldir}.tar.gz
cd ${kerneldir}/
cp Microsoft/config-wsl .config

# Add ashmem and binder
# echo "CONFIG_ANDROID=y
# CONFIG_ASHMEM=y
# CONFIG_ANDROID_BINDER_IPC=y
# CONFIG_ANDROID_BINDERFS=y
# CONFIG_ANDROID_BINDER_DEVICES="binder,hwbinder,vndbinder"
# CONFIG_ANDROID_BINDER_IPC_SELFTEST=y
# CONFIG_STAGING=y" | tee -a .config
./scripts/config --file .config \
    --enable CONFIG_ANDROID \
    --enable CONFIG_ASHMEM \
    --enable CONFIG_ANDROID_BINDER_IPC \
    --set-str CONFIG_ANDROID_BINDER_DEVICES "binder,hwbinder,vndbinder" \
    --enable CONFIG_ANDROID_BINDERFS
make olddefconfig

# compile
make -j $(expr $(nproc) - 1)
# sudo make modules_install

# move new kernel to C drive
# cp arch/x86/boot/bzImage /mnt/c/Users/user/bzImage
# echo "[wsl2]
# kernel=C:\\\\Users\\\\user\\\\bzimage" | tee -a /mnt/c/Users/user/.wslconfig
#nano /mnt/c/Users/user/.wslconfig
