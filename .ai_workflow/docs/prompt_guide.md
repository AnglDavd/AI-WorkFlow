# Prompt Engineering Guide

## 1. Core Principles

The quality of the output is directly proportional to the quality of the input. This guide provides best practices for engineering prompts to ensure they are clear, effective, and produce consistent results.

**The Three Pillars of a Good Prompt:**
1.  **Role & Goal:** Be explicit about the persona the AI should adopt and the specific goal it should achieve.
2.  **Context & Constraints:** Provide all necessary context (code, docs, examples) and define clear constraints and rules.
3.  **Format & Structure:** Specify the desired output format (e.g., Markdown, YAML, JSON) and provide a clear structure or template.

---

## 2. Best Practices

### Be Specific and Unambiguous
-   **Avoid:** "Fix the code."
-   **Prefer:** "In `src/api.ts`, the `getUser` function throws an error when the user is not found. Modify it to return `null` instead of throwing an error."

### Provide High-Quality Context
-   **Code Snippets:** Always provide the relevant code snippet. Include a few lines before and after for context.
-   **File Paths:** Use full, unambiguous file paths.
-   **Existing Patterns:** If a similar feature exists, point to it as a reference pattern.
-   **"What to Avoid":** Explicitly state anti-patterns or common gotchas.

### Use Delimiters
To separate different parts of your prompt (e.g., instructions from context), use clear delimiters like `---`, `###`, or XML tags. This helps the model differentiate between instructions and data.

```
### INSTRUCTIONS ###
Summarize the following text.

### TEXT TO SUMMARIZE ###
{text goes here}
```

### Chain of Thought / Step-by-Step
For complex tasks, instruct the model to "think step by step". This forces a more logical process and often leads to better results.

-   **Example:** "First, analyze the user's request. Second, identify the relevant files. Third, propose a plan. Fourth, write the code."

### Define the Output Format
Be explicit about the structure of the desired output. If you want JSON, provide the schema. If you want Markdown, provide the headings.

-   **Example:** "Provide the output as a JSON object with the following keys: `filePath`, `className`, `methods`."

### Few-Shot Prompting (Provide Examples)
Show, don't just tell. Provide one or two high-quality examples of the desired input/output format.

```
### EXAMPLE 1 ###
Input: "add 2 and 2"
Output: {"operation": "add", "a": 2, "b": 2}

### EXAMPLE 2 ###
Input: "multiply 5 by 3"
Output: {"operation": "multiply", "a": 5, "b": 3}

### YOUR TASK ###
Input: "subtract 10 from 7"
Output:
```

---

## 3. Key Resources

This guide is a summary of best practices from industry leaders. For more in-depth information, consult the original sources:

-   **Google:** [Gemini for Google Workspace Prompting Guide](https://services.google.com/fh/files/misc/gemini-for-google-workspace-prompting-guide-101.pdf)
-   **Anthropic:** [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
-   **OpenAI:** [GPT-4 Prompting Guide](https://cookbook.openai.com/examples/gpt4-1_prompting_guide)
