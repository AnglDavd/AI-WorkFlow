# [STEP-03] Task Execution Master Guide

**WORKFLOW-POSITION:** Step 3 of 3 (PRD → TASKS → EXECUTION)
**INPUT-FILE:** `02_tasks_{session-id}_{project-name}.md` (provided as argument)
**OUTPUT-FILE:** `03_report_{session-id}_{project-name}.md`
**WORKFLOW-COMPLETE:** All files linked by same session-id for perfect traceability

**CRITICAL-EXTRACTION-LOGIC:**
```bash
# Parse input filename to extract components
# INPUT_FILE is already set by the calling script

# Validate input file provided
if [ -z "$INPUT_FILE" ]; then
    echo "ERROR: No input file provided"
    exit 1
fi

# Validate input format
if [[ ! "$INPUT_FILE" =~ ^02_tasks_[^_]+_.*\.md$ ]]; then
    echo "ERROR: Invalid input format. Expected: 02_tasks_{session-id}_{project-name}.md"
    exit 1
fi

# Extract and validate components with enhanced security checks
SESSION_ID=$(echo "$INPUT_FILE" | sed 's/02_tasks_\([^_]*\)_.*/\1/' | grep -E '^[a-zA-Z0-9]{4,8}$')
PROJECT_NAME=$(echo "$INPUT_FILE" | sed 's/02_tasks_[^_]*_\(.*\)\.md/\1/' | grep -E '^[a-zA-Z0-9][a-zA-Z0-9_-]*[a-zA-Z0-9]$')

if [ -z "$SESSION_ID" ] || [ -z "$PROJECT_NAME" ]; then
    echo "ERROR: Could not extract valid session ID or project name"
    echo "Session ID: '$SESSION_ID', Project Name: '$PROJECT_NAME'"
    exit 1
fi

# Define derived file paths
PRD_FILE="01_prd_${SESSION_ID}_${PROJECT_NAME}.md"
TASKS_FILE="$INPUT_FILE"
OUTPUT_FILE="03_report_${SESSION_ID}_${PROJECT_NAME}.md"

# Validate all required files exist
if [ ! -f "$PRD_FILE" ]; then
    echo "ERROR: PRD file not found: $PRD_FILE"
    echo "Expected files in workflow:"
    echo "  1. $PRD_FILE (PRD)"
    echo "  2. $TASKS_FILE (TASKS)"
    echo "  3. $OUTPUT_FILE (REPORT - will be created)"
    exit 1
fi

if [ ! -f "$TASKS_FILE" ]; then
    echo "ERROR: Tasks file not found: $TASKS_FILE"
    exit 1
fi

# Validate extraction success
echo "✅ Extracted SESSION_ID: $SESSION_ID"
echo "✅ Extracted PROJECT_NAME: $PROJECT_NAME"
echo "✅ Validated PRD_FILE: $PRD_FILE"
echo "✅ Validated TASKS_FILE: $TASKS_FILE"
echo "✅ Generated OUTPUT_FILE: $OUTPUT_FILE"
```

**Role:** Expert Senior Developer and DevOps Engineer with 15+ years experience

**Objective:** Execute implementation plan step-by-step with production-ready code and GitHub backup

**Structure Philosophy:** Sequential workflow completion with session ID maintains perfect project lifecycle tracking

