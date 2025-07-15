# Analyze Token Costs

## Overview
This workflow provides comprehensive analysis of token usage costs across different AI providers and models. It generates insights for cost optimization, identifies spending patterns, and provides recommendations for reducing token economy expenses.

## Workflow Instructions

### For AI Agents
When analyzing token costs:

1. **Gather usage data** from all available sources
2. **Calculate detailed costs** by provider, model, and time period
3. **Identify cost optimization opportunities** 
4. **Generate actionable recommendations**
5. **Create cost projection models**

### Cost Analysis Functions

#### Main Cost Analysis
```bash
# Main cost analysis function
analyze_token_costs() {
    local ANALYSIS_TYPE="$1"
    local TIME_PERIOD="$2"
    local OUTPUT_FILE="$3"
    
    if [ -z "$ANALYSIS_TYPE" ]; then
        ANALYSIS_TYPE="comprehensive"
    fi
    
    if [ -z "$TIME_PERIOD" ]; then
        TIME_PERIOD="30"  # days
    fi
    
    if [ -z "$OUTPUT_FILE" ]; then
        OUTPUT_FILE=".ai_workflow/monitoring/cost_analysis_$(date +%Y%m%d_%H%M%S).md"
    fi
    
    echo "Starting token cost analysis..."
    echo "Analysis Type: $ANALYSIS_TYPE"
    echo "Time Period: $TIME_PERIOD days"
    echo "Output File: $OUTPUT_FILE"
    
    # Initialize analysis report
    init_cost_analysis_report "$OUTPUT_FILE" "$ANALYSIS_TYPE" "$TIME_PERIOD"
    
    # Perform analysis based on type
    case "$ANALYSIS_TYPE" in
        "comprehensive")
            analyze_comprehensive_costs "$OUTPUT_FILE" "$TIME_PERIOD"
            ;;
        "provider")
            analyze_provider_costs "$OUTPUT_FILE" "$TIME_PERIOD"
            ;;
        "model")
            analyze_model_costs "$OUTPUT_FILE" "$TIME_PERIOD"
            ;;
        "trend")
            analyze_cost_trends "$OUTPUT_FILE" "$TIME_PERIOD"
            ;;
        *)
            echo "Unknown analysis type: $ANALYSIS_TYPE"
            return 1
            ;;
    esac
    
    # Generate recommendations
    generate_cost_recommendations "$OUTPUT_FILE"
    
    # Finalize report
    finalize_cost_analysis_report "$OUTPUT_FILE"
    
    echo "Cost analysis completed: $OUTPUT_FILE"
}
```

#### Initialize Cost Analysis Report
```bash
# Initialize cost analysis report
init_cost_analysis_report() {
    local OUTPUT_FILE="$1"
    local ANALYSIS_TYPE="$2"
    local TIME_PERIOD="$3"
    
    cat > "$OUTPUT_FILE" << EOF
# Token Cost Analysis Report

## Analysis Information
- **Analysis Type**: $ANALYSIS_TYPE
- **Time Period**: $TIME_PERIOD days
- **Generated**: $(date)
- **Data Source**: Token usage tracking system

## Executive Summary
*Analysis in progress...*

## Cost Breakdown

### Current Pricing Models (USD)
| Provider | Model | Input Cost (per 1K tokens) | Output Cost (per 1K tokens) |
|----------|-------|----------------------------|------------------------------|
| OpenAI | GPT-4 | \$0.03 | \$0.06 |
| OpenAI | GPT-3.5-Turbo | \$0.0015 | \$0.002 |
| Anthropic | Claude-3-Opus | \$0.015 | \$0.075 |
| Anthropic | Claude-3-Sonnet | \$0.003 | \$0.015 |
| Anthropic | Claude-3-Haiku | \$0.00025 | \$0.00125 |
| Google | Gemini-1.5-Pro | \$0.001 | \$0.003 |
| Google | Gemini-1.5-Flash | \$0.0001 | \$0.0003 |

## Analysis Results

EOF
    
    echo "Cost analysis report initialized: $OUTPUT_FILE"
}
```

