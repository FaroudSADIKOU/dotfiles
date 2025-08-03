#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

###############################################################################
# Paths & helpers
###############################################################################
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
DOTFILES_DIR="${DOTFILES_DIR:-$SCRIPT_DIR}"
BREWFILE="${BREWFILE:-$DOTFILES_DIR/Brewfile}"

info() { printf "\033[1;34m==>\033[0m %s\n" "$*"; }

###############################################################################
# Sanity checks
###############################################################################
[[ -d "$DOTFILES_DIR" ]] || { echo "❌  Dotfiles dir not found: $DOTFILES_DIR"; exit 1; }
[[ -f "$BREWFILE"   ]]  || { echo "❌  Brewfile not found:    $BREWFILE";   exit 1; }

info "Using DOTFILES_DIR=$DOTFILES_DIR"
info "Using BREWFILE=$BREWFILE"

###############################################################################
# 1. Homebrew (install if missing)
###############################################################################
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$("$(brew --prefix)"/bin/brew shellenv)"   # works on Intel & Apple Silicon

###############################################################################
# 2. Brewfile
###############################################################################
info "Installing formulae & casks from Brewfile"
brew bundle --file="$BREWFILE"

###############################################################################
# 3. Oh My Zsh  (first-run only)
###############################################################################
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  info "Installing Oh My Zsh…"
  sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
fi

# Back up the template .zshrc so our symlink can replace it
if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
  mv "$HOME/.zshrc" "$HOME/.zshrc.ohmyzsh.bak"
fi

###############################################################################
# 4. Symlink dotfiles with stow  (skip .DS_Store)
###############################################################################
info "Symlinking dotfiles from $DOTFILES_DIR"
brew install stow >/dev/null 2>&1 || true
(
  cd "$DOTFILES_DIR"
  stow --target="$HOME" --ignore='.DS_Store' .
)

###############################################################################
# 5. Language runtimes  (run inside *zsh* so env/plugins are loaded)
###############################################################################
zsh -ic '
  set -e

  echo "👉  Node LTS via nvm"
  nvm install --lts
  nvm alias default "lts/*"

  echo "👉  Python 3.13.5 via pyenv"
  pyenv install -s 3.13.5
  pyenv global 3.13.5

  echo "👉  Latest Temurin 21 JDK via asdf"
  asdf plugin add java || true

  latest21=$(asdf list all java | grep "^temurin-21" | tail -1)
  echo "    selected $latest21"
  asdf install java "$latest21"

  # Try modern CLI syntax first
  if asdf set java "$latest21" >/dev/null 2>&1; then
    echo "    set java with \`asdf set\`"
  # Fallback to classic verb
  elif asdf global java "$latest21" >/dev/null 2>&1; then
    echo "    set java with \`asdf global\`"
  # Last-resort: write to ~/.tool-versions
  else
    echo \"java $latest21\" >> \"$HOME/.tool-versions\"
    echo "    wrote java version to ~/.tool-versions"
  fi
'

###############################################################################
# Done
###############################################################################
info "Bootstrap complete 🎉   Open a new terminal and start coding!"
