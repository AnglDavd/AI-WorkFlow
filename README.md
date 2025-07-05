# AI-Assisted Development Framework ✨

This repository provides a powerful, AI-assisted software development lifecycle framework. It's designed to guide any large language model (LLM) agent through the entire process of transforming a high-level idea into a high-quality, well-architected, and maintainable codebase. 🚀

## Why Use This Framework? 🤔

Developing with AI agents can be challenging due to their stateless nature and the need for precise instructions. This framework solves these problems by:

-   **Structuring the Development Process:** Breaking down complex tasks into manageable, guided steps. 🗺️
-   **Ensuring Best Practices:** Enforcing industry-standard methodologies for PRD creation, task planning, code execution, and quality assurance. ✅
-   **Maintaining Control & Safety:** Implementing strict protocols for code changes, error handling, and secret management. 🔒
-   **Promoting Continuous Improvement:** Integrating a feedback loop for identifying and addressing technical debt. ♻️
-   **Automated Refactoring Reminders:** The AI agent will proactively suggest code review and refactoring cycles after a set number of completed tasks, ensuring continuous quality improvement. 🔔
-   **Being Agent-Agnostic:** Designed to work with any capable LLM agent (Gemini, Claude, GPT-4, etc.). 🤖
-   **Token Efficiency:** Workflow files now include explicit instructions for AI agents to be mindful of token usage, prioritize concise communication, and summarize large outputs when appropriate. 💰

### Recommended Tools for Optimal AI Interaction 🛠️

For the best experience and to maximize the AI agent's effectiveness, we highly recommend using Multi-Context Processing (MCP) tools and strategies. These help manage the large context windows required for the AI to understand the entire project, multiple files, and long conversations.

-   **Context7 (Recommended):** A powerful tool designed specifically for managing and providing context to LLMs. It allows you to easily feed multiple files, previous conversations, and specific instructions to your AI agent. 🧠
-   **GitMCP.io:** Consider using services like GitMCP.io to convert your entire Git repository into an MCP-friendly format, making it easier for LLMs to consume the codebase context. 📦
-   **Local Context Management Tools:** Explore other open-source or commercial tools that allow you to load and manage large amounts of text/code for your LLM locally. Examples include custom scripts, specialized IDE extensions, or dedicated context managers. 💻
-   **Strategic File Selection:** When interacting with your AI, explicitly guide it to read only the most relevant files for the current task. Avoid sending the entire codebase unless absolutely necessary (e.g., during a full refactoring review). 🎯
-   **Summarization Techniques:** Instruct your AI to summarize large code blocks, logs, or documentation before sending them back to you or processing them further, to save tokens. 📝

---

## The Core Workflow: A 4-Step Lifecycle 🔄

The framework operates as a continuous loop, guiding your AI agent through distinct phases:

1.  **Strategy & Architecture (The "WHAT" and "WHY")** 🎯
2.  **Planning (The "HOW")** 📝
3.  **Execution (The "BUILD")** 🏗️
4.  **Feedback & Refactoring (The "IMPROVE")** ✨

Each phase is driven by a dedicated Markdown file, acting as a detailed prompt for your AI agent.

### Workflow Files Explained 📂

Each Markdown file in the workflow directory serves a specific purpose and guides the AI agent through a particular phase of development:

-   **`.ai_workflow/GLOBAL_AI_RULES.md`**: This file contains the **overarching rules and behavioral guidelines** that the AI agent must adhere to in ALL interactions and phases of the development workflow. It ensures consistent behavior, communication style, and adherence to general best practices.

-   **`.ai_workflow/_project.md`**: The central dashboard for your project. It tracks the project's status and links to the current PRD and Task List. This is where you'll typically start when resuming work on a project. 📊

-   **`.ai_workflow/create-prd.md`**: Guides the AI agent to act as a **Senior Technical Product Manager** and **Solution Architect**. It helps define the project's vision, goals, functional and non-functional requirements, data model, technology stack, and UI/UX design system. It's designed to extract all necessary information to create a comprehensive Product Requirements Document (PRD). 💡

-   **`.ai_workflow/generate-tasks.md`**: Guides the AI agent to act as a **Senior Technical Lead**. It takes the completed PRD and translates it into a detailed, actionable list of engineering tasks. It includes specific instructions for setting up the environment, implementing features, testing, and deployment, ensuring traceability back to the PRD's requirements. 📋

-   **`.ai_workflow/process-task-list.md`**: The operational manual for the AI agent acting as a **Developer**. It defines strict protocols for task execution, including atomic commits, error handling (test failures, setup failures), managing secrets, handling blockers, and dynamically adding new tasks. This ensures safe, controlled, and verifiable code delivery. 👷

