#!/bin/bash

# Version Manager Script for AI Development Framework
# Usage: ./version_manager.sh [command] [args]

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(dirname "$SCRIPT_DIR")"
VERSION_CONFIG="$FRAMEWORK_DIR/config/version_config.json"
FRAMEWORK_CONFIG="$FRAMEWORK_DIR/config/framework.json"
PLAN_FILE="$FRAMEWORK_DIR/../plan_de_trabajo.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get current version
get_current_version() {
    if [ -f "$VERSION_CONFIG" ]; then
        jq -r '.current_version' "$VERSION_CONFIG"
    else
        echo "v0.1.0-alpha"
    fi
}

# Get version phase (alpha, beta, production)
get_version_phase() {
    local version="$1"
    if [[ "$version" == *"-alpha"* ]]; then
        echo "alpha"
    elif [[ "$version" == *"-beta"* ]]; then
        echo "beta"
    else
        echo "production"
    fi
}

# Validate version format
validate_version() {
    local version="$1"
    if [[ ! "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-alpha|-beta)?$ ]]; then
        error "Invalid version format: $version"
        error "Expected format: vX.Y.Z[-alpha|-beta]"
        return 1
    fi
    return 0
}

# Check if version meets release criteria
check_release_criteria() {
    local phase="$1"
    local criteria_met=true
    
    info "Checking release criteria for $phase phase..."
    
    case "$phase" in
        "alpha")
            # Check alpha criteria
            if [ ! -f "$FRAMEWORK_DIR/../ai-dev" ]; then
                error "❌ CLI script not found"
                criteria_met=false
            else
                success "✅ CLI script exists"
            fi
            
            # Check workflow functionality
            local workflow_count=$(find "$FRAMEWORK_DIR/workflows" -name "*.md" | wc -l)
            if [ "$workflow_count" -lt 40 ]; then
                error "❌ Insufficient workflows: $workflow_count (minimum 40)"
                criteria_met=false
            else
                success "✅ Sufficient workflows: $workflow_count"
            fi
            
            # Check if interdependencies are resolved
            local interdep_issues=$(grep -r "source .ai_workflow/" "$FRAMEWORK_DIR/workflows" || true)
            if [ -n "$interdep_issues" ]; then
                error "❌ Interdependency issues found"
                criteria_met=false
            else
                success "✅ No interdependency issues"
            fi
            ;;
            
        "beta")
            # Check beta criteria
            if [ ! -f "$FRAMEWORK_DIR/knowledge_base/cro_screenshots_analysis.md" ]; then
                error "❌ CRO knowledge base not integrated"
                criteria_met=false
            else
                success "✅ CRO knowledge base integrated"
            fi
            
            # Check GitHub Actions
            if [ ! -f "$FRAMEWORK_DIR/../.github/workflows/ci.yml" ]; then
                error "❌ GitHub Actions CI/CD not implemented"
                criteria_met=false
            else
                success "✅ GitHub Actions CI/CD implemented"
            fi
            ;;
            
        "production")
            # Check production criteria
            if [ ! -f "$FRAMEWORK_DIR/agents/cro_agent.md" ]; then
                error "❌ Multi-agent system not implemented"
                criteria_met=false
            else
                success "✅ Multi-agent system implemented"
            fi
            ;;
    esac
    
    if [ "$criteria_met" = true ]; then
        success "All release criteria met for $phase phase"
        return 0
    else
        error "Release criteria not met for $phase phase"
        return 1
    fi
}

