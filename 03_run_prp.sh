#!/bin/bash

# --- Script to Run an AI coding agent against a PRP ---

# Function to print in color
print_color() {
    COLOR=$1
    TEXT=$2
    case $COLOR in
        "green") echo -e "\033[0;32m${TEXT}\033[0m" ;;
        "blue")  echo -e "\033[0;34m${TEXT}\033[0m" ;;
        "red")   echo -e "\033[0;31m${TEXT}\033[0m" ;;
    esac
}

# Default values
PRP_PATH=""
PRP_NAME=""
LLM_CLI="claude"
INTERACTIVE_MODE=false
OUTPUT_FORMAT="text"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    key="$1"

    case $key in
        --prp-path)
        PRP_PATH="$2"
        shift # past argument
        shift # past value
        ;;
        --prp)
        PRP_NAME="$2"
        shift # past argument
        shift # past value
        ;;
        --model)
        LLM_CLI="$2"
        shift # past argument
        shift # past value
        ;;
        --interactive)
        INTERACTIVE_MODE=true
        shift # past argument
        ;;
        --output-format)
        OUTPUT_FORMAT="$2"
        shift # past argument
        shift # past value
        ;;
        *)
        # unknown option
        ;;
    esac
done

# Validate required arguments
if [ -z "$PRP_PATH" ] && [ -z "$PRP_NAME" ]; then
    print_color "red" "Error: Must supply --prp or --prp-path." >&2
    exit 1
fi

# Determine PRP file path
if [ -n "$PRP_PATH" ]; then
    PRP_FILE="$PRP_PATH"
elif [ -n "$PRP_NAME" ]; then
    PRP_FILE=".ai_workflow/PRPs/${PRP_NAME}.md"
fi

# Check if PRP file exists
if [ ! -f "$PRP_FILE" ]; then
    print_color "red" "Error: PRP file not found at $PRP_FILE" >&2
    exit 1
fi

# Check if the chosen LLM CLI is available
if ! command -v "$LLM_CLI" &> /dev/null; then
    print_color "red" "Error: '$LLM_CLI' command not found. Please ensure it's installed and in your PATH." >&2
    exit 1
fi

# Meta header for the LLM
META_HEADER="Ingest and understand the Product Requirement Prompt (PRP) below in detail.\n\n    # WORKFLOW GUIDANCE:\n\n    ## Planning Phase\n    - Think hard before you code. Create a comprehensive plan addressing all requirements.\n    - Break down complex tasks into smaller, manageable steps.\n    - Use the TodoWrite tool to create and track your implementation plan.\n    - Identify implementation patterns from existing code to follow.\n\n    ## Implementation Phase\n    - Follow code conventions and patterns found in existing files.\n    - Implement one component at a time and verify it works correctly.\n    - Write clear, maintainable code with appropriate comments.\n    - Consider error handling, edge cases, and potential security issues.\n    - Use type hints to ensure type safety.\n\n    ## Testing Phase\n    - Test each component thoroughly as you build it.\n    - Use the provided validation gates to verify your implementation.\n    - Verify that all requirements have been satisfied.\n    - Run the project tests when finished and output \"DONE\" when they pass.\n\n    ## Example Implementation Approach:\n    1. Analyze the PRP requirements in detail\n    2. Search for and understand existing patterns in the codebase\n    3. Search the Web and gather additional context and examples\n    4. Create a step-by-step implementation plan with TodoWrite\n    5. Implement core functionality first, then additional features\n    6. Test and validate each component\n    7. Ensure all validation gates pass\n\n    ***When you are finished, move the completed PRP to the PRPs/completed folder***\n    "

# Read PRP content
PRP_CONTENT=$(cat "$PRP_FILE")

# Combine meta header and PRP content
FULL_PROMPT="${META_HEADER}${PRP_CONTENT}"

# Allowed tools for the LLM
ALLOWED_TOOLS="Edit,Bash,Write,MultiEdit,NotebookEdit,WebFetch,Agent,LS,Grep,Read,NotebookRead,TodoRead,TodoWrite,WebSearch"

print_color "blue" "========================================================="
print_color "blue" "           PRP Execution Script                        "
print_color "blue" "========================================================="
print_color "blue" "Executing PRP: $PRP_FILE using $LLM_CLI..."

# Execute the LLM CLI command
if [ "$INTERACTIVE_MODE" = true ]; then
    # Interactive mode: feed prompt via STDIN
    echo -e "$FULL_PROMPT" | "$LLM_CLI" --allowedTools "$ALLOWED_TOOLS"
else
    # Headless mode: pass prompt via -p
    "$LLM_CLI" -p "$FULL_PROMPT" --allowedTools "$ALLOWED_TOOLS" --output-format "$OUTPUT_FORMAT"
fi

if [ "$?" -eq 0 ]; then
    print_color "green" "\nPRP execution completed successfully!"
else
    print_color "red" "\nPRP execution failed. Check the output above for errors."
fi

print_color "blue" "========================================================="
print_color "blue" "           PRP Execution Script Finished               "
print_color "blue" "========================================================="