-   **`.ai_workflow/review-and-refactor.md`**: Guides the AI agent to act as a **Senior Software Architect**. It enables the AI to analyze the existing codebase for technical debt, code smells, and anti-patterns. It then proposes concrete refactoring tasks, initiating a continuous improvement cycle for code quality and maintainability. 🔍

---

## Getting Started: Your One-Step Project Setup 🚀

To use this framework for a new project, simply clone this repository and run the `setup.sh` script. It will handle all the initial configuration for you.

### Step 1: Clone the Framework Repository

Open your terminal and run:

```bash
git clone [URL_OF_THIS_REPOSITORY] my-new-project-name
cd my-new-project-name
```

Replace `[URL_OF_THIS_REPOSITORY]` with the actual URL of this GitHub repository (e.g., `https://github.com/AnglDavd/AI-WorkFlow.git`).

### Step 2: Run the Interactive Setup Script

Make the script executable and run it:

```bash
chmod +x setup.sh
./setup.sh
```

This interactive script will:

-   Prompt you for your new project's name. ✍️
-   Allow you to customize the name of the workflow directory (default: `.ai_workflow`). ⚙️
-   Create your project folder and move all framework files into it. 📁
-   Initialize a clean Git repository for your new project. ✨
-   Update all configuration files (like `.gitignore` and `README.md`) to reflect your choices. 📝
-   Delete itself after completion. 🗑️

### Step 3: Navigate to Your New Project

After the script finishes, it will tell you to navigate to your newly created project directory. For example:

```bash
cd ../my-new-project-name
```

Your project is now set up and ready to go! 🎉

---

## Using the Framework: A Step-by-Step Guide 🧭

Now that your project is configured, you can start guiding your AI agent through the development process. All workflow files are located in the directory you chose during setup (default: `.ai_workflow/`).

### Phase 1: Strategy & Architecture (The "WHAT" and "WHY") 🎯

**Goal:** Define the project's vision, scope, and technical foundation.

**File:** `.ai_workflow/create-prd.md`

**How to Use:**

1.  **Start the Conversation:** Tell your AI agent:
    > "Let's start a new project. Please use the guide in `.ai_workflow/create-prd.md` to help me define the product requirements document (PRD)." 🗣️
2.  **Interact with the AI:** The AI, acting as a Senior Technical Product Manager and Solution Architect, will ask you a series of structured questions about:
    -   The business problem and goals. 📈
    -   Target users and market context. 🧑‍💻
    -   **Technology Stack:** It will guide you through selecting the project archetype (Full-Stack, Backend, Frontend) and recommend popular, robust technology stacks (e.g., Next.js, FastAPI, PostgreSQL, Redis). 💻
    -   **UI/UX Design System:** It will offer you a choice between an opinionated default (like ShadCN/UI for developers) or a custom, fine-grained design definition. 🎨
    -   Non-functional requirements (performance, security, scalability). ⚡
    -   Data modeling (primary entities, attributes, relationships). 🗄️
3.  **Output:** The AI will generate a comprehensive PRD in Markdown format (e.g., `prd-my-feature.md`) in your project's root directory. 📄

**What You Achieve:** A clear, unambiguous blueprint for your project, ensuring all stakeholders are aligned before development begins. ✅

### Phase 2: Planning (The "HOW") 📝

**Goal:** Translate the PRD into a detailed, actionable list of engineering tasks.

**File:** `.ai_workflow/generate-tasks.md`

**How to Use:**

1.  **Point to the PRD:** Tell your AI agent:
    > "Now that we have the PRD, please use `.ai_workflow/generate-tasks.md` to create a detailed task list from `prd-my-feature.md`." 🗣️
2.  **AI Analysis:** The AI, acting as a Senior Technical Lead, will analyze the PRD, extract all requirements, and propose a high-level task breakdown. 🧠
3.  **Confirm & Generate:** Confirm the high-level plan, and the AI will generate a comprehensive task list in Markdown format (e.g., `tasks-my-feature.md`) in your project's root directory. 📋
    -   Tasks will include specific setup steps, feature implementation, testing, documentation, and deployment considerations. 🛠️
    -   Tasks will have complexity estimates (S/M/L/XL) and explicit dependencies. 🔗
    -   Tasks will be traceable back to the PRD's functional requirements (e.g., `Fulfills: FR-1`). 🔍

**What You Achieve:** A clear roadmap for development, breaking down the project into manageable, executable steps. ✅

### Phase 3: Execution (The "BUILD") 🏗️

**Goal:** Implement the tasks defined in the task list, producing the actual code.

**File:** `.ai_workflow/process-task-list.md`

**How to Use:**

1.  **Start Execution:** Tell your AI agent:
    > "Okay, let's start working on the tasks. Please use `.ai_workflow/process-task-list.md` to guide you through `tasks-my-feature.md`." 🗣️
