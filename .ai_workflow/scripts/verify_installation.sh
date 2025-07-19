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
    ".ai_workflow/scripts/interactive_input.sh"
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

# Recreate missing manager.md
recreate_manager_md() {
    if [[ ! -f "manager.md" ]]; then
        echo "🔧 Recreating missing manager.md..."
        cat > manager.md << 'EOF'
# 🚀 AI Development Framework

Welcome to the AI Development Framework, a comprehensive system for building and managing software using AI agents with zero-friction automation.

**This file is the main documentation entry point.**

**📋 For comprehensive architectural information, see [ARCHITECTURE.md](.ai_workflow/ARCHITECTURE.md)**

## Framework Status

**📋 For complete version information and development status, see [ARCHITECTURE.md - Framework Status](ARCHITECTURE.md#framework-status)**

**Current Version:** v1.0.0 (Stable Release - Production Ready)  
**Developer:** AnglDavd using Claude Code (Solo Developer Project)  
**License:** Custom Dual License  
**Cross-Platform Support:** Linux (full), macOS (good), Windows (limited via Git Bash/WSL)
**Key Features:**
- ✅ Automatic quality validation with adaptive language support
- ✅ Zero-friction automation philosophy
- ✅ Multi-language project compatibility (30+ languages)
- ✅ Enhanced CLI system with production-ready UX
- ✅ External feedback integration and community synchronization
- ✅ Framework-level task management with organized feedback processing

## Key Principles

- **Transparency:** All logic is defined in readable `.md` workflow files.
- **User Control:** The system proposes, the user approves.
- **Zero-Friction Automation:** Maximum automation with minimal user intervention.
- **Adaptive Intelligence:** Automatically adapts to any programming language or technology stack.
- **Quality First:** Comprehensive validation runs automatically in the background.

---

## 🚀 Quick Start: The `ai-dev` CLI

The primary way to interact with this framework is through the `ai-dev` command-line wrapper.

**To see all available commands, run:**
```bash
./ai-dev help
```

### Core Commands (15 Total Commands)

-   **`./ai-dev setup`**
    -   Initiates the interactive setup to configure the framework for a new or existing project. **This is the first command you should run.**

-   **`./ai-dev generate <path_to_prd.md>`**
    -   Takes a Product Requirements Document (PRD) and generates one or more executable Project-Response-Plan (PRP) files.

-   **`./ai-dev run <path_to_prp.md>`**
    -   Executes a specific PRP using the AI agent engine, which will then write code, run tests, and attempt to complete the task.

-   **`./ai-dev optimize <prompt_file>`**
    -   Optimizes prompt files using best practices and token economy analysis.

-   **`./ai-dev performance <subcommand>`**
    -   Performance optimization and monitoring for the framework.

### Quality & Security Commands

-   **`./ai-dev quality <path>`**
    -   Runs comprehensive quality validation with adaptive language support (30+ languages). Works automatically in the background.

-   **`./ai-dev audit`**
    -   Performs security audit and compliance checking across the entire framework.

-   **`./ai-dev precommit <subcommand>`**
    -   Manages pre-commit validation system. Subcommands: `validate`, `install-hooks`, `configure`, `report`.

### Framework Management Commands

-   **`./ai-dev sync <subcommand>`**
    -   Synchronizes framework with updates and community improvements.
    -   **`./ai-dev sync feedback`** - Integrate external community feedback from GitHub issues/PRs
    -   **`./ai-dev sync framework`** - Synchronize framework updates

-   **`./ai-dev configure [options]`**
    -   Interactive configuration management for framework settings.

-   **`./ai-dev diagnose`**
    -   Comprehensive health check and diagnostic reporting for the framework.

### Documentation & Maintenance Commands

-   **`./ai-dev generate-architecture`**
    -   Generate project architecture documentation.

-   **`./ai-dev update-architecture`**
    -   Update existing architecture documentation.

-   **`./ai-dev cleanup [options]`**
    -   Manage obsolete files and repository cleanup.

-   **`./ai-dev maintenance [level]`**
    -   Run periodic repository maintenance.

-   **`./ai-dev platform`**
    -   Show platform compatibility information.

### Utility Commands

-   **`./ai-dev help`**
    -   Show all available commands.

-   **`./ai-dev version`**
    -   Framework version and platform information.

-   **`./ai-dev status`**
    -   Current framework status.

---

## For AI Agents: How to Interpret User Requests

**Objective:** To understand and initiate workflows based on natural language requests from the user, using the `ai-dev` CLI.

**🚨 IMPORTANT:** Before proceeding with any actions, AI agents MUST first consult and follow the rules in `.ai_workflow/GLOBAL_AI_RULES.md`. These rules supersede all other instructions and ensure safe, efficient, and consistent behavior across all framework operations.

**Instructions for AI Agent:**

-   **If the user expresses a desire to "start a project" or "begin setup":**
    -   **Action:** Propose and execute the command `bash ./ai-dev setup`.
    -   **Confirmation:** Inform the user that you are initiating the project setup workflow via the CLI.

-   **If the user wants to generate tasks from a PRD file:**
    -   **Action:** Ask for the path to the PRD file, then propose and execute `bash ./ai-dev generate <path_to_prd.md>`.

-   **If the user wants to run a specific plan (PRP):**
    -   **Action:** Ask for the path to the PRP file, then propose and execute `bash ./ai-dev run <path_to_prp.md>`.

-   **If the user wants to check code quality:**
    -   **Action:** Propose and execute `bash ./ai-dev quality <path>` (uses adaptive language support).

-   **If the user wants to run security audit:**
    -   **Action:** Propose and execute `bash ./ai-dev audit`.

-   **If the user wants to integrate community feedback:**
    -   **Action:** Propose and execute `bash ./ai-dev sync feedback`.

-   **If the user wants to synchronize framework updates:**
    -   **Action:** Propose and execute `bash ./ai-dev sync framework`.

-   **If the user wants to configure the framework:**
    -   **Action:** Propose and execute `bash ./ai-dev configure`.

-   **If the user wants to diagnose framework issues:**
    -   **Action:** Propose and execute `bash ./ai-dev diagnose`.

-   **If the user asks a general question:**
    -   **Action:** Execute the workflow at `/.ai_workflow/workflows/assistant/01_ask_assistant.md`. (This is a temporary exception until it is integrated into the CLI).

## Automatic Features (Zero-Friction)

The framework now includes automatic background operations:
- **Quality validation** runs automatically during commits and critical operations
- **Pre-commit hooks** are auto-installed and configured
- **Language detection** adapts to project technology stack automatically
- **Security scanning** integrated into all workflows
- **Error recovery** attempts automatic resolution before escalation
EOF
        echo "   ✅ manager.md recreated successfully"
        return 0
    else
        echo "   ℹ️  manager.md already exists"
        return 1
    fi
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
        recreate_manager_md
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