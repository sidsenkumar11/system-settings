#!/bin/bash
# Author  : Sid
# Purpose : CTF VM Setup Script

set -e # This stops the script if there is an error

# Update Repositories
echo ""
echo "################################################################"
echo "#################   Initial Update and Upgrade  ################"
echo "################################################################"
echo ""
sudo apt-get -y update
sudo apt-get -y upgrade
# sudo apt-get dist-upgrade -y # Tends to break vagrant build

# 32 Bit Libraries for 64 bit Machines
echo ""
echo "################################################################"
echo "##################   Installing i386 Libraries  ################"
echo "################################################################"
echo ""
sudo dpkg --add-architecture i386
sudo apt-get -y update
sudo apt-get -y install libc6:i386 libncurses5:i386 libstdc++6:i386
sudo apt-get -y install libgcc1:i386 zlib1g:i386 libglib2.0-0:i386 libfreetype6:i386
sudo apt-get -y install libsm6:i386 libice6:i386 libxrender1:i386 libfontconfig1:i386
sudo apt-get -y install libxext6:i386 libx11-6:i386 libc6-i686:i386 libexpat1:i386
sudo apt-get -y install libffi6:i386 libpcre3:i386 libpng12-0:i386 libstdc++6:i386
sudo apt-get -y install libuuid1:i386 libxau6:i386 libxcb1:i386 libx11-xcb1:i386
sudo apt-get -y install libdbus-1-3:i386 libxi6:i386 libcurl3:i386 libxdmcp6:i386
sudo apt-get -y install libxcb1:i386 libxau6:i386

# These are so the 64 bit VM can build 32 bit
sudo apt-get -y install libx32gcc-4.8-dev
sudo apt-get -y install libc6-dev-i386 libc6-dbg libc-dbg:i386

echo ""
echo "################################################################"
echo "################   Installing Linux Essentials  ################"
echo "################################################################"
echo ""

# Essentials
sudo apt-get -y install build-essential
sudo apt-get -y install git gparted vim
sudo apt-get -y install tmux screen
sudo apt-get -y install htop

# Create folder for holding all git-cloned tools
cd ~
mkdir -p tools # -p gives no error if it already exists
cd tools

echo ""
echo "################################################################"
echo "#################    Programming Languages  ####################"
echo "################################################################"
echo ""

# Pip
sudo apt-get -y install python-pip
sudo apt-get -y install python3-pip
sudo pip install --upgrade pip
sudo pip3 install --upgrade pip

# Latest Python 3
cd ~/tools
sudo apt-get -y install python3
sudo apt-get -y install zlib1g-dev
wget https://www.python.org/ftp/python/3.6.2/Python-3.6.2.tar.xz
tar xvJf Python-3.6.2.tar.xz
cd Python-3.6.2
./configure --prefix=/root/Python-3.6.2 --with-zlib=/usr/include
sudo make
sudo make install

# Latest Python 2
cd ~/tools
sudo apt-get -y install python
wget https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tar.xz
tar xvJf Python-2.7.9.tar.xz
cd Python-2.7.9
./configure --prefix=/root/Python-2.7.9 --with-zlib=/usr/include
sudo make
sudo make install

# Java
# You will need to press Enter to continue installing, then agree to the license in a bit
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get -y install oracle-java8-installer

# Virtualenv
sudo pip install virtualenv

# Fix urllib3 InsecurePlatformWarning
sudo -H pip install --upgrade urllib3[secure]

echo ""
echo "################################################################"
echo "#################    Pwn / Debugging Tools  ####################"
echo "################################################################"
echo ""

# Install binutils and binwalk
cd ~/tools
git clone https://github.com/devttys0/binwalk
cd binwalk
sudo python setup.py install
sudo apt-get -y install squashfs-tools
sudo apt-get -y install binutils

# Install radare2
cd ~/tools
git clone https://github.com/radare/radare2
cd radare2
./sys/install.sh

# Install r2pipe
sudo -H pip install --upgrade r2pipe

# Software Debugging
sudo apt-get -y install gdb gdb-multiarch
sudo apt-get -y install gcc-multilib
sudo apt-get -y install valgrind
sudo apt-get -y install gcc-arm-linux-gnueabihf
echo 'set auto-load safe-path /' > ~/.gdbinit # Fix warning when loading .gdbinit files

