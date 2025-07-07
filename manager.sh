#!/bin/bash

# ==============================================================================
#
# Project Manager - AI-Assisted Development Framework
#
# A unified script to manage project setup, PRD/PRP creation, and execution.
#
# ==============================================================================

# --- Configuration ---
# Directory where AI workflow templates and generated files are stored.
# Users can override this if they rename the directory.
WORKFLOW_DIR=".ai_workflow"
PRP_GENERATED_DIR="${WORKFLOW_DIR}/PRPs/generated"
PRP_TEMPLATES_DIR="${WORKFLOW_DIR}/PRPs/templates"

# --- Helper Functions ---

# Function to print messages in color for better readability.
# Usage: print_color "green" "This is a success message."
print_color() {
    local color_name=$1
    local text=$2
    case $color_name in
        "green") echo -e "[0;32m${text}[0m" ;;
        "blue")  echo -e "[0;34m${text}[0m" ;;
        "red")   echo -e "[0;31m${text}[0m" ;;
        "yellow") echo -e "[1;33m${text}[0m" ;;
        *)       echo "$text" ;;
    esac
}

# Displays the main help message and usage instructions.
show_help() {
    print_color "green" "Project Manager - AI-Assisted Development Framework"
    print_color "yellow" "Usage: ./manager.sh <command> [options]"
    echo ""
    print_color "blue" "Available Commands:"
    echo "  setup         - Interactively sets up a new project from the framework."
    echo "  new-prd       - Guides you to create a new Product Requirements Document (PRD)."
    echo "  new-prp       - Creates a new Product Requirement Prompt (PRP) from a description."
    echo "  run           - Executes a PRP using a specified AI agent."
    echo "  assistant     - Interacts with the Framework Assistant to get guidance."
    echo "  help          - Shows this help message."
    echo ""
    print_color "blue" "For command-specific help, run: ./manager.sh <command> --help"
}

# --- Command Functions ---

