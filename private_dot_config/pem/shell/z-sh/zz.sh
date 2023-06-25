#
# zz(){
#     local temp=` z -l | fzf | awk '{print $2}' | sed -e "s@^~@${HOME}@g" `
#     cd "$temp"
# }
