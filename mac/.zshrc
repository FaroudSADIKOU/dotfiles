# --- Homebrew ---
eval "$(/opt/homebrew/bin/brew shellenv)"

# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git docker kubectl)

source "$ZSH/oh-my-zsh.sh"

# --- starship prompt ---
eval "$(starship init zsh)"

# --- NVM ---
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

# --- pyenv ---
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null && eval "$(pyenv init -)"

# --- asdf ---
. "$(brew --prefix asdf)/libexec/asdf.sh"

# --- direnv ---
eval "$(direnv hook zsh)"

# --- fzf key-bindings & completion ---
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# --- Android ---
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"

# Helpful aliases
alias gs='git status'
alias k='kubectl'
