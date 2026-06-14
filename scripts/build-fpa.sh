#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PLUGIN_DIR="${1:-.}"
PLUGIN_DIR="$(cd "${PLUGIN_DIR}" && pwd)"
PASSWORD="${FPA_PASSWORD:-featherpanel_development_kit_2025_addon_password}"
FRONTEND_DIR="${FRONTEND_DIR:-Frontend/App}"
PACKAGE_MANAGER="${PACKAGE_MANAGER:-auto}"
FRONTEND_BUILD_COMMAND="${FRONTEND_BUILD_COMMAND:-}"
BUILD_FRONTEND="${BUILD_FRONTEND:-true}"
TEMP_DIR="$(mktemp -d)"
EXPORT_FILE="${TEMP_DIR}/plugin.fpa"

cleanup() {
  rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

echo -e "${GREEN}Starting FPA build in ${PLUGIN_DIR}...${NC}"

if ! command -v zip >/dev/null 2>&1; then
  echo -e "${RED}Error: zip is required but not installed${NC}"
  exit 1
fi

should_build_frontend() {
  case "${BUILD_FRONTEND}" in
    1|true|yes|on|TRUE|YES|ON) return 0 ;;
    *) return 1 ;;
  esac
}

run_frontend_build() {
  local frontend_path="${PLUGIN_DIR}/${FRONTEND_DIR}"

  if ! should_build_frontend; then
    echo -e "${YELLOW}Frontend build disabled (build_frontend=false)${NC}"
    return 0
  fi

  if [ "${PACKAGE_MANAGER}" = "none" ]; then
    echo -e "${YELLOW}Frontend build skipped (package_manager=none)${NC}"
    return 0
  fi

  if [ ! -d "${frontend_path}" ]; then
    echo -e "${YELLOW}Frontend directory not found (${FRONTEND_DIR}), skipping frontend build${NC}"
    return 0
  fi

  echo -e "${YELLOW}Building frontend in ${FRONTEND_DIR}...${NC}"
  cd "${frontend_path}"

  local manager="${PACKAGE_MANAGER}"
  if [ "${manager}" = "auto" ]; then
    if [ -f "pnpm-lock.yaml" ]; then
      manager="pnpm"
    elif [ -f "package-lock.json" ]; then
      manager="npm"
    elif [ -f "yarn.lock" ]; then
      manager="yarn"
    else
      manager="pnpm"
    fi
    echo -e "${YELLOW}Auto-detected package manager: ${manager}${NC}"
  fi

  case "${manager}" in
    pnpm)
      echo -e "${YELLOW}Installing with pnpm...${NC}"
      if ! pnpm install --frozen-lockfile 2>&1; then
        echo -e "${YELLOW}Lockfile config mismatch detected, updating lockfile...${NC}"
        pnpm install --no-frozen-lockfile
      fi
      BUILD_CMD="${FRONTEND_BUILD_COMMAND:-pnpm build}"
      ;;
    npm)
      echo -e "${YELLOW}Installing with npm...${NC}"
      npm ci || npm install
      BUILD_CMD="${FRONTEND_BUILD_COMMAND:-npm run build}"
      ;;
    yarn)
      echo -e "${YELLOW}Installing with yarn...${NC}"
      yarn install --frozen-lockfile || yarn install
      BUILD_CMD="${FRONTEND_BUILD_COMMAND:-yarn build}"
      ;;
    *)
      echo -e "${RED}Error: Unsupported package manager '${manager}'. Use auto, pnpm, npm, yarn, or none.${NC}"
      exit 1
      ;;
  esac

  echo -e "${YELLOW}Running: ${BUILD_CMD}${NC}"
  eval "${BUILD_CMD}"
  echo -e "${GREEN}Frontend build completed${NC}"
  cd "${PLUGIN_DIR}"
}

run_frontend_build

CONF_FILE="${PLUGIN_DIR}/conf.yml"
if [ ! -f "${CONF_FILE}" ]; then
  echo -e "${RED}Error: conf.yml not found in ${PLUGIN_DIR}${NC}"
  exit 1
fi

