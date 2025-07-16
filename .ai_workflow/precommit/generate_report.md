# Generate Pre-commit Report Workflow

## Purpose
Generate comprehensive reports about pre-commit validation system performance, metrics, and configuration status.

## When to Use
- Regular monitoring of pre-commit validation performance
- Analyzing validation trends and patterns
- Generating compliance reports
- Troubleshooting validation issues
- Periodic quality assurance reviews

## Prerequisites
- Pre-commit system configured and operational
- Historical validation data available
- Proper permissions for reading logs and reports

## Report Generation Process

### 1. Initialize Report Environment
```bash
echo "=== Pre-commit Report Generation ==="
echo "Framework: AI Development Framework v0.4.0-beta"
echo "Date: $(date)"
echo ""

# Report paths
REPORTS_DIR=".ai_workflow/precommit/reports"
LOGS_DIR=".ai_workflow/logs"
CONFIG_FILE=".ai_workflow/precommit/config/validation_rules.json"
VALIDATION_REPORTS_DIR="$REPORTS_DIR/validation_reports"

# Create directories if they don't exist
mkdir -p "$REPORTS_DIR"
mkdir -p "$VALIDATION_REPORTS_DIR"

# Generate report timestamp
REPORT_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$REPORTS_DIR/precommit_report_$REPORT_TIMESTAMP.html"
JSON_REPORT="$REPORTS_DIR/precommit_report_$REPORT_TIMESTAMP.json"

echo "✅ Report environment initialized"
echo "  Reports directory: $REPORTS_DIR"
echo "  Report file: $REPORT_FILE"
echo ""
```

### 2. Collect System Information
```bash
echo "=== Collecting System Information ==="

# Git repository info
GIT_REPO=$(git rev-parse --show-toplevel 2>/dev/null || echo "Not a git repository")
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Framework info
FRAMEWORK_VERSION="v0.4.0-beta"
AI_DEV_VERSION=$(./ai-dev version 2>/dev/null | grep -o "v[0-9.]*" || echo "unknown")

# System info
SYSTEM_OS=$(uname -s)
SYSTEM_ARCH=$(uname -m)
BASH_VERSION=$BASH_VERSION
PYTHON_VERSION=$(python3 --version 2>/dev/null || echo "Not available")

echo "📋 System Information:"
echo "  Repository: $GIT_REPO"
echo "  Branch: $GIT_BRANCH"
echo "  Commit: $GIT_COMMIT"
echo "  Framework: $FRAMEWORK_VERSION"
echo "  AI-Dev: $AI_DEV_VERSION"
echo "  System: $SYSTEM_OS $SYSTEM_ARCH"
echo "  Bash: $BASH_VERSION"
echo "  Python: $PYTHON_VERSION"
echo ""
```

### 3. Analyze Configuration Status
```bash
echo "=== Analyzing Configuration Status ==="

config_status="unknown"
config_summary=""

if [ -f "$CONFIG_FILE" ]; then
    config_status="configured"
    
    if command -v python3 >/dev/null 2>&1; then
        config_summary=$(python3 -c "
import json
try:
    with open('$CONFIG_FILE', 'r') as f:
        config = json.load(f)
    
    validation_rules = config.get('validation_rules', {})
    quality_gates = config.get('quality_gates', {})
    hooks = config.get('hooks', {})
    
    # Count enabled rules
    enabled_rules = 0
    total_rules = 0
    
    for category in validation_rules:
        total_rules += 1
        if validation_rules[category].get('enabled', False):
            enabled_rules += 1
    
    # Get quality threshold
    min_score = quality_gates.get('minimum_score', 'not set')
    
    # Get hook status
    hooks_enabled = 0
    hooks_total = 3
    
    for hook in ['pre_commit', 'pre_push', 'commit_msg']:
        if hooks.get(hook, {}).get('enabled', False):
            hooks_enabled += 1
    
    print(f'Validation Rules: {enabled_rules}/{total_rules} enabled')
    print(f'Quality Threshold: {min_score}%')
    print(f'Hooks Enabled: {hooks_enabled}/{hooks_total}')
    print(f'Configuration: Valid JSON')
    
except Exception as e:
    print(f'Configuration Error: {e}')
" 2>/dev/null || echo "Could not analyze configuration")
    else
        config_summary="Configuration file exists but Python not available for analysis"
    fi
else
    config_status="not configured"
    config_summary="No configuration file found"
fi

echo "📋 Configuration Status: $config_status"
echo "$config_summary" | sed 's/^/  /'
echo ""
```

