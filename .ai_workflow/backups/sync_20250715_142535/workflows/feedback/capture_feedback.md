## Objective
This node captures feedback from the user about a completed workflow.

## Commands
```bash
# Log workflow start
./.ai_workflow/workflows/common/log_work_journal.md "INFO" "Starting Capture Feedback workflow."

echo "Workflow finished. To help improve the system, please provide your feedback."
read -p "1. Was the workflow efficient? (y/n/partial): " EFFICIENT
read -p "2. Were there any redundant or unnecessary steps? (if yes, please describe): " REDUNDANT
read -p "3. Were there any errors or steps that were difficult to understand?: " ERRORS
read -p "4. Any other suggestions for improvement?: " SUGGESTIONS

# Save feedback to a temporary file for processing
FEEDBACK_FILE=".ai_workflow/temp_feedback.log"
echo "EFFICIENCY: $EFFICIENT" > "$FEEDBACK_FILE"
echo "REDUNDANCY: $REDUNDANT" >> "$FEEDBACK_FILE"
echo "ERRORS: $ERRORS" >> "$FEEDBACK_FILE"
echo "SUGGESTIONS: $SUGGESTIONS" >> "$FEEDBACK_FILE"

echo "Thank you for your feedback!"

if [ $? -ne 0 ]; then
    ./.ai_workflow/workflows/common/error.md "Failed to capture feedback."
    exit 1
fi
```

## Verification Criteria
A `temp_feedback.log` file should be created containing the user's answers.

## Next Steps
- **On Success:** Proceed to [Process Feedback](./process_feedback.md).
- **On Failure:** Proceed to [Generic Error Handler](../../common/error.md).
