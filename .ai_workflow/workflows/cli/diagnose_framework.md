# Diagnose Framework Workflow

## Purpose
Perform comprehensive health checks and diagnostics of the AI Development Framework to identify configuration issues, missing dependencies, permission problems, and provide actionable recommendations for optimal framework performance.

## When to Use
- Troubleshooting framework issues
- Before starting new projects
- After framework updates or configuration changes
- When workflows are failing unexpectedly
- For periodic health monitoring

## Prerequisites
- Framework directory structure exists
- Basic file system permissions
- Access to system command tools

## Diagnostic Categories

### 1. Framework Structure Validation
```bash
echo "=== Framework Structure Diagnostic ==="
echo ""

structure_issues=0
critical_issues=0

# Check core directories
required_dirs=(
    ".ai_workflow"
    ".ai_workflow/workflows"
    ".ai_workflow/workflows/setup"
    ".ai_workflow/workflows/run"
    ".ai_workflow/workflows/security"
    ".ai_workflow/workflows/quality"
    ".ai_workflow/workflows/monitoring"
    ".ai_workflow/workflows/cli"
    ".ai_workflow/cache"
    ".ai_workflow/config"
)

echo "📁 Directory Structure Check:"
for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "  ✅ $dir"
    else
        echo "  ❌ $dir (missing)"
        structure_issues=$((structure_issues + 1))
        if [[ "$dir" == ".ai_workflow" ]] || [[ "$dir" == ".ai_workflow/workflows" ]]; then
            critical_issues=$((critical_issues + 1))
        fi
    fi
done

# Check core files
echo ""
echo "📄 Core Files Check:"
required_files=(
    ".ai_workflow/GLOBAL_AI_RULES.md"
    ".ai_workflow/AGENT_GUIDE.md"
    ".ai_workflow/FRAMEWORK_GUIDE.md"
    "ai-dev"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (missing)"
        structure_issues=$((structure_issues + 1))
        if [[ "$file" == "ai-dev" ]]; then
            critical_issues=$((critical_issues + 1))
        fi
    fi
done

echo ""
echo "Structure Issues: $structure_issues (Critical: $critical_issues)"
```

### 2. Permissions and Access Control
```bash
echo "=== Permissions Diagnostic ==="
echo ""

permission_issues=0

# Check directory permissions
echo "🔐 Directory Permissions:"
check_dir_permission() {
    local dir="$1"
    local required_perm="$2"
    
    if [ -d "$dir" ]; then
        if [ -r "$dir" ] && [ -w "$dir" ] && [ -x "$dir" ]; then
            echo "  ✅ $dir (read/write/execute)"
        else
            echo "  ❌ $dir (insufficient permissions)"
            permission_issues=$((permission_issues + 1))
        fi
    else
        echo "  ⚠️  $dir (does not exist)"
    fi
}

check_dir_permission ".ai_workflow" "rwx"
check_dir_permission ".ai_workflow/cache" "rwx"
check_dir_permission ".ai_workflow/config" "rwx"
check_dir_permission ".ai_workflow/logs" "rwx"

# Check file permissions
echo ""
echo "📝 File Permissions:"
if [ -f "ai-dev" ]; then
    if [ -x "ai-dev" ]; then
        echo "  ✅ ai-dev (executable)"
    else
        echo "  ❌ ai-dev (not executable)"
        echo "    Fix: chmod +x ai-dev"
        permission_issues=$((permission_issues + 1))
    fi
else
    echo "  ❌ ai-dev (missing)"
fi

# Check write access to critical files
critical_files=(
    ".ai_workflow/cache/ai-dev.log"
    ".ai_workflow/config/framework.json"
)

for file in "${critical_files[@]}"; do
    dir=$(dirname "$file")
    if [ -d "$dir" ]; then
        if touch "$file" 2>/dev/null; then
            echo "  ✅ Can write to $file"
        else
            echo "  ❌ Cannot write to $file"
            permission_issues=$((permission_issues + 1))
        fi
    fi
done

echo ""
echo "Permission Issues: $permission_issues"
```