### 4. Analyze Historical Validation Data
```bash
echo "=== Analyzing Historical Validation Data ==="

# Count validation reports
validation_reports_count=0
if [ -d "$VALIDATION_REPORTS_DIR" ]; then
    validation_reports_count=$(find "$VALIDATION_REPORTS_DIR" -name "*.json" | wc -l)
fi

# Count pre-commit logs
precommit_logs_count=0
if [ -d "$LOGS_DIR" ]; then
    precommit_logs_count=$(find "$LOGS_DIR" -name "precommit_*.log" | wc -l)
fi

# Analyze recent validation results
recent_validations=0
passed_validations=0
failed_validations=0

if [ -d "$VALIDATION_REPORTS_DIR" ] && [ $validation_reports_count -gt 0 ]; then
    # Find recent validation reports (last 30 days)
    recent_reports=$(find "$VALIDATION_REPORTS_DIR" -name "*.json" -mtime -30 | sort -r | head -20)
    
    if [ -n "$recent_reports" ] && command -v python3 >/dev/null 2>&1; then
        validation_stats=$(echo "$recent_reports" | python3 -c "
import json
import sys

passed = 0
failed = 0
total = 0

for line in sys.stdin:
    filepath = line.strip()
    if not filepath:
        continue
    
    try:
        with open(filepath, 'r') as f:
            report = json.load(f)
        
        total += 1
        quality_gates = report.get('quality_gates', {})
        
        if quality_gates.get('passed', False):
            passed += 1
        else:
            failed += 1
    except:
        continue

print(f'Total: {total}')
print(f'Passed: {passed}')
print(f'Failed: {failed}')
print(f'Success Rate: {(passed/total*100):.1f}%' if total > 0 else 'Success Rate: N/A')
" 2>/dev/null || echo "Could not analyze validation stats")
        
        recent_validations=$(echo "$validation_stats" | grep "Total:" | cut -d: -f2 | xargs)
        passed_validations=$(echo "$validation_stats" | grep "Passed:" | cut -d: -f2 | xargs)
        failed_validations=$(echo "$validation_stats" | grep "Failed:" | cut -d: -f2 | xargs)
        success_rate=$(echo "$validation_stats" | grep "Success Rate:" | cut -d: -f2 | xargs)
    fi
fi

echo "📊 Historical Data:"
echo "  Validation Reports: $validation_reports_count"
echo "  Pre-commit Logs: $precommit_logs_count"
echo "  Recent Validations (30 days): $recent_validations"
echo "  Passed: $passed_validations"
echo "  Failed: $failed_validations"
echo "  Success Rate: ${success_rate:-N/A}"
echo ""
```

### 5. Analyze Common Issues
```bash
echo "=== Analyzing Common Issues ==="

common_issues=""
issue_count=0

if [ -d "$VALIDATION_REPORTS_DIR" ] && [ $validation_reports_count -gt 0 ]; then
    # Find recent validation reports that failed
    failed_reports=$(find "$VALIDATION_REPORTS_DIR" -name "*.json" -mtime -30 | sort -r | head -10)
    
    if [ -n "$failed_reports" ] && command -v python3 >/dev/null 2>&1; then
        common_issues=$(echo "$failed_reports" | python3 -c "
import json
import sys
from collections import Counter

issues = []

for line in sys.stdin:
    filepath = line.strip()
    if not filepath:
        continue
    
    try:
        with open(filepath, 'r') as f:
            report = json.load(f)
        
        # Check if validation failed
        quality_gates = report.get('quality_gates', {})
        if not quality_gates.get('passed', True):
            issue_counts = report.get('issues', {})
            
            if issue_counts.get('security', 0) > 0:
                issues.append('Security Issues')
            if issue_counts.get('critical', 0) > 0:
                issues.append('Critical Errors')
            if issue_counts.get('quality', 0) > 0:
                issues.append('Quality Issues')
            if issue_counts.get('compliance', 0) > 0:
                issues.append('Compliance Issues')
                
    except:
        continue

# Count common issues
issue_counts = Counter(issues)
total_issues = len(issues)

print(f'Total Issues Analyzed: {total_issues}')
for issue, count in issue_counts.most_common(5):
    print(f'{issue}: {count} occurrences')
" 2>/dev/null || echo "Could not analyze common issues")
        
        issue_count=$(echo "$common_issues" | grep "Total Issues" | cut -d: -f2 | xargs)
    fi
fi

echo "📋 Common Issues Analysis:"
if [ -n "$common_issues" ]; then
    echo "$common_issues" | sed 's/^/  /'
else
    echo "  No recent issues found or insufficient data"
fi
echo ""
```

