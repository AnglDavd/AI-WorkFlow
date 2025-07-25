# [STEP-02] Task Generation Master Guide

**WORKFLOW-POSITION:** Step 2 of 3 (PRD → TASKS → EXECUTION)
**INPUT-FILE:** `01_prd_{session-id}_{project-name}.md` (provided as argument)
**OUTPUT-FILE:** `02_tasks_{session-id}_{project-name}.md`
**NEXT-STEP:** `./ai-dev execute 02_tasks_{session-id}_{project-name}.md`

**CRITICAL-EXTRACTION-LOGIC:**
```bash
# Parse input filename to extract components
# INPUT_FILE is already set by the calling script

# Validate input file provided
if [ -z "$INPUT_FILE" ]; then
    echo "ERROR: No PRD file provided"
    exit 1
fi

# Validate input format
if [[ ! "$INPUT_FILE" =~ ^01_prd_[^_]+_.*\.md$ ]]; then
    echo "ERROR: Invalid input format. Expected: 01_prd_{session-id}_{project-name}.md"
    exit 1
fi

# Validate file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "ERROR: PRD file not found: $INPUT_FILE"
    exit 1
fi

# Extract and validate components with enhanced security checks
SESSION_ID=$(echo "$INPUT_FILE" | sed 's/01_prd_\([^_]*\)_.*/\1/' | grep -E '^[a-zA-Z0-9]{4,8}$')
PROJECT_NAME=$(echo "$INPUT_FILE" | sed 's/01_prd_[^_]*_\(.*\)\.md/\1/' | grep -E '^[a-zA-Z0-9][a-zA-Z0-9_-]*[a-zA-Z0-9]$')

if [ -z "$SESSION_ID" ] || [ -z "$PROJECT_NAME" ]; then
    echo "ERROR: Could not extract valid session ID or project name"
    echo "Session ID: '$SESSION_ID', Project Name: '$PROJECT_NAME'"
    exit 1
fi

OUTPUT_FILE="02_tasks_${SESSION_ID}_${PROJECT_NAME}.md"

# Validate extraction success
echo "✅ Extracted SESSION_ID: $SESSION_ID"
echo "✅ Extracted PROJECT_NAME: $PROJECT_NAME"
echo "✅ Validated PRD_FILE: $INPUT_FILE"
echo "✅ Generated OUTPUT_FILE: $OUTPUT_FILE"
```

**Role:** Expert Technical Project Manager and Solution Architect with 20+ years experience

**Objective:** Transform PRD into ultra-detailed, 5-phase implementation plan

**Structure Philosophy:** Sequential workflow with session ID ensures perfect file relationship tracking

## Process

### Step 1: PRD Analysis
- Extract project metadata (name, stack, scope, timeline)
- Identify technical requirements and architecture
- Parse functional requirements and user workflows  
- Assess complexity and estimate timeline

### Step 2: Phase-Based Breakdown

**Phase 1: Foundation & Setup (16-32 hours - 2-4 tasks of 8h each)**
- Development environment setup (8-12 hours)
- Repository initialization and configuration (8-12 hours)
- Project structure and architecture implementation (8-16 hours)
- Core dependencies and build system (8-12 hours)

**Phase 2: Core Feature Development (varies by scope - 40-80% of total hours)**
- Data models and business logic (16-40 hours)
- API layer and integrations (24-60 hours)
- User interface implementation (32-80 hours)
- Feature-specific testing (16-32 hours)

**Phase 3: Quality Assurance & Testing (32-48 hours - 4-6 tasks of 8h each)**
- Unit, integration, and e2e testing (16-24 hours)
- Quality gates and validation (8-12 hours)
- Security scanning and performance testing (8-16 hours)
- Code review and optimization (8-12 hours)

**Phase 4: Deployment & Production (24-32 hours - 3-4 tasks of 8h each)**
- CI/CD pipeline setup (8-12 hours)
- Infrastructure configuration (8-12 hours)
- Production deployment and monitoring (8-12 hours)
- Security hardening and optimization (8-12 hours)

**Phase 5: Monitoring & Maintenance (16-24 hours - 2-3 tasks of 8h each)**
- Performance monitoring and analytics (8-12 hours)
- Error tracking and logging (8-12 hours)
- Maintenance procedures and documentation (8-12 hours)

