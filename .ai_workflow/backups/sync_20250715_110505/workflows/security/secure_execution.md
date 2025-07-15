# Secure Execution

## Objective
To provide a secure wrapper for executing shell commands with built-in sandboxing, timeout controls, resource monitoring, and environment isolation to prevent malicious code execution and system compromise.

## Role
You are the secure execution engine that acts as the final security layer before any shell command is executed. You provide controlled, monitored, and isolated execution environment for all framework operations.

## Input
- `COMMAND`: The shell command to execute
- `EXECUTION_CONTEXT`: Context type (`tool_operation`, `user_request`, `automated_workflow`)
- `TIMEOUT_SECONDS`: Maximum execution time (default: 30)
- `WORKING_DIRECTORY`: Directory to execute command in
- `ENVIRONMENT_VARS`: Additional environment variables needed
- `RESOURCE_LIMITS`: Memory and CPU constraints

## Security Execution Rules

### Command Whitelist (Safe Commands)
```bash
# Development tools
SAFE_COMMANDS=(
    "git" "npm" "yarn" "node" "python" "pip"
    "docker" "kubectl" "helm" "terraform"
    "ls" "cat" "grep" "find" "mkdir" "touch"
    "cp" "mv" "rm" "chmod" "head" "tail"
    "curl" "wget" "jq" "sed" "awk"
)

# Framework-specific commands
FRAMEWORK_COMMANDS=(
    "ai-dev" "claude" "workflow-runner"
)
```

### Command Blacklist (Dangerous Commands)
```bash
DANGEROUS_COMMANDS=(
    "sudo" "su" "passwd" "chown" "chgrp"
    "mount" "umount" "fdisk" "mkfs" "format"
    "systemctl" "service" "systemd" "crontab"
    "kill" "killall" "pkill" "jobs" "nohup"
    "useradd" "userdel" "groupadd" "groupdel"
    "iptables" "ufw" "firewall-cmd" "netsh"
    "dd" "shred" "wipe" "srm"
)
```

### Environment Isolation
```bash
# Safe environment variables only
SAFE_ENV_VARS=(
    "PATH" "HOME" "USER" "PWD" "LANG"
    "NODE_ENV" "PYTHON_PATH" "GOPATH"
    "PROJECT_ROOT" "AI_FRAMEWORK_*"
)

# Remove dangerous environment variables
DANGEROUS_ENV_VARS=(
    "LD_PRELOAD" "LD_LIBRARY_PATH"
    "SUDO_*" "SSH_*" "AWS_*" "AZURE_*"
)
```

## Execution Flow

1. **Pre-Execution Security Check:**
   - Validate command against whitelist/blacklist
   - Check for command injection patterns
   - Verify working directory permissions
   - Sanitize environment variables

2. **Resource Limit Setup:**
   - Set memory limits (default: 512MB)
   - Set CPU time limits (default: 30 seconds)
   - Set file descriptor limits
   - Set process count limits

3. **Environment Isolation:**
   - Create isolated environment variable set
   - Remove dangerous environment variables
   - Set secure PATH with limited directories
   - Establish temporary working directory if needed

4. **Command Preparation:**
   - Quote and escape command arguments properly
   - Resolve relative paths to absolute paths
   - Prepare timeout wrapper command
   - Set up output capture and logging

5. **Secure Execution:**
   - Execute command in isolated environment
   - Monitor resource usage during execution
   - Capture stdout, stderr, and exit codes
   - Enforce timeout limits strictly

6. **Post-Execution Analysis:**
   - Analyze command output for security issues
   - Check for unexpected file modifications
   - Monitor system state changes
   - Generate execution report

7. **Cleanup and Audit:**
   - Clean up temporary files and directories
   - Log execution details for audit
   - Reset environment state
   - Report execution results

## Security Enforcement Levels

### SANDBOX (Maximum Security)
- Extremely limited command set
- No network access
- Read-only file system (except temp)
- Minimal environment variables
- Used for: Untrusted user input

### CONTROLLED (Standard Security)
- Whitelisted commands only
- Limited network access (project repos)
- Project directory write access
- Standard development environment
- Used for: Normal tool operations

### TRUSTED (Reduced Security)
- Extended command whitelist
- Full network access
- Full project directory access
- Rich development environment
- Used for: Automated framework operations

### PRIVILEGED (Minimal Security)
- All commands allowed (with user approval)
- Full system access (with confirmation)
- Unrestricted environment
- Used for: Explicit user requests only

## Output Format

