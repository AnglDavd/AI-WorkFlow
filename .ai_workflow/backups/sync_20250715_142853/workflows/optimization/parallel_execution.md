# Parallel Execution

## Purpose
Enable parallel execution of independent workflow tasks to improve overall processing time and system resource utilization.

## Input Parameters
- `workflow_list`: List of workflows to execute in parallel
- `max_parallel_jobs`: Maximum number of concurrent jobs (default: 4)
- `timeout_seconds`: Timeout for each parallel job (default: 300)
- `fail_fast`: Stop all jobs if one fails (default: false)
- `dependency_graph`: JSON file defining workflow dependencies

## Prerequisites
- Independent workflows identified
- System resources sufficient for parallel execution
- Proper error handling configured
- Logging system available

## Process Flow

### 1. Dependency Analysis
```bash
# Initialize parallel execution
parallel_timestamp=$(date +%Y%m%d_%H%M%S)
parallel_dir=".ai_workflow/parallel/${parallel_timestamp}"
mkdir -p "$parallel_dir"

# Create dependency graph if not provided
if [ -z "$dependency_graph" ]; then
    dependency_graph="$parallel_dir/dependencies.json"
    
    # Generate basic dependency graph
    cat > "$dependency_graph" << EOF
{
    "workflows": {},
    "dependencies": {},
    "execution_order": []
}
EOF
fi

# Analyze workflow dependencies
analyze_dependencies() {
    local workflow_list="$1"
    local dependency_map=()
    
    echo "🔍 Analyzing workflow dependencies..."
    
    # Read existing dependencies if available
    if [ -f "$dependency_graph" ]; then
        echo "📋 Loading existing dependency graph..."
    fi
    
    # Analyze each workflow for dependencies
    for workflow in $workflow_list; do
        if [ -f "$workflow" ]; then
            workflow_name=$(basename "$workflow" .md)
            
            # Look for dependency indicators in workflow
            dependencies=$(grep -E "# Depends on:|# Requires:" "$workflow" | sed 's/.*: //')
            
            # Look for file dependencies
            file_deps=$(grep -E "source |\\. " "$workflow" | grep -v "^#" | awk '{print $2}' | tr -d '"' | tr '\n' ' ')
            
            # Look for workflow calls
            workflow_calls=$(grep -E "bash.*\\.md|\\./ai-dev" "$workflow" | grep -v "^#" | awk '{print $2}' | tr -d '"' | tr '\n' ' ')
            
            # Store dependencies
            if [ -n "$dependencies" ] || [ -n "$file_deps" ] || [ -n "$workflow_calls" ]; then
                dependency_map+=("$workflow_name:$dependencies $file_deps $workflow_calls")
            fi
        fi
    done
    
    # Create dependency graph
    cat > "$dependency_graph" << EOF
{
    "workflows": {
$(for workflow in $workflow_list; do
    workflow_name=$(basename "$workflow" .md)
    echo "        \"$workflow_name\": {\"path\": \"$workflow\", \"status\": \"pending\"}"
done | sed '$s/,$//')
    },
    "dependencies": {
$(for dep in "${dependency_map[@]}"; do
    workflow_name=$(echo "$dep" | cut -d: -f1)
    deps=$(echo "$dep" | cut -d: -f2-)
    echo "        \"$workflow_name\": [$(echo "$deps" | sed 's/ /", "/g' | sed 's/^/"/;s/$/"/')]"
done | sed '$s/,$//')
    },
    "execution_order": []
}
EOF
    
    echo "✅ Dependency analysis completed"
}

# If workflow_list is provided, analyze dependencies
if [ -n "$workflow_list" ]; then
    analyze_dependencies "$workflow_list"
fi
```

