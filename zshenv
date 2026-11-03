# Alpine（及部分发行版）/etc/zsh/zshrc 会自动 source
#   $XDG_DATA_HOME/zsh/plugins/*/*.plugin.zsh
# 若不在此清空，即使用户 ~/.zshrc 为空也会加载 autosuggestions 等，
# 导致 SSH 下「假多字」且难以排查。
# 插件改由本仓 zshrc 显式 source。
zsh_plugin_dirs=()
