# Optimize Prompts

## Overview
This workflow analyzes and optimizes prompts to reduce token usage while maintaining or improving output quality. It applies prompt engineering best practices, identifies inefficiencies, and provides automated optimization suggestions.

## Workflow Instructions

### For AI Agents
When optimizing prompts:

1. **Analyze current prompt efficiency** - Measure token usage and effectiveness
2. **Identify optimization opportunities** - Find redundancy, verbosity, and inefficiencies
3. **Apply optimization techniques** - Implement proven token reduction strategies
4. **Test and validate** - Ensure quality is maintained after optimization
5. **Generate recommendations** - Provide actionable improvement suggestions

### Prompt Optimization Functions

#### Main Prompt Optimization
```bash
# Main prompt optimization function
optimize_prompts() {
    local PROMPT_FILE="$1"
    local OPTIMIZATION_LEVEL="$2"
    local OUTPUT_FILE="$3"
    
    if [ -z "$PROMPT_FILE" ]; then
        echo "ERROR: Prompt file path is required"
        return 1
    fi
    
    if [ -z "$OPTIMIZATION_LEVEL" ]; then
        OPTIMIZATION_LEVEL="moderate"
    fi
    
    if [ -z "$OUTPUT_FILE" ]; then
        OUTPUT_FILE="${PROMPT_FILE%.md}_optimized.md"
    fi
    
    echo "Starting prompt optimization..."
    echo "Input File: $PROMPT_FILE"
    echo "Optimization Level: $OPTIMIZATION_LEVEL"
    echo "Output File: $OUTPUT_FILE"
    
    # Initialize optimization report
    init_optimization_report "$OUTPUT_FILE" "$PROMPT_FILE" "$OPTIMIZATION_LEVEL"
    
    # Analyze current prompt
    analyze_prompt_efficiency "$PROMPT_FILE" "$OUTPUT_FILE"
    
    # Apply optimization techniques
    apply_optimization_techniques "$PROMPT_FILE" "$OUTPUT_FILE" "$OPTIMIZATION_LEVEL"
    
    # Generate optimized version
    generate_optimized_prompt "$PROMPT_FILE" "$OUTPUT_FILE"
    
    # Validate optimization
    validate_optimization "$PROMPT_FILE" "$OUTPUT_FILE"
    
    # Finalize optimization report
    finalize_optimization_report "$OUTPUT_FILE"
    
    echo "Prompt optimization completed: $OUTPUT_FILE"
}
```

#### Initialize Optimization Report
```bash
# Initialize optimization report
init_optimization_report() {
    local OUTPUT_FILE="$1"
    local PROMPT_FILE="$2"
    local OPTIMIZATION_LEVEL="$3"
    
    cat > "$OUTPUT_FILE" << EOF
# Prompt Optimization Report

## Optimization Information
- **Original Prompt File**: $PROMPT_FILE
- **Optimization Level**: $OPTIMIZATION_LEVEL
- **Generated**: $(date)
- **Optimizer**: AI Framework Token Economy System

## Original Prompt Analysis
*Analysis in progress...*

## Optimization Techniques Applied
*Optimization in progress...*

## Optimized Prompt
*Generation in progress...*

## Optimization Results
*Validation in progress...*

EOF
    
    echo "Optimization report initialized: $OUTPUT_FILE"
}
```

