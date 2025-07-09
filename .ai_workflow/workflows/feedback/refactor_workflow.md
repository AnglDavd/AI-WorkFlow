## Objective
As an AI agent, your objective is to safely apply a proposed change to a workflow node.

## Pre-conditions
- You have already formulated a hypothesis for a change.
- You have identified the file to modify and the exact change to make (the `old_string` and `new_string`).

## Agent Instructions (Protocol)

1.  **Log Start:** Call `log_work_journal.md` with "INFO" and "Starting refactor workflow."
2.  **Propose the Change:** Present the planned change to the user for approval. You MUST show the user the exact file you will modify and a `diff`-like view of the `old_string` and `new_string`.
    - *Example Proposal:* "I will modify `run_tests.md`. I will replace the line `npm test` with `npm run test:ci`. Do you approve?"

3.  **Await Explicit Approval:** Do NOT proceed without a clear "yes" or "proceed" from the user.

4.  **Execute the Change:** Upon approval, use the `replace` or `write_file` tool to apply the change.

5.  **Handle Tool Errors:** If the tool fails (e.g., `old_string` not found), stop immediately. Inform the user, re-read the file to get the latest content, and formulate a new proposal. Do not leave the system in a broken state.

6.  **Verify the Change (Crucial):** After a successful modification, you must validate it. This usually means running the workflow you just changed to ensure it works and that the fix was effective. Report the result of this verification to the user.

7.  **Clean Up:** Once the change is applied and verified, remove any temporary files related to the feedback (`temp_feedback.log`).

## Next Steps

- **After successful verification:** The refactoring is complete. Proceed to [Workflow Completed](../../common/success.md).
- **If verification fails:** The change introduced a new problem. Inform the user and ask if you should attempt to revert the change or debug the new issue. Proceed to [Generic Error Handler](../../common/error.md) to halt the automated flow.

if [ $? -ne 0 ]; then
    ./.ai_workflow/workflows/common/error.md "Failed during refactor workflow."
    exit 1
fi
