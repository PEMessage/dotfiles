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

kernelver="6.6.87.2"
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


CONFIG=""
# Add ashmem and binder
# echo "CONFIG_ANDROID=y
# CONFIG_ASHMEM=y
# CONFIG_ANDROID_BINDER_IPC=y
# CONFIG_ANDROID_BINDERFS=y
# CONFIG_ANDROID_BINDER_DEVICES="binder,hwbinder,vndbinder"
# CONFIG_ANDROID_BINDER_IPC_SELFTEST=y
# CONFIG_STAGING=y" | tee -a .config
CONFIG+=" --enable CONFIG_ANDROID"
CONFIG+=" --enable CONFIG_ANDROID_BINDER_IPC"
CONFIG+=" --set-str CONFIG_ANDROID_BINDER_DEVICES binder,hwbinder,vndbinder"
CONFIG+=" --enable CONFIG_ANDROID_BINDERFS"
CONFIG+=" --enable CONFIG_STAGING"
CONFIG+=" --enable CONFIG_ASHMEM"

#
# WSL Cuttlefish support, thanks to
#   Know How:
#       CONFIG_VHOST_VSOCK is /dev/vhost-vsock
#       https://github.com/owninnn/my-notes/blob/master/cuttlefish-on-wsl.md know
#   crosvm error:
#       https://www.zhihu.com/question/307130942/answer/2948560140
#       https://issuetracker.google.com/issues/329130377
#       Also need `--enable_sandbox=false` to make it work
#
#   crosvm mount update 2025-11-11:
#       ```issue
#       crosvm[1]: libminijail[1]: cannot mount '/usr/lib' as '/var/empty/usr/lib' with flags 0x1001: Invalid argument
#       crosvm[1]: libminijail[1]: mount_one failed with /dev at '(null)'
#       ```
#       Thanks to:
#           https://stackoverflow.com/a/79248399
#           https://github.com/5ec1cff/my-notes/blob/master/cuttlefish-on-wsl.md
#       It seem like create a simple dir called '/var/empty/usr/lib' fix this issue
#
# Full Cmd:
#   HOME=$PWD ./bin/launch_cvd -webrtc_sig_server_port=8449
#
# Cuttlefish GPU explain:
#   See: https://source.android.com/docs/devices/cuttlefish/gpu?hl=zh-cn
#   --gpu_mode=gfxstream(vulkan) > --gpu_mode=drm_virgl(opnegl)
#
# OpenGL hardware accerlate not work:
#   Thanks to: https://forums.developer.nvidia.com/t/wsl2-ubuntu-24-04-lts-nvidia-gpu-detected-but-wslg-not-working-opengl-llvmpipe/347383
#   Official Blog: https://devblogs.microsoft.com/commandline/d3d12-gpu-video-acceleration-in-the-windows-subsystem-for-linux-now-available/
#
#   ```
#   export MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA
#   export GALLIUM_DRIVER=d3d12
#   export LIBGL_ALWAYS_SOFTWARE=false
#   ```
#   `glxgear -info ` workfine
#
# Still not work?(OpenGL):
#   `launch_cvd  -verbosity DEBUG --gpu_mode=drm_virgl` to see full log
#   `rg 'was requested but the prerequisites'`
#   https://github.com/google/android-cuttlefish/blob/8ea98b64f51fad897d1a97f9ab5673af8bcdad82/base/cvd/cuttlefish/host/commands/assemble_cvd/graphics_flags.cc#L171
#   return (sufficient_gles2 || sufficient_gles3) && has_discrete_gpu
#
#   we need has_discrete_gpu to enable hardware accerlate
#
#   so install latest mesa for dozen(dx12 -> vulkan)
#
# Vulkan not enable(not yet fix, and will cause other issue):
#   Thanks: https://forums.developer.nvidia.com/t/vulkan-fails-to-detect-nvidia-gpu-on-wsl2-ubuntu-24-04-dzn-driver-files-missing-tested-on-multiple-systems/342142
#   use `vulkaninfo --summary` see PHYSICAL_DEVICE_TYPE_CPU
#
#   update new version of mesa
#   ```
#   sudo add-apt-repository ppa:kisak/turtle (ubuntu 22.04) or sudo add-apt-repository ppa:kisak/kisak-mesa (ubuntu 24.04)
#   sudo apt update
#   sudo apt upgrade
#   ```
#
#   But if will encounter `emulator` seguement fault, so we need to uninstall it
#   ```
#   sudo ppa-purge -d noble ppa:kisak/turtle
#   ```
CONFIG+=" --enable CONFIG_KVM_GUEST"
CONFIG+=" --enable CONFIG_VHOST_VSOCK"


#
# Add input Relate staff to allow virtual_touchscreen work,
#
# Userland interfaces
CONFIG+=" --enable CONFIG_INPUT_EVDEV"
CONFIG+=" --enable CONFIG_INPUT_MOUSEDEV"
# Input Device Drivers
CONFIG+=" --enable CONFIG_INPUT_KEYBOARD"
CONFIG+=" --enable CONFIG_INPUT_MOUSE"
CONFIG+=" --enable CONFIG_INPUT_TOUCHSCREEN"

./scripts/config --file .config $CONFIG


make olddefconfig

# compile
make -j $(expr $(nproc) - 1)
make INSTALL_MOD_PATH="$PWD/modules" modules_install
sudo ./Microsoft/scripts/gen_modules_vhdx.sh "$PWD/modules" $(make -s kernelrelease) modules.vhdx
# sudo make modules_install

# move new kernel to C drive
# cp arch/x86/boot/bzImage /mnt/c/Users/user/bzImage
# echo "[wsl2]
# kernel=C:\\\\Users\\\\user\\\\bzimage" | tee -a /mnt/c/Users/user/.wslconfig
#nano /mnt/c/Users/user/.wslconfig
