#!/usr/bin/env bash
# Installs and tests formulas from this checkout with Homebrew, as a user would after
# `brew tap mattoddie/tap`. Used by CI on macOS and Linux.
#
# Usage: scripts/test-formulas.sh [formula ...]   (default: every formula in Formula/)
set -euo pipefail

cd "$(dirname "$0")/.."

# GitHub's Linux runners have Homebrew installed but not on the PATH.
if ! command -v brew >/dev/null && [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_NO_ANALYTICS=1

formulas=("$@")
if [[ ${#formulas[@]} -eq 0 ]]; then
  for f in Formula/*.rb; do [[ -e "$f" ]] && formulas+=("$(basename "$f" .rb)"); done
fi
if [[ ${#formulas[@]} -eq 0 ]]; then
  echo "No formulas to test."
  exit 0
fi

# Tap this checkout, including uncommitted formulas, under the real tap name.
tap_dir="$(brew --repository)/Library/Taps/mattoddie/homebrew-tap"
rm -rf "$tap_dir"
mkdir -p "$(dirname "$tap_dir")"
cp -R . "$tap_dir"
git -C "$tap_dir" add -A >/dev/null
git -C "$tap_dir" -c user.name=ci -c user.email=ci@localhost commit -qm "test" --allow-empty
# Homebrew 6 refuses formulas from taps that haven't been trusted (https://docs.brew.sh/Tap-Trust).
brew trust mattoddie/tap

for f in "${formulas[@]}"; do
  echo "::group::$f"
  brew style "mattoddie/tap/$f"
  brew audit --strict "mattoddie/tap/$f"
  brew install "mattoddie/tap/$f"
  brew test "mattoddie/tap/$f"
  brew uninstall "mattoddie/tap/$f"
  echo "::endgroup::"
done
