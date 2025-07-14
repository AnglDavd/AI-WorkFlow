# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an **AI-Assisted Development Framework** - a sophisticated system that enables AI agents to build production-ready software through structured workflows and templates. The framework uses a **PRP (Product Requirement Prompt) methodology** where **PRP = PRD + curated codebase intelligence + agent/runbook**.

## Core Architecture

### Command-Driven System
The framework operates through a unified CLI interface:
- **Main Entry Point**: `ai-dev` script - provides user-friendly access to all workflows
- **Natural Language Integration**: Instructions in `manager.md` guide AI agents to interpret natural language requests

### Key Commands
```bash
# Primary workflow commands
./ai-dev setup                    # Initialize project setup
./ai-dev generate <prd_file>      # Generate tasks from PRD
./ai-dev run <prp_file>           # Execute Project Response Plans
./ai-dev optimize <prompt_file>   # Optimize prompt files
./ai-dev help                     # Show all available commands
```

### Directory Structure
```
.ai_workflow/
├── GLOBAL_AI_RULES.md           # Core behavioral guidelines (supersedes all other rules)
├── AGENT_GUIDE.md               # AI agent operational guidelines
├── FRAMEWORK_GUIDE.md           # Comprehensive framework documentation
├── workflows/                   # Core execution workflows
│   ├── setup/                   # Project initialization (01-05 sequence)
│   ├── prd/                     # Product Requirements Document workflows
│   ├── prp/                     # Project Response Plan workflows
│   ├── run/                     # PRP execution engine
│   └── common/                  # Shared utilities and error handling
├── commands/                    # Specialized AI agent commands
│   ├── PRPs/                    # PRP creation and execution
│   ├── development/             # Core dev utilities (onboarding, debugging)
│   ├── code-quality/            # Review and refactoring commands
│   └── git-operations/          # Git conflict resolution
├── PRPs/
│   ├── templates/               # PRP templates (prp_base.md is primary)
│   └── ai_docs/                 # Curated documentation for AI context
└── tools/                       # Tool abstraction layer with adapters
```

## Framework Philosophy

### Core Principles
1. **Transparency**: All logic is defined in readable `.md` workflow files
2. **User Control**: System proposes, user approves critical changes
3. **Validation-First**: Every workflow includes executable validation gates
4. **Context-Rich**: Comprehensive documentation and examples in every PRP
5. **Tool Abstraction**: Abstract tools decouple AI from specific environments

### AI Agent Behavioral Guidelines
- **Follow GLOBAL_AI_RULES.md**: Core principles supersede all other instructions
- **Think Hard for Critical Changes**: Explicitly articulate internal plan and reasoning
- **Token Economy Optimization**: Actively seek and implement token efficiency
- **Loop Prevention**: Detect and break repetitive patterns, escalate when stuck
- **Privacy First**: Never include project-specific code in external communications

## Development Workflow

### Standard Development Process
1. **PRD Creation** → **Task Breakdown** → **Implementation** → **Review & Refactor**
2. Use `_ai_knowledge.md` for persistent pattern storage
3. Consult `examples/` directory for code patterns and style conventions
4. Maintain atomic commits with clear, single-purpose changes

### PRP (Project Response Plan) Structure
Every PRP must include:
- **Goal**: Specific end state and desires
- **Why**: Business value and user impact  
- **What**: User-visible behavior and technical requirements
- **All Needed Context**: Documentation URLs, code examples, gotchas
- **Implementation Blueprint**: Pseudocode with critical details
- **Validation Loop**: Executable commands for syntax, tests, integration

### Tool Abstraction Layer
The framework uses abstract tools that adapt to different environments:
- **Action Tools**: WRITE_FILE, REPLACE_IN_FILE, DELETE_FILE
- **Validation Tools**: FILE_EXISTS, LINT_FILE, RUN_TESTS, RUN_TYPE_CHECK
- **Integration Tools**: HTTP_REQUEST for API testing

## Common Patterns

### Workflow Initiation
AI agents should interpret natural language requests:
- "start the project" → Execute `./ai-dev setup`
- "create a PRD" → Execute PRD creation workflow
- "run this plan" → Execute `./ai-dev run <prp_file>`

### Error Handling
- **Resilient Testing**: Attempt diagnosis and auto-correction before escalating
- **Contextual Error Reporting**: Provide context for abstract tool failures
- **Graceful Degradation**: Suggest adapter refinement when tools fail

### Quality Assurance
- Always run validation commands after implementation
- Use structured templates for consistency
- Include comprehensive context in all PRPs
- Test early and often with executable validation gates

## Framework Features

### Token Economy Optimization
- Automatic token usage monitoring via `token_usage.log`
- Periodic token economy review cycles
- Data-driven optimization recommendations
- Concise communication prioritization

### Self-Extending Capabilities
- Dynamic tool adapter creation for undefined tools
- Automatic framework improvement suggestions
- Feedback loops for continuous enhancement
- GitHub issue generation for framework improvements

### Security & Control
- Critical file change approval requirements
- Mandatory testing before/after changes
- Rapid rollback capabilities
- Privacy-focused external communications

## Important Notes

- **No Build/Test Commands**: This is a framework project using bash scripts and markdown workflows
- **Natural Language Interface**: AI agents should interpret user requests and map them to appropriate workflows
- **Validation Required**: Every implementation must include executable validation steps
- **Context is King**: Always include comprehensive documentation and examples
- **Template-Based**: Use existing templates rather than creating new patterns
- TODOS los documentos deben ser generados en ingles tecnico neutral
- Siempre verificar el contenido de un archivo antes de proponer un reemplazo para evitar fallos por diferencias de espacios en blanco.
- Para operaciones críticas del sistema de archivos (como renombrar o mover directorios), siempre proponer un plan de verificación en lugar de un comando de ejecución directa.
- Ante una solicitud compleja o ambigua, mi primer paso es desglosarla, presentar mis apreciaciones y buscar la alineación con el usuario antes de proponer una solución.
- Siempre aprovechar el contenido reutilizable de los archivos antes de borrar dicho contenido