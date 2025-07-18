# Configure Framework Workflow

## Purpose
Manage framework configuration settings at both project and user levels, including quality thresholds, security policies, monitoring preferences, and tool customizations to optimize the framework for specific environments and requirements.

## When to Use
- Initial framework setup for new projects
- Updating configuration after environment changes
- Customizing quality gates and security policies
- Setting up user-specific preferences
- Configuring CI/CD integration settings

## Prerequisites
- Framework properly installed
- Write permissions to configuration directories
- Valid user and project context

## Input Parameters
- `CONFIGURE_OPTIONS`: Space-separated configuration options from CLI
- Available options: --user, --project, --reset, --interactive, --export, --import

## Configuration Levels

### Global Framework Configuration
```bash
# Framework-wide settings (affects all projects)
GLOBAL_CONFIG_DIR="${AI_WORKFLOW_DIR}/config"
GLOBAL_CONFIG_FILE="${GLOBAL_CONFIG_DIR}/framework.json"

# Create global config directory
mkdir -p "$GLOBAL_CONFIG_DIR"

# Default global configuration with comprehensive language support
create_default_global_config() {
    cat > "$GLOBAL_CONFIG_FILE" << 'EOF'
{
    "framework_version": "2.0",
    "last_updated": "",
    "global_settings": {
        "default_quality_threshold": 80,
        "security_level": "high",
        "token_monitoring": true,
        "auto_backup": true,
        "log_level": "info",
        "cache_duration_hours": 24
    },
    "default_tools": {
        "javascript": {
            "linter": "eslint",
            "formatter": "prettier",
            "test_runner": "jest",
            "package_manager": "npm",
            "build_tool": "webpack"
        },
        "typescript": {
            "linter": "eslint",
            "formatter": "prettier",
            "test_runner": "jest",
            "package_manager": "npm",
            "build_tool": "webpack",
            "type_checker": "tsc"
        },
        "python": {
            "linter": "pylint",
            "formatter": "black",
            "test_runner": "pytest",
            "package_manager": "pip",
            "type_checker": "mypy",
            "security_scanner": "bandit"
        },
        "php": {
            "linter": "phpcs",
            "formatter": "php-cs-fixer",
            "test_runner": "phpunit",
            "package_manager": "composer",
            "static_analyzer": "phpstan",
            "security_scanner": "psalm"
        },
        "ruby": {
            "linter": "rubocop",
            "formatter": "rubocop",
            "test_runner": "rspec",
            "package_manager": "gem",
            "framework_tools": {
                "rails": ["rails", "rake", "bundle"]
            }
        },
        "java": {
            "linter": "checkstyle",
            "formatter": "google-java-format",
            "test_runner": "junit",
            "build_tool": "maven",
            "alternative_build": "gradle",
            "static_analyzer": "spotbugs"
        },
        "go": {
            "linter": "golangci-lint",
            "formatter": "gofmt",
            "test_runner": "go test",
            "package_manager": "go mod",
            "build_tool": "go build",
            "security_scanner": "gosec"
        },
        "rust": {
            "linter": "clippy",
            "formatter": "rustfmt",
            "test_runner": "cargo test",
            "package_manager": "cargo",
            "build_tool": "cargo build",
            "security_scanner": "cargo audit"
        },
        "csharp": {
            "linter": "dotnet format",
            "formatter": "dotnet format",
            "test_runner": "dotnet test",
            "package_manager": "nuget",
            "build_tool": "dotnet build",
            "static_analyzer": "roslyn"
        },
        "swift": {
            "linter": "swiftlint",
            "formatter": "swift-format",
            "test_runner": "swift test",
            "package_manager": "swift package",
            "build_tool": "xcodebuild"
        },
        "kotlin": {
            "linter": "ktlint",
            "formatter": "ktlint",
            "test_runner": "junit",
            "build_tool": "gradle",
            "package_manager": "maven"
        },
        "scala": {
            "linter": "scalastyle",
            "formatter": "scalafmt",
            "test_runner": "scalatest",
            "build_tool": "sbt",
            "package_manager": "sbt"
        },
        "cpp": {
            "linter": "cppcheck",
            "formatter": "clang-format",
            "test_runner": "gtest",
            "build_tool": "cmake",
            "static_analyzer": "clang-static-analyzer"
        },
        "dart": {
            "linter": "dart analyze",
            "formatter": "dart format",
            "test_runner": "dart test",
            "package_manager": "pub",
            "build_tool": "dart compile"
        }
    },
    "framework_specific_tools": {
        "web_frameworks": {
            "react": {
                "dev_server": "npm start",
                "build": "npm run build",
                "test": "npm test",
                "linter": "eslint-plugin-react"
            },
            "vue": {
                "dev_server": "npm run serve",
                "build": "npm run build",
                "test": "npm run test:unit",
                "linter": "eslint-plugin-vue"
            },
            "angular": {
                "dev_server": "ng serve",
                "build": "ng build",
                "test": "ng test",
                "linter": "@angular-eslint"
            },
            "next": {
                "dev_server": "npm run dev",
                "build": "npm run build",
                "test": "npm test"
            },
            "nuxt": {
                "dev_server": "npm run dev",
                "build": "npm run build",
                "test": "npm test"
            }
        },
        "backend_frameworks": {
            "express": {
                "dev_server": "npm run dev",
                "test": "npm test",
                "security": "npm audit"
            },
            "fastapi": {
                "dev_server": "uvicorn main:app --reload",
                "test": "pytest",
                "security": "safety check"
            },
            "django": {
                "dev_server": "python manage.py runserver",
                "test": "python manage.py test",
                "migrations": "python manage.py migrate",
                "security": "bandit -r ."
            },
            "flask": {
                "dev_server": "flask run",
                "test": "pytest",
                "security": "bandit -r ."
            },
            "rails": {
                "dev_server": "rails server",
                "test": "rspec",
                "migrations": "rails db:migrate",
                "security": "brakeman"
            },
            "laravel": {
                "dev_server": "php artisan serve",
                "test": "phpunit",
                "migrations": "php artisan migrate",
                "security": "psalm --taint-analysis"
            },
            "symfony": {
                "dev_server": "symfony serve",
                "test": "phpunit",
                "security": "symfony security:check"
            },
            "spring": {
                "dev_server": "mvn spring-boot:run",
                "test": "mvn test",
                "build": "mvn clean package"
            },
            "gin": {
                "dev_server": "go run main.go",
                "test": "go test ./...",
                "build": "go build"
            }
        },
        "mobile_frameworks": {
            "react_native": {
                "dev_server": "npx react-native start",
                "test": "npm test",
                "build_android": "npx react-native run-android",
                "build_ios": "npx react-native run-ios"
            },
            "flutter": {
                "dev_server": "flutter run",
                "test": "flutter test",
                "build": "flutter build"
            },
            "ionic": {
                "dev_server": "ionic serve",
                "test": "npm test",
                "build": "ionic build"
            }
        }
    },
    "security_policies": {
        "require_dependency_scan": true,
        "block_critical_vulnerabilities": true,
        "allowed_file_extensions": [
            ".md", ".json", ".txt", ".yml", ".yaml",
            ".py", ".js", ".ts", ".php", ".rb", ".java", 
            ".go", ".rs", ".cs", ".swift", ".kt", ".scala", 
            ".cpp", ".c", ".h", ".dart", ".html", ".css", 
            ".scss", ".less", ".sql", ".sh", ".bash"
        ],
        "blocked_directories": [
            "node_modules", ".git", "dist", "build", "target", 
            ".gradle", ".idea", ".vscode", "__pycache__", 
            "vendor", "storage", "var/cache", "tmp"
        ]
    }
}
EOF
    echo "$(date '+%Y-%m-%d %H:%M:%S')" | jq -r '.' > /tmp/timestamp.json
    jq --slurpfile timestamp /tmp/timestamp.json '.last_updated = $timestamp[0]' "$GLOBAL_CONFIG_FILE" > /tmp/config.json && mv /tmp/config.json "$GLOBAL_CONFIG_FILE"
    rm -f /tmp/timestamp.json
}
```