# Update version in configuration files
update_version_config() {
    local new_version="$1"
    local description="$2"
    
    info "Updating version configuration..."
    
    # Update version_config.json
    local temp_file=$(mktemp)
    jq --arg version "$new_version" \
       --arg date "$(date +%Y-%m-%d)" \
       --arg desc "$description" \
       '.current_version = $version | 
        .version_history += [{
            "version": $version,
            "date": $date,
            "description": $desc,
            "status": "stable"
        }]' "$VERSION_CONFIG" > "$temp_file"
    mv "$temp_file" "$VERSION_CONFIG"
    
    # Update framework.json
    temp_file=$(mktemp)
    jq --arg version "$new_version" \
       --arg date "$(date +%Y-%m-%d)" \
       '.framework_version = $version | 
        .build_date = $date' "$FRAMEWORK_CONFIG" > "$temp_file"
    mv "$temp_file" "$FRAMEWORK_CONFIG"
    
    success "Version configuration updated to $new_version"
}

# Display version information
show_version_info() {
    local current_version=$(get_current_version)
    local phase=$(get_version_phase "$current_version")
    
    echo "=========================================="
    echo "  AI Development Framework Version Info"
    echo "=========================================="
    echo
    echo "Current Version: $current_version"
    echo "Current Phase: $phase"
    echo "Build Date: $(jq -r '.build_date' "$FRAMEWORK_CONFIG" 2>/dev/null || echo 'Unknown')"
    echo "Build Status: $(jq -r '.build_status' "$FRAMEWORK_CONFIG" 2>/dev/null || echo 'Unknown')"
    echo
    echo "Framework Metrics:"
    echo "  Total Workflows: $(jq -r '.metrics.total_workflows' "$FRAMEWORK_CONFIG" 2>/dev/null || echo 'Unknown')"
    echo "  Functionality: $(jq -r '.metrics.functionality_percentage' "$FRAMEWORK_CONFIG" 2>/dev/null || echo 'Unknown')%"
    echo "  Commands Available: $(jq -r '.metrics.commands_available' "$FRAMEWORK_CONFIG" 2>/dev/null || echo 'Unknown')"
    echo
    echo "Release Criteria Status:"
    
    # Check each phase
    for phase in alpha beta production; do
        local status=$(jq -r ".release_criteria.$phase.current_status" "$VERSION_CONFIG" 2>/dev/null || echo 'Unknown')
        echo "  $phase: $status"
    done
    echo
}

# Create new release
create_release() {
    local new_version="$1"
    local description="$2"
    
    info "Creating new release: $new_version"
    
    # Validate version format
    if ! validate_version "$new_version"; then
        return 1
    fi
    
    # Check release criteria
    local phase=$(get_version_phase "$new_version")
    if ! check_release_criteria "$phase"; then
        warning "Release criteria not met. Continue anyway? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            info "Release cancelled"
            return 1
        fi
    fi
    
    # Update configuration
    update_version_config "$new_version" "$description"
    
    # Create git tag if in git repository
    if [ -d ".git" ]; then
        info "Creating git tag: $new_version"
        git tag -a "$new_version" -m "$description"
        success "Git tag created: $new_version"
    fi
    
    success "Release $new_version created successfully"
}

# Main command handler
main() {
    case "${1:-}" in
        "info"|"show")
            show_version_info
            ;;
        "current")
            echo $(get_current_version)
            ;;
        "phase")
            echo $(get_version_phase $(get_current_version))
            ;;
        "check")
            local phase="${2:-$(get_version_phase $(get_current_version))}"
            check_release_criteria "$phase"
            ;;
        "release")
            if [ $# -lt 3 ]; then
                error "Usage: $0 release <version> <description>"
                exit 1
            fi
            create_release "$2" "$3"
            ;;
        "help"|"--help"|"-h")
            echo "AI Development Framework Version Manager"
            echo
            echo "Usage: $0 [command] [args]"
            echo
            echo "Commands:"
            echo "  info, show          Show version information"
            echo "  current             Show current version"
            echo "  phase               Show current phase (alpha/beta/production)"
            echo "  check [phase]       Check release criteria for phase"
            echo "  release <ver> <desc> Create new release"
            echo "  help                Show this help message"
            echo
            echo "Examples:"
            echo "  $0 info"
            echo "  $0 check alpha"
            echo "  $0 release v0.4.0-alpha 'New features added'"
            ;;
        *)
            error "Unknown command: ${1:-}"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"