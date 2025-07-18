#!/bin/bash

# Version Utilities for AI-Assisted Development Framework
# Provides centralized version management across all framework components

# Get the absolute path to the framework directory
get_framework_dir() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "$(dirname "$script_dir")"
}

# Get the current framework version from VERSION file
get_framework_version() {
    local framework_dir="$(get_framework_dir)"
    local version_file="$framework_dir/VERSION"
    
    if [ -f "$version_file" ]; then
        cat "$version_file" | tr -d '\n\r'
    else
        echo "unknown"
    fi
}

# Get framework version with 'v' prefix (e.g., v1.0.0)
get_framework_version_with_prefix() {
    local version="$(get_framework_version)"
    if [[ "$version" != v* ]]; then
        echo "v$version"
    else
        echo "$version"
    fi
}

# Get framework version without 'v' prefix (e.g., 1.0.0)
get_framework_version_number() {
    local version="$(get_framework_version)"
    echo "${version#v}"
}

# Check if version format is valid (semantic versioning)
is_valid_version() {
    local version="$1"
    # Remove 'v' prefix if present
    version="${version#v}"
    
    # Check semantic versioning pattern: X.Y.Z or X.Y.Z-suffix
    if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9\.-]+)?$ ]]; then
        return 0
    else
        return 1
    fi
}

# Update framework version (admin function)
update_framework_version() {
    local new_version="$1"
    
    if [ -z "$new_version" ]; then
        echo "ERROR: Version parameter required"
        return 1
    fi
    
    # Validate version format
    if ! is_valid_version "$new_version"; then
        echo "ERROR: Invalid version format. Use semantic versioning (e.g., 1.0.0 or v1.0.0)"
        return 1
    fi
    
    local framework_dir="$(get_framework_dir)"
    local version_file="$framework_dir/VERSION"
    
    # Remove 'v' prefix for storage
    new_version="${new_version#v}"
    
    echo "$new_version" > "$version_file"
    echo "✅ Framework version updated to: v$new_version"
    
    return 0
}

# Get version info as JSON
get_version_info_json() {
    local version="$(get_framework_version)"
    local version_number="$(get_framework_version_number)"
    local framework_dir="$(get_framework_dir)"
    
    cat << EOF
{
  "version": "$version",
  "version_number": "$version_number",
  "version_with_prefix": "v$version_number",
  "framework_dir": "$framework_dir",
  "updated": "$(date -Iseconds)"
}
EOF
}

# Display version information
show_version_info() {
    local version="$(get_framework_version)"
    local framework_dir="$(get_framework_dir)"
    
    echo "🏗️  AI-Assisted Development Framework"
    echo "📦 Version: $version"
    echo "📁 Location: $framework_dir"
    echo "📅 Last modified: $(stat -f '%Sm' "$framework_dir/VERSION" 2>/dev/null || stat -c '%y' "$framework_dir/VERSION" 2>/dev/null || echo 'Unknown')"
}

# Command-line interface for version utilities
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    case "${1:-}" in
        "get"|"current"|"")
            get_framework_version
            ;;
        "get-with-prefix")
            get_framework_version_with_prefix
            ;;
        "get-number")
            get_framework_version_number
            ;;
        "info")
            show_version_info
            ;;
        "json")
            get_version_info_json
            ;;
        "update")
            if [ -z "$2" ]; then
                echo "Usage: $0 update <new_version>"
                exit 1
            fi
            update_framework_version "$2"
            ;;
        "validate")
            if [ -z "$2" ]; then
                echo "Usage: $0 validate <version>"
                exit 1
            fi
            if is_valid_version "$2"; then
                echo "✅ Valid version format: $2"
                exit 0
            else
                echo "❌ Invalid version format: $2"
                exit 1
            fi
            ;;
        "help"|"-h"|"--help")
            echo "Framework Version Utilities"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  get, current     Get current version"
            echo "  get-with-prefix  Get version with 'v' prefix"
            echo "  get-number       Get version number only"
            echo "  info             Show detailed version information"
            echo "  json             Get version info as JSON"
            echo "  update <version> Update framework version"
            echo "  validate <ver>   Validate version format"
            echo "  help             Show this help"
            echo ""
            echo "Examples:"
            echo "  $0                    # Get current version"
            echo "  $0 info               # Show version info"
            echo "  $0 update v1.1.0      # Update to v1.1.0"
            echo "  $0 validate 1.0.0     # Validate version format"
            ;;
        *)
            echo "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
fi