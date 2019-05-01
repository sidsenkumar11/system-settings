#!/bin/bash
# Author  : Sid
# Purpose : 64-Bit Ubuntu VM Setup Script
# Date    : 05/15/2018

USERNAME=""
if [ $# == 0 ]
then
	echo "Need argument to execute"
	echo "vagrant    : Installing on a vagrant box"
	echo "<username> : Installing on a normal VM"
	echo "windows <username> : Installing on Windows Linux Subsystem."
	exit
elif [[ $1 == "windows" && $# == 1 ]]
then
	echo "Windows must be followed by username on this system."
	exit
elif [ $1 == "vagrant" ]
then
	echo "Executing as if installing on vagrant machine"
	USERNAME="$1"
elif [ $1 == "windows" ]
then
	echo "Executing as if installing on Windows Linux subsystem"
	USERNAME="$2"
else
	echo "Executing as if installing on a normal VM"
	USERNAME="$1"
fi

set -e # This stops the script if there is an error

# Update Repositories
echo ""
echo "################################################################"
echo "#################   Initial Update and Upgrade  ################"
echo "################################################################"

sudo apt-get -y update
sudo apt-get -y upgrade

if [ $1 != "vagrant" ]
then
	# Dist-upgrades break vagrant
	sudo apt-get dist-upgrade -y
fi

# Allow add-apt-repository command and to download over https
sudo apt-get -y install software-properties-common python-software-properties
sudo apt-get -y install apt-transport-https

# Ensure all sudo installed files can be read even without sudo
umask 022
echo -e "\n# Allow all users to read files but only user to write\numask 022" >> ~/.bashrc

# 32 Bit Libraries for 64 bit Machines
echo ""
echo "################################################################"
echo "##################   Installing i386 Libraries  ################"
echo "################################################################"
echo ""
sudo dpkg --add-architecture i386
sudo apt-get -y update
sudo apt-get -y install libc6:i386 libncurses5:i386 libstdc++6:i386
sudo apt-get -y install libgcc1:i386 zlib1g:i386 libglib2.0-0:i386
sudo apt-get -y install libc6-i686:i386
sudo apt-get -y install libfreetype6:i386 libexpat1:i386
sudo apt-get -y install libsm6:i386 libice6:i386 libxrender1:i386
sudo apt-get -y install libxext6:i386 libx11-6:i386 libfontconfig1:i386
sudo apt-get -y install libffi6:i386 libpcre3:i386 libuuid1:i386
sudo apt-get -y install libxau6:i386 libxcb1:i386 libx11-xcb1:i386 libxi6:i386 libxdmcp6:i386
sudo apt-get -y install libcurl3:i386 libdbus-1-3:i386 libpng12-0:i386

# These are so the 64 bit VM can build 32 bit
sudo apt-get -y install libx32gcc-4.8-dev
sudo apt-get -y install libc6-dev-i386 libc6-dbg libc-dbg:i386

echo ""
echo "################################################################"
echo "################   Installing Linux Essentials  ################"
echo "################################################################"
echo ""

sudo apt-get -y install build-essential
sudo apt-get -y install git gparted vim
sudo apt-get -y install tmux screen
sudo apt-get -y install htop
sudo apt-get -y install zip unzip rar unrar p7zip-full
sudo apt-get -y install man cmake
sudo apt-get -y install autoconf autogen libtool nasm
sudo apt-get -y install tree

# Ranger and tools that allow Ranger file previews
sudo apt-get -y install ranger caca-utils highlight atool w3m poppler-utils mediainfo

# Replace netcat-bsd with netcat-traditional
sudo apt-get -y install netcat-traditional
sudo apt-get -y remove netcat-openbsd

echo ""
echo "################################################################"
echo "#################    Programming Languages  ####################"
echo "################################################################"
echo ""

# Pip
sudo apt-get -y install python-pip
sudo apt-get -y install python3-pip
sudo -H pip install --upgrade pip
sudo -H pip3 install --upgrade pip

# Ensures pip -> pip2 -> python2 and pip3 -> python3
sudo -H python3 -m pip install -U --force-reinstall pip
sudo -H python -m pip install -U --force-reinstall pip

# Virtualenv
sudo -H pip install virtualenv

# Fix urllib3 InsecurePlatformWarning
sudo -H pip install --upgrade urllib3[secure]

# Add virtualenvwrapper script
sudo pip install virtualenvwrapper

# JDK Update:
# 	- JDK_URL = URL of the latest JDK package by viewing the source on the Oracle JDK install page
#	- JDK_NAME = Derived from URL
JDK_URL=https://download.oracle.com/otn-pub/java/jdk/12.0.1+12/69cfe15208a647278a19ef0990eea691/jdk-12.0.1_linux-x64_bin.tar.gz
JDK_NAME="jdk-12.0.1"

# Install Java
sudo mkdir /opt/java && cd /opt/java
sudo wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "$JDK_URL"
sudo tar -xzvf "$JDK_NAME"_linux-x64_bin.tar.gz

# Update alternatives for java, javac, and jar files
cd "$JDK_NAME"
sudo update-alternatives --install /usr/bin/java java /opt/java/"$JDK_NAME"/bin/java 100
sudo update-alternatives --config java
sudo update-alternatives --install /usr/bin/javac javac /opt/java/"$JDK_NAME"/bin/javac 100
sudo update-alternatives --config javac
sudo update-alternatives --install /usr/bin/jar jar /opt/java/"$JDK_NAME"/bin/jar 100
sudo update-alternatives --config jar

# Add Java environment vars to path
export JAVA_HOME=/opt/java/"$JDK_NAME"/
export JRE_HOME=/opt/java/"$JDK_NAME"/jre
export PATH=$PATH:/opt/java/"$JDK_NAME"/bin:/opt/java/"$JDK_NAME"/jre/bin

# Install golang
sudo apt-get -y install golang

# Install Ruby
sudo apt-get -y install ruby-full

# Install Scala
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
sudo apt-get update
sudo apt-get install sbt

# Install Node
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs

echo ""
echo "################################################################"
echo "##############    Pwn / Debugging / CTF Tools  #################"
echo "################################################################"
echo ""

# Make build directory
cd ~
mkdir -p .tools # -p gives no error if it already exists

# QEMU
sudo apt-get -y install qemu-kvm qemu virt-manager virt-viewer libvirt-bin

# Install binutils and binwalk
git clone https://github.com/devttys0/binwalk ~/.tools/binwalk
cd ~/.tools/binwalk
sudo apt-get -y install squashfs-tools
sudo apt-get -y install binutils python-lzma
sudo python setup.py install

# Install radare2 - needs the build file directory post-install
sudo git clone https://github.com/radare/radare2 /opt/radare2
cd /opt/radare2
sudo ./sys/install.sh

# Install r2pipe
sudo -H pip install --upgrade r2pipe

# Software Debugging
sudo apt-get -y install gdb gdb-multiarch
sudo apt-get -y install gcc-multilib
sudo apt-get -y install valgrind
sudo apt-get -y install gcc-arm-linux-gnueabihf
echo 'set auto-load safe-path /' > ~/.gdbinit # Fix warning when loading .gdbinit files

# Install Peda
git clone https://github.com/longld/peda.git ~/.peda
echo "source ~/.peda/peda.py" >> ~/.gdbinit

# Install GEF
sudo apt-get -y install python-capstone # Just installing capstone gives error when importing, need this too
sudo -H pip3 install capstone unicorn keystone-engine ropper retdec-python
# wget -q -O- https://github.com/hugsy/gef/raw/master/gef.sh | sh

# Pwntools
sudo apt-get -y install python-dev libssl-dev libffi-dev
sudo -H pip install --upgrade pwntools

# Angr
cd ~
sudo apt-get -y install virtualenvwrapper
virtualenv angr
source angr/bin/activate
pip install angr --upgrade
deactivate

# Install ROPGadget
git clone https://github.com/JonathanSalwan/ROPgadget ~/.tools/ROPgadget
cd ~/.tools/ROPgadget
sudo python setup.py install

# Install One Gadget
sudo gem install one_gadget
sudo gem install zsteg

# Install Intel PIN
sudo mkdir /opt/pin && cd /opt/pin
sudo wget http://software.intel.com/sites/landingpage/pintool/downloads/pin-2.14-71313-gcc.4.4.7-linux.tar.gz
sudo tar -xzvf pin-2.14-71313-gcc.4.4.7-linux.tar.gz
sudo rm pin-2.14-71313-gcc.4.4.7-linux.tar.gz
cd pin*
export PIN_ROOT=$PWD
export PATH=$PATH:$PIN_ROOT;

# Install rp++
cd ~/.tools
wget https://github.com/downloads/0vercl0k/rp/rp-lin-x64
sudo install -s rp-lin-x64 /usr/bin/rp++
rm rp-lin-x64

# Media Manipulation
sudo apt-get -y install foremost
sudo apt-get -y install ipython
sudo apt-get -y install silversearcher-ag

if [[ $1 != "vagrant" && $1 != "windows" ]]
then
	sudo apt-get -y install vlc gimp
fi

# RSA CTF Tool
sudo apt-get -y install libgmp3-dev libmpc-dev
cd ~
mkdir rsa
cd rsa
virtualenv venv
source venv/bin/activate
git clone https://github.com/Ganapati/RsaCtfTool.git
cd RsaCtfTool
git clone https://github.com/hellman/libnum.git
cd libnum
python setup.py install
cd ..
pip install -r requirements.txt # Fails for GMPY2
cd ..
git clone https://github.com/ius/rsatool.git
cd rsatool
python setup.py install
cd ..
pip install sympy
git clone https://github.com/rk700/attackrsa.git
cd attackrsa
python setup.py install
cd ..
deactivate

# AFL Fuzzer
mkdir ~/.tools/afl && cd ~/.tools/afl
wget http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz
tar -zxvf afl-latest.tgz
cd afl-*
make && sudo make install
cd ..
rm afl-latest.tgz

# John the Ripper setup
mkdir -p ~/.tools/john/src
sudo apt-get -y install yasm libgmp-dev libpcap-dev pkg-config libbz2-dev
sudo apt-get -y install libopenmpi-dev openmpi-bin
sudo apt-get -y install cmake bison flex libicu-dev
git clone --recursive https://github.com/teeshop/rexgen.git
cd rexgen
./install.sh

# If you have an Nvidia Graphics Card
# sudo apt-get -y install nvidia-opencl-dev

# Build jumbo bleeding from source
cd ~/.tools/john/src
git clone git://github.com/magnumripper/JohnTheRipper -b bleeding-jumbo john
cd ~/.tools/john/src/john/src
./configure --enable-mpi && make -s clean && make -sj4
sudo ln -s ~/.tools/john/src/john/run/john /usr/local/bin/john

if [ $1 != "windows" ]
then
	# Sage Math - takes a while to download - 1.6 GB
	mkdir ~/.tools/sage && cd ~/.tools/sage
	wget http://mirrors.mit.edu/sage/linux/64bit/sage-8.2-Ubuntu_16.04-x86_64.tar.bz2
	tar -xjvf *.tar.bz2
	sudo ln -s ~/.tools/sage/SageMath/sage /usr/local/bin/sage
fi

echo ""
echo "################################################################"
echo "#################  Installing Z3 Theorem #######################"
echo "################################################################"
echo ""

# This takes a while
git clone https://github.com/Z3Prover/z3.git ~/.tools/z3
cd ~/.tools/z3
sudo python scripts/mk_make.py --python
cd build
sudo make && sudo make install

if [[ $1 != "vagrant" && $1 != "windows" ]]
then
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
	# TODO: Import VSCode settings/plugins

	# Set Visual Studio Code as default text editor
	sudo update-alternatives --set editor /usr/bin/code

	# Google Chrome
	sudo apt-get -y install libxss1 libappindicator1 libindicator7 fonts-liberation
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo dpkg -i google-chrome*.deb
	sudo apt-get install -f
fi

echo ""
echo "################################################################"
echo "#################   Personal Settings Setup  ###################"
echo "################################################################"
echo ""

# Install Hexo for blog
sudo npm install -g hexo-cli

# Install powerline and tmux sensible
git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux_themepack
mkdir ~/.tmux_sensible && cd ~/.tmux_sensible
wget https://raw.githubusercontent.com/tmux-plugins/tmux-sensible/master/sensible.tmux

# Install zsh, set as default shell, then install oh-my-zsh
sudo apt-get -y install zsh

# Both of these will prompt for a password.
# Running as sudo won't help because then shell is only changed for root user.
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Need to exit zsh shell to continue
ZSH_CUSTOM="/home/$USERNAME/.oh-my-zsh/custom"

# Zsh Plugins
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Zsh Zeta theme
mkdir -p $ZSH_CUSTOM/themes
cd $ZSH_CUSTOM/themes
wget https://raw.githubusercontent.com/skylerlee/zeta-zsh-theme/master/zeta.zsh-theme

# Delete the old zshrc, we will replace with our own
sudo rm ~/.zshrc

# Personal Config Settings
sudo apt-get -y install stow
git clone https://github.com/sidsenkumar11/system-settings.git ~/.tools/system_settings
cd ~/.tools/system_settings/dotfiles
chmod +x install.sh
./install.sh

# Install Vim Plug and Vim Plugins. Need to quit to continue.
sudo apt-get -y install fonts-powerline
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -c "PlugInstall"

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
# sudo dpkg-reconfigure locales

# Update Repositories
sudo apt-get -y update
sudo apt-get -y upgrade

# Cleanup
sudo apt-get -y autoremove
sudo apt-get -y autoclean

echo ""
echo "################################################################"
echo "########################   Finished!  ##########################"
echo "################################################################"
echo ""