### 3. System Dependencies Check
```bash
echo "=== System Dependencies Diagnostic ==="
echo ""

dependency_issues=0

# Core system commands
echo "⚙️  Core System Dependencies:"
core_commands=("bash" "grep" "find" "mkdir" "touch" "cat" "chmod" "jq")

for cmd in "${core_commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        version=$(command -v "$cmd" 2>/dev/null && echo " ($(which "$cmd"))")
        echo "  ✅ $cmd$version"
    else
        echo "  ❌ $cmd (not found)"
        dependency_issues=$((dependency_issues + 1))
    fi
done

# Git dependency
echo ""
echo "📋 Version Control:"
if command -v git >/dev/null 2>&1; then
    git_version=$(git --version 2>/dev/null || echo "unknown")
    echo "  ✅ Git ($git_version)"
    
    # Check if we're in a git repository
    if git rev-parse --git-dir >/dev/null 2>&1; then
        echo "  ✅ Inside Git repository"
    else
        echo "  ⚠️  Not in a Git repository"
    fi
else
    echo "  ❌ Git (not found)"
    dependency_issues=$((dependency_issues + 1))
fi

# Language-specific tools
echo ""
echo "🛠️  Language-Specific Tools:"

# Detect project type for targeted dependency check
project_type=$(cat ".ai_workflow/cache/project_type.txt" 2>/dev/null || echo "unknown")

case "$project_type" in
    "javascript"|"typescript")
        for tool in node npm npx; do
            if command -v "$tool" >/dev/null 2>&1; then
                version=$($tool --version 2>/dev/null || echo "unknown")
                echo "  ✅ $tool ($version)"
            else
                echo "  ❌ $tool (not found)"
                dependency_issues=$((dependency_issues + 1))
            fi
        done
        ;;
    "python")
        for tool in python python3 pip pip3; do
            if command -v "$tool" >/dev/null 2>&1; then
                version=$($tool --version 2>/dev/null || echo "unknown")
                echo "  ✅ $tool ($version)"
            else
                echo "  ❌ $tool (not found)"
                dependency_issues=$((dependency_issues + 1))
            fi
        done
        ;;
    "php")
        for tool in php composer; do
            if command -v "$tool" >/dev/null 2>&1; then
                version=$($tool --version 2>/dev/null | head -1 || echo "unknown")
                echo "  ✅ $tool ($version)"
            else
                echo "  ❌ $tool (not found)"
                dependency_issues=$((dependency_issues + 1))
            fi
        done
        ;;
    "ruby")
        for tool in ruby gem bundle; do
            if command -v "$tool" >/dev/null 2>&1; then
                version=$($tool --version 2>/dev/null | head -1 || echo "unknown")
                echo "  ✅ $tool ($version)"
            else
                echo "  ❌ $tool (not found)"
                dependency_issues=$((dependency_issues + 1))
            fi
        done
        ;;
    "go")
        if command -v go >/dev/null 2>&1; then
            version=$(go version 2>/dev/null || echo "unknown")
            echo "  ✅ Go ($version)"
        else
            echo "  ❌ Go (not found)"
            dependency_issues=$((dependency_issues + 1))
        fi
        ;;
    "rust")
        for tool in rustc cargo; do
            if command -v "$tool" >/dev/null 2>&1; then
                version=$($tool --version 2>/dev/null || echo "unknown")
                echo "  ✅ $tool ($version)"
            else
                echo "  ❌ $tool (not found)"
                dependency_issues=$((dependency_issues + 1))
            fi
        done
        ;;
    "java")
        for tool in java javac mvn; do
            if command -v "$tool" >/dev/null 2>&1; then
                version=$($tool --version 2>/dev/null | head -1 || echo "unknown")
                echo "  ✅ $tool ($version)"
            else
                echo "  ❌ $tool (not found)"
                dependency_issues=$((dependency_issues + 1))
            fi
        done
        ;;
    *)
        echo "  ℹ️  No specific language detected for dependency check"
        ;;
esac

echo ""
echo "Dependency Issues: $dependency_issues"
```