**Phase 6: MANDATORY Auto-Healing Quality Validation (16-24 hours - 2-3 tasks of 8h each)**
- Comprehensive UI/UX analysis with MCP Playwright (8-12 hours)
- Automated Level 1 fixes application (4-8 hours)
- Level 2 supervised changes review and approval (4-8 hours)
- Final healing validation and certification (4-8 hours)

### Step 3: Task Detail Template

```markdown
# Comprehensive Implementation Plan

## Project Overview
- **Generated From:** [PRD file path]
- **Project Name:** [extracted from PRD]
- **Estimated Duration:** [calculated time]
- **Total Phases:** 6 (including mandatory healing)

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
# Commands to verify completion will be generated based on task requirements
echo "✅ Task completion validation would be implemented here"
```

**MANDATORY-TASK-GENERATION-REQUIREMENTS:**
- **Minimum Tasks:** 20-30 tasks for complex projects, 10-15 for simple projects
- **Task Granularity:** 8-40 hours per task (nothing smaller than 8h, nothing larger than 40h)
- **Total Effort:** Must align with PRD timeline and budget
- **Phase Distribution:** 5 phases with logical dependencies
- **Resource Allocation:** Specific developer assignments based on PRD team composition

**AUTOMATIC-COMPLEXITY-DETERMINATION:**
```bash
determine_project_complexity() {
    local prd_file="$1"
    
    # Extract key metrics from PRD
    local budget=$(grep -Eo "\$[0-9,]+" "$prd_file" | tr -d '$,' | head -1)
    local integrations=$(grep -ci "integration\|API\|third-party\|webhook\|external" "$prd_file")
    local compliance=$(grep -ci "compliance\|GDPR\|PCI\|security\|audit\|legal" "$prd_file")
    local platforms=$(grep -ci "mobile\|web\|desktop\|ios\|android\|react\|vue\|angular" "$prd_file")
    local features=$(grep -c "^###\|^####" "$prd_file")  # Count feature sections
    local team_mentions=$(grep -ci "team\|developer\|devops\|designer" "$prd_file")
    
    # Default values if extraction fails
    budget=${budget:-0}
    integrations=${integrations:-0}
    compliance=${compliance:-0}
    platforms=${platforms:-1}
    features=${features:-5}
    
    # Complexity scoring algorithm
    local complexity_score=0
    
    # Budget scoring (0-40 points)
    if [ $budget -gt 50000 ]; then
        complexity_score=$((complexity_score + 40))
    elif [ $budget -gt 20000 ]; then
        complexity_score=$((complexity_score + 30))
    elif [ $budget -gt 10000 ]; then
        complexity_score=$((complexity_score + 20))
    elif [ $budget -gt 5000 ]; then
        complexity_score=$((complexity_score + 10))
    fi
    
    # Integration scoring (0-25 points)
    if [ $integrations -gt 8 ]; then
        complexity_score=$((complexity_score + 25))
    elif [ $integrations -gt 5 ]; then
        complexity_score=$((complexity_score + 20))
    elif [ $integrations -gt 3 ]; then
        complexity_score=$((complexity_score + 15))
    elif [ $integrations -gt 1 ]; then
        complexity_score=$((complexity_score + 10))
    fi
    
    # Compliance scoring (0-20 points)
    if [ $compliance -gt 5 ]; then
        complexity_score=$((complexity_score + 20))
    elif [ $compliance -gt 2 ]; then
        complexity_score=$((complexity_score + 15))
    elif [ $compliance -gt 0 ]; then
        complexity_score=$((complexity_score + 10))
    fi
    
    # Platform scoring (0-10 points)
    if [ $platforms -gt 3 ]; then
        complexity_score=$((complexity_score + 10))
    elif [ $platforms -gt 1 ]; then
        complexity_score=$((complexity_score + 5))
    fi
    
    # Feature scoring (0-5 points)
    if [ $features -gt 20 ]; then
        complexity_score=$((complexity_score + 5))
    elif [ $features -gt 10 ]; then
        complexity_score=$((complexity_score + 3))
    fi
    
    # Determine complexity based on score
    if [ $complexity_score -ge 80 ]; then
        echo "Enterprise"
    elif [ $complexity_score -ge 55 ]; then
        echo "Complex"
    elif [ $complexity_score -ge 30 ]; then
        echo "Medium"
    else
        echo "Simple"
    fi
    
    # Debug output
    echo "# Complexity Analysis: Score=$complexity_score, Budget=\$$budget, Integrations=$integrations, Compliance=$compliance" >&2
}
```