### 6. Generate Hook Status Report
```bash
echo "=== Checking Hook Status ==="

hook_status=""
hooks_installed=0
hooks_active=0

# Check if hooks are installed
GIT_HOOKS_DIR="$(git rev-parse --git-dir)/hooks"
if [ -d "$GIT_HOOKS_DIR" ]; then
    hook_status="Git hooks directory: $GIT_HOOKS_DIR"
    
    for hook in pre-commit pre-push commit-msg; do
        if [ -f "$GIT_HOOKS_DIR/$hook" ]; then
            hooks_installed=$((hooks_installed + 1))
            if [ -x "$GIT_HOOKS_DIR/$hook" ]; then
                hooks_active=$((hooks_active + 1))
            fi
        fi
    done
else
    hook_status="Git hooks directory not found"
fi

echo "📋 Hook Status:"
echo "  $hook_status"
echo "  Hooks installed: $hooks_installed/3"
echo "  Hooks active: $hooks_active/3"
echo ""
```

### 7. Generate JSON Report
```bash
echo "=== Generating JSON Report ==="

# Create comprehensive JSON report
cat > "$JSON_REPORT" << EOF
{
  "report_metadata": {
    "generated": "$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")",
    "framework_version": "$FRAMEWORK_VERSION",
    "report_type": "pre-commit_analysis",
    "report_version": "1.0"
  },
  "system_info": {
    "repository": "$GIT_REPO",
    "branch": "$GIT_BRANCH",
    "commit": "$GIT_COMMIT",
    "framework_version": "$FRAMEWORK_VERSION",
    "ai_dev_version": "$AI_DEV_VERSION",
    "system": {
      "os": "$SYSTEM_OS",
      "arch": "$SYSTEM_ARCH",
      "bash_version": "$BASH_VERSION",
      "python_version": "$PYTHON_VERSION"
    }
  },
  "configuration": {
    "status": "$config_status",
    "config_file": "$CONFIG_FILE",
    "config_exists": $([ -f "$CONFIG_FILE" ] && echo "true" || echo "false")
  },
  "validation_history": {
    "total_reports": $validation_reports_count,
    "precommit_logs": $precommit_logs_count,
    "recent_validations": $recent_validations,
    "passed_validations": $passed_validations,
    "failed_validations": $failed_validations,
    "success_rate": "${success_rate:-N/A}"
  },
  "hooks": {
    "installed": $hooks_installed,
    "active": $hooks_active,
    "total": 3,
    "hooks_directory": "$GIT_HOOKS_DIR"
  },
  "issues": {
    "total_analyzed": $(echo "$issue_count" | grep -o "[0-9]*" | head -1 || echo "0")
  }
}
EOF

echo "✅ JSON report generated: $JSON_REPORT"
echo ""
```