PLUGIN_VERSION="$(grep -E '^\s*version:' "${CONF_FILE}" | head -1 | sed -E 's/^[[:space:]]*version:[[:space:]]*//; s/["'\'']//g' | tr -d ' ')"
PLUGIN_IDENTIFIER="$(grep -E '^\s*identifier:' "${CONF_FILE}" | head -1 | sed -E 's/^[[:space:]]*identifier:[[:space:]]*//; s/["'\'']//g' | tr -d ' ')"

if [ -z "${PLUGIN_VERSION}" ]; then
  echo -e "${RED}Error: Could not extract version from conf.yml${NC}"
  exit 1
fi

if [ -z "${PLUGIN_IDENTIFIER}" ]; then
  echo -e "${RED}Error: Could not extract identifier from conf.yml${NC}"
  exit 1
fi

echo -e "${GREEN}Plugin: ${PLUGIN_IDENTIFIER} v${PLUGIN_VERSION}${NC}"

EXCLUSIONS=()
EXPORT_IGNORE="${PLUGIN_DIR}/.featherexport"
if [ -f "${EXPORT_IGNORE}" ]; then
  echo -e "${YELLOW}Reading .featherexport exclusions...${NC}"
  while IFS= read -r line || [ -n "$line" ]; do
    line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    if [ -z "$line" ] || [[ "$line" =~ ^# ]]; then
      continue
    fi
    line="$(echo "$line" | sed 's/#.*$//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    if [ -n "$line" ]; then
      EXCLUSIONS+=("$line")
    fi
  done < "${EXPORT_IGNORE}"
  echo -e "${GREEN}Found ${#EXCLUSIONS[@]} exclusion pattern(s) in .featherexport${NC}"
else
  echo -e "${YELLOW}No .featherexport found — packing all files in the plugin directory${NC}"
  echo -e "${YELLOW}Tip: add .featherexport next to conf.yml to exclude node_modules, frontend source, .git, etc.${NC}"
  echo -e "${YELLOW}Template: https://github.com/MythicalLTD/.github/blob/main/templates/featherexport.example${NC}"
fi

EXCLUSIONS+=(".featherexport")

echo -e "${YELLOW}Creating .fpa archive...${NC}"
cd "${PLUGIN_DIR}"

if [ ${#EXCLUSIONS[@]} -gt 0 ]; then
  echo -e "${YELLOW}Excluding ${#EXCLUSIONS[@]} pattern(s):${NC}"
  for pattern in "${EXCLUSIONS[@]}"; do
    echo -e "  - ${pattern}"
  done

  EXCLUSION_ARGS=()
  for pattern in "${EXCLUSIONS[@]}"; do
    PATTERN="$(echo "$pattern" | sed 's|^/||')"
    EXCLUSION_ARGS+=("-x" "$PATTERN")
  done

  zip -r -P "${PASSWORD}" "${EXPORT_FILE}" * "${EXCLUSION_ARGS[@]}"
else
  zip -r -P "${PASSWORD}" "${EXPORT_FILE}" *
fi

if [ ! -f "${EXPORT_FILE}" ]; then
  echo -e "${RED}Error: Failed to create .fpa file${NC}"
  exit 1
fi

FINAL_EXPORT="${PLUGIN_DIR}/${PLUGIN_IDENTIFIER}-${PLUGIN_VERSION}.fpa"
mv "${EXPORT_FILE}" "${FINAL_EXPORT}"
trap - EXIT
rm -rf "${TEMP_DIR}"

echo -e "${GREEN}Created: ${FINAL_EXPORT}${NC}"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    echo "fpa_file=${FINAL_EXPORT}"
    echo "plugin_version=${PLUGIN_VERSION}"
    echo "plugin_identifier=${PLUGIN_IDENTIFIER}"
    echo "fpa_filename=${PLUGIN_IDENTIFIER}-${PLUGIN_VERSION}.fpa"
    echo "featherexport_patterns=${#EXCLUSIONS[@]}"
  } >> "${GITHUB_OUTPUT}"
fi

echo -e "${GREEN}FPA build completed successfully!${NC}"
