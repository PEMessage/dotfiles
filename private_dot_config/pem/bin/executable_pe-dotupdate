#! /bin/sh
cd ~
chezmoi re-add
echo "Add File to source"
temp=$(chezmoi source-path)
cd $temp
git add .
git commit -m 'Update'
git push 
echo "Push to git"
cd ~
