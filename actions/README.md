# GitHub Actions reference

Use as **steps** in your own workflows — like `actions/checkout@v4`.

## Build FPA

`uses: MythicalLTD/.github/actions/build-fpa@v1`

| Input | Default | Description |
| --- | --- | --- |
| `plugin_dir` | auto | Plugin root with `conf.yml` |
| `build_frontend` | `true` | Build frontend before packing |
| `frontend_dir` | `Frontend/App` | Frontend path |
| `package_manager` | `auto` | `auto`, `pnpm`, `npm`, `yarn`, `none` |
| `frontend_build_command` | — | Override build command |
| `node_version` | `24` | Node.js version |
| `artifact_name` | `fpa-build` | Artifact name (`""` to skip) |
| `artifact_retention_days` | `30` | Retention days |

**Outputs:** `fpa_file`, `fpa_filename`, `plugin_version`, `plugin_identifier`, `plugin_dir`

```yaml
- uses: MythicalLTD/.github/actions/build-fpa@v1
```

```yaml
- uses: MythicalLTD/.github/actions/build-fpa@v1
  with:
    build_frontend: "false"
    package_manager: none
```

---

## Publish release

`uses: MythicalLTD/.github/actions/publish-release@v1`

| Input | Default | Description |
| --- | --- | --- |
| `product_id` | — | Marketplace product ID |
| `environment` | `dev` | `dev` or `production` |
| `version` | — | Semver |
| `changelog` | — | Release notes |
| `file_path` | — | Path to file on runner |
| `title` | — | Optional title |
| `release_token` | — | Upload secret (`mp_rel_...`) |

**Outputs:** `release_id`, `release_url`

Pass tokens via `with:` — composite actions cannot use the workflow `secrets:` keyword. Values from `${{ secrets.* }}` are still masked in logs.

```yaml
- uses: actions/checkout@v4
- uses: MythicalLTD/.github/actions/publish-release@v1
  with:
    product_id: "123"
    environment: dev
    version: "1.2.0"
    changelog: "Bug fixes"
    file_path: myaddon-1.2.0.fpa
    release_token: ${{ secrets.MYTHIC_RELEASE_TOKEN }}
```

**API hosts:** `dev` → `publish-dev.mythicalsystems.org` · `production` → `publish.mythicalsystems.org`

---

## Build and release

`uses: MythicalLTD/.github/actions/build-and-release@v1`

All build inputs + `product_id`, `environment`, `changelog`, optional `version` / `title`, and `release_token`.

**Outputs:** all build outputs + `release_id`, `release_url`

```yaml
- uses: MythicalLTD/.github/actions/build-and-release@v1
  with:
    product_id: "123"
    environment: dev
    changelog: "Bug fixes"
    release_token: ${{ secrets.MYTHIC_RELEASE_TOKEN }}
```

---

## Compose your own workflow

**Same job** — build then publish separately:

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: MythicalLTD/.github/actions/build-fpa@v1
        id: fpa
      - uses: MythicalLTD/.github/actions/publish-release@v1
        with:
          product_id: "123"
          environment: dev
          version: ${{ steps.fpa.outputs.plugin_version }}
          changelog: "Release"
          file_path: ${{ steps.fpa.outputs.fpa_file }}
          release_token: ${{ secrets.MYTHIC_RELEASE_TOKEN }}
```

**One step** — or use `build-and-release` instead.

**Separate jobs** — upload/download artifacts between jobs, or use `build-and-release` in a single job.

---

## Pinning

```yaml
uses: MythicalLTD/.github/actions/build-fpa@v1       # recommended
uses: MythicalLTD/.github/actions/build-fpa@v1.0.0 # exact patch
uses: MythicalLTD/.github/actions/build-fpa@main     # dev only
```

[How to publish new versions →](../docs/publishing-this-repo.md)

## Even shorter name (optional)

Publish the same `actions/` folder from a dedicated repo e.g. `MythicalLTD/featherpanel`:

```yaml
uses: MythicalLTD/featherpanel/build-fpa@v1
```
