# Execute Abstract Tool Call

## Overview
This workflow is the central engine that processes abstract tool calls and executes them via specific tool adapters. It provides a unified interface for all abstract tools while maintaining transparency and auditability.

## Workflow Instructions

### For AI Agents
When you need to execute an abstract tool call, follow these steps:

1. **Parse the abstract call** to extract tool name, action, and parameters
2. **Validate the tool call** using the validation workflow
3. **Route to appropriate adapter** based on tool type
4. **Execute the generated command** and capture results
5. **Handle errors** and provide feedback

### Input Format
Abstract tool calls follow this pattern:
```
TOOL_NAME.ACTION(parameter1=value1, parameter2=value2)
```

Examples:
- `git.add(file_path="src/main.js")`
- `npm.install(package="express", dev=false)`
- `file.write(path="config.json", content="...")`

### Execution Steps

#### Step 1: Parse Abstract Call
```bash
# Extract tool name, action, and parameters from the abstract call
TOOL_NAME=$(echo "$ABSTRACT_CALL" | cut -d'.' -f1)
ACTION=$(echo "$ABSTRACT_CALL" | cut -d'.' -f2 | cut -d'(' -f1)
PARAMS=$(echo "$ABSTRACT_CALL" | sed 's/.*(\(.*\)).*/\1/')

echo "Tool: $TOOL_NAME"
echo "Action: $ACTION"
echo "Parameters: $PARAMS"
```

#### Step 2: Validate Tool Call
```bash
# Use validation workflow to check if tool call is valid
call_workflow "tools/validate_tool_call.md"

# Pass parameters to validation
if ! validate_tool_call "$TOOL_NAME" "$ACTION" "$PARAMS"; then
    echo "ERROR: Invalid tool call - $ABSTRACT_CALL"
    exit 1
fi
```

#### Step 3: Route to Adapter
```bash
# Route to appropriate adapter based on tool name
case "$TOOL_NAME" in
    "git")
        ADAPTER_FILE=".ai_workflow/tools/adapters/git_adapter.md"
        ;;
    "npm")
        ADAPTER_FILE=".ai_workflow/tools/adapters/npm_adapter.md"
        ;;
    "file")
        ADAPTER_FILE=".ai_workflow/tools/adapters/file_adapter.md"
        ;;
    "http")
        ADAPTER_FILE=".ai_workflow/tools/adapters/http_adapter.md"
        ;;
    *)
        echo "ERROR: Unknown tool - $TOOL_NAME"
        echo "Available tools: git, npm, file, http"
        exit 1
        ;;
esac

# Check if adapter exists
if [ ! -f "$ADAPTER_FILE" ]; then
    echo "ERROR: Adapter not found - $ADAPTER_FILE"
    echo "Please create the adapter or check tool name"
    exit 1
fi
```

#### Step 4: Execute via Adapter
```bash
# Source the adapter and execute
source "$ADAPTER_FILE"

# Call the adapter's execute function
COMMAND=$(execute_adapter "$ACTION" "$PARAMS")

if [ $? -ne 0 ]; then
    echo "ERROR: Adapter failed to generate command"
    exit 1
fi

echo "Generated command: $COMMAND"
```

#### Step 5: Execute Command
```bash
# Execute the generated command
echo "Executing: $COMMAND"
eval "$COMMAND"
RESULT=$?

if [ $RESULT -eq 0 ]; then
    echo "SUCCESS: Command executed successfully"
else
    echo "ERROR: Command failed with exit code $RESULT"
    exit $RESULT
fi
```

### Error Handling

#### Common Error Patterns
- **Invalid tool call syntax**: Malformed abstract call
- **Unknown tool**: Tool not supported by framework
- **Missing adapter**: Adapter file not found
- **Command generation failure**: Adapter unable to generate command
- **Execution failure**: Generated command failed

#### Error Recovery
```bash
# Log error for debugging
echo "$(date): ERROR executing $ABSTRACT_CALL" >> .ai_workflow/logs/tool_errors.log

# Attempt basic recovery based on error type
case "$ERROR_TYPE" in
    "missing_adapter")
        echo "Suggestion: Create adapter at $ADAPTER_FILE"
        echo "Use existing adapters as templates"
        ;;
    "invalid_syntax")
        echo "Suggestion: Check abstract call syntax"
        echo "Format: TOOL.ACTION(param1=value1, param2=value2)"
        ;;
    "command_failed")
        echo "Suggestion: Check command parameters and system state"
        echo "Original command: $COMMAND"
        ;;
esac
```

### Integration with Other Workflows

#### Called by:
- `01_run_prp.md` - Main PRP execution
- `process-task-list.md` - Task processing
- Any workflow needing tool execution

#### Calls:
- `validate_tool_call.md` - Tool call validation
- Tool adapters (git_adapter.md, npm_adapter.md, etc.)
- Common error handling workflows

### Usage Examples

#### Example 1: Git Operations
```bash
# Stage a file
ABSTRACT_CALL="git.add(file_path='src/main.js')"
execute_abstract_tool_call "$ABSTRACT_CALL"

# Commit changes
ABSTRACT_CALL="git.commit(message='Add new feature')"
execute_abstract_tool_call "$ABSTRACT_CALL"
```

#### Example 2: NPM Operations
```bash
# Install dependencies
ABSTRACT_CALL="npm.install()"
execute_abstract_tool_call "$ABSTRACT_CALL"

# Run tests
ABSTRACT_CALL="npm.test()"
execute_abstract_tool_call "$ABSTRACT_CALL"
```

#### Example 3: File Operations
```bash
# Write file
ABSTRACT_CALL="file.write(path='config.json', content='{\"debug\": true}')"
execute_abstract_tool_call "$ABSTRACT_CALL"
```

### Logging and Monitoring

#### Execution Log
```bash
# Log successful executions
echo "$(date): SUCCESS - $ABSTRACT_CALL -> $COMMAND" >> .ai_workflow/logs/tool_executions.log
```

#### Performance Tracking
```bash
# Track execution time
START_TIME=$(date +%s)
# ... execute command ...
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
echo "$(date): PERFORMANCE - $ABSTRACT_CALL took ${DURATION}s" >> .ai_workflow/logs/tool_performance.log
```

### Security Considerations

#### Input Sanitization
- Validate all parameters before execution
- Escape special characters in command generation
- Prevent command injection attacks

#### Permission Checking
- Verify write permissions before file operations
- Check system state before destructive operations
- Validate paths are within project boundaries

### Future Enhancements

#### Planned Features
- **Caching**: Cache command results for repeated calls
- **Parallel Execution**: Execute multiple tool calls concurrently
- **Rollback**: Ability to undo tool operations
- **Metrics**: Detailed performance and usage metrics

#### Extensibility
- **New Tool Support**: Easy addition of new tool adapters
- **Plugin System**: External tool integration
- **Configuration**: Tool-specific configuration options

## Notes
- This workflow replaces any previous tool interpretation logic
- All tool execution goes through this central pipeline
- Maintains compatibility with existing PRP workflows
- Provides foundation for advanced tool features