### Language-Specific Configuration Detection
```bash
detect_and_configure_language_tools() {
    local project_type="$1"
    local detected_frameworks="$2"
    
    # Get base tools for the detected language
    base_tools=$(jq -r --arg lang "$project_type" '.default_tools[$lang] // {}' "$GLOBAL_CONFIG_FILE")
    
    if [ "$base_tools" = "{}" ]; then
        echo "LANGUAGE_WARNING: No default tools configured for $project_type"
        echo "Supported languages: $(jq -r '.default_tools | keys | join(", ")' "$GLOBAL_CONFIG_FILE")"
        return 1
    fi
    
    # Enhanced framework detection and tool configuration
    framework_tools="{}"
    
    # Web frameworks
    for framework in react vue angular next nuxt; do
        if echo "$detected_frameworks" | grep -q "$framework"; then
            fw_tools=$(jq -r --arg fw "$framework" '.framework_specific_tools.web_frameworks[$fw] // {}' "$GLOBAL_CONFIG_FILE")
            framework_tools=$(echo "$framework_tools" | jq --argjson tools "$fw_tools" '. + $tools')
        fi
    done
    
    # Backend frameworks
    for framework in express fastapi django flask rails laravel symfony spring gin; do
        if echo "$detected_frameworks" | grep -q "$framework"; then
            fw_tools=$(jq -r --arg fw "$framework" '.framework_specific_tools.backend_frameworks[$fw] // {}' "$GLOBAL_CONFIG_FILE")
            framework_tools=$(echo "$framework_tools" | jq --argjson tools "$fw_tools" '. + $tools')
        fi
    done
    
    # Mobile frameworks
    for framework in react_native flutter ionic; do
        if echo "$detected_frameworks" | grep -q "$framework"; then
            fw_tools=$(jq -r --arg fw "$framework" '.framework_specific_tools.mobile_frameworks[$fw] // {}' "$GLOBAL_CONFIG_FILE")
            framework_tools=$(echo "$framework_tools" | jq --argjson tools "$fw_tools" '. + $tools')
        fi
    done
    
    # Merge base tools with framework-specific tools
    combined_tools=$(echo "$base_tools" | jq --argjson fw "$framework_tools" '. + $fw')
    
    echo "LANGUAGE_TOOLS_CONFIGURED: $project_type"
    echo "BASE_TOOLS: $(echo "$base_tools" | jq -c '.')"
    echo "FRAMEWORK_TOOLS: $(echo "$framework_tools" | jq -c '.')"
    echo "COMBINED_TOOLS: $(echo "$combined_tools" | jq -c '.')"
    
    # Store in project configuration
    if [ -f "$PROJECT_CONFIG_FILE" ]; then
        jq --argjson tools "$combined_tools" '.project_tools = $tools' "$PROJECT_CONFIG_FILE" > /tmp/project_config.json && mv /tmp/project_config.json "$PROJECT_CONFIG_FILE"
    fi
}
```

