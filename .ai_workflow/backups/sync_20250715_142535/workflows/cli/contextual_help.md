# Contextual Help Workflow

## Purpose
Provide intelligent, context-aware help and documentation that adapts to the user's current project type, framework, experience level, and specific situation to deliver the most relevant guidance and examples.

## When to Use
- User requests help or documentation
- Command fails and user needs guidance
- New user onboarding
- Complex workflow explanation needed
- Troubleshooting assistance

## Prerequisites
- Framework structure available
- Project type detection (optional but recommended)
- Access to help documentation

## Context Detection Engine

### Analyze Current Context
```bash
echo "=== Contextual Help System ==="
echo ""

# Gather context information
detect_context() {
    local context_info="{}"
    
    # Project context
    if [ -f ".ai_workflow/cache/project_type.txt" ]; then
        project_type=$(cat ".ai_workflow/cache/project_type.txt")
        frameworks=$(cat ".ai_workflow/cache/project_detection_meta.json" 2>/dev/null | jq -r '.frameworks // ""')
    else
        project_type="unknown"
        frameworks=""
    fi
    
    # User experience level (heuristic based on configuration)
    experience_level="beginner"
    if [ -f ".ai_workflow/config/project_config.json" ]; then
        custom_rules=$(jq -r '.workflow_customizations.custom_validation_rules | length' ".ai_workflow/config/project_config.json" 2>/dev/null || echo 0)
        if [ "$custom_rules" -gt 0 ]; then
            experience_level="advanced"
        elif [ -f "$HOME/.ai_framework/user_config.json" ]; then
            experience_level="intermediate"
        fi
    fi
    
    # Current working state
    working_state="normal"
    if [ -f ".ai_workflow/cache/last_error.log" ]; then
        working_state="error_recovery"
    elif [ -f ".ai_workflow/cache/workflow_state.json" ]; then
        working_state="workflow_active"
    fi
    
    # Available features
    available_features=""
    if [ -d ".ai_workflow/workflows/security" ]; then
        available_features="${available_features},security"
    fi
    if [ -d ".ai_workflow/workflows/quality" ]; then
        available_features="${available_features},quality"
    fi
    if [ -d ".ai_workflow/workflows/monitoring" ]; then
        available_features="${available_features},monitoring"
    fi
    
    # Create context object
    context_info=$(jq -n \
        --arg project_type "$project_type" \
        --arg frameworks "$frameworks" \
        --arg experience "$experience_level" \
        --arg state "$working_state" \
        --arg features "$available_features" \
        '{
            project_type: $project_type,
            frameworks: $frameworks,
            experience_level: $experience,
            working_state: $state,
            available_features: $features,
            timestamp: now
        }')
    
    echo "$context_info"
}

# Get current context
current_context=$(detect_context)
project_type=$(echo "$current_context" | jq -r '.project_type')
experience_level=$(echo "$current_context" | jq -r '.experience_level')
working_state=$(echo "$current_context" | jq -r '.working_state')
```

