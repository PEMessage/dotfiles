# PEMessage/chezmoi-dotfiles

## Requirement

* Linux： `unixutils` `findutils` `nvim/vim` `tmux`

## Recommand 

* `bat` `fd` `ripgrep` `fzf` `jq` `zsh` 
* See [modern unix](https://github.com/ibraheemdev/modern-unix) for more

## Usage

* Windows: `chezmoi init --branch windows PEMessage/chezmoi-dotfiles `
* Linux: `chezmoi init --branch linux PEMessage/chezmoi-dotfiles `

## Action 

Modify action-branch/run.sh
use github action 'Update Windows' manually
(or set event on: push if you want)
then you could sync dotfiles across branch

## Reference 

- [@skywind/vim/etc](https://github.com/skywind3000/vim) 
- [skywind/vim-init](https://github.com/skywind3000/vim-init)
- [LazyVim/LazyVim](https://github.com/LazyVim/LazyVim)
- [rupa/z.sh](https://github.com/rupa/z)
- [fzf](https://github.com/junegunn/fzf/wiki/Related-projects)
- ...
