#!/usr/bin/env bash



COMMANDLINETOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip"
setup_cmdline-tools() {
    (
        if [  -d "cmdline-tools" ] ; then
            return 
        fi

        if [ ! -f "commandlinetools.zip" ] ; then
            curl --progress-bar \
                "$COMMANDLINETOOLS_URL" \
                --output commandlinetools.zip
        fi
        unzip commandlinetools.zip
    )
}