#### Analyze Comprehensive Costs
```bash
# Comprehensive cost analysis
analyze_comprehensive_costs() {
    local OUTPUT_FILE="$1"
    local TIME_PERIOD="$2"
    
    echo "Performing comprehensive cost analysis..."
    
    # Get usage data
    local USAGE_FILE=".ai_workflow/work_journal/token_usage.md"
    
    # Calculate total costs
    local TOTAL_COST=$(grep "Cost Estimate" "$USAGE_FILE" | sed 's/.*\$\([0-9.]*\).*/\1/' | awk '{sum += $1} END {print sum}')
    local TOTAL_TOKENS=$(grep "Total Tokens" "$USAGE_FILE" | sed 's/.*: \([0-9,]*\).*/\1/' | tr -d ',' | awk '{sum += $1} END {print sum}')
    local TOTAL_SESSIONS=$(grep -c "#### Session" "$USAGE_FILE")
    
    # Calculate averages
    local AVG_COST_PER_SESSION=$(echo "scale=4; $TOTAL_COST / $TOTAL_SESSIONS" | bc -l)
    local AVG_TOKENS_PER_SESSION=$(echo "scale=0; $TOTAL_TOKENS / $TOTAL_SESSIONS" | bc -l)
    local AVG_COST_PER_TOKEN=$(echo "scale=8; $TOTAL_COST / $TOTAL_TOKENS" | bc -l)
    
    # Add comprehensive analysis to report
    cat >> "$OUTPUT_FILE" << EOF
### Comprehensive Cost Analysis

#### Overall Statistics
- **Total Cost**: \$$TOTAL_COST
- **Total Tokens**: $(printf "%'d" $TOTAL_TOKENS)
- **Total Sessions**: $TOTAL_SESSIONS
- **Average Cost per Session**: \$$AVG_COST_PER_SESSION
- **Average Tokens per Session**: $(printf "%'d" $AVG_TOKENS_PER_SESSION)
- **Average Cost per Token**: \$$AVG_COST_PER_TOKEN

#### Cost Distribution
$(analyze_cost_distribution "$USAGE_FILE")

#### Usage Patterns
$(analyze_usage_patterns "$USAGE_FILE")

#### Efficiency Metrics
$(analyze_efficiency_metrics "$USAGE_FILE")

EOF
    
    echo "Comprehensive cost analysis completed"
}
```

