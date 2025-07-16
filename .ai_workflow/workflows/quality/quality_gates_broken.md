# Quality Gates Workflow

## Purpose
Execute comprehensive quality validation gates including syntax checking, test execution, and integration validation to ensure code meets quality standards before deployment.

## When to Use
- Before committing code changes
- During PRP execution validation phase
- As part of CI/CD pipeline validation
- When validating external contributions

## Prerequisites
- Project type detection completed
- Dependencies validated
- Valid abstract tool environment

## Input Parameters
- `project_path`: Path to project directory
- `validation_scope`: full|changed_files|specific_files
- `target_files`: Specific files to validate (optional)
- `skip_tests`: Boolean to skip test execution (default: false)
- `quality_threshold`: Minimum quality score required (default: 80)

## Quality Gates Sequence

### Gate 1: Adaptive Syntax Validation
```bash
# Use adaptive language support for comprehensive language detection
if ! bash .ai_workflow/workflows/quality/adaptive_language_support.md; then
    echo "QUALITY_GATE_WARNING: Adaptive language support had issues, using basic detection"
fi

# Load adaptive configuration
ADAPTIVE_CONFIG="${project_path}/.ai_workflow/cache/quality/adaptive_config.json"
if [[ -f "$ADAPTIVE_CONFIG" ]]; then
    project_type=$(jq -r '.primary_language // "unknown"' "$ADAPTIVE_CONFIG")
    linting_commands=($(jq -r '.linting_commands[]?' "$ADAPTIVE_CONFIG"))
    analysis_strategy=$(jq -r '.analysis_strategy // "generic"' "$ADAPTIVE_CONFIG")
    
    echo "QUALITY_GATE_INFO: Using adaptive configuration for $project_type"
    
    # Execute linting commands if available
    if [[ ${#linting_commands[@]} -gt 0 ]]; then
        for cmd in "${linting_commands[@]}"; do
            echo "QUALITY_GATE_LINT: Running $cmd"
            if ! eval "$cmd" 2>&1; then
                echo "QUALITY_GATE_ERROR: Linting failed with $cmd"
                exit 1
            fi
        done
    else
        echo "QUALITY_GATE_INFO: No linting commands configured, using generic validation"
        # Generic syntax validation
        if [[ "$analysis_strategy" == "generic" ]]; then
            # Basic file syntax checks
            find "${project_path}" -name "*.sh" -type f -exec bash -n {} \; 2>/dev/null || echo "QUALITY_GATE_WARNING: Some shell scripts have syntax errors"
            find "${project_path}" -name "*.json" -type f -exec python -m json.tool {} \; >/dev/null 2>&1 || echo "QUALITY_GATE_WARNING: Some JSON files are malformed"
        fi
    fi
else
    echo "QUALITY_GATE_WARNING: No adaptive configuration found, using fallback validation"
    # Fallback to basic project detection
    if [[ -f "${project_path}/package.json" ]]; then
        echo "QUALITY_GATE_INFO: Detected Node.js project"
        npm run lint 2>/dev/null || echo "QUALITY_GATE_WARNING: npm lint not configured"
    elif [[ -f "${project_path}/requirements.txt" ]]; then
        echo "QUALITY_GATE_INFO: Detected Python project"
        python -m py_compile "${project_path}"/*.py 2>/dev/null || echo "QUALITY_GATE_WARNING: Python syntax check failed"
    elif [[ -f "${project_path}/Cargo.toml" ]]; then
        echo "QUALITY_GATE_INFO: Detected Rust project"
        cargo check 2>/dev/null || echo "QUALITY_GATE_WARNING: Cargo check failed"
    fi
fi
```

### Gate 2: Type Checking
```bash
case $project_type in
    "typescript")
        RUN_TYPE_CHECK "tsc" "${project_path}" || exit 1
        ;;
    "python")
        RUN_TYPE_CHECK "mypy" "${project_path}" || exit 1
        ;;
    *)
        echo "QUALITY_GATE_INFO: No type checking available for $project_type"
        ;;
esac
```

### Gate 3: Test Execution
```bash
if [ "$skip_tests" != "true" ]; then
    case $project_type in
        "javascript"|"typescript")
            RUN_TESTS "npm test" "${project_path}" || exit 1
            ;;
        "python")
            RUN_TESTS "pytest" "${project_path}" || exit 1
            ;;
        "java")
            RUN_TESTS "mvn test" "${project_path}" || exit 1
            ;;
        "go")
            RUN_TESTS "go test" "${project_path}" || exit 1
            ;;
        "rust")
            RUN_TESTS "cargo test" "${project_path}" || exit 1
            ;;
        *)
            echo "QUALITY_GATE_WARNING: No test framework detected for $project_type"
            ;;
    esac
fi
```

### Gate 4: Security Scanning
```bash
# Run security vulnerability scans
case $project_type in
    "javascript"|"typescript")
        SECURITY_SCAN "npm audit" "${project_path}" || echo "SECURITY_WARNING: Vulnerabilities found"
        ;;
    "python")
        SECURITY_SCAN "safety check" "${project_path}" || echo "SECURITY_WARNING: Vulnerabilities found"
        SECURITY_SCAN "bandit" "${project_path}" || echo "SECURITY_WARNING: Security issues found"
        ;;
    *)
        echo "QUALITY_GATE_INFO: No security scanning available for $project_type"
        ;;
esac
```

