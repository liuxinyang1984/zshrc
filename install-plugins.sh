#!/bin/sh
# 把 p10k / 高亮 / 建议 克隆到 ~/.local/share/zsh/plugins（不依赖 apk/pacman）
set -e
PLUG="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
mkdir -p "$PLUG"

clone_or_update() {
    dest="$1"
    url="$2"
    if [ -d "$dest/.git" ]; then
        git -C "$dest" fetch --depth 1 origin
        git -C "$dest" reset --hard FETCH_HEAD
    else
        git clone --depth 1 "$url" "$dest"
    fi
}

clone_or_update "$PLUG/powerlevel10k" \
    https://github.com/romkatv/powerlevel10k.git
clone_or_update "$PLUG/zsh-syntax-highlighting" \
    https://github.com/zsh-users/zsh-syntax-highlighting.git
clone_or_update "$PLUG/zsh-autosuggestions" \
    https://github.com/zsh-users/zsh-autosuggestions.git

echo "插件已装到 $PLUG"
