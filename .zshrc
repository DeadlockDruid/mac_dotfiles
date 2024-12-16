# Initialize Starship (minimal prompt setup)
eval "$(starship init zsh)"

### Zinit Plugin Manager Setup ###
# Ensure Zinit is installed
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  echo "Installing Zinit plugin manager..."
  command mkdir -p "$HOME/.local/share/zinit" && \
  command chmod g-rwX "$HOME/.local/share/zinit" && \
  command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" || {
    echo "Zinit installation failed. Please check your network or permissions."
    return 1
  }
fi

# Source Zinit if available
if [[ -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
  source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
  autoload -Uz _zinit
  (( ${+_comps} )) && _comps[zinit]=_zinit
else
  echo "Zinit script not found. Check the installation path."
  return 1
fi

# Load Zinit annexes (required for advanced features)
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

# Load essential plugins
zinit light zsh-users/zsh-syntax-highlighting  # Syntax highlighting for commands
zinit light zsh-users/zsh-autosuggestions      # Command autosuggestions

### Environment Variables ###
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/Cellar/yvm/4.1.4/versions/v1.22.19/bin:$PATH"
export PATH="$(pyenv root)/shims:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PIPENV_PYTHON="$PYENV_ROOT/shims/python"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/Users/divyanshurathore/sessionmanager-bundle/bin:$PATH"
export LIBRARY_PATH=$LIBRARY_PATH:/opt/homebrew/opt/zstd/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/homebrew/opt/zstd/lib


### Pyenv Setup ###
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

### NVM Setup ###
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

### YVM Configuration ###
export YVM_DIR="/opt/homebrew/opt/yvm"
[ -r "$YVM_DIR/yvm.sh" ] && . "$YVM_DIR/yvm.sh"
export PATH="$PATH:$YVM_DIR/versions/v1.22.19/bin"

# Automatically switch Yarn versions
yvm use

# Automatically use Node.js version from `.nvmrc`
autoload -U add-zsh-hook
load-nvmrc() {
  if [[ -f .nvmrc ]]; then
    nvm use || nvm install
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

### Auto Commands for Specific Projects ###
auto_commands() {
  # Prevent infinite loops with a guard variable
  if [ "$AUTO_COMMANDS_RUNNING" = "true" ]; then
    return
  fi

  AUTO_COMMANDS_RUNNING="true"

  case "$PWD" in
    "/Users/divyanshurathore/rails_work/strategize/strategize_frontend")
      echo "Running commands for Strategize..."
      nvm use 20 > /dev/null 2>&1
      yvm use > /dev/null 2>&1
      ;;
    "/Users/divyanshurathore/rails_work/aspenclean-obe-rails")
      echo "Running commands for Aspen Clean..."
      nvm use 12 > /dev/null 2>&1
      yvm use > /dev/null 2>&1
      ;;
  esac

  AUTO_COMMANDS_RUNNING=""
}
chpwd_functions+=(auto_commands)
if [ -n "$PS1" ]; then
  auto_commands
fi

### FZF Setup ###
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Exclusions for FZF Commands
export FZF_EXCLUDE="'{.git,node_modules,dist,.DS_Store,vendor/cache,cache,public/packs,public/packs-test}'"

# Default commands for FZF
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude $FZF_EXCLUDE"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude $FZF_EXCLUDE"

# Use fd for path completion
_fzf_compgen_path() {
  fd --hidden --exclude $FZF_EXCLUDE . "${1:-.}"
}
_fzf_compgen_dir() {
  fd --type=d --exclude $FZF_EXCLUDE . "${1:-.}"
}

# Custom aliases for FZF
alias fzf-js="fd --type=f --extension js --hidden --exclude $FZF_EXCLUDE | fzf"
alias fzf-py="fd --type=f --extension py --hidden --exclude $FZF_EXCLUDE | fzf"
alias fzf-rb="fd --type=f --extension rb --hidden --exclude $FZF_EXCLUDE | fzf"

# FZF Color Scheme (Rose Pine Moon)
# export FZF_DEFAULT_OPTS="
#   --color=fg:#908caa,bg:#232136,hl:#ea9a97
#   --color=fg+:#e0def4,bg+:#393552,hl+:#ea9a97
#   --color=border:#44415a,header:#3e8fb0,gutter:#232136
#   --color=spinner:#f6c177,info:#9ccfd8
#   --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

# FZF Color Scheme (Catppuccin)
export FZF_DEFAULT_OPTS=" \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

# FZF Git Integration
source ~/fzf-git.sh/fzf-git.sh

# ---- Eza (better ls) -----
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# Theme for Bat
export BAT_THEME="Catppuccin Mocha"

# thefuck alias
eval $(thefuck --alias)

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"
alias cd="z"

# Alt + Left Arrow: Move to the beginning of the line
bindkey '^[[1;3D' beginning-of-line
# Alt + Right Arrow: Move to the end of the line
bindkey '^[[1;3C' end-of-line

# Alt + Shift + Left Arrow: Select from the cursor to the beginning of the line
zle_select_to_start() {
  zle beginning-of-line
  zle set-mark-command
}
zle -N zle_select_to_start
bindkey '^[[1;4D' zle_select_to_start

# Alt + Shift + Right Arrow: Select from the cursor to the end of the line
zle_select_to_end() {
  zle end-of-line
  zle set-mark-command
}
zle -N zle_select_to_end
bindkey '^[[1;4C' zle_select_to_end

# NVCHAD nvim alias
alias nvchad="NVIM_APPNAME=nvchad nvim"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
export PATH=$PATH:$HOME/go/bin

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
