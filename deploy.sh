#!/usr/bin/env bash
set -euo pipefail

##
## Deployment script for dcs_report
##
## Copies the current working tree (dev) into the production
## directory used by cron and refreshes the virtualenv.
##

DEV_DIR="/home/konstantin/ghq/github.com/konscodes/dcs_report"
PROD_DIR="/opt/dcs_report"
VENV_DIR="${PROD_DIR}/.venv"

echo "=== dcs_report deployment ==="

# Ensure we are running from the expected dev directory
if [[ "$(pwd)" != "$DEV_DIR" ]]; then
  echo "This script is intended to be run from: $DEV_DIR"
  echo "Current directory: $(pwd)"
  echo "Please 'cd $DEV_DIR' and run it again."
  exit 1
fi

echo "Dev directory : $DEV_DIR"
echo "Prod directory: $PROD_DIR"
echo "Venv directory: $VENV_DIR"

if [[ ! -d "$PROD_DIR" ]]; then
  echo "ERROR: Production directory '$PROD_DIR' does not exist."
  echo "Create it and clone the repo there first, or adjust PROD_DIR in this script."
  exit 1
fi

echo "Step 1/3: Copying code from dev to prod (rsync)..."
rsync -av --delete \
  --exclude ".git" \
  --exclude ".venv" \
  --exclude "__pycache__" \
  --exclude ".mypy_cache" \
  --exclude ".pytest_cache" \
  --exclude "output" \
  "$DEV_DIR"/ "$PROD_DIR"/

echo "Step 2/3: Ensuring virtualenv exists..."
if [[ ! -d "$VENV_DIR" ]]; then
  echo "Virtualenv not found at '$VENV_DIR', creating a new one..."
  python3 -m venv "$VENV_DIR"
fi

echo "Step 3/3: Installing/updating Python dependencies in venv..."
"$VENV_DIR/bin/pip" install --upgrade pip
if [[ -f "$PROD_DIR/requirements.txt" ]]; then
  "$VENV_DIR/bin/pip" install -r "$PROD_DIR/requirements.txt"
else
  echo "WARNING: requirements.txt not found in '$PROD_DIR'. Skipping dependency install."
fi

echo "Deployment complete."
echo "Cron will continue to run: $VENV_DIR/bin/python $PROD_DIR/main.py"

