# --- Zinit bootstrap ---
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  command mkdir -p "$HOME/.local/share/zinit" &&
  command chmod g-rwX "$HOME/.local/share/zinit" &&
  command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" || return 1
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh" || return 1
autoload -Uz _zinit; (( ${+_comps} )) && _comps[zinit]=_zinit

# --- mise (language/tool versions) ---
# Must be loaded early so shims are available before you call node/ruby/python, etc.

# --- Paths & toolchains (dedup via zsh arrays) ---
typeset -U path PATH
path=(
  $HOME/.local/share/nvim/lazy-rocks/hererocks/bin
  $HOME/.local/bin
  $HOME/.deno/bin
  $HOME/.lmstudio/bin
  $HOME/go/bin
  $HOME/.cargo/bin

  /opt/homebrew/opt/openjdk/bin
  /opt/homebrew/opt/openssl@3/bin
  /opt/homebrew/opt/libpq/bin
  /opt/homebrew/opt/llvm/bin
  /opt/codeql
  /Users/divyanshurathore/sessionmanager-bundle/bin

  /opt/homebrew/bin
  /opt/homebrew/sbin
  /usr/local/bin

  # ✅ never drop system paths
  /usr/bin
  /bin
  /usr/sbin
  /sbin
)
export PATH=${(j/:/)path}

# --- mise (language/tool versions) ---
# Keep after PATH rebuild so mise can manage PATH in this shell.
eval "$(mise activate zsh)"

# Compiler/linker flags (merged, unique)
export PKG_CONFIG_PATH="/opt/homebrew/opt/libpq/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib -L/opt/homebrew/opt/libpq/lib${LDFLAGS:+ $LDFLAGS}"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include -I/opt/homebrew/opt/libpq/include${CPPFLAGS:+ $CPPFLAGS}"

# Optional libs
export LIBRARY_PATH=${LIBRARY_PATH:+$LIBRARY_PATH:}/opt/homebrew/opt/zstd/lib
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}/opt/homebrew/opt/zstd/lib


# --- zinit plugins ---
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

# Load essentials (autosuggestions BEFORE syntax-highlighting)
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

# --- FZF & fd setup ---
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
FZF_EXCLUDES=(.git node_modules dist .DS_Store vendor/cache cache public/packs public/packs-test)
_fd_excludes() { printf ' --exclude %q' "${FZF_EXCLUDES[@]}"; }

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix$(_fd_excludes)"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --strip-cwd-prefix$(_fd_excludes)"

_fzf_compgen_path() { fd --hidden$(_fd_excludes) . "${1:-.}"; }
_fzf_compgen_dir()  { fd --type d$(_fd_excludes) . "${1:-.}"; }

# FZF look (Catppuccin)
export FZF_DEFAULT_OPTS=" \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

# fzf-git integration (guarded)
[[ -f ~/fzf-git.sh/fzf-git.sh ]] && source ~/fzf-git.sh/fzf-git.sh

# Eza (better ls) and previews
alias ls="eza --color=always --long --git --icons=always --no-time --no-user --no-permissions"
show_file_or_dir_preview='if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Per-command fzf completion previews
_fzf_comprun() {
  local command=$1
  shift
  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"                           "$@" ;;
    ssh)          fzf --preview 'dig {}'                                    "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview"                 "$@" ;;
  esac
}

# Bat theme
export BAT_THEME="Catppuccin Mocha"

# thefuck (lighter alias)
eval "$(thefuck --alias fuck)"

# Zoxide (no cd alias)
eval "$(zoxide init zsh)"

# --- Keybindings (fixed selection) ---
bindkey '^[[1;3D' beginning-of-line   # Alt+Left -> BOL
bindkey '^[[1;3C' end-of-line         # Alt+Right -> EOL
zle_select_to_start() { zle set-mark-command; zle beginning-of-line; }
zle_select_to_end()   { zle set-mark-command; zle end-of-line; }
zle -N zle_select_to_start; bindkey '^[[1;4D' zle_select_to_start
zle -N zle_select_to_end;   bindkey '^[[1;4C' zle_select_to_end

# --- Aliases ---
alias nvchad="NVIM_APPNAME=nvchad nvim"

# --- Secrets (not committed) ---
[[ -f ~/.zsh_secrets ]] && source ~/.zsh_secrets

# --- Starship (prompt) - keep last ---
eval "$(starship init zsh)"
