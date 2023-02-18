#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix curl jq prefetch-yarn-deps nix-prefetch-github

set -euo pipefail

if [[ "$#" -gt 1 || "$1" == -* ]]; then
  echo "Regenerates packaging data for jellyseerr."
  echo "Usage: $0 [git release tag]"
  exit 1
fi

tag="$1"

set -euo pipefail

if [ -z "$tag" ]; then
  tag="$(
    curl "https://api.github.com/repos/Fallenbagel/jellyseerr/releases?per_page=1" |
    jq -r '.[0].tag_name'
  )"
fi

src="https://raw.githubusercontent.com/Fallenbagel/jellyseerr/$tag"
src_sha256=$(nix-prefetch-github Fallenbagel jellyseerr --rev ${tag} | jq -r .sha256)

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

pushd $tmpdir
curl -O "$src/yarn.lock"
yarn_sha256=$(prefetch-yarn-deps yarn.lock)
popd

curl -O "$src/package.json"
cat > pin.json << EOF
{
  "version": "$(echo $tag | grep -P '(\d|\.)+' -o)",
  "srcSha256": "$src_sha256",
  "yarnSha256": "$yarn_sha256"
}
EOF
