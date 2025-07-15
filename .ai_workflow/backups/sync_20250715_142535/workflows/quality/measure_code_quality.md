# Measure Code Quality Workflow

## Purpose
Collect, analyze, and track comprehensive code quality metrics including complexity, maintainability, test coverage, and technical debt to provide actionable insights for code improvement and long-term project health.

## When to Use
- During quality gates validation
- Before code reviews and merges
- As part of continuous integration
- For periodic code health assessments
- When evaluating technical debt

## Prerequisites
- Project type detection completed
- Dependencies validated
- Access to codebase and test results

## Input Parameters
- `project_path`: Path to project directory
- `measurement_scope`: full|changed_files|specific_files
- `target_files`: Specific files to analyze (optional)
- `include_tests`: Boolean to include test files in analysis (default: false)
- `generate_report`: Boolean to generate detailed report (default: true)
- `baseline_comparison`: Boolean to compare with previous measurements (default: true)

## Quality Metrics Collection

### Step 1: Initialize Measurement Session
```bash
project_type=$(cat .ai_workflow/cache/project_type.txt 2>/dev/null || echo "unknown")
measurement_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
measurement_id=$(date +%s)

echo "CODE_QUALITY_MEASUREMENT_START: Session $measurement_id"
echo "PROJECT_TYPE: $project_type"
echo "SCOPE: $measurement_scope"

# Create measurement session directory
measurement_dir=".ai_workflow/cache/quality_measurements/$measurement_id"
mkdir -p "$measurement_dir"

# Initialize metrics collection
metrics_file="$measurement_dir/metrics.json"
echo "{\"session_id\": \"$measurement_id\", \"timestamp\": \"$measurement_timestamp\", \"metrics\": {}}" > "$metrics_file"
```

### Step 2: Code Complexity Analysis
```bash
echo "QUALITY_METRIC: Analyzing code complexity"

complexity_metrics="{}"
total_files=0
complex_files=0
avg_complexity=0

case $project_type in
    "javascript"|"typescript")
        # Use complexity-report or similar tool
        if command -v cr > /dev/null 2>&1; then
            complexity_output=$(cr --format json "${project_path}/src" 2>/dev/null || echo '{"reports":[]}')
            
            # Parse complexity data
            total_files=$(echo "$complexity_output" | grep -o '"path":' | wc -l)
            high_complexity_files=$(echo "$complexity_output" | grep -c '"complexity":[^,]*[1-9][0-9]\+' || echo 0)
            
            # Extract average cyclomatic complexity
            avg_complexity=$(echo "$complexity_output" | grep -o '"cyclomatic":[0-9.]*' | cut -d':' -f2 | awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 0}')
        fi
        ;;
        
    "python")
        # Use radon for complexity analysis
        if command -v radon > /dev/null 2>&1; then
            complexity_output=$(radon cc "${project_path}" --json 2>/dev/null || echo '{}')
            
            # Count files and complex functions
            total_files=$(find "${project_path}" -name "*.py" -type f | wc -l)
            complex_files=$(echo "$complexity_output" | grep -c '"complexity":[^,]*[1-9][0-9]\+' || echo 0)
            
            # Calculate average complexity
            avg_complexity=$(radon cc "${project_path}" --average 2>/dev/null | grep -o '[0-9.]*' | head -1 || echo 0)
        fi
        ;;
        
    "java")
        # Use PMD or similar for Java complexity
        if command -v pmd > /dev/null 2>&1; then
            pmd_output=$(pmd -d "${project_path}" -f json -R rulesets/java/codesize.xml 2>/dev/null || echo '{"violations":[]}')
            
            total_files=$(find "${project_path}" -name "*.java" -type f | wc -l)
            complex_files=$(echo "$pmd_output" | grep -c 'CyclomaticComplexity' || echo 0)
        fi
        ;;
        
    "go")
        # Use gocyclo for Go complexity
        if command -v gocyclo > /dev/null 2>&1; then
            complexity_output=$(gocyclo -avg "${project_path}" 2>/dev/null || echo "0")
            avg_complexity=$(echo "$complexity_output" | head -1)
            
            total_files=$(find "${project_path}" -name "*.go" -type f | wc -l)
            complex_files=$(gocyclo -over 10 "${project_path}" 2>/dev/null | wc -l || echo 0)
        fi
        ;;
        
    "rust")
        # Use cargo-geiger for Rust complexity/safety
        if command -v cargo > /dev/null 2>&1; then
            total_files=$(find "${project_path}" -name "*.rs" -type f | wc -l)
            # Rust complexity analysis would need additional tools
            avg_complexity=0
        fi
        ;;
        
    *)
        echo "QUALITY_METRIC_WARNING: Complexity analysis not available for $project_type"
        ;;
esac

# Store complexity metrics
complexity_metrics="{
    \"total_files\": $total_files,
    \"complex_files\": $complex_files,
    \"average_complexity\": $avg_complexity,
    \"complexity_ratio\": $([ $total_files -gt 0 ] && echo "scale=2; $complex_files * 100 / $total_files" | bc || echo 0)
}"

echo "COMPLEXITY_RESULTS: Files: $total_files, Complex: $complex_files, Avg: $avg_complexity"
```

