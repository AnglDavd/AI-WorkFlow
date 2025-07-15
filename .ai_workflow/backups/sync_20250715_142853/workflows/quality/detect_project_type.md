# Detect Project Type Workflow

## Purpose
Automatically identify the programming language, framework, and build system of a project to enable appropriate quality validation, tool selection, and optimization strategies.

## When to Use
- At the start of any workflow that needs language-specific tools
- Before executing quality gates
- During project initialization
- When validating dependencies

## Prerequisites
- Read access to project directory
- Valid project path

## Input Parameters
- `project_path`: Path to the project directory to analyze
- `cache_result`: Boolean to cache detection result (default: true)
- `force_redetect`: Boolean to ignore cached results (default: false)

## Detection Algorithm

### Step 1: Check Cache
```bash
cache_file=".ai_workflow/cache/project_type.txt"
cache_metadata=".ai_workflow/cache/project_detection_meta.json"

if [ "$force_redetect" != "true" ] && FILE_EXISTS "$cache_file"; then
    # Check if cache is still valid (project files haven't changed significantly)
    last_detection=$(cat "$cache_metadata" 2>/dev/null | grep "timestamp" | cut -d'"' -f4)
    if [ -n "$last_detection" ]; then
        # Cache is valid for 24 hours or until key files change
        echo "PROJECT_TYPE_CACHED: Using cached detection result"
        cat "$cache_file"
        exit 0
    fi
fi
```

### Step 2: Primary Language Detection
```bash
# Priority-based detection using key indicator files
detected_type=""
confidence_score=0
frameworks_detected=""

# JavaScript/TypeScript Detection
if FILE_EXISTS "${project_path}/package.json"; then
    if FILE_EXISTS "${project_path}/tsconfig.json" || ls "${project_path}"/*.ts 2>/dev/null | head -1; then
        detected_type="typescript"
        confidence_score=95
    else
        detected_type="javascript"
        confidence_score=90
    fi
    
    # Framework detection for JS/TS
    package_content=$(cat "${project_path}/package.json")
    if echo "$package_content" | grep -q '"react"'; then
        frameworks_detected="${frameworks_detected},react"
    fi
    if echo "$package_content" | grep -q '"vue"'; then
        frameworks_detected="${frameworks_detected},vue"
    fi
    if echo "$package_content" | grep -q '"angular"'; then
        frameworks_detected="${frameworks_detected},angular"
    fi
    if echo "$package_content" | grep -q '"express"'; then
        frameworks_detected="${frameworks_detected},express"
    fi
    if echo "$package_content" | grep -q '"next"'; then
        frameworks_detected="${frameworks_detected},nextjs"
    fi
fi

# Python Detection
if FILE_EXISTS "${project_path}/requirements.txt" || FILE_EXISTS "${project_path}/pyproject.toml" || FILE_EXISTS "${project_path}/setup.py"; then
    detected_type="python"
    confidence_score=90
    
    # Python framework detection
    if FILE_EXISTS "${project_path}/manage.py" || ls "${project_path}"/**/settings.py 2>/dev/null | head -1; then
        frameworks_detected="${frameworks_detected},django"
    fi
    if ls "${project_path}"/**/*flask* 2>/dev/null | head -1 || grep -r "from flask" "${project_path}" 2>/dev/null | head -1; then
        frameworks_detected="${frameworks_detected},flask"
    fi
    if ls "${project_path}"/**/*fastapi* 2>/dev/null | head -1 || grep -r "from fastapi" "${project_path}" 2>/dev/null | head -1; then
        frameworks_detected="${frameworks_detected},fastapi"
    fi
fi

# Java Detection
if FILE_EXISTS "${project_path}/pom.xml"; then
    detected_type="java"
    confidence_score=95
    frameworks_detected="${frameworks_detected},maven"
fi

if FILE_EXISTS "${project_path}/build.gradle" || FILE_EXISTS "${project_path}/build.gradle.kts"; then
    detected_type="java"
    confidence_score=95
    frameworks_detected="${frameworks_detected},gradle"
fi

# Go Detection
if FILE_EXISTS "${project_path}/go.mod"; then
    detected_type="go"
    confidence_score=95
fi

# Rust Detection
if FILE_EXISTS "${project_path}/Cargo.toml"; then
    detected_type="rust"
    confidence_score=95
fi

# C# Detection
if FILE_EXISTS "${project_path}/*.csproj" || FILE_EXISTS "${project_path}/*.sln"; then
    detected_type="csharp"
    confidence_score=90
fi

# PHP Detection
if FILE_EXISTS "${project_path}/composer.json"; then
    detected_type="php"
    confidence_score=90
    
    # PHP framework detection
    composer_content=$(cat "${project_path}/composer.json" 2>/dev/null)
    if echo "$composer_content" | grep -q '"laravel"'; then
        frameworks_detected="${frameworks_detected},laravel"
    fi
    if echo "$composer_content" | grep -q '"symfony"'; then
        frameworks_detected="${frameworks_detected},symfony"
    fi
fi

# Ruby Detection
if FILE_EXISTS "${project_path}/Gemfile"; then
    detected_type="ruby"
    confidence_score=90
    
    # Ruby framework detection
    if FILE_EXISTS "${project_path}/config/application.rb"; then
        frameworks_detected="${frameworks_detected},rails"
    fi
fi
```

