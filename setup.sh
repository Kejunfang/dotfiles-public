#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required: https://brew.sh/" >&2
  exit 1
fi

brew bundle --file "$repo_dir/Brewfile"

conda_bin="$(brew --prefix)/Caskroom/miniconda/base/bin/conda"
if [[ ! -x "$conda_bin" ]]; then
  echo "Miniconda was installed, but conda was not found at $conda_bin" >&2
  exit 1
fi

"$conda_bin" init zsh
"$conda_bin" env update --file "$repo_dir/environment.yml"

echo
echo "Setup complete. Restart the terminal, then run: conda activate dev"
