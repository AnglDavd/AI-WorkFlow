# 🚀 AI Development Framework

Welcome to the AI Development Framework, a system for building and managing software using AI agents.

**This file is the main documentation entry point.**

## Key Principles

- **Transparency:** All logic is defined in readable `.md` workflow files.
- **User Control:** The system proposes, the user approves.
- **Automation:** A simple command-line interface (`ai-dev`) provides access to all major workflows.

---

## 🚀 Quick Start: The `ai-dev` CLI

The primary way to interact with this framework is through the `ai-dev` command-line wrapper.

**To see all available commands, run:**
```bash
./ai-dev help
```

### Common Commands

-   **`./ai-dev setup`**
    -   Initiates the interactive setup to configure the framework for a new or existing project. **This is the first command you should run.**

-   **`./ai-dev generate <path_to_prd.md>`**
    -   Takes a Product Requirements Document (PRD) and generates one or more executable Project-Response-Plan (PRP) files.

-   **`./ai-dev run <path_to_prp.md>`**
    -   Executes a specific PRP using the AI agent engine, which will then write code, run tests, and attempt to complete the task.

---

## For AI Agents: How to Interpret User Requests

**Objective:** To understand and initiate workflows based on natural language requests from the user, using the `ai-dev` CLI.

**Instructions for AI Agent:**

-   **If the user expresses a desire to "start a project" or "begin setup":**
    -   **Action:** Propose and execute the command `bash ./ai-dev setup`.
    -   **Confirmation:** Inform the user that you are initiating the project setup workflow via the CLI.

-   **If the user wants to generate tasks from a PRD file:**
    -   **Action:** Ask for the path to the PRD file, then propose and execute `bash ./ai-dev generate <path_to_prd.md>`.

-   **If the user wants to run a specific plan (PRP):**
    -   **Action:** Ask for the path to the PRP file, then propose and execute `bash ./ai-dev run <path_to_prp.md>`.

-   **If the user asks a general question:**
    -   **Action:** Execute the workflow at `/.ai_workflow/workflows/assistant/01_ask_assistant.md`. (This is a temporary exception until it is integrated into the CLI).
