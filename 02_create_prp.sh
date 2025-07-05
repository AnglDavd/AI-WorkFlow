#!/bin/bash

# --- Script to Create Product Requirement Prompts (PRPs) ---

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

print_color "blue" "========================================================="
print_color "blue" "           PRP Creation Script                         "
print_color "blue" "========================================================="

# Ensure PRPs/generated directory exists
mkdir -p prp_framework_assets/PRPs/generated

# 1. Get the feature description from the user
read -p "Enter a brief description of the feature for the PRP: " FEATURE_DESCRIPTION

if [ -z "$FEATURE_DESCRIPTION" ]; then
    print_color "red" "Feature description cannot be empty. Aborting."
    exit 1
fi

# 2. Define the path to the base PRP template
PRP_TEMPLATE_PATH="prp_framework_assets/PRPs/templates/prp_base.md"

if [ ! -f "$PRP_TEMPLATE_PATH" ]; then
    print_color "red" "PRP template not found at $PRP_TEMPLATE_PATH. Aborting."
    exit 1
fi

# Read the content of the base PRP template
PRP_TEMPLATE_CONTENT=$(cat "$PRP_TEMPLATE_PATH")

# 3. Construct the full prompt for the LLM
FULL_PROMPT="Generate a Product Requirement Prompt (PRP) for the following feature: '$FEATURE_DESCRIPTION'.\n\nUse the following template structure and fill in all relevant sections based on the feature description. Be as detailed and comprehensive as possible.\n\n---\n$PRP_TEMPLATE_CONTENT"

# 4. Choose LLM CLI
print_color "blue" "\nChoose which LLM CLI to use (e.g., claude, gemini, openai):"
read -p "Enter LLM CLI name: " LLM_CLI

if [ -z "$LLM_CLI" ]; then
    print_color "red" "LLM CLI name cannot be empty. Aborting."
    exit 1
}

# Check if the chosen LLM CLI is available
if ! command -v "$LLM_CLI" &> /dev/null; then
    print_color "red" "Error: '$LLM_CLI' command not found. Please ensure it's installed and in your PATH. Aborting."
    exit 1
fi

# 5. Define the output file name
# Sanitize feature description for filename
SANITIZED_FEATURE_DESCRIPTION=$(echo "$FEATURE_DESCRIPTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_ -]//g' | sed 's/ /-/g' | cut -c1-50)
OUTPUT_FILE=".ai_workflow/PRPs/generated/${SANITIZED_FEATURE_DESCRIPTION}-prp.md"

print_color "blue" "\nGenerating PRP using $LLM_CLI..."
print_color "blue" "Output will be saved to: $OUTPUT_FILE"

# 6. Execute the LLM CLI command and redirect output
# Using -p for non-interactive mode and redirecting stdout
if "$LLM_CLI" -p "$FULL_PROMPT" > "$OUTPUT_FILE"; then
    print_color "green" "\nPRP generated successfully!"
    print_color "green" "You can find your new PRP at: $OUTPUT_FILE"
else
    print_color "red" "\nFailed to generate PRP. Check the output above for errors."
    print_color "red" "Please ensure your LLM CLI is correctly configured and authenticated."
fi

print_color "blue" "========================================================="
print_color "blue" "           PRP Creation Script Finished                "
print_color "blue" "========================================================="
