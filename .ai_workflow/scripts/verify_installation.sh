#!/bin/bash
# Installation Verification Script
# Verifies that all critical framework files are present after installation

set -euo pipefail

# Critical files that must be present for framework to work
CRITICAL_FILES=(
    "ai-dev"
    "manager.md"
    "CLAUDE.md"
    ".ai_workflow/scripts/platform_adapter.sh"
    ".ai_workflow/scripts/generate_prps.sh"
    ".ai_workflow/workflows/setup/01_start_setup.md"
    ".ai_workflow/workflows/run/01_run_prp.md"
    ".ai_workflow/generate-tasks.md"
)

# Important directories that should exist
CRITICAL_DIRS=(
    ".ai_workflow"
    ".ai_workflow/scripts"
    ".ai_workflow/workflows"
    ".ai_workflow/workflows/setup"
    ".ai_workflow/workflows/run"
    ".ai_workflow/PRPs"
    ".ai_workflow/PRPs/templates"
)

verify_installation() {
    local errors=0
    local warnings=0
    
    echo "🔍 Verifying AI Framework Installation"
    echo "=================================="
    echo ""
    
    # Check critical directories
    echo "📁 Checking critical directories..."
    for dir in "${CRITICAL_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            echo "   ✅ $dir"
        else
            echo "   ❌ MISSING: $dir"
            ((errors++))
        fi
    done
    echo ""
    
    # Check critical files
    echo "📄 Checking critical files..."
    for file in "${CRITICAL_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            echo "   ✅ $file"
        else
            echo "   ❌ MISSING: $file"
            ((errors++))
        fi
    done
    echo ""
    
    # Check ai-dev executable
    echo "⚙️  Checking ai-dev executable..."
    if [[ -f "ai-dev" ]]; then
        if [[ -x "ai-dev" ]]; then
            echo "   ✅ ai-dev is executable"
        else
            echo "   ⚠️  ai-dev exists but is not executable"
            echo "      Run: chmod +x ai-dev"
            ((warnings++))
        fi
    else
        echo "   ❌ ai-dev script missing"
        ((errors++))
    fi
    echo ""
    
    # Check scripts executable
    echo "🔧 Checking script permissions..."
    local script_errors=0
    for script in .ai_workflow/scripts/*.sh; do
        if [[ -f "$script" ]]; then
            if [[ ! -x "$script" ]]; then
                echo "   ⚠️  $script is not executable"
                ((warnings++))
                ((script_errors++))
            fi
        fi
    done
    
    if [[ $script_errors -eq 0 ]]; then
        echo "   ✅ All scripts are executable"
    else
        echo "   💡 To fix script permissions, run: chmod +x .ai_workflow/scripts/*.sh"
    fi
    echo ""
    
    # Summary
    echo "📊 Installation Summary"
    echo "======================"
    if [[ $errors -eq 0 && $warnings -eq 0 ]]; then
        echo "🎉 Perfect! Framework installation is complete and ready to use."
        echo ""
        echo "💡 Next steps:"
        echo "   - Run: ./ai-dev help"
        echo "   - Start a project: ./ai-dev setup"
        return 0
    elif [[ $errors -eq 0 ]]; then
        echo "✅ Framework installation is functional with $warnings warnings."
        echo "⚠️  Fix warnings for optimal experience."
        return 0
    else
        echo "❌ Framework installation is incomplete!"
        echo "   Errors: $errors"
        echo "   Warnings: $warnings"
        echo ""
        echo "🛠️  This indicates:"
        echo "   - Framework was not downloaded completely from GitHub"
        echo "   - Some files were deleted accidentally"
        echo "   - Installation process failed"
        echo ""
        echo "💡 Recommended actions:"
        echo "   1. Re-download framework from GitHub"
        echo "   2. Ensure all files are extracted properly"
        echo "   3. Run this verification script again"
        return 1
    fi
}

# Create missing directories
create_missing_dirs() {
    echo "🔧 Creating missing directories..."
    for dir in "${CRITICAL_DIRS[@]}"; do
        if [[ ! -d "$dir" ]]; then
            echo "   📁 Creating: $dir"
            mkdir -p "$dir"
        fi
    done
    echo "✅ Directory structure created"
}

# Fix permissions
fix_permissions() {
    echo "🔧 Fixing file permissions..."
    
    # Make ai-dev executable
    if [[ -f "ai-dev" ]]; then
        chmod +x ai-dev
        echo "   ✅ ai-dev made executable"
    fi
    
    # Make all scripts executable
    if [[ -d ".ai_workflow/scripts" ]]; then
        chmod +x .ai_workflow/scripts/*.sh 2>/dev/null || true
        echo "   ✅ Scripts made executable"
    fi
}

# Main execution
case "${1:-verify}" in
    "verify")
        verify_installation
        ;;
    "fix-dirs")
        create_missing_dirs
        verify_installation
        ;;
    "fix-permissions")
        fix_permissions
        verify_installation
        ;;
    "fix-all")
        create_missing_dirs
        fix_permissions
        verify_installation
        ;;
    *)
        echo "Usage: $0 [verify|fix-dirs|fix-permissions|fix-all]"
        echo ""
        echo "Commands:"
        echo "  verify          - Check installation (default)"
        echo "  fix-dirs        - Create missing directories"
        echo "  fix-permissions - Fix file permissions"
        echo "  fix-all         - Create dirs and fix permissions"
        exit 1
        ;;
esac