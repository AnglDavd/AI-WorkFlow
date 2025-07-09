# Core Project Context Primer

## Goal
To prime the AI agent with essential knowledge about this project, enabling it to understand the codebase's structure, purpose, and key components efficiently.

## Role
You are an AI agent preparing to work on a new software project. Your task is to analyze the provided files and synthesize a foundational understanding of the codebase.

## Instructions

1.  **Analyze Key Files:** Read and analyze the content of the following critical files:
    -   `AGENT_GUIDE.md` (if it exists)
    -   `README.md`
    -   Any other key files specified by the user (`$ARGUMENTS`).

2.  **Explore the Codebase:**
    -   Use file system tools to understand the project's directory structure.
    -   Identify the main source code directories (e.g., `src/`).

3.  **Synthesize and Report:** After your analysis, provide a concise summary that explains back your understanding of the following points: **Ensure conciseness and directness to optimize token usage.**
    -   **Project Purpose:** What is the main goal of this project?
    -   **Project Structure:** How is the codebase organized at a high level?
    -   **Key Technologies:** What are the primary languages, frameworks, and dependencies?
    -   **Core Files:** What are the most important files or directories and what are their roles?
    -   **Configuration:** How is the project configured (e.g., environment variables, config files)?

## Token Economy
- Be efficient. Your summary should be a high-level overview. Do not recite file contents verbatim. Use bullet points and keep descriptions brief.