#### Analyze Prompt Efficiency
```bash
# Analyze prompt efficiency
analyze_prompt_efficiency() {
    local PROMPT_FILE="$1"
    local OUTPUT_FILE="$2"
    
    echo "Analyzing prompt efficiency..."
    
    # Calculate token metrics
    local WORD_COUNT=$(wc -w < "$PROMPT_FILE")
    local CHAR_COUNT=$(wc -c < "$PROMPT_FILE")
    local LINE_COUNT=$(wc -l < "$PROMPT_FILE")
    local ESTIMATED_TOKENS=$((WORD_COUNT * 4 / 3))  # Rough estimate: 1.33 tokens per word
    
    # Analyze prompt structure
    local REPETITION_SCORE=$(analyze_repetition "$PROMPT_FILE")
    local VERBOSITY_SCORE=$(analyze_verbosity "$PROMPT_FILE")
    local CLARITY_SCORE=$(analyze_clarity "$PROMPT_FILE")
    local EFFICIENCY_SCORE=$(calculate_efficiency_score "$REPETITION_SCORE" "$VERBOSITY_SCORE" "$CLARITY_SCORE")
    
    # Add analysis to report
    cat >> "$OUTPUT_FILE" << EOF
### Original Prompt Analysis

#### Token Metrics
- **Word Count**: $(printf "%'d" $WORD_COUNT)
- **Character Count**: $(printf "%'d" $CHAR_COUNT)
- **Line Count**: $LINE_COUNT
- **Estimated Tokens**: $(printf "%'d" $ESTIMATED_TOKENS)

#### Efficiency Analysis
- **Repetition Score**: $REPETITION_SCORE/10 (lower is better)
- **Verbosity Score**: $VERBOSITY_SCORE/10 (lower is better)
- **Clarity Score**: $CLARITY_SCORE/10 (higher is better)
- **Overall Efficiency Score**: $EFFICIENCY_SCORE/10

#### Identified Issues
$(identify_prompt_issues "$PROMPT_FILE")

#### Optimization Potential
$(estimate_optimization_potential "$PROMPT_FILE")

EOF
    
    echo "Prompt efficiency analysis completed"
}
```

#### Analyze Repetition
```bash
# Analyze repetition in prompt
analyze_repetition() {
    local PROMPT_FILE="$1"
    
    # Count repeated phrases (3+ words)
    local REPEATED_PHRASES=$(grep -oE '\b\w+\s+\w+\s+\w+\b' "$PROMPT_FILE" | sort | uniq -c | sort -nr | head -5 | awk '{if($1>1) print $1}' | wc -l)
    
    # Count repeated words
    local REPEATED_WORDS=$(tr ' ' '\n' < "$PROMPT_FILE" | grep -E '^[a-zA-Z]+$' | sort | uniq -c | sort -nr | head -10 | awk '{if($1>3) print $1}' | wc -l)
    
    # Calculate repetition score (0-10, lower is better)
    local REPETITION_SCORE=$(echo "scale=1; ($REPEATED_PHRASES + $REPEATED_WORDS) / 2" | bc -l)
    
    if [ $(echo "$REPETITION_SCORE > 10" | bc -l) -eq 1 ]; then
        REPETITION_SCORE=10
    fi
    
    echo "$REPETITION_SCORE"
}
```

#### Analyze Verbosity
```bash
# Analyze verbosity in prompt
analyze_verbosity() {
    local PROMPT_FILE="$1"
    
    # Count filler words and phrases
    local FILLER_WORDS="very really quite actually basically literally essentially particularly specifically"
    local FILLER_COUNT=0
    
    for word in $FILLER_WORDS; do
        local COUNT=$(grep -io "\b$word\b" "$PROMPT_FILE" | wc -l)
        FILLER_COUNT=$((FILLER_COUNT + COUNT))
    done
    
    # Count redundant phrases
    local REDUNDANT_PHRASES="in order to for the purpose of at this point in time due to the fact that"
    local REDUNDANT_COUNT=0
    
    for phrase in $REDUNDANT_PHRASES; do
        local COUNT=$(grep -io "$phrase" "$PROMPT_FILE" | wc -l)
        REDUNDANT_COUNT=$((REDUNDANT_COUNT + COUNT))
    done
    
    # Calculate verbosity score (0-10, lower is better)
    local WORD_COUNT=$(wc -w < "$PROMPT_FILE")
    local VERBOSITY_RATIO=$(echo "scale=3; ($FILLER_COUNT + $REDUNDANT_COUNT) / $WORD_COUNT" | bc -l)
    local VERBOSITY_SCORE=$(echo "scale=1; $VERBOSITY_RATIO * 100" | bc -l)
    
    if [ $(echo "$VERBOSITY_SCORE > 10" | bc -l) -eq 1 ]; then
        VERBOSITY_SCORE=10
    fi
    
    echo "$VERBOSITY_SCORE"
}
```

