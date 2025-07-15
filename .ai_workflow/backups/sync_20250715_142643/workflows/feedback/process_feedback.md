## Objective
As an AI agent, your objective is to analyze the user's feedback and decide if a change to the workflow is needed. This is a cognitive, not a command-execution, step.

## Pre-conditions
The file `/.ai_workflow/temp_feedback.log` exists.

## Agent Instructions

1.  **Log Start:** Call `log_work_journal.md` with "INFO" and "Starting feedback processing."
2.  **Read the Feedback:** Ingest the contents of `/.ai_workflow/temp_feedback.log`. The content should conform to the "Feedback Summary Format" defined in `/.ai_workflow/docs/output_formats.md`.
3.  **Analyze for Actionable Insights:** Review the user's feedback. Is there a clear, actionable suggestion? 
    - *Example of actionable feedback:* "The node `run_tests.md` should be modified to use the command `npm run test:ci` instead of `npm test`."
    - *Example of non-actionable feedback:* "It felt a bit slow today."
4.  **Formulate a Hypothesis:** If the feedback is actionable, formulate a hypothesis for a change. 
    - *Hypothesis:* "The node `run_tests.md` should be modified to use the command `npm run test:ci`."
5.  **Update Knowledge Base:** If the change represents a new, persistent piece of information, add it to `_ai_knowledge.md`. 
    - *Knowledge Entry:* "Project tests must be run with the `:ci` flag to avoid interactive prompts."
6.  **Determine Next Step:** Based on your analysis, decide on the next action.

## Next Steps

- **If a change is required:**
    - **Action:** Prepare a plan to modify the relevant workflow node(s).
    - **Proceed to:** [Refactor Workflow](./refactor_workflow.md).

- **If no change is required:**
    - **Action:** Clean up the temporary feedback file.
    - **Command to execute:** `rm ./.ai_workflow/temp_feedback.log`
    - **Proceed to:** [Workflow Completed](../../common/success.md).

if [ $? -ne 0 ]; then
    ./.ai_workflow/workflows/common/error.md "Failed to process feedback."
    exit 1
fi
