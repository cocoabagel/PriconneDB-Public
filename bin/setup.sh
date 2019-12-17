#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Ruby version from .ruby-version file
RUBY_VERSION_FILE="$PROJECT_ROOT/.ruby-version"
if [[ -f "$RUBY_VERSION_FILE" ]]; then
    RUBY_VERSION=$(cat "$RUBY_VERSION_FILE" | tr -d '[:space:]')
else
    echo -e "${RED}✗ .ruby-version file not found${NC}"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  PriconneDB Development Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

cd "$PROJECT_ROOT"

# ------------------------------------------
# 1. Homebrew
# ------------------------------------------
echo -e "${YELLOW}[1/6] Checking Homebrew...${NC}"

if command -v brew &> /dev/null; then
    echo -e "${GREEN}✓ Homebrew is already installed${NC}"
else
    echo -e "${BLUE}→ Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    echo -e "${GREEN}✓ Homebrew installed${NC}"
fi

# ------------------------------------------
# 2. Brew Bundle
# ------------------------------------------
echo ""
echo -e "${YELLOW}[2/6] Installing Homebrew dependencies...${NC}"

if [[ -f "$PROJECT_ROOT/Brewfile" ]]; then
    brew bundle --file="$PROJECT_ROOT/Brewfile"
    echo -e "${GREEN}✓ Homebrew dependencies installed${NC}"
else
    echo -e "${RED}✗ Brewfile not found${NC}"
    exit 1
fi

# ------------------------------------------
# 3. rbenv setup
# ------------------------------------------
echo ""
echo -e "${YELLOW}[3/6] Setting up rbenv...${NC}"

# Initialize rbenv
if command -v rbenv &> /dev/null; then
    eval "$(rbenv init - bash)"
    echo -e "${GREEN}✓ rbenv initialized${NC}"
else
    echo -e "${RED}✗ rbenv not found. Please check Brewfile installation.${NC}"
    exit 1
fi

# ------------------------------------------
# 4. Ruby
# ------------------------------------------
echo ""
echo -e "${YELLOW}[4/6] Checking Ruby ${RUBY_VERSION}...${NC}"

# Check if the required Ruby version is installed
if rbenv versions --bare | grep -q "^${RUBY_VERSION}$"; then
    echo -e "${GREEN}✓ Ruby ${RUBY_VERSION} is already installed${NC}"
else
    echo -e "${BLUE}→ Installing Ruby ${RUBY_VERSION}...${NC}"
    rbenv install "$RUBY_VERSION"
    echo -e "${GREEN}✓ Ruby ${RUBY_VERSION} installed${NC}"
fi

# Rehash rbenv
rbenv rehash

# Verify Ruby version
ACTIVE_RUBY=$(rbenv version-name)
if [[ "$ACTIVE_RUBY" == "$RUBY_VERSION" ]]; then
    echo -e "${GREEN}✓ Ruby ${RUBY_VERSION} is active${NC}"
else
    echo -e "${YELLOW}! Active Ruby is ${ACTIVE_RUBY}, expected ${RUBY_VERSION}${NC}"
    echo -e "${YELLOW}  Run 'rbenv local ${RUBY_VERSION}' to set it${NC}"
fi

# ------------------------------------------
# 5. Bundle Install
# ------------------------------------------
echo ""
echo -e "${YELLOW}[5/6] Installing Ruby gems...${NC}"

# Ensure bundler is installed
if ! gem list bundler -i &> /dev/null; then
    echo -e "${BLUE}→ Installing Bundler...${NC}"
    gem install bundler --no-document
fi

# Install gems
if [[ -f "$PROJECT_ROOT/Gemfile" ]]; then
    bundle install
    echo -e "${GREEN}✓ Ruby gems installed${NC}"
else
    echo -e "${RED}✗ Gemfile not found${NC}"
    exit 1
fi

# ------------------------------------------
# 6. Git Hooks
# ------------------------------------------
echo ""
echo -e "${YELLOW}[6/6] Setting up Git hooks...${NC}"

git config core.hooksPath .githooks
echo -e "${GREEN}✓ Git hooks configured${NC}"

# ------------------------------------------
# Done
# ------------------------------------------
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "You can now:"
echo -e "  • Open ${BLUE}PriconneDB.xcodeproj${NC} in Xcode"
echo -e "  • Run ${BLUE}bundle exec fastlane unit_tests${NC} to run tests"
echo -e "  • Run ${BLUE}swiftformat Packages/${NC} to format code"
echo -e "  • Run ${BLUE}swiftlint lint Packages/${NC} to lint code"
echo ""