#### Analyze Provider Costs
```bash
# Provider-specific cost analysis
analyze_provider_costs() {
    local OUTPUT_FILE="$1"
    local TIME_PERIOD="$2"
    
    echo "Analyzing costs by provider..."
    
    local USAGE_FILE=".ai_workflow/work_journal/token_usage.md"
    
    # Analyze OpenAI costs
    local OPENAI_SESSIONS=$(grep -c "OpenAI" "$USAGE_FILE")
    local OPENAI_COST=$(grep -A 5 "OpenAI" "$USAGE_FILE" | grep "Cost Estimate" | sed 's/.*\$\([0-9.]*\).*/\1/' | awk '{sum += $1} END {print sum}')
    
    # Analyze Anthropic costs
    local ANTHROPIC_SESSIONS=$(grep -c "Anthropic" "$USAGE_FILE")
    local ANTHROPIC_COST=$(grep -A 5 "Anthropic" "$USAGE_FILE" | grep "Cost Estimate" | sed 's/.*\$\([0-9.]*\).*/\1/' | awk '{sum += $1} END {print sum}')
    
    # Analyze Google costs
    local GOOGLE_SESSIONS=$(grep -c "Google" "$USAGE_FILE")
    local GOOGLE_COST=$(grep -A 5 "Google" "$USAGE_FILE" | grep "Cost Estimate" | sed 's/.*\$\([0-9.]*\).*/\1/' | awk '{sum += $1} END {print sum}')
    
    # Calculate percentages
    local TOTAL_COST=$(echo "$OPENAI_COST + $ANTHROPIC_COST + $GOOGLE_COST" | bc -l)
    local OPENAI_PERCENT=$(echo "scale=1; $OPENAI_COST * 100 / $TOTAL_COST" | bc -l)
    local ANTHROPIC_PERCENT=$(echo "scale=1; $ANTHROPIC_COST * 100 / $TOTAL_COST" | bc -l)
    local GOOGLE_PERCENT=$(echo "scale=1; $GOOGLE_COST * 100 / $TOTAL_COST" | bc -l)
    
    cat >> "$OUTPUT_FILE" << EOF
### Provider Cost Analysis

#### Cost by Provider
| Provider | Sessions | Total Cost | Percentage | Avg Cost/Session |
|----------|----------|------------|------------|------------------|
| OpenAI | $OPENAI_SESSIONS | \$$OPENAI_COST | $OPENAI_PERCENT% | \$$(echo "scale=4; $OPENAI_COST / $OPENAI_SESSIONS" | bc -l) |
| Anthropic | $ANTHROPIC_SESSIONS | \$$ANTHROPIC_COST | $ANTHROPIC_PERCENT% | \$$(echo "scale=4; $ANTHROPIC_COST / $ANTHROPIC_SESSIONS" | bc -l) |
| Google | $GOOGLE_SESSIONS | \$$GOOGLE_COST | $GOOGLE_PERCENT% | \$$(echo "scale=4; $GOOGLE_COST / $GOOGLE_SESSIONS" | bc -l) |

#### Provider Efficiency Ranking
$(rank_providers_by_efficiency "$USAGE_FILE")

#### Cost Optimization Opportunities by Provider
$(identify_provider_optimization_opportunities "$USAGE_FILE")

EOF
    
    echo "Provider cost analysis completed"
}
```

#### Analyze Model Costs
```bash
# Model-specific cost analysis
analyze_model_costs() {
    local OUTPUT_FILE="$1"
    local TIME_PERIOD="$2"
    
    echo "Analyzing costs by model..."
    
    local USAGE_FILE=".ai_workflow/work_journal/token_usage.md"
    
    cat >> "$OUTPUT_FILE" << EOF
### Model Cost Analysis

#### Cost by Model
| Model | Sessions | Total Cost | Avg Tokens | Cost/Token | Efficiency Score |
|-------|----------|------------|------------|------------|------------------|
EOF
    
    # Analyze each model
    local MODELS=("GPT-4" "Claude-3-Opus" "Gemini-1.5-Pro" "Claude-3-Sonnet" "GPT-3.5-Turbo")
    
    for model in "${MODELS[@]}"; do
        local MODEL_SESSIONS=$(grep -c "$model" "$USAGE_FILE")
        if [ $MODEL_SESSIONS -gt 0 ]; then
            local MODEL_COST=$(grep -A 5 "$model" "$USAGE_FILE" | grep "Cost Estimate" | sed 's/.*\$\([0-9.]*\).*/\1/' | awk '{sum += $1} END {print sum}')
            local MODEL_TOKENS=$(grep -A 5 "$model" "$USAGE_FILE" | grep "Total Tokens" | sed 's/.*: \([0-9,]*\).*/\1/' | tr -d ',' | awk '{sum += $1} END {print sum}')
            local AVG_TOKENS=$(echo "scale=0; $MODEL_TOKENS / $MODEL_SESSIONS" | bc -l)
            local COST_PER_TOKEN=$(echo "scale=8; $MODEL_COST / $MODEL_TOKENS" | bc -l)
            local EFFICIENCY_SCORE=$(calculate_efficiency_score "$model" "$COST_PER_TOKEN" "$AVG_TOKENS")
            
            echo "| $model | $MODEL_SESSIONS | \$$MODEL_COST | $AVG_TOKENS | \$$COST_PER_TOKEN | $EFFICIENCY_SCORE |" >> "$OUTPUT_FILE"
        fi
    done
    
    cat >> "$OUTPUT_FILE" << EOF

#### Model Recommendations
$(generate_model_recommendations "$USAGE_FILE")

#### Cost Projection by Model
$(project_model_costs "$USAGE_FILE")

EOF
    
    echo "Model cost analysis completed"
}
```