**PRD-TASKS-CONSISTENCY-VALIDATION:**
Before starting execution, validate task file against PRD:
```bash
# Enhanced cross-validation with robust pattern matching
PRD_BUDGET=$(grep -Eo "\$[0-9,]+" "$PRD_FILE" | head -1 | tr -d '$,')
TASKS_HOURS=$(grep -Eo "\*\*Time:\*\* [0-9]+ hours" "$TASKS_FILE" | grep -Eo "[0-9]+" | awk '{sum+=$1} END {print sum}')
PRD_TIMELINE=$(grep -Eo "[0-9]+ weeks" "$PRD_FILE" | head -1)
TASKS_PHASES=$(grep -c "^## Phase" "$TASKS_FILE")

# Validate extracted values
if [ -z "$TASKS_HOURS" ] || ! [[ "$TASKS_HOURS" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Could not extract valid hour estimates from tasks file"
    echo "Expected format: **Time:** XX hours"
    echo "Please check task file format"
    exit 1
fi

if [ -z "$PRD_BUDGET" ] || ! [[ "$PRD_BUDGET" =~ ^[0-9]+$ ]]; then
    echo "WARNING: Could not extract budget from PRD file"
    echo "Proceeding without budget validation"
else
    # Basic budget-hour alignment check (assuming $25/hour average)
    EXPECTED_HOURS=$((PRD_BUDGET / 25))
    VARIANCE=$((TASKS_HOURS * 100 / EXPECTED_HOURS))
    if [ $VARIANCE -lt 80 ] || [ $VARIANCE -gt 120 ]; then
        echo "WARNING: Budget-hours mismatch detected"
        echo "PRD Budget: \$$PRD_BUDGET (~$EXPECTED_HOURS hours at \$25/hr)"
        echo "Tasks Hours: $TASKS_HOURS hours ($VARIANCE% of expected)"
    fi
fi

# Enhanced validation checks
if [ "$TASKS_HOURS" -lt 50 ] || [ "$TASKS_HOURS" -gt 3000 ]; then
    echo "ERROR: Task hours ($TASKS_HOURS) seem unrealistic"
    echo "Expected range: 50-3000 hours for typical projects"
    exit 1
fi

if [ "$TASKS_PHASES" -lt 3 ] || [ "$TASKS_PHASES" -gt 6 ]; then
    echo "ERROR: Phase count ($TASKS_PHASES) outside expected range"
    echo "Expected: 3-6 phases for structured development"
    exit 1
fi

echo "✅ Cross-validation passed: $TASKS_HOURS hours across $TASKS_PHASES phases"
if [ -n "$PRD_BUDGET" ]; then
    echo "✅ Budget alignment: \$$PRD_BUDGET budget vs $TASKS_HOURS hours"
fi

# CRITICAL: Execute validation functions that were previously only defined
echo "🔍 Executing session consistency validation..."
if ! validate_session_consistency "$SESSION_ID"; then
    echo "❌ Session validation failed - execution cannot continue"
    exit 1
fi

echo "🔍 Executing dependency validation for Phase 1..."
validate_task_dependencies 1 1
```

**EXECUTION-ERROR-HANDLING:**

**Session Consistency Validation:**
Before starting execution, validate session state:
```bash
validate_session_consistency() {
    local session_id="$1"
    local prd_count=$(ls 01_prd_${session_id}_*.md 2>/dev/null | wc -l)
    local tasks_count=$(ls 02_tasks_${session_id}_*.md 2>/dev/null | wc -l)
    
    if [ $prd_count -ne 1 ]; then
        echo "ERROR: Session $session_id has $prd_count PRD files (expected 1)"
        return 1
    fi
    
    if [ $tasks_count -ne 1 ]; then
        echo "ERROR: Session $session_id has $tasks_count TASKS files (expected 1)"
        return 1
    fi
    
    echo "✅ Session consistency validated for session: $session_id"
    return 0
}
```

**Missing Dependencies:**
If task dependencies aren't met:
1. **STOP** execution immediately
2. **IDENTIFY** which prerequisite tasks are incomplete
3. **REQUEST** completion of dependencies before proceeding
4. **DO NOT** skip or work around missing dependencies

**Dependency Validation:**
```bash
validate_task_dependencies() {
    local current_phase="$1"
    local current_task="$2"
    
    # Check if previous phase completed successfully
    if [ $current_phase -gt 1 ]; then
        local prev_phase=$((current_phase - 1))
        echo "Validating Phase $prev_phase completion before starting Phase $current_phase"
        # Implementation would check completion markers
    fi
}
```

**Technical Blockers:**
If implementation hits technical barriers:
1. **DOCUMENT** the specific technical issue
2. **RESEARCH** alternative implementation approaches
3. **ESTIMATE** time impact of workaround solutions
4. **REQUEST** stakeholder decision on approach

**Resource Constraints:**
If team/budget constraints emerge:
1. **CALCULATE** actual vs planned resource consumption
2. **IDENTIFY** tasks that can be descoped or deferred
3. **PRESENT** options with impact analysis
4. **GET APPROVAL** before scope changes

**Quality Gate Failures:**
If validation commands fail:
1. **DO NOT PROCEED** to next task
2. **ANALYZE** root cause of failure
3. **IMPLEMENT** fixes to meet acceptance criteria
4. **RE-RUN** validation until all criteria pass