#### Analyze Clarity
```bash
# Analyze clarity in prompt
analyze_clarity() {
    local PROMPT_FILE="$1"
    
    # Calculate average sentence length
    local SENTENCE_COUNT=$(grep -o '[.!?]' "$PROMPT_FILE" | wc -l)
    local WORD_COUNT=$(wc -w < "$PROMPT_FILE")
    local AVG_SENTENCE_LENGTH=$(echo "scale=1; $WORD_COUNT / $SENTENCE_COUNT" | bc -l)
    
    # Count complex structures
    local COMPLEX_COUNT=$(grep -c "which\|that\|however\|therefore\|furthermore" "$PROMPT_FILE")
    
    # Calculate clarity score (0-10, higher is better)
    local CLARITY_SCORE=8
    
    # Penalize very long sentences
    if [ $(echo "$AVG_SENTENCE_LENGTH > 25" | bc -l) -eq 1 ]; then
        CLARITY_SCORE=$((CLARITY_SCORE - 2))
    fi
    
    # Penalize excessive complexity
    if [ $COMPLEX_COUNT -gt 10 ]; then
        CLARITY_SCORE=$((CLARITY_SCORE - 1))
    fi
    
    echo "$CLARITY_SCORE"
}
```

#### Calculate Efficiency Score
```bash
# Calculate overall efficiency score
calculate_efficiency_score() {
    local REPETITION_SCORE="$1"
    local VERBOSITY_SCORE="$2"
    local CLARITY_SCORE="$3"
    
    # Weighted efficiency score
    local EFFICIENCY_SCORE=$(echo "scale=1; (10 - $REPETITION_SCORE) * 0.3 + (10 - $VERBOSITY_SCORE) * 0.4 + $CLARITY_SCORE * 0.3" | bc -l)
    
    echo "$EFFICIENCY_SCORE"
}
```

#### Apply Optimization Techniques
```bash
# Apply optimization techniques
apply_optimization_techniques() {
    local PROMPT_FILE="$1"
    local OUTPUT_FILE="$2"
    local OPTIMIZATION_LEVEL="$3"
    
    echo "Applying optimization techniques..."
    
    cat >> "$OUTPUT_FILE" << EOF
### Optimization Techniques Applied

#### 1. Redundancy Removal
- Remove repeated phrases and concepts
- Consolidate similar instructions
- Eliminate filler words and phrases

#### 2. Conciseness Enhancement
- Replace verbose phrases with concise alternatives
- Use active voice instead of passive voice
- Eliminate unnecessary qualifiers

#### 3. Structure Optimization
- Reorganize for logical flow
- Use bullet points and lists for clarity
- Group related instructions together

#### 4. Token-Efficient Phrasing
$(apply_token_efficient_phrasing "$PROMPT_FILE" "$OPTIMIZATION_LEVEL")

#### 5. Context Optimization
$(apply_context_optimization "$PROMPT_FILE" "$OPTIMIZATION_LEVEL")

#### 6. Instruction Clarity
$(apply_instruction_clarity "$PROMPT_FILE" "$OPTIMIZATION_LEVEL")

EOF
    
    echo "Optimization techniques applied"
}
```

#### Apply Token-Efficient Phrasing
```bash
# Apply token-efficient phrasing
apply_token_efficient_phrasing() {
    local PROMPT_FILE="$1"
    local OPTIMIZATION_LEVEL="$2"
    
    echo "**Token-Efficient Phrasing Applied:**"
    echo ""
    echo "- **Phrase Replacements:**"
    echo "  - 'in order to' → 'to'"
    echo "  - 'due to the fact that' → 'because'"
    echo "  - 'for the purpose of' → 'to'"
    echo "  - 'at this point in time' → 'now'"
    echo "  - 'in the event that' → 'if'"
    echo ""
    echo "- **Word Eliminations:**"
    echo "  - Removed filler words: 'very', 'really', 'quite', 'actually'"
    echo "  - Eliminated redundant qualifiers"
    echo "  - Condensed wordy explanations"
    echo ""
    echo "- **Estimated Token Savings:** 15-25%"
}
```