### Smart Configuration Assistant
```bash
smart_configuration_assistant() {
    echo "=== Smart Configuration Assistant ==="
    echo "Analyzing your project to suggest optimal configuration..."
    echo ""
    
    # Detect project characteristics
    project_type=$(cat "${AI_WORKFLOW_DIR}/cache/project_type.txt" 2>/dev/null || echo "unknown")
    detected_frameworks=$(cat "${AI_WORKFLOW_DIR}/cache/project_detection_meta.json" 2>/dev/null | jq -r '.frameworks // ""')
    
    echo "Detected project type: $project_type"
    echo "Detected frameworks: $detected_frameworks"
    echo ""
    
    # Language-specific suggestions
    case "$project_type" in
        "php")
            echo "📋 PHP Project Configuration Suggestions:"
            echo "  • Linter: PHP_CodeSniffer (phpcs) for PSR standards"
            echo "  • Formatter: PHP CS Fixer for automatic code formatting"
            echo "  • Testing: PHPUnit for unit testing"
            echo "  • Security: Psalm for static analysis and security"
            echo "  • Package Manager: Composer for dependency management"
            
            if echo "$detected_frameworks" | grep -q "laravel"; then
                echo "  • Laravel specific: Artisan commands, Eloquent ORM"
                echo "  • Security: Laravel security checker, Brakeman equivalent"
            fi
            
            if echo "$detected_frameworks" | grep -q "symfony"; then
                echo "  • Symfony specific: Console commands, Doctrine ORM"
                echo "  • Security: Symfony security checker"
            fi
            ;;
            
        "ruby")
            echo "📋 Ruby Project Configuration Suggestions:"
            echo "  • Linter: RuboCop for code style and quality"
            echo "  • Testing: RSpec for behavior-driven testing"
            echo "  • Package Manager: Bundler for gem management"
            echo "  • Security: Brakeman for Rails security analysis"
            
            if echo "$detected_frameworks" | grep -q "rails"; then
                echo "  • Rails specific: Rails generators, migrations, routes"
                echo "  • Testing: RSpec-Rails for Rails-specific testing"
                echo "  • Security: Rails security scanner, bundler-audit"
            fi
            ;;
            
        "go")
            echo "📋 Go Project Configuration Suggestions:"
            echo "  • Linter: golangci-lint (includes multiple linters)"
            echo "  • Formatter: gofmt (built-in Go formatter)"
            echo "  • Testing: Built-in go test framework"
            echo "  • Security: gosec for security analysis"
            echo "  • Build: go build with module support"
            ;;
            
        "rust")
            echo "📋 Rust Project Configuration Suggestions:"
            echo "  • Linter: Clippy for idiomatic Rust code"
            echo "  • Formatter: rustfmt for consistent formatting"
            echo "  • Testing: Built-in cargo test framework"
            echo "  • Security: cargo audit for vulnerability scanning"
            echo "  • Build: cargo build with workspace support"
            ;;
            
        "java")
            echo "📋 Java Project Configuration Suggestions:"
            echo "  • Linter: Checkstyle for code style enforcement"
            echo "  • Formatter: Google Java Format"
            echo "  • Testing: JUnit 5 for modern testing"
            echo "  • Build: Maven or Gradle (detected: $detected_frameworks)"
            echo "  • Security: SpotBugs for bug detection"
            
            if echo "$detected_frameworks" | grep -q "spring"; then
                echo "  • Spring specific: Spring Boot DevTools, Actuator"
                echo "  • Testing: Spring Boot Test for integration testing"
            fi
            ;;
            
        "csharp")
            echo "📋 C# Project Configuration Suggestions:"
            echo "  • Linter: Roslyn analyzers for code quality"
            echo "  • Formatter: dotnet format for consistent style"
            echo "  • Testing: xUnit or NUnit for unit testing"
            echo "  • Build: dotnet CLI or MSBuild"
            echo "  • Package Manager: NuGet for dependencies"
            ;;
            
        "swift")
            echo "📋 Swift Project Configuration Suggestions:"
            echo "  • Linter: SwiftLint for style and conventions"
            echo "  • Formatter: swift-format for code formatting"
            echo "  • Testing: XCTest for unit and UI testing"
            echo "  • Build: Xcode or Swift Package Manager"
            ;;
            
        *)
            echo "📋 General Project Configuration:"
            echo "  • Consider adding your language to the framework"
            echo "  • Check available tools: $(jq -r '.default_tools | keys | join(", ")' "$GLOBAL_CONFIG_FILE")"
            ;;
    esac
    
    echo ""
    read -p "Would you like to apply these suggestions automatically? (y/n): " apply_suggestions
    
    if [ "$apply_suggestions" = "y" ]; then
        detect_and_configure_language_tools "$project_type" "$detected_frameworks"
        echo "✅ Configuration applied based on project analysis"
    fi
}
```