**CRITICAL-CHECKPOINTS:**
Stop and validate at these points:
- [ ] End of Phase 1: Core architecture functional
- [ ] End of Phase 2: Core features working
- [ ] End of Phase 3: Quality gates passed
- [ ] End of Phase 4: Production deployment ready
- [ ] End of Phase 5: Documentation complete

## Execution Process

### Step 1: Preparation & GitHub Setup

**Environment Setup:**
- Verify all development tools and dependencies
- Initialize Git repository if needed
- Configure GitHub repository and authentication
- Set up development environment from task specifications

**GitHub Integration Setup:**
```bash
# Extract project title from PRD for proper naming
PROJECT_TITLE=$(grep "^- \*\*Project Name:\*\*" "$PRD_FILE" | cut -d':' -f2- | xargs)
if [ -z "$PROJECT_TITLE" ]; then
    # Fallback: use project name from filename
    PROJECT_TITLE=$(echo "$PROJECT_NAME" | tr '-' ' ' | sed 's/\b\w/\u&/g')
fi

# Initialize Git if not exists
if [ ! -d ".git" ]; then
    git init
    echo "# $PROJECT_TITLE - Implementation Log" > README.md
    echo "" >> README.md
    echo "**Session ID:** $SESSION_ID" >> README.md  
    echo "**Generated:** $(date)" >> README.md
    echo "**Framework:** AI Development Framework v1.1" >> README.md
    echo "" >> README.md
    echo "## Implementation Progress" >> README.md
    echo "- [ ] Phase 1: Foundation & Setup" >> README.md
    echo "- [ ] Phase 2: Core Feature Development" >> README.md
    echo "- [ ] Phase 3: Quality Assurance & Testing" >> README.md
    echo "- [ ] Phase 4: Deployment & Production" >> README.md
    echo "- [ ] Phase 5: Monitoring & Maintenance" >> README.md
    
    git add README.md
    git commit -m "Initial commit: $PROJECT_TITLE setup

Session ID: $SESSION_ID
Generated by AI Development Framework"
else
    echo "Git repository already exists, updating README..."
    echo "# $PROJECT_TITLE - Implementation Log" > README.md
fi

# Configure for automated commits
git config user.name "AI Development Framework"
git config user.email "ai-framework@$(hostname)"

# Create implementation branch with session ID
BRANCH_NAME="implementation-${SESSION_ID}"
if ! git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
    git checkout -b "$BRANCH_NAME"
    echo "✅ Created implementation branch: $BRANCH_NAME"
else
    git checkout "$BRANCH_NAME"
    echo "✅ Switched to existing branch: $BRANCH_NAME"
fi
```

### Step 2: Phase-by-Phase Execution

**Execution Pattern for Each Phase:**

1. **Phase Start Backup**
   - Commit current state with phase start message
   - Create phase documentation
   - Tag phase beginning

2. **Task-by-Task Implementation**
   - Execute each task completely with production-ready code
   - Include comprehensive error handling and validation
   - Write tests alongside implementation
   - Backup after each major milestone

3. **Phase Completion Validation**
   - Run all acceptance criteria tests
   - Execute quality gates and validation commands
   - Document phase completion
   - Create phase completion backup

4. **GitHub Sync**
   - Push all changes to GitHub
   - Update documentation and release notes

### Step 3: Production-Ready Code Standards

**Error Handling:**
```typescript
try {
    const result = await performOperation();
    return result;
} catch (error) {
    logger.error('Operation failed', { error: error.message, stack: error.stack });
    throw new CustomError('Operation failed', error);
}
```

**Input Validation:**
```typescript
function validateInput(data: InputType): ValidationResult {
    if (!data || typeof data !== 'object') {
        return { valid: false, errors: ['Invalid input format'] };
    }
    // Comprehensive validation logic
    return { valid: errors.length === 0, errors };
}
```

**Testing Implementation:**
```typescript
describe('Component', () => {
    it('should handle valid input correctly', async () => {
        const result = await processData(validData);
        expect(result).toBeDefined();
        expect(result.status).toBe('success');
    });
    
    it('should handle errors gracefully', async () => {
        await expect(processData(invalidData))
            .rejects.toThrow(ValidationError);
    });
});
```

### Step 4: Continuous Backup Strategy

