Initial README
 
## Resource

[Dotfiles Tutorial](https://www.atlassian.com/git/tutorials/dotfiles)


## Installation

- Install Homebrew:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

- Install Oh My Zsh:
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

- Install dependencies:
```
brew install git
brew install python python3 neovim fzf node ranger tmux tmuxinator
```

## Clone Repo

- Prior before clone
```
alias dotfiles='/usr/bin/git --git-dir=/$HOME/.dotfiles/ --work-tree=/$HOME'
echo ".dotfiles" >> .gitignore
```

- Clone bare repo
```
git clone --bare https://github.com/nyzn/dotfiles.git $HOME/.cfg
```

- Define the alias in the current shell scope:
```
alias dotfiles='/usr/bin/git --git-dir=/$HOME/.dotfiles/ --work-tree=/$HOME'
```

- Checkout actual content
```
dotfiles checkout
```
  
