# Confirm Critical File Change

## Objective
To obtain explicit user approval before making modifications to critical project files.

## Role
You are a security gatekeeper. Your primary responsibility is to ensure that no critical file is modified without the human user's direct consent.

## Input
-   `FILE_PATH`: The absolute path to the file proposed for modification.
-   `PROPOSED_CONTENT_DIFF`: (Optional) A diff string showing the proposed changes to the file. If not provided, the agent should read the `NEW_CONTENT`.
-   `NEW_CONTENT`: (Optional) The full new content of the file. Used if `PROPOSED_CONTENT_DIFF` is not available.

## Critical File Patterns (Examples - to be refined in _ai_knowledge.md)

-   `src/**` (all source code files)
-   `config/**` (configuration directories)
-   `package.json`, `pom.xml`, `build.gradle`, `requirements.txt` (dependency/build configs)
-   `Dockerfile`
-   `_ai_knowledge.md`, `GLOBAL_AI_RULES.md` (framework core files)

## Execution Flow

1.  **Identify File:** Clearly state the `FILE_PATH` that is about to be modified.

2.  **Present Changes:**
    -   If `PROPOSED_CONTENT_DIFF` is provided, display it to the user.
    -   If `NEW_CONTENT` is provided (and `PROPOSED_CONTENT_DIFF` is not), read the current content of `FILE_PATH` and generate a diff between the current and `NEW_CONTENT`. Then display this diff.
    -   If neither is provided, inform the user that the content of the change cannot be displayed and ask for confirmation based on the file path alone (less ideal).

3.  **Request Approval:** Ask the user for explicit approval to proceed with the modification.
    -   **Question:** "I am about to modify the critical file: `<FILE_PATH>`. Do you approve this change? (Yes/No)"

4.  **Await User Decision:** Wait for the user's response.

5.  **Act Based on Decision:**
    -   **If User Approves (Yes):** Inform the user that the change will proceed. The calling workflow is responsible for actually performing the `write_file` or `replace` operation.
    -   **If User Disapproves (No):** Inform the user that the change has been cancelled. The calling workflow is responsible for handling the cancellation (e.g., reverting its state, reporting a failure).

## Example Interaction

**Agent:** "I am about to modify the critical file: `/home/user/project/src/main.py`. Here are the proposed changes:
```diff
--- a/src/main.py
+++ b/src/main.py
@@ -1,3 +1,4 @@
 def old_function():
     pass
+def new_function():
+    pass
```
Do you approve this change? (Yes/No)"

**User:** "Yes"

**Agent:** "Change approved. Proceeding with modification."
