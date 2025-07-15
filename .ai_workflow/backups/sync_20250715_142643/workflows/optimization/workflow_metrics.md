# Workflow Metrics

## Purpose
Collect, analyze, and report comprehensive metrics for workflow performance, resource usage, and system health to enable data-driven optimization decisions.

## Input Parameters
- `metric_type`: Type of metrics to collect (performance, resource, usage, all)
- `time_range`: Time range for metrics collection (1h, 24h, 7d, 30d)
- `workflow_filter`: Filter for specific workflows (optional)
- `output_format`: Output format (json, csv, html, dashboard)
- `include_historical`: Include historical trend data (default: true)

## Prerequisites
- Metrics collection system initialized
- Performance logging enabled
- System monitoring tools available
- Data storage permissions configured

## Process Flow

### 1. Metrics Collection System Setup
```bash
# Initialize metrics collection
metrics_timestamp=$(date +%Y%m%d_%H%M%S)
metrics_dir=".ai_workflow/metrics"
metrics_config="$metrics_dir/config.json"
metrics_db="$metrics_dir/metrics.db"

# Create metrics directory structure
mkdir -p "$metrics_dir"/{data,reports,dashboards,archives}

# Initialize metrics configuration
if [ ! -f "$metrics_config" ]; then
    cat > "$metrics_config" << EOF
{
    "version": "1.0.0",
    "collection_enabled": true,
    "collection_interval_seconds": 60,
    "retention_days": 30,
    "metrics_types": {
        "performance": {
            "enabled": true,
            "metrics": ["execution_time", "memory_usage", "cpu_usage", "disk_io"]
        },
        "resource": {
            "enabled": true,
            "metrics": ["system_load", "disk_space", "network_io", "process_count"]
        },
        "usage": {
            "enabled": true,
            "metrics": ["workflow_executions", "error_rates", "success_rates", "user_activity"]
        },
        "quality": {
            "enabled": true,
            "metrics": ["validation_pass_rate", "test_coverage", "code_quality_score"]
        }
    },
    "thresholds": {
        "slow_execution_ms": 5000,
        "high_memory_mb": 500,
        "high_cpu_percent": 80,
        "high_error_rate": 0.05
    },
    "alerts": {
        "enabled": true,
        "channels": ["log", "email", "webhook"]
    }
}
EOF
fi

# Initialize metrics database (simple file-based)
if [ ! -f "$metrics_db" ]; then
    cat > "$metrics_db" << EOF
timestamp,metric_type,workflow_id,metric_name,value,unit,tags
EOF
fi

echo "📊 Metrics collection system initialized"
```

