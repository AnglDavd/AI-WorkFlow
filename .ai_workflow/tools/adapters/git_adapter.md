# Git Tool Adapter

## Overview
This workflow adapter translates abstract Git tool calls into concrete `git` shell commands. It provides a standardized interface for Git operations within the framework.

## Workflow Instructions

### For AI Agents
When you need to execute Git operations through abstract calls, this adapter will:

1. **Parse the action and parameters** from the abstract call
2. **Generate the appropriate git command** based on the action
3. **Return the command** for execution by the main tool engine
4. **Handle parameter validation** and error cases

### Adapter Function
```bash
# Main adapter function - called by execute_abstract_tool_call.md
execute_adapter() {
    local ACTION="$1"
    local PARAMS="$2"
    
    case "$ACTION" in
        "add")
            git_add "$PARAMS"
            ;;
        "add_all")
            git_add_all "$PARAMS"
            ;;
        "commit")
            git_commit "$PARAMS"
            ;;
        "push")
            git_push "$PARAMS"
            ;;
        "pull")
            git_pull "$PARAMS"
            ;;
        "checkout_branch")
            git_checkout_branch "$PARAMS"
            ;;
        "status")
            git_status "$PARAMS"
            ;;
        "diff")
            git_diff "$PARAMS"
            ;;
        "log")
            git_log "$PARAMS"
            ;;
        *)
            echo "ERROR: Unknown Git action - $ACTION"
            return 1
            ;;
    esac
}
```

### Supported Actions

#### `add` - Stage a single file
```bash
git_add() {
    local PARAMS="$1"
    
    # Extract file_path parameter
    local FILE_PATH=$(echo "$PARAMS" | sed -n 's/.*file_path="\([^"]*\)".*/\1/p')
    
    if [ -z "$FILE_PATH" ]; then
        echo "ERROR: file_path parameter required for git.add"
        return 1
    fi
    
    # Validate file exists
    if [ ! -f "$FILE_PATH" ] && [ ! -d "$FILE_PATH" ]; then
        echo "ERROR: File not found - $FILE_PATH"
        return 1
    fi
    
    # Generate command
    echo "git add \"$FILE_PATH\""
}
```

#### `add_all` - Stage all changes
```bash
git_add_all() {
    local PARAMS="$1"
    
    # No parameters needed for add_all
    echo "git add ."
}
```

#### `commit` - Commit staged changes
```bash
git_commit() {
    local PARAMS="$1"
    
    # Extract message parameter
    local MESSAGE=$(echo "$PARAMS" | sed -n 's/.*message="\([^"]*\)".*/\1/p')
    
    if [ -z "$MESSAGE" ]; then
        echo "ERROR: message parameter required for git.commit"
        return 1
    fi
    
    # Escape quotes in message
    local ESCAPED_MESSAGE=$(echo "$MESSAGE" | sed 's/"/\\"/g')
    
    # Generate command
    echo "git commit -m \"$ESCAPED_MESSAGE\""
}
```

#### `push` - Push changes to remote
```bash
git_push() {
    local PARAMS="$1"
    
    # Extract parameters with defaults
    local REMOTE=$(echo "$PARAMS" | sed -n 's/.*remote="\([^"]*\)".*/\1/p')
    local BRANCH=$(echo "$PARAMS" | sed -n 's/.*branch="\([^"]*\)".*/\1/p')
    
    # Set defaults
    if [ -z "$REMOTE" ]; then
        REMOTE="origin"
    fi
    
    if [ -z "$BRANCH" ]; then
        # Get current branch
        BRANCH=$(git branch --show-current)
    fi
    
    # Generate command
    echo "git push \"$REMOTE\" \"$BRANCH\""
}
```

#### `pull` - Pull changes from remote
```bash
git_pull() {
    local PARAMS="$1"
    
    # Extract parameters with defaults
    local REMOTE=$(echo "$PARAMS" | sed -n 's/.*remote="\([^"]*\)".*/\1/p')
    local BRANCH=$(echo "$PARAMS" | sed -n 's/.*branch="\([^"]*\)".*/\1/p')
    
    # Set defaults
    if [ -z "$REMOTE" ]; then
        REMOTE="origin"
    fi
    
    if [ -z "$BRANCH" ]; then
        # Get current branch
        BRANCH=$(git branch --show-current)
    fi
    
    # Generate command
    echo "git pull \"$REMOTE\" \"$BRANCH\""
}
```

