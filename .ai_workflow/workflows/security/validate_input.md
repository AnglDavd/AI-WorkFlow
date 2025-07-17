# Validate Input

## Purpose
To sanitize and validate all inputs (file paths, commands, arguments) before they are processed by the Tool Abstraction Layer, preventing malicious code injection, path traversal attacks, and unauthorized system access.

## When to Use
- Before processing any user input through the Tool Abstraction Layer
- When validating file paths, commands, or arguments
- As the first line of defense for framework security
- Before executing any abstract tool calls
- When security validation is required for any input string

## Objective
To sanitize and validate all inputs (file paths, commands, arguments) before they are processed by the Tool Abstraction Layer, preventing malicious code injection, path traversal attacks, and unauthorized system access.

## Role
You are a security validation layer that acts as the first line of defense for the framework. Every input must pass through your validation before any tool execution can proceed.

## Input
- `INPUT_STRING`: The raw input string to validate (e.g., abstract tool call)
- `VALIDATION_TYPE`: Type of validation needed (`tool_call`, `file_path`, `command_args`)
- `CONTEXT`: Execution context (`user_request`, `automated_workflow`, `system_internal`)

## Security Rules

### Critical Path Patterns (FORBIDDEN)
```
/etc/
/root/
/home/*/.*ssh/
/home/*/.aws/
/home/*/.config/
/var/log/
/proc/
/sys/
/dev/
/boot/
/usr/bin/
/usr/sbin/
/sbin/
/bin/
```

### Dangerous Command Patterns (FORBIDDEN)
```
sudo
su -
rm -rf
chmod 777
chown
passwd
useradd
userdel
systemctl
service
kill -9
pkill
killall
format
dd if=
curl.*|.*sh
wget.*|.*sh
eval
exec
```

### Path Traversal Patterns (FORBIDDEN)
```
../
..\\
%2e%2e%2f
%252e%252e%252f
..%2f
..%5c
%c0%ae%c0%ae%c0%af
```