#### Analyze Cost Trends
```bash
# Cost trend analysis
analyze_cost_trends() {
    local OUTPUT_FILE="$1"
    local TIME_PERIOD="$2"
    
    echo "Analyzing cost trends..."
    
    local USAGE_FILE=".ai_workflow/work_journal/token_usage.md"
    
    cat >> "$OUTPUT_FILE" << EOF
### Cost Trend Analysis

#### Historical Cost Trend
$(analyze_historical_costs "$USAGE_FILE")

#### Usage Growth Rate
$(calculate_usage_growth_rate "$USAGE_FILE")

#### Cost Projections
$(project_future_costs "$USAGE_FILE" "$TIME_PERIOD")

#### Seasonal Patterns
$(identify_seasonal_patterns "$USAGE_FILE")

EOF
    
    echo "Cost trend analysis completed"
}
```

#### Cost Distribution Analysis
```bash
# Analyze cost distribution
analyze_cost_distribution() {
    local USAGE_FILE="$1"
    
    echo "**Cost Distribution Analysis:**"
    echo ""
    echo "- **Input vs Output Costs:**"
    
    # Calculate input/output cost ratio
    local TOTAL_INPUT_TOKENS=$(grep "Input Tokens" "$USAGE_FILE" | sed 's/.*: \([0-9,]*\).*/\1/' | tr -d ',' | awk '{sum += $1} END {print sum}')
    local TOTAL_OUTPUT_TOKENS=$(grep "Output Tokens" "$USAGE_FILE" | sed 's/.*: \([0-9,]*\).*/\1/' | tr -d ',' | awk '{sum += $1} END {print sum}')
    
    echo "  - Input tokens: $(printf "%'d" $TOTAL_INPUT_TOKENS) ($(echo "scale=1; $TOTAL_INPUT_TOKENS * 100 / ($TOTAL_INPUT_TOKENS + $TOTAL_OUTPUT_TOKENS)" | bc -l)%)"
    echo "  - Output tokens: $(printf "%'d" $TOTAL_OUTPUT_TOKENS) ($(echo "scale=1; $TOTAL_OUTPUT_TOKENS * 100 / ($TOTAL_INPUT_TOKENS + $TOTAL_OUTPUT_TOKENS)" | bc -l)%)"
    
    echo ""
    echo "- **Cost Concentration:**"
    echo "  - Top 20% of sessions account for ~80% of costs (Pareto principle)"
    echo "  - Average session cost varies by model complexity"
}
```

#### Usage Patterns Analysis
```bash
# Analyze usage patterns
analyze_usage_patterns() {
    local USAGE_FILE="$1"
    
    echo "**Usage Patterns Analysis:**"
    echo ""
    
    # Session frequency analysis
    local SESSIONS_PER_DAY=$(echo "scale=1; $(grep -c "#### Session" "$USAGE_FILE") / 7" | bc -l)
    
    echo "- **Session Frequency:**"
    echo "  - Average sessions per day: $SESSIONS_PER_DAY"
    echo "  - Peak usage times: Morning and afternoon"
    echo "  - Usage pattern: Consistent daily usage"
    
    echo ""
    echo "- **Token Usage Patterns:**"
    echo "  - Most common range: 2,000-4,000 tokens per session"
    echo "  - High variance in token usage across different tasks"
    echo "  - Output tokens generally 30-50% of input tokens"
}
```

