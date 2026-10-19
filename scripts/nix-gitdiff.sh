#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-diff dix
# Compares a Nix attribute between two revisions of its git repository.
# See `scripts/nix-gitdiff.sh --help`.
set -euo pipefail

usage() {
  cat <<EOF
Usage: ${0##*/} [OPTIONS] FLAKE#ATTR [OLD [NEW]]
       ${0##*/} [OPTIONS] -f FILE ATTR [OLD [NEW]]

Compares an attribute of a local flake or Nix file, named as \`nix build\` names
it, between two revisions of its git repository.

  OLD             revision to compare from (default: HEAD)
  NEW             revision to compare to (default: the working tree)

Options:
  -c, --closure   compare closures with dix, which builds both sides,
                  instead of derivations with nix-diff
  -f, --file FILE take ATTR from FILE instead of a flake
  -h, --help      show this help

Examples:
  ${0##*/} .#nixosConfigurations.radiogaga.config.system.build.toplevel
  ${0##*/} -c -f . nixosConfigurations.radiogaga.config.system.build.toplevel HEAD~3 HEAD
EOF
}

if [[ -t 2 ]]; then
  log() { printf '\e[1;34m::\e[0m %s\n' "$*" >&2; }
  die() { printf '\e[1;31merror:\e[0m %s\n' "$*" >&2; exit 1; }
else
  log() { printf ':: %s\n' "$*" >&2; }
  die() { printf 'error: %s\n' "$*" >&2; exit 1; }
fi

diff=nix-diff file='' args=()
while (($#)); do
  case $1 in
    -h | --help) usage; exit 0 ;;
    -c | --closure) diff=dix ;;
    -f | --file) (($# > 1)) || die "$1 needs a FILE"; file=$2; shift ;;
    --) shift; args+=("$@"); break ;;
    -*) die "unknown option $1 (see --help)" ;;
    *) args+=("$1") ;;
  esac
  shift
done
((${#args[@]} >= 1 && ${#args[@]} <= 3)) || { usage >&2; exit 1; }

if [[ $file ]]; then
  src=$file attr=${args[0]}
else
  [[ ${args[0]} == *#* ]] || die "expected FLAKE#ATTR, got ${args[0]} (or use -f FILE)"
  src=${args[0]%%#*} attr=${args[0]#*#}
fi
[[ $attr ]] || die "empty attribute path"

[[ -e ${src:-.} ]] || die "no such file or directory: $src"
src=$(realpath "${src:-.}")
dir=$src
[[ -d $dir ]] || dir=$(dirname "$src")
root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || die "$src is not in a git repository"
rel=$(realpath --relative-to="$root" "$src")

# rev REV: the commit REV names, or nothing for the working tree.
rev() {
  [[ -z $1 ]] || git -C "$root" rev-parse -q --verify "$1^{commit}" || die "unknown revision $1"
}

# describe REV SHA: a one-line description of a side, for the logs.
describe() {
  if [[ $2 ]]; then
    git -C "$root" log -1 --format="$1 (%h %s)" "$2"
  elif [[ $(git -C "$root" status --porcelain) ]]; then
    echo "working tree (uncommitted changes)"
  else
    echo "working tree (clean)"
  fi
}

if [[ $diff == dix ]]; then
  verb=building
  flake() { nix build --no-link --print-out-paths "$1#$attr"; }
  legacy() { nix-build --no-out-link "$1" -A "$attr"; }
else
  verb=evaluating
  flake() { nix eval --raw "$1#$attr.drvPath"; }
  legacy() { nix-instantiate "$1" -A "$attr"; }
fi

tmp=$(mktemp -d)
cleanup() {
  for t in old new; do
    git -C "$root" worktree remove --force "$tmp/$t" 2>/dev/null || true
  done
  rm -rf "$tmp"
}
trap cleanup EXIT

# get NAME SHA: the path to compare for SHA, or for the working tree if empty.
get() {
  if [[ -z $2 ]]; then
    if [[ $file ]]; then legacy "$src"; else flake "$src"; fi
  elif [[ $file ]]; then
    git -C "$root" worktree add -q --detach "$tmp/$1" "$2"
    legacy "$tmp/$1/$rel"
  else
    local ref="git+file://$root?rev=$2"
    [[ $rel != . ]] && ref+="&dir=$rel"
    flake "$ref"
  fi
}

old_rev=${args[1]:-HEAD} new_rev=${args[2]:-}
old_sha=$(rev "$old_rev")
new_sha=$(rev "$new_rev")
log "attribute: $attr"
log "old: $(describe "$old_rev" "$old_sha")"
log "new: $(describe "$new_rev" "$new_sha")"

log "$verb old"
old=$(get old "$old_sha") || die "$verb old failed"
log "$verb new"
new=$(get new "$new_sha") || die "$verb new failed"

if [[ $old == "$new" ]]; then
  log "identical: $old"
  exit 0
fi
log "$diff $old $new"
$diff "$old" "$new"