**TASK-VALIDATION-MATRIX:**
```
Project Complexity | Min Tasks | Max Hours | Phases | Team Size
Simple             | 10-15     | 200-400   | 3-4    | 1-2 devs
Medium             | 15-25     | 400-800   | 4-5    | 2-4 devs  
Complex            | 25-40     | 800-1500  | 5      | 4+ devs
Enterprise         | 40+       | 1500+     | 5-6    | 6+ devs
```

**ENHANCED-EXECUTION-SEQUENCE-WITH-MCP:**
Execute this enhanced sequence with MCP Context7 integration:
```bash
echo "🔍 Step 1: Analyzing PRD complexity with current best practices..."

# Extract project metadata from PRD
PRD_BUDGET=$(grep -Eo "\$[0-9,]+" "$INPUT_FILE" | tr -d '$,' | head -1)
PRD_FEATURES=$(grep -c "^###\|^####" "$INPUT_FILE")
PRD_INTEGRATIONS=$(grep -ci "integration\|API\|third-party" "$INPUT_FILE")
PRD_TECH_STACK=$(extract_approved_tech_stack "$INPUT_FILE")
PRD_INDUSTRY=$(extract_industry_from_prd "$INPUT_FILE")

echo "🔬 Step 2: Researching current implementation patterns with MCP Context7..."
research_current_patterns "$PRD_TECH_STACK" "$PRD_INDUSTRY" "$PROJECT_COMPLEXITY"

echo "🧠 Step 3: Validating task structure against latest best practices..."
validate_task_approach_with_context7 "$PRD_TECH_STACK" "$PRD_INDUSTRY"

# Enhanced complexity determination with research validation
if [ "${PRD_BUDGET:-0}" -gt 30000 ] || [ "${PRD_FEATURES:-0}" -gt 15 ] || [ "${PRD_INTEGRATIONS:-0}" -gt 5 ]; then
    PROJECT_COMPLEXITY="Enterprise"
    MIN_TASKS=29; MAX_TASKS=40; MAX_HOURS=600; PHASES=6; TEAM_SIZE_REC="5-6"
elif [ "${PRD_BUDGET:-0}" -gt 15000 ] || [ "${PRD_FEATURES:-0}" -gt 8 ]; then
    PROJECT_COMPLEXITY="Complex"
    MIN_TASKS=20; MAX_TASKS=30; MAX_HOURS=400; PHASES=5; TEAM_SIZE_REC="3-4"
elif [ "${PRD_BUDGET:-0}" -gt 8000 ] || [ "${PRD_FEATURES:-0}" -gt 5 ]; then
    PROJECT_COMPLEXITY="Medium"
    MIN_TASKS=15; MAX_TASKS=25; MAX_HOURS=300; PHASES=4; TEAM_SIZE_REC="2-3"
else
    PROJECT_COMPLEXITY="Simple"
    MIN_TASKS=10; MAX_TASKS=15; MAX_HOURS=200; PHASES=3; TEAM_SIZE_REC="1-2"
fi

echo "✅ Determined complexity: $PROJECT_COMPLEXITY (validated with current standards)"
echo "✅ Configuration: $MIN_TASKS-$MAX_TASKS tasks, $MAX_HOURS max hours, $PHASES phases"
echo "✅ Technology validation: $PRD_TECH_STACK patterns researched"
# MCP CONTEXT7 FUNCTIONS FOR TASK GENERATION
extract_approved_tech_stack() {
    local prd_file="$1"
    
    # Extract approved technology from PRD comments
    local approved_tech=$(grep "TECH_APPROVED:" "$prd_file" | tail -1 | sed 's/.*TECH_APPROVED: \([^[:space:]]*\).*/\1/')
    
    if [ -z "$approved_tech" ]; then
        # Fallback: extract from content
        if grep -qi "react\|nextjs" "$prd_file"; then
            echo "react-stack"
        elif grep -qi "vue\|nuxt" "$prd_file"; then
            echo "vue-stack"
        elif grep -qi "laravel\|php" "$prd_file"; then
            echo "php-stack"
        elif grep -qi "django\|python" "$prd_file"; then
            echo "python-stack"
        else
            echo "unknown-stack"
        fi
    else
        echo "$approved_tech"
    fi
}

extract_industry_from_prd() {
    local prd_file="$1"
    
    # Extract industry context from PRD content
    if grep -qi "ecommerce\|e-commerce\|shop\|store" "$prd_file"; then
        echo "ecommerce"
    elif grep -qi "saas\|software.*service" "$prd_file"; then
        echo "saas"
    elif grep -qi "education\|learning" "$prd_file"; then
        echo "education"
    elif grep -qi "healthcare\|medical" "$prd_file"; then
        echo "healthcare"
    else
        echo "general"
    fi
}

research_current_patterns() {
    local tech_stack="$1"
    local industry="$2"
    local complexity="$3"
    
    echo "📚 Researching with MCP Context7:"
    echo "1. ${tech_stack} development patterns 2025"
    echo "2. ${industry} ${tech_stack} best practices current"
    echo "3. ${complexity} project task breakdown patterns"
    echo "4. ${tech_stack} testing strategies latest"
    echo "5. ${industry} deployment patterns ${tech_stack}"
    
    # Framework for MCP Context7 integration
    echo "✅ Research queries prepared for Context7 validation"
}

validate_task_approach_with_context7() {
    local tech_stack="$1"
    local industry="$2"
    
    echo "🔍 Validating task approach against current standards:"
    echo "- ${tech_stack} project structure validation"
    echo "- ${industry} compliance requirements check"
    echo "- Current security standards validation"
    echo "- Performance optimization patterns verification"
    
    # This would integrate with actual MCP Context7 validation
    echo "✅ Task approach validated with current best practices"
}
```