### Command Injection Patterns (FORBIDDEN)
```
;
&&
||
|
`
$()
${
$(
```

## Commands

```bash
#!/bin/bash

# Input Validation Security Layer
# Validates all inputs before they reach the Tool Abstraction Layer

# Set security context
SECURITY_CONTEXT="${CONTEXT:-user_request}"
VALIDATION_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
VALIDATION_LOG=".ai_workflow/logs/security_validation_$(date +%Y%m%d).log"

# Initialize logging
mkdir -p ".ai_workflow/logs"
echo "[$VALIDATION_TIMESTAMP] Starting input validation: $INPUT_STRING" >> "$VALIDATION_LOG"

# Critical path validation
validate_critical_paths() {
    local input="$1"
    local forbidden_paths=(
        "/etc/" "/root/" "/home/*/.*ssh/" "/home/*/.aws/" "/home/*/.config/"
        "/var/log/" "/proc/" "/sys/" "/dev/" "/boot/" "/usr/bin/" "/usr/sbin/" "/sbin/" "/bin/"
    )
    
    for path in "${forbidden_paths[@]}"; do
        if [[ "$input" =~ $path ]]; then
            echo "RED: Critical path violation detected: $path"
            echo "[$VALIDATION_TIMESTAMP] CRITICAL: Path violation - $path in: $input" >> "$VALIDATION_LOG"
            return 1
        fi
    done
    return 0
}

# Command injection validation
validate_command_injection() {
    local input="$1"
    local dangerous_patterns=(
        "sudo" "su -" "rm -rf" "chmod 777" "chown" "passwd" "useradd" "userdel"
        "systemctl" "service" "kill -9" "pkill" "killall" "format" "dd if="
        "curl.*|.*sh" "wget.*|.*sh" "eval" "exec"
    )
    
    for pattern in "${dangerous_patterns[@]}"; do
        if [[ "$input" =~ $pattern ]]; then
            echo "RED: Dangerous command pattern detected: $pattern"
            echo "[$VALIDATION_TIMESTAMP] CRITICAL: Command injection - $pattern in: $input" >> "$VALIDATION_LOG"
            return 1
        fi
    done
    return 0
}

# Path traversal validation
validate_path_traversal() {
    local input="$1"
    local traversal_patterns=(
        "../" "..\\\\" "%2e%2e%2f" "%252e%252e%252f" "..%2f" "..%5c" "%c0%ae%c0%ae%c0%af"
    )
    
    for pattern in "${traversal_patterns[@]}"; do
        if [[ "$input" =~ $pattern ]]; then
            echo "RED: Path traversal attempt detected: $pattern"
            echo "[$VALIDATION_TIMESTAMP] CRITICAL: Path traversal - $pattern in: $input" >> "$VALIDATION_LOG"
            return 1
        fi
    done
    return 0
}

# Validate shell metacharacters
validate_shell_metacharacters() {
    local input="$1"
    local meta_patterns=(
        ";" "&&" "||" "|" "\`" "\$(" "\$\{" "\$("
    )
    
    for pattern in "${meta_patterns[@]}"; do
        if [[ "$input" =~ $pattern ]]; then
            echo "YELLOW: Shell metacharacter detected: $pattern"
            echo "[$VALIDATION_TIMESTAMP] WARNING: Shell metachar - $pattern in: $input" >> "$VALIDATION_LOG"
            return 2  # Warning level
        fi
    done
    return 0
}

# Main validation function
validate_input() {
    local input_string="$INPUT_STRING"
    local validation_type="$VALIDATION_TYPE"
    local security_status="GREEN"
    local violations=()
    local modifications=()
    
    echo "🔒 Starting security validation..."
    echo "Input: $input_string"
    echo "Type: $validation_type"
    echo "Context: $SECURITY_CONTEXT"
    
    # Run all validation checks
    if ! validate_critical_paths "$input_string"; then
        security_status="RED"
        violations+=("critical_path_violation")
    fi
    
    if ! validate_command_injection "$input_string"; then
        security_status="RED"
        violations+=("command_injection_attempt")
    fi
    
    if ! validate_path_traversal "$input_string"; then
        security_status="RED"
        violations+=("path_traversal_attempt")
    fi
    
    # Check for shell metacharacters (warning level)
    if validate_shell_metacharacters "$input_string"; then
        if [[ $? -eq 2 && "$security_status" == "GREEN" ]]; then
            security_status="YELLOW"
            violations+=("shell_metacharacters")
        fi
    fi
    
    # Generate sanitized input
    sanitized_input="$input_string"
    if [[ "$security_status" == "YELLOW" ]]; then
        # Apply basic sanitization for yellow status
        sanitized_input=$(echo "$input_string" | sed 's/[;&|`$()]//g')
        modifications+=("removed_shell_metacharacters")
    fi
    
    # Output validation result
    echo "Security Status: $security_status"
    echo "Violations: ${violations[*]}"
    echo "Modifications: ${modifications[*]}"
    echo "Sanitized Input: $sanitized_input"
    
    # Log final result
    echo "[$VALIDATION_TIMESTAMP] RESULT: $security_status - Violations: ${violations[*]}" >> "$VALIDATION_LOG"
    
    # Export results for caller
    export VALIDATION_STATUS="$security_status"
    export SANITIZED_INPUT="$sanitized_input"
    export SECURITY_VIOLATIONS="${violations[*]}"
    export SECURITY_MODIFICATIONS="${modifications[*]}"
    
    # Return appropriate exit code
    case "$security_status" in
        "GREEN") return 0 ;;
        "YELLOW") return 1 ;;
        "RED") return 2 ;;
    esac
}

# Execute validation
validate_input

# Handle results based on validation status
case "$VALIDATION_STATUS" in
    "GREEN")
        echo "✅ Security validation passed - proceeding"
        ;;
    "YELLOW")
        echo "⚠️  Security validation passed with warnings - proceeding with caution"
        ;;
    "RED")
        echo "🚫 Security validation failed - blocking execution"
        echo "[$VALIDATION_TIMESTAMP] BLOCKED: $INPUT_STRING" >> "$VALIDATION_LOG"
        exit 1
        ;;
