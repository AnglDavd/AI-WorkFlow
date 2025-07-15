---
description: A reusable workflow to check if a command-line tool is installed and available.
---
# Rule: Check for Command-Line Dependency

## Goal
To verify if a specific command-line tool (e.g., `playwright`, `mcp`, `git`) is available in the system's PATH. If it is not found, inform the user with a helpful message.

## Input Parameters
1.  `COMMAND_NAME`: The name of the command to check (e.g., "playwright").
2.  `INSTALL_GUIDE_URL`: (Optional) A URL to the installation guide for the tool.

## Process
```bash
# Check if the command exists using the 'command -v' which is a reliable, built-in way.
if ! command -v "$COMMAND_NAME" &> /dev/null
then
    # If the command is not found, print an error message and exit.
    echo "--------------------------------------------------"
    echo "ERROR: Dependency Not Found"
    echo ""
    echo "The required command-line tool '$COMMAND_NAME' could not be found in your system's PATH."
    echo "This tool is necessary for the workflow to continue."
    
    if [ -n "$INSTALL_GUIDE_URL" ]; then
        echo "Please install it by following the instructions at:"
        echo "$INSTALL_GUIDE_URL"
    else
        echo "Please install it using your system's package manager (e.g., brew, apt, npm)."
    fi
    
    echo "--------------------------------------------------"
    
    # Exit with a non-zero status code to halt the parent process.
    exit 1
else
    # If the command is found, print a success message.
    echo "Dependency Check: '$COMMAND_NAME' is installed."
fi
```

## Example Usage
To use this in another workflow, you would call it like this:

```bash
# In another workflow file...

# Define the dependency you need
export COMMAND_NAME="playwright"
export INSTALL_GUIDE_URL="https://playwright.dev/docs/intro"

# Call the checker
./.ai_workflow/workflows/common/check_dependency.md
```