### Dynamic Help Content Generation
```bash
generate_contextual_help() {
    local help_topic="${1:-general}"
    local context="$2"
    
    echo "🎯 Context-Aware Help"
    echo "Project Type: $project_type"
    echo "Experience Level: $experience_level"
    echo "Current State: $working_state"
    echo ""
    
    case "$help_topic" in
        "general"|"commands")
            show_general_help "$context"
            ;;
        "setup")
            show_setup_help "$context"
            ;;
        "quality")
            show_quality_help "$context"
            ;;
        "security")
            show_security_help "$context"
            ;;
        "troubleshooting")
            show_troubleshooting_help "$context"
            ;;
        "examples")
            show_examples_help "$context"
            ;;
        *)
            show_topic_specific_help "$help_topic" "$context"
            ;;
    esac
}

show_general_help() {
    local context="$1"
    
    echo "📚 AI Framework Commands"
    echo ""
    
    if [ "$experience_level" = "beginner" ]; then
        echo "🚀 Getting Started (Beginner Guide):"
        echo ""
        echo "1. Initialize your project:"
        echo "   ./ai-dev setup"
        echo ""
        echo "2. Check framework health:"
        echo "   ./ai-dev diagnose"
        echo ""
        echo "3. Configure for your project:"
        echo "   ./ai-dev configure --interactive"
        echo ""
        echo "💡 Tip: Start with these commands to get familiar with the framework"
        echo ""
    fi
    
    echo "📋 Core Commands:"
    echo "  setup           - Initialize framework for your project"
    echo "  diagnose        - Check framework health and configuration"
    echo "  configure       - Set up project and user preferences"
    echo "  quality <path>  - Run quality validation on code"
    echo "  audit           - Perform security audit"
    echo "  status          - Show current framework status"
    echo ""
    
    # Project-specific suggestions
    if [ "$project_type" != "unknown" ]; then
        echo "🎯 Suggestions for $project_type projects:"
        echo ""
        
        case "$project_type" in
            "javascript"|"typescript")
                echo "  Quality Gates:"
                echo "    ./ai-dev quality src/           # Check your source code"
                echo "    ./ai-dev audit                  # Security scan with npm audit"
                echo ""
                echo "  Configuration:"
                echo "    ./ai-dev configure --project    # Set up ESLint, Prettier, Jest"
                ;;
            "python")
                echo "  Quality Gates:"
                echo "    ./ai-dev quality .              # Check with pylint, pytest"
                echo "    ./ai-dev audit                  # Security scan with bandit"
                echo ""
                echo "  Configuration:"
                echo "    ./ai-dev configure --project    # Set up pylint, black, pytest"
                ;;
            "php")
                echo "  Quality Gates:"
                echo "    ./ai-dev quality src/           # Check with phpcs, phpunit"
                echo "    ./ai-dev audit                  # Security scan with psalm"
                echo ""
                echo "  Configuration:"
                echo "    ./ai-dev configure --project    # Set up phpcs, php-cs-fixer"
                ;;
            "ruby")
                echo "  Quality Gates:"
                echo "    ./ai-dev quality .              # Check with rubocop, rspec"
                echo "    ./ai-dev audit                  # Security scan with brakeman"
                echo ""
                echo "  Configuration:"
                echo "    ./ai-dev configure --project    # Set up rubocop, rspec"
                ;;
        esac
        echo ""
    fi
    
    if [ "$experience_level" = "advanced" ]; then
        echo "🔧 Advanced Features:"
        echo "  --verbose       - Show detailed output"
        echo "  --dry-run       - Preview actions without executing"
        echo "  --force         - Bypass some validations"
        echo ""
        echo "  Examples:"
        echo "    ./ai-dev quality src/ --verbose"
        echo "    ./ai-dev configure --export=my-config.json"
        echo "    ./ai-dev diagnose --force"
        echo ""
    fi
    
    echo "📖 More Help:"
    echo "  ./ai-dev help setup         - Setup command help"
    echo "  ./ai-dev help quality       - Quality validation help"
    echo "  ./ai-dev help examples      - See usage examples"
    echo "  ./ai-dev help troubleshooting - Common issues and solutions"
}

show_setup_help() {
    local context="$1"
    
    echo "🚀 Project Setup Help"
    echo ""
    
    if [ "$working_state" = "error_recovery" ]; then
        echo "⚠️  Error Recovery Mode Detected"
        echo ""
        echo "It looks like you encountered an error. Setup can help fix issues:"
        echo "  ./ai-dev setup --reset      # Reset and reinitialize"
        echo "  ./ai-dev diagnose           # Identify specific problems"
        echo ""
    fi
    
    echo "📋 Setup Commands:"
    echo "  ./ai-dev setup              # Interactive project initialization"
    echo "  ./ai-dev setup --reset      # Reset configuration and restart"
    echo "  ./ai-dev setup --minimal    # Quick setup with defaults"
    echo ""
    
    echo "🔄 Setup Process:"
    echo "  1. 📁 Creates framework directory structure"
    echo "  2. 🔍 Detects project type and frameworks"
    echo "  3. ⚙️  Configures appropriate tools"
    echo "  4. 🔒 Sets up security policies"
    echo "  5. ✅ Validates installation"
    echo ""
    
    if [ "$project_type" != "unknown" ]; then
        echo "🎯 $project_type Project Setup:"
        echo ""
        
        case "$project_type" in
            "javascript"|"typescript")
                echo "  Will configure:"
                echo "  • ESLint for code quality"
                echo "  • Prettier for formatting"
                echo "  • Jest for testing"
                echo "  • npm audit for security"
                echo ""
                echo "  Prerequisites:"
                echo "  • Node.js and npm installed"
                echo "  • package.json file exists"
                ;;
            "python")
                echo "  Will configure:"
                echo "  • pylint for code quality"
                echo "  • black for formatting"
                echo "  • pytest for testing"
                echo "  • bandit for security"
                echo ""
                echo "  Prerequisites:"
                echo "  • Python 3.6+ installed"
                echo "  • pip package manager"
                echo "  • requirements.txt or pyproject.toml"
                ;;
        esac
        echo ""
    fi
    
    echo "🔧 Post-Setup Recommendations:"
    echo "  1. Run: ./ai-dev diagnose"
    echo "  2. Configure: ./ai-dev configure --interactive"
    echo "  3. Test: ./ai-dev quality ."
    echo ""
    
    if [ "$experience_level" = "beginner" ]; then
        echo "💡 Beginner Tips:"
        echo "  • Setup is safe to run multiple times"
        echo "  • Use --dry-run to preview changes"
        echo "  • Configuration can be changed later"
        echo ""
    fi
}

show_quality_help() {
    local context="$1"
    
    echo "🏆 Quality Validation Help"
    echo ""
    
    echo "📋 Quality Commands:"
    echo "  ./ai-dev quality .          # Check entire project"
    echo "  ./ai-dev quality src/       # Check specific directory"
    echo "  ./ai-dev quality file.js    # Check specific file"
    echo ""
    
    echo "🔍 Quality Gates:"
    echo "  1. 📝 Syntax validation (linting)"
    echo "  2. 🧪 Test execution"
    echo "  3. 🔒 Security scanning"
    echo "  4. 📊 Code coverage analysis"
    echo "  5. 🔄 Complexity measurement"
    echo ""
    
    if [ "$project_type" != "unknown" ]; then
        echo "🎯 $project_type Quality Tools:"
        echo ""
        
        case "$project_type" in
            "javascript"|"typescript")
                echo "  Linting: ESLint with recommended rules"
                echo "  Testing: Jest with coverage reporting"
                echo "  Security: npm audit for vulnerabilities"
                echo "  Formatting: Prettier for consistent style"
                echo ""
                echo "  Custom configuration in:"
                echo "  • .eslintrc.js - ESLint rules"
                echo "  • jest.config.js - Jest settings"
                echo "  • .prettierrc - Prettier options"
                ;;
            "python")
                echo "  Linting: pylint with PEP 8 standards"
                echo "  Testing: pytest with coverage"
                echo "  Security: bandit for security issues"
                echo "  Formatting: black for code style"
                echo ""
                echo "  Custom configuration in:"
                echo "  • .pylintrc - Pylint settings"
                echo "  • pytest.ini - pytest configuration"
                echo "  • pyproject.toml - black and other tools"
                ;;
            "php")
                echo "  Linting: PHP_CodeSniffer (phpcs)"
                echo "  Testing: PHPUnit for unit tests"
                echo "  Security: Psalm for static analysis"
                echo "  Formatting: PHP CS Fixer"
                echo ""
                echo "  Custom configuration in:"
                echo "  • phpcs.xml - CodeSniffer rules"
                echo "  • phpunit.xml - PHPUnit settings"
                echo "  • psalm.xml - Psalm configuration"
                ;;
        esac
        echo ""
    fi
    
    echo "⚙️  Quality Thresholds:"
    echo "  • Overall Quality: 85/100 (configurable)"
    echo "  • Test Coverage: 80% (configurable)"
    echo "  • Complexity: Max 10 per function"
    echo "  • Duplication: Max 3% of codebase"
    echo ""
    
    echo "🔧 Configuration:"
    echo "  ./ai-dev configure --interactive    # Set custom thresholds"
    echo "  Edit: .ai_workflow/config/project_config.json"
    echo ""
    
    if [ "$experience_level" = "advanced" ]; then
        echo "🚀 Advanced Options:"
        echo "  --verbose       Show detailed quality reports"
        echo "  --skip-tests    Skip test execution"
        echo "  --security-only Run only security checks"
        echo ""
        echo "  Examples:"
        echo "    ./ai-dev quality src/ --verbose"
        echo "    ./ai-dev quality . --skip-tests"
        echo ""
    fi
}

show_troubleshooting_help() {
    local context="$1"
    
    echo "🔧 Troubleshooting Guide"
    echo ""
    
    # Check for common issues based on current state
    if [ "$working_state" = "error_recovery" ]; then
        echo "🚨 Current Issue Detection:"
        echo ""
        if [ -f ".ai_workflow/cache/last_error.log" ]; then
            echo "Recent error found. Top suggestions:"
            echo "  1. ./ai-dev diagnose        # Identify the problem"
            echo "  2. ./ai-dev setup --reset   # Reset configuration"
            echo "  3. ./ai-dev help examples   # See working examples"
            echo ""
        fi
    fi
    
    echo "❓ Common Issues and Solutions:"
    echo ""
    
    echo "🔴 Framework Not Working:"
    echo "  Problem: ./ai-dev command not found"
    echo "  Solution:"
    echo "    chmod +x ai-dev"
    echo "    ./ai-dev diagnose"
    echo ""
    
    echo "🔴 Permission Denied:"
    echo "  Problem: Cannot write to .ai_workflow directory"
    echo "  Solution:"
    echo "    sudo chown -R \$USER .ai_workflow"
    echo "    chmod -R u+w .ai_workflow"
    echo ""
    
    echo "🔴 Missing Dependencies:"
    echo "  Problem: Command 'xyz' not found"
    echo "  Solution:"
    
    case "$project_type" in
        "javascript"|"typescript")
            echo "    npm install -g eslint prettier jest"
            echo "    # Or install project dependencies:"
            echo "    npm install"
            ;;
        "python")
            echo "    pip install pylint black pytest bandit"
            echo "    # Or install from requirements:"
            echo "    pip install -r requirements.txt"
            ;;
        "php")
            echo "    composer global require squizlabs/php_codesniffer"
            echo "    composer global require friendsofphp/php-cs-fixer"
            ;;
        "ruby")
            echo "    gem install rubocop rspec"
            echo "    # Or install from Gemfile:"
            echo "    bundle install"
            ;;
        *)
            echo "    ./ai-dev diagnose  # Check missing dependencies"
            ;;
    esac
    echo ""
    
    echo "🔴 Configuration Issues:"
    echo "  Problem: Invalid configuration or settings"
    echo "  Solution:"
    echo "    ./ai-dev configure --reset"
    echo "    ./ai-dev configure --interactive"
    echo ""
    
    echo "🔴 Quality Gates Failing:"
    echo "  Problem: Quality validation always fails"
    echo "  Solution:"
    echo "    ./ai-dev quality . --verbose  # See detailed errors"
    echo "    ./ai-dev configure            # Adjust thresholds"
    echo "    # Fix code issues one by one"
    echo ""
    
    echo "🔴 Slow Performance:"
    echo "  Problem: Commands taking too long"
    echo "  Solution:"
    echo "    ./ai-dev quality src/ --skip-tests  # Skip slow tests"
    echo "    # Clean cache: rm -rf .ai_workflow/cache/*"
    echo "    ./ai-dev configure                  # Adjust cache settings"
    echo ""
    
    echo "🛠️  Diagnostic Commands:"
    echo "  ./ai-dev diagnose           # Full health check"
    echo "  ./ai-dev status             # Quick status overview"
    echo "  ./ai-dev version            # Check framework version"
    echo ""
    
    echo "📞 Getting More Help:"
    echo "  1. Check logs: .ai_workflow/logs/"
    echo "  2. Review configuration: .ai_workflow/config/"
    echo "  3. Run with --verbose for detailed output"
    echo "  4. Reset and try again: ./ai-dev setup --reset"
    echo ""
    
    if [ "$experience_level" = "beginner" ]; then
        echo "💡 Beginner Tips:"
        echo "  • Don't panic! Most issues are configuration-related"
        echo "  • Always start with './ai-dev diagnose'"
        echo "  • Use --dry-run to preview changes"
        echo "  • The framework is designed to be safe to reset"
        echo ""
    fi
}

show_examples_help() {
    local context="$1"
    
    echo "📚 Usage Examples"
    echo ""
    
    echo "🚀 Getting Started Workflow:"
    echo "  # 1. Initialize new project"
    echo "  ./ai-dev setup"
    echo ""
    echo "  # 2. Check everything is working"
    echo "  ./ai-dev diagnose"
    echo ""
    echo "  # 3. Configure for your needs"
    echo "  ./ai-dev configure --interactive"
    echo ""
    echo "  # 4. Run quality checks"
    echo "  ./ai-dev quality ."
    echo ""
    
    if [ "$project_type" != "unknown" ]; then
        echo "🎯 $project_type Project Examples:"
        echo ""
        
        case "$project_type" in
            "javascript"|"typescript")
                echo "  # Setup and validate React project"
                echo "  ./ai-dev setup"
                echo "  ./ai-dev quality src/"
                echo "  ./ai-dev audit"
                echo ""
                echo "  # Configure for TypeScript"
                echo "  ./ai-dev configure --project"
                echo "  # Quality check specific files"
                echo "  ./ai-dev quality src/components/"
                echo ""
                echo "  # Before deployment"
                echo "  ./ai-dev quality . --verbose"
                echo "  ./ai-dev audit"
                ;;
            "python")
                echo "  # Setup Django project"
                echo "  ./ai-dev setup"
                echo "  ./ai-dev configure --project"
                echo "  ./ai-dev quality myapp/"
                echo ""
                echo "  # Run security scan"
                echo "  ./ai-dev audit"
                echo ""
                echo "  # Check specific module"
                echo "  ./ai-dev quality myapp/models.py"
                ;;
            "php")
                echo "  # Setup Laravel project"
                echo "  ./ai-dev setup"
                echo "  ./ai-dev quality app/"
                echo ""
                echo "  # Security audit"
                echo "  ./ai-dev audit"
                echo ""
                echo "  # Check controllers"
                echo "  ./ai-dev quality app/Http/Controllers/"
                ;;
        esac
        echo ""
    fi
    
    echo "🔧 Configuration Examples:"
    echo "  # Interactive setup"
    echo "  ./ai-dev configure --interactive"
    echo ""
    echo "  # Export/import configuration"
    echo "  ./ai-dev configure --export=team-config.json"
    echo "  ./ai-dev configure --import=team-config.json"
    echo ""
    echo "  # Reset to defaults"
    echo "  ./ai-dev configure --reset"
    echo ""
    
    echo "🔍 Debugging Examples:"
    echo "  # Detailed output"
    echo "  ./ai-dev quality . --verbose"
    echo ""
    echo "  # Preview without executing"
    echo "  ./ai-dev setup --dry-run"
    echo ""
    echo "  # Force execution (skip some validations)"
    echo "  ./ai-dev quality . --force"
    echo ""
    
    echo "📊 Status and Monitoring:"
    echo "  # Quick status check"
    echo "  ./ai-dev status"
    echo ""
    echo "  # Full diagnostic"
    echo "  ./ai-dev diagnose"
    echo ""
    echo "  # Version information"
    echo "  ./ai-dev version"
    echo ""
    
    if [ "$experience_level" = "advanced" ]; then
        echo "🚀 Advanced Workflows:"
        echo "  # Custom quality thresholds"
        echo "  ./ai-dev configure --project"
        echo "  # Edit .ai_workflow/config/project_config.json"
        echo ""
        echo "  # Selective quality checks"
        echo "  ./ai-dev quality src/ --skip-tests"
        echo "  ./ai-dev audit --security-only"
        echo ""
        echo "  # Automation friendly"
        echo "  ./ai-dev quality . --quiet && echo 'Quality passed'"
        echo ""
    fi
}

show_topic_specific_help() {
    local topic="$1"
    local context="$2"
    
    case "$topic" in
        "commands")
            show_general_help "$context"
            ;;
        "config"|"configuration")
            echo "🔧 Configuration Help"
            echo ""
            echo "Configuration files:"
            echo "  Global: .ai_workflow/config/framework.json"
            echo "  Project: .ai_workflow/config/project_config.json"
            echo "  User: ~/.ai_framework/user_config.json"
            echo ""
            echo "Commands:"
            echo "  ./ai-dev configure --interactive"
            echo "  ./ai-dev configure --project"
            echo "  ./ai-dev configure --user"
            echo "  ./ai-dev configure --reset"
            ;;
        "workflows")
            echo "📋 Workflow Help"
            echo ""
            echo "Available workflows:"
            find .ai_workflow/workflows -name "*.md" | while read -r workflow; do
                workflow_name=$(basename "$workflow" .md)
                echo "  • $workflow_name"
            done
            ;;
        *)
            echo "❓ Unknown Help Topic: $topic"
            echo ""
            echo "Available help topics:"
            echo "  general, setup, quality, security, troubleshooting"
            echo "  examples, configuration, workflows"
            echo ""
            echo "Usage: ./ai-dev help <topic>"
            ;;
    esac
}
```

### Help Request Router
```bash
# Parse help request and route to appropriate handler
help_topic="${1:-general}"

# Special handling for error recovery
if [ "$working_state" = "error_recovery" ]; then
    echo "🚨 Error Recovery Mode - Contextual Help"
    echo ""
    help_topic="troubleshooting"
fi

# Generate contextual help
generate_contextual_help "$help_topic" "$current_context"

echo ""
echo "💡 Need more specific help?"
echo "  ./ai-dev help <topic>    # Get help on specific topic"
echo "  ./ai-dev diagnose        # Check for issues"
echo "  ./ai-dev status          # Quick status overview"
echo ""

# Save help context for future reference
help_context_file=".ai_workflow/cache/help_context.json"
echo "$current_context" | jq --arg topic "$help_topic" '. + {help_topic: $topic, help_timestamp: now}' > "$help_context_file"
```

## Success Criteria
- Context-aware help content
- Project-type specific guidance
- Experience-level appropriate explanations
- Working state awareness
- Actionable examples and solutions
- Integration with troubleshooting workflow

## Dependencies
- Project type detection system
- Configuration management system
- Framework diagnostic capabilities
- jq for JSON processing