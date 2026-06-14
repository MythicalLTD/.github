# Getting started

Build and publish FeatherPanel addons using MythicalLTD **actions** in your own workflows.

## What you need in your plugin repo

```
my-addon/
├── conf.yml
├── .featherexport
├── Frontend/App/          # optional
└── .github/workflows/     # YOUR workflows — you write these
    └── release-fpa.yml
```

### 1. `conf.yml`

```yaml
identifier: myaddon
version: "1.0.0"
name: My Addon
```

Output file: `myaddon-1.0.0.fpa`

### 2. `.featherexport`

Exclude dev files from the `.fpa`:

```gitignore
*/node_modules/*
/demo/*
banner.png
README.md
*/App/*
```

Copy [examples/featherexport/minimal.featherexport](../examples/featherexport/minimal.featherexport) → `.featherexport`

Full guide: [featherexport.md](featherexport.md)

### 3. Your workflow

Write your own `.github/workflows/*.yml` using our actions as steps.

**Build only:**

```yaml
name: Build FPA
on:
  push:
    branches: [main]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: MythicalLTD/.github/actions/build-fpa@v1
```

**Build + publish on tag:**

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

More examples: [examples/workflows/](../examples/workflows/)

Action reference: [actions/README.md](../actions/README.md)

### 4. Marketplace secret

1. Product → **Releases → Automated Release Uploads** → create upload secret
2. Repo → **Settings → Secrets → Actions** → `MYTHIC_RELEASE_TOKEN`

---

## Available actions

| Action | One-liner |
| --- | --- |
| Build `.fpa` | `uses: MythicalLTD/.github/actions/build-fpa@v1` |
| Publish file | `uses: MythicalLTD/.github/actions/publish-release@v1` |
| Build + publish | `uses: MythicalLTD/.github/actions/build-and-release@v1` |

---

## Compose multiple steps

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
        secrets:
          release_token: ${{ secrets.MYTHIC_RELEASE_TOKEN }}
```

Or use `build-and-release` as a single step.

---

## Pinning

```yaml
uses: MythicalLTD/.github/actions/build-fpa@v1   # recommended
```

Do not use `@main` in production.

---

## Next steps

- [Actions reference](../actions/README.md)
- [Example workflows](../examples/workflows/)
- [Publish API docs](https://publish-dev.mythicalsystems.org/docs)
