#!/usr/bin/env bash
#
# consommé installer
# Symlinks skills into ~/.gemini/skills/ and ~/.claude/skills/
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}==>${NC} $1"; }
ok()    { echo -e "${GREEN}✓${NC} $1"; }
warn()  { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Target directories
TARGETS=("$HOME/.gemini/skills" "$HOME/.claude/skills")

# Parse arguments
DRY_RUN=false
VERIFY_ONLY=false
UNINSTALL=false

show_help() {
    echo "consommé installer"
    echo ""
    echo "Usage: ./install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help      Show this help message"
    echo "  --dry-run   Preview what would be installed (no changes)"
    echo "  --verify    Check existing installation"
    echo "  --uninstall Remove symlinks created by this installer"
    echo ""
}

for arg in "$@"; do
    case $arg in
        --help)      show_help; exit 0 ;;
        --dry-run)   DRY_RUN=true ;;
        --verify)    VERIFY_ONLY=true ;;
        --uninstall) UNINSTALL=true ;;
        *)           error "Unknown option: $arg"; show_help; exit 1 ;;
    esac
done

# ============================================================
# UNINSTALL MODE
# ============================================================
if [[ "$UNINSTALL" == true ]]; then
    echo ""
    echo "consommé uninstaller"
    echo "========================"
    echo ""

    for target_dir in "${TARGETS[@]}"; do
        info "Checking ${target_dir/#$HOME/\~}..."
        REMOVED=0
        for link in "$target_dir"/*/; do
            [[ -L "${link%/}" ]] || continue
            target=$(readlink "${link%/}")
            if [[ "$target" == *"consomme"* ]]; then
                if [[ "$DRY_RUN" == true ]]; then
                    echo "  Would remove: ${link%/}"
                else
                    rm "${link%/}"
                fi
                REMOVED=$((REMOVED + 1))
            fi
        done
        ok "Removed $REMOVED symlinks from ${target_dir/#$HOME/\~}"
    done
    echo ""
    exit 0
fi

# ============================================================
# VERIFY MODE
# ============================================================
if [[ "$VERIFY_ONLY" == true ]]; then
    echo ""
    echo "consommé verification"
    echo "========================="
    echo ""

    ERRORS=0
    for target_dir in "${TARGETS[@]}"; do
        info "Checking ${target_dir/#$HOME/\~}..."
        if [[ ! -d "$target_dir" ]]; then
            echo "  – directory does not exist"
            continue
        fi
        for skill_dir in "$SCRIPT_DIR"/skills/*/; do
            skill=$(basename "$skill_dir")
            link="$target_dir/$skill"
            if [[ -L "$link" ]]; then
                if [[ -d "$link" ]]; then
                    echo "  ✓ $skill"
                else
                    echo "  ✗ $skill (broken symlink)"
                    ERRORS=$((ERRORS + 1))
                fi
            elif [[ -d "$link" ]]; then
                echo "  ~ $skill (directory, not symlink)"
            else
                echo "  ✗ $skill (missing)"
                ERRORS=$((ERRORS + 1))
            fi
        done
    done

    echo ""
    if [[ $ERRORS -eq 0 ]]; then
        ok "All checks passed!"
    else
        error "$ERRORS issues found"
        exit 1
    fi
    exit 0
fi

# ============================================================
# INSTALL MODE
# ============================================================
echo ""
echo "consommé installer"
echo "======================"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    warn "DRY RUN — no changes will be made"
    echo ""
fi

# Check which target directories exist
ACTIVE_TARGETS=()
MISSING_TARGETS=()
for target_dir in "${TARGETS[@]}"; do
    if [[ -d "$target_dir" ]]; then
        ACTIVE_TARGETS+=("$target_dir")
    else
        MISSING_TARGETS+=("$target_dir")
    fi
done

if [[ ${#ACTIVE_TARGETS[@]} -eq 0 ]]; then
    warn "Neither ~/.gemini/skills/ nor ~/.claude/skills/ exists"
    info "Creating both directories..."
    if [[ "$DRY_RUN" != true ]]; then
        for target_dir in "${TARGETS[@]}"; do
            mkdir -p "$target_dir"
        done
    fi
    ACTIVE_TARGETS=("${TARGETS[@]}")
fi

# Symlink skills into each active target
INSTALLED=()
for target_dir in "${ACTIVE_TARGETS[@]}"; do
    short_dir="${target_dir/#$HOME/\~}"
    info "Installing to $short_dir..."

    for skill_dir in "$SCRIPT_DIR"/skills/*/; do
        skill_name=$(basename "$skill_dir")
        skill_path="${skill_dir%/}"
        link="$target_dir/$skill_name"

        if [[ -L "$link" ]]; then
            if [[ "$DRY_RUN" != true ]]; then
                rm "$link"
                ln -s "$skill_path" "$link"
            fi
            ok "$skill_name (updated)"
            INSTALLED+=("$skill_name → $short_dir/$skill_name")
        elif [[ -d "$link" ]]; then
            warn "Skipping $skill_name (existing directory, not symlink)"
        else
            if [[ "$DRY_RUN" != true ]]; then
                ln -s "$skill_path" "$link"
            fi
            ok "$skill_name"
            INSTALLED+=("$skill_name → $short_dir/$skill_name")
        fi
    done
done

# Summary
echo ""
echo "================================"
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}DRY RUN complete${NC}"
else
    echo -e "${GREEN}Installation complete!${NC}"
fi
echo "================================"
echo ""
echo "Installed:"
for item in "${INSTALLED[@]}"; do
    echo "  • $item"
done
echo ""
echo -e "${YELLOW}NEXT STEP:${NC} Restart your AI agent to activate."
echo ""
