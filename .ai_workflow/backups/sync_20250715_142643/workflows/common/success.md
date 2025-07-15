## Objective
This node provides a standardized success message to the user when a workflow is completed.

## Commands
```bash
# Get success message from workflow arguments or use default
if [ -n "${WORKFLOW_ARGS:-}" ]; then
    SUCCESS_MESSAGE="$WORKFLOW_ARGS"
else
    SUCCESS_MESSAGE="${1:-Workflow completed successfully.}"
fi

echo "✅ $SUCCESS_MESSAGE"
log_workflow_event "INFO" "$SUCCESS_MESSAGE"
```

## Next Steps
- This is a terminal node. The process is finished.
