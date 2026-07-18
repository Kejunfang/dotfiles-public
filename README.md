# Hill's dotfiles

Development tools and setup notes for macOS on Apple Silicon.

## Before installation

This setup expects:

- An Apple Silicon Mac running macOS.
- An administrator account, because macOS may request a password or permission.
- An internet connection.
- Apple's Command Line Tools.
- [Homebrew](https://brew.sh/).
- This repository cloned to the Mac.

Install the Command Line Tools first:

```bash
xcode-select --install
```

Then install Homebrew with the command shown on the official
[Homebrew website](https://brew.sh/). Homebrew must be available before running
`setup.sh` because the script uses it to install everything in `Brewfile`.

## One-command setup

From this repository, run:

```bash
./setup.sh
```

The script:

1. Installs or updates the tools and applications declared in `Brewfile`.
2. Installs the Visual Studio Code extensions in `vscode-extensions.txt`.
3. Initializes Conda for Zsh.
4. Creates or updates the `dev` Conda environment from `environment.yml`.
5. Installs the Playwright browsers used by the Python environment.

It can be run again. The Conda update does not prune packages that exist only
on the current machine.

After it finishes, restart the terminal and activate the environment:

```bash
conda activate dev
```

## What gets installed

`Brewfile` is the source of truth for this list.

### Command-line tools

- Shell and terminal workflow: tmux, fzf.
- Editing and search: Neovim, ripgrep, fd, tree-sitter.
- Development: Git, GitHub CLI, Node.js, OpenJDK, CMake, pipx.
- Media, archives, and documents: FFmpeg, p7zip, Pandoc.
- Downloads: curl, wget.

### Applications

- Terminals and editors: Ghostty, Visual Studio Code.
- Browsers: Google Chrome, Zen Browser.
- AI tools: Claude Code, Codex, [LM Studio](https://lmstudio.ai/).
- Productivity: Raycast, Numi, Obsidian.
- Utilities: Karabiner-Elements.
- Communication: Discord.
- Python environment manager: Miniconda.

The VS Code application and the extensions listed in `vscode-extensions.txt` are
installed automatically. Application login, settings, shortcuts, macOS
permissions, and cloud synchronization are not configured automatically.

### Java

OpenJDK is installed automatically. Confirm that macOS can find it:

```bash
java -version
/usr/libexec/java_home
```

If `/usr/libexec/java_home` cannot find the Homebrew JDK, register it once:

```bash
sudo ln -sfn "$(brew --prefix openjdk)/libexec/openjdk.jdk" \
  /Library/Java/JavaVirtualMachines/openjdk.jdk
```

## Manual setup

### Git identity

Git is installed automatically, but the user identity is personal and remains
manual:

```bash
git config --global user.name "hillzhang"
git config --global user.email "vezq52431821z@gmail.com"
git config --global --list
```

To remove an incorrect value:

```bash
git config --global --unset-all user.name
git config --global --unset-all user.email
```

### Browsers

- Use Chrome as the main browser.
- Use Zen Browser for searching.
- Sign in and configure browser synchronization manually.

### Raycast

Raycast is installed automatically. See the [Raycast website](https://www.raycast.com/)
for account and extension information.

Application shortcuts:

| Shortcut | Action |
| --- | --- |
| `cmd + opt + shift + esc` | Open Raycast |
| `cmd + shift + \` | Web browser |
| `cmd + opt + shift + t` | Terminal |
| `cmd + opt + shift + d` | Discord |
| `cmd + opt + shift + n` | Notes |
| `cmd + opt + shift + r` | Reminders |
| `cmd + opt + shift + c` | Calendar |
| `cmd + opt + shift + f` | Finder |
| `cmd + opt + shift + m` | Music |

Window management shortcuts:

| Shortcut | Action |
| --- | --- |
| `cmd + shift + /` | Almost maximize |
| `cmd + shift + =` | Maximize |
| `cmd + shift + -` | Reasonable size |

### Karabiner-Elements

Karabiner-Elements is installed automatically, but macOS permissions and key
mappings must be enabled manually:

1. Map Caps Lock to Left Control.
2. Open [Karabiner complex modifications](https://ke-complex-modifications.pqrs.org/).
3. Enable the Vim-style Escape mapping.
4. Enable the Vi-style arrow mapping for `fn + h/j/k/l`.

### Terminal prompt

Ghostty is installed automatically. Oh My Zsh and Powerlevel10k are not yet
managed by `setup.sh`.

1. Install [Oh My Zsh](https://ohmyz.sh/#install).
2. Install Powerlevel10k:

```bash
git clone https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
```

3. Set the theme in `~/.zshrc`:

```bash
ZSH_THEME="powerlevel10k/powerlevel10k"
```

4. Reload Zsh and follow the prompt configuration:

```bash
exec zsh
p10k configure
```

### Neovim

Neovim and its command-line dependencies are installed automatically. The
current LazyVim configuration is not yet copied by `setup.sh`.

Back up an existing Neovim installation before replacing its configuration:

```bash
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null
mv ~/.local/state/nvim ~/.local/state/nvim.bak 2>/dev/null
mv ~/.cache/nvim ~/.cache/nvim.bak 2>/dev/null
```

Install the [LazyVim starter](https://github.com/LazyVim/starter):

```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

Current preferences:

- Colorscheme: `catppuccin-mocha`.
- In Neo-tree, press `shift + h` to show hidden files.
- Use the LazyVim `fzf-lua` extra for file search.
- Configure `fzf-lua` with `hidden = true` to include dotfiles.
- Configure `no_ignore = true` only when files ignored by `.gitignore` should
  also appear.

## Conda

Miniconda is installed automatically through Homebrew. On this Apple Silicon
Mac, Conda is located under `/opt/homebrew/Caskroom/miniconda/base`.

`setup.sh` runs `conda init zsh` and creates or updates the environment declared
in `environment.yml`. The current `dev` environment uses Python 3.12 and includes
data science, notebook, formatting, computer vision, and browser automation
packages. It also downloads the Chromium, Firefox, and WebKit browser binaries
required by Playwright.

Do not install project dependencies into `base`. Homebrew can treat its managed
Miniconda base directory as read-only, and separate environments are easier to
reproduce or remove.

### Daily commands

```bash
conda activate dev         # enter the environment
conda deactivate           # leave the environment
conda list                 # show installed packages
conda env list             # show all environments
conda update --all         # update the active environment
conda env remove -n dev    # delete the dev environment
```

To stop Conda from activating `base` when a terminal opens:

```bash
conda config --set auto_activate_base false
```

After intentionally adding a direct dependency, update `environment.yml`. A
portable list of explicitly requested Conda packages can be inspected with:

```bash
conda env export -n dev --from-history
```

Do not replace `environment.yml` blindly with a full export. Full exports contain
platform-specific transitive dependencies and can contain a local `prefix` path.
Packages installed with pip are not included by `--from-history`, so keep those
under the `pip:` section manually.

## AI resources

The AI applications are installed automatically. These reference links remain
manual because they are libraries or reading material rather than applications:

1. [Anthropic skills library](https://github.com/anthropics/skills)
2. [Andrej Karpathy skills](https://github.com/multica-ai/andrej-karpathy-skills)
3. [Humanizer](https://github.com/blader/humanizer.git)
4. [Idea of llm-wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)

## Reference videos

1. [Development setup from devaslife](https://www.youtube.com/watch?v=RNqDkF17ogY&list=LL&index=9)
2. [Git tutorial](https://www.youtube.com/watch?v=FKXRiAiQFiY&list=LL)
3. [Git concepts](https://www.youtube.com/watch?v=bWUUHBVg-7E)
4. [Improve the terminal workflow](https://www.youtube.com/watch?v=CF1tMjvHDRA&t=340s)
