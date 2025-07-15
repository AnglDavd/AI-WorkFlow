# Validate Dependencies Workflow

## Purpose
Perform comprehensive validation of project dependencies including availability, security vulnerabilities, version compatibility, and license compliance to ensure reliable and secure project builds.

## When to Use
- Before project build or deployment
- During security audits
- After dependency updates
- As part of quality gates validation
- Before accepting external contributions

## Prerequisites
- Project type detection completed
- Network connectivity for vulnerability databases
- Package manager tools available

## Input Parameters
- `project_path`: Path to project directory
- `check_security`: Boolean to enable security vulnerability scanning (default: true)
- `check_licenses`: Boolean to enable license compatibility checking (default: true)
- `check_updates`: Boolean to check for available updates (default: false)
- `fail_on_vulnerabilities`: Boolean to fail on security issues (default: true)
- `severity_threshold`: Minimum vulnerability severity to fail on (low|medium|high|critical)

## Dependency Validation Sequence

### Step 1: Load Project Configuration
```bash
project_type=$(cat .ai_workflow/cache/project_type.txt 2>/dev/null || echo "unknown")
build_system=$(cat .ai_workflow/cache/project_detection_meta.json 2>/dev/null | grep "build_system" | cut -d'"' -f4)

if [ "$project_type" = "unknown" ]; then
    echo "DEPENDENCY_ERROR: Project type not detected. Run detect_project_type.md first."
    exit 1
fi

echo "DEPENDENCY_VALIDATION_START: Validating $project_type project dependencies"
```

### Step 2: Dependency Availability Check
```bash
# Check if dependency files exist and are readable
dependency_files_found=true

case $project_type in
    "javascript"|"typescript")
        if ! FILE_EXISTS "${project_path}/package.json"; then
            echo "DEPENDENCY_ERROR: package.json not found"
            dependency_files_found=false
        fi
        
        # Check lock files for consistency
        if FILE_EXISTS "${project_path}/package-lock.json" && FILE_EXISTS "${project_path}/yarn.lock"; then
            echo "DEPENDENCY_WARNING: Both package-lock.json and yarn.lock found"
        fi
        ;;
        
    "python")
        found_dep_file=false
        
        if FILE_EXISTS "${project_path}/requirements.txt"; then
            found_dep_file=true
        fi
        if FILE_EXISTS "${project_path}/pyproject.toml"; then
            found_dep_file=true
        fi
        if FILE_EXISTS "${project_path}/setup.py"; then
            found_dep_file=true
        fi
        if FILE_EXISTS "${project_path}/Pipfile"; then
            found_dep_file=true
        fi
        
        if [ "$found_dep_file" = "false" ]; then
            echo "DEPENDENCY_ERROR: No Python dependency file found"
            dependency_files_found=false
        fi
        ;;
        
    "java")
        if ! FILE_EXISTS "${project_path}/pom.xml" && ! FILE_EXISTS "${project_path}/build.gradle"; then
            echo "DEPENDENCY_ERROR: No Java build file found (pom.xml or build.gradle)"
            dependency_files_found=false
        fi
        ;;
        
    "go")
        if ! FILE_EXISTS "${project_path}/go.mod"; then
            echo "DEPENDENCY_ERROR: go.mod not found"
            dependency_files_found=false
        fi
        ;;
        
    "rust")
        if ! FILE_EXISTS "${project_path}/Cargo.toml"; then
            echo "DEPENDENCY_ERROR: Cargo.toml not found"
            dependency_files_found=false
        fi
        ;;
        
    *)
        echo "DEPENDENCY_WARNING: Unknown project type, skipping dependency validation"
        exit 0
        ;;
esac

if [ "$dependency_files_found" = "false" ]; then
    echo "DEPENDENCY_VALIDATION_FAILED: Critical dependency files missing"
    exit 1
fi
```