# Install Peda 
git clone https://github.com/longld/peda.git ~/peda
echo "source ~/peda/peda.py" >> ~/.gdbinit

# Pwntools
sudo apt-get -y install python-dev libssl-dev libffi-dev
sudo pip install --upgrade pwntools

# Angr
cd ~
sudo apt-get -y install virtualenvwrapper
virtualenv angr
source angr/bin/activate
pip install angr --upgrade
deactivate

# Install ROPGadget
cd ~/tools
git clone https://github.com/JonathanSalwan/ROPgadget
cd ROPgadget
sudo python setup.py install

# Install Intel PIN
cd ~/tools
wget  --quiet http://software.intel.com/sites/landingpage/pintool/downloads/pin-2.14-71313-gcc.4.4.7-linux.tar.gz
tar -xzvf pin-2.14-71313-gcc.4.4.7-linux.tar.gz
rm pin-2.14-71313-gcc.4.4.7-linux.tar.gz
cd pin*
export PIN_ROOT=$PWD
export PATH=$PATH:$PIN_ROOT;

#Install ropper 
sudo -H pip install ropper 

# Install golang
sudo apt-get -y install golang 

# Install rp++
cd ~/tools
wget -q https://github.com/downloads/0vercl0k/rp/rp-lin-x64
sudo install -s rp-lin-x64 /usr/bin/rp++
rm rp-lin-x64

# AFL Fuzzer
cd ~/tools
wget http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz
tar -zxvf afl-latest.tgz
pushd afl-*
make && sudo make install
popd
rm afl-latest.tgz

# Install z3 theorem prover
cd ~/tools
git clone https://github.com/Z3Prover/z3.git && cd z3
python scripts/mk_make.py --python
cd build
make && sudo make install

# Image Manipulation
sudo apt-get -y install foremost
sudo apt-get -y install ipython
sudo apt-get -y install silversearcher-ag
sudo apt-get -y install vlc gimp

# RSA CTF Tool
sudo apt-get -y install libgmp3-dev
cd ~/tools
git clone https://github.com/Ganapati/RsaCtfTool.git
cd RsaCtfTool
git clone https://github.com/hellman/libnum.git
virtualenv venv
source venv/bin/activate
cd libnum
python setup.py install
cd ..
pip install -r requirements.txt
git clone https://github.com/ius/rsatool.git
cd rsatool
python setup.py install
cd ..
deactivate

echo ""
echo "################################################################"
echo "#################   Personal Settings Setup  ###################"
echo "################################################################"
echo ""

# Linux utilities
sudo apt-get -y install tree ranger caca-utils highlight atool w3m poppler-utils mediainfo # The other tools allow file previews in ranger
sudo apt-get -y install zip unzip rar unrar p7zip-full

# Install zsh, set as default shell, install oh-my-zsh
sudo apt-get -y install zsh
chsh -s $(which zsh)
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
# plugins=(zsh-autosuggestions) # TODO: Might have to be done manually

# Personal Config Settings
sudo apt-get -y install stow
cd /home/vagrant
git clone https://github.com/sidsenkumar11/system-settings.git
cd system-settings/dotfiles
./install.sh

echo ""
echo "################################################################"
echo "#############  Installing Miscellaneous Software  ##############"
echo "################################################################"
echo ""

# Visual Studio Code
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get -y update
sudo apt-get -y install code # or code-insiders
# TODO: Export VSCode settings and import

# Set Visual Studio Code as default text editor
sudo update-alternatives --set editor /usr/bin/code

# Google Chrome
sudo apt-get -y install libxss1 libappindicator1 libindicator7
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome*.deb
sudo apt-get install -f

echo ""
echo "################################################################"
echo "#################   Final upgrades and cleanup  ################"
echo "################################################################"
echo ""

# Fix locales after installing everything
sudo locale-gen en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
sudo dpkg-reconfigure locales

# Update Repositories
sudo apt-get -y update
sudo apt-get -y upgrade
# sudo apt-get -y dist-upgrade # Tends to break vagrant build

# Cleanup
sudo apt-get -y autoremove
sudo apt-get -y autoclean