### 2. Execution Planning
```bash
# Create execution plan based on dependencies
create_execution_plan() {
    echo "📋 Creating parallel execution plan..."
    
    local execution_groups=()
    local processed_workflows=()
    local group_number=0
    
    # Read workflows from dependency graph
    workflows=$(grep -o '"[^"]*": {' "$dependency_graph" | cut -d'"' -f2)
    
    # Group workflows by dependency levels
    while [ ${#processed_workflows[@]} -lt $(echo "$workflows" | wc -w) ]; do
        current_group=()
        
        for workflow in $workflows; do
            # Skip if already processed
            if [[ " ${processed_workflows[@]} " =~ " ${workflow} " ]]; then
                continue
            fi
            
            # Check if all dependencies are satisfied
            dependencies=$(grep -A 1 "\"$workflow\":" "$dependency_graph" | grep -o '\[.*\]' | sed 's/[][]//g' | tr -d '"')
            
            can_execute=true
            if [ -n "$dependencies" ]; then
                for dep in $(echo "$dependencies" | tr ',' ' '); do
                    dep=$(echo "$dep" | tr -d ' ')
                    if [ -n "$dep" ] && [[ ! " ${processed_workflows[@]} " =~ " ${dep} " ]]; then
                        can_execute=false
                        break
                    fi
                done
            fi
            
            if [ "$can_execute" = true ]; then
                current_group+=("$workflow")
            fi
        done
        
        # Add current group to execution plan
        if [ ${#current_group[@]} -gt 0 ]; then
            execution_groups+=("${current_group[@]}")
            processed_workflows+=("${current_group[@]}")
            
            echo "📌 Group $group_number: ${current_group[@]}"
            group_number=$((group_number + 1))
        else
            # Break if no progress (circular dependencies)
            echo "⚠️  Warning: Possible circular dependencies detected"
            break
        fi
    done
    
    # Save execution plan
    cat > "$parallel_dir/execution_plan.json" << EOF
{
    "plan_created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "total_groups": $group_number,
    "max_parallel_jobs": $max_parallel_jobs,
    "execution_groups": [
$(for i in "${!execution_groups[@]}"; do
    echo "        {"
    echo "            \"group_id\": $i,"
    echo "            \"workflows\": [$(echo "${execution_groups[$i]}" | sed 's/ /", "/g' | sed 's/^/"/;s/$/"/')]"
    echo "        }"
    [ $i -ne $((${#execution_groups[@]} - 1)) ] && echo ","
done)
    ]
}
EOF
    
    echo "✅ Execution plan created with $group_number groups"
}

create_execution_plan
```

### 3. Parallel Job Management
```bash
# Job control functions
job_pids=()
job_status=()
job_start_times=()

# Start parallel job
start_parallel_job() {
    local workflow_path="$1"
    local job_id="$2"
    local job_log="$parallel_dir/job_${job_id}.log"
    
    echo "🚀 Starting job $job_id: $(basename "$workflow_path")"
    
    # Record start time
    job_start_times[$job_id]=$(date +%s)
    
    # Start job in background
    (
        echo "$(date): Starting workflow: $workflow_path" >> "$job_log"
        
        # Execute workflow
        if timeout "$timeout_seconds" bash "$workflow_path" >> "$job_log" 2>&1; then
            echo "$(date): Workflow completed successfully" >> "$job_log"
            echo "SUCCESS" > "$parallel_dir/job_${job_id}.status"
        else
            echo "$(date): Workflow failed or timed out" >> "$job_log"
            echo "FAILED" > "$parallel_dir/job_${job_id}.status"
        fi
    ) &
    
    # Store job PID
    job_pids[$job_id]=$!
    job_status[$job_id]="RUNNING"
    
    echo "✅ Job $job_id started with PID ${job_pids[$job_id]}"
}

# Wait for job completion
wait_for_job() {
    local job_id="$1"
    
    if [ -n "${job_pids[$job_id]}" ]; then
        wait "${job_pids[$job_id]}"
        job_exit_code=$?
        
        # Read final status
        if [ -f "$parallel_dir/job_${job_id}.status" ]; then
            job_status[$job_id]=$(cat "$parallel_dir/job_${job_id}.status")
        else
            job_status[$job_id]="UNKNOWN"
        fi
        
        # Calculate execution time
        end_time=$(date +%s)
        execution_time=$((end_time - job_start_times[$job_id]))
        
        echo "⏱️  Job $job_id completed in ${execution_time}s with status: ${job_status[$job_id]}"
        
        return $job_exit_code
    fi
    
    return 1
}

# Monitor all running jobs
monitor_jobs() {
    local active_jobs=()
    
    for job_id in "${!job_pids[@]}"; do
        if [ "${job_status[$job_id]}" = "RUNNING" ]; then
            if kill -0 "${job_pids[$job_id]}" 2>/dev/null; then
                active_jobs+=("$job_id")
            else
                wait_for_job "$job_id"
            fi
        fi
    done
    
    echo "${#active_jobs[@]}"
}
```

