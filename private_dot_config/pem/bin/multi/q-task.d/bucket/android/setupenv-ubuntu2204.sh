#!/bin/bash


(
  [[ -n $ZSH_VERSION && $ZSH_EVAL_CONTEXT =~ :file$ ]] || 
  [[ -n $KSH_VERSION && "$(cd -- "$(dirname -- "$0")" && pwd -P)/$(basename -- "$0")" != "$(cd -- "$(dirname -- "${.sh.file}")" && pwd -P)/$(basename -- "${.sh.file}")" ]] || 
  [[ -n $BASH_VERSION ]] && (return 0 2>/dev/null)
) && sourced=1 || sourced=0

if [ "$sourced" = 0 ] ; then
    sudo apt install sdkmanager
    # download tools, the old name of commandline-tools (and still have old sdkmanager, ubuntu22.04 sdkmanager is so OLD!!!)
    # if using ubuntu24.04 we will have handy google-android-* package
    sudo sdkmanager tools # download less old sdkmanager

    sudo apt install openjdk-8-jdk # for sdkmanager in 'tool'
    sudo apt install openjdk-17-jdk # for sdkmanager in 'commandline-tools;latest'
fi


(
    export PATH="/opt/android-sdk/tools/bin:$PATH"
    export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-amd64"

    if [ "$sourced" = 0 ] ; then
        sudo -E env "PATH=$PATH" sdkmanager --install \
            "platforms;android-33" \
            "build-tools;33.0.2" \
            "cmdline-tools;latest"
    fi
)

export PATH="/opt/android-sdk/cmdline-tools/latest/bin:$PATH" # now we have new sdkmanager
# using q-sudo to call it(pass PATH)
