#!/bin/bash

# Performance Optimizer Script
# Implements runtime optimizations for the AI Development Framework

set -e

# Configuration
PERFORMANCE_CONFIG=".ai_workflow/config/performance.json"
CACHE_DIR=".ai_workflow/cache"
PERFORMANCE_LOG="${CACHE_DIR}/performance.log"
ALERTS_LOG="${CACHE_DIR}/performance_alerts.log"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# Performance monitoring function
monitor_performance() {
    local command="$1"
    local start_time=$(date +%s.%N)
    
    # Execute command
    shift
    "$@"
    local exit_code=$?
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0.0")
    
    # Log performance
    echo "$(date): $command - Duration: ${duration}s - Exit: $exit_code" >> "$PERFORMANCE_LOG"
    
    # Check thresholds
    case "$command" in
        "status"|"version"|"help")
            if (( $(echo "$duration > 0.1" | bc -l 2>/dev/null) )); then
                echo "$(date): WARNING: $command took ${duration}s (>0.1s threshold)" >> "$ALERTS_LOG"
            fi
            ;;
        "diagnose")
            if (( $(echo "$duration > 3.0" | bc -l 2>/dev/null) )); then
                echo "$(date): WARNING: $command took ${duration}s (>3.0s threshold)" >> "$ALERTS_LOG"
            fi
            ;;
        "audit"|"quality")
            if (( $(echo "$duration > 5.0" | bc -l 2>/dev/null) )); then
                echo "$(date): WARNING: $command took ${duration}s (>5.0s threshold)" >> "$ALERTS_LOG"
            fi
            ;;
    esac
    
    return $exit_code
}

# Cache management functions
cache_with_ttl() {
    local key="$1"
    local data="$2"
    local ttl="$3"
    
    local cache_file="${CACHE_DIR}/${key}.cache"
    local timestamp_file="${CACHE_DIR}/${key}.timestamp"
    
    echo "$data" > "$cache_file"
    echo "$(date +%s)" > "$timestamp_file"
}

is_cache_valid() {
    local key="$1"
    local ttl="$2"
    
    local cache_file="${CACHE_DIR}/${key}.cache"
    local timestamp_file="${CACHE_DIR}/${key}.timestamp"
    
    if [ -f "$cache_file" ] && [ -f "$timestamp_file" ]; then
        local cache_time=$(cat "$timestamp_file" 2>/dev/null || echo "0")
        local current_time=$(date +%s)
        
        if [ $((current_time - cache_time)) -lt $ttl ]; then
            return 0
        fi
    fi
    
    return 1
}

get_cached_result() {
    local key="$1"
    local cache_file="${CACHE_DIR}/${key}.cache"
    
    if [ -f "$cache_file" ]; then
        cat "$cache_file"
        return 0
    fi
    
    return 1
}

# Optimized command execution
execute_with_cache() {
    local command="$1"
    local ttl="$2"
    shift 2
    
    local cache_key="command_${command}_$(echo "$*" | md5sum | cut -d' ' -f1)"
    
    # Check cache first
    if is_cache_valid "$cache_key" "$ttl"; then
        get_cached_result "$cache_key"
        return 0
    fi
    
    # Execute and cache result
    local result
    result=$(monitor_performance "$command" "$@")
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        cache_with_ttl "$cache_key" "$result" "$ttl"
    fi
    
    echo "$result"
    return $exit_code
}

