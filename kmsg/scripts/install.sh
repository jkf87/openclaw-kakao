#!/usr/bin/env bash
# kmsg installer - macOS only
set -euo pipefail

INSTALL_DIR="${HOME}/.local/bin"
BIN_PATH="${INSTALL_DIR}/kmsg"
DOWNLOAD_URL="https://github.com/channprj/kmsg/releases/latest/download/kmsg-macos-universal"

echo "=== kmsg installer ==="

# Check macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "ERROR: kmsg requires macOS 13+." >&2
  exit 1
fi

# Check existing installation
if command -v kmsg &>/dev/null; then
  EXISTING="$(command -v kmsg)"
  echo "kmsg already installed at: ${EXISTING}"
  kmsg --version 2>/dev/null || true
  read -rp "Reinstall? [y/N] " answer
  [[ "${answer}" =~ ^[yY]$ ]] || { echo "Aborted."; exit 0; }
fi

# Download
mkdir -p "${INSTALL_DIR}"
echo "Downloading kmsg..."
curl -fL "${DOWNLOAD_URL}" -o "${BIN_PATH}"
chmod +x "${BIN_PATH}"

# PATH check
if ! echo "${PATH}" | tr ':' '\n' | grep -qx "${INSTALL_DIR}"; then
  SHELL_RC="${HOME}/.zshrc"
  echo "export PATH=\"\${HOME}/.local/bin:\${PATH}\"" >> "${SHELL_RC}"
  echo "Added ${INSTALL_DIR} to PATH in ${SHELL_RC}"
  echo "Run: source ${SHELL_RC}"
fi

# Verify
echo ""
"${BIN_PATH}" --version 2>/dev/null && echo "Installation complete." || echo "Installed but version check failed. Run: kmsg status"
echo ""
echo "Next: Grant Accessibility permission in System Settings > Privacy & Security > Accessibility"
