## Objective
This node handles graceful exits when a user chooses to abort a workflow.

## Commands
```bash
echo "🟡 Workflow aborted by user."
# Clean up the temporary state file if it exists
if [ -f "./.ai_workflow/temp_state.vars" ]; then
    rm ./.ai_workflow/temp_state.vars
fi
```

## Next Steps
- This is a terminal node. The process is finished.
