#!/bin/sh
# 个人安装：配置默认 symlink 到本仓；插件 → ~/.local/share/zsh/plugins
#   ./install.sh              # 默认：~/.config/zsh → 本仓，~/.zshrc source 该处
#   ./install.sh --copy       # 拷贝配置到 ~/.config/zsh
#   ./install.sh --dev        # 同默认（兼容旧用法）
#   ./install.sh --plugins-only
# 不做系统/--system 安装。
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
INSTALL_DIR="${ZSHRC_INSTALL_DIR:-$CONFIG_HOME/zsh}"
ZSHRC_DEST="${ZDOTDIR:-$HOME}/.zshrc"

MODE=link
for arg in "$@"; do
	case "$arg" in
	--copy) MODE=copy ;;
	--dev) MODE=link ;;
	--plugins-only) MODE=plugins ;;
	-h|--help)
		cat <<'EOF'
用法: ./install.sh [--copy|--dev|--plugins-only]

  （默认）              插件 → ~/.local/share/zsh/plugins
                        ~/.config/zsh → symlink 本仓库，~/.zshrc source 该处
  --copy                拷贝配置到 ~/.config/zsh（不链）
  --dev                 同默认（兼容）
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

sync_config_copy() {
	mkdir -p "$INSTALL_DIR/alias"
	# 若原先是指向本仓的 symlink，先拆掉再拷
	if [ -L "$INSTALL_DIR" ]; then
		rm -f "$INSTALL_DIR"
		mkdir -p "$INSTALL_DIR/alias"
	fi
	cp -f "$ROOT/zshrc" "$INSTALL_DIR/zshrc"
	rm -f "$INSTALL_DIR/alias/"*.alias
	if [ -d "$ROOT/alias" ]; then
		for f in "$ROOT/alias/"*.alias; do
			[ -f "$f" ] || continue
			cp -f "$f" "$INSTALL_DIR/alias/"
		done
	fi
	echo "已拷贝配置 → $INSTALL_DIR"
}

sync_config_link() {
	mkdir -p "$(dirname "$INSTALL_DIR")"
	if [ -L "$INSTALL_DIR" ]; then
		cur="$(readlink "$INSTALL_DIR")"
		if [ "$cur" = "$ROOT" ]; then
			echo "已正确链接: $INSTALL_DIR → $ROOT"
			return
		fi
		ln -sfn "$ROOT" "$INSTALL_DIR"
		echo "已更新符号链接 $INSTALL_DIR → $ROOT（原: $cur）"
		return
	fi
	if [ -e "$INSTALL_DIR" ]; then
		backup="${INSTALL_DIR}.backup.$(date +%Y%m%d%H%M%S)"
		mv "$INSTALL_DIR" "$backup"
		echo "已备份 $INSTALL_DIR → $backup"
	fi
	ln -sfn "$ROOT" "$INSTALL_DIR"
	echo "symlink $INSTALL_DIR → $ROOT"
}

ensure_source_line() {
	dest="$1"
	line="$2"
	if [ -L "$dest" ]; then
		echo "警告: $dest 是符号链接，将备份后改成 source 入口"
		backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
		mv "$dest" "$backup"
		echo "已备份到 $backup"
		printf '%s\n' "$line" >"$dest"
		echo "已写入 $dest"
		return
	fi
	if [ -f "$dest" ]; then
		if grep -Fq "$line" "$dest"; then
			echo "$dest 已包含正确的 source 行"
			return
		fi
		tmp="${dest}.tmp.$$"
		grep -vE '^[[:space:]]*source[[:space:]].*zshrc([[:space:]]|$)' "$dest" >"$tmp" || true
		printf '\n%s\n' "$line" >>"$tmp"
		mv "$tmp" "$dest"
		echo "已更新 $dest 中的 source 行"
		return
	fi
	printf '%s\n' "$line" >"$dest"
	echo "已创建 $dest"
}

if [ "$MODE" = copy ]; then
	sync_config_copy
else
	sync_config_link
fi

SOURCE_LINE="source $INSTALL_DIR/zshrc"
ensure_source_line "$ZSHRC_DEST" "$SOURCE_LINE"

# Alpine /etc/zsh/zshrc 自动加载 plugins 目录；必须用 ~/.zshenv 清空 zsh_plugin_dirs
ZSHENV_DEST="${ZDOTDIR:-$HOME}/.zshenv"
ZSHENV_SRC="$ROOT/zshenv"
if [ -f "$ZSHENV_SRC" ]; then
	if [ -L "$ZSHENV_DEST" ] || [ ! -e "$ZSHENV_DEST" ]; then
		ln -sfn "$ZSHENV_SRC" "$ZSHENV_DEST"
		echo "zshenv → $ZSHENV_DEST（禁用 Alpine 自动插件）"
	elif ! grep -q 'zsh_plugin_dirs=()' "$ZSHENV_DEST" 2>/dev/null; then
		printf '\n# from vendor/zshrc\n' >>"$ZSHENV_DEST"
		cat "$ZSHENV_SRC" >>"$ZSHENV_DEST"
		echo "已追加 zsh_plugin_dirs=() → $ZSHENV_DEST"
	else
		echo "$ZSHENV_DEST 已含 zsh_plugin_dirs=()"
	fi
fi

echo "zshrc 安装完成。新开终端或 exec zsh。"
echo "私货放: $CONFIG_HOME/shell/local/*.alias"