Initial README
 
## Installation

- Install [Homebrew](https://brew.sh/index_de):
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

- Install [Oh My Zsh](https://ohmyz.sh):
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

- Install dependencies:
```
brew install git python python3 neovim fzf node ranger tmux tmuxinator wget ripgrep fd bazel watchman lazygit
brew install --cask docker
```

- Install plugin manager for vim if using vimscript (OLD)
```
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

- Install [Packer](https://github.com/wbthomason/packer.nvim) with lua
> Unix, Linux Installation
```
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

- Install [Tmux Plugin Manger](https://github.com/tmux-plugins/tpm) 
`prefix` + <kbd>I</kbd>
```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

- Install fonts
```
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts

git clone https://github.com/ryanoasis/nerd-fonts.git --depth 1
cd nerd-fonts
./install.sh
cd ..
rm -rf nerd-fonts
```

## Clone Repo

- Prior before clone
```
alias dotfiles='/usr/bin/git --git-dir=/$HOME/.dotfiles/ --work-tree=/$HOME'
echo ".dotfiles" >> .gitignore
```

- Clone bare repo
```
git clone --bare https://github.com/nyzn/dotfiles.git $HOME/.dotfiles
```

- Define the alias in the current shell scope:
```
alias dotfiles='/usr/bin/git --git-dir=/$HOME/.dotfiles/ --work-tree=/$HOME'
```

- Checkout actual content:
```
dotfiles checkout
```

- The step above might fail with a message like:
error: The following untracked working tree files would be overwritten by checkout:
    .bashrc
    .gitignore
Please move or remove them before you can switch branches.
Aborting

- Run this to remove error:
```
mkdir -p .dotfiles-backup && \
dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .dotfiles-backup/{}
```

- Re-run the check out if you had problems:
```
dotfiles checkout
```

- Set the flag showUntrackedFiles to no on this specific (local) repository:
```
dotfiles config --local status.showUntrackedFiles no
```

- Install plugins for vim 
>vim-plug
```
:PlugInstall
```
>packer.vim
```
:PackerSync
```

## Resource

- [Dotfiles Tutorial](https://www.atlassian.com/git/tutorials/dotfiles)
- [Plugin Manager](https://github.com/junegunn/vim-plug)
- [Packer](https://github.com/wbthomason/packer.nvim)
- [Tmux Packer]()https://github.com/tmux-plugins/tpm
