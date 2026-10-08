# zshrc

轻量 zsh：Powerlevel10k（含 instant prompt）、语法高亮、autosuggestions。

仓库与正在使用的配置分开：默认把配置发布到 `~/.config/zsh`，插件装到 `~/.local/share/zsh/plugins`。仅支持个人安装（无 `--system`）。

## 依赖

只要 `zsh` 和 `git`。GitHub 慢可先 `proxyon`。

Arch：`sudo pacman -S zsh git`  
Alpine：`doas apk add zsh git`

## 安装

```bash
git clone git@github.com:liuxinyang1984/zshrc.git ~/git/zshrc
~/git/zshrc/install.sh
```

默认会：

1. clone/更新三个插件 → `~/.local/share/zsh/plugins`
2. 拷贝 `zshrc` + `alias/` → `~/.config/zsh`（覆盖公共部分，不碰 local）
3. 保证 `~/.zshrc` 有一行 `source ~/.config/zsh/zshrc`（旧 symlink 会先备份；旧的 source 行会替换）

```bash
./install.sh --dev           # 不拷贝，~/.zshrc 直接 source 本仓库（改完即生效）
./install.sh --plugins-only  # 只更新插件
./install-plugins.sh         # 同上
```

改仓库后要让日常 shell 吃到新配置，再跑一次 `./install.sh`（非 `--dev`）。

已有 `~/.p10k.zsh` 会继续用。没有则启动 zsh 后执行 `p10k configure`。

dotfiles 登记 submodule 之后：`~/git/dotfiles/install.sh zsh` 会调用本仓 `install.sh`。

## alias

仓内 `alias/*.alias` 安装时同步到 `~/.config/zsh/alias/`。mysql、带密码或内网主机放到：

```text
~/.config/shell/local/*.alias
```

该目录不进本仓，也不会被 `install.sh` 覆盖。

## 本机 PATH / API key

不要写进仓内 `zshrc`。放 `~/.config/shell/local/`。