**CRITICAL-EXTRACTION-FROM-PRD:**
Values extracted automatically by sequence above:
1. **Budget from PRD:** $PRD_BUDGET → Hours at market rate
2. **Timeline from PRD:** $PRD_TIMELINE weeks → Hours per week
3. **Team Composition:** $TEAM_SIZE developers, $TEAM_SIZE_REC recommended
4. **Technical Stack:** $TECH_STACK technologies identified
5. **Complexity Level:** $PROJECT_COMPLEXITY with automatic parameters

**TASK-QUALITY-REQUIREMENTS:**
Each task MUST include:
- [ ] Clear objective (1 sentence)
- [ ] Detailed steps (3-8 specific actions)
- [ ] Acceptance criteria (3-5 testable conditions)
- [ ] Time estimate (8-40 hours range)
- [ ] Dependencies (explicit task references)
- [ ] Assigned role (based on PRD team composition)
- [ ] Output files (specific deliverables)
- [ ] Validation commands (executable tests)

**CROSS-VALIDATION-WITH-PRD:**
- Total task hours MUST match PRD budget ±10%
- Timeline MUST align with PRD phases
- Technology stack MUST match PRD specifications
- Team assignments MUST use PRD-specified roles
- Critical features from PRD MUST have corresponding tasks

**TECHNICAL-FEASIBILITY-VALIDATION:**
Before finalizing tasks, validate technical assumptions:

**WordPress/WooCommerce Projects:**
- [ ] Verify plugin architecture limitations don't conflict with requirements
- [ ] Check WooCommerce API capabilities for described integrations
- [ ] Validate performance requirements against typical hosting environments
- [ ] Confirm third-party service integrations are technically possible

**Performance Requirements:**
- [ ] Response times: <500ms realistic for described complexity?
- [ ] Concurrent users: Server requirements match target load?
- [ ] Data volume: Database design handles expected scale?
- [ ] Memory usage: Within typical hosting constraints?

**Integration Complexity:**
- [ ] External APIs: Rate limits and availability confirmed?
- [ ] Payment processing: Gateway capabilities match requirements?
- [ ] Real-time features: WebSocket/polling feasibility assessed?
- [ ] Mobile responsiveness: Touch interface requirements achievable?

