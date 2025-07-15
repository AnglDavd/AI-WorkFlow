# Check Permissions

## Objective
To verify that the framework has appropriate read/write permissions for file operations and detect operations that require elevated privileges, ensuring secure and authorized access to system resources.

## Role
You are a permission validation system that checks file system access rights before any file operations are performed. You prevent unauthorized access and alert users when elevated privileges are needed.

## Input
- `OPERATION_TYPE`: Type of operation (`read`, `write`, `delete`, `execute`, `create_directory`)
- `TARGET_PATH`: Absolute path to the target file or directory
- `USER_CONTEXT`: Current user context (`normal_user`, `elevated`, `system`)
- `REQUIRED_PERMISSIONS`: Specific permissions needed (e.g., `644`, `755`)

## Permission Rules

### Project Boundary Enforcement
```bash
# Allowed project directories
ALLOWED_DIRS=(
    "$PROJECT_ROOT"
    "$PROJECT_ROOT/.ai_workflow"
    "$PROJECT_ROOT/src"
    "$PROJECT_ROOT/docs"
    "$PROJECT_ROOT/tests"
    "$PROJECT_ROOT/examples"
    "$PROJECT_ROOT/.git"
    "/tmp/ai_framework_*"
)

# Forbidden system directories (even with permissions)
FORBIDDEN_DIRS=(
    "/etc"
    "/root"
    "/var/log"
    "/usr/bin"
    "/usr/sbin"
    "/sbin"
    "/bin"
    "/boot"
    "/proc"
    "/sys"
    "/dev"
)
```

### Required Permission Levels
```
READ_OPERATIONS: 
  - Files: r-- (400 minimum)
  - Directories: r-x (500 minimum)

WRITE_OPERATIONS:
  - Files: rw- (600 minimum)
  - Directories: rwx (700 minimum)

EXECUTE_OPERATIONS:
  - Files: r-x (500 minimum)
  - Scripts: rwx (700 required)

CREATE_OPERATIONS:
  - Parent directory: rwx (700 required)
```

## Execution Flow

1. **Initialize Permission Check:**
   - Resolve target path to absolute path
   - Identify current user and group
   - Set operation context and requirements

2. **Boundary Validation:**
   - Verify target path is within allowed project boundaries
   - Check against forbidden system directories
   - Ensure no symlink attacks to system paths
   - **If violation found:** Call `escalate_permission_violation.md`

3. **Path Existence and Type Check:**
   - Check if target path exists
   - Determine if it's a file, directory, or symlink
   - Validate parent directory permissions for create operations
   - Handle special cases (pipes, devices, etc.)

4. **Permission Level Analysis:**
   - Get current file/directory permissions using `stat`
   - Compare against required permission levels
   - Check owner and group membership
   - Identify if elevated privileges are needed

5. **User Context Validation:**
   - Verify current user has necessary access
   - Check group membership for group permissions
   - Detect if sudo/root access is required
   - Validate against user's actual capabilities

6. **Critical Operation Detection:**
   - Identify operations that modify critical files
   - Check for operations requiring system-level access
   - Detect potentially destructive operations
   - Flag operations needing user confirmation

7. **Generate Permission Report:**
   - Document current permissions vs. required
   - List any missing permissions
   - Identify recommended actions
   - Set permission clearance level

## Permission Clearance Levels

### GRANTED (Full Access)
- User has all required permissions
- Operation is within safe boundaries
- No elevated privileges needed

### CONDITIONAL (Needs Confirmation)
- Permissions available but operation is sensitive
- Requires user approval for critical files
- May need temporary permission elevation

### DENIED (Insufficient Permissions)
- User lacks required permissions
- Operation would require dangerous privilege escalation
- Target is outside allowed boundaries

### ELEVATED (Requires Sudo)
- Operation needs root/admin privileges
- Must be explicitly authorized by user
- Requires additional security validation

## Output Format

```json
{
  "permission_status": "GRANTED|CONDITIONAL|DENIED|ELEVATED",
  "current_permissions": "755",
  "required_permissions": "644",
  "permission_gaps": ["write access to parent directory"],
  "user_can_access": true,
  "needs_elevation": false,
  "boundary_check": "within_project",
  "critical_operation": false,
  "recommended_action": "proceed|request_user_confirmation|deny_access|request_elevation",
  "security_notes": "additional context for decision"
}
```

## Security Checks

### Symlink Attack Prevention
- Resolve all symlinks in path
- Verify symlink targets are within boundaries
- Check for symlink loops
- Prevent symlink privilege escalation

### Race Condition Prevention
- Lock files during permission checks
- Validate permissions immediately before operations
- Handle time-of-check-time-of-use (TOCTOU) attacks
- Re-verify permissions for long-running operations

### Privilege Escalation Detection
- Monitor for unexpected permission changes
- Detect setuid/setgid file creation
- Check for suspicious ownership changes
- Alert on attempts to modify system files

## Integration Points

### Called By:
- `validate_input.md` (for file path operations)
- `secure_execution.md` (before command execution)
- All file manipulation workflows
- `execute_abstract_tool_call.md` (for file operations)

### Calls:
- `escalate_permission_violation.md` (when access denied)
- `request_user_elevation.md` (when sudo needed)
- `log_permission_event.md` (for audit trail)
- `confirm_file_change.md` (for critical operations)

## Error Handling

### On Permission Denied:
1. **Analysis:** Determine exact permission gap
2. **User Guidance:** Suggest how to fix permissions
3. **Safe Alternatives:** Propose alternative approaches
4. **Escalation:** Offer to request elevated access if appropriate

### On System Boundary Violation:
1. **Immediate Block:** Prevent any system access
2. **Security Alert:** Log potential security breach attempt
3. **User Education:** Explain why operation was blocked
4. **Safe Redirection:** Suggest project-relative alternatives

## Permission Management

### Automatic Permission Fixes
- Suggest chmod commands for common issues
- Offer to create directories with proper permissions
- Recommend git configuration for executable files
- Provide guidance for workspace setup

### User Interaction for Elevation
- Clear explanation of why elevation is needed
- Specific command that will be run with sudo
- Security implications of granting access
- Option to deny and choose alternative approach

## Examples

### Example 1: Safe Project File Write
**Input:** 
- `OPERATION_TYPE`: `write`
- `TARGET_PATH`: `/project/src/component.js`
**Result:** GRANTED - User has write access to project files

### Example 2: System Directory Access Attempt
**Input:**
- `OPERATION_TYPE`: `read` 
- `TARGET_PATH`: `/etc/passwd`
**Result:** DENIED - System directory access not allowed

### Example 3: Missing Parent Directory
**Input:**
- `OPERATION_TYPE`: `create`
- `TARGET_PATH`: `/project/new_dir/file.js`
**Result:** CONDITIONAL - Need to create parent directory first

### Example 4: Git Configuration Change
**Input:**
- `OPERATION_TYPE`: `write`
- `TARGET_PATH`: `/project/.git/config`
**Result:** CONDITIONAL - Critical git file, needs confirmation

## Audit and Monitoring

### Permission Event Logging
All permission checks are logged with:
- Timestamp and user context
- Operation type and target path
- Permission analysis results
- Decision made and reasoning
- Any elevations or denials

### Security Metrics
Track patterns of:
- Permission denials by operation type
- Boundary violation attempts
- Elevation requests and approvals
- Critical file access patterns

### Anomaly Detection
Monitor for:
- Unusual permission patterns
- Repeated boundary violations
- Suspicious elevation requests
- Unexpected system file access attempts