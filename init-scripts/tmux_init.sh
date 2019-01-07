#!/bin/bash

# Installing Zsh


# Installing Tmux
sudo apt-get update -y
sudo apt-get install --upgrade tmux

cd
git clone https://github.com/gpakosz/.tmux.git
git clone https://github.com/powerline/fonts.git

ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .

# Install fonts easy way
sudo apt-get install fonts-powerline

# Install fonts hard way
#./fonts/install.sh
#rm -rf fonts

# Install Tmux Plugin Manager

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

cat <<EOT >> .tmux.conf.local
# Tmux Plugin Manager

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Other examples:
# set -g @plugin 'github_username/plugin_name'
# set -g @plugin 'git@github.com/user/plugin'
# set -g @plugin 'git@bitbucket.com/user/plugin'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run -b '~/.tmux/plugins/tpm/tpm'
EOT

# Nord Tmux Theme
cat <<EOT >> .tmux.conf.local
set -g @plugin 'tmux-plugins/tmux-prefix-highlight'
set -g @plugin 'sei40kr/tmux-onedark'
set -g @plugin 'arcticicestudio/nord-tmux'
EOT


wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
mv PowerlineSymbols.otf ~/.local/share/fonts/

sudo fc-cache -vf ~/.local/share/fonts/
mv 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/