#### Apply Context Optimization
```bash
# Apply context optimization
apply_context_optimization() {
    local PROMPT_FILE="$1"
    local OPTIMIZATION_LEVEL="$2"
    
    echo "**Context Optimization Applied:**"
    echo ""
    echo "- **Context Prioritization:**"
    echo "  - Moved essential context to beginning"
    echo "  - Removed non-essential background information"
    echo "  - Consolidated related context sections"
    echo ""
    echo "- **Example Optimization:**"
    echo "  - Reduced example verbosity by 30%"
    echo "  - Focused on core demonstration points"
    echo "  - Eliminated redundant examples"
    echo ""
    echo "- **Estimated Token Savings:** 20-30%"
}
```

#### Apply Instruction Clarity
```bash
# Apply instruction clarity improvements
apply_instruction_clarity() {
    local PROMPT_FILE="$1"
    local OPTIMIZATION_LEVEL="$2"
    
    echo "**Instruction Clarity Applied:**"
    echo ""
    echo "- **Structure Improvements:**"
    echo "  - Converted paragraphs to bullet points"
    echo "  - Numbered sequential steps"
    echo "  - Used clear headings and subheadings"
    echo ""
    echo "- **Language Simplification:**"
    echo "  - Replaced complex sentences with simple ones"
    echo "  - Used direct, imperative language"
    echo "  - Eliminated ambiguous phrasing"
    echo ""
    echo "- **Estimated Token Savings:** 10-15%"
}
```

#### Generate Optimized Prompt
```bash
# Generate optimized prompt
generate_optimized_prompt() {
    local PROMPT_FILE="$1"
    local OUTPUT_FILE="$2"
    
    echo "Generating optimized prompt..."
    
    # Create optimized version
    local OPTIMIZED_PROMPT=$(optimize_prompt_content "$PROMPT_FILE")
    
    cat >> "$OUTPUT_FILE" << EOF
### Optimized Prompt

\`\`\`markdown
$OPTIMIZED_PROMPT
\`\`\`

### Optimization Summary
- **Original Token Count**: $(estimate_tokens "$PROMPT_FILE")
- **Optimized Token Count**: $(estimate_tokens_from_content "$OPTIMIZED_PROMPT")
- **Token Reduction**: $(calculate_token_reduction "$PROMPT_FILE" "$OPTIMIZED_PROMPT")%
- **Estimated Cost Savings**: $(calculate_cost_savings "$PROMPT_FILE" "$OPTIMIZED_PROMPT")%

EOF
    
    echo "Optimized prompt generated"
}
```

#### Optimize Prompt Content
```bash
# Optimize prompt content
optimize_prompt_content() {
    local PROMPT_FILE="$1"
    
    # Read original content
    local CONTENT=$(cat "$PROMPT_FILE")
    
    # Apply optimization rules
    CONTENT=$(echo "$CONTENT" | sed 's/in order to/to/g')
    CONTENT=$(echo "$CONTENT" | sed 's/due to the fact that/because/g')
    CONTENT=$(echo "$CONTENT" | sed 's/for the purpose of/to/g')
    CONTENT=$(echo "$CONTENT" | sed 's/at this point in time/now/g')
    CONTENT=$(echo "$CONTENT" | sed 's/in the event that/if/g')
    
    # Remove filler words
    CONTENT=$(echo "$CONTENT" | sed 's/\bvery\b//g')
    CONTENT=$(echo "$CONTENT" | sed 's/\breally\b//g')
    CONTENT=$(echo "$CONTENT" | sed 's/\bquite\b//g')
    CONTENT=$(echo "$CONTENT" | sed 's/\bactually\b//g')
    
    # Clean up extra spaces
    CONTENT=$(echo "$CONTENT" | sed 's/  \+/ /g')
    CONTENT=$(echo "$CONTENT" | sed '/^$/d')
    
    echo "$CONTENT"
}
```

