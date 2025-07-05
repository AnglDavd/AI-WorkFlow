# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Nature

This is a **PRP (Product Requirement Prompt) Framework** repository, not a traditional software project. The core concept: **"PRP = PRD + curated codebase intelligence + agent/runbook"** - designed to enable AI agents to ship production-ready code on the first pass.

## Core Architecture

### Command-Driven System

- **Pre-configured Claude Code commands** in `.claude/commands/`
- Commands organized by function:
  - `PRPs/` - PRP creation and execution workflows
  - `development/` - Core development utilities (prime-core, onboarding, debug)
  - `code-quality/` - Review and refactoring commands
  - `git-operations/` - Conflict resolution and smart git operations

### Template-Based Methodology

- **PRP Templates** in `PRPs/templates/` follow structured format with validation loops
- **Context-Rich Approach**: Every PRP must include comprehensive documentation, examples, and gotchas
- **Validation-First Design**: Each PRP contains executable validation gates (syntax, tests, integration)

### AI Documentation Curation

- `PRPs/ai_docs/` contains curated Claude Code documentation for context injection
- `claude_md_files/` provides framework-specific CLAUDE.md examples

## Development Commands

### PRP Creation

```bash
# Use the dedicated script to create new PRPs
./create_prp.sh
```

### PRP Execution

```bash
# Interactive mode (recommended for development)
./PRPs/scripts/prp_runner.py --prp [prp-name] --interactive

# Headless mode (for CI/CD)
./PRPs/scripts/prp_runner.py --prp [prp-name] --output-format json

# Streaming JSON (for real-time monitoring)
./PRPs/scripts/prp_runner.py --prp [prp-name] --output-format stream-json
```

### Key Claude Commands

- `/execute-base-prp` - Execute PRPs against codebase
- `/planning-execute` - Execute planning documents
- `/spec-execute` - Execute specifications
- `/task-execute` - Execute task lists
- `/prime-core` - Prime Claude with project context
- `/review-staged-unstaged` - Review git changes using PRP methodology

## Critical Success Patterns

### The PRP Methodology

1. **Context is King**: Include ALL necessary documentation, examples, and caveats
2. **Validation Loops**: Provide executable tests/lints the AI can run and fix
3. **Information Dense**: Use keywords and patterns from the codebase
4. **Progressive Success**: Start simple, validate, then enhance

### PRP Structure Requirements

- **Goal**: Specific end state and desires
- **Why**: Business value and user impact
- **What**: User-visible behavior and technical requirements
- **All Needed Context**: Documentation URLs, code examples, gotchas, and patterns
- **Implementation Blueprint**: Pseudocode with critical details and task lists
- **Validation Loop**: Executable commands for syntax, tests, integration

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

- ❌ Don't create minimal context prompts - context is everything
- ❌ Don't skip validation steps - they're critical for one-pass success
- ❌ Don't ignore the structured PRP format - it's battle-tested
- ❌ Don't create new patterns when existing templates work
- ❌ Don't hardcode values that should be config
- ❌ Don't catch all exceptions - be specific

## Working with This Framework

### When Creating PRPs

1. **Use `create_prp.sh`**: This script will guide you through the process.
2. **Research First**: Analyze codebase patterns and external documentation (if your LLM CLI supports it).
3. **Use Templates**: The script uses `prp_framework_assets/PRPs/templates/prp_base.md`.
4. **Include Context**: The LLM will fill this based on its capabilities.
5. **Validate Early**: The generated PRP will include validation steps.
6. **Score Confidence**: Rate PRP 1-10 for one-pass implementation success.

### When Executing PRPs

1. **Load PRP**: Read and understand all context and requirements
2. **ULTRATHINK**: Create comprehensive plan, break down into todos
3. **Execute**: Implement following the blueprint
4. **Validate**: Run each validation command, fix failures
5. **Complete**: Ensure all checklist items done

### Command Usage

- Access via `/` prefix in Claude Code
- Commands are self-documenting with argument placeholders
- Leverage existing review and refactoring commands

## Project Structure Understanding

```
PRPs-agentic-eng/
.claude/
  commands/           # Claude Code commands
  settings.local.json # Tool permissions
prp_framework_assets/PRPs-agentic-eng/PRPs/
  templates/          # PRP templates with validation
  scripts/           # PRP runner and utilities
  ai_docs/           # Curated Claude Code documentation
   *.md               # Active and example PRPs
 claude_md_files/        # Framework-specific CLAUDE.md examples
 create_prp.sh         # Script to create new PRPs
```

Remember: This framework is about **one-pass implementation success through comprehensive context**. Every PRP should contain enough context for an AI agent to implement working code without additional research.
