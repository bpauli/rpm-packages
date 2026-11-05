#!/bin/sh
# Sign every .rpm under packages/, rebuild repodata/ and sign repodata/repomd.xml.
# Run from the repository root. The secret key of key.asc must be in the gpg keyring.
set -eu

fingerprint=$(gpg --batch --with-colons --show-keys key.asc | awk -F: '$1 == "fpr" { print $10; exit }')

# rpmsign skips a package that already has a signature of this key.
find packages -name '*.rpm' -exec rpmsign --addsign --define "_gpg_name $fingerprint" {} +

createrepo_c .

gpg --batch --yes --armor --detach-sign --local-user "$fingerprint" \
    --output repodata/repomd.xml.asc repodata/repomd.xml
