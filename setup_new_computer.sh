#!/bin/bash

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

check_and_link () {
    ORIGIN=$1
    DESTINATION=$2

    if [ ! -L ~/${DESTINATION} ]; then
        echo "LINK: ~/${DESTINATION} ✅"
        ln -s ${BASEDIR}/${ORIGIN} ~/${DESTINATION}
    else
        echo "LINK: ~/${DESTINATION} ✘"
    fi
}

check_and_copy () {
    ORIGIN=$1
    DESTINATION=$2

    if [ ! -f ~/${DESTINATION} ]; then
        echo "COPY: ~/${DESTINATION} ✅"
        cp ${BASEDIR}/${ORIGIN} ~/${DESTINATION}
    else
        echo "COPY: ~/${DESTINATION} ✘"
    fi
}

########################################
############# BOOTSTRAPING #############
########################################

echo "# Installing homebrew..."
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install brew tools
brew install zsh
brew install wget
brew install pyenv
brew install pyenv-virtualenv

pyenv install 3.7.6
pyenv global 3.7.6

echo "# Installing Powerline fonts..."
# clone
git clone https://github.com/powerline/fonts.git --depth=1
# install
cd fonts
./install.sh
# clean-up
cd ..
rm -rf fonts

echo "# Installing Oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "# Installing zsh-autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo "# Installing fast-syntax-highlighting..."
git clone https://github.com/zdharma/fast-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting

##### K8s #####
echo "Installing kubectl"
brew install kubectl

echo "Installing kubens and kubectx"
brew install kubectx

#### AWS ####
echo "Installing assume-role"
brew install remind101/formulae/assume-role

####################################################
############ LINKS AND CUSTOM SETTINGS #############
####################################################

# LINK .vimrc
check_and_link "vimrc" ".vimrc"

# LINK .gitconfig
check_and_link "gitconfig" ".gitconfig"

# LINK .gitignore_global
check_and_link "gitignore_global" ".gitignore_global"

# LINK .gitconfig
check_and_link "oh-my-zsh-themes/agnoster-carlos.zsh-theme" ".oh-my-zsh/custom/themes/agnoster-carlos.zsh-theme"

# MKDR .ssh/
mkdir -p ~/.ssh
# COPY .ssh/config
check_and_copy "ssh/config" ".ssh/config"

echo "Changing default shell to zsh"
echo $(which zsh) | sudo tee -a /etc/shells
chsh -s $(which zsh)

# LINK .zshrc
check_and_link "zshrc" ".zshrc"


################ POST-INSTALL NOTES ################

echo "Remember to install AWS CLI in a new session with: "
echo "pip3 install awscli --upgrade --user"

echo "____________________"
echo "____________________"
echo "______FINISHED______"
echo "____________________"
echo "____________________"
