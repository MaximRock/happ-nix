#!/usr/bin/env bash
# Update happ.nix to the latest Happ release and verify the build.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
happ_nix="$repo_root/happ.nix"
release_api="https://api.github.com/repos/Happ-proxy/happ-desktop/releases/latest"
asset_name="Happ.linux.x64.deb"

for cmd in curl jq nix; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "error: $cmd is required" >&2
    exit 1
  fi
done

tag="$(
  curl -fsSL "$release_api" |
    jq -r 'select(.draft == false and .prerelease == false) | .tag_name'
)"

if [[ -z "$tag" || "$tag" == "null" ]]; then
  echo "error: could not determine the latest Happ release" >&2
  exit 1
fi

version="${tag#v}"

current="$(sed -n -E 's/^[[:space:]]*version = "(.*)";$/\1/p' "$happ_nix")"
if [[ -z "$current" ]]; then
  echo "error: could not parse version from $happ_nix" >&2
  exit 1
fi

if [[ "$version" == "$current" ]]; then
  echo "Happ is already up to date: $current"
  exit 0
fi

url="https://github.com/Happ-proxy/happ-desktop/releases/download/${tag}/${asset_name}"
echo "Updating Happ ${current} -> ${version}"
echo "Fetching $url"

new_hash="$(nix store prefetch-file --json --hash-type sha256 "$url" | jq -r '.hash')"
if [[ -z "$new_hash" || "$new_hash" == "null" ]]; then
  echo "error: failed to prefetch $url" >&2
  exit 1
fi

sed -i -E "s|^([[:space:]]*)version = \"[^\"]*\";$|\1version = \"${version}\";|" "$happ_nix"
sed -i -E "s|^([[:space:]]*)hash = \"[^\"]*\";$|\1hash = \"${new_hash}\";|" "$happ_nix"

if ! (cd "$repo_root" && nix build .#happ --no-link --print-out-paths); then
  echo "error: nix build .#happ failed; happ.nix left updated for inspection" >&2
  exit 1
fi

echo "Happ ${version} updated successfully"
