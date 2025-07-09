## Objective
This node creates the new project directory and moves all the framework files into it.

## Pre-conditions
The file `/.ai_workflow/temp_state.vars` must exist and contain the `PROJECT_NAME`.

## Commands
```bash
source ./.ai_workflow/temp_state.vars

# To avoid path issues, we operate from one level up
current_dir_name=${PWD##*/}
cd ..

if mkdir "$PROJECT_NAME"; then
    # Move all framework files into the new project directory
    # Using git to track all files, even hidden ones, is more reliable
    cd "$current_dir_name"
    git ls-files -c -o --exclude-standard | xargs -I {} mv {} "../$PROJECT_NAME/"
    mv .git* "../$PROJECT_NAME/" # Move git related files
    cd ".."
    # We will remove the old directory in a separate, final step
else
    echo "Failed to create directory '$PROJECT_NAME'. It might already exist."
    ./.ai_workflow/workflows/common/error.md "Failed to create project directory: '$PROJECT_NAME'. It might already exist."
    exit 1
fi

# Store the old directory name for the cleanup step
echo "export OLD_DIR_NAME=\"$current_dir_name\"" >> ./.ai_workflow/temp_state.vars
```

## Verification Criteria
A new directory with the project name should exist at `../` and contain the framework files.

## Next Steps
- **On Success:** Proceed to [Initialize New Git Repository](./04_init_git.md).
- **On Failure:** Proceed to [Generic Error Handler](../../common/error.md).