### Step 3: Test Coverage Analysis
```bash
echo "QUALITY_METRIC: Analyzing test coverage"

coverage_metrics="{}"
line_coverage=0
branch_coverage=0
function_coverage=0

case $project_type in
    "javascript"|"typescript")
        # Use nyc or jest coverage
        if command -v nyc > /dev/null 2>&1; then
            coverage_output=$(nyc report --reporter=json 2>/dev/null || echo '{"total":{}}')
            line_coverage=$(echo "$coverage_output" | grep -o '"lines":{"total":[0-9]*,"covered":[0-9]*' | sed 's/.*"covered":\([0-9]*\).*/\1/' || echo 0)
            branch_coverage=$(echo "$coverage_output" | grep -o '"branches":{"total":[0-9]*,"covered":[0-9]*' | sed 's/.*"covered":\([0-9]*\).*/\1/' || echo 0)
        elif grep -q '"jest"' "${project_path}/package.json" 2>/dev/null; then
            # Run jest with coverage
            COVERAGE_CHECK "npm test -- --coverage --silent" "${project_path}" 2>/dev/null || echo "Coverage check failed"
        fi
        ;;
        
    "python")
        # Use pytest-cov or coverage.py
        if command -v coverage > /dev/null 2>&1; then
            coverage_output=$(coverage report --format=json 2>/dev/null || echo '{"totals":{}}')
            line_coverage=$(echo "$coverage_output" | grep -o '"percent_covered":[0-9.]*' | cut -d':' -f2 || echo 0)
        elif command -v pytest > /dev/null 2>&1; then
            COVERAGE_CHECK "pytest --cov=${project_path} --cov-report=json" "${project_path}" 2>/dev/null || echo "Coverage check failed"
        fi
        ;;
        
    "java")
        # Use JaCoCo for Java coverage
        if FILE_EXISTS "${project_path}/target/site/jacoco/jacoco.xml"; then
            line_coverage=$(grep -o 'line-rate="[0-9.]*"' "${project_path}/target/site/jacoco/jacoco.xml" | cut -d'"' -f2 | head -1 || echo 0)
            branch_coverage=$(grep -o 'branch-rate="[0-9.]*"' "${project_path}/target/site/jacoco/jacoco.xml" | cut -d'"' -f2 | head -1 || echo 0)
        fi
        ;;
        
    "go")
        # Use go test -cover
        if command -v go > /dev/null 2>&1; then
            coverage_output=$(go test -cover ./... 2>/dev/null | grep -o 'coverage: [0-9.]*%' | grep -o '[0-9.]*' || echo 0)
            line_coverage=$coverage_output
        fi
        ;;
        
    "rust")
        # Use cargo-tarpaulin for Rust coverage
        if command -v cargo > /dev/null 2>&1 && cargo --list | grep -q tarpaulin; then
            coverage_output=$(cargo tarpaulin --out Json 2>/dev/null | grep -o '"coverage":[0-9.]*' | cut -d':' -f2 || echo 0)
            line_coverage=$coverage_output
        fi
        ;;
esac

# Store coverage metrics
coverage_metrics="{
    \"line_coverage\": $line_coverage,
    \"branch_coverage\": $branch_coverage,
    \"function_coverage\": $function_coverage
}"

echo "COVERAGE_RESULTS: Lines: ${line_coverage}%, Branches: ${branch_coverage}%"
```

