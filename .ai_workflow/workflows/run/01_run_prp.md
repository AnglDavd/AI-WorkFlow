## Objective
This node executes a given Product Requirement Prompt (PRP) file using a specified AI agent.

## Commands
```bash
# Log workflow start
./.ai_workflow/workflows/common/log_work_journal.md "INFO" "Starting Run PRP workflow."

# Default values
prp_path=""
llm_cli="claude"
interactive_mode=false

# This is a placeholder for argument parsing. In a real scenario, the agent
# would be responsible for getting these values from the user or a preceding node.
# For now, we will prompt for them interactively.

read -p "Enter the path to the PRP file: " prp_path
read -p "Enter the LLM CLI to use [default: claude]: " llm_cli_input
llm_cli=${llm_cli_input:-claude}
read -p "Run in interactive mode? (y/n) [default: n]: " interactive_input
if [[ "$interactive_input" == "y" ]]; then
    interactive_mode=true
fi

# --- Validation ---
if [ -z "$prp_path" ]; then
    echo "Error: PRP path cannot be empty."
    ./.ai_workflow/workflows/common/error.md "PRP path cannot be empty."
    exit 1
fi
if [ ! -f "$prp_path" ]; then
    echo "Error: PRP file not found at '$prp_path'."
    ./.ai_workflow/workflows/common/error.md "PRP file not found at '$prp_path'."
    exit 1
fi
if ! command -v "$llm_cli" &> /dev/null; then
    echo "Error: '$llm_cli' command not found."
    ./.ai_workflow/workflows/common/error.md "LLM CLI '$llm_cli' command not found."
    exit 1
fi

# --- Execution ---
WORKFLOW_DIR=".ai_workflow"
PRP_GENERATED_DIR="${WORKFLOW_DIR}/PRPs/generated"

meta_header="Ingest and understand the Product Requirement Prompt (PRP) below in detail. Your goal is to implement the requirements by writing and modifying code. Think hard, create a plan, and execute it step-by-step. Ask for clarification if anything is ambiguous. When you are finished, move the completed PRP to the '${PRP_GENERATED_DIR}/completed' folder."
prp_content=$(cat "$prp_path")
full_prompt="${meta_header}\n\n---\n\n${prp_content}"

echo "Executing PRP: $prp_path using $llm_cli..."

if [ "$interactive_mode" = true ]; then
    echo -e "$full_prompt" | "$llm_cli"
else
    echo -e "$full_prompt" | "$llm_cli"
fi

if [ $? -ne 0 ]; then
    echo "PRP execution failed."
    ./.ai_workflow/workflows/common/error.md "PRP execution failed. Check LLM CLI output."
    exit 1
fi
```

## Verification Criteria
The command should exit with 0 after the PRP execution is complete.

## Next Steps
- **On Success:** Proceed to [Workflow Completed](../../common/success.md).
- **On Failure:** Proceed to [Generic Error Handler](../../common/error.md).