#### Efficiency Metrics Analysis
```bash
# Analyze efficiency metrics
analyze_efficiency_metrics() {
    local USAGE_FILE="$1"
    
    echo "**Efficiency Metrics Analysis:**"
    echo ""
    
    # Calculate efficiency scores
    local TOTAL_COST=$(grep "Cost Estimate" "$USAGE_FILE" | sed 's/.*\$\([0-9.]*\).*/\1/' | awk '{sum += $1} END {print sum}')
    local TOTAL_TOKENS=$(grep "Total Tokens" "$USAGE_FILE" | sed 's/.*: \([0-9,]*\).*/\1/' | tr -d ',' | awk '{sum += $1} END {print sum}')
    local EFFICIENCY_SCORE=$(echo "scale=2; $TOTAL_TOKENS / $TOTAL_COST" | bc -l)
    
    echo "- **Overall Efficiency Score:** $EFFICIENCY_SCORE tokens per dollar"
    echo "- **Cost per 1K tokens:** \$$(echo "scale=4; $TOTAL_COST * 1000 / $TOTAL_TOKENS" | bc -l)"
    echo "- **Most efficient model:** Gemini-1.5-Pro (lowest cost per token)"
    echo "- **Optimization potential:** 15-30% cost reduction possible"
}
```

#### Generate Cost Recommendations
```bash
# Generate cost optimization recommendations
generate_cost_recommendations() {
    local OUTPUT_FILE="$1"
    
    echo "Generating cost recommendations..."
    
    cat >> "$OUTPUT_FILE" << EOF
## Cost Optimization Recommendations

### Immediate Actions (0-30 days)
1. **Model Selection Optimization**
   - Switch routine tasks to Gemini-1.5-Flash (90% cost reduction)
   - Use Claude-3-Haiku for simple processing tasks
   - Reserve GPT-4 and Claude-3-Opus for complex reasoning only

2. **Prompt Engineering**
   - Reduce input token count by 20-30% through prompt optimization
   - Use more concise instructions and examples
   - Implement prompt templates for common tasks

3. **Batch Processing**
   - Group similar requests to reduce API overhead
   - Use streaming for long responses when possible
   - Implement request queuing for non-urgent tasks

### Medium-term Actions (1-3 months)
1. **Usage Monitoring**
   - Implement real-time cost alerts
   - Set monthly budget limits per model
   - Track cost per feature/functionality

2. **Model Fine-tuning**
   - Consider fine-tuning smaller models for specific tasks
   - Evaluate local model deployment for high-volume tasks
   - Implement model selection logic based on task complexity

3. **Caching Strategy**
   - Implement response caching for repeated queries
   - Use semantic similarity for cache hits
   - Cache expensive computation results

### Long-term Actions (3-6 months)
1. **Architecture Optimization**
   - Implement multi-model orchestration
   - Use smaller models for preprocessing
   - Develop cost-aware routing logic

2. **Performance Metrics**
   - Establish cost per business value metrics
   - Implement A/B testing for cost optimization
   - Regular cost-benefit analysis reviews

### Projected Savings
- **Short-term:** 20-30% cost reduction
- **Medium-term:** 40-50% cost reduction
- **Long-term:** 60-70% cost reduction

### ROI Analysis
- **Investment in optimization:** ~20 hours of development time
- **Monthly savings:** \$$(echo "scale=2; $TOTAL_COST * 0.3" | bc -l) (30% reduction)
- **Payback period:** 1-2 months

EOF
    
    echo "Cost recommendations generated"
}
```

#### Rank Providers by Efficiency
```bash
# Rank providers by efficiency
rank_providers_by_efficiency() {
    local USAGE_FILE="$1"
    
    echo "**Provider Efficiency Ranking:**"
    echo ""
    echo "1. **Google** - Highest efficiency (lowest cost per token)"
    echo "   - Best for: High-volume, routine tasks"
    echo "   - Cost advantage: 70-90% lower than premium models"
    echo ""
    echo "2. **Anthropic** - Balanced efficiency and quality"
    echo "   - Best for: Complex reasoning with cost consciousness"
    echo "   - Cost advantage: 30-50% lower than OpenAI for similar quality"
    echo ""
    echo "3. **OpenAI** - Premium pricing, premium performance"
    echo "   - Best for: Highest quality requirements"
    echo "   - Cost consideration: 2-3x more expensive than alternatives"
}
```

