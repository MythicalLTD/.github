# Copy-paste examples

These are **your** workflow files — copy into your plugin repo at `.github/workflows/`.

They use MythicalLTD actions as steps. Customize triggers, jobs, and inputs freely.

## Example workflows

| File | Description |
| --- | --- |
| [build-only.yml](workflows/build-only.yml) | Build `.fpa` on push |
| [build-and-release-tag.yml](workflows/build-and-release-tag.yml) | Tag → build + marketplace |
| [build-and-release-manual.yml](workflows/build-and-release-manual.yml) | Manual release from UI |
| [build-then-publish.yml](workflows/build-then-publish.yml) | Build + publish as separate steps |
| [php-only.yml](workflows/php-only.yml) | No frontend |
| [monorepo.yml](workflows/monorepo.yml) | Plugin in a subdirectory |
| [publish-artifact-only.yml](workflows/publish-artifact-only.yml) | Upload pre-built file |

## `.featherexport` examples → plugin root

| File | Description |
| --- | --- |
| [minimal.featherexport](featherexport/minimal.featherexport) | **Recommended** |
| [full-addon.featherexport](featherexport/full-addon.featherexport) | Extra exclusions |
| [php-only.featherexport](featherexport/php-only.featherexport) | PHP-only |

Rename to `.featherexport` after copying.

## Minimal copy-paste

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
          release_token: ${{ secrets.MYTHIC_RELEASE_TOKEN }}
```

Action reference: [actions/README.md](../actions/README.md)