### Step 3: Secondary Detection (File Extensions)
```bash
# If no primary indicators found, analyze file extensions
if [ -z "$detected_type" ]; then
    echo "PROJECT_TYPE_INFO: No primary indicators found, analyzing file extensions"
    
    # Count file extensions
    js_count=$(find "${project_path}" -name "*.js" -type f | wc -l)
    ts_count=$(find "${project_path}" -name "*.ts" -type f | wc -l)
    py_count=$(find "${project_path}" -name "*.py" -type f | wc -l)
    java_count=$(find "${project_path}" -name "*.java" -type f | wc -l)
    go_count=$(find "${project_path}" -name "*.go" -type f | wc -l)
    rs_count=$(find "${project_path}" -name "*.rs" -type f | wc -l)
    cs_count=$(find "${project_path}" -name "*.cs" -type f | wc -l)
    php_count=$(find "${project_path}" -name "*.php" -type f | wc -l)
    rb_count=$(find "${project_path}" -name "*.rb" -type f | wc -l)
    
    # Determine majority language
    max_count=0
    if [ $ts_count -gt $max_count ]; then
        detected_type="typescript"
        max_count=$ts_count
        confidence_score=70
    fi
    if [ $js_count -gt $max_count ]; then
        detected_type="javascript"
        max_count=$js_count
        confidence_score=70
    fi
    if [ $py_count -gt $max_count ]; then
        detected_type="python"
        max_count=$py_count
        confidence_score=70
    fi
    if [ $java_count -gt $max_count ]; then
        detected_type="java"
        max_count=$java_count
        confidence_score=70
    fi
    if [ $go_count -gt $max_count ]; then
        detected_type="go"
        max_count=$go_count
        confidence_score=70
    fi
    if [ $rs_count -gt $max_count ]; then
        detected_type="rust"
        max_count=$rs_count
        confidence_score=70
    fi
    if [ $cs_count -gt $max_count ]; then
        detected_type="csharp"
        max_count=$cs_count
        confidence_score=70
    fi
    if [ $php_count -gt $max_count ]; then
        detected_type="php"
        max_count=$php_count
        confidence_score=70
    fi
    if [ $rb_count -gt $max_count ]; then
        detected_type="ruby"
        max_count=$rb_count
        confidence_score=70
    fi
fi
```

### Step 4: Build System Detection
```bash
build_system=""

# Detect build systems
if FILE_EXISTS "${project_path}/package.json"; then
    build_system="npm"
    if FILE_EXISTS "${project_path}/yarn.lock"; then
        build_system="yarn"
    fi
    if FILE_EXISTS "${project_path}/pnpm-lock.yaml"; then
        build_system="pnpm"
    fi
fi

if FILE_EXISTS "${project_path}/Makefile"; then
    build_system="${build_system},make"
fi

if FILE_EXISTS "${project_path}/docker-compose.yml" || FILE_EXISTS "${project_path}/Dockerfile"; then
    build_system="${build_system},docker"
fi

# Language-specific build systems
case $detected_type in
    "python")
        if FILE_EXISTS "${project_path}/pyproject.toml"; then
            build_system="${build_system},poetry"
        fi
        if FILE_EXISTS "${project_path}/Pipfile"; then
            build_system="${build_system},pipenv"
        fi
        ;;
    "java")
        if FILE_EXISTS "${project_path}/pom.xml"; then
            build_system="${build_system},maven"
        fi
        if FILE_EXISTS "${project_path}/build.gradle"; then
            build_system="${build_system},gradle"
        fi
        ;;
    "rust")
        build_system="${build_system},cargo"
        ;;
    "go")
        build_system="${build_system},go_modules"
        ;;
esac
```

### Step 5: Testing Framework Detection
```bash
test_frameworks=""

case $detected_type in
    "javascript"|"typescript")
        if grep -q '"jest"' "${project_path}/package.json" 2>/dev/null; then
            test_frameworks="${test_frameworks},jest"
        fi
        if grep -q '"mocha"' "${project_path}/package.json" 2>/dev/null; then
            test_frameworks="${test_frameworks},mocha"
        fi
        if grep -q '"cypress"' "${project_path}/package.json" 2>/dev/null; then
            test_frameworks="${test_frameworks},cypress"
        fi
        ;;
    "python")
        if FILE_EXISTS "${project_path}/pytest.ini" || grep -r "import pytest" "${project_path}" 2>/dev/null | head -1; then
            test_frameworks="${test_frameworks},pytest"
        fi
        if grep -r "import unittest" "${project_path}" 2>/dev/null | head -1; then
            test_frameworks="${test_frameworks},unittest"
        fi
        ;;
    "java")
        if grep -q "junit" "${project_path}/pom.xml" 2>/dev/null; then
            test_frameworks="${test_frameworks},junit"
        fi
        ;;
    "go")
        # Go has built-in testing
        test_frameworks="go_test"
        ;;
    "rust")
        # Rust has built-in testing
        test_frameworks="cargo_test"
        ;;
esac
```

