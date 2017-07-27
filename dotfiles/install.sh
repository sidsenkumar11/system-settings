cd .dotfiles
for d in $(ls); do stow $d; done
cd ..
