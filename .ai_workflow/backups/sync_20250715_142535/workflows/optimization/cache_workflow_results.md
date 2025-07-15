# Cache Workflow Results

## Purpose
Implement intelligent caching system for workflow results to improve performance by avoiding redundant computations and operations.

## Input Parameters
- `cache_operation`: Operation to perform (store, retrieve, invalidate, clear, status)
- `workflow_id`: Unique identifier for the workflow
- `cache_key`: Specific cache key for the result
- `cache_data`: Data to cache (for store operations)
- `ttl_seconds`: Time-to-live in seconds (default: 3600)

## Prerequisites
- Cache directory structure initialized
- File system write permissions
- Workflow execution context available
- Cache configuration loaded

## Process Flow

### 1. Cache System Initialization
```bash
# Initialize cache system
cache_dir=".ai_workflow/cache"
cache_config="$cache_dir/config.json"
cache_index="$cache_dir/index.json"

# Create cache directory structure
mkdir -p "$cache_dir"/{workflows,results,metadata}

# Initialize cache configuration
if [ ! -f "$cache_config" ]; then
    cat > "$cache_config" << EOF
{
    "version": "1.0.0",
    "max_cache_size_mb": 100,
    "default_ttl_seconds": 3600,
    "cleanup_interval_hours": 24,
    "compression_enabled": true,
    "cache_levels": {
        "workflow_results": true,
        "validation_results": true,
        "dependency_checks": true,
        "api_responses": true
    }
}
EOF
fi

# Initialize cache index
if [ ! -f "$cache_index" ]; then
    cat > "$cache_index" << EOF
{
    "entries": {},
    "last_cleanup": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "total_size_bytes": 0,
    "hit_count": 0,
    "miss_count": 0
}
EOF
fi

echo "🗄️  Cache system initialized"
```

### 2. Cache Key Generation
```bash
# Generate cache key from inputs
generate_cache_key() {
    local workflow_id="$1"
    local input_params="$2"
    local context_hash="$3"
    
    # Create deterministic hash from inputs
    local key_input="${workflow_id}:${input_params}:${context_hash}"
    local cache_key=$(echo -n "$key_input" | sha256sum | cut -d' ' -f1)
    
    echo "$cache_key"
}

# Generate context hash for cache invalidation
generate_context_hash() {
    local workflow_file="$1"
    local dependency_files="$2"
    
    # Hash workflow file content and dependencies
    local workflow_hash=""
    if [ -f "$workflow_file" ]; then
        workflow_hash=$(sha256sum "$workflow_file" | cut -d' ' -f1)
    fi
    
    # Hash dependency files
    local dep_hash=""
    if [ -n "$dependency_files" ]; then
        for dep in $dependency_files; do
            if [ -f "$dep" ]; then
                dep_hash="${dep_hash}$(sha256sum "$dep" | cut -d' ' -f1)"
            fi
        done
    fi
    
    echo -n "${workflow_hash}${dep_hash}" | sha256sum | cut -d' ' -f1
}
```