### 4. Parallel Execution Engine
```bash
# Execute workflows in parallel groups
execute_parallel_groups() {
    echo "⚡ Starting parallel execution..."
    
    local total_groups=$(grep -o '"total_groups": [0-9]*' "$parallel_dir/execution_plan.json" | cut -d' ' -f2)
    local overall_success=true
    
    # Process each execution group
    for group_id in $(seq 0 $((total_groups - 1))); do
        echo "📊 Processing execution group $group_id..."
        
        # Get workflows for this group
        group_workflows=$(grep -A 3 "\"group_id\": $group_id" "$parallel_dir/execution_plan.json" | grep -o '\[.*\]' | sed 's/[][]//g' | tr -d '"')
        
        local group_job_ids=()
        local job_counter=0
        
        # Start jobs for this group
        for workflow_name in $(echo "$group_workflows" | tr ',' ' '); do
            workflow_name=$(echo "$workflow_name" | tr -d ' ')
            
            # Get workflow path
            workflow_path=$(grep -A 1 "\"$workflow_name\":" "$dependency_graph" | grep -o '"path": "[^"]*"' | cut -d'"' -f4)
            
            if [ -f "$workflow_path" ]; then
                # Wait if we've reached max parallel jobs
                while [ "$(monitor_jobs)" -ge "$max_parallel_jobs" ]; do
                    sleep 1
                done
                
                # Start job
                job_id="${group_id}_${job_counter}"
                start_parallel_job "$workflow_path" "$job_id"
                group_job_ids+=("$job_id")
                job_counter=$((job_counter + 1))
            else
                echo "⚠️  Workflow file not found: $workflow_path"
            fi
        done
        
        # Wait for all jobs in this group to complete
        echo "⏳ Waiting for group $group_id jobs to complete..."
        group_success=true
        
        for job_id in "${group_job_ids[@]}"; do
            if ! wait_for_job "$job_id"; then
                group_success=false
                
                if [ "$fail_fast" = "true" ]; then
                    echo "❌ Job $job_id failed - stopping all jobs (fail_fast enabled)"
                    
                    # Kill all running jobs
                    for kill_job_id in "${!job_pids[@]}"; do
                        if [ "${job_status[$kill_job_id]}" = "RUNNING" ]; then
                            kill "${job_pids[$kill_job_id]}" 2>/dev/null
                            job_status[$kill_job_id]="KILLED"
                        fi
                    done
                    
                    overall_success=false
                    break 2
                fi
            fi
        done
        
        if [ "$group_success" = false ]; then
            overall_success=false
        fi
        
        echo "✅ Group $group_id completed (success: $group_success)"
    done
    
    return $([ "$overall_success" = true ] && echo 0 || echo 1)
}

# Execute the parallel workflow
if execute_parallel_groups; then
    echo "🎉 Parallel execution completed successfully"
    execution_result="SUCCESS"
else
    echo "❌ Parallel execution failed"
    execution_result="FAILED"
fi
```

### 5. Results Collection and Reporting
```bash
# Collect results from all jobs
collect_results() {
    echo "📊 Collecting execution results..."
    
    local successful_jobs=0
    local failed_jobs=0
    local total_execution_time=0
    
    # Create results summary
    cat > "$parallel_dir/results_summary.json" << EOF
{
    "execution_timestamp": "$parallel_timestamp",
    "execution_result": "$execution_result",
    "max_parallel_jobs": $max_parallel_jobs,
    "fail_fast": $fail_fast,
    "jobs": [
EOF
    
    # Process each job
    local first_job=true
    for job_id in "${!job_pids[@]}"; do
        if [ "$first_job" = false ]; then
            echo "," >> "$parallel_dir/results_summary.json"
        fi
        first_job=false
        
        # Calculate job metrics
        job_execution_time=$(($(date +%s) - job_start_times[$job_id]))
        total_execution_time=$((total_execution_time + job_execution_time))
        
        # Count success/failure
        if [ "${job_status[$job_id]}" = "SUCCESS" ]; then
            successful_jobs=$((successful_jobs + 1))
        else
            failed_jobs=$((failed_jobs + 1))
        fi
        
        # Add job to results
        cat >> "$parallel_dir/results_summary.json" << EOF
        {
            "job_id": "$job_id",
            "pid": "${job_pids[$job_id]}",
            "status": "${job_status[$job_id]}",
            "execution_time_seconds": $job_execution_time,
            "log_file": "job_${job_id}.log"
        }
EOF
    done
    
    # Complete results summary
    cat >> "$parallel_dir/results_summary.json" << EOF
    ],
    "summary": {
        "total_jobs": ${#job_pids[@]},
        "successful_jobs": $successful_jobs,
        "failed_jobs": $failed_jobs,
        "total_execution_time_seconds": $total_execution_time,
        "average_execution_time_seconds": $((total_execution_time / ${#job_pids[@]}))
    }
}
EOF
    
    echo "📈 Results summary:"
    echo "   - Total jobs: ${#job_pids[@]}"
    echo "   - Successful: $successful_jobs"
    echo "   - Failed: $failed_jobs"
    echo "   - Total execution time: ${total_execution_time}s"
    echo "   - Average execution time: $((total_execution_time / ${#job_pids[@]}))s"
}

collect_results
```