### Step 4: Code Duplication Analysis
```bash
echo "QUALITY_METRIC: Analyzing code duplication"

duplication_metrics="{}"
duplicate_blocks=0
duplication_percentage=0

case $project_type in
    "javascript"|"typescript")
        # Use jscpd for JavaScript duplication detection
        if command -v jscpd > /dev/null 2>&1; then
            duplication_output=$(jscpd "${project_path}" --reporters json --output "${measurement_dir}/duplication.json" 2>/dev/null || echo '{}')
            duplicate_blocks=$(echo "$duplication_output" | grep -o '"duplicates":[0-9]*' | cut -d':' -f2 || echo 0)
            duplication_percentage=$(echo "$duplication_output" | grep -o '"percentage":[0-9.]*' | cut -d':' -f2 || echo 0)
        fi
        ;;
        
    "python")
        # Use pylint for duplicate code detection
        if command -v pylint > /dev/null 2>&1; then
            duplicate_lines=$(pylint "${project_path}" --disable=all --enable=duplicate-code 2>/dev/null | grep -c "duplicate code" || echo 0)
            duplicate_blocks=$duplicate_lines
        fi
        ;;
        
    "java")
        # Use PMD for Java duplication detection
        if command -v pmd > /dev/null 2>&1; then
            duplication_output=$(pmd -d "${project_path}" -f json -R rulesets/java/design.xml 2>/dev/null || echo '{"violations":[]}')
            duplicate_blocks=$(echo "$duplication_output" | grep -c 'duplicate' || echo 0)
        fi
        ;;
        
    *)
        echo "QUALITY_METRIC_INFO: Duplication analysis not available for $project_type"
        ;;
esac

duplication_metrics="{
    \"duplicate_blocks\": $duplicate_blocks,
    \"duplication_percentage\": $duplication_percentage
}"

echo "DUPLICATION_RESULTS: Blocks: $duplicate_blocks, Percentage: ${duplication_percentage}%"
```

### Step 5: Technical Debt Assessment
```bash
echo "QUALITY_METRIC: Assessing technical debt"

debt_metrics="{}"
debt_hours=0
debt_score=0
code_smells=0

case $project_type in
    "javascript"|"typescript")
        # Use ESLint for code smell detection
        if command -v eslint > /dev/null 2>&1; then
            lint_output=$(eslint "${project_path}" --format json 2>/dev/null || echo '[]')
            code_smells=$(echo "$lint_output" | grep -o '"severity":2' | wc -l || echo 0)
            
            # Estimate debt hours (rough calculation: 5 minutes per error)
            debt_hours=$(echo "scale=2; $code_smells * 5 / 60" | bc || echo 0)
        fi
        ;;
        
    "python")
        # Use pylint and bandit for technical debt
        if command -v pylint > /dev/null 2>&1; then
            pylint_score=$(pylint "${project_path}" 2>/dev/null | grep -o 'rated at [0-9.-]*' | grep -o '[0-9.-]*' || echo 0)
            debt_score=$(echo "10 - $pylint_score" | bc 2>/dev/null || echo 0)
            
            # Count code smells from pylint
            code_smells=$(pylint "${project_path}" 2>/dev/null | grep -c '^[CRWE]:' || echo 0)
            debt_hours=$(echo "scale=2; $code_smells * 3 / 60" | bc || echo 0)
        fi
        ;;
        
    "java")
        # Use PMD for technical debt analysis
        if command -v pmd > /dev/null 2>&1; then
            pmd_violations=$(pmd -d "${project_path}" -f json 2>/dev/null | grep -c '"violation"' || echo 0)
            code_smells=$pmd_violations
            debt_hours=$(echo "scale=2; $code_smells * 4 / 60" | bc || echo 0)
        fi
        ;;
        
    *)
        echo "QUALITY_METRIC_INFO: Technical debt analysis not available for $project_type"
        ;;
esac

debt_metrics="{
    \"debt_hours\": $debt_hours,
    \"debt_score\": $debt_score,
    \"code_smells\": $code_smells
}"

echo "DEBT_RESULTS: Hours: $debt_hours, Score: $debt_score, Smells: $code_smells"
```

