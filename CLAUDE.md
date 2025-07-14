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
./ai-dev audit                    # Run security audit
./ai-dev sync                     # Synchronize with framework updates
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
│   ├── security/                # Security validation and protection workflows
│   ├── sync/                    # Framework synchronization and external feedback
│   ├── monitoring/              # Token economy and performance monitoring
│   ├── feedback/                # User feedback collection and processing
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
- **Security First**: All inputs pass through validation, all commands through secure execution
- **Think Hard for Critical Changes**: Explicitly articulate internal plan and reasoning
- **Token Economy Optimization**: Actively seek and implement token efficiency
- **Loop Prevention**: Detect and break repetitive patterns, escalate when stuck
- **Privacy First**: Never include project-specific code in external communications
- **Community Contribution**: Automatically identify and share framework improvements

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
- **Security-First Error Processing**: All errors pass through security validation
- **Resilient Testing**: Attempt diagnosis and auto-correction before escalating
- **Contextual Error Reporting**: Provide context for abstract tool failures
- **Graceful Degradation**: Suggest adapter refinement when tools fail
- **Automated Security Escalation**: Critical security violations trigger immediate escalation

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

### Community Integration & Synchronization
- **External Feedback Integration**: Automated processing of community contributions
- **Framework Synchronization**: Safe integration of upstream improvements
- **Version Management**: Automated tracking and compatibility verification
- **Community Contributions**: Streamlined process for sharing improvements
- **Privacy-Safe Sharing**: Framework improvements shared without exposing project data

### Security & Control
- **Input Validation**: Comprehensive sanitization of file paths and commands
- **Permission Management**: Automated verification of file system permissions
- **Secure Execution**: Sandboxed command execution with resource limits
- **Security Auditing**: Automated security scanning and vulnerability detection
- **Critical file change approval requirements**
- **Mandatory testing before/after changes**
- **Rapid rollback capabilities**
- **Privacy-focused external communications**

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

## Maintenance and Updates

### Periodic GitHub Updates Protocol
**IMPORTANT**: Always ensure README.md is up-to-date before pushing to GitHub
- **Frequency**: Update GitHub after completing major milestones or significant feature additions
- **Pre-Update Checklist**:
  1. ✅ Verify README.md reflects all new features and capabilities
  2. ✅ Update CLAUDE.md with new directory structures and workflows
  3. ✅ Update plan_de_trabajo.md with current progress status
  4. ✅ Ensure .gitignore excludes non-pertinent files (IDE configs, temp files)
  5. ✅ **Run repository cleanliness check**: `./.ai_workflow/scripts/check_repo_cleanliness.sh`
  6. ✅ Run security audit if new workflows were added
- **Commit Message Format**: Follow conventional commits with detailed descriptions
- **Branch Protection**: Always push to main branch after local validation

### Repository Cleanliness Protocol
**CRITICAL**: Keep repository free of development tool configurations and temporary files
- **Automated Check**: Use `./.ai_workflow/scripts/check_repo_cleanliness.sh` before every push
- **Prohibited Files**: 
  - IDE configs (.vscode/, .idea/, *.swp)
  - AI tool configs (.claude/, *.claude, .anthropic/)
  - Logs and temp files (*.log, *.tmp, *.temp)
  - OS files (.DS_Store, Thumbs.db)
  - Credentials (*.key, *.pem, .env files)
- **If Issues Found**: Use `git rm --cached <file>` to untrack, update .gitignore, then commit
- **Prevention**: The .gitignore file is comprehensive and should prevent most issues automatically