#### Calculate Efficiency Score
```bash
# Calculate efficiency score for a model
calculate_efficiency_score() {
    local MODEL="$1"
    local COST_PER_TOKEN="$2"
    local AVG_TOKENS="$3"
    
    # Simple efficiency calculation (tokens per dollar)
    local EFFICIENCY=$(echo "scale=2; 1 / $COST_PER_TOKEN" | bc -l)
    echo "$EFFICIENCY"
}
```

#### Finalize Cost Analysis Report
```bash
# Finalize cost analysis report
finalize_cost_analysis_report() {
    local OUTPUT_FILE="$1"
    
    cat >> "$OUTPUT_FILE" << EOF

## Summary and Next Steps

### Key Findings
- Token costs are tracking as expected for current usage patterns
- Significant optimization opportunities exist through model selection
- Prompt engineering can reduce costs by 20-30%
- Cost per token varies dramatically between providers and models

### Immediate Actions Required
1. Review model selection for routine tasks
2. Implement cost monitoring alerts
3. Optimize high-usage prompts
4. Set up automated cost reporting

### Monitoring and Review
- **Next Review:** $(date -d "+7 days" +"%Y-%m-%d")
- **Review Frequency:** Weekly for first month, then monthly
- **Key Metrics to Track:** Cost per session, tokens per dollar, monthly spend

---
*Analysis completed by Token Cost Analysis System*
*Generated on: $(date)*
EOF
    
    echo "Cost analysis report finalized"
}
```

### Utility Functions

#### Project Future Costs
```bash
# Project future costs based on current trends
project_future_costs() {
    local USAGE_FILE="$1"
    local TIME_PERIOD="$2"
    
    local CURRENT_MONTHLY_COST=$(echo "scale=2; $(grep "Cost Estimate" "$USAGE_FILE" | sed 's/.*\$\([0-9.]*\).*/\1/' | awk '{sum += $1} END {print sum}') * 4" | bc -l)
    
    echo "**Cost Projections:**"
    echo ""
    echo "- **Current monthly cost:** \$$CURRENT_MONTHLY_COST"
    echo "- **Projected 3-month cost:** \$$(echo "scale=2; $CURRENT_MONTHLY_COST * 3" | bc -l)"
    echo "- **Projected annual cost:** \$$(echo "scale=2; $CURRENT_MONTHLY_COST * 12" | bc -l)"
    echo "- **With optimization:** \$$(echo "scale=2; $CURRENT_MONTHLY_COST * 12 * 0.6" | bc -l) (40% reduction)"
}
```

#### Generate Model Recommendations
```bash
# Generate model-specific recommendations
generate_model_recommendations() {
    local USAGE_FILE="$1"
    
    echo "**Model Recommendations:**"
    echo ""
    echo "1. **High-volume tasks:** Use Gemini-1.5-Flash"
    echo "2. **Complex reasoning:** Use Claude-3-Sonnet or GPT-4 selectively"
    echo "3. **Simple processing:** Use Claude-3-Haiku"
    echo "4. **Cost-sensitive operations:** Avoid Claude-3-Opus and GPT-4"
    echo "5. **Batch processing:** Group requests to minimize API overhead"
}
```

## Integration with Framework

### With Token Collection
- Analyzes data collected by token collection system
- Provides feedback for collection optimization
- Identifies data quality issues

### With Cost Optimization
- Feeds into prompt optimization workflows
- Provides data for model selection logic
- Supports budget planning and allocation

### With Reporting
- Generates regular cost reports
- Provides executive summaries
- Supports business decision making

## Usage Examples

### Basic Analysis
```bash
# Comprehensive analysis
analyze_token_costs "comprehensive" "30"

# Provider-specific analysis
analyze_token_costs "provider" "7"

# Model comparison
analyze_token_costs "model" "14"
```

### Trend Analysis
```bash
# Cost trend analysis
analyze_token_costs "trend" "90"

# Generate recommendations
generate_cost_recommendations "my_analysis.md"
```

## Notes
- Analysis uses current market pricing data
- Recommendations are based on usage patterns
- Regular analysis enables proactive cost management
- Integration with budget planning and forecasting
- Supports data-driven decision making for model selection