### User-Level Configuration
```bash
# User-specific settings (overrides global)
USER_CONFIG_DIR="${HOME}/.ai_workflow"
USER_CONFIG_FILE="${USER_CONFIG_DIR}/user_config.json"

create_user_config() {
    mkdir -p "$USER_CONFIG_DIR"
    
    cat > "$USER_CONFIG_FILE" << 'EOF'
{
    "user_preferences": {
        "preferred_editor": "code",
        "notification_level": "normal",
        "auto_quality_check": true,
        "preferred_languages": [],
        "custom_workflows_enabled": true,
        "theme": "default"
    },
    "personal_tools": {
        "git_username": "",
        "git_email": "",
        "preferred_package_managers": {
            "javascript": "npm",
            "python": "pip",
            "php": "composer",
            "ruby": "gem",
            "java": "maven",
            "go": "go mod",
            "rust": "cargo",
            "csharp": "nuget"
        },
        "code_style_preference": "language_default"
    },
    "integration_settings": {
        "github_enabled": false,
        "gitlab_enabled": false,
        "slack_notifications": false,
        "email_reports": false,
        "ide_integration": true
    },
    "custom_commands": {},
    "language_overrides": {}
}
EOF
    
    echo "USER_CONFIG_CREATED: $USER_CONFIG_FILE"
}
```

