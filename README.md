# 🚀 AI-Assisted Development Framework 🚀

Welcome to the AI-Assisted Development Framework! This project provides a structured approach to building software with the help of advanced AI agents. It's designed to streamline your development workflow from ideation to code implementation and continuous improvement.

## ✨ Key Features

-   **Dynamic Project Manager (DPM):** The framework's core is now driven by a transparent, auditable, and self-improving system based on `.md` workflow nodes. This replaces traditional scripts with human-readable, agent-executable manifests.
-   **Model-Agnostic Prompts:** Prompts designed to work effectively with various AI models (e.g., Gemini, Claude, OpenAI).
-   **Structured PRD & PRP Creation:** Tools to generate detailed Product Requirements Documents (PRDs) and Product Requirement Prompts (PRPs).
-   **Automated Task Execution:** AI agents can execute granular tasks, write code, and perform validations.
-   **Continuous Quality:** Integrated commands for code review, refactoring, and Git operations.
-   **Framework Feedback Loop:** Automated suggestions to provide feedback on the framework's performance and generate GitHub issues, ensuring continuous improvement while respecting project privacy.
-   **Clear Guidance:** Comprehensive documentation (`.ai_workflow/FRAMEWORK_GUIDE.md`) to guide you through every step.

## 🛠️ How to Use the Dynamic Project Manager (DPM)

The DPM operates through a series of interconnected Markdown files, making the entire workflow transparent and auditable.

**To start any workflow or get help, simply read the main `manager.md` file:**

```bash
cat manager.md
```

This file acts as your central hub, listing all available workflows. Each workflow is a sequence of `.md` nodes. To execute a workflow, you (or an AI agent) will:
1.  Read the current `.md` node.
2.  Understand its `Objective` and `Commands`.
3.  Execute the `Commands` block in your terminal.
4.  Based on the `Next Steps` section, navigate to the next `.md` node (e.g., `cat ./.ai_workflow/workflows/setup/01_start_setup.md`).

This approach provides unparalleled flexibility, allowing you to pause, inspect, modify, or even skip steps as needed.

## 🚀 Getting Started

To set up a new project using this framework, begin by reading the `manager.md` and following the "Project Setup" workflow:

```bash
cat manager.md
```

Then, navigate to the first step of the setup workflow:

```bash
cat ./.ai_workflow/workflows/setup/01_start_setup.md
```

Follow the instructions within each `.md` file to proceed.

## 📚 Documentation

-   **`manager.md`**: The main entry point and map of all available workflows.
-   **`.ai_workflow/FRAMEWORK_GUIDE.md`**: The main guide explaining the framework's philosophy, workflows, and component usage.
-   **`.ai_workflow/AGENT_GUIDE.md`**: Guidelines and best practices for AI agents working within this repository.

## 🤝 Contributing

We welcome contributions to improve this framework! Please refer to the `FRAMEWORK_GUIDE.md` for insights into the project's structure and principles before contributing.

## 📄 License

This project is licensed under the MIT License.

---

_Happy AI-Assisted Coding!_ ✨
