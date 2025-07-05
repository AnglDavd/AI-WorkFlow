# AI-Assisted Development Framework

This project provides a simplified, shell-script-based framework for AI-assisted software development.
It leverages Large Language Model (LLM) CLIs and Markdown files to guide the entire development workflow, from Product Requirements Definition (PRD) to code implementation.

## Project Structure

```
your-project/
|-- 01_setup.sh            # Initial project setup script (run once)
|-- 02_create_prp.sh       # Script to generate PRDs and PRPs
|-- README.md              # This file
|-- .ai_workflow/          # Core framework assets and LLM instructions
|   |-- commands/          # LLM commands (e.g., code review, git operations)
|   |   |-- claude/
|   |   |-- gemini/
|   |   `-- openai/
|   |-- PRPs/              # Product Requirement Prompts (PRPs) and related assets
|   |   |-- templates/     # PRP templates (e.g., prp_base.md, prp_planning.md)
|   |   |-- scripts/       # PRP runner script (prp_runner.sh)
|   |   |-- ai_docs/       # AI documentation and context for LLMs
|   |   |-- generated/     # Generated PRDs and PRPs
|   |   `-- completed/     # Completed PRPs
|   |-- claude_md_files/   # Framework-specific CLAUDE.md examples
|   |-- CLAUDE.md          # Project-specific guidelines for LLMs
|   |-- README_framework.md # Original README from the framework assets
|   |-- _ai_knowledge.md   # LLM's persistent knowledge base
|   |-- _project.md        # Project status and key documents for LLMs
|   |-- create-prd.md      # LLM instructions for creating PRDs
|   |-- generate-tasks.md  # LLM instructions for generating task lists
|   |-- process-task-list.md # LLM instructions for executing tasks
|   |-- review-and-refactor.md # LLM instructions for code review and refactoring
|   |-- feedback_prompt.md # LLM instructions for generating feedback
|   |-- progress_report.md # LLM instructions for generating progress reports
|   `-- GLOBAL_AI_RULES.md # Global rules for LLM behavior
|-- 03_run_prp.sh          # Script to execute PRPs
`-- (your source code and tests will reside here)
```

## Getting Started

1.  **Initial Setup**: Run the `01_setup.sh` script once to set up your project structure.

    ```bash
    ./01_setup.sh
    ```

    *This script will prompt you for a project name and then move all framework assets into the new project directory. It will then self-destruct.* 

2.  **Generate a PRD (Product Requirements Document)**: Use `02_create_prp.sh` to have an LLM generate a high-level PRD for your feature.

    ```bash
    ./02_create_prp.sh
    ```

    *This script will prompt you for a feature description and the LLM CLI to use. It will generate a PRD based on the `.ai_workflow/PRPs/templates/prp_planning.md` template and save it in `.ai_workflow/PRPs/generated/`.*

3.  **Generate an Implementation PRP**: Once you have a PRD, use `02_create_prp.sh` again to generate a detailed Implementation PRP.

    ```bash
    ./02_create_prp.sh
    ```

    *This time, you'll guide the LLM to use the `.ai_workflow/PRPs/templates/prp_base.md` template, incorporating details from your PRD to create actionable development tasks.*

4.  **Execute the Implementation PRP**: Use the `03_run_prp.sh` script to have an LLM implement the tasks defined in your PRP.

    ```bash
    ./03_run_prp.sh --prp [your-prp-name] --model [llm-cli] --interactive
    ```

    *Replace `[your-prp-name]` with the name of your generated PRP (e.g., `my-feature-prp`) and `[llm-cli]` with your LLM CLI (e.g., `claude`, `gemini`). The `--interactive` flag allows for a conversational execution.* 

## Key Concepts

-   **PRD (Product Requirements Document)**: A high-level document defining *what* to build and *why*. Generated using `prp_planning.md`.
-   **PRP (Product Requirement Prompt)**: A detailed implementation document defining *how* to build a feature. Generated using `prp_base.md`.
-   **LLM CLI**: Command-line interface for your chosen Large Language Model (e.g., Claude, Gemini, OpenAI).
-   **`.ai_workflow/`**: The central directory containing all framework assets, LLM instructions, templates, and scripts.

## Customization

-   **LLM Commands**: Add new `.md` prompt files to `.ai_workflow/commands/` to create custom LLM commands.
-   **PRP Templates**: Modify existing templates or add new ones in `.ai_workflow/PRPs/templates/`."
-   **AI Documentation**: Add project-specific documentation and context for LLMs in `.ai_workflow/PRPs/ai_docs/`.

## Support

If you find value in this project, please consider supporting the original creator:

https://github.com/AnglDavd/AI-WorkFlow

---

Remember: This framework aims for one-pass implementation success through comprehensive context and clear guidance for LLMs.