### Gate 5: Architecture Documentation Validation
```bash
# Validate architecture documentation synchronization
if [[ -f "${project_path}/.ai_workflow/config/quality_config.json" ]]; then
    DOC_VALIDATION_ENABLED=$(jq -r '.documentation_validation.enabled // false' "${project_path}/.ai_workflow/config/quality_config.json")
    
    if [[ "$DOC_VALIDATION_ENABLED" == "true" ]]; then
        echo "QUALITY_GATE_INFO: Running architecture documentation validation"
        
        # Execute architecture documentation validation
        if bash "${project_path}/.ai_workflow/workflows/documentation/validate_architecture_sync.md"; then
            echo "QUALITY_GATE_SUCCESS: Architecture documentation is synchronized"
        else
            echo "QUALITY_GATE_WARNING: Architecture documentation is out of sync"
            # Check if this should fail the build
            FAIL_ON_OUTDATED=$(jq -r '.documentation_validation.fail_on_outdated // false' "${project_path}/.ai_workflow/config/quality_config.json")
            if [[ "$FAIL_ON_OUTDATED" == "true" ]]; then
                echo "QUALITY_GATE_FAILURE: Architecture documentation validation failed"
                exit 1
            fi
        fi
    else
        echo "QUALITY_GATE_INFO: Architecture documentation validation disabled"
    fi
fi
```

### Gate 5: Code Coverage Analysis
```bash
if [ "$skip_tests" != "true" ]; then
    case $project_type in
        "javascript"|"typescript")
            COVERAGE_CHECK "jest --coverage" "${project_path}" || echo "COVERAGE_WARNING: Low coverage detected"
            ;;
        "python")
            COVERAGE_CHECK "pytest --cov" "${project_path}" || echo "COVERAGE_WARNING: Low coverage detected"
            ;;
        *)
            echo "QUALITY_GATE_INFO: No coverage analysis available for $project_type"
            ;;
    esac
fi
```

## Quality Metrics Collection

### Performance Metrics
```bash
# Collect execution times and resource usage
echo "QUALITY_METRICS_START: $(date '+%Y-%m-%d %H:%M:%S')"
start_time=$(date +%s)

# Execute all quality gates...

end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo "QUALITY_METRICS_EXECUTION_TIME: ${execution_time}s"
```

### Code Quality Score Calculation
```bash
# Calculate overall quality score based on gates passed
gates_passed=0
total_gates=6

# Increment gates_passed for each successful gate
# Quality score = (gates_passed / total_gates) * 100
quality_score=$(( (gates_passed * 100) / total_gates ))

echo "QUALITY_SCORE: $quality_score"

if [ $quality_score -lt $quality_threshold ]; then
    echo "QUALITY_GATE_FAILURE: Quality score $quality_score below threshold $quality_threshold"
    exit 1
fi
```

## Output Format

### Success Output
```
QUALITY_GATES_PASSED: true
QUALITY_SCORE: 95
GATES_EXECUTED: syntax,type_check,tests,security,documentation,coverage
EXECUTION_TIME: 45s
WARNINGS: 2
ERRORS: 0
```

### Failure Output
```
QUALITY_GATES_FAILED: true
QUALITY_SCORE: 65
FAILED_GATES: tests,documentation,coverage
GATE_ERRORS: [
  "TEST_FAILURE: 3 tests failed in user_service_test.py",
  "COVERAGE_LOW: Only 45% coverage, minimum required is 80%"
]
RECOMMENDATIONS: [
  "Fix failing tests in user authentication module",
  "Add tests for uncovered branches in payment processing"
]
```

## Integration Points

### With Abstract Tools
- Uses LINT_FILE, RUN_TYPE_CHECK, RUN_TESTS abstract tools
- Integrates with security validation workflows
- Connects to project type detection system

### With PRP Execution
- Called from `01_run_prp.md` during validation phase
- Results stored in `.ai_workflow/cache/quality_results.json`
- Failure triggers rollback workflow

### With Monitoring System
- Quality metrics logged to `quality_metrics.log`
- Integration with token economy monitoring
- Performance data fed to optimization workflows

## Error Handling

### Recoverable Errors
- Low code coverage: Continue with warning
- Minor linting issues: Report but don't fail
- Security warnings: Log and continue

### Non-Recoverable Errors
- Syntax errors: Fail immediately
- Test failures: Fail and provide detailed report
- Critical security vulnerabilities: Fail and escalate

## Configuration Options

### Project-Level Configuration (.ai_quality.json)
```json
{
  "quality_threshold": 85,
  "required_gates": ["syntax", "tests"],
  "optional_gates": ["coverage", "security"],
  "coverage_threshold": 80,
  "skip_patterns": ["*.test.js", "mock/**"],
  "custom_linters": {
    "javascript": ["eslint", "prettier"]
  }
}
```

### Framework Integration
- Reads project-specific quality requirements
- Adapts gates based on project maturity
- Supports custom quality metrics

## Success Criteria
- All mandatory quality gates pass
- Quality score meets or exceeds threshold
- No critical security vulnerabilities detected
- Test coverage meets minimum requirements
- Execution completes within reasonable time

## Dependencies
- `detect_project_type.md` workflow
- `validate_dependencies.md` workflow
- Abstract tool system with LINT_FILE, RUN_TESTS, etc.
- Security validation workflows