**Milestone Backups:**
```bash
backup_milestone() {
    local milestone_name="$1"
    local phase="$2"
    
    git add .
    git commit -m "feat($phase): Complete $milestone_name

    - [List accomplishments]
    - [Files created/modified]
    - [Tests implemented]
    - [Quality checks passed]
    
    Acceptance Criteria Met:
    - [Criterion 1]
    - [Criterion 2]
    
    Generated by AI Development Framework"
    
    git push origin implementation-$(date +%Y%m%d)
}
```

### Step 5: Quality Validation

**Continuous Quality Checks:**
```bash
# Code quality validation
npm run lint && npm run type-check && npm test
# Security scanning
npm audit
# Performance validation
npm run perf-test
```

### Step 6: Mandatory Auto-Healing Quality Validation

**CRITICAL REQUIREMENT:** All projects MUST pass auto-healing validation before completion.

**Objective:** Ensure application meets professional standards (8/10 minimum across all dimensions) through automated healing with supervised approval for complex changes.

**Prerequisites:**
- Application deployed and accessible via URL
- MCP Playwright installed and functional (`claude mcp add playwright npx '@playwright/mcp@latest'`)
- All previous phases (1-5) completed successfully

**Auto-Healing Protocol:**

#### Step 6.1: Comprehensive Quality Analysis
Execute automated healing analysis using MCP Playwright:

**Required Files to Load:**
- `ui_healing_guide.md` (complete healing instructions)
- `ui_healing_standards.json` (technical standards and scoring matrix)
- `cro_optimization_patterns.json` (88 proven CRO patterns)

**Analysis Dimensions (ALL must achieve >= 8/10):**
- **Visual Consistency (20% weight)** - Design system adherence
- **CRO Optimization (25% weight)** - Conversion rate optimization
- **Accessibility (20% weight)** - WCAG 2.1 compliance
- **Architecture Quality (15% weight)** - Code structure quality
- **Performance (10% weight)** - Load times and optimization
- **Responsive Design (10% weight)** - Multi-device support

#### Step 6.2: Intelligent Healing Classification
AI automatically categorizes required fixes:

**LEVEL 1 - Auto-Apply (No Supervision Required):**
```javascript
SAFE_AUTO_FIXES = {
  accessibility: [
    "add_alt_text_to_images",
    "fix_color_contrast_simple", 
    "add_aria_labels_to_buttons",
    "fix_heading_hierarchy",
    "add_focus_indicators",
    "fix_tab_order_issues"
  ],
  performance: [
    "add_image_lazy_loading",
    "minify_css_js_files",
    "add_meta_viewport",
    "optimize_image_formats",
    "implement_browser_caching",
    "compress_text_assets"
  ],
  responsive: [
    "fix_overflow_issues",
    "adjust_touch_target_sizes",
    "add_responsive_breakpoints",
    "fix_mobile_navigation",
    "optimize_mobile_forms"
  ],
  visual_consistency: [
    "fix_color_palette_violations",
    "standardize_button_styles",
    "fix_typography_inconsistencies",
    "align_spacing_patterns",
    "standardize_component_styles"
  ]
}
```

**LEVEL 2 - Supervised Approval Required:**
```javascript
SUPERVISED_FIXES = {
  architecture: [
    "component_restructuring",
    "api_endpoint_modifications", 
    "database_schema_changes",
    "framework_upgrades",
    "major_refactoring"
  ],
  cro_optimization: [
    "layout_structural_changes",
    "navigation_redesign",
    "form_flow_modifications",
    "pricing_display_changes",
    "checkout_process_changes"
  ],
  major_performance: [
    "code_splitting_implementation",
    "cdn_integration_setup",
    "caching_strategy_overhaul",
    "server_optimization"
  ],
  design_system_changes: [
    "brand_color_modifications",
    "typography_system_changes",
    "component_design_overhauls",
    "layout_pattern_changes"
  ]
}
```

