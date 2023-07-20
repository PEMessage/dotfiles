# set PATH so it includes user's private bin if it exists

# if [ -d "$PEMHOME/arch/x86_64/bin" ]; then
#     export PATH="$PATH:$PEMHOME/arch/x86_64/bin"
# fi

for d in "$PEMHOME"/arch/x86_64/bin/*.d; do 
    export PATH="$PATH:$d"
done

export PATH

