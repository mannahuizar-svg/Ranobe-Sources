#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts_setup-consumet.sh [branch]
# If branch is not provided, defaults to "main".
DEST_DIR="external/consumet-api"
REPO_URL="https://github.com/consumet/api.consumet.org.git"
BRANCH="${1:-main}"

command_exists() { command -v "$1" >/dev/null 2>&1; }

echo "Preparing Consumet API setup (branch: $BRANCH)..."

if ! command_exists git; then
  echo "Error: git is not installed. Install git and re-run this script." >&2
  exit 1
fi

if [ -d "$DEST_DIR" ]; then
  echo "Directory $DEST_DIR already exists. Attempting to update..."
  if [ -d "$DEST_DIR/.git" ]; then
    (cd "$DEST_DIR" && \
      git fetch origin "$BRANCH" && \
      git checkout "$BRANCH" 2>/dev/null || git checkout -B "$BRANCH" "origin/$BRANCH" 2>/dev/null && \
      git pull --ff-only origin "$BRANCH" || git pull --rebase origin "$BRANCH")
  else
    echo "Warning: $DEST_DIR exists but is not a git repo. Skipping git pull." >&2
  fi
else
  echo "Cloning Consumet API into $DEST_DIR..."
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$DEST_DIR"
fi

cd "$DEST_DIR"

# Detect Node / package manager
if ! command_exists node; then
  echo "Warning: node is not installed. You will need Node.js to install/run dependencies." >&2
fi

if command_exists pnpm; then
  PM="pnpm"
elif command_exists yarn; then
  PM="yarn"
elif command_exists npm; then
  PM="npm"
else
  PM=""
fi

echo "Detected package manager: ${PM:-none}"

# Prefer lockfile-aware installs
if [ -n "$PM" ]; then
  if [ "$PM" = "pnpm" ]; then
    echo "Installing dependencies with pnpm..."
    pnpm install --frozen-lockfile || pnpm install
  elif [ "$PM" = "yarn" ]; then
    if [ -f yarn.lock ]; then
      echo "Installing dependencies with yarn (frozen lockfile)..."
      yarn install --frozen-lockfile || yarn install
    else
      echo "Installing dependencies with yarn..."
      yarn install
    fi
  else
    # npm
    if [ -f package-lock.json ]; then
      echo "Installing dependencies with npm ci..."
      npm ci || npm install
    else
      echo "Installing dependencies with npm install..."
      npm install
    fi
  fi
else
  echo "No package manager found (npm/yarn/pnpm). Skipping dependency install." >&2
fi

# Create .env if example exists and .env missing
if [ -f .env.example ] && [ ! -f .env ]; then
  cp .env.example .env
  echo "Copied .env.example → .env (please review and update secrets/keys in .env)."
fi

echo
echo "Setup complete for Consumet API at: $DEST_DIR"
echo
echo "Recommended next steps:"
echo "  1) Edit $DEST_DIR/.env and set any required environment variables (API keys, DB urls, etc.)."
echo "  2) Start the server for development (hot reload) if the project supports it:"
echo "       cd $DEST_DIR && ${PM:-npm} run dev    # common command"
echo "  3) Start the server in production:"
echo "       cd $DEST_DIR && ${PM:-npm} start"
echo
echo "If you prefer a background process manager, consider using pm2 or Docker."
echo "  Example with pm2:"
echo "    npm install -g pm2"
echo "    cd $DEST_DIR && pm2 start npm --name consumet -- start"
echo
echo "If anything failed above, re-run this script with a branch name:"
echo "  ./scripts_setup-consumet.sh develop"