### 3. Cache Operations
```bash
case "$cache_operation" in
    "store")
        echo "💾 Storing result in cache..."
        
        # Generate cache key if not provided
        if [ -z "$cache_key" ]; then
            cache_key=$(generate_cache_key "$workflow_id" "$input_params" "$context_hash")
        fi
        
        # Create cache entry
        cache_entry_file="$cache_dir/results/${cache_key}.json"
        cache_data_file="$cache_dir/results/${cache_key}.data"
        
        # Calculate expiration time
        expiration_time=$(date -d "+${ttl_seconds} seconds" -u +%Y-%m-%dT%H:%M:%SZ)
        
        # Store metadata
        cat > "$cache_entry_file" << EOF
{
    "workflow_id": "$workflow_id",
    "cache_key": "$cache_key",
    "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "expires_at": "$expiration_time",
    "ttl_seconds": $ttl_seconds,
    "context_hash": "$context_hash",
    "data_size_bytes": $(echo -n "$cache_data" | wc -c),
    "compressed": false
}
EOF
        
        # Store actual data
        echo "$cache_data" > "$cache_data_file"
        
        # Update cache index
        cache_size=$(wc -c < "$cache_data_file")
        update_cache_index "$cache_key" "$cache_size" "add"
        
        echo "✅ Cache entry stored: $cache_key"
        ;;
        
    "retrieve")
        echo "🔍 Retrieving result from cache..."
        
        # Generate cache key if not provided
        if [ -z "$cache_key" ]; then
            cache_key=$(generate_cache_key "$workflow_id" "$input_params" "$context_hash")
        fi
        
        cache_entry_file="$cache_dir/results/${cache_key}.json"
        cache_data_file="$cache_dir/results/${cache_key}.data"
        
        if [ -f "$cache_entry_file" ] && [ -f "$cache_data_file" ]; then
            # Check if cache entry is expired
            expires_at=$(grep -o '"expires_at": "[^"]*"' "$cache_entry_file" | cut -d'"' -f4)
            current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
            
            if [[ "$expires_at" > "$current_time" ]]; then
                # Cache hit
                echo "✅ Cache hit for key: $cache_key"
                cat "$cache_data_file"
                update_cache_statistics "hit"
                exit 0
            else
                # Cache expired
                echo "⏰ Cache expired for key: $cache_key"
                rm -f "$cache_entry_file" "$cache_data_file"
                update_cache_statistics "miss"
                exit 1
            fi
        else
            # Cache miss
            echo "❌ Cache miss for key: $cache_key"
            update_cache_statistics "miss"
            exit 1
        fi
        ;;
        
    "invalidate")
        echo "🗑️  Invalidating cache entries..."
        
        if [ -n "$cache_key" ]; then
            # Invalidate specific cache key
            cache_entry_file="$cache_dir/results/${cache_key}.json"
            cache_data_file="$cache_dir/results/${cache_key}.data"
            
            if [ -f "$cache_entry_file" ]; then
                cache_size=$(grep -o '"data_size_bytes": [0-9]*' "$cache_entry_file" | cut -d' ' -f2)
                rm -f "$cache_entry_file" "$cache_data_file"
                update_cache_index "$cache_key" "$cache_size" "remove"
                echo "✅ Cache entry invalidated: $cache_key"
            else
                echo "ℹ️  Cache entry not found: $cache_key"
            fi
        elif [ -n "$workflow_id" ]; then
            # Invalidate all entries for workflow
            invalidated_count=0
            for entry_file in "$cache_dir/results"/*.json; do
                if [ -f "$entry_file" ]; then
                    entry_workflow_id=$(grep -o '"workflow_id": "[^"]*"' "$entry_file" | cut -d'"' -f4)
                    if [ "$entry_workflow_id" = "$workflow_id" ]; then
                        entry_cache_key=$(grep -o '"cache_key": "[^"]*"' "$entry_file" | cut -d'"' -f4)
                        cache_size=$(grep -o '"data_size_bytes": [0-9]*' "$entry_file" | cut -d' ' -f2)
                        rm -f "$entry_file" "$cache_dir/results/${entry_cache_key}.data"
                        update_cache_index "$entry_cache_key" "$cache_size" "remove"
                        invalidated_count=$((invalidated_count + 1))
                    fi
                fi
            done
            echo "✅ Invalidated $invalidated_count cache entries for workflow: $workflow_id"
        else
            echo "❌ Invalid invalidation request - provide cache_key or workflow_id"
            exit 1
        fi
        ;;
        
    "clear")
        echo "🧹 Clearing cache..."
        
        # Remove all cache entries
        rm -f "$cache_dir/results"/*.json
        rm -f "$cache_dir/results"/*.data
        
        # Reset cache index
        cat > "$cache_index" << EOF
{
    "entries": {},
    "last_cleanup": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "total_size_bytes": 0,
    "hit_count": 0,
    "miss_count": 0
}
EOF
        
        echo "✅ Cache cleared successfully"
        ;;
        
    "status")
        echo "📊 Cache status report..."
        
        # Read cache statistics
        if [ -f "$cache_index" ]; then
            total_size=$(grep -o '"total_size_bytes": [0-9]*' "$cache_index" | cut -d' ' -f2)
            hit_count=$(grep -o '"hit_count": [0-9]*' "$cache_index" | cut -d' ' -f2)
            miss_count=$(grep -o '"miss_count": [0-9]*' "$cache_index" | cut -d' ' -f2)
            
            # Calculate hit rate
            total_requests=$((hit_count + miss_count))
            if [ $total_requests -gt 0 ]; then
                hit_rate=$(awk "BEGIN {printf \"%.2f\", ($hit_count / $total_requests) * 100}")
            else
                hit_rate="0.00"
            fi
            
            # Count cache entries
            entry_count=$(find "$cache_dir/results" -name "*.json" | wc -l)
            
            echo "📊 Cache Statistics:"
            echo "   - Total entries: $entry_count"
            echo "   - Total size: $(numfmt --to=iec $total_size)B"
            echo "   - Hit rate: ${hit_rate}%"
            echo "   - Hits: $hit_count"
            echo "   - Misses: $miss_count"
            
            # Show top workflows by cache usage
            echo "🔝 Top workflows by cache usage:"
            for entry_file in "$cache_dir/results"/*.json; do
                if [ -f "$entry_file" ]; then
                    workflow_id=$(grep -o '"workflow_id": "[^"]*"' "$entry_file" | cut -d'"' -f4)
                    data_size=$(grep -o '"data_size_bytes": [0-9]*' "$entry_file" | cut -d' ' -f2)
                    echo "   - $workflow_id: $(numfmt --to=iec $data_size)B"
                fi
            done | sort -k3 -nr | head -5
        else
            echo "❌ Cache index not found"
        fi
        ;;
        
    *)
        echo "❌ Unknown cache operation: $cache_operation"
        echo "Available operations: store, retrieve, invalidate, clear, status"
        exit 1
        ;;
esac
```