#### Step 6.3: Automated Healing Execution
```javascript
// AI executes this healing protocol automatically:
async function executeAutoHealing(analysisResults, sessionId) {
  const fixes = categorizeRequiredFixes(analysisResults);
  
  console.log(`🔍 Healing Analysis Complete: ${fixes.total} issues found`);
  console.log(`✅ Level 1 (Auto-fix): ${fixes.level1.length} issues`);
  console.log(`⚠️  Level 2 (Supervised): ${fixes.level2.length} issues`);
  
  // Apply Level 1 fixes automatically
  for (const fix of fixes.level1) {
    await applyAutoFix(fix);
    console.log(`✅ Auto-applied: ${fix.description}`);
  }
  
  // Request supervision for Level 2 fixes
  if (fixes.level2.length > 0) {
    await requestSupervision(fixes.level2, sessionId);
    await waitForApproval(sessionId);
  }
  
  // Re-test after all fixes applied
  const newScores = await runHealingAnalysis();
  
  if (allDimensionsPass(newScores)) {
    generateSuccessReport(sessionId);
    return "HEALING_SUCCESS";
  } else {
    escalateToUser(sessionId, newScores);
    return "MANUAL_INTERVENTION_REQUIRED";
  }
}
```

#### Step 6.4: Supervision Workflow for Complex Changes
When Level 2 fixes are needed, AI generates detailed supervision request:

```markdown
🚨 SUPERVISION REQUIRED: Complex healing changes detected

Session: ${SESSION_ID}
Project: ${PROJECT_NAME}

Current Scores Requiring Attention:
- [Dimension]: X.X/10 (needs improvement)
- [Dimension]: X.X/10 (needs improvement)

Proposed Level 2 Changes:

1. **Change Category**: [e.g., CRO Layout Optimization]
   **Risk Level**: [Low/Medium/High]
   **Description**: [Detailed explanation]
   **Impact**: [What will change]
   **Rationale**: [Why this change is needed]
   **Alternatives**: [Other approaches considered]

2. **Change Category**: [e.g., Architecture Improvement]
   **Risk Level**: [Low/Medium/High]
   **Description**: [Detailed explanation]
   **Impact**: [What will change]
   **Rationale**: [Why this change is needed]
   **Alternatives**: [Other approaches considered]

Supervision Options:
A) Approve all proposed changes
B) Approve selected changes (specify which)
C) Request alternative approaches
D) Manual review and custom implementation

Please respond with your choice: [A/B/C/D]

If B, specify approved changes: [list numbers]
If C, specify concerns: [detailed feedback]
```

#### Step 6.5: Validation and Completion
After all fixes applied (auto + supervised):

1. **Re-run complete healing analysis**
2. **Verify ALL dimensions >= 8/10**
3. **Generate final validation report**
4. **Create GitHub backup of healed application**
5. **Mark project as COMPLETE only if healing passes**

**Healing Success Criteria (ALL REQUIRED):**
- ✅ Visual Consistency >= 8/10
- ✅ CRO Optimization >= 8/10
- ✅ Accessibility >= 8/10
- ✅ Architecture Quality >= 8/10
- ✅ Performance >= 8/10
- ✅ Responsive Design >= 8/10

#### Step 6.6: Healing Failure Protocol
If healing cannot achieve 8/10 on all dimensions after fixes:

1. **Generate comprehensive remediation plan**
2. **Provide step-by-step manual healing guide**
3. **Mark project status as "REQUIRES_MANUAL_HEALING"**
4. **Block project completion until healing standards met**
5. **Create detailed technical debt report**

```bash
# Healing failure example output:
echo "❌ HEALING VALIDATION FAILED"
echo "📊 Current Scores:"
echo "   - Architecture: 6.2/10 (FAILED - requires major refactoring)"
echo "   - Performance: 5.8/10 (FAILED - infrastructure optimization needed)"
echo ""
echo "📋 Manual Remediation Required:"
echo "   See: 03_healing_${SESSION_ID}_${PROJECT_NAME}.md"
echo ""
echo "🚫 Project marked as: REQUIRES_MANUAL_HEALING"
echo "⚠️  Cannot complete until ALL dimensions >= 8/10"
```

### Step 7: Final Release (Only After Healing Success)

**Project Completion (Conditional on Healing Success):**
```bash
# Only execute if healing validation passed
if [ "$HEALING_STATUS" = "SUCCESS" ]; then
    # Create final release tag
    git tag -a "v1.0.0" -m "Production release: Implementation + Healing complete

    All PRD requirements implemented and validated.
    Comprehensive testing completed.
    Auto-healing validation passed (all dimensions >= 8/10).
    Production environment ready.

    Healing Scores:
    - Visual Consistency: ${VISUAL_SCORE}/10
    - CRO Optimization: ${CRO_SCORE}/10
    - Accessibility: ${A11Y_SCORE}/10
    - Architecture Quality: ${ARCH_SCORE}/10
    - Performance: ${PERF_SCORE}/10
    - Responsive Design: ${RESP_SCORE}/10

    Generated by AI Development Framework v3.1.1"

    # Create release notes and handover documentation
    git push origin --tags
    git checkout main
    git merge implementation-$(date +%Y%m%d) --no-ff
    git push origin main
    
    echo "🎉 PROJECT COMPLETED SUCCESSFULLY WITH HEALING VALIDATION"
else
    echo "❌ PROJECT CANNOT BE COMPLETED - HEALING VALIDATION REQUIRED"
    echo "📋 Address issues in healing report before final release"
fi
```

