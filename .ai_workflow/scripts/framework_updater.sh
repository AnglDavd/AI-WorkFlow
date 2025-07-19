#!/bin/bash

# Framework Update Script
# Enhanced version with safety checks and rollback capabilities
# Usage: ./framework_updater.sh /path/to/your/project

PROJECT_PATH="${1:-}"
FRAMEWORK_SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="/tmp/ai_framework_backup_$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Validation functions
validate_input() {
    if [ -z "$PROJECT_PATH" ]; then
        error "Please provide project path"
        echo "Usage: $0 /path/to/your/project"
        exit 1
    fi

    if [ ! -d "$PROJECT_PATH" ]; then
        error "Project directory does not exist: $PROJECT_PATH"
        exit 1
    fi

    if [ ! -d "$FRAMEWORK_SOURCE" ]; then
        error "Framework source directory not found: $FRAMEWORK_SOURCE"
        exit 1
    fi
}

# Create backup before update
create_backup() {
    log "Creating backup of existing framework..."
    mkdir -p "$BACKUP_DIR"
    
    if [ -d "$PROJECT_PATH/.ai_workflow" ]; then
        cp -r "$PROJECT_PATH/.ai_workflow" "$BACKUP_DIR/" 2>/dev/null || true
        success "Backup created at: $BACKUP_DIR"
    else
        warning "No existing framework found - fresh installation"
    fi
}

# Check framework compatibility
check_compatibility() {
    log "Checking framework compatibility..."
    
    # Check for required tools
    local required_tools=("bash" "git")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            error "Required tool not found: $tool"
            return 1
        fi
    done
    
    # Check bash version
    if [ "${BASH_VERSION%%.*}" -lt 4 ]; then
        warning "Bash version ${BASH_VERSION} detected. Version 4+ recommended."
    fi
    
    success "Compatibility check passed"
    return 0
}

# Update framework files
update_framework() {
    log "Updating AI Framework files..."
    
    # Copy core framework
    cp -r "$FRAMEWORK_SOURCE/.ai_workflow" "$PROJECT_PATH/" || {
        error "Failed to copy framework files"
        return 1
    }
    
    # Copy main script
    cp "$FRAMEWORK_SOURCE/ai-dev" "$PROJECT_PATH/" || {
        error "Failed to copy ai-dev script"
        return 1
    }
    
    # Make ai-dev executable
    chmod +x "$PROJECT_PATH/ai-dev"
    
    # Copy essential documentation if missing
    for doc in "CLAUDE.md" "manager.md"; do
        if [ -f "$FRAMEWORK_SOURCE/$doc" ] && [ ! -f "$PROJECT_PATH/$doc" ]; then
            cp "$FRAMEWORK_SOURCE/$doc" "$PROJECT_PATH/"
            log "Copied missing documentation: $doc"
        fi
    done
    
    success "Framework files updated"
}

# Validate installation
validate_installation() {
    log "Validating framework installation..."
    
    cd "$PROJECT_PATH" || return 1
    
    # Check if ai-dev works
    if ./ai-dev status >/dev/null 2>&1; then
        success "Framework validation passed"
        return 0
    else
        error "Framework validation failed"
        return 1
    fi
}

# Rollback function
rollback() {
    warning "Rolling back to previous version..."
    
    if [ -d "$BACKUP_DIR/.ai_workflow" ]; then
        rm -rf "$PROJECT_PATH/.ai_workflow"
        cp -r "$BACKUP_DIR/.ai_workflow" "$PROJECT_PATH/"
        success "Framework rolled back successfully"
    else
        error "No backup found for rollback"
    fi
}

# Main update process
main() {
    echo "🔄 AI Framework Update System"
    echo "============================="
    echo "Source: $FRAMEWORK_SOURCE"
    echo "Target: $PROJECT_PATH"
    echo ""
    
    # Step 1: Validate input
    validate_input
    
    # Step 2: Check compatibility
    if ! check_compatibility; then
        error "Compatibility check failed"
        exit 1
    fi
    
    # Step 3: Create backup
    create_backup
    
    # Step 4: Update framework
    if ! update_framework; then
        error "Framework update failed"
        rollback
        exit 1
    fi
    
    # Step 5: Validate installation
    if ! validate_installation; then
        error "Installation validation failed"
        rollback
        exit 1
    fi
    
    # Step 6: Cleanup
    log "Cleaning up temporary files..."
    # Keep backup for manual cleanup
    
    echo ""
    success "🚀 Framework update completed successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. cd $PROJECT_PATH"
    echo "  2. ./ai-dev status"
    echo "  3. ./ai-dev help"
    echo ""
    echo "Backup location: $BACKUP_DIR"
    echo "Remove backup manually when satisfied with update"
}

# Handle script interruption
trap 'error "Update interrupted. Backup available at: $BACKUP_DIR"' INT TERM

# Run main function
main "$@"