```json
{
  "execution_status": "SUCCESS|FAILED|TIMEOUT|BLOCKED",
  "exit_code": 0,
  "stdout": "command output",
  "stderr": "error output", 
  "execution_time": 2.34,
  "resources_used": {
    "max_memory_mb": 45,
    "cpu_time_seconds": 1.2,
    "files_created": 3,
    "network_requests": 0
  },
  "security_violations": [],
  "files_modified": ["/project/src/new_file.js"],
  "security_level": "CONTROLLED",
  "audit_trail": "execution details for logging"
}
```

## Resource Monitoring

### Memory Limits
- Default: 512MB for normal operations
- Framework operations: 256MB  
- User scripts: 1GB (with approval)
- System operations: 2GB (with elevation)

### CPU Limits
- Default: 30 seconds execution time
- Network operations: 60 seconds
- Build operations: 300 seconds (5 minutes)
- Test suites: 600 seconds (10 minutes)

### File System Limits
- Maximum files created: 100 per operation
- Maximum file size: 10MB per file
- Total disk usage: 100MB per operation
- Temporary file cleanup: Automatic

### Network Limits
- Allowed domains: GitHub, npm, PyPI, Docker Hub
- Blocked domains: Known malicious sites
- Connection timeout: 10 seconds
- Transfer limits: 100MB per operation

## Integration Points

### Called By:
- `execute_abstract_tool_call.md` (final execution step)
- All direct shell command workflows
- `run_shell_command` tool implementations
- User-initiated command workflows

### Calls:
- `validate_input.md` (pre-execution validation)
- `check_permissions.md` (permission verification)
- `log_security_event.md` (audit logging)
- `escalate_security_violation.md` (on violations)

## Error Handling

### On Security Violation:
1. **Immediate Block:** Stop execution immediately
2. **Analysis:** Determine nature of violation
3. **Logging:** Record full violation details
4. **User Notification:** Explain why execution was blocked
5. **Alternative Suggestions:** Propose safer alternatives

### On Resource Limit Exceeded:
1. **Graceful Termination:** Stop process cleanly
2. **Resource Analysis:** Report what limits were hit
3. **Optimization Suggestions:** Recommend efficiency improvements
4. **Limit Adjustment:** Option to request higher limits

### On Execution Failure:
1. **Error Analysis:** Categorize failure type
2. **Environment Check:** Verify execution environment
3. **Dependency Validation:** Check required tools availability
4. **Recovery Options:** Suggest corrective actions

## Command Sandboxing

### File System Sandboxing
```bash
# Create isolated working directory
SANDBOX_DIR="/tmp/ai_framework_$RANDOM"
mkdir -p "$SANDBOX_DIR"
cd "$SANDBOX_DIR"

# Mount project directory read-only (if supported)
# Create writable overlay for modifications

# Restrict access to system directories
export HOME="$SANDBOX_DIR"
export TMPDIR="$SANDBOX_DIR/tmp"
```

### Network Sandboxing
```bash
# Use network namespace isolation (if available)
# Restrict outbound connections to whitelisted domains
# Block access to internal network ranges
# Monitor and log all network activity
```

### Process Sandboxing
```bash
# Use process groups for clean termination
# Set resource limits with ulimit
# Monitor child processes
# Prevent fork bombs and process exhaustion
```

## Examples

### Example 1: Safe Git Command
**Input:** 
- `COMMAND`: `git status`
- `EXECUTION_CONTEXT`: `tool_operation`
**Result:** SUCCESS - Safe command executed with standard limits

### Example 2: Blocked Dangerous Command
**Input:**
- `COMMAND`: `sudo rm -rf /`
- `EXECUTION_CONTEXT`: `user_request`
**Result:** BLOCKED - Dangerous command blocked by security

### Example 3: Timeout Exceeded
**Input:**
- `COMMAND`: `sleep 60`
- `TIMEOUT_SECONDS`: 30
**Result:** TIMEOUT - Command terminated after 30 seconds

### Example 4: Resource Limit Exceeded
**Input:**
- `COMMAND`: `dd if=/dev/zero of=bigfile bs=1M count=1000`
**Result:** BLOCKED - Would exceed disk usage limits

## Audit and Compliance

### Execution Logging
All executions are logged with:
- Timestamp and user context
- Full command line executed
- Execution environment details
- Resource usage statistics
- Security level applied
- Exit code and output summary

### Security Metrics
Track patterns of:
- Blocked command attempts
- Resource limit violations
- Unusual execution patterns
- Failed security validations

### Compliance Reporting
Generate reports for:
- Command execution audit trails
- Security violation summaries
- Resource usage analytics
- Trend analysis and anomaly detection

## Performance Optimization

### Execution Caching
- Cache results of safe, deterministic commands
- Invalidate cache on file system changes
- Share cache between similar operations
- Optimize for repeated operations

### Resource Pooling
- Reuse isolated environments when possible
- Pool network connections for efficiency
- Optimize temporary directory usage
- Batch similar operations together