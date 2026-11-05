#!/bin/bash
# Put the .rpm files of one release into packages/PACKAGE/. Usage: fetch-package.sh PACKAGE TAG REPOSITORY
# Every download is checked against checksums.txt. A file that is already in packages/ stays as it is.
set -euo pipefail

package=$1 tag=$2 repo=$3
dest="$(pwd)/packages/$package"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# Signing changes only the signature header, so the digest of the main header identifies
# a release file and its signed copy in packages/.
header_digest() {
    rpm --query --package --nosignature --queryformat '%{SHA256HEADER}' "$1"
}

gh release download "$tag" --repo "$repo" --dir "$work" --pattern checksums.txt
rpm_lines=$(grep -E "  ${package}-[^ ]*\.(x86_64|aarch64|noarch)\.rpm$" "$work/checksums.txt" || true)

if [ -z "$rpm_lines" ]; then
    echo "No .rpm for ${package} ${tag}" >&2
    exit 1
fi

mkdir -p "$dest"

while read -r rpm_line; do
    rpm_file=${rpm_line##* }
    gh release download "$tag" --repo "$repo" --dir "$work" --pattern "$rpm_file"
    (cd "$work" && sha256sum --check <<< "$rpm_line")
    if [ ! -e "$dest/$rpm_file" ]; then
        mv "$work/$rpm_file" "$dest/"
    elif [ "$(header_digest "$dest/$rpm_file")" != "$(header_digest "$work/$rpm_file")" ]; then
        echo "packages/$package/$rpm_file exists and is not the same package as in ${repo} ${tag}" >&2
        exit 1
    fi
done <<< "$rpm_lines"
