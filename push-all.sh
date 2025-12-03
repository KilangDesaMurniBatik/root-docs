#!/bin/bash

#############################################################################
# NIAGA PLATFORM - Multi-Repo Push Script (Bash)
#
# This script iterates through all repository folders in the niaga-platform
# directory, checks for changes, and pushes them to their remote repos.
#
# Usage:
#   ./push-all.sh              # Push all changes
#   ./push-all.sh --dry-run    # Preview what would be pushed
#   ./push-all.sh -m "message" # Custom commit message
#############################################################################

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Default values
DRY_RUN=false
COMMIT_MESSAGE="Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -m|--message)
            COMMIT_MESSAGE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--dry-run] [-m|--message \"commit message\"]"
            exit 1
            ;;
    esac
done

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$SCRIPT_DIR"

# List of all repositories
REPOS=(
    "infra-platform"
    "infra-database"
    "lib-common"
    "lib-ui"
    "service-auth"
    "service-catalog"
    "service-inventory"
    "service-order"
    "service-customer"
    "service-notification"
    "service-agent"
    "service-reporting"
    "frontend-storefront"
    "frontend-admin"
    "frontend-warehouse"
    "frontend-agent"
)

# Statistics
TOTAL_REPOS=${#REPOS[@]}
PROCESSED_REPOS=0
PUSHED_REPOS=0
SKIPPED_REPOS=0
ERROR_REPOS=0
REPOS_WITH_CHANGES=()

# Print header
echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║   NIAGA PLATFORM - Multi-Repo Push Script            ║${RESET}"
echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════╝${RESET}"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}🔍 DRY RUN MODE - No changes will be pushed${RESET}"
    echo ""
fi

# Function to check if directory is a git repo
is_git_repo() {
    [ -d "$1/.git" ]
}

# Function to process each repository
push_repo() {
    local repo_name=$1
    local repo_path=$2
    
    ((PROCESSED_REPOS++))
    
    echo -e "${BOLD}${BLUE}[$PROCESSED_REPOS/$TOTAL_REPOS]${RESET} ${CYAN}$repo_name${RESET}"
    
    # Check if directory exists
    if [ ! -d "$repo_path" ]; then
        echo -e "    ${YELLOW}⊘ Directory not found - skipping${RESET}"
        ((SKIPPED_REPOS++))
        echo ""
        return
    fi
    
    # Check if it's a git repo
    if ! is_git_repo "$repo_path"; then
        echo -e "    ${YELLOW}⊘ Not a git repository - skipping${RESET}"
        ((SKIPPED_REPOS++))
        echo ""
        return
    fi
    
    cd "$repo_path" || return
    
    # Check if remote exists
    if ! git remote get-url origin &> /dev/null; then
        echo -e "    ${YELLOW}⊘ No remote configured - skipping${RESET}"
        ((SKIPPED_REPOS++))
        echo ""
        return
    fi
    
    # Get current branch
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    echo -e "    Branch: ${GREEN}$CURRENT_BRANCH${RESET}"
    
    # Check for uncommitted changes
    HAS_UNCOMMITTED=false
    if [ -n "$(git status --porcelain)" ]; then
        HAS_UNCOMMITTED=true
        echo -e "    ${YELLOW}✓${RESET} Uncommitted changes detected"
        
        if [ "$DRY_RUN" = false ]; then
            echo -e "    ${BLUE}→${RESET} Adding all changes..."
            git add -A
            
            echo -e "    ${BLUE}→${RESET} Committing with message: '$COMMIT_MESSAGE'"
            git commit -m "$COMMIT_MESSAGE"
        else
            echo -e "    ${CYAN}[DRY RUN]${RESET} Would add and commit changes"
        fi
    fi
    
    # Check for unpushed commits
    HAS_UNPUSHED=false
    if git log origin/$CURRENT_BRANCH..$CURRENT_BRANCH --oneline 2>/dev/null | grep -q .; then
        HAS_UNPUSHED=true
    fi
    
    # Push if needed
    if [ "$HAS_UNCOMMITTED" = true ] || [ "$HAS_UNPUSHED" = true ]; then
        echo -e "    ${YELLOW}✓${RESET} Unpushed commits detected"
        
        if [ "$DRY_RUN" = false ]; then
            echo -e "    ${BLUE}→${RESET} Pushing to origin/$CURRENT_BRANCH..."
            
            if git push origin "$CURRENT_BRANCH" 2>&1; then
                echo -e "    ${GREEN}✓ Successfully pushed!${RESET}"
                ((PUSHED_REPOS++))
                REPOS_WITH_CHANGES+=("$repo_name")
            else
                echo -e "    ${RED}✗ Push failed${RESET}"
                ((ERROR_REPOS++))
            fi
        else
            echo -e "    ${CYAN}[DRY RUN]${RESET} Would push to origin/$CURRENT_BRANCH"
            REPOS_WITH_CHANGES+=("$repo_name")
        fi
    else
        echo -e "    ${GREEN}✓ Already up to date${RESET}"
        ((SKIPPED_REPOS++))
    fi
    
    echo ""
}

# Main execution
echo "Scanning ${BOLD}$TOTAL_REPOS${RESET} repositories..."
echo ""
echo -e "${CYAN}────────────────────────────────────────────────────────────${RESET}"
echo ""

for repo in "${REPOS[@]}"; do
    repo_path="$ROOT_DIR/$repo"
    push_repo "$repo" "$repo_path"
done

# Print summary
echo -e "${CYAN}════════════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "${BOLD}${CYAN}Summary:${RESET}"
echo ""
echo -e "  Total repositories: ${BOLD}$TOTAL_REPOS${RESET}"

if [ "$DRY_RUN" = true ]; then
    echo -e "  Would be pushed:    ${GREEN}${BOLD}${#REPOS_WITH_CHANGES[@]}${RESET}"
else
    echo -e "  Successfully pushed: ${GREEN}${BOLD}$PUSHED_REPOS${RESET}"
fi

echo -e "  Skipped:            ${YELLOW}${BOLD}$SKIPPED_REPOS${RESET}"

if [ $ERROR_REPOS -gt 0 ]; then
    echo -e "  Errors:             ${RED}${BOLD}$ERROR_REPOS${RESET}"
fi

echo ""

if [ ${#REPOS_WITH_CHANGES[@]} -gt 0 ]; then
    if [ "$DRY_RUN" = true ]; then
        echo -e "${BOLD}Repositories with changes (would be pushed):${RESET}"
    else
        echo -e "${BOLD}Pushed repositories:${RESET}"
    fi
    
    for repo in "${REPOS_WITH_CHANGES[@]}"; do
        echo -e "  ${GREEN}✓${RESET} $repo"
    done
    echo ""
fi

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}This was a dry run. Run without --dry-run to actually push changes.${RESET}"
    echo ""
else
    echo -e "${GREEN}${BOLD}✓ All done!${RESET}"
    echo ""
fi
