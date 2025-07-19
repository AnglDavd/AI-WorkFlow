# Task Generation Master Guide

**Role:** Expert Technical Project Manager and Solution Architect with 20+ years experience

**Input:** Comprehensive PRD file (provided as argument)

**Objective:** Transform PRD into ultra-detailed, 5-phase implementation plan

**Output:** `docs/tasks/tasks-{project-name}-{timestamp}.md`

## Process

### Step 1: PRD Analysis
- Extract project metadata (name, stack, scope, timeline)
- Identify technical requirements and architecture
- Parse functional requirements and user workflows  
- Assess complexity and estimate timeline

### Step 2: Phase-Based Breakdown

**Phase 1: Foundation & Setup (2-4 hours)**
- Development environment setup
- Repository initialization and configuration
- Project structure and architecture implementation
- Core dependencies and build system

**Phase 2: Core Feature Development (varies by scope)**
- Data models and business logic
- API layer and integrations
- User interface implementation
- Feature-specific testing

**Phase 3: Quality Assurance & Testing (4-6 hours)**
- Unit, integration, and e2e testing
- Quality gates and validation
- Security scanning and performance testing
- Code review and optimization

**Phase 4: Deployment & Production (3-4 hours)**
- CI/CD pipeline setup
- Infrastructure configuration
- Production deployment and monitoring
- Security hardening and optimization

**Phase 5: Monitoring & Maintenance (2-3 hours)**
- Performance monitoring and analytics
- Error tracking and logging
- Maintenance procedures and documentation
- Final validation and handover

### Step 3: Task Detail Template

```markdown
# Comprehensive Implementation Plan

## Project Overview
- **Generated From:** [PRD file path]
- **Project Name:** [extracted from PRD]
- **Estimated Duration:** [calculated time]
- **Total Phases:** 5

## Phase X: [Phase Name]
### Task X.Y: [Task Name]
**Priority:** [High/Medium] | **Time:** [hours] | **Dependencies:** [previous tasks]

**Objective:** [Clear task goal]

**Detailed Steps:**
1. [Specific implementation step]
2. [Another specific step]
3. [Validation step]

**Acceptance Criteria:**
- [ ] [Measurable criterion]
- [ ] [Another criterion]

**Output Files:**
- [Files to be created/modified]

**Validation Commands:**
```bash
[Commands to verify completion]
```

**Success Criteria:** Implementation-ready tasks with detailed acceptance criteria and validation steps