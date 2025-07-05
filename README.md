# Gemini AI-Assisted Development Framework

This repository contains a set of structured Markdown files that form a powerful, AI-assisted software development lifecycle framework. It guides an AI agent (like Gemini, Claude, or others) through the entire process of turning an idea into a high-quality, well-architected, and maintainable codebase.

## The Workflow

The framework is built around a 4-step lifecycle:

1.  **Strategy & Architecture (`create-prd.md`):** Define the **WHAT** and **WHY**.
2.  **Planning (`generate-tasks.md`):** Define **HOW** it will be built.
3.  **Execution (`process-task-list.md`):** Establish the **RULES** for building.
4.  **Feedback & Refactoring (`review-and-refactor.md`):** **IMPROVE** what was built.

All workflow files are located in the `.ai_workflow/` directory by default, but you can customize this during setup.

---

## Getting Started: One-Step Setup

To use this framework for your project, you only need to run the interactive setup script.

### 1. Clone the Repository

```bash
git clone [URL_OF_THIS_REPOSITORY] ai-dev-framework
cd ai-dev-framework
```

### 2. Run the Setup Script

Make the script executable and run it:

```bash
chmod +x setup.sh
./setup.sh
```

The script will guide you through:
- Naming your new project.
- Choosing a name for the workflow directory (or keeping the default).
- Creating your project folder.
- Initializing a clean Git repository for you.
- Deleting itself after completion.

### 3. Begin Developing

Once the script is finished, navigate to your new project directory and follow the instructions in the updated `README.md` file to start working with your AI agent.