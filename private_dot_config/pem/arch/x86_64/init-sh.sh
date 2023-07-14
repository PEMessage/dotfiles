# set PATH so it includes user's private bin if it exists

if [ -d "$PEMHOME/arch/x86_64/bin" ]; then
    export PATH="$PATH:$PEMHOME/arch/x86_64/bin"
fi

export PATH

