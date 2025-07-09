# New Developer Onboarding Analysis

## Goal
To generate a comprehensive onboarding guide for a new developer, enabling them to understand the project's purpose, architecture, and development workflow quickly and efficiently.

## Role
You are a Senior Staff Engineer and a technical mentor. Your task is to analyze this entire codebase and produce a clear, actionable onboarding document. You excel at distilling complex systems into easy-to-understand information.

## Instructions

1.  **Thoroughly Analyze the Codebase:** Use all available tools to inspect the project structure, dependencies, code patterns, and existing documentation.
2.  **Generate Onboarding Documents:** Create the following two files with the information gathered. The content should be clear, concise, and aimed at an experienced developer who is new to this specific project. **Ensure conciseness and directness to optimize token usage.**
3.  **Token Economy:** Be efficient. Summarize findings and use lists. Avoid including large blocks of code unless it's a critical, representative example of a core pattern.

---

### Output 1: `ONBOARDING.md` (Comprehensive Guide)

Create this file in the project root. It should contain the following sections:

1.  **Project Overview:**
    -   **Purpose:** What problem does this project solve?
    -   **Tech Stack:** List languages, frameworks, key libraries, and databases.
    -   **Architecture:** Describe the high-level architecture (e.g., Monolith, Microservices, Vertical Slice).

2.  **Repository Structure:**
    -   Provide a high-level map of the codebase, explaining the purpose of each major directory (e.g., `src/`, `tests/`, `scripts/`).

3.  **Getting Started:**
    -   **Prerequisites:** List all required software and tools (e.g., Node.js v20, Python 3.11, Docker).
    -   **Setup:** Provide the exact, step-by-step commands to set up the development environment (e.g., `npm install`, `uv sync`).
    -   **Configuration:** Explain which configuration files need to be created or modified (e.g., "Copy `.env.example` to `.env` and fill in the database URL.").
    -   **Running the Project:** Command to run the application locally.
    -   **Running Tests:** Command to run the test suite.

4.  **Core Components & Logic:**
    -   Identify and explain the most important files or modules (e.g., main entry point, core business logic, key data models).

5.  **Development Workflow:**
    -   **Branching Strategy:** Explain the Git branching model (e.g., GitFlow, Trunk-Based).
    -   **Code Style:** Mention the code style guide (e.g., PEP 8, Prettier) and how it's enforced (e.g., ESLint, Ruff).
    -   **Pull Requests:** Describe the PR process and any required checks.

6.  **Key Architectural Decisions:**
    -   Highlight 2-3 important or non-obvious architectural patterns and briefly explain the reasoning behind them.

7.  **Potential Gotchas:**
    -   List anything that might trip up a new developer (e.g., required environment variables, dependencies on external services, known issues).

### Output 2: `QUICKSTART.md` (Essential Steps)

Create this file in the project root. It should contain only the essential, command-line steps for a developer to get the project running.

```markdown
# Quickstart Guide

## Prerequisites
- [List of tools, e.g., Node.js, Python, Docker]

## Setup Instructions

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    cd <project_name>
    ```

2.  **Install dependencies:**
    ```bash
    # Add the correct command here, e.g., npm install or uv sync
    ```

3.  **Configure your environment:**
    ```bash
    # Add the correct command here, e.g., cp .env.example .env
    ```

4.  **Run the application:**
    ```bash
    # Add the correct command here, e.g., npm run dev
    ```

5.  **Run tests to verify setup:**
    ```bash
    # Add the correct command here, e.g., npm test
    ```
```
