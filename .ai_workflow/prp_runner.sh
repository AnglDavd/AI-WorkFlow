#!/bin/bash

# Default values
AGENT="claude"
PRP_NAME=""
INTERACTIVE_MODE=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    key="$1"

    case $key in
        --agent)
        AGENT="$2"
        shift # past argument
        shift # past value
        ;;
        --prp)
        PRP_NAME="$2"
        shift # past argument
        shift # past value
        ;;
        --interactive)
        INTERACTIVE_MODE=true
        shift # past argument
        ;;
        *)
        # unknown option
        ;;
    esac
done

# Validate required arguments
if [ -z "$PRP_NAME" ]; then
    echo "Error: --prp argument is required." >&2
    exit 1
fi

# Construct file paths
PRP_FILE="PRPs/${PRP_NAME}.md"
COMMAND_FILE=".ai_workflow/commands/${AGENT}/execute-prp.md" # This is a placeholder, you might need a more dynamic way to select commands

# Fallback to common command if agent-specific one doesn't exist
if [ ! -f "$COMMAND_FILE" ]; then
    COMMAND_FILE=".ai_workflow/commands/_common/execute-prp.md"
fi

# Validate that the files exist
if [ ! -f "$PRP_FILE" ]; then
    echo "Error: PRP file not found at $PRP_FILE" >&2
    exit 1
fi

if [ ! -f "$COMMAND_FILE" ]; then
    echo "Error: Command file not found for agent $AGENT." >&2
    exit 1
fi

# Combine the prompt from the command file and the PRP content
# Note: This is a simple concatenation. A more sophisticated approach might be needed.
FINAL_PROMPT=$(cat "$COMMAND_FILE" "$PRP_FILE")

# Execute the agent
case $AGENT in
    claude)
        if [ "$INTERACTIVE_MODE" = true ]; then
            echo -e "$FINAL_PROMPT" | claude
        else
            claude -p "$FINAL_PROMPT"
        fi
        ;;
    openai)
        echo "OpenAI agent execution not yet implemented." >&2
        # Example: openai api completions.create -m gpt-4 -p "$FINAL_PROMPT"
        ;;
    gemini)
        echo "Gemini agent execution not yet implemented." >&2
        # Example: gcloud ai models predict ...
        ;;
    deepseek)
        echo "DeepSeek agent execution not yet implemented." >&2
        # Example: curl -X POST https://api.deepseek.com/v1/chat/completions ...
        ;;
    *)
        echo "Error: Unknown agent '$AGENT'" >&2
        exit 1
        ;;
esac