### Step 3: Dependency Installation Check
```bash
# Verify dependencies can be resolved and installed
echo "DEPENDENCY_CHECK: Verifying dependency resolution"

case $project_type in
    "javascript"|"typescript")
        if echo "$build_system" | grep -q "yarn"; then
            VALIDATE_DEPENDENCIES "yarn install --dry-run" "${project_path}" || {
                echo "DEPENDENCY_ERROR: Yarn dependency resolution failed"
                exit 1
            }
        elif echo "$build_system" | grep -q "pnpm"; then
            VALIDATE_DEPENDENCIES "pnpm install --dry-run" "${project_path}" || {
                echo "DEPENDENCY_ERROR: PNPM dependency resolution failed"
                exit 1
            }
        else
            VALIDATE_DEPENDENCIES "npm install --dry-run" "${project_path}" || {
                echo "DEPENDENCY_ERROR: NPM dependency resolution failed"
                exit 1
            }
        fi
        ;;
        
    "python")
        if FILE_EXISTS "${project_path}/Pipfile"; then
            VALIDATE_DEPENDENCIES "pipenv check" "${project_path}" || {
                echo "DEPENDENCY_WARNING: Pipenv check found issues"
            }
        elif FILE_EXISTS "${project_path}/pyproject.toml"; then
            VALIDATE_DEPENDENCIES "poetry check" "${project_path}" || {
                echo "DEPENDENCY_WARNING: Poetry check found issues"
            }
        else
            # Basic pip check for requirements.txt
            VALIDATE_DEPENDENCIES "pip check" "${project_path}" || {
                echo "DEPENDENCY_WARNING: Pip check found issues"
            }
        fi
        ;;
        
    "java")
        if FILE_EXISTS "${project_path}/pom.xml"; then
            VALIDATE_DEPENDENCIES "mvn dependency:resolve" "${project_path}" || {
                echo "DEPENDENCY_ERROR: Maven dependency resolution failed"
                exit 1
            }
        else
            VALIDATE_DEPENDENCIES "gradle dependencies" "${project_path}" || {
                echo "DEPENDENCY_ERROR: Gradle dependency resolution failed"
                exit 1
            }
        fi
        ;;
        
    "go")
        VALIDATE_DEPENDENCIES "go mod verify" "${project_path}" || {
            echo "DEPENDENCY_ERROR: Go module verification failed"
            exit 1
        }
        ;;
        
    "rust")
        VALIDATE_DEPENDENCIES "cargo check" "${project_path}" || {
            echo "DEPENDENCY_ERROR: Cargo dependency check failed"
            exit 1
        }
        ;;
esac

echo "DEPENDENCY_RESOLUTION: Success"
```

### Step 4: Security Vulnerability Scanning
```bash
if [ "$check_security" = "true" ]; then
    echo "DEPENDENCY_SECURITY_SCAN: Starting vulnerability check"
    
    vulnerability_count=0
    critical_vulnerabilities=0
    high_vulnerabilities=0
    
    case $project_type in
        "javascript"|"typescript")
            # NPM audit
            audit_output=$(SECURITY_SCAN "npm audit --json" "${project_path}" 2>/dev/null || echo '{"vulnerabilities": {}}')
            
            # Parse audit results
            critical_vulnerabilities=$(echo "$audit_output" | grep -o '"critical":[0-9]*' | cut -d':' -f2 | head -1)
            high_vulnerabilities=$(echo "$audit_output" | grep -o '"high":[0-9]*' | cut -d':' -f2 | head -1)
            
            # Also check yarn audit if yarn is used
            if echo "$build_system" | grep -q "yarn"; then
                SECURITY_SCAN "yarn audit" "${project_path}" || {
                    echo "DEPENDENCY_SECURITY_WARNING: Yarn audit found vulnerabilities"
                }
            fi
            ;;
            
        "python")
            # Safety check for Python
            SECURITY_SCAN "safety check" "${project_path}" || {
                echo "DEPENDENCY_SECURITY_WARNING: Python safety check found vulnerabilities"
                vulnerability_count=$((vulnerability_count + 1))
            }
            
            # Bandit for security issues in code
            SECURITY_SCAN "bandit -r ." "${project_path}" || {
                echo "DEPENDENCY_SECURITY_WARNING: Bandit found security issues"
            }
            ;;
            
        "java")
            # OWASP dependency check
            SECURITY_SCAN "mvn org.owasp:dependency-check-maven:check" "${project_path}" || {
                echo "DEPENDENCY_SECURITY_WARNING: OWASP dependency check found vulnerabilities"
                vulnerability_count=$((vulnerability_count + 1))
            }
            ;;
            
        "go")
            # Gosec for Go security issues
            SECURITY_SCAN "gosec ./..." "${project_path}" || {
                echo "DEPENDENCY_SECURITY_WARNING: Gosec found security issues"
            }
            ;;
            
        "rust")
            # Cargo audit
            SECURITY_SCAN "cargo audit" "${project_path}" || {
                echo "DEPENDENCY_SECURITY_WARNING: Cargo audit found vulnerabilities"
                vulnerability_count=$((vulnerability_count + 1))
            }
            ;;
    esac
    
    # Evaluate security scan results
    total_critical=${critical_vulnerabilities:-0}
    total_high=${high_vulnerabilities:-0}
    
    echo "SECURITY_SCAN_RESULTS: Critical: $total_critical, High: $total_high"
    
    if [ "$fail_on_vulnerabilities" = "true" ]; then
        case $severity_threshold in
            "critical")
                if [ "$total_critical" -gt 0 ]; then
                    echo "DEPENDENCY_SECURITY_FAILURE: $total_critical critical vulnerabilities found"
                    exit 1
                fi
                ;;
            "high")
                if [ "$total_critical" -gt 0 ] || [ "$total_high" -gt 0 ]; then
                    echo "DEPENDENCY_SECURITY_FAILURE: High or critical vulnerabilities found"
                    exit 1
                fi
                ;;
            "medium"|"low")
                if [ "$vulnerability_count" -gt 0 ]; then
                    echo "DEPENDENCY_SECURITY_FAILURE: Security vulnerabilities found"
                    exit 1
                fi
                ;;
        esac
    fi
fi
```