### 8. Generate HTML Report
```bash
echo "=== Generating HTML Report ==="

# Create comprehensive HTML report
cat > "$REPORT_FILE" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Pre-commit Validation Report - $REPORT_TIMESTAMP</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1, h2 { color: #333; border-bottom: 2px solid #4CAF50; padding-bottom: 10px; }
        .status-good { color: #4CAF50; font-weight: bold; }
        .status-warning { color: #FF9800; font-weight: bold; }
        .status-error { color: #F44336; font-weight: bold; }
        .metric { display: inline-block; margin: 10px; padding: 15px; background: #f0f0f0; border-radius: 5px; min-width: 150px; text-align: center; }
        .metric-value { font-size: 24px; font-weight: bold; color: #333; }
        .metric-label { font-size: 14px; color: #666; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #4CAF50; color: white; }
        .footer { margin-top: 30px; text-align: center; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔍 Pre-commit Validation Report</h1>
        <p><strong>Generated:</strong> $(date)</p>
        <p><strong>Framework:</strong> $FRAMEWORK_VERSION</p>
        
        <h2>📊 Key Metrics</h2>
        <div class="metric">
            <div class="metric-value">$validation_reports_count</div>
            <div class="metric-label">Total Reports</div>
        </div>
        <div class="metric">
            <div class="metric-value">$recent_validations</div>
            <div class="metric-label">Recent Validations</div>
        </div>
        <div class="metric">
            <div class="metric-value">${success_rate:-N/A}</div>
            <div class="metric-label">Success Rate</div>
        </div>
        <div class="metric">
            <div class="metric-value">$hooks_active/3</div>
            <div class="metric-label">Active Hooks</div>
        </div>
        
        <h2>🔧 System Information</h2>
        <table>
            <tr><th>Property</th><th>Value</th></tr>
            <tr><td>Repository</td><td>$GIT_REPO</td></tr>
            <tr><td>Branch</td><td>$GIT_BRANCH</td></tr>
            <tr><td>Commit</td><td>$GIT_COMMIT</td></tr>
            <tr><td>Framework Version</td><td>$FRAMEWORK_VERSION</td></tr>
            <tr><td>System</td><td>$SYSTEM_OS $SYSTEM_ARCH</td></tr>
            <tr><td>Bash Version</td><td>$BASH_VERSION</td></tr>
            <tr><td>Python Version</td><td>$PYTHON_VERSION</td></tr>
        </table>
        
        <h2>⚙️ Configuration Status</h2>
        <p><strong>Status:</strong> <span class="$([ "$config_status" = "configured" ] && echo "status-good" || echo "status-error")">$config_status</span></p>
        <p><strong>Configuration File:</strong> $CONFIG_FILE</p>
        $(if [ -n "$config_summary" ]; then echo "<pre>$config_summary</pre>"; fi)
        
        <h2>🔗 Git Hooks Status</h2>
        <table>
            <tr><th>Hook</th><th>Status</th></tr>
            <tr><td>Pre-commit</td><td>$([ -f "$GIT_HOOKS_DIR/pre-commit" ] && echo '<span class="status-good">Installed</span>' || echo '<span class="status-error">Not Installed</span>')</td></tr>
            <tr><td>Pre-push</td><td>$([ -f "$GIT_HOOKS_DIR/pre-push" ] && echo '<span class="status-good">Installed</span>' || echo '<span class="status-error">Not Installed</span>')</td></tr>
            <tr><td>Commit Message</td><td>$([ -f "$GIT_HOOKS_DIR/commit-msg" ] && echo '<span class="status-good">Installed</span>' || echo '<span class="status-error">Not Installed</span>')</td></tr>
        </table>
        
        <h2>📈 Validation History</h2>
        <table>
            <tr><th>Metric</th><th>Value</th></tr>
            <tr><td>Total Reports</td><td>$validation_reports_count</td></tr>
            <tr><td>Recent Validations (30 days)</td><td>$recent_validations</td></tr>
            <tr><td>Passed Validations</td><td>$passed_validations</td></tr>
            <tr><td>Failed Validations</td><td>$failed_validations</td></tr>
            <tr><td>Success Rate</td><td>${success_rate:-N/A}</td></tr>
        </table>
        
        $(if [ -n "$common_issues" ]; then
            echo "<h2>⚠️ Common Issues</h2>"
            echo "<pre>$common_issues</pre>"
        fi)
        
        <div class="footer">
            <p>Generated by AI Development Framework v$FRAMEWORK_VERSION</p>
            <p>Report ID: $REPORT_TIMESTAMP</p>
        </div>
    </div>
</body>
</html>
EOF

echo "✅ HTML report generated: $REPORT_FILE"
echo ""
```

### 9. Display Report Summary
```bash
echo "=== Report Summary ==="
echo ""
echo "📄 Pre-commit Validation Report Generated Successfully"
echo ""
echo "📊 Key Statistics:"
echo "  • Total validation reports: $validation_reports_count"
echo "  • Recent validations: $recent_validations"
echo "  • Success rate: ${success_rate:-N/A}"
echo "  • Active hooks: $hooks_active/3"
echo "  • Configuration status: $config_status"
echo ""
echo "📁 Generated Files:"
echo "  • HTML Report: $REPORT_FILE"
echo "  • JSON Report: $JSON_REPORT"
echo ""
echo "🔧 Next Steps:"
echo "  • Open HTML report in browser for detailed view"
echo "  • Review configuration if status is not 'configured'"
echo "  • Install missing hooks if needed"
echo "  • Investigate failed validations if success rate is low"
echo ""
echo "✅ Report generation complete!"
```

## Success Criteria
- Comprehensive system information collected
- Historical validation data analyzed
- Configuration status validated
- Common issues identified and reported
- Both HTML and JSON reports generated
- Clear recommendations provided

## Error Handling
- Graceful handling of missing data
- Fallback options when tools unavailable
- Clear error messages for troubleshooting
- Partial report generation if some data missing
- Validation of generated reports

## Integration Points
- Historical validation data integration
- Configuration system integration
- Git hooks status checking
- CLI reporting interface
- File system report storage