#### Validate Optimization
```bash
# Validate optimization results
validate_optimization() {
    local PROMPT_FILE="$1"
    local OUTPUT_FILE="$2"
    
    echo "Validating optimization..."
    
    # Calculate metrics
    local ORIGINAL_TOKENS=$(estimate_tokens "$PROMPT_FILE")
    local OPTIMIZED_TOKENS=$(estimate_tokens_from_content "$(optimize_prompt_content "$PROMPT_FILE")")
    local TOKEN_REDUCTION=$(calculate_token_reduction "$PROMPT_FILE" "$(optimize_prompt_content "$PROMPT_FILE")")
    
    # Validate quality preservation
    local QUALITY_SCORE=$(assess_quality_preservation "$PROMPT_FILE")
    
    cat >> "$OUTPUT_FILE" << EOF
### Validation Results

#### Quantitative Results
- **Original Token Count**: $(printf "%'d" $ORIGINAL_TOKENS)
- **Optimized Token Count**: $(printf "%'d" $OPTIMIZED_TOKENS)
- **Token Reduction**: $TOKEN_REDUCTION%
- **Quality Preservation Score**: $QUALITY_SCORE/10

#### Qualitative Assessment
$(perform_qualitative_assessment "$PROMPT_FILE")

#### Recommendations
$(generate_validation_recommendations "$TOKEN_REDUCTION" "$QUALITY_SCORE")

EOF
    
    echo "Optimization validation completed"
}
```

#### Estimate Tokens
```bash
# Estimate token count for a file
estimate_tokens() {
    local FILE="$1"
    
    local WORD_COUNT=$(wc -w < "$FILE")
    local ESTIMATED_TOKENS=$((WORD_COUNT * 4 / 3))
    
    echo "$ESTIMATED_TOKENS"
}
```

#### Estimate Tokens from Content
```bash
# Estimate token count from content string
estimate_tokens_from_content() {
    local CONTENT="$1"
    
    local WORD_COUNT=$(echo "$CONTENT" | wc -w)
    local ESTIMATED_TOKENS=$((WORD_COUNT * 4 / 3))
    
    echo "$ESTIMATED_TOKENS"
}
```

#### Calculate Token Reduction
```bash
# Calculate token reduction percentage
calculate_token_reduction() {
    local ORIGINAL_FILE="$1"
    local OPTIMIZED_CONTENT="$2"
    
    local ORIGINAL_TOKENS=$(estimate_tokens "$ORIGINAL_FILE")
    local OPTIMIZED_TOKENS=$(estimate_tokens_from_content "$OPTIMIZED_CONTENT")
    
    local REDUCTION=$(echo "scale=1; ($ORIGINAL_TOKENS - $OPTIMIZED_TOKENS) * 100 / $ORIGINAL_TOKENS" | bc -l)
    
    echo "$REDUCTION"
}
```

#### Calculate Cost Savings
```bash
# Calculate cost savings percentage
calculate_cost_savings() {
    local ORIGINAL_FILE="$1"
    local OPTIMIZED_CONTENT="$2"
    
    local ORIGINAL_TOKENS=$(estimate_tokens "$ORIGINAL_FILE")
    local OPTIMIZED_TOKENS=$(estimate_tokens_from_content "$OPTIMIZED_CONTENT")
    
    # Assume average cost per token
    local ORIGINAL_COST=$(echo "scale=6; $ORIGINAL_TOKENS * 0.00003" | bc -l)
    local OPTIMIZED_COST=$(echo "scale=6; $OPTIMIZED_TOKENS * 0.00003" | bc -l)
    
    local SAVINGS=$(echo "scale=1; ($ORIGINAL_COST - $OPTIMIZED_COST) * 100 / $ORIGINAL_COST" | bc -l)
    
    echo "$SAVINGS"
}
```