### 2. Performance Metrics Collection
```bash
# Collect performance metrics
collect_performance_metrics() {
    echo "⚡ Collecting performance metrics..."
    
    local current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local performance_log=".ai_workflow/logs/performance.log"
    
    if [ -f "$performance_log" ]; then
        # Parse performance log for recent entries
        if [ "$time_range" = "1h" ]; then
            cutoff_time=$(date -d "1 hour ago" -u +%Y-%m-%dT%H:%M:%SZ)
        elif [ "$time_range" = "24h" ]; then
            cutoff_time=$(date -d "1 day ago" -u +%Y-%m-%dT%H:%M:%SZ)
        elif [ "$time_range" = "7d" ]; then
            cutoff_time=$(date -d "7 days ago" -u +%Y-%m-%dT%H:%M:%SZ)
        else
            cutoff_time=$(date -d "30 days ago" -u +%Y-%m-%dT%H:%M:%SZ)
        fi
        
        # Extract execution times
        execution_times=$(awk -v cutoff="$cutoff_time" '$1 >= cutoff' "$performance_log" | grep "execution_time" | cut -d: -f3 | sed 's/ms//')
        
        if [ -n "$execution_times" ]; then
            # Calculate statistics
            avg_execution_time=$(echo "$execution_times" | awk '{sum+=$1} END {if(NR>0) print sum/NR; else print 0}')
            max_execution_time=$(echo "$execution_times" | sort -n | tail -1)
            min_execution_time=$(echo "$execution_times" | sort -n | head -1)
            total_executions=$(echo "$execution_times" | wc -l)
            
            # Calculate percentiles
            p50_execution_time=$(echo "$execution_times" | sort -n | awk '{all[NR] = $0} END{print all[int(NR*0.5 - 0.5)+1]}')
            p95_execution_time=$(echo "$execution_times" | sort -n | awk '{all[NR] = $0} END{print all[int(NR*0.95 - 0.5)+1]}')
            p99_execution_time=$(echo "$execution_times" | sort -n | awk '{all[NR] = $0} END{print all[int(NR*0.99 - 0.5)+1]}')
            
            # Store metrics
            echo "$current_time,performance,all,avg_execution_time,$avg_execution_time,ms,time_range=$time_range" >> "$metrics_db"
            echo "$current_time,performance,all,max_execution_time,$max_execution_time,ms,time_range=$time_range" >> "$metrics_db"
            echo "$current_time,performance,all,min_execution_time,$min_execution_time,ms,time_range=$time_range" >> "$metrics_db"
            echo "$current_time,performance,all,total_executions,$total_executions,count,time_range=$time_range" >> "$metrics_db"
            echo "$current_time,performance,all,p50_execution_time,$p50_execution_time,ms,time_range=$time_range" >> "$metrics_db"
            echo "$current_time,performance,all,p95_execution_time,$p95_execution_time,ms,time_range=$time_range" >> "$metrics_db"
            echo "$current_time,performance,all,p99_execution_time,$p99_execution_time,ms,time_range=$time_range" >> "$metrics_db"
            
            echo "📈 Performance metrics collected: $total_executions executions analyzed"
        else
            echo "ℹ️  No performance data found for time range: $time_range"
        fi
        
        # Collect memory usage metrics
        memory_usage=$(awk -v cutoff="$cutoff_time" '$1 >= cutoff' "$performance_log" | grep "memory_usage" | cut -d: -f3 | sed 's/kb//')
        
        if [ -n "$memory_usage" ]; then
            avg_memory=$(echo "$memory_usage" | awk '{sum+=$1} END {if(NR>0) print sum/NR; else print 0}')
            max_memory=$(echo "$memory_usage" | sort -n | tail -1)
            
            echo "$current_time,performance,all,avg_memory_usage,$avg_memory,kb,time_range=$time_range" >> "$metrics_db"
            echo "$current_time,performance,all,max_memory_usage,$max_memory,kb,time_range=$time_range" >> "$metrics_db"
        fi
    fi
}

# Collect performance metrics based on type
if [ "$metric_type" = "performance" ] || [ "$metric_type" = "all" ]; then
    collect_performance_metrics
fi
```

### 3. Resource Usage Metrics
```bash
# Collect system resource metrics
collect_resource_metrics() {
    echo "💾 Collecting resource usage metrics..."
    
    local current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    # System load
    system_load=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | tr -d ' ')
    
    # Memory usage
    memory_info=$(free -m | grep '^Mem:')
    total_memory=$(echo "$memory_info" | awk '{print $2}')
    used_memory=$(echo "$memory_info" | awk '{print $3}')
    memory_usage_percent=$(awk "BEGIN {printf \"%.2f\", ($used_memory / $total_memory) * 100}")
    
    # Disk usage
    disk_usage=$(df -h . | tail -1 | awk '{print $5}' | sed 's/%//')
    disk_available=$(df -h . | tail -1 | awk '{print $4}')
    
    # Process count
    process_count=$(ps aux | wc -l)
    
    # Network I/O (if available)
    network_io=""
    if command -v sar >/dev/null 2>&1; then
        network_io=$(sar -n DEV 1 1 | grep -v Average | grep -v Interface | tail -1 | awk '{print $5+$6}')
    fi
    
    # Store resource metrics
    echo "$current_time,resource,system,system_load,$system_load,load,time_range=$time_range" >> "$metrics_db"
    echo "$current_time,resource,system,memory_usage_percent,$memory_usage_percent,%,time_range=$time_range" >> "$metrics_db"
    echo "$current_time,resource,system,disk_usage_percent,$disk_usage,%,time_range=$time_range" >> "$metrics_db"
    echo "$current_time,resource,system,process_count,$process_count,count,time_range=$time_range" >> "$metrics_db"
    
    if [ -n "$network_io" ]; then
        echo "$current_time,resource,system,network_io,$network_io,bytes,time_range=$time_range" >> "$metrics_db"
    fi
    
    echo "📊 Resource metrics collected: Load=$system_load, Memory=${memory_usage_percent}%, Disk=${disk_usage}%"
}

# Collect resource metrics based on type
if [ "$metric_type" = "resource" ] || [ "$metric_type" = "all" ]; then
    collect_resource_metrics
fi
```

