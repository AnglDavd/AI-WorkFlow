# Validate Input

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