### Project-Level Configuration
```bash
# Project-specific settings (highest priority)
PROJECT_CONFIG_FILE="${AI_WORKFLOW_DIR}/config/project_config.json"

create_project_config() {
    mkdir -p "${AI_WORKFLOW_DIR}/config"
    
    # Detect project characteristics for smart defaults
    project_type=$(cat "${AI_WORKFLOW_DIR}/cache/project_type.txt" 2>/dev/null || echo "unknown")
    detected_frameworks=$(cat "${AI_WORKFLOW_DIR}/cache/project_detection_meta.json" 2>/dev/null | jq -r '.frameworks // ""')
    
    cat > "$PROJECT_CONFIG_FILE" << EOF
{
    "project_info": {
        "name": "$(basename "$(pwd)")",
        "type": "$project_type",
        "frameworks": "$detected_frameworks",
        "created_date": "$(date '+%Y-%m-%d')",
        "framework_version": "2.0"
    },
    "quality_settings": {
        "quality_threshold": 85,
        "coverage_threshold": 80,
        "complexity_threshold": 10,
        "duplication_threshold": 3,
        "required_gates": ["syntax", "tests", "security"],
        "optional_gates": ["coverage", "complexity"],
        "language_specific_rules": {}
    },
    "security_overrides": {
        "custom_security_rules": [],
        "excluded_paths": ["test/", "tests/", "spec/", "docs/", "examples/"],
        "additional_scanners": [],
        "security_level": "high"
    },
    "workflow_customizations": {
        "pre_commit_hooks": true,
        "auto_format_on_save": true,
        "parallel_execution": true,
        "custom_validation_rules": [],
        "framework_specific_commands": {}
    },
    "monitoring_preferences": {
        "token_usage_alerts": true,
        "performance_tracking": true,
        "error_reporting": "detailed",
        "metrics_retention_days": 30
    },
    "project_tools": {}
}
EOF
    
    echo "PROJECT_CONFIG_CREATED: $PROJECT_CONFIG_FILE"
    
    # Auto-configure tools based on detected language and frameworks
    if [ "$project_type" != "unknown" ]; then
        detect_and_configure_language_tools "$project_type" "$detected_frameworks"
    fi
}
```

