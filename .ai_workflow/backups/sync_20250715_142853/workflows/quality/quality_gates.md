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

### Gate 1: Syntax Validation
```bash
# Detect project type and run appropriate syntax checks
project_type=$(cat .ai_workflow/cache/project_type.txt 2>/dev/null || echo "unknown")

case $project_type in
    "javascript"|"typescript")
        LINT_FILE "eslint" "${project_path}" || exit 1
        ;;
    "python")
        LINT_FILE "pylint" "${project_path}" || exit 1
        LINT_FILE "flake8" "${project_path}" || exit 1
        ;;
    "java")
        LINT_FILE "checkstyle" "${project_path}" || exit 1
        ;;
    "go")
        LINT_FILE "golint" "${project_path}" || exit 1
        LINT_FILE "gofmt" "${project_path}" || exit 1
        ;;
    "rust")
        LINT_FILE "clippy" "${project_path}" || exit 1
        LINT_FILE "rustfmt" "${project_path}" || exit 1
        ;;
    *)
        echo "QUALITY_GATE_WARNING: Unknown project type, skipping syntax validation"
        ;;
esac
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
total_gates=5

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
GATES_EXECUTED: syntax,type_check,tests,security,coverage
EXECUTION_TIME: 45s
WARNINGS: 2
ERRORS: 0
```

### Failure Output
```
QUALITY_GATES_FAILED: true
QUALITY_SCORE: 65
FAILED_GATES: tests,coverage
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