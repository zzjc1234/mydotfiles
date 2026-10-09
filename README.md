# My dotfiles

This repository mirrors the current Linux/Niri desktop configuration, custom
desktop commands, and the older macOS dotfiles that are still useful.

## Layout

## Restore

The repository does not overwrite the live home directory automatically.
Review the diff first, then mirror the desired sections:

```bash
rsync -avni config/ ~/.config/
rsync -avni .local/ ~/.local/

rsync -av config/ ~/.config/
rsync -av .local/ ~/.local/
install -m 0644 zshrc ~/.zshrc
install -m 0644 zsh_plugins.txt ~/.zsh_plugins.txt
install -m 0644 p10k.zsh ~/.p10k.zsh
install -m 0644 .zshenv ~/.zshenv
```


## Waybar CFFI module

Waybar must include CFFI module support. The module also depends on GTK3 and a
compatible Niri IPC version.

## Main runtime dependencies

- Desktop: Niri, Waybar, Mako, Kitty, Rofi, Fcitx5, Hyprlock, swaybg, swayidle
- Wayland tools: grim, slurp, Swappy, wl-clipboard, cliphist
- Command-line tools: jq, fzf, ripgrep, btop, tmux, Antidote, Python 3, Rust/Cargo
- Desktop integration: NetworkManager, BlueZ, PipeWire/PulseAudio tools

`config/tmux/plugins/tpm/` is intentionally not vendored. Install TPM into
`~/.config/tmux/plugins/tpm` after restoring the tmux configuration.

## Intentionally excluded state

Raw dconf databases, Fcitx DBus/cache state, Herdr logs and sessions, editor
bytecode, timestamped backups, Cargo build output, and nested Git metadata are
not dotfiles and are ignored.

The V2Ray systemd unit references `~/.tools/proxy/config.json`; that file may
contain credentials and is intentionally not included. The Niri startup script
also contains a local Zotero path under `~/Downloads`, and Neovim references
personal Dropbox notes and locally installed language tools. Those paths need
manual setup on a fresh machine.

Two commands, `.local/bin/niri-sidebar` and
`.local/bin/niri-scratchpad.real`, are prebuilt x86-64 executables because no
matching local source checkout was found during this sync. Replace them with
native builds on another architecture.

## Acknowledgements

The legacy Yabai and skhd configurations are based on
[@Hydraallen](https://github.com/Hydraallen/yabai). The Zsh and Powerlevel10k
configuration is based on
[@daniruiz](https://github.com/daniruiz/dotfiles). The Waybar CFFI module is
based on [dev-jie-liu/waybar-niri-workspaces](https://github.com/dev-jie-liu/waybar-niri-workspaces)
with local changes.

## 外部项目依赖

以下项目不再随本仓库保存源码或机器相关二进制。`niri` 配置和本仓库的包装脚本通过 `PATH` 查找 `niri-sidebar` 与 `niri-scratchpad`；请确保 `~/.local/bin` 已加入 `PATH`。

### Waybar Niri workspaces 模块

源码：<https://github.com/zzjc1234/waybar-niri-workspaces>

```bash
git clone https://github.com/zzjc1234/waybar-niri-workspaces.git
cd waybar-niri-workspaces
cargo build --release --locked
install -Dm755 target/release/libwaybar_niri_workspaces.so \
  ~/.config/waybar/modules/libwaybar_niri_workspaces.so
```

### niri-sidebar

上游：<https://github.com/Vigintillionn/niri-sidebar>

```bash
git clone https://github.com/Vigintillionn/niri-sidebar.git
cd niri-sidebar
cargo build --release
install -Dm755 target/release/niri-sidebar ~/.local/bin/niri-sidebar
```

也可以从上游 Releases 下载与当前架构匹配的二进制，重命名为 `niri-sidebar` 后放入 `PATH`。

### niri-scratchpad

上游：<https://github.com/argosnothing/niri-scratchpad-rs>

```bash
git clone https://github.com/argosnothing/niri-scratchpad-rs.git
cd niri-scratchpad-rs
cargo build --release
install -Dm755 target/release/niri-scratchpad ~/.local/bin/niri-scratchpad
```
