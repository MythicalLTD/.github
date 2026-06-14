#!/usr/bin/env bash
set -euo pipefail

PRODUCT_ID="${1:?product_id required}"
ENVIRONMENT="${2:-dev}"
VERSION="${3:?version required}"
CHANGELOG="${4:?changelog required}"
FILE_PATH="${5:?file_path required}"
TITLE="${6:-}"
TOKEN="${MYTHIC_RELEASE_TOKEN:?MYTHIC_RELEASE_TOKEN required}"

case "${ENVIRONMENT}" in
  production|prod) BASE_URL="https://publish.mythicalsystems.org" ;;
  dev|development|"") BASE_URL="https://publish-dev.mythicalsystems.org" ;;
  *)
    echo "::error::Unknown environment '${ENVIRONMENT}'. Use dev or production."
    exit 1
    ;;
esac

if [[ ! -f "${FILE_PATH}" ]]; then
  echo "::error::Release file not found: ${FILE_PATH}"
  exit 1
fi

ext="${FILE_PATH##*.}"
ext="${ext,,}"
allowed='zip jar tar gz tgz phar fpa'
if [[ ! " ${allowed} " =~ " ${ext} " ]]; then
  echo "::error::Unsupported file extension '.${ext}'."
  exit 1
fi

size_kb=$(( ($(stat -c%s "${FILE_PATH}") + 1023) / 1024 ))
if (( size_kb > 51200 )); then
  echo "::error::Release file exceeds 50 MB limit (${size_kb} KB)."
  exit 1
fi

url="${BASE_URL}/${PRODUCT_ID}/releases"
release_title="${TITLE:-Release ${VERSION}}"

response_file="$(mktemp)"
http_code="$(
  curl -sS -w '%{http_code}' -o "${response_file}" \
    -X POST "${url}" \
    -H "Authorization: Bearer ${TOKEN}" \
    -F "version=${VERSION}" \
    -F "title=${release_title}" \
    -F "changelog=${CHANGELOG}" \
    -F "file=@${FILE_PATH}"
)"

body="$(cat "${response_file}")"
rm -f "${response_file}"

echo "HTTP ${http_code}"
echo "${body}"

if [[ "${http_code}" -lt 200 || "${http_code}" -ge 300 ]]; then
  echo "::error::Publish API returned HTTP ${http_code}"
  exit 1
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  release_id="$(echo "${body}" | jq -r '.release_id // .id // .data.id // empty' 2>/dev/null || true)"
  if [[ -n "${release_id}" && "${release_id}" != "null" ]]; then
    echo "release_id=${release_id}" >> "${GITHUB_OUTPUT}"
    echo "release_url=${BASE_URL}/${PRODUCT_ID}/releases/${release_id}" >> "${GITHUB_OUTPUT}"
  fi
fi