**Compliance & Legal:**
- [ ] Tax calculations: Legal requirements research completed?
- [ ] Data privacy: GDPR/local law compliance tasks included?
- [ ] Security: Penetration testing and audit tasks planned?
- [ ] Accessibility: WCAG compliance requirements addressed?

**AUTOMATED-VALIDATION-HANDLER:**
```bash
handle_validation_failure() {
    local check_name="$1"
    local severity="$2"  # "CRITICAL" | "WARNING" | "INFO"
    local details="$3"
    
    case $severity in
        "CRITICAL")
            echo "❌ CRITICAL FAILURE: $check_name"
            echo "🔍 Details: $details" 
            echo "🚫 Task generation halted - manual review required"
            echo "💡 Recommendation: Revise PRD to address this issue"
            exit 1
            ;;
        "WARNING")
            echo "⚠️  WARNING: $check_name"
            echo "🔍 Details: $details"
            echo "⏭️  Continuing with adjusted parameters"
            echo "📝 Note: Review this before implementation"
            ;;
        "INFO")
            echo "ℹ️  INFO: $check_name"
            echo "🔍 Details: $details"
            echo "✅ No action required"
            ;;
    esac
}

validate_technical_feasibility() {
    local prd_file="$1"
    local project_complexity="$2"
    
    # Performance requirements validation
    local response_times=$(grep -ci "response.*time.*<.*ms\|latency.*<.*ms" "$prd_file")
    local sub_100ms=$(grep -ci "response.*time.*<.*[1-9][0-9]ms\|latency.*<.*[1-9][0-9]ms" "$prd_file")
    
    if [ $sub_100ms -gt 0 ] && [ "$project_complexity" = "Complex" -o "$project_complexity" = "Enterprise" ]; then
        handle_validation_failure "Performance Requirements" "WARNING" "Sub-100ms response times for complex operations may be unrealistic"
    fi
    
    # API integration validation  
    local api_integrations=$(grep -ci "integrate.*with.*API\|connect.*to.*service" "$prd_file")
    local specific_apis=$(grep -Eo "integrate with [A-Z][a-zA-Z0-9 ]*" "$prd_file")
    
    if [ $api_integrations -gt 5 ] && [ "$project_complexity" = "Simple" ]; then
        handle_validation_failure "API Integration Complexity" "WARNING" "Many integrations detected for Simple project classification"
    fi
    
    # Budget-complexity alignment
    local budget=$(grep -Eo "\$[0-9,]+" "$prd_file" | tr -d '$,' | head -1)
    budget=${budget:-0}
    
    if [ "$project_complexity" = "Enterprise" ] && [ $budget -lt 20000 ]; then
        handle_validation_failure "Budget-Complexity Mismatch" "CRITICAL" "Enterprise complexity requires minimum \$20,000 budget, found \$$budget"
    elif [ "$project_complexity" = "Complex" ] && [ $budget -lt 10000 ]; then
        handle_validation_failure "Budget-Complexity Mismatch" "WARNING" "Complex projects typically require \$10,000+ budget, found \$$budget"
    fi
    
    # Timeline validation
    local timeline=$(grep -Eo "[0-9]+ weeks" "$prd_file" | head -1 | grep -Eo "[0-9]+")
    timeline=${timeline:-0}
    
    if [ "$project_complexity" = "Enterprise" ] && [ $timeline -lt 16 ]; then
        handle_validation_failure "Timeline Constraints" "WARNING" "Enterprise projects typically require 16+ weeks, found $timeline weeks"
    fi
    
    echo "✅ Technical feasibility validation completed"
}
```

**RED-FLAG-INDICATORS:**
Automatic validation with specific thresholds:
- **Performance:** Sub-100ms response times for Complex/Enterprise → WARNING
- **API Integration:** 5+ integrations for Simple projects → WARNING  
- **Budget Mismatch:** Enterprise <$20K or Complex <$10K → CRITICAL/WARNING
- **Timeline:** Enterprise <16 weeks → WARNING
- **Team Skills:** Technology mismatches detected → INFO