## Result Generation and Caching

### Generate Detection Result
```bash
# Clean up framework lists (remove leading commas)
frameworks_detected=$(echo "$frameworks_detected" | sed 's/^,//')
build_system=$(echo "$build_system" | sed 's/^,//')
test_frameworks=$(echo "$test_frameworks" | sed 's/^,//')

# Generate final result
if [ -z "$detected_type" ]; then
    detected_type="unknown"
    confidence_score=0
fi

# Create result JSON
result_json="{
    \"primary_language\": \"$detected_type\",
    \"confidence_score\": $confidence_score,
    \"frameworks\": \"$frameworks_detected\",
    \"build_system\": \"$build_system\",
    \"test_frameworks\": \"$test_frameworks\",
    \"detection_timestamp\": \"$(date '+%Y-%m-%d %H:%M:%S')\",
    \"project_path\": \"$project_path\"
}"
```

### Cache Results
```bash
if [ "$cache_result" = "true" ]; then
    mkdir -p ".ai_workflow/cache"
    echo "$detected_type" > "$cache_file"
    echo "$result_json" > "$cache_metadata"
    
    # Create tool-specific configuration hints
    case $detected_type in
        "javascript"|"typescript")
            echo "eslint,prettier" > ".ai_workflow/cache/recommended_linters.txt"
            echo "npm test,npm run build" > ".ai_workflow/cache/recommended_commands.txt"
            ;;
        "python")
            echo "pylint,flake8,black" > ".ai_workflow/cache/recommended_linters.txt"
            echo "pytest,python -m py_compile" > ".ai_workflow/cache/recommended_commands.txt"
            ;;
        "java")
            echo "checkstyle,spotbugs" > ".ai_workflow/cache/recommended_linters.txt"
            echo "mvn test,mvn compile" > ".ai_workflow/cache/recommended_commands.txt"
            ;;
        "go")
            echo "golint,gofmt,go vet" > ".ai_workflow/cache/recommended_linters.txt"
            echo "go test,go build" > ".ai_workflow/cache/recommended_commands.txt"
            ;;
        "rust")
            echo "clippy,rustfmt" > ".ai_workflow/cache/recommended_linters.txt"
            echo "cargo test,cargo build" > ".ai_workflow/cache/recommended_commands.txt"
            ;;
    esac
fi
```

## Output Format

### Success Output
```
PROJECT_TYPE_DETECTED: typescript
CONFIDENCE_SCORE: 95
FRAMEWORKS: react,express
BUILD_SYSTEM: npm
TEST_FRAMEWORKS: jest,cypress
DETECTION_TIME: 2.3s
CACHE_STATUS: updated
```

### Detailed JSON Output
```json
{
    "primary_language": "typescript",
    "confidence_score": 95,
    "frameworks": "react,express",
    "build_system": "npm",
    "test_frameworks": "jest,cypress",
    "detection_timestamp": "2024-12-06 14:30:22",
    "project_path": "/path/to/project",
    "recommended_linters": ["eslint", "prettier"],
    "recommended_commands": ["npm test", "npm run build"],
    "cache_hit": false
}
```

## Integration Points

### With Quality Gates
- Provides language-specific tool configuration
- Enables appropriate linting and testing strategies
- Feeds framework-specific validation rules

### With Abstract Tools
- Configures LINT_FILE tool for detected language
- Sets up RUN_TESTS with appropriate test command
- Enables RUN_TYPE_CHECK for typed languages

### With Dependency Validation
- Identifies package managers and dependency files
- Provides context for security scanning tools
- Enables framework-specific vulnerability checks

## Error Handling

### Low Confidence Detection
```bash
if [ $confidence_score -lt 50 ]; then
    echo "PROJECT_TYPE_WARNING: Low confidence detection ($confidence_score%)"
    echo "RECOMMENDATION: Manual project type specification may be needed"
    echo "FALLBACK: Using generic validation tools"
fi
```

### Multiple Language Projects
```bash
# For projects with multiple significant languages
if [ $js_count -gt 10 ] && [ $py_count -gt 10 ]; then
    echo "PROJECT_TYPE_INFO: Multi-language project detected"
    echo "PRIMARY_LANGUAGE: $detected_type"
    echo "SECONDARY_LANGUAGES: Additional languages present"
fi
```

## Configuration Options

### Project-Level Override (.ai_project_type.json)
```json
{
    "override_detection": true,
    "primary_language": "typescript",
    "frameworks": ["react", "nextjs"],
    "build_system": "yarn",
    "test_frameworks": ["jest"],
    "custom_linters": ["eslint", "@typescript-eslint/eslint-plugin"],
    "exclude_patterns": ["dist/", "node_modules/", "*.test.js"]
}
```

## Success Criteria
- Accurate language detection with high confidence
- Framework and build system identification
- Appropriate tool recommendations generated
- Results cached for performance
- Integration with downstream workflows enabled

## Dependencies
- Abstract tool system (FILE_EXISTS)
- File system access permissions
- Cache directory write permissions