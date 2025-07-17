# AGENT_GUIDE.md

This file provides guidance to the AI agent when working with code in this repository.

## Project Nature

This is an **AI-Assisted Development Framework** repository - a comprehensive system that enables AI agents to build production-ready software through structured workflows and templates. The core concept: **"PRP = PRD + curated codebase intelligence + agent/runbook"** - designed to enable AI agents to ship production-ready code on the first pass.

## Framework Version Status

**Current Version:** v0.4.2-beta (Beta Phase with Advanced Features)
**Key Features:** 
- ✅ Complete Alpha v0.3.0 core functionality
- ✅ Automatic quality validation with adaptive language support
- ✅ Pre-commit system with background validation
- ✅ Zero-friction automation philosophy
- ✅ Multi-language project compatibility (30+ languages)
- ✅ Comprehensive CLI integration
- ✅ Enhanced CLI system with production-ready UX
- ✅ External feedback integration and community synchronization
- ✅ Framework-level task management

## Core Architecture

### Command-Driven System

**📋 For complete architectural overview, see [ARCHITECTURE.md - System Overview](ARCHITECTURE.md#1-system-overview)**

The framework operates through a unified CLI interface:
- **Main Entry Point**: `ai-dev` script - provides user-friendly access to all workflows
- **Core Commands** (see [CLI Command Registry](ARCHITECTURE.md#command-registry) for complete reference):
  - `setup` - Initialize project setup
  - `generate <prd_file>` - Generate tasks from PRD
  - `run <prp_file>` - Execute Project Response Plans
  - `quality <path>` - Run quality validation with adaptive language support
  - `audit` - Run security audit
  - `precommit` - Pre-commit validation and quality assurance
  - `sync <subcommand>` - Framework synchronization and external feedback
    - `sync feedback` - Integrate community feedback from GitHub
    - `sync framework` - Synchronize framework updates (planned)
  - `configure` - Interactive configuration management
  - `diagnose` - Framework health and diagnostic reporting

### Template-Based Methodology

- **PRP Templates** in `PRPs/templates/` follow a structured format with validation loops.
- **Context-Rich Approach**: Every PRP must include comprehensive documentation, examples, and gotchas.
- **Validation-First Design**: Each PRP contains executable validation gates (syntax, tests, integration).

### AI Documentation Curation

- `.ai_workflow/PRPs/ai_docs/` contains curated documentation for context injection.
- `.ai_workflow/agent_guide_examples/` provides framework-specific `AGENT_GUIDE.md` examples.

## Development Commands

### PRP Creation

```bash
# Use the dedicated script to create new PRPs
./manager.sh new-prp
```

### PRP Execution

```bash
# Use the unified runner script
./manager.sh run --prp <path_to_prp_file> [--model <agent_cli>] [--interactive]
```

### Key Agent Commands

The commands are stored in `.ai_workflow/commands/`. They are designed to be executed by an AI agent.
- `execute-base-prp` - Execute PRPs against the codebase.
- `planning-create` - Create planning documents.
- `spec-execute` - Execute specifications.
- `task-execute` - Execute task lists.
- `prime-core` - Prime the AI with project context.
- `review-staged-unstaged` - Review git changes using the PRP methodology.

## Core Principles

1.  **Context is King**: Include ALL necessary documentation, examples, and caveats.
2.  **Validation Loops**: Provide executable tests/lints the AI can run and fix.
3.  **Information Dense**: Use keywords and patterns from the codebase.
4.  **Progressive Success**: Start simple, validate, then enhance.
5.  **Resilient Testing**: When tests fail, attempt initial diagnosis and auto-correction before escalating. Do not halt development unless explicitly instructed or all recovery options are exhausted.
6.  **Privacy & Data Handling**: When generating external output (e.g., GitHub issues, reports), ensure that **NO project-specific code, sensitive data, or private information is ever included**. All external communication must strictly adhere to framework-related feedback only.
7.  **Zero-Friction Automation**: Every system should work through seamless automation with minimal user intervention. Convert manual processes to automatic background operations.
8.  **Adaptive Language Support**: Framework must intelligently adapt to any programming language or technology stack without manual configuration.

### PRP Structure Requirements

- **Goal**: Specific end state and desires.
- **Why**: Business value and user impact.
- **What**: User-visible behavior and technical requirements.
- **All Needed Context**: Documentation URLs, code examples, gotchas, and patterns.
- **Implementation Blueprint**: Pseudocode with critical details and task lists.
- **Validation Loop**: Executable commands for syntax, tests, and integration.

### Validation Gates (Must be Executable)

```bash
# Level 1: Syntax & Style (Example for Python - adjust for your language)
ruff check --fix && mypy .

# Level 2: Unit Tests (Example for Python - adjust for your language)
pytest tests/ -v

# Level 3: Integration (Example for Python - adjust for your language)
curl -X POST http://localhost:8000/endpoint -H "Content-Type: application/json" -d '{...}'
```

## Anti-Patterns to Avoid

- ❌ Don't create minimal context prompts - context is everything.
- ❌ Don't skip validation steps - they're critical for one-pass success.
- ❌ Don't ignore the structured PRP format - it's battle-tested.
- ❌ Don't create new patterns when existing templates work.
- ❌ Don't hardcode values that should be config.
- ❌ Don't catch all exceptions - be specific.

## Working with This Framework

### When Creating PRPs

1.  **Use `manager.sh new-prp`**: This script will guide you through the process.
2.  **Research First**: Analyze codebase patterns and external documentation.
3.  **Use Templates**: The script uses `.ai_workflow/PRPs/templates/prp_base.md`.
4.  **Include Context**: The AI agent will fill this based on its capabilities.
5.  **Validate Early**: The generated PRP will include validation steps.

### When Executing PRPs

1.  **Load PRP**: Read and understand all context and requirements.
2.  **Plan Thoroughly**: Create a comprehensive plan, breaking it down into smaller steps.
3.  **Execute**: Implement following the blueprint.
4.  **Validate**: Run each validation command, fix failures.
5.  **Complete**: Ensure all checklist items are done.

## Project Structure Understanding

```
project-name/
├── .ai_workflow/
│   ├── commands/           # AI agent commands
│   ├── PRPs/
│   │   ├── templates/      # PRP templates with validation
│   │   └── ai_docs/        # Curated AI documentation
│   ├── agent_guide_examples/ # Framework-specific AGENT_GUIDE.md examples
│   └── AGENT_GUIDE.md      # This file
├── manager.sh              # Unified script for managing the framework
└── ... (rest of your project files)
```

Remember: This framework is about **one-pass implementation success through comprehensive context**. Every PRP should contain enough context for an AI agent to implement working code without additional research.