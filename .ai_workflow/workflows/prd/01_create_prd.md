## Objective
This node guides the user through the creation of a Product Requirements Document (PRD).

## Commands
```bash
# Log workflow start
./.ai_workflow/workflows/common/log_work_journal.md "INFO" "Starting Create PRD workflow."

WORKFLOW_DIR=".ai_workflow"
PRP_GENERATED_DIR="${WORKFLOW_DIR}/PRPs/generated"

prd_template_path="${WORKFLOW_DIR}/create-prd.md"
if [ ! -f "$prd_template_path" ]; then
    echo "Error: PRD template not found at $prd_template_path. Aborting."
    ./.ai_workflow/workflows/common/error.md "PRD template not found at $prd_template_path."
    exit 1
fi

read -p "Enter a brief description for the product/feature: " PRD_DESCRIPTION
if [ -z "$PRD_DESCRIPTION" ]; then
    echo "Error: Description cannot be empty. Aborting."
    ./.ai_workflow/workflows/common/error.md "PRD description cannot be empty."
    exit 1
fi

read -p "Enter the LLM CLI to use (e.g., claude, gemini) [default: claude]: " LLM_CLI
LLM_CLI=${LLM_CLI:-claude}

if ! command -v "$LLM_CLI" &> /dev/null; then
    echo "Error: '$LLM_CLI' command not found. Aborting."
    ./.ai_workflow/workflows/common/error.md "LLM CLI '$LLM_CLI' command not found."
    exit 1
fi

sanitized_desc=$(echo "$PRD_DESCRIPTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_ -]//g' | sed 's/ /-/g' | cut -c1-50)
output_file="${PRP_GENERATED_DIR}/prd-${sanitized_desc}.md"
mkdir -p "$(dirname "$output_file")"

template_content=$(cat "$prd_template_path")
full_prompt="You are a Senior Technical Product Manager. Your task is to create a comprehensive Product Requirements Document (PRD).\n\n## User's Initial Request:\n'${PRD_DESCRIPTION}'\n\n## Your Instructions:\nFollow the process outlined in the template below. Start by asking clarifying questions to gather all necessary requirements before generating the final PRD. Use the template as your guide for structure and content.\n\n---\n${template_content}"

echo "Generating PRD using $LLM_CLI..."
echo "The agent will now ask you clarifying questions. Please answer them to generate a high-quality PRD."
echo "The final PRD will be saved to: $output_file"

# Start interactive session with the constructed prompt
echo -e "$full_prompt" | "$LLM_CLI" > "$output_file"

if [ $? -ne 0 ]; then
    echo "Error during PRD generation."
    ./.ai_workflow/workflows/common/error.md "PRD generation failed. Check LLM CLI output."
    exit 1
fi
```

## Verification Criteria
The command should exit with 0 and a new PRD file should be created in the `PRPs/generated` directory.

## Next Steps
- **On Success:** Proceed to [Workflow Completed](../../common/success.md).
- **On Failure:** Proceed to [Generic Error Handler](../../common/error.md).
