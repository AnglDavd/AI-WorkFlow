#!/bin/bash

# --- Interactive Project Setup Script ---
# This script configures the AI-Assisted Development Framework for a new project.

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
print_color "blue" " AI-Assisted Development Framework Setup           "
print_color "blue" "========================================================="

# 1. Get the desired project name
read -p "Enter your new project name (e.g., my-awesome-app): " PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
    print_color "red" "Project name cannot be empty. Aborting."
    exit 1
fi

# 2. Get the desired workflow directory name
read -p "Enter a name for the workflow directory [default: .ai_workflow]: " WORKFLOW_DIR_NAME
WORKFLOW_DIR_NAME=${WORKFLOW_DIR_NAME:-.ai_workflow}

print_color "green" "\nConfiguration Summary:"
print_color "green" "- Project Directory: $PROJECT_NAME"
print_color "green" "- Workflow Directory: $WORKFLOW_DIR_NAME"

read -p "Proceed with this configuration? (y/n): " CONFIRMATION
if [ "$CONFIRMATION" != "y" ]; then
    print_color "red" "Setup aborted by user."
    exit 1
fi

# 3. Create project directory and move files
print_color "blue" "\nCreating project structure..."

# Create the project directory in the parent folder
cd ..
mkdir "$PROJECT_NAME"

# Move all framework files into the new project directory
mv Project_Manager/* "$PROJECT_NAME/"
mv Project_Manager/.gitignore "$PROJECT_NAME/"

# Enter the new project directory
cd "$PROJECT_NAME"

# 4. Rename workflow directory if needed
if [ ".ai_workflow" != "$WORKFLOW_DIR_NAME" ]; then
    mv .ai_workflow "$WORKFLOW_DIR_NAME"
    print_color "blue" "Renamed workflow directory to $WORKFLOW_DIR_NAME"
fi

# 5. Update .gitignore and README.md with the new workflow directory name
sed -i "s/.ai_workflow/$WORKFLOW_DIR_NAME/g" .gitignore
sed -i "s/.ai_workflow/$WORKFLOW_DIR_NAME/g" README.md
print_color "blue" "Updated configuration files."

# 6. Initialize new Git repository
print_color "blue" "Initializing new Git repository..."
rm -rf .git
git init > /dev/null 2>&1
git add . > /dev/null 2>&1
git commit -m "Initial commit: Set up AI development framework" > /dev/null 2>&1

# 7. Self-destruct setup script
print_color "blue" "Cleaning up setup script..."
rm -- "$0"

print_color "green" "\n========================================================="
print_color "green" " Setup Complete! Your new project is ready."
print_color "green" "- Navigate to your project: cd ../$PROJECT_NAME"
print_color "green" "- Start by following the instructions in README.md"
print_color "green" "========================================================="
