# Publishing this repository

How to ship **MythicalLTD/.github** actions for plugin authors.

Follows [GitHub's release-management guidance for actions](https://docs.github.com/en/actions/sharing-automations/creating-actions#using-release-management-for-actions): **pin with tags**, not `@main`.

---

## Publish a release (maintainers)

### 1. Merge to `main`

```bash
git push origin main
```

### 2. Create a release on GitHub

**Releases → Draft a new release**

1. Click **Choose a tag** → type e.g. `v1.0.0` → **Create new tag** on `main`
2. Set the title (e.g. `v1.0.0`)
3. Write release notes (what changed)
4. Click **Publish release**

That's it. The [`publish-actions-release` workflow](../.github/workflows/publish-actions-release.yml) runs automatically and:

- Validates semver tag (`v1.0.0`, `v2.1.3`, …)
- Verifies all `actions/*/action.yml` and `scripts/*.sh` exist
- Moves the major tag (`v1`, `v2`, …) to this release — so `@v1` users get the update
- Appends usage snippets to the release notes
- Writes a job summary with pin examples

**Prereleases** skip the moving major tag update (use for betas).

### One-time setup

| Step | Where |
| --- | --- |
| Org Actions access | **MythicalLTD → Settings → Actions → General → Access** |
| Public actions | Repo **public** if third-party plugin repos should use them |

---

## What we publish

```
actions/
  build-fpa/          → uses: MythicalLTD/.github/actions/build-fpa@v1
  publish-release/    → uses: MythicalLTD/.github/actions/publish-release@v1
  build-and-release/  → uses: MythicalLTD/.github/actions/build-and-release@v1
scripts/
  build-fpa.sh
  publish-release.sh
```

---

## How users consume it

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: MythicalLTD/.github/actions/build-and-release@v1
        with:
          product_id: "123"
          environment: dev
          changelog: "Bug fixes"
        secrets:
          release_token: ${{ secrets.MYTHIC_RELEASE_TOKEN }}
```

| Pin | Meaning |
| --- | --- |
| `@v1` | **Recommended** — latest 1.x (updated by our release workflow) |
| `@v1.0.0` | Exact patch — never changes |
| `@main` | Dev only — unstable |

---

## Version bumps

| Change | Release tag |
| --- | --- |
| Bug fix | `v1.0.1` |
| New optional input | `v1.1.0` |
| Breaking change | `v2.0.0` → workflow moves `v2` tag |

---

## Release checklist

- [ ] Tested from a plugin repo (`@main` or branch pin)
- [ ] `actions/`, `docs/`, `examples/` updated
- [ ] Merged to `main`
- [ ] **Releases tab → Publish release** with semver tag

---

## Manual fallback

If the workflow fails, sync the major tag yourself:

```bash
git tag -f v1 v1.0.1
git push origin v1 --force
```

---

## Links

- [Getting started](getting-started.md)
- [Actions reference](../actions/README.md)
- [GitHub: Creating actions](https://docs.github.com/en/actions/sharing-automations/creating-actions)
