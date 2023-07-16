# set PATH so it includes user's private bin if it exists

if [ -d "$PEMHOME/arch/arm64/bin" ]; then
    export PATH="$PATH:$PEMHOME/arch/arm64/bin"
fi

export PATH