### Step 5: License Compliance Check
```bash
if [ "$check_licenses" = "true" ]; then
    echo "DEPENDENCY_LICENSE_CHECK: Validating license compatibility"
    
    # Define problematic licenses (customize based on organization policy)
    restricted_licenses="GPL-3.0,AGPL-3.0,SSPL-1.0"
    
    case $project_type in
        "javascript"|"typescript")
            # Use license-checker for npm packages
            LICENSE_CHECK "npx license-checker --onlyAllow 'MIT;Apache-2.0;BSD;ISC'" "${project_path}" || {
                echo "DEPENDENCY_LICENSE_WARNING: Potentially incompatible licenses found"
            }
            ;;
            
        "python")
            # Use pip-licenses
            LICENSE_CHECK "pip-licenses --format=json" "${project_path}" || {
                echo "DEPENDENCY_LICENSE_WARNING: Could not retrieve license information"
            }
            ;;
            
        "java")
            # Maven license plugin
            LICENSE_CHECK "mvn license:add-third-party" "${project_path}" || {
                echo "DEPENDENCY_LICENSE_WARNING: Could not generate license report"
            }
            ;;
            
        *)
            echo "DEPENDENCY_LICENSE_INFO: License checking not available for $project_type"
            ;;
    esac
fi
```

### Step 6: Dependency Update Analysis
```bash
if [ "$check_updates" = "true" ]; then
    echo "DEPENDENCY_UPDATE_CHECK: Analyzing available updates"
    
    outdated_count=0
    major_updates=0
    
    case $project_type in
        "javascript"|"typescript")
            # Check for outdated npm packages
            outdated_output=$(npm outdated --json 2>/dev/null || echo '{}')
            outdated_count=$(echo "$outdated_output" | grep -o '"[^"]*":' | wc -l)
            
            echo "DEPENDENCY_UPDATES_AVAILABLE: $outdated_count packages can be updated"
            ;;
            
        "python")
            # Use pip list --outdated
            outdated_output=$(pip list --outdated --format=json 2>/dev/null || echo '[]')
            outdated_count=$(echo "$outdated_output" | grep -o '"name":' | wc -l)
            
            echo "DEPENDENCY_UPDATES_AVAILABLE: $outdated_count packages can be updated"
            ;;
            
        "java")
            # Maven versions plugin
            UPDATE_CHECK "mvn versions:display-dependency-updates" "${project_path}" || {
                echo "DEPENDENCY_UPDATE_INFO: Could not check for Maven updates"
            }
            ;;
            
        "go")
            # Go modules update check
            UPDATE_CHECK "go list -u -m all" "${project_path}" || {
                echo "DEPENDENCY_UPDATE_INFO: Could not check for Go module updates"
            }
            ;;
            
        "rust")
            # Cargo outdated
            UPDATE_CHECK "cargo outdated" "${project_path}" || {
                echo "DEPENDENCY_UPDATE_INFO: Could not check for Cargo updates"
            }
            ;;
    esac
fi
```

