#!/bin/bash

# Release script for Jade ORM
# Usage: ./scripts/release.sh <version>
# Example: ./scripts/release.sh 0.1.1

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: ./scripts/release.sh <version>"
    echo "Example: ./scripts/release.sh 0.1.1"
    exit 1
fi

echo "Releasing Jade v${VERSION}..."

# Update _VERSION.lua
echo "return \"${VERSION}\"" > src/jade/_VERSION.lua
echo "Updated _VERSION.lua"

# Update rockspec
sed -i "s/version = \".*\"/version = \"${VERSION}-1\"/" jade-scm-1.rockspec
echo "Updated rockspec"

# Create commit
git add src/jade/_VERSION.lua jade-scm-1.rockspec
git commit -m "release: v${VERSION}"

# Create tag
git tag "v${VERSION}"

echo ""
echo "Release v${VERSION} prepared!"
echo ""
echo "Next steps:"
echo "  git push origin master --tags"
echo ""
echo "The GitHub Action will automatically publish to LuaRocks!"
