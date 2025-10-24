#!/usr/bin/env bash
set -e

DEST_DIR="external/consumet-api"

if [ -d "$DEST_DIR" ]; then
  echo "Directory $DEST_DIR already exists. Updating..."
  (cd "$DEST_DIR" && git pull)
else
  echo "Cloning Consumet API into $DEST_DIR..."
  git clone https://github.com/consumet/api.consumet.org.git "$DEST_DIR"
fi

echo "Installing dependencies..."
cd "$DEST_DIR"
npm install    # or yarn install

echo "To start the server run:"
echo "  cd $DEST_DIR && npm start"