## Result Generation and Reporting

### Generate Validation Summary
```bash
# Create comprehensive validation report
validation_summary="{
    \"validation_timestamp\": \"$(date '+%Y-%m-%d %H:%M:%S')\",
    \"project_type\": \"$project_type\",
    \"dependency_files_found\": $dependency_files_found,
    \"resolution_success\": true,
    \"security_scan_enabled\": $check_security,
    \"vulnerabilities\": {
        \"critical\": ${total_critical:-0},
        \"high\": ${total_high:-0},
        \"total\": ${vulnerability_count:-0}
    },
    \"license_check_enabled\": $check_licenses,
    \"update_check_enabled\": $check_updates,
    \"outdated_packages\": ${outdated_count:-0}
}"

# Save validation results
mkdir -p ".ai_workflow/cache"
echo "$validation_summary" > ".ai_workflow/cache/dependency_validation.json"

# Create human-readable report
cat > ".ai_workflow/cache/dependency_report.txt" << EOF
Dependency Validation Report
============================
Project Type: $project_type
Validation Date: $(date '+%Y-%m-%d %H:%M:%S')

Dependency Resolution: ✅ Success
Security Vulnerabilities: ${total_critical:-0} critical, ${total_high:-0} high
License Compliance: $([ "$check_licenses" = "true" ] && echo "Checked" || echo "Skipped")
Available Updates: ${outdated_count:-0} packages

Status: $([ "${total_critical:-0}" -eq 0 ] && echo "PASSED" || echo "REQUIRES_ATTENTION")
EOF
```

## Output Format

### Success Output
```
DEPENDENCY_VALIDATION_SUCCESS: All validations passed
RESOLUTION_STATUS: Success
SECURITY_STATUS: No critical vulnerabilities
LICENSE_STATUS: Compliant
UPDATE_STATUS: 5 updates available
VALIDATION_TIME: 15.3s
```

### Failure Output
```
DEPENDENCY_VALIDATION_FAILED: Critical issues found
RESOLUTION_STATUS: Failed
SECURITY_STATUS: 2 critical vulnerabilities found
FAILED_CHECKS: [
  "SECURITY: Critical vulnerability in package xyz v1.2.3",
  "RESOLUTION: Package abc@2.0.0 not found"
]
RECOMMENDATIONS: [
  "Update xyz package to v1.2.4 or later",
  "Check package registry configuration"
]
```

## Integration Points

### With Quality Gates
- Blocks build if critical dependencies fail validation
- Provides security and compliance metrics
- Feeds into overall quality score calculation

### With Security Workflows
- Integrates with security audit workflows
- Provides vulnerability data for risk assessment
- Triggers security escalation if needed

### With Project Type Detection
- Uses detected project type for appropriate validation
- Adapts validation strategy based on build system
- Leverages framework-specific security tools

## Error Handling

### Network Connectivity Issues
```bash
# Handle offline scenarios gracefully
if ! curl -s --head https://registry.npmjs.org/ > /dev/null 2>&1; then
    echo "DEPENDENCY_WARNING: Limited connectivity, some checks may be skipped"
    check_security=false
    check_updates=false
fi
```

### Missing Tools
```bash
# Check for required tools and fail gracefully
case $project_type in
    "javascript"|"typescript")
        if ! command -v npm > /dev/null 2>&1; then
            echo "DEPENDENCY_ERROR: npm not found in PATH"
            exit 1
        fi
        ;;
esac
```

## Configuration Options

### Project-Level Configuration (.ai_dependency_config.json)
```json
{
    "security_threshold": "high",
    "allowed_licenses": ["MIT", "Apache-2.0", "BSD-3-Clause"],
    "excluded_packages": ["dev-only-package"],
    "update_policy": "patch",
    "fail_on_outdated": false,
    "custom_security_checks": ["semgrep", "snyk"]
}
```

## Success Criteria
- All dependencies can be resolved successfully
- No critical security vulnerabilities (based on threshold)
- License compliance verified
- Comprehensive validation report generated
- Integration with quality gates functional

## Dependencies
- Project type detection workflow
- Abstract tool system (VALIDATE_DEPENDENCIES, SECURITY_SCAN, etc.)
- Network connectivity for security databases
- Package manager tools for target language