### 4. Cache Index Management
```bash
# Update cache index
update_cache_index() {
    local cache_key="$1"
    local size_bytes="$2"
    local operation="$3"  # add, remove, update
    
    if [ ! -f "$cache_index" ]; then
        return 1
    fi
    
    # Read current values
    current_size=$(grep -o '"total_size_bytes": [0-9]*' "$cache_index" | cut -d' ' -f2)
    
    case "$operation" in
        "add")
            new_size=$((current_size + size_bytes))
            # Add entry to index
            sed -i 's/"total_size_bytes": [0-9]*/"total_size_bytes": '$new_size'/' "$cache_index"
            ;;
        "remove")
            new_size=$((current_size - size_bytes))
            if [ $new_size -lt 0 ]; then new_size=0; fi
            sed -i 's/"total_size_bytes": [0-9]*/"total_size_bytes": '$new_size'/' "$cache_index"
            ;;
    esac
}

# Update cache statistics
update_cache_statistics() {
    local stat_type="$1"  # hit, miss
    
    if [ ! -f "$cache_index" ]; then
        return 1
    fi
    
    case "$stat_type" in
        "hit")
            hit_count=$(grep -o '"hit_count": [0-9]*' "$cache_index" | cut -d' ' -f2)
            new_hit_count=$((hit_count + 1))
            sed -i 's/"hit_count": [0-9]*/"hit_count": '$new_hit_count'/' "$cache_index"
            ;;
        "miss")
            miss_count=$(grep -o '"miss_count": [0-9]*' "$cache_index" | cut -d' ' -f2)
            new_miss_count=$((miss_count + 1))
            sed -i 's/"miss_count": [0-9]*/"miss_count": '$new_miss_count'/' "$cache_index"
            ;;
    esac
}
```

