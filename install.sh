#!/bin/sh
# 个人安装（默认）：配置同步到 ~/.config/zsh，插件到 ~/.local/share/zsh/plugins
#   ./install.sh           # 发布到 ~/.config/zsh，~/.zshrc source 该处
#   ./install.sh --dev     # 不拷贝，~/.zshrc 直接 source 本仓库（改完即生效）
#   ./install.sh --plugins-only
# 不做系统/--system 安装。
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
INSTALL_DIR="${ZSHRC_INSTALL_DIR:-$CONFIG_HOME/zsh}"
ZSHRC_DEST="${ZDOTDIR:-$HOME}/.zshrc"

MODE=install
for arg in "$@"; do
    case "$arg" in
        --dev) MODE=dev ;;
        --plugins-only) MODE=plugins ;;
        -h|--help)
            cat <<'EOF'
用法: ./install.sh [--dev|--plugins-only]

  （默认）              插件 → ~/.local/share/zsh/plugins
                        配置 → ~/.config/zsh，~/.zshrc source 该处
  --dev                 不拷贝，~/.zshrc 直接 source 本仓库
  --plugins-only        只更新插件
  -h, --help            显示本说明

仅个人安装，无 --system。
EOF
            exit 0
            ;;
        *)
            echo "未知参数: $arg（见 ./install.sh --help）" >&2
            exit 1
            ;;
    esac
done

# shellcheck source=install-plugins.sh
. "$ROOT/install-plugins.sh"

if [ "$MODE" = plugins ]; then
    exit 0
fi

sync_config() {
    mkdir -p "$INSTALL_DIR/alias"
    cp -f "$ROOT/zshrc" "$INSTALL_DIR/zshrc"
    # 只同步仓内公共 alias，不碰 ~/.config/shell/local
    rm -f "$INSTALL_DIR/alias/"*.alias
    if [ -d "$ROOT/alias" ]; then
        for f in "$ROOT/alias/"*.alias; do
            [ -f "$f" ] || continue
            cp -f "$f" "$INSTALL_DIR/alias/"
        done
    fi
    echo "已同步配置 → $INSTALL_DIR"
}

ensure_source_line() {
    dest="$1"
    line="$2"
    if [ -L "$dest" ]; then
        echo "警告: $dest 是符号链接，将备份后改成 source 入口"
        backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
        mv "$dest" "$backup"
        echo "已备份到 $backup"
        printf '%s\n' "$line" > "$dest"
        echo "已写入 $dest"
        return
    fi
    if [ -f "$dest" ]; then
        if grep -Fq "$line" "$dest"; then
            echo "$dest 已包含正确的 source 行"
            return
        fi
        # 换掉旧的 zshrc source（仓路径或上次安装路径），避免叠两行
        tmp="${dest}.tmp.$$"
        grep -vE '^[[:space:]]*source[[:space:]].*zshrc([[:space:]]|$)' "$dest" > "$tmp" || true
        printf '\n%s\n' "$line" >> "$tmp"
        mv "$tmp" "$dest"
        echo "已更新 $dest 中的 source 行"
        return
    fi
    printf '%s\n' "$line" > "$dest"
    echo "已创建 $dest"
}

if [ "$MODE" = dev ]; then
    SOURCE_LINE="source $ROOT/zshrc"
    echo "开发模式：不拷贝，直接 source 仓库"
else
    sync_config
    SOURCE_LINE="source $INSTALL_DIR/zshrc"
fi

ensure_source_line "$ZSHRC_DEST" "$SOURCE_LINE"
echo "zshrc 安装完成。新开终端或 exec zsh。"
echo "私货放: $CONFIG_HOME/shell/local/*.alias"
