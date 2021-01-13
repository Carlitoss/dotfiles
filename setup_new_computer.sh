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

echo "# Installing x86_64 homebrew"
arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "# Installing homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> ~/.zprofile
eval $(/opt/homebrew/bin/brew shellenv)

echo 'set -gx LDFLAGS -L(xcrun --show-sdk-path)/usr/lib -Lbrew --prefix bzip2/lib' >> ~/.zprofile
echo 'set -gx CFLAGS -L(xcrun --show-sdk-path)/usr/lib -Lbrew --prefix bzip2/lib' >> ~/.zprofile


# Temporary homebrew alias (saved later on in .zshrc)
alias ibrew='arch -x86_64 /usr/local/bin/brew'
alias mbrew='arch -arm64e /opt/homebrew/bin/brew'

# Install brew tools
mbrew install zsh
mbrew install wget
mbrew install pyenv
mbrew install pyenv-virtualenv
mbrew install asdf
mbrew install gnupg


## Python ##
# https://github.com/pyenv/pyenv/issues/1643

mbrew install zlib
mbrew install sqlite
mbrew install bzip2
mbrew install libiconv
mbrew install libzip

LDFLAGS="-L$(brew --prefix zlib)/lib -L$(brew --prefix bzip2)/lib" pyenv install 3.7.9
pyenv global 3.7.9

echo "# Installing Powerline fonts..."
# clone
git clone https://github.com/powerline/fonts.git --depth=1
# install
cd fonts
./install.sh
# clean-up
cd ..
rm -rf fonts

cp -R ./fonts ~/Library/Fonts

echo "# Installing Oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "# Installing zsh-autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo "# Installing fast-syntax-highlighting..."
git clone https://github.com/zdharma/fast-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting

echo "# Installing powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

##### K8s #####
echo "Installing kubectl"
ibrew install kubectl

echo "Installing kubens and kubectx"
ibrew install kubectx

#### AWS ####
echo "Installing AWS CLI V2..."
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
rm -rf AWSCLIV2.pkg

echo "AWS IAM authenticator (K8s)"
brew install aws-iam-authenticator

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

# LINK .p10k.zsh
check_and_link "p10k.zsh" ".p10k.zsh"


################ POST-INSTALL NOTES ################

echo "____________________"
echo "____________________"
echo "______FINISHED______"
echo "____________________"
echo "____________________"
