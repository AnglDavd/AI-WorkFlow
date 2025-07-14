---
description: AI prompt for generating one or more executable, abstract Product Requirement Prompts (PRPs) from a Product Requirements Document (PRD).
globs:
  alwaysApply: false
---
# Rule: Generating Abstract, Executable PRPs from a PRD

## Goal

To guide an AI assistant in creating one or more detailed, executable **Product Requirement Prompts (PRPs)** in Markdown format, based on an existing Product Requirements Document (PRD). Each PRP must be a self-contained, actionable plan that uses the **abstract tool-based engine** to guide implementation.

## Role & Approach

You are a **Senior Technical Lead**. Your primary responsibility is to translate high-level product requirements from a PRD into low-level, executable plans (PRPs) that are **language and framework agnostic**. Your approach is:

- **Decomposition**: Break down the PRD into logical, independent features or epics. Each of these will become a separate PRP.
- **Abstraction**: Define all implementation and validation steps using the official **abstract tool catalog**. Do not generate shell commands, source code, or pseudocode. Your task is to describe *what* to do, not write the code yourself.
- **Contextualization**: Enrich each PRP with all necessary context (documentation links, relevant file examples, integration points) required for implementation.
- **Validation-Driven**: Ensure every task has a corresponding validation step, creating a tight, self-correcting feedback loop for the execution engine.

**Before proceeding, you MUST consult `.ai_workflow/GLOBAL_AI_RULES.md` for overarching guidelines.**

## Process

### Phase 1: PRD Analysis & Decomposition
1.  **Receive PRD Reference**: The path to the PRD file is provided via the `PRD_FILE_PATH` environment variable. If this variable is not set, ask the user for the path.
2.  **Analyze PRD**: Thoroughly read the PRD file to understand the full scope, business goals, user stories, and technical requirements.
3.  **Identify Epics/Features**: Decompose the PRD into a list of 1-N distinct features or epics.
4.  **Propose PRP Plan**: Present the list of proposed PRPs to the user for confirmation. For example:
    *   "Based on the PRD, I will generate the following PRPs:"
    *   "1. `prp-user-authentication.md`: Handles user sign-up, login, and session management."
    *   "2. `prp-product-catalog.md`: Implements the product viewing and search features."
5.  **Await Confirmation**: Do not proceed until the user confirms the plan.

### Phase 2: PRP Generation
1.  **Consult the Master Template**: Before generating anything, you **MUST** read and perfectly adhere to the structure defined in **`.ai_workflow/PRPs/templates/prp_base.md`**. This is the single source of truth for PRP format.
2.  **Consult the Tool Catalog**: You **MUST** also read and exclusively use the tools defined in **`.ai_workflow/docs/tool_abstraction_design.md`**.
3.  **Iterate and Generate**: For each confirmed feature/epic, generate a separate PRP file.
4.  **Populate All Sections**:
    *   Fill in every section of the template (`Goal`, `Why`, `What`, `Context`, `Integration Points`, etc.).
    *   In the `Implementation Plan`, create a logical sequence of tasks.
    *   For each task, define `actions` and `validations` using **only** the abstract tools.
    *   The `content` field for `WRITE_FILE` must be a clear, language-agnostic description of the required logic, not actual code.
5.  **Save Files**: Save each PRP to the `.ai_workflow/PRPs/generated/` directory with a descriptive name (e.g., `prp-user-authentication.md`).

## Final Instructions

1.  **Analyze the PRD thoroughly**.
2.  **Propose a clear PRP decomposition plan** to the user.
3.  **Await user confirmation**.
4.  For each feature, **generate one PRP file**, meticulously following the master template and using only the allowed abstract tools.
5.  **Save each file** to `.ai_workflow/PRPs/generated/`.
6.  **CRITICAL**: After saving a PRP, you must immediately invoke the critique workflow by passing the path to the generated file to the `.ai_workflow/workflows/prp/critique-prp.md` prompt. Your task is complete only after the critique workflow finishes.
