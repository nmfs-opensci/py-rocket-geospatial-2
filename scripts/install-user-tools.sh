#!/usr/bin/env bash
# install-user-tools: install self-updating CLI tools into your own home directory.
#
# These tools are not baked into the image because they update themselves
# (roughly weekly); a copy in the image could not update and would go stale.
# Installed in your home, they persist across image updates on the hub.
#
# Usage:
#   install-user-tools claude        # Claude Code  -> ~/.local/bin/claude
#   install-user-tools agy           # Antigravity  -> ~/.local/bin/agy
#   install-user-tools claude agy    # both
#   install-user-tools --list
#
# Each tool uses its official installer. Nothing here signs you in: run the
# tool afterwards and log in with your own account or key (personal account,
# your organization's Bedrock, a LiteLLM gateway key, ...). The image ships no
# credentials.

set -euo pipefail

usage() {
  sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'
}

tools_list() {
  cat <<'EOF'
claude   Claude Code (Anthropic). ~230 MB in ~/.local/share/claude (keeps several versions).
agy      Antigravity CLI (Google). ~280 MB binary in ~/.local/bin.
EOF
}

install_claude() {
  echo "==> Installing Claude Code into your home (official installer)"
  curl -fsSL https://claude.ai/install.sh | bash
}

install_agy() {
  echo "==> Installing Antigravity (agy) into your home (official installer)"
  # The installer is served gzipped even without Accept-Encoding, so
  # --compressed is required or bash receives binary garbage.
  curl -fsSL --compressed https://antigravity.google/cli/install.sh | bash
}

if [ $# -eq 0 ]; then
  usage
  exit 1
fi

for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    --list) tools_list; exit 0 ;;
    claude|agy) ;;
    *) echo "Unknown tool: $arg" >&2; echo "Known tools:" >&2; tools_list >&2; exit 1 ;;
  esac
done

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this as your own user, not root: it installs into your home directory." >&2
  exit 1
fi

cat <<'EOF'
Note: your home directory on the hub has a 20 GiB quota. Check what is using it
with:  du -sh ~/.local ~/.cache 2>/dev/null
EOF

for arg in "$@"; do
  case "$arg" in
    claude) install_claude ;;
    agy) install_agy ;;
  esac
done

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) echo; echo "~/.local/bin is not on your PATH. Add this to ~/.bashrc:"
     echo '  export PATH="$HOME/.local/bin:$PATH"' ;;
esac

echo
echo "Done. Start a new terminal, then run the tool (claude / agy) and sign in."