### Step 7: MANDATORY Iterative Quality Loop (Replaces Single Healing Step)

**CRITICAL ENHANCEMENT:** Replace single healing validation with iterative improvement loop until 8/10+ achieved.

```bash
# ITERATIVE QUALITY IMPROVEMENT SYSTEM
execute_iterative_quality_loop() {
    local session_id="$1"
    local project_name="$2"
    local max_iterations=5
    local current_iteration=1
    
    echo "🔄 Starting Iterative Quality Loop for Session: $session_id"
    echo "📋 Target: ALL dimensions >= 8/10"
    echo "🎯 Maximum iterations: $max_iterations"
    echo ""
    
    while [ $current_iteration -le $max_iterations ]; do
        echo "🔍 === ITERATION $current_iteration of $max_iterations ==="
        
        # 1. Comprehensive Quality Audit with MCP Context7
        echo "📊 Step 1: Running comprehensive audit..."
        audit_results=$(run_enhanced_audit_with_context7 "$session_id")
        
        # 2. Extract scores and analyze results
        overall_score=$(extract_overall_score "$audit_results")
        failing_dimensions=$(extract_failing_dimensions "$audit_results")
        improvement_areas=$(extract_improvement_opportunities "$audit_results")
        
        echo "📈 Current Overall Score: $overall_score/10"
        
        # 3. Check if quality threshold met
        if [ "$overall_score" -ge 8 ] && [ -z "$failing_dimensions" ]; then
            echo "✅ QUALITY THRESHOLD ACHIEVED!"
            echo "🎉 All dimensions >= 8/10"
            echo "📋 Project approved for release"
            
            # Generate final quality report
            generate_final_quality_report "$session_id" "$audit_results" "$current_iteration"
            mark_project_complete_with_quality_seal "$session_id"
            return 0
        fi
        
        # 4. Research current best practices for failing areas
        echo "🔬 Step 2: Researching improvement strategies with MCP Context7..."
        research_improvement_strategies "$failing_dimensions" "$improvement_areas"
        
        # 5. Generate targeted improvement tasks
        echo "🛠️ Step 3: Generating improvement tasks for iteration $current_iteration..."
        generate_targeted_improvement_tasks "$session_id" "$failing_dimensions" "$current_iteration"
        
        # 6. Execute improvements automatically
        echo "⚡ Step 4: Executing automatic improvements..."
        execute_automatic_improvements "$session_id" "$current_iteration"
        
        # 7. Create iteration backup
        echo "💾 Step 5: Creating iteration $current_iteration backup..."
        create_iteration_backup "$session_id" "$current_iteration" "$overall_score"
        
        echo ""
        echo "📊 Iteration $current_iteration Summary:"
        echo "   - Previous score: $overall_score/10"
        echo "   - Failing dimensions: ${failing_dimensions:-None}"
        echo "   - Improvements applied: ✅"
        echo "   - Backup created: ✅"
        echo ""
        
        current_iteration=$((current_iteration + 1))
        sleep 2  # Brief pause between iterations
    done
    
    # If we reach here, maximum iterations exceeded
    echo "⚠️ MAXIMUM ITERATIONS REACHED ($max_iterations)"
    echo "📋 Project requires manual intervention"
    
    # Generate comprehensive manual improvement guide
    generate_manual_improvement_plan "$session_id" "$failing_dimensions" "$audit_results"
    mark_project_needs_manual_review "$session_id"
    
    return 1
}

# Enhanced audit function with MCP Context7 integration
run_enhanced_audit_with_context7() {
    local session_id="$1"
    
    echo "🔍 Running enhanced audit with current best practices research..."
    
    # 1. Load current standards via MCP Context7
    echo "📚 Loading latest quality standards..."
    load_current_quality_standards_with_context7
    
    # 2. Execute comprehensive healing analysis
    echo "🏥 Executing healing analysis with updated standards..."
    healing_results=$(execute_healing_analysis "$session_id")
    
    # 3. Validate against industry benchmarks
    echo "📊 Validating against current industry benchmarks..."
    benchmark_validation=$(validate_against_industry_benchmarks "$healing_results")
    
    echo "$healing_results"
}

# Generate targeted improvement tasks based on failing dimensions
generate_targeted_improvement_tasks() {
    local session_id="$1"
    local failing_dimensions="$2"
    local iteration="$3"
    
    local iteration_tasks_file="02_tasks_${session_id}_iteration_${iteration}.md"
    
    echo "📝 Generating targeted tasks for failing dimensions: $failing_dimensions"
    
    cat > "$iteration_tasks_file" << EOF
# Iteration $iteration - Targeted Quality Improvements

## Session Information
- **Session ID:** $session_id
- **Iteration:** $iteration
- **Target:** Address failing dimensions: $failing_dimensions
- **Generated:** $(date)

## Improvement Tasks

EOF

    # Generate specific tasks based on failing dimensions
    IFS=',' read -ra DIMENSIONS <<< "$failing_dimensions"
    for dimension in "${DIMENSIONS[@]}"; do
        case "$dimension" in
            "visual_consistency")
                add_visual_consistency_tasks "$iteration_tasks_file"
                ;;
            "cro_optimization")
                add_cro_optimization_tasks "$iteration_tasks_file"
                ;;
            "accessibility")
                add_accessibility_improvement_tasks "$iteration_tasks_file"
                ;;
            "architecture")
                add_architecture_improvement_tasks "$iteration_tasks_file"
                ;;
            "performance")
                add_performance_optimization_tasks "$iteration_tasks_file"
                ;;
            "responsive_design")
                add_responsive_improvement_tasks "$iteration_tasks_file"
                ;;
        esac
    done
    
    echo "✅ Iteration tasks generated: $iteration_tasks_file"
}

# Execute automatic improvements
execute_automatic_improvements() {
    local session_id="$1"
    local iteration="$2"
    
    local iteration_tasks_file="02_tasks_${session_id}_iteration_${iteration}.md"
    
    echo "⚡ Executing automatic improvements from: $iteration_tasks_file"
    
    # Execute tasks with Context7 enhanced guidance
    execute_tasks_with_context7_guidance "$iteration_tasks_file"
    
    echo "✅ Automatic improvements completed for iteration $iteration"
}

# Create iteration backup with quality metrics
create_iteration_backup() {
    local session_id="$1"
    local iteration="$2"
    local score="$3"
    
    git add .
    git commit -m "feat(iteration-$iteration): Quality improvement iteration $iteration

Score: $score/10
Automated improvements applied
Iteration backup for session: $session_id

🔄 Iterative Quality Loop - Iteration $iteration
📊 Quality Score: $score/10
⚡ Automated improvements executed
🎯 Target: All dimensions >= 8/10

Generated by AI Development Framework v3.1.1 Enhanced"
    
    git tag "iteration-$iteration-$session_id"
    echo "✅ Iteration $iteration backup created with tag: iteration-$iteration-$session_id"
}

# Mark project complete with quality seal
mark_project_complete_with_quality_seal() {
    local session_id="$1"
    
    echo "🏆 MARKING PROJECT COMPLETE WITH QUALITY SEAL"
    
    git tag -a "v1.0.0-quality-certified" -m "🏆 QUALITY CERTIFIED RELEASE

✅ ALL dimensions achieved >= 8/10
🔄 Iterative quality loop completed successfully
📊 Professional quality standards exceeded
🎯 Ready for production deployment

Session: $session_id
Certification: AI Development Framework v3.1.1 Enhanced
Certified: $(date)

This release has been automatically validated and certified 
to meet professional quality standards across all dimensions."

    echo "🎉 PROJECT SUCCESSFULLY COMPLETED WITH QUALITY CERTIFICATION!"
}
```

**Enhanced Final Success Criteria:** 
- Complete project with production-ready code
- Full test coverage and comprehensive documentation
- **ALL healing dimensions >= 8/10 achieved through iterative loop**
- Maximum 5 iterations allowed before manual review required
- Complete GitHub backup history with iteration tracking
- Quality certification seal applied to final release
- Professional quality standards exceeded (not just met)