2.  **AI as Developer:** The AI will act as a Developer, picking the next available task. 👷
3.  **Interactive & Controlled:**
    -   The AI will implement **one sub-task at a time**. ➡️
    -   After each sub-task, it will report its progress and **wait for your explicit approval** before proceeding. 👍
    -   It will perform **atomic Git commits** for each completed sub-task. 💾
    -   **Error Handling:** If tests fail or setup encounters issues, the AI will revert changes, report the error, and await your instructions. 🐞
    -   **Secret Management:** The AI is strictly instructed to never hardcode secrets and to use environment variables. 🔑
    -   **Blocker Protocol:** If the AI encounters ambiguity or a blocker, it will stop, explain the issue, and propose solutions. 🛑
    -   **Dynamic Task Management:** It can propose new tasks if discovered during implementation. ➕

**What You Achieve:** A high-quality codebase built incrementally, with full control over each step, ensuring safety and stability. ✅

### Phase 4: Feedback & Refactoring (The "IMPROVE") ✨

**Goal:** Continuously improve the codebase by identifying and addressing technical debt and anti-patterns.

**File:** `.ai_workflow/review-and-refactor.md`

**How to Use:**

1.  **Initiate Review:** Once a significant feature or module is complete, tell your AI agent:
    > "Please use `.ai_workflow/review-and-refactor.md` to analyze the codebase (or a specific module like `src/auth/`) for refactoring opportunities." 🗣️
    *The AI agent will also proactively suggest a refactoring cycle after a set number of completed tasks, as defined in `process-task-list.md`.*
2.  **AI as Architect:** The AI, acting as a Senior Software Architect, will analyze the code for:
    -   Complexity and readability issues. 📏
    -   Violations of SOLID principles. 📐
    -   Code duplication. 👯
    -   Performance bottlenecks. ⚡
3.  **Report & Propose:** The AI will generate a structured report of its findings and propose concrete refactoring tasks. 📄
4.  **Approve Refactoring:** You can then approve these refactoring tasks, and the AI will add them to your main task list (`tasks-my-feature.md`) for future implementation. ✅

**What You Achieve:** A codebase that actively fights technical debt, remains clean, maintainable, and performs optimally over time. 🏆

---

## Adding New Features to Existing Projects 🧩

This framework is not just for starting projects from scratch! It's also incredibly powerful for adding new features to an existing codebase. The core workflow remains the same, but with a few key adaptations.

### Why Use This Framework for Existing Projects?

-   **Structured Feature Development:** Ensures new features are well-defined, planned, and implemented following best practices.
-   **Seamless Integration:** Helps the AI understand and work within your existing project's conventions and architecture.
-   **Controlled Changes:** Maintains the safety and quality of your established codebase.

### Key Differences from Starting a New Project

-   **No `setup.sh`:** You **do not** run `setup.sh`. This script is only for initializing new repositories.
-   **Existing Codebase:** Your project already has code, dependencies, and a Git history.
-   **Context is King:** Providing the AI with context about your existing project is crucial.

### Step-by-Step Guide for Existing Projects

#### Step 1: Integrate the Framework Files 📂

1.  **Copy the Workflow Folder:** Copy the entire `.ai_workflow/` folder from a fresh clone of this repository into the root of your existing project.
    ```bash
    # Example (assuming you cloned this repo to ~/ai-dev-framework)
    cp -r ~/ai-dev-framework/.ai_workflow/ /path/to/your/existing-project/
    ```
2.  **Update `.gitignore`:** Add the `.ai_workflow/` folder to your existing project's `.gitignore` file. This prevents the framework's internal files from being committed to your project's main repository.
    ```gitignore
    # .gitignore (in your existing project)
    
    # ... other existing ignores ...
    
    # AI Workflow Framework files
    .ai_workflow/
    ```
3.  **Optional: Copy `_project.md`:** If you want to use the central dashboard, copy `_project.md` to your project's root and update its links.

#### Step 2: Provide Initial Context to Your AI Agent 🧠

Before starting Phase 1 for your new feature, give your AI agent an overview of your existing project. This is vital for junior developers, as it helps the AI understand the environment.

> "I want to add a new feature to an existing project. Here's some context about it:
> -   **Project Name:** [Your Project Name]
> -   **Main Goal:** [Briefly describe what the project does]
> -   **Primary Technology Stack:** [e.g., React, Node.js, Express, PostgreSQL]
> -   **Key Directories:** [e.g., `src/`, `backend/`, `frontend/`, `database/`]
> -   **Coding Conventions:** [e.g., ESLint rules, Prettier, TypeScript, specific naming conventions]
> -   **Existing Database:** [e.g., PostgreSQL, MongoDB, no database]
> -   **Existing APIs:** [e.g., REST, GraphQL, internal, external]
> 
> Now, let's define the new feature using `.ai_workflow/create-prd.md`."

