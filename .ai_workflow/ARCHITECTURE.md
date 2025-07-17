# AI-Assisted Development Framework Architecture

**Version:** v1.0.0  
**Last Updated:** July 2025  
**Purpose:** Master architectural documentation for framework development and maintenance
**Developer:** AnglDavd using Claude Code (Solo Developer Project)
**License:** Custom Dual License

### Framework Status

**Current Version:** v1.0.0 (Stable Release - Production Ready)
**Key Features Completed:**
- ✅ Complete Alpha v0.3.0 core functionality
- ✅ Automatic quality validation with adaptive language support
- ✅ Zero-friction automation philosophy
- ✅ Pre-commit system with background validation
- ✅ Multi-language project compatibility (30+ languages)
- ✅ Comprehensive CLI integration
- ✅ Master architectural documentation (ARCHITECTURE.md)
- ✅ Automatic architecture documentation generation for user projects
- ✅ Quality Gate 5: Architecture documentation validation
- ✅ Zero-friction documentation maintenance
- ✅ Enhanced CLI system with production-ready UX
- ✅ External feedback integration and community synchronization
- ✅ Framework-level task management with organized feedback processing

**Development Status:**
- **Phase 1:** 4/4 tasks completed (100%) ✅
- **Phase 2:** 7/7 tasks completed (100%) ✅ **PHASE COMPLETE**
- **Phase 3:** 3/3 tasks completed (100%) ✅ **PHASE COMPLETE**
- **Production Release:** v1.0.0 Stable ✅ **RELEASED**
- **Total Framework:** 14/14 tasks completed (100%) ✅ **COMPLETE**

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Component Registry](#2-component-registry)
3. [Dependency Matrix](#3-dependency-matrix)
4. [Change Impact Matrix](#4-change-impact-matrix)
5. [Integration Points](#5-integration-points)
6. [Development Guidelines](#6-development-guidelines)

---

## 1. System Overview

### 1.1 Framework Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    AI-Assisted Development Framework            │
├─────────────────────────────────────────────────────────────────┤
│  Entry Point: manager.md → CLI: ai-dev → Workflows: *.md       │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   User Layer    │    │  Documentation  │    │   CLI Layer     │
│                 │    │     Layer       │    │                 │
│ • Natural Lang  │◄──►│ • manager.md    │◄──►│ • ai-dev script │
│ • Commands      │    │ • CLAUDE.md     │    │ • Command       │
│ • Requests      │    │ • Guides        │    │   Routing       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Workflow Engine │    │ Quality System  │    │ Security System │
│                 │    │                 │    │                 │
│ • MD Parser     │◄──►│ • Quality Gates │◄──►│ • Input Valid.  │
│ • State Mgmt    │    │ • Lang Support  │    │ • Permissions   │
│ • Execution     │    │ • Pre-commit    │    │ • Secure Exec   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Configuration Layer                          │
│ • quality_config.json • validation_rules.json • framework.json │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Component Hierarchy

```
Framework Root
├── Documentation System
│   ├── Primary Entry (manager.md)
│   ├── Technical Guides (CLAUDE.md, GLOBAL_AI_RULES.md)
│   └── Architectural Guides (FRAMEWORK_GUIDE.md, AGENT_GUIDE.md)
├── CLI System
│   ├── Main Interface (ai-dev)
│   ├── Command Routing
│   └── Workflow Execution Engine
├── Workflow System
│   ├── Quality Workflows (.ai_workflow/workflows/quality/)
│   ├── Security Workflows (.ai_workflow/workflows/security/)
│   ├── Integration Workflows (.ai_workflow/workflows/integration/)
│   └── Audit Workflows (.ai_workflow/workflows/audit/)
├── Configuration System
│   ├── Quality Config (quality_config.json)
│   ├── Validation Rules (validation_rules.json)
│   └── Framework Config (framework.json)
└── Support Systems
    ├── Pre-commit Hooks
    ├── Setup Scripts
    └── Audit Reports
```

### 1.3 Data Flow

```
User Input → CLI Validation → Workflow Selection → Execution → Validation → Output

Detailed Flow:
1. User Request (Natural Language or Command)
2. CLI Processing (ai-dev script)
3. Input Validation (Security System)
4. Workflow Selection (Command Routing)
5. Configuration Loading (Config System)
6. Workflow Execution (Workflow Engine)
7. Quality Validation (Quality System)
8. Output Generation (Results/Reports)
9. State Persistence (Cache/Logs)
```

---

## 2. Component Registry

### 2.1 CLI System

#### Primary Component: `ai-dev` Script
- **Location:** `/ai-dev`
- **Purpose:** Main CLI interface and command router
- **Key Functions:**
  - Command validation and routing
  - Workflow execution engine (`execute_md_workflow()`)
  - Environment setup and validation
  - Error handling and logging
- **Dependencies:** All workflow files, configuration files
- **Integration Points:** All systems

#### Command Registry (15 Commands)
```bash
# Core Commands (5)
setup                    # Project initialization
generate <prd_file>      # Task generation from PRD
run <prp_file>          # PRP execution
optimize <prompt_file>   # Prompt optimization
performance <subcommand> # Performance optimization and monitoring

# Quality & Security Commands (3)
quality <path>          # Quality validation with adaptive language support
audit                   # Security audit and compliance checking
precommit <subcommand>  # Pre-commit validation system management

# Framework Management Commands (3)
sync <subcommand>       # Framework synchronization and external feedback
  ├── feedback          # Integrate external community feedback from GitHub
  └── framework         # Synchronize framework updates
configure [options]     # Interactive configuration management
diagnose               # Framework health and diagnostic reporting

# Documentation Commands (2)
generate-architecture   # Generate project architecture documentation
update-architecture     # Update existing architecture documentation

# Maintenance Commands (4)
cleanup [options]       # Manage obsolete files and repository cleanup
update-gitignore        # Update .gitignore with latest patterns
maintenance [level]     # Run periodic repository maintenance
platform                # Show platform compatibility information

# Utility Commands (3)
help                    # Show all available commands
version                 # Framework version and platform information
status                  # Current framework status
```

### 2.2 Workflow Engine

#### Core Component: Markdown Workflow Execution
- **Location:** Embedded in `ai-dev` script
- **Purpose:** Parse and execute markdown workflows
- **Key Functions:**
  - Bash block extraction from markdown
  - Workflow-to-workflow communication
  - State management and persistence
  - Error recovery and rollback
- **Dependencies:** All `.md` workflow files
- **Integration Points:** CLI system, configuration system

#### Workflow Categories
```
Quality Workflows:
├── quality_gates.md              # Core quality validation
├── adaptive_language_support.md  # Multi-language support (30+ languages)
├── detect_project_type.md        # Automatic project detection
├── validate_dependencies.md      # Dependency validation and security
└── measure_code_quality.md       # Quality metrics and analysis

Security Workflows:
├── validate_input.md             # Input sanitization and validation
├── check_permissions.md          # Permission verification
├── secure_execution.md           # Secure command execution
└── audit_security.md             # Security audit and compliance

CLI Workflows:
└── enhanced_cli_validation.md    # Production-ready CLI UX and validation

Sync Workflows:
└── external_feedback_integration.md  # Community feedback integration

Integration Workflows:
├── auto_quality_integration.md   # Master integration workflow
└── setup_quality_env.sh          # Environment setup automation

Audit Workflows:
└── audit_manual_processes.md     # Manual process identification
```

### 2.3 Quality System

#### Primary Component: Adaptive Quality Validation
- **Location:** `.ai_workflow/workflows/quality/`
- **Purpose:** Automated quality assurance with multi-language support
- **Key Features:**
  - Adaptive language detection (30+ programming languages)
  - Automatic tool configuration
  - Graceful degradation for unknown languages
  - Integration with PRD language hints
- **Dependencies:** Language-specific tooling, configuration files
- **Integration Points:** CLI commands, pre-commit hooks, PRP execution

#### Quality Gates
```json
{
  "validation_levels": {
    "syntax": "Language-specific syntax validation",
    "tests": "Automated test execution",
    "dependencies": "Dependency validation and security scanning",
    "code_quality": "Complexity, duplication, and maintainability analysis"
  },
  "thresholds": {
    "quality_score": 75,
    "test_coverage": 70,
    "complexity": 10,
    "duplication": 5
  }
}
```

### 2.4 Security System

#### Primary Component: Layered Security Validation
- **Location:** `.ai_workflow/workflows/security/`
- **Purpose:** Comprehensive security validation and protection
- **Key Features:**
  - Input validation and sanitization
  - Permission verification
  - Secure command execution with timeouts
  - Automatic security auditing
- **Dependencies:** System permissions, security tools
- **Integration Points:** All workflow executions, CLI input processing

#### Security Layers
```
Layer 1: Input Validation
├── Path traversal prevention
├── Command injection protection
├── Malicious input detection
└── File system access control

Layer 2: Execution Security
├── Permission verification
├── Secure command execution
├── Resource limits and timeouts
└── Process isolation

Layer 3: Audit and Compliance
├── Security scanning
├── Vulnerability detection
├── Compliance reporting
└── Incident logging
```

### 2.5 Configuration System

#### Primary Component: Hierarchical Configuration Management
- **Location:** `.ai_workflow/config/`
- **Purpose:** Centralized configuration for all framework components
- **Key Files:**
  - `quality_config.json` - Quality validation settings
  - `validation_rules.json` - Pre-commit validation rules
  - `framework.json` - Framework-wide settings
- **Dependencies:** All framework components
- **Integration Points:** All systems

#### Configuration Hierarchy
```
Framework Configuration Priority:
1. Command-line flags (--verbose, --quiet, --dry-run, --force)
2. Environment variables (QUALITY_VALIDATION_ENABLED, etc.)
3. Project-specific config files (.ai_workflow/config/)
4. User-specific settings (planned)
5. System defaults (embedded in workflows)
```

---

## 3. Dependency Matrix

### 3.1 Inter-Component Dependencies

#### Critical Dependencies
```
CLI System (ai-dev)
├── DEPENDS ON → All workflow files (execution)
├── DEPENDS ON → Configuration files (behavior)
├── DEPENDS ON → Documentation files (help system)
└── PROVIDES → Entry point for all operations

Workflow Engine
├── DEPENDS ON → CLI system (invocation)
├── DEPENDS ON → Configuration system (settings)
├── DEPENDS ON → Security system (validation)
└── PROVIDES → Workflow execution capability

Quality System
├── DEPENDS ON → Workflow engine (execution)
├── DEPENDS ON → Configuration system (settings)
├── DEPENDS ON → Project files (analysis)
└── PROVIDES → Quality validation for all operations

Security System
├── DEPENDS ON → Configuration system (rules)
├── DEPENDS ON → System permissions (execution)
└── PROVIDES → Security validation for all operations

Configuration System
├── DEPENDS ON → File system (persistence)
└── PROVIDES → Settings for all components
```

### 3.2 Documentation Dependencies

#### Documentation Dependency Graph
```
manager.md (entry point)
├── REFERENCES → CLAUDE.md (detailed instructions)
├── REFERENCES → GLOBAL_AI_RULES.md (behavioral rules)
├── REFERENCES → FRAMEWORK_GUIDE.md (comprehensive guide)
└── REFERENCES → AGENT_GUIDE.md (agent-specific instructions)

CLAUDE.md
├── REFERENCES → Directory structure
├── REFERENCES → Command patterns
├── REFERENCES → Workflow execution
└── REFERENCES → Development philosophy

GLOBAL_AI_RULES.md
├── INFORMS → Quality validation rules
├── INFORMS → Security validation processes
├── INFORMS → CLI behavior patterns
└── INFORMS → Workflow execution standards
```

### 3.3 Configuration Dependencies

#### Configuration Impact Map
```
quality_config.json
├── CONTROLS → Quality validation behavior
├── CONTROLS → Language detection settings
├── CONTROLS → Integration touchpoints
├── CONTROLS → Pre-commit validation
└── AFFECTS → CLI commands (quality, precommit, run)

validation_rules.json
├── CONTROLS → Pre-commit hook behavior
├── DEFINES → Quality gate thresholds
├── DEFINES → Security scanning rules
└── AFFECTS → Git commit process

framework.json
├── CONTROLS → Framework-wide settings
├── CONTROLS → Default behaviors
└── AFFECTS → All framework operations
```

---

## 4. Change Impact Matrix

### 4.1 Change Type → Impact Mapping

#### When Adding a New CLI Command
**Required Updates:**
1. **`ai-dev` script** - Command implementation and routing
2. **`manager.md`** - Command documentation in CLI section
3. **`CLAUDE.md`** - Command in "Key Commands" section
4. **`FRAMEWORK_GUIDE.md`** - Command in "Core Commands" section
5. **`GLOBAL_AI_RULES.md`** - If command affects behavior rules

**Validation Required:**
- CLI help function consistency
- Command routing functionality
- Documentation consistency across all files
- Integration with existing workflows

#### When Adding a New Workflow
**Required Updates:**
1. **Workflow directory** - New workflow file
2. **`plan_de_trabajo.md`** - If it's a new major task
3. **`CLAUDE.md`** - If it affects directory structure
4. **`GLOBAL_AI_RULES.md`** - If it requires new behavioral rules
5. **Integration workflows** - If it requires new integration points

**Validation Required:**
- Workflow execution compatibility
- Integration point functionality
- Documentation accuracy
- Dependency satisfaction

#### When Changing Framework Version
**Required Updates:**
1. **`manager.md`** - Framework status section
2. **`FRAMEWORK_GUIDE.md`** - Version status section
3. **`AGENT_GUIDE.md`** - Framework version status
4. **`GLOBAL_AI_RULES.md`** - Framework version footer
5. **`ai-dev` script** - Version command output

**Validation Required:**
- Version consistency across all documentation
- Changelog updates
- Backward compatibility verification
- Migration guide updates (if needed)

#### When Modifying Quality System
**Required Updates:**
1. **Quality workflows** - Core functionality
2. **`quality_config.json`** - Configuration settings
3. **`GLOBAL_AI_RULES.md`** - Quality-related rules
4. **Integration workflows** - Quality integration points
5. **Pre-commit hooks** - Quality validation integration

**Validation Required:**
- Quality validation functionality
- Multi-language support
- Integration point compatibility
- Configuration consistency

### 4.2 Validation Checklist by Change Type

#### CLI Command Changes
- [ ] Command executes successfully
- [ ] Help text is accurate and consistent
- [ ] Command appears in all documentation
- [ ] Integration with workflow system works
- [ ] Error handling is appropriate
- [ ] Logging is implemented

#### Workflow Changes
- [ ] Workflow executes without errors
- [ ] Integration points function correctly
- [ ] Dependencies are satisfied
- [ ] Documentation is updated
- [ ] Testing is implemented
- [ ] Error recovery works

#### Configuration Changes
- [ ] Configuration loads correctly
- [ ] All affected systems respond to changes
- [ ] Validation rules are enforced
- [ ] Backward compatibility is maintained
- [ ] Documentation reflects changes
- [ ] Default values are appropriate

#### Documentation Changes
- [ ] Information is accurate and up-to-date
- [ ] Cross-references are correct
- [ ] Consistency across all documents
- [ ] Technical English is used
- [ ] Examples are functional
- [ ] Links and references work

---

## 5. Integration Points

### 5.1 CLI-to-Workflow Integration

#### Workflow Execution Mechanism
```bash
# CLI calls workflows using execute_md_workflow()
execute_md_workflow() {
    local workflow_file="$1"
    # Extract bash blocks from markdown
    # Process workflow calls
    # Execute with function context
    # Handle errors and state
}
```

#### Integration Patterns
```
CLI Command → Workflow Selection → Execution → Validation → Output

Example Flow:
./ai-dev quality src/ 
├── Validates input path
├── Loads quality configuration
├── Executes quality_gates.md
├── Runs adaptive language support
├── Validates results
└── Reports output
```

### 5.2 Workflow-to-Workflow Communication

#### Inter-Workflow Calling
```bash
# Workflows can call other workflows
call_workflow() {
    local workflow_path="$1"
    # Resolve full path
    # Export arguments
    # Execute workflow
    # Handle results
}
```

#### Communication Patterns
```
Primary Workflow → Sub-Workflow → Validation → State Update

Example:
quality_gates.md
├── Calls → detect_project_type.md
├── Calls → adaptive_language_support.md
├── Calls → validate_dependencies.md
├── Calls → measure_code_quality.md
└── Aggregates results
```

### 5.3 Configuration-to-System Integration

#### Configuration Loading
```bash
# Configuration is loaded hierarchically
1. Command-line flags
2. Environment variables
3. Project configuration files
4. User settings
5. System defaults
```

#### Configuration Impact
```
Configuration Change → System Notification → Behavior Update

Example:
quality_config.json change
├── Affects → Quality validation behavior
├── Affects → Language detection settings
├── Affects → Integration touchpoints
└── Affects → Pre-commit validation
```

### 5.4 Pre-commit Integration

#### Automatic Integration
```bash
# Pre-commit hooks are auto-installed
Git Hook → Quality Validation → Security Check → Commit Decision

Pre-commit Flow:
1. Code changes detected
2. Quality validation executed
3. Security validation executed
4. Results evaluated
5. Commit allowed/blocked
```

#### Configuration Integration
```json
{
  "validation_rules": {
    "code_quality": { "enabled": true },
    "security": { "enabled": true },
    "framework_compliance": { "enabled": true }
  },
  "quality_gates": {
    "minimum_score": 80,
    "block_on_security_issues": true
  }
}
```

---

## 6. Development Guidelines

### 6.1 Adding New Features

#### Step-by-Step Process
1. **Update Plan** - Add to `plan_de_trabajo.md`
2. **Design Review** - Consider architectural impact
3. **Implementation** - Follow existing patterns
4. **Documentation** - Update all affected docs
5. **Testing** - Validate functionality
6. **Integration** - Ensure compatibility
7. **Deployment** - Follow release process

#### Architecture Considerations
- **Maintain MD-based architecture** - All logic in markdown workflows
- **Preserve CLI simplicity** - Single entry point through `ai-dev`
- **Ensure security-first** - All inputs validated
- **Support zero-friction** - Minimize user intervention
- **Maintain backward compatibility** - Existing functionality must work

### 6.2 Modifying Existing Components

#### Critical Path Analysis
1. **Identify dependencies** - Use dependency matrix
2. **Assess impact** - Use change impact matrix
3. **Plan updates** - Create comprehensive update plan
4. **Validate changes** - Use validation checklists
5. **Test thoroughly** - Ensure no regressions
6. **Document changes** - Update all affected documentation

#### Risk Mitigation
- **Backup before changes** - Complete system backup
- **Test incrementally** - Validate each change
- **Rollback capability** - Plan for failure scenarios
- **Peer review** - Review complex changes
- **Staged deployment** - Test in controlled environment

### 6.3 Documentation Maintenance

#### Single Source of Truth Principle
- **CLI Commands** - Defined in `ai-dev` script, referenced elsewhere
- **Version Information** - Managed centrally, propagated to all docs
- **Directory Structure** - Documented here, referenced elsewhere
- **Development Principles** - Centralized in `GLOBAL_AI_RULES.md`

#### Update Responsibilities
- **When adding CLI commands** - Update 4 documentation files
- **When changing versions** - Update 4 documentation files
- **When modifying structure** - Update 3 documentation files
- **When changing principles** - Update 4 documentation files

### 6.4 Quality Assurance

#### Continuous Quality Checks
- **Pre-commit validation** - Automatic quality gates
- **Integration testing** - Verify component interactions
- **Documentation consistency** - Ensure accuracy across all docs
- **Security validation** - Continuous security scanning

#### Quality Gates
- **Minimum 85% quality score** - For all code changes
- **Zero critical security issues** - Blocking requirement
- **Complete documentation** - All changes must be documented
- **Backward compatibility** - Existing functionality must work

---

## 7. Maintenance and Evolution

### 7.1 Framework Growth Strategy

#### Scalability Considerations
- **Modular architecture** - Components can be extended independently
- **Clear interfaces** - Well-defined integration points
- **Configuration-driven** - Behavior controlled by configuration
- **Documentation-first** - Architecture documented before implementation

#### Evolution Path
```
Current: v1.0.0 (Stable Release)
├── Production Ready ✅ v1.0.0
├── Cross-Platform Support ✅ Linux/macOS/Windows
├── Enhanced Features → v1.1.0+
└── Community Contributions → v1.2.0+
```

### 7.2 Architectural Reviews

#### Regular Review Schedule
- **Monthly** - Dependency matrix validation
- **Quarterly** - Architecture document updates
- **Major releases** - Complete architectural review
- **After significant changes** - Impact assessment

#### Review Criteria
- **Complexity management** - Keep architecture understandable
- **Dependency health** - Minimize coupling
- **Documentation accuracy** - Ensure docs match implementation
- **Performance impact** - Monitor system performance

### 7.3 Community Integration

#### Framework Synchronization
- **External feedback processing** - Community contributions
- **Framework updates** - Safe integration of improvements
- **Version management** - Compatibility with upstream changes
- **Privacy protection** - No project-specific data in external communications

#### Contribution Guidelines
- **Architecture compliance** - Follow established patterns
- **Documentation requirements** - Update all affected docs
- **Testing standards** - Comprehensive validation
- **Security review** - All contributions security-validated

---

## 8. Troubleshooting and Diagnostics

### 8.1 Common Issues and Solutions

#### CLI Issues
- **Command not found** - Check `ai-dev` script permissions
- **Workflow execution fails** - Verify workflow file exists and is readable
- **Configuration errors** - Validate configuration file syntax
- **Permission denied** - Check file system permissions

#### Integration Issues
- **Quality validation fails** - Check language detection and tool availability
- **Security validation blocks** - Review input validation rules
- **Pre-commit hooks fail** - Verify hook installation and configuration
- **Workflow communication fails** - Check inter-workflow dependencies

#### Performance Issues
- **Slow execution** - Check workflow complexity and system resources
- **Memory usage** - Monitor bash block execution
- **File system access** - Verify permissions and disk space
- **Network issues** - Check external dependencies

### 8.2 Diagnostic Tools

#### Built-in Diagnostics
- **`./ai-dev diagnose`** - Comprehensive framework health check
- **`./ai-dev status`** - Current framework status
- **`./ai-dev precommit report`** - Pre-commit system status
- **Log files** - Detailed execution logs

#### Manual Diagnostics
- **Configuration validation** - Verify all config files
- **Dependency checking** - Ensure all dependencies satisfied
- **Permission verification** - Check file system access
- **Integration testing** - Validate component interactions

---

**Document Status:** Living document - Updated with each architectural change  
**Current Status:** v1.0.0 Stable - Production Ready  
**Developer:** AnglDavd using Claude Code  
**License:** Custom Dual License  
**Next Review:** After v1.1.0 feature planning  
**Feedback:** Report architectural issues to framework development team via GitHub issues