### 4. Configuration Validation
```bash
echo "=== Configuration Diagnostic ==="
echo ""

config_issues=0

# Global configuration
echo "🔧 Global Configuration:"
global_config=".ai_workflow/config/framework.json"
if [ -f "$global_config" ]; then
    if jq empty "$global_config" 2>/dev/null; then
        echo "  ✅ Global config (valid JSON)"
        
        # Check required fields
        required_fields=(".framework_version" ".global_settings.default_quality_threshold")
        for field in "${required_fields[@]}"; do
            if jq -e "$field" "$global_config" >/dev/null 2>&1; then
                echo "  ✅ Required field: $field"
            else
                echo "  ❌ Missing field: $field"
                config_issues=$((config_issues + 1))
            fi
        done
    else
        echo "  ❌ Global config (invalid JSON)"
        config_issues=$((config_issues + 1))
    fi
else
    echo "  ⚠️  Global config (not found - will use defaults)"
fi

# Project configuration
echo ""
echo "📁 Project Configuration:"
project_config=".ai_workflow/config/project_config.json"
if [ -f "$project_config" ]; then
    if jq empty "$project_config" 2>/dev/null; then
        echo "  ✅ Project config (valid JSON)"
        
        # Validate quality thresholds
        quality_threshold=$(jq -r '.quality_settings.quality_threshold // "null"' "$project_config")
        if [ "$quality_threshold" != "null" ]; then
            if [ "$quality_threshold" -ge 0 ] && [ "$quality_threshold" -le 100 ]; then
                echo "  ✅ Quality threshold: $quality_threshold"
            else
                echo "  ❌ Invalid quality threshold: $quality_threshold (must be 0-100)"
                config_issues=$((config_issues + 1))
            fi
        fi
    else
        echo "  ❌ Project config (invalid JSON)"
        config_issues=$((config_issues + 1))
    fi
else
    echo "  ⚠️  Project config (not found - will use defaults)"
fi

# User configuration
echo ""
echo "👤 User Configuration:"
user_config="$HOME/.ai_framework/user_config.json"
if [ -f "$user_config" ]; then
    if jq empty "$user_config" 2>/dev/null; then
        echo "  ✅ User config (valid JSON)"
    else
        echo "  ❌ User config (invalid JSON)"
        config_issues=$((config_issues + 1))
    fi
else
    echo "  ⚠️  User config (not found - will use defaults)"
fi

echo ""
echo "Configuration Issues: $config_issues"
```

### 5. Workflow Integrity Check
```bash
echo "=== Workflow Integrity Diagnostic ==="
echo ""

workflow_issues=0

# Count workflows by category
echo "📋 Workflow Inventory:"
workflow_categories=(
    "setup"
    "run"
    "security"
    "quality"
    "monitoring"
    "cli"
    "sync"
    "common"
)

total_workflows=0
for category in "${workflow_categories[@]}"; do
    category_dir=".ai_workflow/workflows/$category"
    if [ -d "$category_dir" ]; then
        count=$(find "$category_dir" -name "*.md" | wc -l)
        echo "  📁 $category: $count workflows"
        total_workflows=$((total_workflows + count))
    else
        echo "  ❌ $category: directory missing"
        workflow_issues=$((workflow_issues + 1))
    fi
done

echo "  📊 Total workflows: $total_workflows"

# Check critical workflows
echo ""
echo "🔍 Critical Workflow Check:"
critical_workflows=(
    ".ai_workflow/workflows/setup/01_start_setup.md"
    ".ai_workflow/workflows/run/01_run_prp.md"
    ".ai_workflow/workflows/security/validate_input.md"
    ".ai_workflow/workflows/quality/quality_gates.md"
    ".ai_workflow/workflows/cli/configure_framework.md"
    ".ai_workflow/workflows/cli/diagnose_framework.md"
)

for workflow in "${critical_workflows[@]}"; do
    if [ -f "$workflow" ]; then
        # Basic syntax check for markdown workflows
        if grep -q "^## Purpose" "$workflow" && grep -q "^## When to Use" "$workflow"; then
            echo "  ✅ $(basename "$workflow")"
        else
            echo "  ⚠️  $(basename "$workflow") (missing standard sections)"
            workflow_issues=$((workflow_issues + 1))
        fi
    else
        echo "  ❌ $(basename "$workflow") (missing)"
        workflow_issues=$((workflow_issues + 1))
    fi
done

echo ""
echo "Workflow Issues: $workflow_issues"
```