# 1. SETUP COMMAND
# Replaces 01_setup.sh
run_setup() {
    if [[ "$1" == "--help" ]]; then
        print_color "yellow" "Usage: ./manager.sh setup"
        echo "This command walks you through setting up a new project based on this framework."
        echo "It will ask for a project name, create a new directory, move the framework files,"
        echo "initialize a new Git repository, and then self-destruct the original folder."
        return
    fi

    print_color "blue" "========================================================="
    print_color "blue" "      AI-Assisted Development Framework Setup"
    print_color "blue" "========================================================="

    read -p "Enter your new project name (e.g., my-awesome-app): " PROJECT_NAME
    if [ -z "$PROJECT_NAME" ]; then
        print_color "red" "Project name cannot be empty. Aborting."
        exit 1
    fi

    print_color "green" "
Configuration Summary:"
    print_color "green" "- New Project Directory: ../$PROJECT_NAME"

    read -p "Proceed with this configuration? (y/n): " CONFIRMATION
    if [[ "$CONFIRMATION" != "y" ]]; then
        print_color "red" "Setup aborted by user."
        exit 1
    fi

    print_color "blue" "
Creating project structure..."

    # To avoid path issues, we operate from one level up
    local current_dir_name=${PWD##*/}
    cd ..

    if mkdir "$PROJECT_NAME"; then
        # Move all framework files into the new project directory
        # Using git to track all files, even hidden ones, is more reliable
        cd "$current_dir_name"
        git ls-files -c -o --exclude-standard | xargs -I {} mv {} "../$PROJECT_NAME/"
        mv .git* "../$PROJECT_NAME/" # Move git related files
        cd ".."
        rm -rf "$current_dir_name" # Remove the old directory
    else
        print_color "red" "Failed to create directory '$PROJECT_NAME'. It might already already exist."
        exit 1
    fi

    cd "$PROJECT_NAME"

    print_color "blue" "Initializing new Git repository..."
    rm -rf .git
    git init > /dev/null 2>&1
    git add . > /dev/null 2>&1
    git commit -m "Initial commit: Set up AI development framework" > /dev/null 2>&1

    print_color "green" "
========================================================="
    print_color "green" " Setup Complete! Your new project is ready."
    print_color "green" " You are now in the project directory: $PWD"
    print_color "green" " Start by following the instructions in README.md"
    print_color "green" "========================================================="
}

# 2. NEW-PRD COMMAND
# New functionality
run_new_prd() {
    if [[ "$1" == "--help" ]]; then
        print_color "yellow" "Usage: ./manager.sh new-prd"
        echo "This command helps you generate a Product Requirements Document (PRD)."
        echo "It uses the 'create-prd.md' template and your chosen AI agent to create a"
        echo "structured PRD file in '${PRP_GENERATED_DIR}'."
        return
    fi

    print_color "blue" "========================================================="
    print_color "blue" "      Product Requirements Document (PRD) Creator"
    print_color "blue" "========================================================="
    
    local prd_template_path="${WORKFLOW_DIR}/create-prd.md"
    if [ ! -f "$prd_template_path" ]; then
        print_color "red" "PRD template not found at $prd_template_path. Aborting."
        exit 1
    fi

    read -p "Enter a brief description for the product/feature: " PRD_DESCRIPTION
    if [ -z "$PRD_DESCRIPTION" ]; then
        print_color "red" "Description cannot be empty. Aborting."
        exit 1
    fi

    read -p "Enter the LLM CLI to use (e.g., claude, gemini) [default: claude]: " LLM_CLI
    LLM_CLI=${LLM_CLI:-claude}

    if ! command -v "$LLM_CLI" &> /dev/null; then
        print_color "red" "Error: '$LLM_CLI' command not found. Aborting."
        exit 1
    fi

    local sanitized_desc=$(echo "$PRD_DESCRIPTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_ -]//g' | sed 's/ /-/g' | cut -c1-50)
    local output_file="${PRP_GENERATED_DIR}/prd-${sanitized_desc}.md"
    mkdir -p "$(dirname "$output_file")"

    local template_content=$(cat "$prd_template_path")
    local full_prompt="You are a Senior Technical Product Manager. Your task is to create a comprehensive Product Requirements Document (PRD).

## User's Initial Request:
'${PRD_DESCRIPTION}'

## Your Instructions:
Follow the process outlined in the template below. Start by asking clarifying questions to gather all necessary requirements before generating the final PRD. Use the template as your guide for structure and content.

---
${template_content}"

    print_color "blue" "
Generating PRD using $LLM_CLI..."
    print_color "blue" "The agent will now ask you clarifying questions. Please answer them to generate a high-quality PRD."
    print_color "blue" "The final PRD will be saved to: $output_file"

    # Start interactive session with the constructed prompt
    echo -e "$full_prompt" | "$LLM_CLI" > "$output_file"

    if [ $? -eq 0 ]; then
        print_color "green" "
PRD generation process finished."
        print_color "green" "Please review the generated file: $output_file"
    else
        print_color "red" "
An error occurred during PRD generation."
    fi
}


# 3. NEW-PRP COMMAND
# Replaces 02_create_prp.sh
run_new_prp() {
    if [[ "$1" == "--help" ]]; then
        print_color "yellow" "Usage: ./manager.sh new-prp"
        echo "This command generates a Product Requirement Prompt (PRP) from a feature description."
        echo "It uses a base template and your chosen AI agent to create a detailed PRP file"
        echo "in '${PRP_GENERATED_DIR}'."
        return
    fi

    print_color "blue" "========================================================="
    print_color "blue" "      Product Requirement Prompt (PRP) Creator"
    print_color "blue" "========================================================="

    local prp_template_path="${PRP_TEMPLATES_DIR}/prp_base.md"
    if [ ! -f "$prp_template_path" ]; then
        print_color "red" "PRP template not found at $prp_template_path. Aborting."
        exit 1
    fi

    read -p "Enter a brief description of the feature for the PRP: " FEATURE_DESCRIPTION
    if [ -z "$FEATURE_DESCRIPTION" ]; then
        print_color "red" "Feature description cannot be empty. Aborting."
        exit 1
    fi

    read -p "Enter the LLM CLI to use (e.g., claude, gemini) [default: claude]: " LLM_CLI
    LLM_CLI=${LLM_CLI:-claude}

    if ! command -v "$LLM_CLI" &> /dev/null; then
        print_color "red" "Error: '$LLM_CLI' command not found. Aborting."
        exit 1
    fi

    local sanitized_desc=$(echo "$FEATURE_DESCRIPTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_ -]//g' | sed 's/ /-/g' | cut -c1-50)
    local output_file="${PRP_GENERATED_DIR}/${sanitized_desc}-prp.md"
    mkdir -p "$(dirname "$output_file")"

    local template_content=$(cat "$prp_template_path")
    local full_prompt="Generate a Product Requirement Prompt (PRP) for the following feature: '$FEATURE_DESCRIPTION'.

Use the following template structure and fill in all relevant sections based on the feature description. Be as detailed and comprehensive as possible.

---
$PRP_TEMPLATE_CONTENT"

    print_color "blue" "
Generating PRP using $LLM_CLI..."
    print_color "blue" "Output will be saved to: $output_file"

    if "$LLM_CLI" -p "$full_prompt" > "$output_file"; then
        print_color "green" "
PRP generated successfully!"
        print_color "green" "You can find your new PRP at: $output_file"
    else
        print_color "red" "
Failed to generate PRP. Check the output above for errors."
    fi
}

# 4. RUN COMMAND
# Replaces 03_run_prp.sh
run_prp() {
    local prp_path=""
    local llm_cli="claude"
    local interactive_mode=false

    # Parse arguments for this specific command
    shift # remove 'run'
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --prp) prp_path="$2"; shift 2;;
            --model) llm_cli="$2"; shift 2;;
            --interactive) interactive_mode=true; shift;;
            --help)
                print_color "yellow" "Usage: ./manager.sh run --prp <path_to_prp_file> [--model <llm_cli>] [--interactive]"
                echo "Executes a PRP using the specified AI agent."
                echo ""
                print_color "blue" "Options:"
                echo "  --prp <path>     - (Required) The path to the PRP file to execute."
                echo "  --model <cli>    - The LLM CLI to use (e.g., claude, gemini). Default: claude."
                echo "  --interactive    - Runs the agent in interactive mode."
                return
                ;;
            *) print_color "red" "Unknown option: $1"; exit 1;;
        esac
    done

    if [ -z "$prp_path" ]; then
        print_color "red" "Error: --prp <path_to_prp_file> is a required argument."
        exit 1
    fi
    if [ ! -f "$prp_path" ]; then
        print_color "red" "Error: PRP file not found at '$prp_path'."
        exit 1
    fi
    if ! command -v "$llm_cli" &> /dev/null; then
        print_color "red" "Error: '$llm_cli' command not found."
        exit 1
    fi

    local meta_header="Ingest and understand the Product Requirement Prompt (PRP) below in detail. Your goal is to implement the requirements by writing and modifying code. Think hard, create a plan, and execute it step-by-step. Ask for clarification if anything is ambiguous. When you are finished, move the completed PRP to the '${PRP_GENERATED_DIR}/completed' folder."
    local prp_content=$(cat "$prp_path")
    local full_prompt="${meta_header}

