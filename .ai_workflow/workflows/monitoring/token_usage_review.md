# Token Usage Review and Optimization

## Purpose
Comprehensive token usage analysis and optimization workflow for the AI-Assisted Development Framework. This workflow monitors, analyzes, and optimizes token consumption across all framework operations to achieve cost efficiency while maintaining quality.

## When to Use
- Periodic token economy reviews (weekly/monthly)
- Before major workflow deployments
- When identifying cost optimization opportunities
- As part of framework maintenance cycles

## Objective
Analyze token usage patterns, identify optimization opportunities, implement cost-saving measures, and provide actionable recommendations for reducing AI operational costs while maintaining or improving output quality.

## Pre-conditions
- Framework is operational with workflows in use
- Token usage data is available for analysis
- Optimization tools are accessible
- Baseline metrics are established

## Commands
```bash
# Initialize token review session
TOKEN_REVIEW_SESSION="token_review_$(date +%Y%m%d_%H%M%S)"
REVIEW_DIR=".ai_workflow/state/token_reviews/$TOKEN_REVIEW_SESSION"
mkdir -p "$REVIEW_DIR"

# Log workflow start
./.ai_workflow/workflows/common/log_work_journal.md "INFO" "Starting token usage review session: $TOKEN_REVIEW_SESSION"

echo "💰 Starting Token Usage Review and Optimization"
echo "📊 Session ID: $TOKEN_REVIEW_SESSION"
echo "📁 Review directory: $REVIEW_DIR"
echo ""

# Set review parameters
REVIEW_PERIOD="${TOKEN_REVIEW_PERIOD:-30}"  # Days to analyze
COST_TARGET="${TOKEN_COST_TARGET:-40}"      # Target cost reduction percentage
ANALYSIS_DEPTH="${TOKEN_ANALYSIS_DEPTH:-comprehensive}"  # basic|detailed|comprehensive

echo "🎯 Review Parameters:"
echo "   • Analysis Period: $REVIEW_PERIOD days"
echo "   • Cost Reduction Target: $COST_TARGET%"
echo "   • Analysis Depth: $ANALYSIS_DEPTH"
echo ""

# Function to collect token usage data
collect_token_usage_data() {
    echo "📊 Collecting token usage data..."
    
    local data_file="$REVIEW_DIR/token_usage_data.json"
    local summary_file="$REVIEW_DIR/usage_summary.txt"
    
    # Initialize data collection
    cat > "$data_file" << EOF
{
  "collection_info": {
    "session_id": "$TOKEN_REVIEW_SESSION",
    "collection_date": "$(date -Iseconds)",
    "analysis_period_days": $REVIEW_PERIOD,
    "framework_version": "$(get_framework_version)"
  },
  "workflows": {},
  "prompts": {},
  "templates": {},
  "total_usage": {}
}
EOF
    
    # Collect workflow token usage
    echo "🔄 Analyzing workflow token usage..."
    analyze_workflow_token_usage >> "$summary_file"
    
    # Collect prompt token usage
    echo "📝 Analyzing prompt token usage..."
    analyze_prompt_token_usage >> "$summary_file"
    
    # Collect template token usage
    echo "📋 Analyzing template token usage..."
    analyze_template_token_usage >> "$summary_file"
    
    # Generate usage statistics
    echo "📈 Generating usage statistics..."
    generate_usage_statistics >> "$summary_file"
    
    echo "✅ Token usage data collection completed"
}

# Function to analyze workflow token usage
analyze_workflow_token_usage() {
    echo ""
    echo "🔄 WORKFLOW TOKEN USAGE ANALYSIS"
    echo "================================="
    echo ""
    
    local workflow_dir=".ai_workflow/workflows"
    local total_workflow_tokens=0
    local workflow_count=0
    
    # Analyze each workflow category
    for category in setup prd prp run security monitoring; do
        if [ -d "$workflow_dir/$category" ]; then
            echo "📁 Category: $category"
            local category_tokens=0
            local category_files=0
            
            find "$workflow_dir/$category" -name "*.md" | while read -r workflow_file; do
                if [ -f "$workflow_file" ]; then
                    local tokens=$(estimate_file_tokens "$workflow_file")
                    local filename=$(basename "$workflow_file")
                    
                    category_tokens=$((category_tokens + tokens))
                    category_files=$((category_files + 1))
                    
                    if [ $tokens -gt 1000 ]; then
                        echo "   ⚠️  $filename: $(printf '%,d' $tokens) tokens (HIGH)"
                    elif [ $tokens -gt 500 ]; then
                        echo "   ⚡ $filename: $(printf '%,d' $tokens) tokens (MEDIUM)"
                    else
                        echo "   ✅ $filename: $(printf '%,d' $tokens) tokens (LOW)"
                    fi
                fi
            done
            
            echo "   📊 Category Total: $(printf '%,d' $category_tokens) tokens ($category_files files)"
            echo ""
            
            total_workflow_tokens=$((total_workflow_tokens + category_tokens))
            workflow_count=$((workflow_count + category_files))
        fi
    done
    
    echo "📊 WORKFLOW SUMMARY:"
    echo "   • Total Workflows: $workflow_count files"
    echo "   • Total Tokens: $(printf '%,d' $total_workflow_tokens) tokens"
    echo "   • Average per Workflow: $(printf '%,d' $((total_workflow_tokens / workflow_count))) tokens"
    echo "   • Estimated Cost: \$$(calculate_token_cost $total_workflow_tokens)"
}

# Function to analyze prompt token usage
analyze_prompt_token_usage() {
    echo ""
    echo "📝 PROMPT TOKEN USAGE ANALYSIS"
    echo "=============================="
    echo ""
    
    local prp_dir=".ai_workflow/PRPs"
    local total_prompt_tokens=0
    local prompt_count=0
    
    # Analyze PRP templates
    if [ -d "$prp_dir/templates" ]; then
        echo "📋 PRP Templates Analysis:"
        find "$prp_dir/templates" -name "*.md" | while read -r template_file; do
            if [ -f "$template_file" ]; then
                local tokens=$(estimate_file_tokens "$template_file")
                local filename=$(basename "$template_file")
                
                total_prompt_tokens=$((total_prompt_tokens + tokens))
                prompt_count=$((prompt_count + 1))
                
                if [ $tokens -gt 2000 ]; then
                    echo "   🔴 $filename: $(printf '%,d' $tokens) tokens (VERY HIGH - OPTIMIZE)"
                elif [ $tokens -gt 1000 ]; then
                    echo "   🟡 $filename: $(printf '%,d' $tokens) tokens (HIGH)"
                else
                    echo "   🟢 $filename: $(printf '%,d' $tokens) tokens (OPTIMAL)"
                fi
            fi
        done
        echo ""
    fi
    
    # Analyze example PRPs
    if [ -d "$prp_dir" ]; then
        echo "📄 Example PRPs Analysis:"
        find "$prp_dir" -maxdepth 1 -name "*.md" | head -5 | while read -r prp_file; do
            if [ -f "$prp_file" ]; then
                local tokens=$(estimate_file_tokens "$prp_file")
                local filename=$(basename "$prp_file")
                
                total_prompt_tokens=$((total_prompt_tokens + tokens))
                prompt_count=$((prompt_count + 1))
                
                echo "   📋 $filename: $(printf '%,d' $tokens) tokens"
            fi
        done
        echo ""
    fi
    
    echo "📊 PROMPT SUMMARY:"
    echo "   • Total Prompts Analyzed: $prompt_count files"
    echo "   • Total Tokens: $(printf '%,d' $total_prompt_tokens) tokens"
    echo "   • Average per Prompt: $(printf '%,d' $((total_prompt_tokens / prompt_count))) tokens"
    echo "   • Estimated Cost: \$$(calculate_token_cost $total_prompt_tokens)"
}

# Function to analyze template token usage
analyze_template_token_usage() {
    echo ""
    echo "📋 TEMPLATE TOKEN USAGE ANALYSIS"
    echo "================================"
    echo ""
    
    local total_template_tokens=0
    local template_count=0
    
    # Analyze various template types
    local template_patterns=(
        "README*.md"
        "CLAUDE.md"
        "ARCHITECTURE.md"
        "FRAMEWORK_GUIDE.md"
        "*_template.md"
        "template_*.md"
    )
    
    for pattern in "${template_patterns[@]}"; do
        find . -name "$pattern" -not -path "./.git/*" | while read -r template_file; do
            if [ -f "$template_file" ]; then
                local tokens=$(estimate_file_tokens "$template_file")
                local filename=$(basename "$template_file")
                local relative_path=$(echo "$template_file" | sed 's|^\./||')
                
                total_template_tokens=$((total_template_tokens + tokens))
                template_count=$((template_count + 1))
                
                if [ $tokens -gt 3000 ]; then
                    echo "   🔴 $relative_path: $(printf '%,d' $tokens) tokens (VERY HIGH)"
                elif [ $tokens -gt 1500 ]; then
                    echo "   🟡 $relative_path: $(printf '%,d' $tokens) tokens (HIGH)"
                else
                    echo "   🟢 $relative_path: $(printf '%,d' $tokens) tokens (OPTIMAL)"
                fi
            fi
        done
    done
    
    echo ""
    echo "📊 TEMPLATE SUMMARY:"
    echo "   • Total Templates: $template_count files"
    echo "   • Total Tokens: $(printf '%,d' $total_template_tokens) tokens"
    if [ $template_count -gt 0 ]; then
        echo "   • Average per Template: $(printf '%,d' $((total_template_tokens / template_count))) tokens"
    fi
    echo "   • Estimated Cost: \$$(calculate_token_cost $total_template_tokens)"
}

# Function to estimate tokens in a file
estimate_file_tokens() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "0"
        return
    fi
    
    # More accurate token estimation
    local word_count=$(wc -w < "$file" 2>/dev/null || echo "0")
    local char_count=$(wc -c < "$file" 2>/dev/null || echo "0")
    
    # Token estimation: ~0.75 tokens per word, adjusted for markdown
    local estimated_tokens=$((word_count * 3 / 4 + char_count / 100))
    
    echo "$estimated_tokens"
}

# Function to calculate token cost
calculate_token_cost() {
    local tokens="$1"
    
    # Using GPT-4 pricing as baseline: $0.03 per 1K tokens
    local cost=$(echo "scale=6; $tokens * 0.00003" | bc -l 2>/dev/null || echo "0.000000")
    
    printf "%.4f" "$cost"
}

# Function to generate usage statistics
generate_usage_statistics() {
    echo ""
    echo "📈 OVERALL USAGE STATISTICS"
    echo "==========================="
    echo ""
    
    # Calculate framework-wide statistics
    local total_md_files=$(find . -name "*.md" -not -path "./.git/*" | wc -l)
    local total_tokens=0
    local high_token_files=0
    local optimization_candidates=0
    
    # Analyze all markdown files
    find . -name "*.md" -not -path "./.git/*" | while read -r md_file; do
        local tokens=$(estimate_file_tokens "$md_file")
        total_tokens=$((total_tokens + tokens))
        
        if [ $tokens -gt 2000 ]; then
            high_token_files=$((high_token_files + 1))
            optimization_candidates=$((optimization_candidates + 1))
        elif [ $tokens -gt 1000 ]; then
            high_token_files=$((high_token_files + 1))
        fi
    done
    
    local avg_tokens_per_file=$((total_tokens / total_md_files))
    local total_cost=$(calculate_token_cost $total_tokens)
    local potential_savings=$(echo "scale=2; $total_cost * $COST_TARGET / 100" | bc -l)
    
    echo "📊 FRAMEWORK-WIDE STATISTICS:"
    echo "   • Total Markdown Files: $(printf '%,d' $total_md_files)"
    echo "   • Total Estimated Tokens: $(printf '%,d' $total_tokens)"
    echo "   • Average Tokens per File: $(printf '%,d' $avg_tokens_per_file)"
    echo "   • High Token Files (>1K): $high_token_files"
    echo "   • Optimization Candidates (>2K): $optimization_candidates"
    echo ""
    
    echo "💰 COST ANALYSIS:"
    echo "   • Current Estimated Cost: \$$total_cost"
    echo "   • Target Reduction ($COST_TARGET%): \$$potential_savings"
    echo "   • Optimized Estimated Cost: \$$(echo "scale=4; $total_cost - $potential_savings" | bc -l)"
    echo ""
    
    echo "🎯 OPTIMIZATION OPPORTUNITIES:"
    if [ $optimization_candidates -gt 0 ]; then
        echo "   • $optimization_candidates files identified for optimization"
        echo "   • Potential token reduction: 20-40%"
        echo "   • Estimated cost savings: \$$potential_savings"
        echo "   • ROI: High (automated optimization available)"
    else
        echo "   • Framework is well-optimized"
        echo "   • Consider micro-optimizations for marginal gains"
        echo "   • Focus on new content optimization"
    fi
}

# Function to identify optimization opportunities
identify_optimization_opportunities() {
    echo "🔍 Identifying optimization opportunities..."
    
    local opportunities_file="$REVIEW_DIR/optimization_opportunities.md"
    
    cat > "$opportunities_file" << 'EOF'
# Token Optimization Opportunities

## High-Priority Optimizations

### Large Files (>2000 tokens)
EOF
    
    # Find large files for optimization
    find . -name "*.md" -not -path "./.git/*" | while read -r md_file; do
        local tokens=$(estimate_file_tokens "$md_file")
        if [ $tokens -gt 2000 ]; then
            local relative_path=$(echo "$md_file" | sed 's|^\./||')
            echo "- **$relative_path**: $(printf '%,d' $tokens) tokens" >> "$opportunities_file"
        fi
    done
    
    cat >> "$opportunities_file" << 'EOF'

### Repetitive Content Patterns
- Check for duplicated sections across workflows
- Consolidate common instructions
- Create reusable components

### Verbose Templates
- PRP templates can be condensed
- Remove redundant examples
- Streamline instructions

## Medium-Priority Optimizations

### Documentation Optimization
- README files often contain repetitive information
- Architectural documentation can be condensed
- Examples can be made more concise

### Workflow Streamlining
- Some workflows have overlapping functionality
- Instructions can be more direct
- Reduce explanatory text where possible

## Low-Priority Optimizations

### Minor Text Improvements
- Remove filler words
- Shorten sentences
- Use bullet points instead of paragraphs

### Format Optimizations
- Reduce whitespace
- Optimize code block sizes
- Streamline markdown formatting

## Automated Optimization Candidates

The following files are recommended for automated optimization:
EOF
    
    # List top 10 largest files as automation candidates
    find . -name "*.md" -not -path "./.git/*" -exec wc -w {} \; | \
        sort -nr | head -10 | while read -r words filename; do
            local tokens=$((words * 3 / 4))
            local relative_path=$(echo "$filename" | sed 's|^\./||')
            echo "- **$relative_path**: ~$(printf '%,d' $tokens) tokens" >> "$opportunities_file"
        done
    
    echo "✅ Optimization opportunities identified: $opportunities_file"
}

# Function to generate recommendations
generate_optimization_recommendations() {
    echo "💡 Generating optimization recommendations..."
    
    local recommendations_file="$REVIEW_DIR/recommendations.md"
    
    cat > "$recommendations_file" << EOF
# Token Optimization Recommendations

## Executive Summary
Based on the token usage analysis, the following recommendations will help achieve the target $COST_TARGET% cost reduction while maintaining or improving framework quality.

## Immediate Actions (High Impact)

### 1. Automated Prompt Optimization
**Impact**: 20-30% token reduction
**Effort**: Low (automated)
**Timeline**: 1 day

\`\`\`bash
# Run automated optimization on large files
./ai-dev optimize .ai_workflow/PRPs/templates/prp_base.md
./ai-dev optimize README.md
./ai-dev optimize FRAMEWORK_GUIDE.md
\`\`\`

### 2. Template Consolidation
**Impact**: 15-25% token reduction
**Effort**: Medium
**Timeline**: 2-3 days

- Merge redundant template sections
- Create reusable component library
- Eliminate duplicate instructions

### 3. Workflow Streamlining
**Impact**: 10-20% token reduction
**Effort**: Medium
**Timeline**: 3-5 days

- Combine similar workflows
- Remove redundant explanations
- Optimize instruction clarity

## Strategic Actions (Medium Impact)

### 4. Documentation Restructuring
**Impact**: 10-15% token reduction
**Effort**: High
**Timeline**: 1 week

- Restructure large documentation files
- Create modular documentation approach
- Implement progressive disclosure

### 5. Example Optimization
**Impact**: 5-15% token reduction
**Effort**: Medium
**Timeline**: 2-3 days

- Reduce example verbosity
- Focus on essential demonstrations
- Remove redundant examples

### 6. Framework Architecture Review
**Impact**: 5-10% token reduction
**Effort**: High
**Timeline**: 1-2 weeks

- Review overall framework structure
- Identify architectural optimizations
- Implement token-efficient patterns

## Implementation Plan

### Phase 1: Quick Wins (Week 1)
1. Run automated optimization on top 10 largest files
2. Apply manual optimization to templates
3. Remove obvious redundancies

**Expected Savings**: 15-20%

### Phase 2: Systematic Optimization (Week 2-3)
1. Implement workflow consolidations
2. Restructure documentation
3. Optimize examples and demonstrations

**Expected Savings**: Additional 10-15%

### Phase 3: Architecture Optimization (Week 4)
1. Review framework architecture
2. Implement structural improvements
3. Create optimization guidelines

**Expected Savings**: Additional 5-10%

**Total Expected Savings**: 30-45%

## Monitoring and Validation

### Success Metrics
- Token count reduction percentage
- Cost savings achieved
- Quality preservation score
- User satisfaction ratings

### Validation Process
1. **Before/After Comparison**: Document token counts before optimization
2. **Quality Assurance**: Test optimized content for effectiveness
3. **User Feedback**: Collect feedback on optimized workflows
4. **Performance Monitoring**: Track actual usage and costs

### Continuous Improvement
- Monthly token usage reviews
- Quarterly optimization cycles
- Annual framework architecture reviews
- Community feedback integration

## Risk Mitigation

### Quality Preservation
- Maintain comprehensive testing
- Preserve essential functionality
- Keep quality gates in place

### Rollback Plan
- Version control all changes
- Maintain backup copies
- Quick rollback procedures

### Change Management
- Gradual implementation
- User communication
- Training updates

## Tools and Resources

### Automated Tools
- \`./ai-dev optimize\` command
- Token counting utilities
- Quality assessment tools

### Manual Processes
- Content review procedures
- Quality assurance checklists
- User acceptance testing

### Monitoring Tools
- Token usage tracking
- Cost monitoring dashboards
- Performance metrics

## Next Steps

1. **Review and Approve**: Stakeholder review of recommendations
2. **Resource Allocation**: Assign team members to optimization tasks
3. **Timeline Confirmation**: Confirm implementation timeline
4. **Kickoff Meeting**: Begin Phase 1 implementation
5. **Progress Tracking**: Set up monitoring and reporting

---

*Token optimization recommendations generated on $(date)*
*Session: $TOKEN_REVIEW_SESSION*
*Target: $COST_TARGET% cost reduction*
EOF
    
    echo "✅ Optimization recommendations generated: $recommendations_file"
}

# Function to create action plan
create_action_plan() {
    echo "📋 Creating actionable implementation plan..."
    
    local action_plan_file="$REVIEW_DIR/action_plan.md"
    
    cat > "$action_plan_file" << EOF
# Token Optimization Action Plan

## Session Information
- **Session ID**: $TOKEN_REVIEW_SESSION
- **Date**: $(date)
- **Target**: $COST_TARGET% cost reduction
- **Framework Version**: $(get_framework_version)

## Phase 1: Immediate Optimizations (Days 1-3)

### Day 1: Automated Optimization
- [ ] **Run optimization on large templates**
  \`\`\`bash
  ./ai-dev optimize .ai_workflow/PRPs/templates/prp_base.md
  ./ai-dev optimize FRAMEWORK_GUIDE.md
  ./ai-dev optimize README.md
  \`\`\`
- [ ] **Review optimization results**
- [ ] **Test optimized templates**

### Day 2: Manual Template Review
- [ ] **Review PRP templates for redundancy**
- [ ] **Consolidate common sections**
- [ ] **Update template structure**

### Day 3: Workflow Optimization
- [ ] **Identify redundant workflows**
- [ ] **Streamline instructions**
- [ ] **Test workflow functionality**

**Expected Result**: 15-20% token reduction

## Phase 2: Systematic Improvements (Days 4-7)

### Day 4-5: Documentation Restructuring
- [ ] **Break down large documentation files**
- [ ] **Create modular documentation structure**
- [ ] **Implement cross-references**

### Day 6-7: Content Optimization
- [ ] **Optimize examples and demonstrations**
- [ ] **Remove verbose explanations**
- [ ] **Enhance content clarity**

**Expected Result**: Additional 10-15% token reduction

## Phase 3: Architecture Review (Days 8-14)

### Week 2: Framework Analysis
- [ ] **Analyze framework architecture**
- [ ] **Identify structural optimizations**
- [ ] **Plan implementation approach**

### Implementation
- [ ] **Implement architectural changes**
- [ ] **Update documentation**
- [ ] **Test complete system**

**Expected Result**: Additional 5-10% token reduction

## Validation Checklist

### Before Each Phase
- [ ] Backup current state
- [ ] Document baseline metrics
- [ ] Prepare rollback plan

### After Each Phase
- [ ] Measure token reduction
- [ ] Test functionality
- [ ] Collect user feedback
- [ ] Update documentation

## Success Criteria

### Quantitative Metrics
- **Token Reduction**: ≥ $COST_TARGET%
- **Cost Savings**: ≥ \$$(echo "scale=2; $(calculate_token_cost 100000) * $COST_TARGET / 100" | bc -l) per 100K tokens
- **Quality Score**: ≥ 8/10
- **Performance**: No degradation

### Qualitative Metrics
- User satisfaction maintained
- Framework functionality preserved
- Documentation clarity improved
- Maintenance complexity reduced

## Risk Management

### High Risk Items
- [ ] Large template modifications
- [ ] Core workflow changes
- [ ] Architecture modifications

### Mitigation Strategies
- [ ] Gradual implementation
- [ ] Comprehensive testing
- [ ] User feedback loops
- [ ] Quick rollback capability

## Resources Required

### Tools
- Automated optimization scripts
- Token counting utilities
- Quality assessment tools
- Version control system

### Personnel
- Framework maintainer (lead)
- Quality assurance reviewer
- User experience validator
- Documentation specialist

## Monitoring and Reporting

### Daily During Implementation
- Token count changes
- Functionality tests
- User feedback
- Issue tracking

### Weekly Summary
- Overall progress
- Cost savings achieved
- Quality metrics
- Next week planning

### Final Report
- Complete optimization results
- Lessons learned
- Future recommendations
- Updated guidelines

---

*Action plan created: $(date)*
*Next review: $(date -d "+7 days" +"%Y-%m-%d")*
EOF
    
    echo "✅ Action plan created: $action_plan_file"
}

# Main execution flow
echo "🚀 Starting token usage analysis..."
collect_token_usage_data

echo ""
echo "🔍 Identifying optimization opportunities..."
identify_optimization_opportunities

echo ""
echo "💡 Generating recommendations..."
generate_optimization_recommendations

echo ""
echo "📋 Creating action plan..."
create_action_plan

# Generate session summary
SESSION_SUMMARY="$REVIEW_DIR/session_summary.json"
cat > "$SESSION_SUMMARY" << EOF
{
  "session_id": "$TOKEN_REVIEW_SESSION",
  "timestamp": "$(date -Iseconds)",
  "analysis_period_days": $REVIEW_PERIOD,
  "cost_target_percentage": $COST_TARGET,
  "analysis_depth": "$ANALYSIS_DEPTH",
  "framework_version": "$(get_framework_version)",
  "status": "completed",
  "output_files": [
    "token_usage_data.json",
    "usage_summary.txt",
    "optimization_opportunities.md",
    "recommendations.md",
    "action_plan.md"
  ],
  "next_review_date": "$(date -d "+30 days" +"%Y-%m-%d")",
  "completed": "$(date -Iseconds)"
}
EOF

# Final summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💰 Token Usage Review Completed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Session ID: $TOKEN_REVIEW_SESSION"
echo "📁 Review directory: $REVIEW_DIR"
echo "🎯 Target cost reduction: $COST_TARGET%"
echo ""
echo "📄 Generated Reports:"
echo "  • Usage analysis: usage_summary.txt"
echo "  • Optimization opportunities: optimization_opportunities.md"
echo "  • Recommendations: recommendations.md"
echo "  • Action plan: action_plan.md"
echo "  • Session data: session_summary.json"
echo ""
echo "🚀 Next Steps:"
echo "  1. Review recommendations: cat $REVIEW_DIR/recommendations.md"
echo "  2. Execute action plan: cat $REVIEW_DIR/action_plan.md"
echo "  3. Start Phase 1 optimizations immediately"
echo "  4. Schedule next review for $(date -d "+30 days" +"%Y-%m-%d")"
echo ""
echo "💡 Quick Start Optimization:"
echo "  ./ai-dev optimize README.md"
echo "  ./ai-dev optimize .ai_workflow/PRPs/templates/prp_base.md"

# Log completion
./.ai_workflow/workflows/common/log_work_journal.md "INFO" "Token usage review completed: $TOKEN_REVIEW_SESSION"

echo ""
echo "✅ Token usage review and optimization workflow completed successfully"
```