### 6. Performance and Resource Check
```bash
echo "=== Performance Diagnostic ==="
echo ""

performance_issues=0

# Disk space check
echo "💾 Disk Space:"
cache_dir=".ai_workflow/cache"
if [ -d "$cache_dir" ]; then
    cache_size=$(du -sh "$cache_dir" 2>/dev/null | cut -f1)
    echo "  📁 Cache size: $cache_size"
    
    # Check available disk space
    available_space=$(df -h . | tail -1 | awk '{print $4}')
    echo "  💿 Available space: $available_space"
else
    echo "  ⚠️  Cache directory not found"
fi

# Memory usage (basic check)
echo ""
echo "🧠 Memory Usage:"
if command -v free >/dev/null 2>&1; then
    total_mem=$(free -h | grep "Mem:" | awk '{print $2}')
    available_mem=$(free -h | grep "Mem:" | awk '{print $7}')
    echo "  💾 Total memory: $total_mem"
    echo "  🆓 Available memory: $available_mem"
elif command -v vm_stat >/dev/null 2>&1; then
    # macOS
    echo "  🍎 macOS system detected"
    pages_free=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    echo "  🆓 Free pages: $pages_free"
fi

# Process check
echo ""
echo "⚡ Process Information:"
echo "  🔧 Current shell: $SHELL"
echo "  👤 User: $(whoami)"
echo "  🏠 Home: $HOME"
echo "  📂 Working directory: $(pwd)"

# Check for long-running processes that might interfere
if command -v pgrep >/dev/null 2>&1; then
    ai_processes=$(pgrep -f "ai-dev" | wc -l)
    if [ "$ai_processes" -gt 1 ]; then
        echo "  ⚠️  Multiple ai-dev processes detected: $ai_processes"
        performance_issues=$((performance_issues + 1))
    fi
fi

echo ""
echo "Performance Issues: $performance_issues"
```

### 7. Integration and External Services
```bash
echo "=== Integration Diagnostic ==="
echo ""

integration_issues=0

# Network connectivity
echo "🌐 Network Connectivity:"
if command -v curl >/dev/null 2>&1; then
    # Test connectivity to common package registries
    test_connectivity() {
        local url="$1"
        local name="$2"
        
        if curl -s --head --connect-timeout 5 "$url" >/dev/null 2>&1; then
            echo "  ✅ $name connectivity"
        else
            echo "  ❌ $name connectivity failed"
            integration_issues=$((integration_issues + 1))
        fi
    }
    
    test_connectivity "https://registry.npmjs.org/" "NPM Registry"
    test_connectivity "https://pypi.org/" "Python PyPI"
    test_connectivity "https://packagist.org/" "PHP Packagist"
    test_connectivity "https://rubygems.org/" "RubyGems"
else
    echo "  ⚠️  curl not available for connectivity tests"
fi

# Git configuration
echo ""
echo "📋 Git Integration:"
if command -v git >/dev/null 2>&1; then
    git_user=$(git config --get user.name 2>/dev/null || echo "not set")
    git_email=$(git config --get user.email 2>/dev/null || echo "not set")
    
    echo "  👤 Git user: $git_user"
    echo "  📧 Git email: $git_email"
    
    if [ "$git_user" = "not set" ] || [ "$git_email" = "not set" ]; then
        echo "  ⚠️  Git user/email not configured"
        integration_issues=$((integration_issues + 1))
    fi
fi

# Environment variables
echo ""
echo "🔐 Environment Variables:"
important_vars=("PATH" "HOME" "USER" "SHELL")

for var in "${important_vars[@]}"; do
    if [ -n "${!var}" ]; then
        echo "  ✅ $var is set"
    else
        echo "  ❌ $var is not set"
        integration_issues=$((integration_issues + 1))
    fi
done

echo ""
echo "Integration Issues: $integration_issues"
```

## Comprehensive Health Report

