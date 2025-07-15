# Manage Project State

## Overview
This workflow manages project state variables and provides a centralized way to track and access project configuration information.

## Current Project State

### Project Configuration
- **Project Name**: `Puchum_POS`
- **Original Directory**: `Project_Manager`
- **Framework Version**: AI-Assisted Development Framework v3
- **State Updated**: 2025-07-14

### Environment Variables
The following environment variables are available for workflow execution:

```bash
export PROJECT_NAME="Puchum_POS"
export OLD_DIR_NAME="Project_Manager"
```

## Workflow Instructions

### For AI Agents
When you need to access project state information:

1. **Read this file** to get current project configuration
2. **Use the environment variables** listed above in your bash commands
3. **Update this file** if project state changes during execution

### Generating Environment Variables
To generate environment variables for shell execution:

```bash
# Set project name
export PROJECT_NAME="Puchum_POS"

# Set original directory name
export OLD_DIR_NAME="Project_Manager"

# Verify variables are set
echo "Project Name: $PROJECT_NAME"
echo "Original Directory: $OLD_DIR_NAME"
```

### Updating Project State
To update project state, modify the "Current Project State" section above and update the timestamp.

## State Management Rules

1. **Single Source of Truth**: This file is the authoritative source for project state
2. **Atomic Updates**: Update all related fields when making changes
3. **Timestamp Tracking**: Always update the "State Updated" field when modifying state
4. **Environment Variables**: Keep bash export statements in sync with configuration

## Integration with Other Workflows

This workflow integrates with:
- **Setup workflows**: Initialize project state during setup
- **PRP execution**: Provide project context for task execution
- **Configuration management**: Central store for project settings

## Usage Examples

### Reading State in Workflows
```bash
# Source project state
source .ai_workflow/workflows/common/manage_project_state.md

# Use variables
echo "Working on project: $PROJECT_NAME"
```

### Updating State
```markdown
# Update this file when project configuration changes
# Example: After renaming project
- **Project Name**: `New_Project_Name`
- **State Updated**: 2025-07-14
```

## Notes
- This workflow replaces the previous `temp_state.vars` file
- All project state is now documented in markdown format
- Environment variables are generated from this central configuration
- State changes are tracked with timestamps for audit purposes