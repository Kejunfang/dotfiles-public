#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required: https://brew.sh/" >&2
  exit 1
fi

brew bundle --file "$repo_dir/Brewfile"

tmux_config="$HOME/.tmux.conf"
if [[ ! -f "$tmux_config" ]] || ! grep -Fqx 'set -g mouse on' "$tmux_config"; then
  printf '\nset -g mouse on\n' >> "$tmux_config"
fi

while IFS= read -r extension; do
  [[ -z "$extension" ]] || code --install-extension "$extension"
done < "$repo_dir/vscode-extensions.txt"

conda_bin="$(brew --prefix)/Caskroom/miniconda/base/bin/conda"
if [[ ! -x "$conda_bin" ]]; then
  echo "Miniconda was installed, but conda was not found at $conda_bin" >&2
  exit 1
fi

"$conda_bin" init zsh
"$conda_bin" env update --file "$repo_dir/environment.yml"
"$conda_bin" run -n dev playwright install

echo
echo "Setup complete. Restart the terminal, then run: conda activate dev"
