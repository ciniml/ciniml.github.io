#!/bin/sh
# Build the site into docs/ (committed and served by GitHub Pages).
set -eu
cd "$(dirname "$0")/.."
exec hugo --minify --cleanDestinationDir "$@"
