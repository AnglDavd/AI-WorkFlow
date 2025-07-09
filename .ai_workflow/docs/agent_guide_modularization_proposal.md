# Agent Guide Modularization Proposal

## 1. Introduction

This proposal outlines a strategy for modularizing the content within the `.ai_workflow/agent_guide_examples/` directory. Currently, each file (e.g., `ASTRO.md`, `JAVA-GRADLE.md`) contains a comprehensive guide for a specific technology stack. While effective, this monolithic approach can lead to redundancy and make it challenging for agents to selectively inject relevant context without including irrelevant information.

## 2. Current State Analysis

Each existing guide typically covers a broad range of topics, including:
- Core Development Philosophy
- AI Assistant Guidelines
- Code Structure & Modularity
- Key Features (framework-specific)
- Configuration (e.g., TypeScript, Maven, Gradle)
- Package Management & Dependencies
- Data Validation
- Testing Strategy
- Component Guidelines
- State Management
- Security Requirements
- Performance Guidelines
- Code Style & Quality
- Pre-commit Checklist
- Critical Guidelines

Many of these sections contain patterns and best practices that are common across different technologies (e.g., general code style, testing principles, security basics) or are specific to a broader category (e.g., frontend, backend, JavaScript ecosystem).

## 3. Proposed Modular Structure

We propose breaking down these comprehensive guides into smaller, thematic `.md` modules. These modules would reside in a new directory, e.g., `.ai_workflow/agent_guide_modules/`, organized by category.

### Proposed Directory Structure:

```
.ai_workflow/
├── agent_guide_examples/  # Existing full guides (will become composed from modules)
│   ├── ASTRO.md
│   ├── JAVA-GRADLE.md
│   └── ...
├── agent_guide_modules/   # New directory for reusable modules
│   ├── core_principles/   # General development philosophy
│   │   ├── kiss_yagni.md
│   │   └── design_principles.md
│   ├── ai_guidelines/     # General AI assistant directives
│   │   ├── context_awareness.md
│   │   └── workflow_patterns.md
│   ├── language_specific/ # Language-specific conventions
│   │   ├── java_conventions.md
│   │   ├── python_conventions.md
│   │   └── typescript_conventions.md
│   ├── framework_specific/ # Framework-specific features/configs
│   │   ├── astro_features.md
│   │   ├── nextjs_features.md
│   │   └── react_features.md
│   ├── build_tools/       # Build tool configurations/commands
│   │   ├── gradle_config.md
│   │   ├── maven_config.md
│   │   └── npm_scripts.md
│   ├── testing_patterns/  # General testing strategies
│   │   ├── unit_testing.md
│   │   ├── integration_testing.md
│   │   └── test_coverage.md
│   ├── security_patterns/ # General security best practices
│   │   ├── input_validation.md
│   │   └── env_vars.md
│   └── ... (other thematic categories)
```

## 4. Examples of Composition

Instead of a single large `.md` file, a technology-specific guide (e.g., `ASTRO.md`) would become a composition of these modules. An agent would be instructed to read and combine relevant modules based on the context of the task.

### Example: Composing `ASTRO.md`

An agent needing context for an Astro project would be instructed to read:

-   `.ai_workflow/agent_guide_modules/core_principles/kiss_yagni.md`
-   `.ai_workflow/agent_guide_modules/ai_guidelines/context_awareness.md`
-   `.ai_workflow/agent_guide_modules/framework_specific/astro_features.md`
-   `.ai_workflow/agent_guide_modules/build_tools/npm_scripts.md` (if using npm)
-   `.ai_workflow/agent_guide_modules/testing_patterns/vitest_config.md` (if using Vitest)
-   And so on, for other relevant sections.

This composition could be managed by a higher-level prompt or a new workflow node that takes the desired technology stack as input and returns a list of `.md` files to read.

## 5. Benefits

-   **Increased Flexibility:** Agents can dynamically compose context relevant to a specific task, avoiding the injection of irrelevant information (e.g., a backend agent doesn't need frontend component guidelines).
-   **Reduced Redundancy:** Common patterns and principles are defined once and reused across multiple technology guides.
-   **Easier Maintenance:** Updates to a specific pattern (e.g., a new security best practice) only need to be made in one modular file.
-   **Improved Contextualization:** Agents can be more precise in the context they provide to LLMs, potentially leading to better responses and token economy.
-   **Scalability:** Easier to add new language/framework guides by composing existing modules and creating only the truly unique ones.

## 6. Challenges and Considerations

-   **Initial Refactoring Effort:** Significant manual effort will be required to break down existing guides into modules.
-   **Module Granularity:** Determining the optimal granularity for modules to maximize reusability without making them too fragmented.
-   **Composition Logic:** Developing clear instructions or a mechanism for agents to correctly identify and compose the necessary modules for a given task.
-   **Version Control:** Managing changes across many small files.

## 7. Future Work

-   Implement a prototype of the modularization for one or two existing guides.
-   Develop a workflow node that assists agents in composing context from these modules.
-   Explore automated tools for extracting and categorizing content into modules.
