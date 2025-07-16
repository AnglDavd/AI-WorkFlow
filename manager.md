# 🚀 AI Development Framework

Welcome to the AI Development Framework, a comprehensive system for building and managing software using AI agents with zero-friction automation.

**This file is the main documentation entry point.**

**📋 For comprehensive architectural information, see [ARCHITECTURE.md](.ai_workflow/ARCHITECTURE.md)**

## Framework Status

**📋 For complete version information and development status, see [ARCHITECTURE.md - Framework Status](ARCHITECTURE.md#framework-status)**

**Current Version:** v0.4.1-beta (Beta Phase with Quality Integration)
**Key Features:**
- ✅ Automatic quality validation with adaptive language support
- ✅ Zero-friction automation philosophy
- ✅ Multi-language project compatibility (30+ languages)

## Key Principles

- **Transparency:** All logic is defined in readable `.md` workflow files.
- **User Control:** The system proposes, the user approves.
- **Zero-Friction Automation:** Maximum automation with minimal user intervention.
- **Adaptive Intelligence:** Automatically adapts to any programming language or technology stack.
- **Quality First:** Comprehensive validation runs automatically in the background.

---

## 🚀 Quick Start: The `ai-dev` CLI

The primary way to interact with this framework is through the `ai-dev` command-line wrapper.

**To see all available commands, run:**
```bash
./ai-dev help
```

### Core Commands

-   **`./ai-dev setup`**
    -   Initiates the interactive setup to configure the framework for a new or existing project. **This is the first command you should run.**

-   **`./ai-dev generate <path_to_prd.md>`**
    -   Takes a Product Requirements Document (PRD) and generates one or more executable Project-Response-Plan (PRP) files.

-   **`./ai-dev run <path_to_prp.md>`**
    -   Executes a specific PRP using the AI agent engine, which will then write code, run tests, and attempt to complete the task.

### New Quality & Automation Commands

-   **`./ai-dev quality <path>`**
    -   Runs comprehensive quality validation with adaptive language support (30+ languages). Works automatically in the background.

-   **`./ai-dev audit`**
    -   Performs security audit and compliance checking across the entire framework.

-   **`./ai-dev precommit <subcommand>`**
    -   Manages pre-commit validation system. Subcommands: `validate`, `install-hooks`, `configure`, `report`.

### Advanced Commands

-   **`./ai-dev optimize <prompt_file>`**
    -   Optimizes prompt files using best practices and token economy analysis.

-   **`./ai-dev sync`**
    -   Synchronizes framework with updates and community improvements.

-   **`./ai-dev configure`**
    -   Interactive configuration management for framework settings.

-   **`./ai-dev diagnose`**
    -   Comprehensive health check and diagnostic reporting for the framework.

---

## For AI Agents: How to Interpret User Requests

**Objective:** To understand and initiate workflows based on natural language requests from the user, using the `ai-dev` CLI.

**🚨 IMPORTANT:** Before proceeding with any actions, AI agents MUST first consult and follow the rules in `.ai_workflow/GLOBAL_AI_RULES.md`. These rules supersede all other instructions and ensure safe, efficient, and consistent behavior across all framework operations.

**Instructions for AI Agent:**

-   **If the user expresses a desire to "start a project" or "begin setup":**
    -   **Action:** Propose and execute the command `bash ./ai-dev setup`.
    -   **Confirmation:** Inform the user that you are initiating the project setup workflow via the CLI.

-   **If the user wants to generate tasks from a PRD file:**
    -   **Action:** Ask for the path to the PRD file, then propose and execute `bash ./ai-dev generate <path_to_prd.md>`.

-   **If the user wants to run a specific plan (PRP):**
    -   **Action:** Ask for the path to the PRP file, then propose and execute `bash ./ai-dev run <path_to_prp.md>`.

-   **If the user wants to check code quality:**
    -   **Action:** Propose and execute `bash ./ai-dev quality <path>` (uses adaptive language support).

-   **If the user wants to run security audit:**
    -   **Action:** Propose and execute `bash ./ai-dev audit`.

-   **If the user wants to configure the framework:**
    -   **Action:** Propose and execute `bash ./ai-dev configure`.

-   **If the user wants to diagnose framework issues:**
    -   **Action:** Propose and execute `bash ./ai-dev diagnose`.

-   **If the user asks a general question:**
    -   **Action:** Execute the workflow at `/.ai_workflow/workflows/assistant/01_ask_assistant.md`. (This is a temporary exception until it is integrated into the CLI).

## Automatic Features (Zero-Friction)

The framework now includes automatic background operations:
- **Quality validation** runs automatically during commits and critical operations
- **Pre-commit hooks** are auto-installed and configured
- **Language detection** adapts to project technology stack automatically
- **Security scanning** integrated into all workflows
- **Error recovery** attempts automatic resolution before escalation