### 4. Usage Analytics
```bash
# Collect usage analytics
collect_usage_metrics() {
    echo "📈 Collecting usage analytics..."
    
    local current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local workflow_logs=".ai_workflow/logs"
    
    # Workflow execution counts
    workflow_executions=0
    error_count=0
    success_count=0
    
    # Count executions by workflow
    declare -A workflow_counts
    declare -A workflow_errors
    
    if [ -d "$workflow_logs" ]; then
        # Parse log files for execution data
        for log_file in "$workflow_logs"/*.log; do
            if [ -f "$log_file" ]; then
                # Count total executions
                executions=$(grep -c "workflow:" "$log_file" 2>/dev/null || echo 0)
                workflow_executions=$((workflow_executions + executions))
                
                # Count errors
                errors=$(grep -c "ERROR\|FAILED\|failed" "$log_file" 2>/dev/null || echo 0)
                error_count=$((error_count + errors))
                
                # Count successes
                successes=$(grep -c "SUCCESS\|completed successfully" "$log_file" 2>/dev/null || echo 0)
                success_count=$((success_count + successes))
                
                # Per-workflow statistics
                log_name=$(basename "$log_file" .log)
                workflow_counts["$log_name"]=$executions
                workflow_errors["$log_name"]=$errors
            fi
        done
    fi
    
    # Calculate rates
    if [ $workflow_executions -gt 0 ]; then
        error_rate=$(awk "BEGIN {printf \"%.4f\", $error_count / $workflow_executions}")
        success_rate=$(awk "BEGIN {printf \"%.4f\", $success_count / $workflow_executions}")
    else
        error_rate="0.0000"
        success_rate="0.0000"
    fi
    
    # Store usage metrics
    echo "$current_time,usage,all,total_executions,$workflow_executions,count,time_range=$time_range" >> "$metrics_db"
    echo "$current_time,usage,all,error_count,$error_count,count,time_range=$time_range" >> "$metrics_db"
    echo "$current_time,usage,all,success_count,$success_count,count,time_range=$time_range" >> "$metrics_db"
    echo "$current_time,usage,all,error_rate,$error_rate,rate,time_range=$time_range" >> "$metrics_db"
    echo "$current_time,usage,all,success_rate,$success_rate,rate,time_range=$time_range" >> "$metrics_db"
    
    # Most used workflows
    echo "🔥 Most used workflows:"
    for workflow in "${!workflow_counts[@]}"; do
        echo "   - $workflow: ${workflow_counts[$workflow]} executions"
        echo "$current_time,usage,$workflow,executions,${workflow_counts[$workflow]},count,time_range=$time_range" >> "$metrics_db"
    done
    
    echo "📊 Usage metrics collected: $workflow_executions executions, ${success_rate} success rate"
}

# Collect usage metrics based on type
if [ "$metric_type" = "usage" ] || [ "$metric_type" = "all" ]; then
    collect_usage_metrics
fi
```

