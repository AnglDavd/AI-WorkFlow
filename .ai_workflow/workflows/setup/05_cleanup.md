## Objective
This node performs the final cleanup actions based on the setup mode used.

## Pre-conditions
- The setup process is complete.
- The `SETUP_MODE` is defined in `temp_state.vars`.

## Commands
```bash
source ./.ai_workflow/temp_state.vars

# Function to generate architecture documentation
generate_architecture_docs() {
    local target_dir="$1"
    local project_name="$2"
    
    echo "📋 Generating project architecture documentation..."
    
    # Change to target directory for proper project detection
    cd "$target_dir"
    
    # Set PROJECT_ROOT for the architecture generation workflow
    export PROJECT_ROOT="$target_dir"
    export PROJECT_NAME="$project_name"
    
    # Execute architecture generation workflow
    if [ -f ".ai_workflow/workflows/documentation/generate_project_architecture.md" ]; then
        # Use the framework's workflow execution
        bash .ai_workflow/workflows/documentation/generate_project_architecture.md
        
        if [ $? -eq 0 ]; then
            echo "✅ Architecture documentation generated successfully"
            echo "📄 Created: ARCHITECTURE.md"
        else
            echo "⚠️  Architecture documentation generation failed, but setup continues"
        fi
    else
        echo "⚠️  Architecture documentation workflow not found, skipping"
    fi
    
    # Return to original directory
    cd - > /dev/null
}

# Determine target directory and generate architecture documentation
if [ -n "$PROJECT_DIR" ] && [ "$PROJECT_DIR" != "." ]; then
    # Injected into existing project
    TARGET_DIR="$PROJECT_DIR"
else
    # New project in current directory
    TARGET_DIR="."
fi

# Generate architecture documentation
generate_architecture_docs "$TARGET_DIR" "$PROJECT_NAME"

# Setup automatic .gitignore for repository cleanliness
echo "🛡️  Setting up automatic repository cleanliness..."
if [ -f ".ai_workflow/workflows/setup/auto_gitignore_setup.md" ]; then
    # Change to target directory for proper setup
    cd "$TARGET_DIR"
    
    # Execute auto .gitignore setup
    sed -n '/^```bash/,/^```/p' .ai_workflow/workflows/setup/auto_gitignore_setup.md | sed '/^```/d' | bash
    
    if [ $? -eq 0 ]; then
        echo "✅ Auto .gitignore setup completed successfully"
        echo "🛡️  Repository cleanliness: Zero-friction guaranteed"
    else
        echo "⚠️  Auto .gitignore setup failed, but setup continues"
    fi
    
    # Return to original directory
    cd - > /dev/null
else
    echo "⚠️  Auto .gitignore setup workflow not found, skipping"
fi

# CASE 1: We injected the framework into an existing project.
if [ "$SETUP_MODE" == "inject" ]; then
    echo "--------------------------------------------------"
    echo "Framework injection complete."
    echo "✅ Project: $PROJECT_NAME"
    echo "📋 Architecture documentation: $TARGET_DIR/ARCHITECTURE.md"
    echo "This installer directory has served its purpose."
    echo "You can now safely delete this directory."
    echo "--------------------------------------------------"

# CASE 2: We created a new project from the installer.
elif [ "$SETUP_MODE" == "new" ]; then
    # The logic to handle directory cleanup if a new one was created
    # was complex and brittle. A simpler approach is to instruct the user.
    echo "--------------------------------------------------"
    echo "New project '$PROJECT_NAME' created successfully."
    echo "📋 Architecture documentation: $TARGET_DIR/ARCHITECTURE.md"
    echo "This installer directory is no longer needed."
    echo "You can now safely delete it."
    echo "--------------------------------------------------"
fi

# Clean up the temporary state file in the final project directory
if [ -n "$PROJECT_DIR" ] && [ "$PROJECT_DIR" != "." ]; then
    rm "$PROJECT_DIR/.ai_workflow/temp_state.vars"
else
    rm ./.ai_workflow/temp_state.vars
fi

```

## Verification Criteria
- The `temp_state.vars` file should be removed from the final project directory.
- The `ARCHITECTURE.md` file should be created in the project root directory.
- The architecture documentation should be customized for the detected project technologies.

## Next Steps
- **On Success:** Proceed to [Workflow Completed](../../common/success.md).
- **On Failure:** Proceed to [Generic Error Handler](../../common/error.md).