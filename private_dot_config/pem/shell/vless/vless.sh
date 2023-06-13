# export MANPAGER="/bin/sh -c \"col -b | vim -c 'set ft=man ts=8 nomod nolist nonu noma' -\""
alias vman="MANPAGER='vim +MANPAGER \"+set nonumber\" -'  man"

# alias vvman="nvim -c \"lua require('telescope.builtin').man_pages({sections={'ALL'}})\""

vvman(){
    local temp="

       require('telescope.builtin').man_pages({
         sections={'ALL'},
         attach_mappings = function(_, map)
            map(
              {'i'},
              '<Enter>',
              function(...)
                return require('telescope.actions').select_tab(...)
              end
            )
            return true
         end,
       })

    "

    nvim -c "lua   $temp      " 

}