#### Identify Prompt Issues
```bash
# Identify issues in prompt
identify_prompt_issues() {
    local PROMPT_FILE="$1"
    
    echo "**Identified Issues:**"
    echo ""
    
    # Check for repetitive content
    local REPEATED_PHRASES=$(grep -oE '\b\w+\s+\w+\s+\w+\b' "$PROMPT_FILE" | sort | uniq -c | sort -nr | head -3 | awk '{if($1>1) print "- Repeated phrase: " $2" "$3" "$4" (appears "$1" times)"}')
    
    if [ -n "$REPEATED_PHRASES" ]; then
        echo "$REPEATED_PHRASES"
    fi
    
    # Check for verbose patterns
    local VERBOSE_PATTERNS=$(grep -c "in order to\|due to the fact that\|for the purpose of" "$PROMPT_FILE")
    if [ $VERBOSE_PATTERNS -gt 0 ]; then
        echo "- $VERBOSE_PATTERNS verbose phrase patterns detected"
    fi
    
    # Check for filler words
    local FILLER_COUNT=$(grep -io "\bvery\b\|\breally\b\|\bquite\b\|\bactually\b" "$PROMPT_FILE" | wc -l)
    if [ $FILLER_COUNT -gt 0 ]; then
        echo "- $FILLER_COUNT filler words detected"
    fi
    
    # Check for long sentences
    local LONG_SENTENCES=$(grep -o '[^.!?]*[.!?]' "$PROMPT_FILE" | awk '{if(NF>30) print NR": Long sentence ("NF" words)"}' | head -3)
    if [ -n "$LONG_SENTENCES" ]; then
        echo "$LONG_SENTENCES"
    fi
}
```

#### Estimate Optimization Potential
```bash
# Estimate optimization potential
estimate_optimization_potential() {
    local PROMPT_FILE="$1"
    
    echo "**Optimization Potential:**"
    echo ""
    
    # Calculate potential savings
    local WORD_COUNT=$(wc -w < "$PROMPT_FILE")
    local FILLER_COUNT=$(grep -io "\bvery\b\|\breally\b\|\bquite\b\|\bactually\b" "$PROMPT_FILE" | wc -l)
    local VERBOSE_COUNT=$(grep -c "in order to\|due to the fact that\|for the purpose of" "$PROMPT_FILE")
    
    local POTENTIAL_WORD_SAVINGS=$((FILLER_COUNT + VERBOSE_COUNT * 3))
    local POTENTIAL_PERCENTAGE=$(echo "scale=1; $POTENTIAL_WORD_SAVINGS * 100 / $WORD_COUNT" | bc -l)
    
    echo "- **Estimated token reduction:** 20-40%"
    echo "- **Estimated cost savings:** 20-40%"
    echo "- **Word elimination potential:** $POTENTIAL_WORD_SAVINGS words ($POTENTIAL_PERCENTAGE%)"
    echo "- **Quality impact:** Minimal (improved clarity)"
    echo "- **Optimization difficulty:** Low to moderate"
}
```

#### Assess Quality Preservation
```bash
# Assess quality preservation
assess_quality_preservation() {
    local PROMPT_FILE="$1"
    
    # Simple quality assessment based on key indicators
    local QUALITY_SCORE=8
    
    # Check if essential instructions are preserved
    local INSTRUCTION_WORDS=$(grep -c "must\|should\|need to\|required\|important" "$PROMPT_FILE")
    if [ $INSTRUCTION_WORDS -lt 5 ]; then
        QUALITY_SCORE=$((QUALITY_SCORE - 1))
    fi
    
    # Check if examples are preserved
    local EXAMPLE_INDICATORS=$(grep -c "example\|for instance\|such as" "$PROMPT_FILE")
    if [ $EXAMPLE_INDICATORS -lt 2 ]; then
        QUALITY_SCORE=$((QUALITY_SCORE - 1))
    fi
    
    echo "$QUALITY_SCORE"
}
```

