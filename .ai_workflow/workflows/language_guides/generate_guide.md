## Objective
This node generates a draft language guide for a specified language/framework, using a skeleton and the LLM's web search capabilities.

## Commands
```bash
read -p "Enter the name of the language/framework for the new guide (e.g., PHP, Go, Ruby): " LANGUAGE_NAME
if [ -z "$LANGUAGE_NAME" ]; then
    echo "Error: Language name cannot be empty. Aborting."
    exit 1
fi

read -p "Enter the LLM CLI to use (e.g., claude, gemini) [default: gemini]: " LLM_CLI
LLM_CLI=${LLM_CLI:-gemini}

if ! command -v "$LLM_CLI" &> /dev/null; then
    echo "Error: '$LLM_CLI' command not found. Aborting."
    exit 1
fi

SKELETON_PATH=".ai_workflow/language_guide_skeleton.md"
if [ ! -f "$SKELETON_PATH" ]; then
    echo "Error: Language guide skeleton not found at '$SKELETON_PATH'. Aborting."
    exit 1
fi

OUTPUT_FILE=".ai_workflow/agent_guide_examples/${LANGUAGE_NAME}.md"

# Read the skeleton content
SKELETON_CONTENT=$(cat "$SKELETON_PATH")

# Construct the prompt for the LLM
FULL_PROMPT="You are an expert in software development and technical documentation. Your task is to generate a comprehensive agent guide for the '${LANGUAGE_NAME}' language/framework. Use the provided skeleton as a template and fill in all sections with detailed, accurate, and up-to-date information. Focus on best practices, common patterns, and critical guidelines relevant to an AI assistant working with this technology.\n\nLeverage your web search capabilities to gather the necessary information. Ensure the guide is model-agnostic and concise, optimizing for token usage.\n\n---\n${SKELETON_CONTENT}"

echo "Generating guide for ${LANGUAGE_NAME} using $LLM_CLI..."
echo "Output will be saved to: $OUTPUT_FILE"

# Execute the LLM to generate the guide
# Note: This assumes the LLM CLI can take a prompt and output to a file.
# The --web flag is conceptual for LLMs that can perform web searches.
if ! echo -e "$FULL_PROMPT" | "$LLM_CLI" --web > "$OUTPUT_FILE"; then
    echo "Failed to generate language guide."
    exit 1
fi

echo "Draft guide for ${LANGUAGE_NAME} generated successfully at $OUTPUT_FILE."
```

## Verification Criteria
The command should exit with 0, and a new `.md` file for the specified language should be created in `agent_guide_examples/`.

## Next Steps
- **On Success:** Proceed to [Workflow Completed](../../common/success.md). Review the generated guide for accuracy and completeness. Consider contributing it back to the framework.
- **On Failure:** Proceed to [Generic Error Handler](../../common/error.md).