## Interactive Configuration Wizard
```bash
interactive_configuration() {
    echo "=== AI Framework Interactive Configuration ==="
    echo ""
    
    # Run smart configuration assistant first
    smart_configuration_assistant
    
    echo ""
    echo "=== Manual Configuration Options ==="
    
    # Project Information
    echo "Project Configuration:"
    read -p "Project name [$(basename "$(pwd)")]: " project_name
    project_name=${project_name:-$(basename "$(pwd)")}
    
    # Quality Settings
    echo ""
    echo "Quality Settings:"
    read -p "Quality threshold (0-100) [85]: " quality_threshold
    quality_threshold=${quality_threshold:-85}
    
    read -p "Test coverage threshold (0-100) [80]: " coverage_threshold
    coverage_threshold=${coverage_threshold:-80}
    
    # Security Settings
    echo ""
    echo "Security Settings:"
    echo "Security level options: low, medium, high, strict"
    read -p "Security level [high]: " security_level
    security_level=${security_level:-high}
    
    # Language-specific tool preferences
    echo ""
    echo "Tool Preferences:"
    project_type=$(cat "${AI_WORKFLOW_DIR}/cache/project_type.txt" 2>/dev/null || echo "unknown")
    
    if [ "$project_type" != "unknown" ]; then
        configure_language_specific_tools "$project_type"
    fi
    
    # Monitoring Preferences
    echo ""
    echo "Monitoring:"
    read -p "Enable token usage monitoring? (y/n) [y]: " enable_monitoring
    enable_monitoring=${enable_monitoring:-y}
    
    read -p "Enable performance tracking? (y/n) [y]: " enable_performance
    enable_performance=${enable_performance:-y}
    
    # Generate configuration based on answers
    generate_interactive_config "$project_name" "$quality_threshold" "$coverage_threshold" "$security_level" "$enable_monitoring" "$enable_performance"
}

configure_language_specific_tools() {
    local lang="$1"
    
    case "$lang" in
        "php")
            read -p "PHP linter (phpcs/psalm/phpstan) [phpcs]: " php_linter
            read -p "Test framework (phpunit/pest) [phpunit]: " php_test
            read -p "Framework (laravel/symfony/none) [none]: " php_framework
            ;;
        "ruby")
            read -p "Ruby linter (rubocop/standard) [rubocop]: " ruby_linter
            read -p "Test framework (rspec/minitest) [rspec]: " ruby_test
            ;;
        "javascript"|"typescript")
            read -p "Package manager (npm/yarn/pnpm) [npm]: " js_package_manager
            read -p "Linter (eslint/standard) [eslint]: " js_linter
            ;;
        "java")
            read -p "Build tool (maven/gradle) [maven]: " java_build
            read -p "Test framework (junit/testng) [junit]: " java_test
            ;;
        "go")
            read -p "Linter (golangci-lint/golint) [golangci-lint]: " go_linter
            ;;
        "rust")
            read -p "Additional linters beyond clippy? (y/n) [n]: " rust_extra
            ;;
    esac
}
```

### Main Configuration Logic with Enhanced Language Support
```bash
# Parse configuration options and execute
echo "=== AI Framework Configuration ==="
echo "Supported languages: $(jq -r '.default_tools | keys | join(", ")' "$GLOBAL_CONFIG_FILE")"
echo "Supported frameworks: $(jq -r '[.framework_specific_tools.web_frameworks, .framework_specific_tools.backend_frameworks, .framework_specific_tools.mobile_frameworks] | map(keys) | flatten | unique | join(", ")' "$GLOBAL_CONFIG_FILE")"
echo ""

# Continue with existing configuration logic...
# [Previous configuration parsing and execution code remains the same]
```

## Success Criteria
- Multi-language support implemented (12+ languages)
- Framework-specific tools configured automatically
- Smart configuration assistant working
- Language detection integrated with tool selection
- User can override defaults per language/framework
- Configuration validation works for all supported languages

## Dependencies
- Enhanced project type detection supporting all languages
- jq for JSON processing
- Language-specific tools availability detection
- Framework directory structure validation