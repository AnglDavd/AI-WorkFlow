## Objective
This node guides the user through the creation of a Product Requirement Prompt (PRP).

## Commands
```bash
# Log workflow start
./.ai_workflow/workflows/common/log_work_journal.md "INFO" "Starting Create PRP workflow."

WORKFLOW_DIR=".ai_workflow"
PRP_GENERATED_DIR="${WORKFLOW_DIR}/PRPs/generated"
PRP_TEMPLATES_DIR="${WORKFLOW_DIR}/PRPs/templates"

prp_template_path="${PRP_TEMPLATES_DIR}/prp_base.md"
if [ ! -f "$prp_template_path" ]; then
    echo "Error: PRP template not found at $prp_template_path. Aborting."
    ./.ai_workflow/workflows/common/error.md "PRP template not found at $prp_template_path."
    exit 1
fi

read -p "Enter a brief description of the feature for the PRP: " FEATURE_DESCRIPTION
if [ -z "$FEATURE_DESCRIPTION" ]; then
    echo "Error: Feature description cannot be empty. Aborting."
    ./.ai_workflow/workflows/common/error.md "Feature description cannot be empty."
    exit 1
fi

read -p "Enter the LLM CLI to use (e.g., claude, gemini) [default: claude]: " LLM_CLI
LLM_CLI=${LLM_CLI:-claude}

if ! command -v "$LLM_CLI" &> /dev/null; then
    echo "Error: '$LLM_CLI' command not found. Aborting."
    ./.ai_workflow/workflows/common/error.md "LLM CLI '$LLM_CLI' command not found."
    exit 1
fi

sanitized_desc=$(echo "$FEATURE_DESCRIPTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_ -]//g' | sed 's/ /-/g' | cut -c1-50)
output_file="${PRP_GENERATED_DIR}/${sanitized_desc}-prp.md"
mkdir -p "$(dirname "$output_file")"

template_content=$(cat "$prp_template_path")
full_prompt="Generate a Product Requirement Prompt (PRP) for the following feature: '$FEATURE_DESCRIPTION'.\n\nUse the following template structure and fill in all relevant sections based on the feature description. Be as detailed and comprehensive as possible.\n\n---\n$template_content"

echo "Generating PRP using $LLM_CLI..."
echo "Output will be saved to: $output_file"

if ! echo -e "$full_prompt" | "$LLM_CLI" > "$output_file"; then
    echo "Failed to generate PRP."
    ./.ai_workflow/workflows/common/error.md "PRP generation failed. Check LLM CLI output."
    exit 1
fi
```

## Verification Criteria
The command should exit with 0 and a new PRP file should be created in the `PRPs/generated` directory.

## Next Steps
- **On Success:** Proceed to [Workflow Completed](../../common/success.md).
- **On Failure:** Proceed to [Generic Error Handler](../../common/error.md).