esac
```

## Verification Criteria
- All inputs must pass security validation before tool execution
- Critical security violations must be blocked immediately
- All validation attempts must be logged with timestamps
- Sanitized inputs must maintain functional equivalence when safe
- Security clearance levels must be correctly assigned
- Audit trail must be maintained for all validation activities

## Next Steps
- **On GREEN status**: Proceed with tool execution using original or sanitized input
- **On YELLOW status**: Proceed with enhanced logging and monitoring
- **On RED status**: Block execution and escalate security violation
- **On validation error**: Apply most restrictive security measures

## Execution Flow

1. **Initialize Security Context:**
   - Log validation attempt with timestamp
   - Set security level based on `CONTEXT`
   - Initialize violation tracking

2. **Parse Input String:**
   - Extract tool name, action, and all arguments
   - Identify any file paths, URLs, or executable commands
   - Create sanitized parameter map

3. **Critical Path Validation:**
   - Check all file paths against `Critical Path Patterns`
   - Validate that paths stay within project boundaries
   - Ensure no access to system directories
   - **If violation found:** Call `escalate_security_violation.md`

4. **Command Injection Prevention:**
   - Scan for dangerous command patterns
   - Check for shell metacharacters in arguments
   - Validate command separator sequences
   - **If violation found:** Call `escalate_security_violation.md`

5. **Path Traversal Prevention:**
   - Normalize all file paths (resolve . and ..)
   - Check for encoded traversal attempts
   - Ensure paths remain within allowed directories
   - **If violation found:** Call `escalate_security_violation.md`

6. **Argument Sanitization:**
   - Escape special characters in string arguments
   - Validate numeric arguments are actually numeric
   - Check URL arguments for malicious protocols
   - Remove or escape potentially dangerous characters

7. **Tool-Specific Validation:**
   - Apply additional validation rules based on tool type
   - Check git commands for dangerous flags
   - Validate npm/yarn commands for registry tampering
   - Ensure HTTP requests use safe methods and headers

8. **Generate Validation Report:**
   - Create sanitized input string
   - Log all modifications made
   - Set security clearance level
   - Return validation status

## Security Clearance Levels

### GREEN (Safe to Execute)
- Input passed all validation checks
- No suspicious patterns detected
- Within project scope and normal operations

### YELLOW (Proceed with Caution)
- Minor sanitization applied
- Potentially risky but allowable operation
- Requires additional logging and monitoring

### RED (Blocked - Security Violation)
- Critical security pattern detected
- Potential malicious intent
- Execution must be prevented

## Output Format

```json
{
  "validation_status": "GREEN|YELLOW|RED",
  "sanitized_input": "cleaned input string",
  "violations_found": ["list", "of", "security", "issues"],
  "modifications_made": ["list", "of", "sanitizations"],
  "security_notes": "additional context for logging",
  "recommended_action": "proceed|log_and_proceed|block_and_escalate"
}
```

## Integration Points

### Called By:
- `execute_abstract_tool_call.md` (Step 1 - before parsing)
- `run_shell_command` (before any direct command execution)
- User input handlers in CLI workflows

### Calls:
- `escalate_security_violation.md` (when RED violations found)
- `log_security_event.md` (for all validation attempts)
- `check_permissions.md` (for additional permission validation)

## Error Handling

### On Security Violation:
1. **Immediate Action:** Block execution
2. **Logging:** Record full violation details
3. **User Notification:** Explain why input was blocked
4. **Escalation:** Call security escalation workflow
5. **Recovery:** Suggest safe alternatives if possible

### On Validation Failure:
1. **Fallback:** Apply most restrictive validation
2. **Logging:** Record validation system error
3. **User Notification:** Explain validation system issue
4. **Manual Override:** Allow manual review for legitimate cases

## Security Audit Trail

All validation attempts are logged with:
- Timestamp
- Input source (user/automated)
- Original input string
- Validation result
- Modifications applied
- Security clearance given
- Tool execution result (if proceeded)

## Examples

### Example 1: Safe Git Command
**Input:** `tool.git.add_all()`
**Result:** GREEN - No violations, proceed normally

### Example 2: Dangerous Path Traversal
**Input:** `tool.file.read(path="../../../etc/passwd")`
**Result:** RED - Path traversal attempt, block execution

### Example 3: Command Injection Attempt
**Input:** `tool.npm.install(package="lodash; rm -rf /")`
**Result:** RED - Command injection detected, block execution

### Example 4: Sanitized File Path
**Input:** `tool.file.write(path="src/component.js", content="...")`
**Result:** GREEN - Safe project file, proceed normally

## Framework Integration

This validation layer integrates with:
- **Token Economy:** Security violations consume warning tokens
- **Error Handling:** Security blocks trigger error workflows
- **Audit System:** All validations feed into security audit logs
- **User Experience:** Clear explanations for blocked operations