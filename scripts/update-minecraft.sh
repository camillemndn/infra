#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash git nix cacert
#
# update-minecraft.sh — regenerate patches/nix-minecraft/update.diff for the
#                       nix-minecraft revision pinned in lon.lock.
#
#   lon update nix-minecraft
#   ./scripts/update-minecraft.sh
#
# The pinned source is copied to a scratch git tree and every
# pkgs/*/update.py of nix-minecraft is run in it, the way its own CI does.
# The resulting diff of the lock files becomes update.diff. The other diffs in
# patches/nix-minecraft/ are hand-written and left alone; the script only
# checks that they still apply on top.
#
# The updaters run against the nixpkgs pinned by lon, not the channel.
#
#   ./scripts/update-minecraft.sh /tmp/update.diff   # write somewhere else

set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
patches=$root/patches/nix-minecraft
out=${1:-$patches/update.diff}

pinned() {
  nix-instantiate --eval --json -E "(import $root/lon.nix).$1" | tr -d '"'
}

src=$(pinned nix-minecraft)
nixpkgs=$(pinned nixpkgs)

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

cp -r "$src" "$work/nix-minecraft"
chmod -R u+w "$work/nix-minecraft"
cd "$work/nix-minecraft"

git() { command git -c user.name=update -c user.email=update@localhost "$@"; }
git init -q
git add -A
git commit -qm pinned

# A shellHook exported by an enclosing dev shell would otherwise run inside
# every updater's nix-shell, in this tree.
unset shellHook

for script in pkgs/*/update.py; do
  echo ">>> $script" >&2
  chmod +x "$script"
  NIX_PATH=nixpkgs=$nixpkgs "./$script"
done

git add -- 'pkgs/*.json'
git checkout -q -- .
git clean -fdq
git diff --cached > "$work/update.diff"

for patch in "$patches"/*.diff "$patches"/*.patch; do
  [ -e "$patch" ] && [ "$(basename "$patch")" != update.diff ] || continue
  git apply --check "$patch" || {
    echo "$patch no longer applies on the updated tree" >&2
    exit 1
  }
done

mv "$work/update.diff" "$out"
git diff --cached --stat >&2
echo "wrote $out" >&2
