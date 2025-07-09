## Objective
This node guides the user through the process of creating a Pull Request to contribute a new or improved language guide to the main framework repository.

## Commands
```bash
# --- Step 1: Get Guide File Path ---
read -p "Enter the absolute path to the language guide file you want to contribute (e.g., /home/user/my_project/.ai_workflow/agent_guide_examples/NEW_LANG.md): " GUIDE_FILE_PATH

if [ -z "$GUIDE_FILE_PATH" ]; then
    echo "Error: Guide file path cannot be empty. Aborting."
    exit 1
fi

if [ ! -f "$GUIDE_FILE_PATH" ]; then
    echo "Error: Guide file not found at '$GUIDE_FILE_PATH'. Aborting."
    exit 1
fi

# --- Step 2: Determine Target Path in Framework Repository ---
# Assuming the guide should go into .ai_workflow/agent_guide_examples/
GUIDE_FILE_NAME=$(basename "$GUIDE_FILE_PATH")
TARGET_REPO_PATH=".ai_workflow/agent_guide_examples/${GUIDE_FILE_NAME}"

# --- Step 3: Create a New Branch ---
BRANCH_NAME="feat/contribute-$(echo "$GUIDE_FILE_NAME" | sed 's/.md$//g' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_ -]//g' | sed 's/ /-/g')"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed. Please install it to proceed with PR creation. Aborting."
    exit 1
fi

# Ensure we are in a git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Error: Not inside a Git repository. Please run this workflow from the root of your cloned framework repository. Aborting."
    exit 1
fi

# Fetch latest main/develop to ensure up-to-date branch
git checkout main || git checkout develop || git checkout master
git pull origin main || git pull origin develop || git pull origin master

git checkout -b "$BRANCH_NAME"

# --- Step 4: Copy the Guide File to the Correct Location ---
cp "$GUIDE_FILE_PATH" "$TARGET_REPO_PATH"

# --- Step 5: Stage and Commit Changes ---
git add "$TARGET_REPO_PATH"
git commit -m "feat(docs): Add/update language guide for $(echo "$GUIDE_FILE_NAME" | sed 's/.md$//g')"

# --- Step 6: Create Pull Request ---
PR_TITLE="feat(docs): Add/update language guide for $(echo "$GUIDE_FILE_NAME" | sed 's/.md$//g')"
PR_BODY="This PR contributes a new/updated language guide for $(echo "$GUIDE_FILE_NAME" | sed 's/.md$//g').\n\nIt follows the framework's guidelines for agent_guide_examples and aims to provide comprehensive context for AI assistants working with this technology.\n\n**Checklist:**\n- [ ] The guide is model-agnostic.\n- [ ] It adheres to the framework's documentation standards.\n- [ ] It provides clear and actionable guidance for AI agents.\n- [ ] All code examples are correct and follow best practices.\n- [ ] The guide is concise and optimizes token usage.\n\n**Reviewers:** @framework-maintainers (if applicable)"

# Create the PR using gh CLI
gh pr create --title "$PR_TITLE" --body "$PR_BODY" --web

echo "Pull Request creation initiated. A browser window should open for you to finalize the PR."
```

## Verification Criteria
The command should exit with 0, and a browser window should open to the GitHub Pull Request creation page with fields pre-filled.

## Next Steps
- **On Success:** Proceed to [Workflow Completed](../../common/success.md).
- **On Failure:** Proceed to [Generic Error Handler](../../common/error.md).