### 6. Error Handling and Cleanup
```bash
# Error handling and cleanup
cleanup_parallel_execution() {
    echo "🧹 Cleaning up parallel execution..."
    
    # Kill any remaining jobs
    for job_id in "${!job_pids[@]}"; do
        if [ "${job_status[$job_id]}" = "RUNNING" ]; then
            echo "🔪 Killing job $job_id (PID: ${job_pids[$job_id]})"
            kill "${job_pids[$job_id]}" 2>/dev/null
            job_status[$job_id]="KILLED"
        fi
    done
    
    # Archive execution logs
    if [ -d "$parallel_dir" ]; then
        archive_file=".ai_workflow/parallel/archive_${parallel_timestamp}.tar.gz"
        tar -czf "$archive_file" -C "$parallel_dir" .
        echo "📦 Execution logs archived: $archive_file"
    fi
    
    # Clean up temporary files
    rm -rf "$parallel_dir/temp_"*
    
    echo "✅ Cleanup completed"
}

# Set up signal handlers for cleanup
trap cleanup_parallel_execution EXIT INT TERM

# Generate final report
cat > "$parallel_dir/execution_report.md" << EOF
# Parallel Execution Report

## Execution Summary
- **Timestamp**: $parallel_timestamp
- **Result**: $execution_result
- **Max Parallel Jobs**: $max_parallel_jobs
- **Fail Fast**: $fail_fast

## Performance Metrics
- **Total Jobs**: ${#job_pids[@]}
- **Successful Jobs**: $successful_jobs
- **Failed Jobs**: $failed_jobs
- **Success Rate**: $(awk "BEGIN {printf \"%.2f\", ($successful_jobs / ${#job_pids[@]}) * 100}")%

## Execution Times
- **Total Execution Time**: ${total_execution_time}s
- **Average Job Time**: $((total_execution_time / ${#job_pids[@]}))s

## Job Details
$(for job_id in "${!job_pids[@]}"; do
    echo "- **Job $job_id**: Status=${job_status[$job_id]}, Time=$(($(date +%s) - job_start_times[$job_id]))s"
done)

## Log Files
- **Execution Directory**: $parallel_dir
- **Individual Job Logs**: job_*.log files
- **Results Summary**: results_summary.json

## Recommendations
$(if [ "$failed_jobs" -gt 0 ]; then
    echo "- Review failed job logs for error details"
    echo "- Consider adjusting timeout values"
    echo "- Check workflow dependencies"
else
    echo "- All jobs completed successfully"
    echo "- Consider increasing parallel jobs for better performance"
fi)
EOF

echo "📁 Parallel execution report generated: $parallel_dir/execution_report.md"
```

## Output
- Parallel execution results and status
- Individual job logs and status files
- Performance metrics and timing data
- Dependency analysis and execution plan
- Comprehensive execution report

## Error Handling
- Job timeout management → Kill and restart if needed
- Dependency resolution failures → Skip dependent jobs
- Resource exhaustion → Queue jobs until resources available
- Job failures → Continue or fail-fast based on configuration
- Signal handling → Clean shutdown on interruption

## Security Considerations
- Job isolation and sandboxing
- Resource limits for parallel jobs
- Secure logging without sensitive data
- Process cleanup on termination
- File permission management

## Dependencies
- Sufficient system resources for parallel execution
- Proper job scheduling and monitoring
- Timeout and signal handling capabilities
- File system for logging and coordination
- JSON processing for configuration management

## Success Criteria
- All independent jobs execute in parallel
- Dependency constraints respected
- Performance improvement achieved
- Resource utilization optimized
- Comprehensive monitoring and reporting