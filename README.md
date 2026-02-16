# dotfiles

Minimal dotfiles for Linux, macOS, and WSL.

## Install

```sh
git clone https://github.com/jcbpl/dotfiles ~/.dotfiles
cd ~/.dotfiles
./setup.sh      # auth, identity, install
```

### macOS

macOS ships bash 3.2 (2007). Install a current version before running setup:

```sh
brew bundle           # install bash, completions, gh
./shell.sh            # set Homebrew bash as login shell
# restart your terminal
./setup.sh            # auth, identity, install
```

## What each script does

**`setup.sh`** -- one-time setup:
- Authenticates with GitHub via `gh` (also configures git credentials)
- Sets git name/email from your GitHub profile
- Runs `install.sh` automatically

**`install.sh`** -- wires dotfiles into your shell:
- Adds `[include]` to `~/.gitconfig` pointing at the dotfiles gitconfig
- Sets global gitignore
- Appends source lines to `~/.bashrc` and `~/.tmux.conf`

All files stay owned by the system -- tools like `gh` can write to
`~/.gitconfig` without polluting the repo.

**`shell.sh`** (macOS only) -- sets Homebrew's bash as your login shell.

## Local overrides

- `~/.bashrc.local` -- sourced at end of bashrc (secrets, machine-specific config)
- `~/.gitconfig` -- the system file; `install.sh` adds an include, everything
  else (identity, credentials, machine-specific settings) lives here naturally

## Tool integrations

- **[mise](https://mise.jdx.dev/)** -- activated automatically if installed

## WSL

On WSL, the bashrc automatically:
- Sets `EDITOR` to `code --wait`
- Sets `BROWSER` to `wslview` for opening URLs in Windows
- Adds `pbcopy`/`pbpaste` aliases via `clip.exe`/`powershell.exe`

To keep your PATH clean, add to `/etc/wsl.conf`:

```ini
[interop]
appendWindowsPath = false
```

Then add back only what you need (e.g. VS Code) in `~/.bashrc.local`:

```bash
export PATH="$PATH:/mnt/c/Users/YOU/AppData/Local/Programs/Microsoft VS Code/bin"
```
