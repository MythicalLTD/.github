# MythicalLTD — GitHub Actions

Composite actions for **FeatherPanel `.fpa` builds** and **Mythic Marketplace releases**.

You write your own workflows — we provide the steps.

## Quick start

```yaml
name: Release FPA
on:
  push:
    tags: ["v*"]
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: MythicalLTD/.github/actions/build-and-release@v1
        with:
          product_id: "123"
          environment: dev
          changelog: ${{ github.event.head_commit.message }}
        secrets:
          release_token: ${{ secrets.MYTHIC_RELEASE_TOKEN }}
```

## Actions

| Action | Usage |
| --- | --- |
| Build `.fpa` | `uses: MythicalLTD/.github/actions/build-fpa@v1` |
| Publish file | `uses: MythicalLTD/.github/actions/publish-release@v1` |
| Build + publish | `uses: MythicalLTD/.github/actions/build-and-release@v1` |

Pin `@v1` in production — not `@main`.

## Docs

| | |
| --- | --- |
| [Getting started](docs/getting-started.md) | Plugin repo setup |
| [Actions reference](actions/README.md) | All inputs & outputs |
| [`.featherexport`](docs/featherexport.md) | Exclude files from the `.fpa` |
| [Example workflows](examples/README.md) | Copy-paste YAML for your repo |
| [Publishing this repo](docs/publishing-this-repo.md) | Maintainers |

## `.featherexport`

```gitignore
*/node_modules/*
/demo/*
banner.png
README.md
*/App/*
```

Copy [examples/featherexport/minimal.featherexport](examples/featherexport/minimal.featherexport) → plugin root as `.featherexport`.

## Repo layout

```
actions/           build-fpa, publish-release, build-and-release
scripts/           build + publish shell scripts
examples/workflows Sample workflows you copy into your plugin repo
templates/         .featherexport template
docs/              Documentation
```

## Publish (maintainers)

1. Push to `main`
2. **Releases → Draft a new release** → tag `v1.0.0` → **Publish**

The [`publish-actions-release`](.github/workflows/publish-actions-release.yml) workflow moves the `@v1` tag and appends usage notes automatically.

[Full guide →](docs/publishing-this-repo.md)