### 5. Quality Metrics
```bash
# Collect quality metrics
collect_quality_metrics() {
    echo "🎯 Collecting quality metrics..."
    
    local current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local validation_logs=".ai_workflow/logs/validation.log"
    
    # Validation pass rates
    validation_total=0
    validation_passed=0
    validation_failed=0
    
    if [ -f "$validation_logs" ]; then
        validation_total=$(grep -c "validation:" "$validation_logs" 2>/dev/null || echo 0)
        validation_passed=$(grep -c "validation:.*PASSED" "$validation_logs" 2>/dev/null || echo 0)
        validation_failed=$(grep -c "validation:.*FAILED" "$validation_logs" 2>/dev/null || echo 0)
    fi
    
    # Calculate validation pass rate
    if [ $validation_total -gt 0 ]; then
        validation_pass_rate=$(awk "BEGIN {printf \"%.4f\", $validation_passed / $validation_total}")
    else
        validation_pass_rate="0.0000"
    fi
    
    # Code quality score (simplified)
    code_quality_score=0
    workflow_count=$(find .ai_workflow/workflows -name "*.md" | wc -l)
    
    if [ $workflow_count -gt 0 ]; then
        # Basic quality checks
        workflows_with_purpose=$(find .ai_workflow/workflows -name "*.md" -exec grep -l "## Purpose" {} \; | wc -l)
        workflows_with_params=$(find .ai_workflow/workflows -name "*.md" -exec grep -l "## Input Parameters" {} \; | wc -l)
        workflows_with_process=$(find .ai_workflow/workflows -name "*.md" -exec grep -l "## Process Flow" {} \; | wc -l)
        
        # Calculate quality score (0-100)
        quality_score=$(awk "BEGIN {printf \"%.2f\", (($workflows_with_purpose + $workflows_with_params + $workflows_with_process) / (3 * $workflow_count)) * 100}")
        code_quality_score=$quality_score
    fi
    
    # Store quality metrics
    echo "$current_time,quality,all,validation_total,$validation_total,count,time_range=$time_range" >> "$metrics_db"
    echo "$current_time,quality,all,validation_passed,$validation_passed,count,time_range=$time_range" >> "$metrics_db"
    echo "$current_time,quality,all,validation_failed,$validation_failed,count,time_range=$time_range" >> "$metrics_db"
    echo "$current_time,quality,all,validation_pass_rate,$validation_pass_rate,rate,time_range=$time_range" >> "$metrics_db"
    echo "$current_time,quality,all,code_quality_score,$code_quality_score,score,time_range=$time_range" >> "$metrics_db"
    
    echo "🎯 Quality metrics collected: ${validation_pass_rate} validation pass rate, ${code_quality_score} quality score"
}

# Collect quality metrics based on type
if [ "$metric_type" = "quality" ] || [ "$metric_type" = "all" ]; then
    collect_quality_metrics
fi
```

