# Audit Security

## Objective
To perform comprehensive security audits of the AI framework, analyzing workflows, configurations, dependencies, and execution patterns to identify vulnerabilities, policy violations, and security improvements.

## Role
You are the security auditor that continuously monitors the framework's security posture, identifies potential vulnerabilities, and generates actionable security reports for maintaining a secure development environment.

## Input
- `AUDIT_TYPE`: Type of audit (`full_framework`, `workflow_security`, `dependency_scan`, `execution_analysis`)
- `AUDIT_SCOPE`: Scope of audit (`project_only`, `framework_only`, `system_wide`)
- `SCHEDULE_TYPE`: Audit scheduling (`manual`, `scheduled`, `triggered`)
- `COMPLIANCE_STANDARDS`: Standards to check against (`internal`, `owasp`, `nist`)

## Security Audit Areas

### Framework Security Analysis
```
1. Workflow File Security:
   - Scan all .md workflows for security issues
   - Check for hardcoded secrets or credentials
   - Validate input sanitization in workflows
   - Identify privilege escalation patterns

2. Configuration Security:
   - Audit framework configuration files
   - Check for insecure default settings
   - Validate access control configurations
   - Review environment variable usage

3. Tool Abstraction Security:
   - Analyze adapter implementations
   - Check for command injection vulnerabilities
   - Validate input validation in adapters
   - Review tool permission requirements
```

### Dependency Security Scanning
```
1. Language-Specific Dependencies:
   - npm audit (Node.js projects)
   - pip-audit (Python projects)
   - cargo audit (Rust projects)
   - go mod audit (Go projects)

2. Framework Dependencies:
   - Audit internal framework components
   - Check for outdated security patches
   - Validate third-party integrations
   - Review external service connections

3. System Dependencies:
   - Check system package vulnerabilities
   - Audit container image dependencies
   - Review development tool security
   - Validate infrastructure components
```

### Execution Pattern Analysis
```
1. Command Execution Patterns:
   - Analyze executed commands for anomalies
   - Detect suspicious command sequences
   - Identify privilege escalation attempts
   - Monitor resource usage patterns

2. File Access Patterns:
   - Review file access logs for violations
   - Detect unauthorized directory access
   - Monitor critical file modifications
   - Analyze permission change patterns

3. Network Activity Analysis:
   - Monitor outbound network connections
   - Detect suspicious domain accesses
   - Analyze data transfer patterns
   - Review API endpoint usage
```

## Execution Flow

1. **Initialize Security Audit:**
   - Set audit context and timestamp
   - Determine audit scope and depth
   - Initialize vulnerability tracking
   - Prepare audit environment

2. **Framework Structure Analysis:**
   - Scan all workflow files (.md)
   - Analyze configuration files
   - Check file permissions and ownership
   - Review directory structure security

3. **Workflow Security Scanning:**
   - Parse workflow files for security patterns
   - Detect hardcoded secrets or credentials
   - Check for input validation gaps
   - Identify dangerous command patterns

4. **Dependency Vulnerability Scanning:**
   - Run language-specific security scanners
   - Check for known CVEs in dependencies
   - Analyze dependency chains for risks
   - Review third-party service integrations

5. **Execution Log Analysis:**
   - Review recent command executions
   - Analyze security violation logs
   - Check permission denial patterns
   - Monitor resource usage anomalies

6. **Configuration Security Review:**
   - Audit framework settings
   - Check environment variable security
   - Review access control policies
   - Validate security default settings

7. **Generate Security Report:**
   - Compile findings by severity
   - Provide remediation recommendations
   - Generate compliance status
   - Create actionable improvement plan

## Security Severity Levels

### CRITICAL (Immediate Action Required)
- Remote code execution vulnerabilities
- Privilege escalation exploits
- Hardcoded secrets in source code
- System compromise indicators

### HIGH (Fix Within 24 Hours)
- Local privilege escalation
- Information disclosure vulnerabilities
- Unsafe default configurations
- Missing security validations

### MEDIUM (Fix Within 1 Week)
- Denial of service vulnerabilities
- Security misconfiguration issues
- Outdated dependencies with known issues
- Weak access controls

### LOW (Fix Within 1 Month)
- Information leakage (non-sensitive)
- Security best practice violations
- Minor configuration improvements
- Documentation security gaps

### INFORMATIONAL (For Awareness)
- Security recommendations
- Best practice suggestions
- Compliance improvements
- Educational security notes

## Output Format

```json
{
  "audit_summary": {
    "audit_id": "audit_20240101_123456",
    "timestamp": "2024-01-01T12:34:56Z",
    "audit_type": "full_framework",
    "scope": "project_only",
    "duration_seconds": 45,
    "total_issues": 12
  },
  "severity_breakdown": {
    "critical": 0,
    "high": 2,
    "medium": 5,
    "low": 4,
    "informational": 1
  },
  "findings": [
    {
      "id": "SEC-001",
      "severity": "HIGH",
      "category": "Configuration Security",
      "title": "Insecure default permissions",
      "description": "Default file permissions allow world-writable access",
      "location": ".ai_workflow/tools/adapters/",
      "impact": "Potential unauthorized file modifications",
      "remediation": "Set restrictive permissions (644 for files, 755 for directories)",
      "cve_references": [],
      "compliance_violations": ["NIST SP 800-53 AC-3"]
    }
  ],
  "compliance_status": {
    "internal_policies": "PASS",
    "owasp_top10": "PARTIAL",
    "nist_framework": "FAIL"
  },
  "recommendations": [
    "Implement automated security scanning in CI/CD",
    "Add input validation to all user-facing workflows",
    "Enable security logging for all operations"
  ]
}
```