### 5. Cache Cleanup and Maintenance
```bash
# Automatic cache cleanup
cleanup_cache() {
    echo "🧹 Running cache cleanup..."
    
    cleaned_count=0
    freed_bytes=0
    
    # Remove expired entries
    for entry_file in "$cache_dir/results"/*.json; do
        if [ -f "$entry_file" ]; then
            expires_at=$(grep -o '"expires_at": "[^"]*"' "$entry_file" | cut -d'"' -f4)
            current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
            
            if [[ "$expires_at" < "$current_time" ]]; then
                cache_key=$(grep -o '"cache_key": "[^"]*"' "$entry_file" | cut -d'"' -f4)
                data_size=$(grep -o '"data_size_bytes": [0-9]*' "$entry_file" | cut -d' ' -f2)
                
                rm -f "$entry_file" "$cache_dir/results/${cache_key}.data"
                update_cache_index "$cache_key" "$data_size" "remove"
                
                cleaned_count=$((cleaned_count + 1))
                freed_bytes=$((freed_bytes + data_size))
            fi
        fi
    done
    
    # Check cache size limits
    max_size_mb=$(grep -o '"max_cache_size_mb": [0-9]*' "$cache_config" | cut -d' ' -f2)
    max_size_bytes=$((max_size_mb * 1024 * 1024))
    current_size=$(grep -o '"total_size_bytes": [0-9]*' "$cache_index" | cut -d' ' -f2)
    
    if [ "$current_size" -gt "$max_size_bytes" ]; then
        echo "⚠️  Cache size exceeds limit, removing oldest entries..."
        
        # Remove oldest entries until under limit
        while [ "$current_size" -gt "$max_size_bytes" ]; do
            oldest_file=$(ls -t "$cache_dir/results"/*.json | tail -1)
            if [ -f "$oldest_file" ]; then
                cache_key=$(grep -o '"cache_key": "[^"]*"' "$oldest_file" | cut -d'"' -f4)
                data_size=$(grep -o '"data_size_bytes": [0-9]*' "$oldest_file" | cut -d' ' -f2)
                
                rm -f "$oldest_file" "$cache_dir/results/${cache_key}.data"
                update_cache_index "$cache_key" "$data_size" "remove"
                
                current_size=$((current_size - data_size))
                cleaned_count=$((cleaned_count + 1))
                freed_bytes=$((freed_bytes + data_size))
            else
                break
            fi
        done
    fi
    
    # Update last cleanup time
    sed -i 's/"last_cleanup": "[^"]*"/"last_cleanup": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"/' "$cache_index"
    
    echo "✅ Cache cleanup completed:"
    echo "   - Entries removed: $cleaned_count"
    echo "   - Space freed: $(numfmt --to=iec $freed_bytes)B"
}

# Run cleanup if needed
last_cleanup=$(grep -o '"last_cleanup": "[^"]*"' "$cache_index" | cut -d'"' -f4)
cleanup_interval=$(grep -o '"cleanup_interval_hours": [0-9]*' "$cache_config" | cut -d' ' -f2)
current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Check if cleanup is needed (simplified time comparison)
if [ -z "$last_cleanup" ] || [ "$(date -d "$last_cleanup" +%s)" -lt "$(date -d "$current_time - ${cleanup_interval} hours" +%s)" ]; then
    cleanup_cache
fi
```

### 6. Cache Validation
```bash
# Validate cache integrity
validate_cache() {
    echo "🔍 Validating cache integrity..."
    
    validation_errors=()
    
    # Check cache directory structure
    if [ ! -d "$cache_dir/results" ]; then
        validation_errors+=("Missing cache results directory")
    fi
    
    # Validate cache entries
    for entry_file in "$cache_dir/results"/*.json; do
        if [ -f "$entry_file" ]; then
            cache_key=$(grep -o '"cache_key": "[^"]*"' "$entry_file" | cut -d'"' -f4 2>/dev/null)
            data_file="$cache_dir/results/${cache_key}.data"
            
            if [ ! -f "$data_file" ]; then
                validation_errors+=("Missing data file for cache key: $cache_key")
            fi
            
            # Validate JSON structure
            if ! python3 -m json.tool "$entry_file" >/dev/null 2>&1; then
                validation_errors+=("Invalid JSON in cache entry: $entry_file")
            fi
        fi
    done
    
    # Report validation results
    if [ ${#validation_errors[@]} -eq 0 ]; then
        echo "✅ Cache validation passed"
    else
        echo "❌ Cache validation failed:"
        for error in "${validation_errors[@]}"; do
            echo "   - $error"
        done
        exit 1
    fi
}

# Run validation if requested
if [ "$cache_operation" = "validate" ]; then
    validate_cache
fi
```

## Output
- Cache operation results (stored, retrieved, invalidated, cleared)
- Cache statistics and performance metrics
- Validation results and error reports
- Cleanup reports and space optimization results

## Error Handling
- Cache directory creation failures → Create with appropriate permissions
- Invalid cache keys → Generate new keys automatically
- Corrupted cache entries → Remove and log errors
- Disk space issues → Trigger aggressive cleanup
- Permission errors → Detailed error reporting

## Security Considerations
- Cache key generation uses secure hashing
- No sensitive data stored in cache metadata
- File permissions restricted to user only
- Cache invalidation on security-sensitive changes
- Regular cleanup prevents cache poisoning

## Dependencies
- File system with sufficient space
- JSON parsing capabilities
- Hash generation tools (sha256sum)
- Date/time utilities
- Disk space monitoring

## Success Criteria
- Cache operations complete successfully
- Performance improvements measurable
- Cache hit rates within acceptable ranges
- Storage limits respected
- Data integrity maintained