### Generate Summary Report
```bash
echo ""
echo "================================================================"
echo "                 🏥 FRAMEWORK HEALTH REPORT"
echo "================================================================"
echo ""

total_issues=$((structure_issues + permission_issues + dependency_issues + config_issues + workflow_issues + performance_issues + integration_issues))

# Overall health status
if [ "$critical_issues" -gt 0 ]; then
    health_status="🚨 CRITICAL"
    health_color="$RED"
elif [ "$total_issues" -eq 0 ]; then
    health_status="✅ EXCELLENT"
    health_color="$GREEN"
elif [ "$total_issues" -le 3 ]; then
    health_status="⚠️  GOOD"
    health_color="$YELLOW"
elif [ "$total_issues" -le 8 ]; then
    health_status="🔶 NEEDS ATTENTION"
    health_color="$YELLOW"
else
    health_status="❌ POOR"
    health_color="$RED"
fi

echo -e "Overall Health: ${health_color}${health_status}${NC}"
echo ""

# Issue breakdown
echo "Issue Breakdown:"
echo "  🏗️  Structure: $structure_issues issues ($critical_issues critical)"
echo "  🔐 Permissions: $permission_issues issues"
echo "  ⚙️  Dependencies: $dependency_issues issues"
echo "  🔧 Configuration: $config_issues issues"
echo "  📋 Workflows: $workflow_issues issues"
echo "  ⚡ Performance: $performance_issues issues"
echo "  🌐 Integration: $integration_issues issues"
echo ""
echo "Total Issues: $total_issues"

# Recommendations
echo ""
echo "🎯 RECOMMENDATIONS:"

if [ "$critical_issues" -gt 0 ]; then
    echo ""
    echo "🚨 CRITICAL ISSUES (Fix Immediately):"
    echo "  • Framework structure is incomplete or corrupted"
    echo "  • Run: ./ai-dev setup to reinitialize the framework"
    echo "  • Ensure ai-dev script exists and is executable"
fi

if [ "$structure_issues" -gt 0 ]; then
    echo ""
    echo "🏗️  Structure Issues:"
    echo "  • Create missing directories: mkdir -p .ai_workflow/{workflows,cache,config,logs}"
    echo "  • Restore missing workflow files from framework repository"
    echo "  • Verify framework installation integrity"
fi

if [ "$permission_issues" -gt 0 ]; then
    echo ""
    echo "🔐 Permission Issues:"
    echo "  • Fix ai-dev permissions: chmod +x ai-dev"
    echo "  • Ensure write access to .ai_workflow directories"
    echo "  • Check user permissions in current directory"
fi

if [ "$dependency_issues" -gt 0 ]; then
    echo ""
    echo "⚙️  Dependency Issues:"
    echo "  • Install missing system dependencies"
    echo "  • Update package managers for your language"
    echo "  • Ensure development tools are in PATH"
fi

if [ "$config_issues" -gt 0 ]; then
    echo ""
    echo "🔧 Configuration Issues:"
    echo "  • Run: ./ai-dev configure --interactive"
    echo "  • Fix invalid JSON in configuration files"
    echo "  • Reset configuration: ./ai-dev configure --reset"
fi

if [ "$workflow_issues" -gt 0 ]; then
    echo ""
    echo "📋 Workflow Issues:"
    echo "  • Restore missing workflow files"
    echo "  • Update framework to latest version"
    echo "  • Check workflow file integrity"
fi

if [ "$total_issues" -eq 0 ]; then
    echo ""
    echo "🎉 Framework is in excellent condition!"
    echo "  • All systems operational"
    echo "  • Ready for development work"
    echo "  • Consider running periodic diagnostics"
fi

# Save diagnostic report
echo ""
echo "💾 Diagnostic Report:"
report_file=".ai_workflow/logs/diagnostic_$(date +%Y%m%d_%H%M%S).txt"
{
    echo "AI Framework Diagnostic Report"
    echo "Generated: $(date)"
    echo "Status: $health_status"
    echo "Total Issues: $total_issues"
    echo ""
    echo "Issue Breakdown:"
    echo "Structure: $structure_issues"
    echo "Permissions: $permission_issues"
    echo "Dependencies: $dependency_issues"
    echo "Configuration: $config_issues"
    echo "Workflows: $workflow_issues"
    echo "Performance: $performance_issues"
    echo "Integration: $integration_issues"
} > "$report_file"

echo "Report saved: $report_file"

# Exit with appropriate code
if [ "$critical_issues" -gt 0 ]; then
    exit 2
elif [ "$total_issues" -gt 0 ]; then
    exit 1
else
    exit 0
fi
```

## Success Criteria
- Comprehensive health check covering all framework aspects
- Clear issue identification and categorization
- Actionable recommendations for problem resolution
- Detailed diagnostic report generation
- Appropriate exit codes for automation integration

## Dependencies
- System command availability (find, grep, etc.)
- File system read/write permissions
- Framework directory structure
- Optional: network connectivity for integration checks