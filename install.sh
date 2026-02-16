#!/usr/bin/env bash
#
# consommé installer
# - Symlinks skills into ~/.claude/skills/ (Claude Code / Amp)
# - Links as Gemini CLI extension (Gemini)
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

# Target directory for skill symlinks (Claude Code / Amp only)
SKILL_TARGETS=("$HOME/.claude/skills")

# Parse arguments
DRY_RUN=false
VERIFY_ONLY=false
UNINSTALL=false

show_help() {
    echo "consommé installer"
    echo ""
    echo "Usage: ./install.sh [OPTIONS]"
    echo ""
    echo "Installs consomme for Claude Code, Amp, and Gemini CLI:"
    echo "  - Claude Code / Amp: symlinks skill into ~/.claude/skills/"
    echo "  - Gemini CLI: links repo as extension via 'gemini extensions link'"
    echo ""
    echo "Options:"
    echo "  --help      Show this help message"
    echo "  --dry-run   Preview what would be installed (no changes)"
    echo "  --verify    Check existing installation"
    echo "  --uninstall Remove symlinks and extension link"
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

    # Remove skill symlinks
    for target_dir in "${SKILL_TARGETS[@]}"; do
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

    # Remove legacy Gemini skill symlink if present
    GEMINI_SKILL_LINK="$HOME/.gemini/skills/consomme"
    if [[ -L "$GEMINI_SKILL_LINK" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "  Would remove legacy Gemini skill symlink: ${GEMINI_SKILL_LINK/#$HOME/\~}"
        else
            rm "$GEMINI_SKILL_LINK"
        fi
        ok "Removed legacy Gemini skill symlink"
    fi

    # Unlink Gemini extension
    if command -v gemini &>/dev/null; then
        info "Unlinking Gemini extension..."
        if [[ "$DRY_RUN" == true ]]; then
            echo "  Would run: gemini extensions uninstall consomme"
        else
            gemini extensions uninstall consomme 2>/dev/null && \
                ok "Gemini extension unlinked" || \
                warn "Gemini extension was not linked"
        fi
    fi

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

    # Check Claude Code / Amp skill symlinks
    for target_dir in "${SKILL_TARGETS[@]}"; do
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

    # Check Gemini extension
    info "Checking Gemini extension..."
    EXT_LINK="$HOME/.gemini/extensions/consomme"
    if [[ -L "$EXT_LINK" ]]; then
        if [[ -d "$EXT_LINK" ]]; then
            echo "  ✓ Gemini extension (linked)"
        else
            echo "  ✗ Gemini extension (broken symlink)"
            ERRORS=$((ERRORS + 1))
        fi
    elif [[ -d "$EXT_LINK" ]]; then
        echo "  ✓ Gemini extension (installed)"
    else
        echo "  ✗ Gemini extension (not linked)"
        ERRORS=$((ERRORS + 1))
    fi

    # Warn about legacy Gemini skill symlink
    GEMINI_SKILL_LINK="$HOME/.gemini/skills/consomme"
    if [[ -L "$GEMINI_SKILL_LINK" ]]; then
        warn "Legacy Gemini skill symlink exists at ${GEMINI_SKILL_LINK/#$HOME/\~}"
        echo "    This may cause double-loading. Run install to clean up."
    fi

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

# --- Claude Code / Amp: skill symlinks ---

ACTIVE_TARGETS=()
for target_dir in "${SKILL_TARGETS[@]}"; do
    if [[ -d "$target_dir" ]]; then
        ACTIVE_TARGETS+=("$target_dir")
    fi
done

if [[ ${#ACTIVE_TARGETS[@]} -eq 0 ]]; then
    info "Creating ~/.claude/skills/..."
    if [[ "$DRY_RUN" != true ]]; then
        mkdir -p "$HOME/.claude/skills"
    fi
    ACTIVE_TARGETS=("$HOME/.claude/skills")
fi

INSTALLED=()
for target_dir in "${ACTIVE_TARGETS[@]}"; do
    short_dir="${target_dir/#$HOME/\~}"
    info "Installing skill to $short_dir..."

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

# --- Clean up legacy Gemini skill symlink ---

GEMINI_SKILL_LINK="$HOME/.gemini/skills/consomme"
if [[ -L "$GEMINI_SKILL_LINK" ]]; then
    info "Removing legacy Gemini skill symlink (replaced by extension)..."
    if [[ "$DRY_RUN" != true ]]; then
        rm "$GEMINI_SKILL_LINK"
    fi
    ok "Removed ${GEMINI_SKILL_LINK/#$HOME/\~}"
fi

# --- Gemini CLI: extension link ---

if command -v gemini &>/dev/null; then
    echo ""
    EXT_DIR="$HOME/.gemini/extensions/consomme"

    if [[ -L "$EXT_DIR" ]] && [[ "$(readlink "$EXT_DIR")" == "$SCRIPT_DIR" ]]; then
        ok "Gemini extension already linked"
    else
        info "Linking Gemini extension..."
        if [[ "$DRY_RUN" != true ]]; then
            # Create symlink directly — 'gemini extensions link' requires
            # interactive input for settings which can't be piped
            mkdir -p "$HOME/.gemini/extensions"
            [[ -e "$EXT_DIR" ]] && rm -rf "$EXT_DIR"
            ln -s "$SCRIPT_DIR" "$EXT_DIR"

            # Create .env for settings if not present
            if [[ ! -f "$SCRIPT_DIR/.env" ]]; then
                echo "BIGQUERY_PROJECT=" > "$SCRIPT_DIR/.env"
                warn "Set your project in .env: echo 'BIGQUERY_PROJECT=your-project' > $SCRIPT_DIR/.env"
            fi
            ok "Gemini extension linked"
        else
            echo "  Would symlink: $EXT_DIR → $SCRIPT_DIR"
        fi
    fi
    INSTALLED+=("Gemini extension → ~/.gemini/extensions/consomme")

    echo ""
    warn "BQ tools require the Google BQ Data Analytics extension:"
    echo "  gemini extensions install googlecloudplatform/bq-data-analytics"
else
    echo ""
    warn "Gemini CLI not found — skipping extension link"
    echo "  Install: https://github.com/google-gemini/gemini-cli"
fi

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
