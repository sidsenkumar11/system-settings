cd .dotfiles
for d in $(ls); do stow $d -t $HOME; done
cd ..