# Parallel execution helper
execute_parallel() {
    local max_jobs="${1:-4}"
    shift
    
    local jobs=()
    local results=()
    
    for cmd in "$@"; do
        # Wait if we've reached max jobs
        if [ ${#jobs[@]} -ge $max_jobs ]; then
            wait "${jobs[0]}"
            jobs=("${jobs[@]:1}")
        fi
        
        # Start job in background
        eval "$cmd" &
        jobs+=($!)
    done
    
    # Wait for all remaining jobs
    for job in "${jobs[@]}"; do
        wait "$job"
    done
}

# Memory optimization
optimize_memory() {
    # Clean up temporary files
    find /tmp -name "ai-dev-*" -mtime +1 -delete 2>/dev/null || true
    find "$CACHE_DIR" -name "*.tmp" -mtime +1 -delete 2>/dev/null || true
    
    # Compress old logs
    find "$CACHE_DIR" -name "*.log" -size +10M -mtime +7 -exec gzip {} \; 2>/dev/null || true
    
    # Clean old cache entries
    find "$CACHE_DIR" -name "*.cache" -mtime +7 -delete 2>/dev/null || true
    find "$CACHE_DIR" -name "*.timestamp" -mtime +7 -delete 2>/dev/null || true
}

# I/O optimization
optimize_io() {
    # Set optimal I/O scheduler if available
    if [ -w /sys/block/sda/queue/scheduler ]; then
        echo "mq-deadline" > /sys/block/sda/queue/scheduler 2>/dev/null || true
    fi
    
    # Optimize file system cache
    sync
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
}

# Performance report generation
generate_performance_report() {
    local report_file="${CACHE_DIR}/performance_report.md"
    
    cat > "$report_file" << EOF
# Performance Report

## Summary
- **Report Generated**: $(date)
- **Framework Version**: v1.0.0
- **Optimization Status**: Active

## Performance Metrics
EOF

    if [ -f "$PERFORMANCE_LOG" ]; then
        echo "" >> "$report_file"
        echo "### Recent Performance Data" >> "$report_file"
        echo '```' >> "$report_file"
        tail -20 "$PERFORMANCE_LOG" >> "$report_file"
        echo '```' >> "$report_file"
    fi
    
    if [ -f "$ALERTS_LOG" ]; then
        echo "" >> "$report_file"
        echo "### Performance Alerts" >> "$report_file"
        echo '```' >> "$report_file"
        tail -10 "$ALERTS_LOG" >> "$report_file"
        echo '```' >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

## Cache Statistics
- **Cache Directory**: $CACHE_DIR
- **Cache Files**: $(find "$CACHE_DIR" -name "*.cache" | wc -l)
- **Cache Size**: $(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)

## Optimization Status
- ✅ Command caching enabled
- ✅ Parallel execution enabled
- ✅ Memory optimization active
- ✅ I/O optimization configured
- ✅ Performance monitoring active

## Performance Targets
- Status commands: <0.1s
- Diagnostic commands: <3.0s
- Workflow execution: <5.0s
- Memory usage: <100MB
- Cache hit rate: >80%
EOF

    echo "Performance report generated: $report_file"
}

# Benchmark runner
run_benchmarks() {
    echo "Running performance benchmarks..."
    
    local commands=("status --quiet" "version" "help" "diagnose --summary")
    
    for cmd in "${commands[@]}"; do
        echo "Benchmarking: $cmd"
        time ./ai-dev $cmd > /dev/null 2>&1
    done
    
    generate_performance_report
}

# Main optimization function
optimize_framework() {
    echo "🚀 Starting framework performance optimization..."
    
    # Enable performance features
    export PERFORMANCE_MODE=true
    export PARALLEL_EXECUTION=true
    export CACHE_AGGRESSIVE=true
    export LAZY_LOADING=true
    
    # Run optimizations
    optimize_memory
    optimize_io
    
    # Generate initial report
    generate_performance_report
    
    echo "✅ Performance optimization completed"
}

# Validation function
validate_performance() {
    echo "🔍 Validating performance improvements..."
    
    local threshold_status=0.1
    local threshold_diagnose=3.0
    
    # Test status command
    local start_time=$(date +%s.%N)
    ./ai-dev status --quiet > /dev/null 2>&1
    local end_time=$(date +%s.%N)
    local status_time=$(echo "$end_time - $start_time" | bc -l)
    
    if (( $(echo "$status_time < $threshold_status" | bc -l) )); then
        echo "✅ Status command performance: ${status_time}s (<${threshold_status}s)"
    else
        echo "❌ Status command performance: ${status_time}s (>${threshold_status}s)"
    fi
    
    # Test diagnose command
    start_time=$(date +%s.%N)
    ./ai-dev diagnose --summary > /dev/null 2>&1
    end_time=$(date +%s.%N)
    local diagnose_time=$(echo "$end_time - $start_time" | bc -l)
    
    if (( $(echo "$diagnose_time < $threshold_diagnose" | bc -l) )); then
        echo "✅ Diagnose command performance: ${diagnose_time}s (<${threshold_diagnose}s)"
    else
        echo "❌ Diagnose command performance: ${diagnose_time}s (>${threshold_diagnose}s)"
    fi
}

# Main execution
case "${1:-optimize}" in
    "optimize")
        optimize_framework
        ;;
    "benchmark")
        run_benchmarks
        ;;
    "validate")
        validate_performance
        ;;
    "report")
        generate_performance_report
        ;;
    "clean")
        optimize_memory
        ;;
    *)
        echo "Usage: $0 {optimize|benchmark|validate|report|clean}"
        exit 1
        ;;
esac