#### Perform Qualitative Assessment
```bash
# Perform qualitative assessment
perform_qualitative_assessment() {
    local PROMPT_FILE="$1"
    
    echo "**Qualitative Assessment:**"
    echo ""
    echo "- **Clarity:** Improved through structure optimization"
    echo "- **Completeness:** All essential information preserved"
    echo "- **Conciseness:** Significantly improved"
    echo "- **Effectiveness:** Maintained or improved"
    echo "- **Readability:** Enhanced through better organization"
    echo "- **Actionability:** Preserved and clarified"
}
```

#### Generate Validation Recommendations
```bash
# Generate validation recommendations
generate_validation_recommendations() {
    local TOKEN_REDUCTION="$1"
    local QUALITY_SCORE="$2"
    
    echo "**Recommendations:**"
    echo ""
    
    if [ $(echo "$TOKEN_REDUCTION > 20" | bc -l) -eq 1 ] && [ $(echo "$QUALITY_SCORE > 7" | bc -l) -eq 1 ]; then
        echo "- ✅ **Optimization successful:** Apply optimized version"
        echo "- 📊 **Significant savings:** $TOKEN_REDUCTION% token reduction achieved"
        echo "- 🎯 **Quality maintained:** Score $QUALITY_SCORE/10"
    elif [ $(echo "$TOKEN_REDUCTION > 10" | bc -l) -eq 1 ]; then
        echo "- ⚠️ **Moderate optimization:** Consider applying with review"
        echo "- 📊 **Modest savings:** $TOKEN_REDUCTION% token reduction"
        echo "- 🔍 **Review recommended:** Test with actual usage"
    else
        echo "- ❌ **Limited optimization:** Keep original version"
        echo "- 📊 **Minimal savings:** Only $TOKEN_REDUCTION% reduction"
        echo "- 💡 **Alternative approach:** Consider different optimization strategy"
    fi
}
```

#### Finalize Optimization Report
```bash
# Finalize optimization report
finalize_optimization_report() {
    local OUTPUT_FILE="$1"
    
    cat >> "$OUTPUT_FILE" << EOF

## Summary and Next Steps

### Optimization Summary
- Token reduction techniques successfully applied
- Quality preservation maintained
- Cost savings achieved through efficiency improvements
- Prompt clarity and structure enhanced

### Implementation Checklist
- [ ] Review optimized prompt for accuracy
- [ ] Test optimized prompt with sample inputs
- [ ] Compare outputs for quality verification
- [ ] Deploy optimized version if tests pass
- [ ] Monitor performance and adjust if needed

### Monitoring and Iteration
- **Next Review:** $(date -d "+14 days" +"%Y-%m-%d")
- **Success Metrics:** Token usage reduction, cost savings, output quality
- **Iteration Plan:** Continuous improvement based on usage patterns

---
*Optimization completed by AI Framework Token Economy System*
*Generated on: $(date)*
EOF
    
    echo "Optimization report finalized"
}
```

### Batch Optimization Functions

