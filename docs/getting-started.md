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

Copy the tested example into your repo:

**[examples/workflows/release-fpa.yml](../examples/workflows/release-fpa.yml)** → `.github/workflows/release-fpa.yml`

It validates secrets, resolves version from input or `conf.yml`, builds the `.fpa`, publishes to Mythic Marketplace, creates a GitHub release, and commits a version bump when needed.

Action reference: [actions/README.md](../actions/README.md)

### 4. Marketplace secrets

1. Product → **Releases → Automated Release Uploads** → create upload secret
2. Repo → **Settings → Secrets → Actions**:
   - `MYTHIC_RELEASE_TOKEN` — upload secret (`mp_rel_...`)
   - `MYTHIC_PRODUCT_ID` — product ID from the marketplace

Pass tokens to actions via `with:` — composite actions cannot use the workflow `secrets:` keyword at the step level. Values from `${{ secrets.* }}` are still masked in logs.

---

## Available actions

| Action | One-liner |
| --- | --- |
| Build `.fpa` | `uses: MythicalLTD/.github/actions/build-fpa@v1` |
| Publish file | `uses: MythicalLTD/.github/actions/publish-release@v1` |
| Build + publish | `uses: MythicalLTD/.github/actions/build-and-release@v1` |

---

---

## Pinning

```yaml
uses: MythicalLTD/.github/actions/build-fpa@v1   # recommended
```

Do not use `@main` in production.

---

## Next steps

- [Actions reference](../actions/README.md)
- [Example workflow](../examples/workflows/release-fpa.yml)
- [Publish API docs](https://publish-dev.mythicalsystems.org/docs)
