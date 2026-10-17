#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-update jq
# Usage: scripts/update.sh [package...]
# Updates every package of pkgs/ that has an updateScript, or only the ones
# given, with one commit per updated package that builds.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "The working tree must be clean: each update is committed on its own." >&2
  exit 1
fi

scripts=$(nix-instantiate --eval --strict --json -E '
  let
    packages = (import ./.).packages.${builtins.currentSystem};
  in
  builtins.listToAttrs (
    map (name: {
      inherit name;
      value = builtins.tail (packages.${name}.updateScript.command or packages.${name}.updateScript);
    }) (builtins.filter (name: packages.${name} ? updateScript) (builtins.attrNames packages))
  )')

names=("$@")
[ ${#names[@]} -gt 0 ] || mapfile -t names < <(jq -r 'keys[]' <<<"$scripts")

message=$(mktemp)
trap 'rm -f "$message"' EXIT

for name in "${names[@]}"; do
  mapfile -t args < <(jq -r --arg n "$name" '.[$n][]' <<<"$scripts")
  : >"$message"
  if ! nix-update --flake --build --write-commit-message "$message" "${args[@]}" "$name"; then
    echo "failed: $name" >&2
    git checkout -- "pkgs/$name"
    continue
  fi
  if [ -s "$message" ]; then
    sed -i "1s/^$name: /chore($name): /" "$message"
    git add "pkgs/$name"
    git commit --quiet --file "$message" -- "pkgs/$name"
  fi
done