#### `checkout_branch` - Switch or create branch
```bash
git_checkout_branch() {
    local PARAMS="$1"
    
    # Extract parameters
    local BRANCH_NAME=$(echo "$PARAMS" | sed -n 's/.*branch_name="\([^"]*\)".*/\1/p')
    local NEW=$(echo "$PARAMS" | sed -n 's/.*new=\([^,)]*\).*/\1/p')
    
    if [ -z "$BRANCH_NAME" ]; then
        echo "ERROR: branch_name parameter required for git.checkout_branch"
        return 1
    fi
    
    # Generate command based on new flag
    if [ "$NEW" = "true" ]; then
        echo "git checkout -b \"$BRANCH_NAME\""
    else
        echo "git checkout \"$BRANCH_NAME\""
    fi
}
```

#### `status` - Show repository status
```bash
git_status() {
    local PARAMS="$1"
    
    # Extract optional parameters
    local SHORT=$(echo "$PARAMS" | sed -n 's/.*short=\([^,)]*\).*/\1/p')
    
    if [ "$SHORT" = "true" ]; then
        echo "git status -s"
    else
        echo "git status"
    fi
}
```

#### `diff` - Show differences
```bash
git_diff() {
    local PARAMS="$1"
    
    # Extract parameters
    local FILE_PATH=$(echo "$PARAMS" | sed -n 's/.*file_path="\([^"]*\)".*/\1/p')
    local STAGED=$(echo "$PARAMS" | sed -n 's/.*staged=\([^,)]*\).*/\1/p')
    
    if [ "$STAGED" = "true" ]; then
        if [ -n "$FILE_PATH" ]; then
            echo "git diff --cached \"$FILE_PATH\""
        else
            echo "git diff --cached"
        fi
    else
        if [ -n "$FILE_PATH" ]; then
            echo "git diff \"$FILE_PATH\""
        else
            echo "git diff"
        fi
    fi
}
```

#### `log` - Show commit history
```bash
git_log() {
    local PARAMS="$1"
    
    # Extract parameters
    local LIMIT=$(echo "$PARAMS" | sed -n 's/.*limit=\([^,)]*\).*/\1/p')
    local ONELINE=$(echo "$PARAMS" | sed -n 's/.*oneline=\([^,)]*\).*/\1/p')
    
    local COMMAND="git log"
    
    if [ "$ONELINE" = "true" ]; then
        COMMAND="$COMMAND --oneline"
    fi
    
    if [ -n "$LIMIT" ]; then
        COMMAND="$COMMAND -n $LIMIT"
    fi
    
    echo "$COMMAND"
}
```

### Parameter Extraction Helper
```bash
# Helper function to extract parameters from abstract call
extract_param() {
    local PARAMS="$1"
    local PARAM_NAME="$2"
    local DEFAULT_VALUE="$3"
    
    local VALUE=$(echo "$PARAMS" | sed -n "s/.*${PARAM_NAME}=\"\([^\"]*\)\".*/\1/p")
    
    if [ -z "$VALUE" ]; then
        VALUE=$(echo "$PARAMS" | sed -n "s/.*${PARAM_NAME}=\([^,)]*\).*/\1/p")
    fi
    
    if [ -z "$VALUE" ] && [ -n "$DEFAULT_VALUE" ]; then
        VALUE="$DEFAULT_VALUE"
    fi
    
    echo "$VALUE"
}
```

### Validation Functions
```bash
# Validate Git repository exists
validate_git_repo() {
    if [ ! -d ".git" ]; then
        echo "ERROR: Not a Git repository"
        return 1
    fi
    return 0
}

# Validate branch exists
validate_branch_exists() {
    local BRANCH="$1"
    
    if ! git show-ref --verify --quiet "refs/heads/$BRANCH"; then
        echo "ERROR: Branch does not exist - $BRANCH"
        return 1
    fi
    return 0
}
```

### Error Handling
- **Repository Validation**: Check if current directory is a Git repository
- **Parameter Validation**: Ensure required parameters are provided
- **File Validation**: Verify files exist before staging
- **Branch Validation**: Check branch existence for checkout operations
- **Command Generation**: Return proper error codes for invalid operations

### Integration Notes
- Called by `execute_abstract_tool_call.md`
- Returns generated commands as strings
- Handles parameter parsing and validation
- Provides detailed error messages for debugging
- Supports all common Git operations needed by PRP workflows

### Abstract Call Examples
```bash
# Stage a file
git.add(file_path="src/main.js")

# Stage all changes
git.add_all()

# Commit with message
git.commit(message="Add new feature")

# Push to origin main
git.push(remote="origin", branch="main")

# Pull from origin
git.pull(remote="origin", branch="main")

# Create new branch
git.checkout_branch(branch_name="feature-branch", new=true)

# Switch to existing branch
git.checkout_branch(branch_name="main", new=false)

# Show status
git.status()

# Show diff
git.diff(file_path="src/main.js")

# Show recent commits
git.log(limit=5, oneline=true)
```