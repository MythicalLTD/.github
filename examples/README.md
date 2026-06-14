# Copy-paste example

Copy into your plugin repo at `.github/workflows/release-fpa.yml`.

| File | Description |
| --- | --- |
| [release-fpa.yml](workflows/release-fpa.yml) | Manual release — marketplace + GitHub release + version bump |

Set repository secrets `MYTHIC_PRODUCT_ID` and `MYTHIC_RELEASE_TOKEN`, then run **Actions → Release FPA → Run workflow**.

## `.featherexport` examples → plugin root

| File | Description |
| --- | --- |
| [minimal.featherexport](featherexport/minimal.featherexport) | **Recommended** |
| [full-addon.featherexport](featherexport/full-addon.featherexport) | Extra exclusions |
| [php-only.featherexport](featherexport/php-only.featherexport) | PHP-only |

Rename to `.featherexport` after copying.

Action reference: [actions/README.md](../actions/README.md)