#### Step 3: Adapt the Workflow Phases for a New Feature 🔄

Once the framework files are integrated and the AI has context, you follow the same 4-phase workflow, but with a feature-specific focus:

-   **Phase 1: Strategy & Architecture (`create-prd.md`)**
    -   **Focus:** Define the **WHAT** and **WHY** for the *new feature only*. The PRD will be much shorter and focused.
    -   **Tech Stack:** When asked about the technology stack, emphasize how the new feature will integrate with or extend the *existing* stack. Only propose new technologies if the feature absolutely requires them.
    -   **Data Model:** Define only the new data entities or changes to existing ones required by the feature.

-   **Phase 2: Planning (`generate-tasks.md`)**
    -   **Focus:** Generate tasks specifically for implementing the *new feature*. 
    -   **Setup Tasks:** Tasks related to environment setup (e.g., `npx create-next-app`) will likely be skipped or adapted to installing new feature-specific dependencies.
    -   **Scaffolding:** The AI will generate basic code for new UI components or data models relevant to the feature, fitting them into your existing project structure.

-   **Phase 3: Execution (`process-task-list.md`)**
    -   **Focus:** Implement the feature's tasks. This phase is largely identical to new project development.
    -   **Context:** The AI will use its tools to read existing files as needed to ensure the new code integrates seamlessly.

-   **Phase 4: Feedback & Refactoring (`review-and-refactor.md`)**
    -   **Focus:** Review the *newly added code* for the feature, or a specific module it touches. You can instruct the AI to limit its review scope.
    -   **Proactive Reminders:** The automated refactoring reminders will still function, prompting you to review the code quality of the new feature.

**What You Achieve:** A new feature seamlessly integrated into your existing project, developed with the same high standards and structured approach as a greenfield project. ✅

---

### Phase 4: Feedback & Refactoring (The "IMPROVE") ✨

**Goal:** Continuously improve the codebase by identifying and addressing technical debt and anti-patterns.

**File:** `.ai_workflow/review-and-refactor.md`

**How to Use:**

1.  **Initiate Review:** Once a significant feature or module is complete, tell your AI agent:
    > "Please use `.ai_workflow/review-and-refactor.md` to analyze the codebase (or a specific module like `src/auth/`) for refactoring opportunities." 🗣️
    *The AI agent will also proactively suggest a refactoring cycle after a set number of completed tasks, as defined in `process-task-list.md`.*
2.  **AI as Architect:** The AI, acting as a Senior Software Architect, will analyze the code for:
    -   Complexity and readability issues. 📏
    -   Violations of SOLID principles. 📐
    -   Code duplication. 👯
    -   Performance bottlenecks. ⚡
3.  **Report & Propose:** The AI will generate a structured report of its findings and propose concrete refactoring tasks. 📄
4.  **Approve Refactoring:** You can then approve these refactoring tasks, and the AI will add them to your main task list (`tasks-my-feature.md`) for future implementation. ✅

**What You Achieve:** A codebase that actively fights technical debt, remains clean, maintainable, and performs optimally over time. 🏆

---

## Project Reporting & Feedback 📊

This framework automatically generates reports to help you track progress and provide valuable feedback for the framework's continuous improvement.

### Progress Report (`progress_report.md`) 📈

This file, located in your project's root, is automatically updated by the AI agent after every sub-task completion. It provides a real-time overview of your project's development status.

**Contents:**
-   A visual progress bar (with emojis! 🎉).
-   Total, completed, and pending task counts.
-   Details of the current task in progress.
-   A comprehensive list of all tasks (pending and completed).

**How to View:**
-   You can simply open `progress_report.md` in any Markdown viewer (like VS Code's built-in preview).
-   For a more interactive web-based visualization, you can use online Markdown to HTML converters or simple local scripts (e.g., a basic Python script using `markdown` and `webbrowser` libraries).

### Framework Feedback Summary (`feedback_summary.md`) 🗣️

This file is generated automatically by the AI agent when you mark your project's status as `Completed` in `_project.md`. It's crucial for the continuous improvement of this framework.

**Contents:**
-   The AI agent's self-reflection on its experience using the framework for your project (strengths, challenges, suggestions).
-   A structured section for *your* qualitative feedback (overall satisfaction, clarity, effectiveness, missing features, general comments).

**How to Submit Your Feedback:**

Your feedback is invaluable! Please consider sharing the content of your `feedback_summary.md` file (or the file itself) with the framework maintainers via:

-   **Twitter:** Mention @angldavd
-   **GitHub:** Open an issue or a pull request in the repository: https://github.com/AnglDavd/AI-WorkFlow

---

## Contributing 🤝

Contributions are welcome! If you have ideas for improving the framework, please open an issue or submit a pull request.

## License 📜

This project is licensed under the MIT License - see the LICENSE file for details.