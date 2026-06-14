# `.featherexport` — excluding files from the `.fpa`

When CI builds your addon, the packer creates a password-protected zip named `{identifier}-{version}.fpa`. By default **every file** in the plugin directory is included.

Add **`.featherexport`** next to `conf.yml` to exclude paths you don't want shipped — same idea as `.gitignore`.

## Quick start

```bash
# From your plugin repo root
curl -o .featherexport \
  https://raw.githubusercontent.com/MythicalLTD/.github/main/examples/featherexport/minimal.featherexport
```

Or copy [templates/featherexport.example](../templates/featherexport.example) and rename to `.featherexport`.

## Recommended minimal config

This is the most common setup for addons with a CI-built frontend:

```gitignore
# FeatherPanel Export Ignore File

*/node_modules/*
/demo/*
banner.png
README.md
*/App/*
```

| Pattern | Why |
| --- | --- |
| `*/node_modules/*` | Drop dependency trees anywhere in the plugin |
| `/demo/*` | Demo/preview folder not for production |
| `banner.png` | Marketing image — not needed in the install |
| `README.md` | GitHub readme — not needed in the install |
| `*/App/*` | Frontend **source** — CI builds first, compiled output stays |

### Why `*/App/*` instead of `Frontend/App/`?

`*/App/*` matches any `App` folder at any depth (`Frontend/App/`, nested paths, etc.). Use it when your build outputs compiled files **outside** the `App` folder (e.g. `Frontend/dist/`).

If your layout differs, be specific:

```gitignore
Frontend/App/
resources/ui/src/
```

## Ready-made examples

| File | Best for |
| --- | --- |
| [minimal.featherexport](../examples/featherexport/minimal.featherexport) | Standard addon with frontend built in CI |
| [full-addon.featherexport](../examples/featherexport/full-addon.featherexport) | More exclusions (.git, IDE, changelog, etc.) |
| [php-only.featherexport](../examples/featherexport/php-only.featherexport) | No frontend, PHP/composer only |
| [featherexport.example](../templates/featherexport.example) | Annotated template with comments |

## Pattern reference

| Pattern | Excludes |
| --- | --- |
| `README.md` | A single file at plugin root |
| `banner.png` | A single file |
| `demo/` | A directory at plugin root |
| `/demo/*` | Contents of `demo/` at root |
| `*.log` | All `.log` files |
| `*/node_modules/*` | Any `node_modules` folder |
| `*/App/*` | Any folder named `App` and its contents |
| `# comment` | Ignored line |

## Syntax notes

- One pattern per line.
- Lines starting with `#` are comments.
- Inline comments work: `banner.png # marketing only`
- `.featherexport` itself is **always** excluded from the archive — you don't need to list it.
- Patterns are passed to `zip -x` — similar to `.gitignore` but **not identical**. When in doubt, check the CI log; excluded patterns are printed during the build.

## Typical workflows

### Addon with Vue/React frontend

CI builds the frontend, then packs everything except source:

```yaml
# .github/workflows/release-fpa.yml
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: MythicalLTD/.github/actions/build-and-release@v1
        with:
          build_frontend: "true"
          package_manager: auto
```

```gitignore
# .featherexport
*/node_modules/*
*/App/*
README.md
/demo/*
```

### PHP-only addon

No frontend build — exclude dev files only:

```yaml
with:
  build_frontend: "false"
  package_manager: none
```

```gitignore
# .featherexport
vendor/
tests/
.phpunit.result.cache
README.md
.env
```

### Monorepo plugin

`.featherexport` lives in the **plugin directory**, not the monorepo root:

```
backend/storage/addons/billingcore/
├── conf.yml
├── .featherexport    ← here
└── Frontend/App/
```

```yaml
with:
  plugin_dir: backend/storage/addons/billingcore
```

## CI feedback

If `.featherexport` is missing, the workflow prints a **notice** in the log and the job summary links to this guide.

If present, the summary shows how many patterns were applied and lists them in the build log.

## Panel export vs CI export

The same `.featherexport` format is used when exporting from the FeatherPanel admin UI and when building via GitHub Actions — keep one file in your plugin repo and both paths stay consistent.