### Step 6: Maintainability Index Calculation
```bash
echo "QUALITY_METRIC: Calculating maintainability index"

# Calculate composite maintainability index (0-100 scale)
# Formula: 171 - 5.2 * ln(HalsteadVolume) - 0.23 * CyclomaticComplexity - 16.2 * ln(LinesOfCode) + 50 * sin(sqrt(2.4 * percentComment))

# Simplified calculation based on available metrics
lines_of_code=$(find "${project_path}" -name "*.${project_type}" -type f -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}' || echo 1000)

# Basic maintainability calculation
maintainability_base=100
complexity_penalty=$(echo "scale=2; $avg_complexity * 2" | bc 2>/dev/null || echo 0)
coverage_bonus=$(echo "scale=2; $line_coverage / 10" | bc 2>/dev/null || echo 0)
duplication_penalty=$(echo "scale=2; $duplication_percentage * 2" | bc 2>/dev/null || echo 0)

maintainability_index=$(echo "scale=2; $maintainability_base - $complexity_penalty + $coverage_bonus - $duplication_penalty" | bc 2>/dev/null || echo 50)

# Ensure index is between 0 and 100
if [ $(echo "$maintainability_index > 100" | bc 2>/dev/null || echo 0) -eq 1 ]; then
    maintainability_index=100
fi
if [ $(echo "$maintainability_index < 0" | bc 2>/dev/null || echo 0) -eq 1 ]; then
    maintainability_index=0
fi

echo "MAINTAINABILITY_INDEX: $maintainability_index"
```

## Comprehensive Quality Score Calculation

### Quality Score Formula
```bash
# Calculate overall quality score (0-100)
# Weighted average of different metrics

complexity_weight=0.25
coverage_weight=0.30
duplication_weight=0.20
debt_weight=0.15
maintainability_weight=0.10

# Normalize metrics to 0-100 scale
complexity_score=$(echo "scale=2; 100 - ($avg_complexity * 10)" | bc 2>/dev/null || echo 50)
if [ $(echo "$complexity_score < 0" | bc 2>/dev/null || echo 0) -eq 1 ]; then
    complexity_score=0
fi

coverage_score=$line_coverage
duplication_score=$(echo "scale=2; 100 - ($duplication_percentage * 2)" | bc 2>/dev/null || echo 90)
debt_score=$(echo "scale=2; 100 - ($debt_hours * 5)" | bc 2>/dev/null || echo 80)

# Calculate weighted quality score
quality_score=$(echo "scale=2; 
    $complexity_score * $complexity_weight + 
    $coverage_score * $coverage_weight + 
    $duplication_score * $duplication_weight + 
    $debt_score * $debt_weight + 
    $maintainability_index * $maintainability_weight" | bc 2>/dev/null || echo 50)

echo "OVERALL_QUALITY_SCORE: $quality_score"
```

## Result Generation and Historical Tracking

### Generate Comprehensive Report
```bash
# Create detailed quality report
quality_report="{
    \"measurement_id\": \"$measurement_id\",
    \"timestamp\": \"$measurement_timestamp\",
    \"project_type\": \"$project_type\",
    \"scope\": \"$measurement_scope\",
    \"overall_quality_score\": $quality_score,
    \"complexity_metrics\": $complexity_metrics,
    \"coverage_metrics\": $coverage_metrics,
    \"duplication_metrics\": $duplication_metrics,
    \"debt_metrics\": $debt_metrics,
    \"maintainability_index\": $maintainability_index,
    \"lines_of_code\": $lines_of_code,
    \"recommendations\": []
}"

# Add recommendations based on metrics
recommendations=""
if [ $(echo "$avg_complexity > 10" | bc 2>/dev/null || echo 0) -eq 1 ]; then
    recommendations="${recommendations}\"Reduce cyclomatic complexity in complex functions\","
fi
if [ $(echo "$line_coverage < 80" | bc 2>/dev/null || echo 0) -eq 1 ]; then
    recommendations="${recommendations}\"Increase test coverage to at least 80%\","
fi
if [ $(echo "$duplication_percentage > 5" | bc 2>/dev/null || echo 0) -eq 1 ]; then
    recommendations="${recommendations}\"Refactor duplicate code blocks\","
fi
if [ $(echo "$debt_hours > 8" | bc 2>/dev/null || echo 0) -eq 1 ]; then
    recommendations="${recommendations}\"Address technical debt (estimated $debt_hours hours)\","
fi

# Remove trailing comma and update report
recommendations=$(echo "$recommendations" | sed 's/,$//')
quality_report=$(echo "$quality_report" | sed "s/\"recommendations\": \[\]/\"recommendations\": [$recommendations]/")

# Save comprehensive report
echo "$quality_report" > "$metrics_file"
echo "$quality_report" > ".ai_workflow/cache/latest_quality_report.json"
```