---

${prp_content}"
    local allowed_tools="Edit,Bash,Write,MultiEdit,NotebookEdit,WebFetch,Agent,LS,Grep,Read,NotebookRead,TodoRead,TodoWrite,WebSearch"

    print_color "blue" "========================================================="
    print_color "blue" "           PRP Execution Engine"
    print_color "blue" "========================================================="
    print_color "blue" "Executing PRP: $prp_path using $llm_cli..."

    if [ "$interactive_mode" = true ]; then
        echo -e "$full_prompt" | "$llm_cli" --allowedTools "$allowed_tools"
    else
        "$llm_cli" -p "$full_prompt" --allowedTools "$allowed_tools"
    fi

    if [ $? -eq 0 ]; then
        print_color "green" "
PRP execution completed."
    else
        print_color "red" "
PRP execution failed."
    fi
}

# 5. ASSISTANT COMMAND
run_assistant() {
    if [[ "$1" == "--help" ]]; then
        print_color "yellow" "Usage: ./manager.sh assistant <your_question> [--model <llm_cli>]"
        echo "Interacts with the Framework Assistant to get guidance, status updates, or command suggestions."
        echo ""
        print_color "blue" "Options:"
        echo "  <your_question>  - (Required) The question or query for the assistant."
        echo "  --model <cli>    - The LLM CLI to use (e.g., claude, gemini). Default: claude."
        return
    fi

    local question=""
    local llm_cli="claude"
    local assistant_prompt_path="${WORKFLOW_DIR}/FRAMEWORK_ASSISTANT.md"

    # Parse arguments for this specific command
    local args_array=()
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --model) llm_cli="$2"; shift 2;;
            *)
                args_array+=("$1")
                shift
                ;;
        esac
    done
    question=$(printf "%s " "${args_array[@]}")

    if [ -z "$question" ]; then
        print_color "red" "Error: A question is required for the assistant."
        exit 1
    fi
    if [ ! -f "$assistant_prompt_path" ]; then
        print_color "red" "Error: Assistant prompt file not found at '$assistant_prompt_path'."
        exit 1
    fi
    if ! command -v "$llm_cli" &> /dev/null; then
        print_color "red" "Error: '$llm_cli' command not found."
        exit 1
    fi

    local assistant_prompt_content=$(cat "$assistant_prompt_path")
    local full_prompt="${assistant_prompt_content}

## User Query:
${question}"

    print_color "blue" "========================================================="
    print_color "blue" "           Framework Assistant"
    print_color "blue" "========================================================="
    print_color "blue" "Querying assistant using $llm_cli..."

    echo -e "$full_prompt" | "$llm_cli" --allowedTools "Edit,Bash,Write,MultiEdit,NotebookEdit,WebFetch,Agent,LS,Grep,Read,NotebookRead,TodoRead,TodoWrite,WebSearch"

    if [ $? -eq 0 ]; then
        print_color "green" "
Assistant query completed."
    else
        print_color "red" "
Assistant query failed."
    fi
}


# --- Main Script Logic ---

# Check if a command was provided
if [ -z "$1" ]; then
    show_help
    exit 1
fi

# Command routing
case "$1" in
    setup)
        run_setup "$2"
        ;;
    new-prd)
        run_new_prd "$2"
        ;;
    new-prp)
        run_new_prp "$2"
        ;;
    run)
        run_prp "$@"
        ;;
    assistant)
        run_assistant "$@"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_color "red" "Unknown command: $1"
        show_help
        exit 1
        ;;
esac