## Automated Security Checks

### Vulnerability Pattern Detection
```bash
# Common vulnerability patterns to scan for
VULNERABILITY_PATTERNS=(
    # Command injection
    'eval.*\$'
    'exec.*\$'
    'system.*\$'
    
    # Path traversal
    '\.\./.*'
    '\.\.\\.*'
    
    # Hardcoded secrets
    'password.*=.*["\'].*["\']'
    'api[_-]?key.*=.*["\'].*["\']'
    'secret.*=.*["\'].*["\']'
    'token.*=.*["\'].*["\']'
    
    # Dangerous file operations
    'rm.*-rf.*\$'
    'chmod.*777'
    'chown.*root'
)
```

### Configuration Security Checks
```bash
# Security configuration validations
check_file_permissions() {
    find .ai_workflow -type f -perm /002 -ls  # World-writable files
    find .ai_workflow -type d -perm /002 -ls  # World-writable directories
}

check_environment_variables() {
    env | grep -E "(PASSWORD|SECRET|KEY|TOKEN)" | grep -v "EXAMPLE"
}

check_git_security() {
    git secrets --scan --all  # If git-secrets is available
    git log --grep="password\|secret\|key" --oneline
}
```

### Dependency Security Scanning
```bash
# Language-specific security scans
scan_npm_vulnerabilities() {
    if [ -f package.json ]; then
        npm audit --audit-level moderate
    fi
}

scan_python_vulnerabilities() {
    if [ -f requirements.txt ]; then
        pip-audit -r requirements.txt
    fi
}

scan_docker_vulnerabilities() {
    if [ -f Dockerfile ]; then
        trivy fs . --security-checks vuln
    fi
}
```

## Integration Points

### Called By:
- Scheduled cron job (daily/weekly audits)
- Pre-commit hooks (code change audits)
- CI/CD pipeline (deployment audits)
- Manual security reviews
- `ai-dev audit` command

### Calls:
- `log_security_event.md` (audit logging)
- `generate_security_report.md` (report generation)
- `escalate_security_violation.md` (critical findings)
- External security tools (npm audit, etc.)

## Compliance Frameworks

### OWASP Top 10 Checks
1. **Injection Flaws:** Scan for command/code injection
2. **Broken Authentication:** Review auth mechanisms
3. **Sensitive Data Exposure:** Check for data leaks
4. **XML External Entities:** Validate XML processing
5. **Broken Access Control:** Review permission systems
6. **Security Misconfiguration:** Audit configurations
7. **Cross-Site Scripting:** Check web interfaces
8. **Insecure Deserialization:** Review data handling
9. **Known Vulnerabilities:** Scan dependencies
10. **Insufficient Logging:** Verify audit trails

### NIST Cybersecurity Framework
- **Identify:** Asset inventory and risk assessment
- **Protect:** Access controls and protective technology
- **Detect:** Anomaly detection and monitoring
- **Respond:** Incident response procedures
- **Recover:** Recovery planning and improvements

## Remediation Workflows

### Automated Fixes
- Update outdated dependencies
- Fix common configuration issues
- Apply security patches automatically
- Correct file permissions

### Manual Review Required
- Code injection vulnerabilities
- Architecture security issues
- Complex configuration problems
- Policy compliance violations

### User Notification
- Critical security findings
- Required manual actions
- Compliance deadlines
- Security training recommendations

## Examples

### Example 1: Clean Framework Audit
**Input:** `AUDIT_TYPE=full_framework`
**Result:** All checks pass, no vulnerabilities found

### Example 2: Dependency Vulnerability Found
**Finding:** High severity npm package vulnerability
**Action:** Generate report, suggest update, track remediation

### Example 3: Configuration Issue Detected
**Finding:** World-writable workflow files
**Action:** Automatic fix with permission correction

### Example 4: Hardcoded Secret Detection
**Finding:** API key in workflow file
**Action:** Critical alert, block execution, require immediate fix

## Continuous Security Monitoring

### Real-Time Monitoring
- Monitor execution logs for anomalies
- Track permission violations
- Watch for unusual command patterns
- Alert on security threshold breaches

### Trend Analysis
- Track security improvements over time
- Identify recurring vulnerability patterns
- Monitor remediation effectiveness
- Analyze security metric trends

### Reporting Schedule
- **Daily:** Critical vulnerability scans
- **Weekly:** Full framework security audit
- **Monthly:** Compliance assessment report
- **Quarterly:** Security posture review

## Security Metrics and KPIs

### Vulnerability Metrics
- Mean time to vulnerability detection
- Mean time to vulnerability remediation
- Vulnerability density by component
- Recurring vulnerability patterns

### Security Process Metrics
- Audit coverage percentage
- False positive rates
- Security review completion rates
- Compliance score trends

### Operational Security Metrics
- Security incident frequency
- Permission violation rates
- Anomalous execution patterns
- User security training completion