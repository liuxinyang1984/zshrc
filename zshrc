# zshrc — 由 install.sh 同步到 ~/.config/zsh（或 --dev 时直接 source 仓库）
# 插件: ~/.local/share/zsh/plugins（install-plugins.sh），不依赖发行版包路径。

# 本文件所在目录 = 安装目录（~/.config/zsh）或开发时的仓库根
ZSHRC_HOME="${${(%):-%x}:A:h}"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# vcs_info 必须在 p10k instant prompt 之前
autoload -Uz vcs_info

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

HISTFILE="${HISTFILE:-$HOME/.histfile}"
HISTSIZE=1000
SAVEHIST=1000
bindkey -v

zstyle :compinstall filename "${ZDOTDIR:-$HOME}/.zshrc"
autoload -Uz compinit
compinit

# PATH：suckless / pipx 等
typeset -U path
path=("$HOME/.local/bin" $path)

ZSH_PLUGINS="${XDG_DATA_HOME}/zsh/plugins"
_zsh_need_plugins=0
for _p in \
  "$ZSH_PLUGINS/powerlevel10k/powerlevel10k.zsh-theme" \
  "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
do
  if [[ -r $_p ]]; then
    source "$_p"
  else
    _zsh_need_plugins=1
  fi
done
unset _p
if (( _zsh_need_plugins )); then
  print -u2 "zshrc: 缺少插件，请在仓库目录运行 ./install.sh 或 ./install-plugins.sh"
fi
unset _zsh_need_plugins

# 安装目录内公共 alias；本机私货（含 mysql）放 ~/.config/shell/local/*.alias
for f in "$ZSHRC_HOME"/alias/*.alias(N); do
  source "$f"
done
for f in "$XDG_CONFIG_HOME"/shell/local/*.alias(N); do
  source "$f"
done
unset f

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