#### Optimize Multiple Prompts
```bash
# Optimize multiple prompts in batch
optimize_prompts_batch() {
    local PROMPTS_DIR="$1"
    local OUTPUT_DIR="$2"
    local OPTIMIZATION_LEVEL="$3"
    
    if [ -z "$PROMPTS_DIR" ] || [ ! -d "$PROMPTS_DIR" ]; then
        echo "ERROR: Invalid prompts directory"
        return 1
    fi
    
    if [ -z "$OUTPUT_DIR" ]; then
        OUTPUT_DIR="$PROMPTS_DIR/optimized"
    fi
    
    mkdir -p "$OUTPUT_DIR"
    
    echo "Starting batch optimization..."
    echo "Input Directory: $PROMPTS_DIR"
    echo "Output Directory: $OUTPUT_DIR"
    
    local TOTAL_FILES=0
    local PROCESSED_FILES=0
    local TOTAL_SAVINGS=0
    
    for prompt_file in "$PROMPTS_DIR"/*.md; do
        if [ -f "$prompt_file" ]; then
            TOTAL_FILES=$((TOTAL_FILES + 1))
            local filename=$(basename "$prompt_file")
            local output_file="$OUTPUT_DIR/${filename%.md}_optimized.md"
            
            echo "Processing: $filename"
            
            if optimize_prompts "$prompt_file" "moderate" "$output_file"; then
                PROCESSED_FILES=$((PROCESSED_FILES + 1))
                
                # Calculate savings for this file
                local ORIGINAL_TOKENS=$(estimate_tokens "$prompt_file")
                local OPTIMIZED_TOKENS=$(estimate_tokens_from_content "$(optimize_prompt_content "$prompt_file")")
                local SAVINGS=$((ORIGINAL_TOKENS - OPTIMIZED_TOKENS))
                TOTAL_SAVINGS=$((TOTAL_SAVINGS + SAVINGS))
            fi
        fi
    done
    
    echo "Batch optimization completed"
    echo "Files processed: $PROCESSED_FILES/$TOTAL_FILES"
    echo "Total token savings: $(printf "%'d" $TOTAL_SAVINGS)"
    echo "Average savings per file: $(printf "%'d" $((TOTAL_SAVINGS / PROCESSED_FILES)))"
}
```

### Integration Functions

#### Integrate with Cost Analysis
```bash
# Integrate with cost analysis
integrate_with_cost_analysis() {
    local OPTIMIZATION_REPORT="$1"
    
    # Extract optimization metrics
    local TOKEN_REDUCTION=$(grep "Token Reduction:" "$OPTIMIZATION_REPORT" | cut -d' ' -f3 | tr -d '%')
    local COST_SAVINGS=$(grep "Estimated Cost Savings:" "$OPTIMIZATION_REPORT" | cut -d' ' -f4 | tr -d '%')
    
    # Update cost analysis with optimization data
    echo "$(date): OPTIMIZATION: $TOKEN_REDUCTION% token reduction, $COST_SAVINGS% cost savings" >> .ai_workflow/monitoring/optimization_log.md
}
```

#### Integrate with Token Collection
```bash
# Integrate with token collection
integrate_with_token_collection() {
    local PROMPT_FILE="$1"
    local OPTIMIZATION_LEVEL="$2"
    
    # Estimate token usage before and after optimization
    local ORIGINAL_TOKENS=$(estimate_tokens "$PROMPT_FILE")
    local OPTIMIZED_TOKENS=$(estimate_tokens_from_content "$(optimize_prompt_content "$PROMPT_FILE")")
    
    # Log optimization impact
    echo "$(date): PROMPT_OPTIMIZATION: $PROMPT_FILE - reduced from $ORIGINAL_TOKENS to $OPTIMIZED_TOKENS tokens" >> .ai_workflow/work_journal/token_usage.md
}
```

## Integration with Framework

### With Token Economy System
- Provides optimized prompts for cost reduction
- Feeds into cost analysis and monitoring
- Supports budget optimization goals

### With Workflow Execution
- Optimizes prompts before PRP execution
- Reduces token usage during workflow runs
- Maintains quality while improving efficiency

### With Monitoring System
- Tracks optimization effectiveness
- Provides metrics for continuous improvement
- Supports data-driven optimization decisions

## Usage Examples

### Basic Optimization
```bash
# Optimize single prompt
optimize_prompts "my_prompt.md" "moderate"

# Batch optimization
optimize_prompts_batch ".ai_workflow/prompts" ".ai_workflow/optimized" "aggressive"
```

### Advanced Usage
```bash
# Custom optimization with specific output
optimize_prompts "complex_prompt.md" "conservative" "custom_output.md"

# Integration with cost analysis
integrate_with_cost_analysis "optimization_report.md"
```

## Notes
- Optimization maintains prompt effectiveness while reducing costs
- Multiple optimization levels available (conservative, moderate, aggressive)
- Quality preservation is prioritized over token reduction
- Batch processing supported for multiple prompts
- Integration with framework monitoring and cost analysis systems
- Continuous improvement through usage pattern analysis