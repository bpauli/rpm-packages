# rpm-packages

Signed DNF repository for Fedora, updated on each release via GitHub Actions. It is served from GitHub Pages at https://bpauli.de/rpm-packages.

## Packages

- **zwift-bootstrap** - Unofficial native Linux launcher for Zwift

## Use the repository

Supported systems: Fedora. zwift-bootstrap is available for x86_64.

```sh
sudo curl -fsSL -o /etc/yum.repos.d/bpauli.repo https://bpauli.de/rpm-packages/bpauli.repo
sudo dnf install zwift-bootstrap
```

dnf asks you to import the signing key. Make sure that the fingerprint is the same as below.

`sudo dnf upgrade` then installs new releases.

## Signing key

The packages and the repository metadata are signed with this key. It is the key of the APT repository https://bpauli.de/apt-packages:

```text
Burkhard Pauli APT repository <burkhard@pauli.tech>
D938 19E1 6C12 6779 1909  1714 0B1A E188 72B1 9100
```

## How it works

A release of a package starts `.github/workflows/update-package.yml`. The workflow runs `scripts/fetch-package.sh`, which puts the `.rpm` files of the GitHub release into `packages/<name>/`. Every download is checked against the release's `checksums.txt`. Only zwift-bootstrap releases contain `.rpm` files. Then `scripts/update-repo.sh` signs the packages, rebuilds the metadata in `repodata/` and signs `repodata/repomd.xml`.
