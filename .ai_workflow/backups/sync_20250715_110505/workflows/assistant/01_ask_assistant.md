## Objective
This node allows the user to ask a question to the Framework Assistant.

## Commands
```bash
# Log workflow start
./.ai_workflow/workflows/common/log_work_journal.md "INFO" "Starting Assistant workflow."

# Default values
llm_cli="claude"

# In a real scenario, the agent would get the question from the user.
# For now, we will prompt for it interactively.

read -p "What is your question for the Framework Assistant?: " question
read -p "Enter the LLM CLI to use [default: claude]: " llm_cli_input
llm_cli=${llm_cli_input:-claude}

# --- Validation ---
if [ -z "$question" ]; then
    echo "Error: A question is required for the assistant."
    ./.ai_workflow/workflows/common/error.md "A question is required for the assistant."
    exit 1
fi

WORKFLOW_DIR=".ai_workflow"
assistant_prompt_path="${WORKFLOW_DIR}/FRAMEWORK_ASSISTANT.md"

if [ ! -f "$assistant_prompt_path" ]; then
    echo "Error: Assistant prompt file not found at '$assistant_prompt_path'."
    ./.ai_workflow/workflows/common/error.md "Assistant prompt file not found at '$assistant_prompt_path'."
    exit 1
fi
if ! command -v "$llm_cli" &> /dev/null; then
    echo "Error: '$llm_cli' command not found."
    ./.ai_workflow/workflows/common/error.md "LLM CLI '$llm_cli' command not found."
    exit 1
fi

# --- Execution ---
assistant_prompt_content=$(cat "$assistant_prompt_path")
full_prompt="${assistant_prompt_content}\n\n## User Query:\n${question}"

echo "Querying assistant using $llm_cli..."

echo -e "$full_prompt" | "$llm_cli"

if [ $? -ne 0 ]; then
    echo "Assistant query failed."
    ./.ai_workflow/workflows/common/error.md "Assistant query failed. Check LLM CLI output."
    exit 1
fi
```


## Verification Criteria
The command should exit with 0 after the assistant query is complete.

## Next Steps
- **On Success:** Proceed to [Workflow Completed](../../common/success.md).
- **On Failure:** Proceed to [Generic Error Handler](../../common/error.md).

