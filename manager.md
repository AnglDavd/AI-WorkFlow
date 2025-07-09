# 🚀 Dynamic Project Manager (DPM)

Welcome to the project management system based on the Dynamic Project Manifest. All logic and workflows are driven by `.md` files for maximum transparency and auditability.

**This file is the main entry point.**

## Key Principles

- **Transparency:** What you see is what is executed. No hidden logic.
- **User Control:** The system proposes, the user approves.
- **Self-Improvement:** The system learns from feedback and errors to evolve.

---

## For AI Agents: How to Interpret User Requests

**Objective:** To understand and initiate workflows based on natural language requests from the user.

**Instructions for AI Agent:**

-   **If the user expresses a desire to "start a project" or "begin setup" (e.g., "comencemos el proyecto", "quiero iniciar un nuevo proyecto"):**
    -   **Action:** Read and execute the workflow located at `/.ai_workflow/workflows/setup/01_start_setup.md`.
    -   **Confirmation:** Inform the user that you are initiating the project setup workflow.

-   **If the user asks a general question or requests guidance not covered by a specific workflow:**
    -   **Action:** Read and execute the workflow located at `/.ai_workflow/workflows/assistant/01_ask_assistant.md`.

-   **For any other specific workflow listed below:**
    -   **Action:** Read the corresponding `.md` file and follow its instructions.

---

## Available Workflows

Select the workflow you want to start:

- **[Project Setup](./.ai_workflow/workflows/setup/01_start_setup.md):** Set up a new project from scratch using this framework.
- **[Create a new PRD (Product Requirements Document)](./.ai_workflow/workflows/prd/01_create_prd.md):** A guided process for creating a new PRD.
- **[Create a new PRP (Product Requirement Prompt)](./.ai_workflow/workflows/prp/01_create_prp.md):** A guided process for creating a new PRP.
- **[Execute a PRP](./.ai_workflow/workflows/run/01_run_prp.md):** Execute an existing PRP with an AI agent.
- **[Framework Assistant](./.ai_workflow/workflows/assistant/01_ask_assistant.md):** Ask a question or request guidance from the framework assistant.

To start a workflow, read its corresponding `.md` file and follow the instructions. Each workflow will log its progress to the work journal.