### 6. Metrics Analysis and Reporting
```bash
# Analyze collected metrics
analyze_metrics() {
    echo "🔍 Analyzing metrics data..."
    
    local report_file="$metrics_dir/reports/metrics_report_${metrics_timestamp}.md"
    local json_report="$metrics_dir/reports/metrics_report_${metrics_timestamp}.json"
    
    # Create analysis report
    cat > "$report_file" << EOF
# Workflow Metrics Report

## Report Summary
- **Generated**: $(date)
- **Time Range**: $time_range
- **Metric Types**: $metric_type
- **Report ID**: $metrics_timestamp

## Performance Metrics
EOF
    
    # Analyze performance data
    if [ "$metric_type" = "performance" ] || [ "$metric_type" = "all" ]; then
        perf_data=$(grep "performance" "$metrics_db" | grep "time_range=$time_range")
        
        if [ -n "$perf_data" ]; then
            avg_exec_time=$(echo "$perf_data" | grep "avg_execution_time" | cut -d, -f5)
            max_exec_time=$(echo "$perf_data" | grep "max_execution_time" | cut -d, -f5)
            total_exec=$(echo "$perf_data" | grep "total_executions" | cut -d, -f5)
            
            cat >> "$report_file" << EOF
- **Average Execution Time**: ${avg_exec_time}ms
- **Maximum Execution Time**: ${max_exec_time}ms
- **Total Executions**: $total_exec
EOF
        fi
    fi
    
    cat >> "$report_file" << EOF

## Resource Usage
EOF
    
    # Analyze resource data
    if [ "$metric_type" = "resource" ] || [ "$metric_type" = "all" ]; then
        resource_data=$(grep "resource" "$metrics_db" | grep "time_range=$time_range")
        
        if [ -n "$resource_data" ]; then
            system_load=$(echo "$resource_data" | grep "system_load" | cut -d, -f5)
            memory_usage=$(echo "$resource_data" | grep "memory_usage_percent" | cut -d, -f5)
            disk_usage=$(echo "$resource_data" | grep "disk_usage_percent" | cut -d, -f5)
            
            cat >> "$report_file" << EOF
- **System Load**: $system_load
- **Memory Usage**: ${memory_usage}%
- **Disk Usage**: ${disk_usage}%
EOF
        fi
    fi
    
    cat >> "$report_file" << EOF

## Usage Analytics
EOF
    
    # Analyze usage data
    if [ "$metric_type" = "usage" ] || [ "$metric_type" = "all" ]; then
        usage_data=$(grep "usage" "$metrics_db" | grep "time_range=$time_range")
        
        if [ -n "$usage_data" ]; then
            total_exec=$(echo "$usage_data" | grep "total_executions" | cut -d, -f5)
            success_rate=$(echo "$usage_data" | grep "success_rate" | cut -d, -f5)
            error_rate=$(echo "$usage_data" | grep "error_rate" | cut -d, -f5)
            
            cat >> "$report_file" << EOF
- **Total Executions**: $total_exec
- **Success Rate**: ${success_rate}
- **Error Rate**: ${error_rate}
EOF
        fi
    fi
    
    cat >> "$report_file" << EOF

## Quality Metrics
EOF
    
    # Analyze quality data
    if [ "$metric_type" = "quality" ] || [ "$metric_type" = "all" ]; then
        quality_data=$(grep "quality" "$metrics_db" | grep "time_range=$time_range")
        
        if [ -n "$quality_data" ]; then
            validation_pass_rate=$(echo "$quality_data" | grep "validation_pass_rate" | cut -d, -f5)
            code_quality_score=$(echo "$quality_data" | grep "code_quality_score" | cut -d, -f5)
            
            cat >> "$report_file" << EOF
- **Validation Pass Rate**: ${validation_pass_rate}
- **Code Quality Score**: ${code_quality_score}
EOF
        fi
    fi
    
    cat >> "$report_file" << EOF

## Recommendations
$(analyze_trends_and_recommendations)

## Data Files
- **Metrics Database**: $metrics_db
- **Raw Data**: Available in CSV format
- **Report Archive**: $report_file
EOF
    
    # Create JSON report for programmatic access
    cat > "$json_report" << EOF
{
    "report_id": "$metrics_timestamp",
    "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "time_range": "$time_range",
    "metric_type": "$metric_type",
    "metrics": {
        "performance": $(extract_json_metrics "performance"),
        "resource": $(extract_json_metrics "resource"),
        "usage": $(extract_json_metrics "usage"),
        "quality": $(extract_json_metrics "quality")
    }
}
EOF
    
    echo "📊 Metrics analysis completed"
    echo "📁 Report available at: $report_file"
    echo "📄 JSON data available at: $json_report"
}

# Helper function to analyze trends
analyze_trends_and_recommendations() {
    local recommendations=""
    
    # Performance recommendations
    if [ "$metric_type" = "performance" ] || [ "$metric_type" = "all" ]; then
        avg_time=$(grep "avg_execution_time" "$metrics_db" | grep "time_range=$time_range" | cut -d, -f5)
        if [ -n "$avg_time" ] && [ "$avg_time" -gt 5000 ]; then
            recommendations="${recommendations}- Consider optimizing workflow performance (avg: ${avg_time}ms)\n"
        fi
    fi
    
    # Resource recommendations
    if [ "$metric_type" = "resource" ] || [ "$metric_type" = "all" ]; then
        memory_usage=$(grep "memory_usage_percent" "$metrics_db" | grep "time_range=$time_range" | cut -d, -f5)
        if [ -n "$memory_usage" ] && [ "$(echo "$memory_usage > 80" | bc -l 2>/dev/null)" = "1" ]; then
            recommendations="${recommendations}- High memory usage detected (${memory_usage}%)\n"
        fi
    fi
    
    # Quality recommendations
    if [ "$metric_type" = "quality" ] || [ "$metric_type" = "all" ]; then
        quality_score=$(grep "code_quality_score" "$metrics_db" | grep "time_range=$time_range" | cut -d, -f5)
        if [ -n "$quality_score" ] && [ "$(echo "$quality_score < 80" | bc -l 2>/dev/null)" = "1" ]; then
            recommendations="${recommendations}- Improve code quality (score: ${quality_score})\n"
        fi
    fi
    
    if [ -z "$recommendations" ]; then
        echo "- All metrics within acceptable ranges"
    else
        echo -e "$recommendations"
    fi
}

# Helper function to extract JSON metrics
extract_json_metrics() {
    local metric_type="$1"
    local data=$(grep "$metric_type" "$metrics_db" | grep "time_range=$time_range")
    
    if [ -n "$data" ]; then
        echo "{"
        echo "$data" | while IFS=, read -r timestamp type workflow metric_name value unit tags; do
            echo "\"$metric_name\": {\"value\": $value, \"unit\": \"$unit\", \"timestamp\": \"$timestamp\"}"
        done | paste -sd ',' | sed 's/,$//'
        echo "}"
    else
        echo "{}"
    fi
}

analyze_metrics
```