## Verification Criteria
- Token usage data is successfully collected and analyzed
- Optimization opportunities are identified and prioritized
- Actionable recommendations are generated with clear implementation steps
- Action plan provides specific tasks with timelines and success criteria
- Session data is properly documented for future reference

## Input Parameters
- `TOKEN_REVIEW_PERIOD`: Analysis period in days (default: 30)
- `TOKEN_COST_TARGET`: Target cost reduction percentage (default: 40)
- `TOKEN_ANALYSIS_DEPTH`: Analysis depth level - basic|detailed|comprehensive (default: comprehensive)

## Output
- Comprehensive token usage analysis reports
- Optimization opportunities and recommendations
- Detailed action plan with phases and timelines
- Session data for tracking and future reference
- Cost savings projections and success metrics

## Integration Points
- **Optimization Workflow**: Integrates with existing `optimize_prompts.md`
- **Monitoring System**: Feeds into framework monitoring and reporting
- **Quality Assurance**: Maintains quality gates throughout optimization
- **Cost Tracking**: Provides input for budget and cost management

## Next Steps
- **On Success:** Execute action plan phases in sequence
- **On Opportunities Found:** Prioritize and implement high-impact optimizations
- **On Regular Schedule:** Schedule monthly token usage reviews

## Related Workflows
- [Optimize Prompts](./optimize_prompts.md) - Automated prompt optimization
- [Performance Monitoring](./performance_monitoring.md) - Framework performance tracking
- [Quality Validation](../security/validate_input.md) - Quality assurance processes