### Historical Comparison
```bash
if [ "$baseline_comparison" = "true" ]; then
    echo "QUALITY_TREND_ANALYSIS: Comparing with historical data"
    
    # Find previous measurement
    previous_report=".ai_workflow/cache/previous_quality_report.json"
    if FILE_EXISTS "$previous_report"; then
        prev_score=$(cat "$previous_report" | grep -o '"overall_quality_score":[0-9.]*' | cut -d':' -f2 || echo 0)
        score_diff=$(echo "scale=2; $quality_score - $prev_score" | bc 2>/dev/null || echo 0)
        
        if [ $(echo "$score_diff > 0" | bc 2>/dev/null || echo 0) -eq 1 ]; then
            echo "QUALITY_TREND: IMPROVED (+$score_diff points)"
        elif [ $(echo "$score_diff < 0" | bc 2>/dev/null || echo 0) -eq 1 ]; then
            echo "QUALITY_TREND: DEGRADED ($score_diff points)"
        else
            echo "QUALITY_TREND: STABLE (no change)"
        fi
    fi
    
    # Update baseline for next comparison
    cp ".ai_workflow/cache/latest_quality_report.json" "$previous_report"
fi
```

### Generate Human-Readable Summary
```bash
if [ "$generate_report" = "true" ]; then
    report_file="$measurement_dir/quality_summary.txt"
    
    cat > "$report_file" << EOF
Code Quality Measurement Report
===============================
Measurement ID: $measurement_id
Date: $measurement_timestamp
Project Type: $project_type

Overall Quality Score: ${quality_score}/100

Detailed Metrics:
- Average Complexity: $avg_complexity
- Test Coverage: ${line_coverage}%
- Code Duplication: ${duplication_percentage}%
- Technical Debt: ${debt_hours} hours
- Maintainability Index: ${maintainability_index}/100

Quality Assessment:
$([ $(echo "$quality_score >= 80" | bc 2>/dev/null || echo 0) -eq 1 ] && echo "✅ EXCELLENT - High quality codebase" || echo "")
$([ $(echo "$quality_score >= 60" | bc 2>/dev/null || echo 0) -eq 1 ] && [ $(echo "$quality_score < 80" | bc 2>/dev/null || echo 0) -eq 1 ] && echo "⚠️  GOOD - Minor improvements needed" || echo "")
$([ $(echo "$quality_score < 60" | bc 2>/dev/null || echo 0) -eq 1 ] && echo "❌ NEEDS_IMPROVEMENT - Significant issues detected" || echo "")

Recommendations:
$(echo "$recommendations" | sed 's/","/\n- /g' | sed 's/"//g' | sed 's/^/- /')

EOF

    echo "QUALITY_REPORT_GENERATED: $report_file"
fi
```

## Output Format

### Success Output
```
CODE_QUALITY_MEASUREMENT_SUCCESS: Analysis completed
OVERALL_SCORE: 78.5/100
COMPLEXITY_SCORE: 85/100
COVERAGE_SCORE: 72/100
DUPLICATION_SCORE: 88/100
DEBT_SCORE: 76/100
MAINTAINABILITY_INDEX: 73/100
TREND: IMPROVED (+3.2 points)
RECOMMENDATIONS: 3 items
MEASUREMENT_TIME: 45.2s
```

### Metrics JSON Output
```json
{
    "measurement_id": "1701234567",
    "timestamp": "2024-12-06 14:30:15",
    "overall_quality_score": 78.5,
    "complexity_metrics": {
        "total_files": 156,
        "complex_files": 12,
        "average_complexity": 4.2,
        "complexity_ratio": 7.69
    },
    "coverage_metrics": {
        "line_coverage": 72.5,
        "branch_coverage": 68.3,
        "function_coverage": 85.1
    },
    "recommendations": [
        "Increase test coverage to at least 80%",
        "Reduce complexity in 3 high-complexity functions"
    ]
}
```

## Integration Points

### With Quality Gates
- Provides quality metrics for gate validation
- Feeds into pass/fail decisions
- Generates actionable improvement recommendations

### With CI/CD Pipeline
- Automated quality measurement on commits
- Quality trend tracking over time
- Integration with code review processes

### With Monitoring System
- Long-term quality trend analysis
- Quality regression detection
- Technical debt tracking

## Success Criteria
- Comprehensive quality metrics collected
- Accurate quality score calculation
- Historical trend analysis functional
- Actionable recommendations generated
- Integration with quality gates working

## Dependencies
- Project type detection workflow
- Code analysis tools for target language
- Test coverage tools
- File system access permissions
- Mathematical calculation tools (bc)