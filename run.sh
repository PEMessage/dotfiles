#! /usr/bin/bash

pwd
ls -al

cp -f ./linux/dot_vimrc ./windows/dot_vimrc 

mkdir -p ./windows/AppData/Local/nvim
cp -f ./linux/private_dot_config/nvim/init.lua  ./windows/AppData/Local/nvim/init.lua