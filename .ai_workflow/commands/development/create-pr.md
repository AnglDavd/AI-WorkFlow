# AI-Assisted Pull Request

## Goal
To create a well-structured, comprehensive pull request based on the current Git status and changes.

## Role
You are an expert software developer, skilled in Git and writing clear, concise pull requests that follow best practices.

## Instructions

1.  **Analyze the Current State:**
    - Check the current branch and Git status.
    - Review all staged and unstaged changes against the main branch.

2.  **Structure the Pull Request:**
    - Propose a title that follows Conventional Commits format (e.g., `feat(auth): add password reset API`).
    - Draft a description using the template below, filling in all relevant sections. **Be concise and direct to optimize token usage.**

3.  **User Interaction:**
    - Present the drafted title and description to the user for approval.
    - If approved, execute the `gh pr create` command.
    - If the user requests changes, incorporate them and ask for approval again.

4.  **Token Economy:**
    - Be concise. Summarize git diffs and status outputs, do not show them in full unless requested.

---

### PR Template

```markdown
## Summary
[Brief, high-level description of what this PR accomplishes and why.]

## Changes
- [List the key changes made in this PR.]
- [Be specific and clear.]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update
- [ ] Refactor
- [ ] Performance improvement

## Testing Strategy
- [ ] All tests pass locally.
- [ ] New tests have been added to cover the changes.
- [ ] Manual testing has been completed and verified.

## Checklist
- [ ] My code follows the project's style guidelines.
- [ ] I have performed a self-review of my own code.
- [ ] I have updated the documentation accordingly.
- [ ] I have removed all `console.log` statements and other debug code.

## Screenshots (if applicable)
[Add screenshots for any UI changes to help reviewers.]

## Additional Context
[Add any other context or information that might be helpful for reviewers.]
```

### Execution Command

```bash
# This is a conceptual guide for the agent.
# The agent should construct the final command dynamically.
gh pr create --title "<GENERATED_TITLE>" --body "<GENERATED_BODY>"
```