### 7. Output Generation
```bash
# Generate output in requested format
generate_output() {
    case "$output_format" in
        "json")
            echo "📄 Generating JSON output..."
            cat "$metrics_dir/reports/metrics_report_${metrics_timestamp}.json"
            ;;
        "csv")
            echo "📊 Generating CSV output..."
            echo "metric_type,workflow_id,metric_name,value,unit,timestamp"
            grep "time_range=$time_range" "$metrics_db" | cut -d, -f2-6,1
            ;;
        "html")
            echo "🌐 Generating HTML dashboard..."
            html_file="$metrics_dir/dashboards/metrics_dashboard_${metrics_timestamp}.html"
            generate_html_dashboard "$html_file"
            echo "HTML dashboard generated: $html_file"
            ;;
        "dashboard")
            echo "📊 Generating interactive dashboard..."
            dashboard_file="$metrics_dir/dashboards/interactive_dashboard_${metrics_timestamp}.html"
            generate_interactive_dashboard "$dashboard_file"
            echo "Interactive dashboard generated: $dashboard_file"
            ;;
        *)
            echo "📋 Displaying markdown report..."
            cat "$metrics_dir/reports/metrics_report_${metrics_timestamp}.md"
            ;;
    esac
}

# Generate HTML dashboard
generate_html_dashboard() {
    local html_file="$1"
    
    cat > "$html_file" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Workflow Metrics Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .metric-card { border: 1px solid #ddd; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .metric-value { font-size: 24px; font-weight: bold; color: #007cba; }
        .metric-label { color: #666; font-size: 14px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px; }
    </style>
</head>
<body>
    <h1>Workflow Metrics Dashboard</h1>
    <div class="grid">
        <!-- Performance metrics will be inserted here -->
    </div>
</body>
</html>
EOF
}

generate_output
```

## Output
- Comprehensive metrics data in multiple formats
- Performance, resource, usage, and quality analytics
- Trend analysis and recommendations
- Interactive dashboards and reports
- Historical data and comparisons

## Error Handling
- Missing log files → Skip and continue with available data
- Invalid time ranges → Default to reasonable values
- Calculation errors → Report as unavailable
- File permission issues → Create with appropriate permissions
- Resource constraints → Reduce collection frequency

## Security Considerations
- Metrics data contains no sensitive information
- Access controls for metrics database
- Secure storage of historical data
- Rate limiting for metrics collection
- Privacy-safe analytics

## Dependencies
- System monitoring tools (free, ps, df, uptime)
- Log files from workflow executions
- File system access for data storage
- Mathematical calculation tools (awk, bc)
- Web server for dashboard hosting (optional)

## Success Criteria
- Metrics collected successfully for specified time range
- Data analysis completed without errors
- Reports generated in requested format
- Trends and recommendations provided
- Performance insights actionable