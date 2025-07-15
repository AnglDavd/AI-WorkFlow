# Workflow Calling Mechanism Design

## Overview
Design for extending the existing MD parser to handle workflow interdependencies while maintaining the zero-dependency philosophy and markdown-based approach.

## Current Problem
- 95+ workflows attempt to execute `.md` files as bash scripts
- Framework designed for readable `.md` workflows but uses bash execution patterns
- Core functions like error handling, logging, and state management are broken

## Design Principles
1. **Zero Dependencies**: Pure bash implementation, no external tools
2. **Backward Compatibility**: Existing workflows should work with minimal changes
3. **Markdown Philosophy**: Keep workflows as readable `.md` files  
4. **Native Execution**: Extend existing `execute_md_workflow()` function
5. **Parameter Support**: Enable parameter passing between workflows

## Solution Architecture

### Phase 1: Enhanced MD Parser with Workflow Recognition

#### 1.1 Extend `execute_md_workflow()` Function
```bash
execute_md_workflow() {
    local workflow_file="$1"
    local temp_script="/tmp/ai_workflow_$$.sh"
    local in_bash_block=false
    local bash_content=""
    local line_num=0
    local blocks_executed=0
    
    # NEW: Process each line for workflow calls
    while IFS= read -r line; do
        line_num=$((line_num + 1))
        
        # Detect start of bash code block
        if [[ "$line" =~ ^```bash$ ]]; then
            in_bash_block=true
            bash_content=""
            continue
        fi
        
        # Detect end of code block
        if [[ "$line" =~ ^```$ ]] && [ "$in_bash_block" = true ]; then
            in_bash_block=false
            blocks_executed=$((blocks_executed + 1))
            
            # NEW: Process bash content for workflow calls
            bash_content=$(process_workflow_calls "$bash_content")
            
            # Execute processed bash code
            echo "#!/bin/bash" > "$temp_script"
            echo "set -euo pipefail" >> "$temp_script"
            printf "%s" "$bash_content" >> "$temp_script"
            chmod +x "$temp_script"
            
            "$temp_script" || return 1
            rm -f "$temp_script"
            continue
        fi
        
        # Collect bash code lines
        if [ "$in_bash_block" = true ]; then
            bash_content="${bash_content}${line}\n"
        fi
        
    done < "$workflow_file"
    
    return 0
}
```

#### 1.2 Workflow Call Processing Function
```bash
process_workflow_calls() {
    local bash_content="$1"
    local processed_content="$bash_content"
    
    # Replace direct workflow execution calls
    processed_content=$(echo "$processed_content" | sed -E 's|\./\.ai_workflow/workflows/([^/]+)/([^/]+)\.md|call_workflow "\1/\2.md"|g')
    
    # Replace source workflow calls  
    processed_content=$(echo "$processed_content" | sed -E 's|source \.ai_workflow/workflows/([^/]+)/([^/]+)\.md|call_workflow "\1/\2.md"|g')
    
    # Replace bash workflow calls
    processed_content=$(echo "$processed_content" | sed -E 's|bash \.ai_workflow/workflows/([^/]+)/([^/]+)\.md|call_workflow "\1/\2.md"|g')
    
    echo "$processed_content"
}
```

### Phase 2: Core Workflow Functions

#### 2.1 Universal Workflow Calling Function
```bash
call_workflow() {
    local workflow_path="$1"
    shift
    local workflow_args="$*"
    
    # Resolve full path
    local full_path="${AI_WORKFLOW_DIR}/workflows/${workflow_path}"
    
    if [ ! -f "$full_path" ]; then
        error "Workflow not found: $workflow_path"
        return 1
    fi
    
    # Export arguments for the called workflow
    export WORKFLOW_ARGS="$workflow_args"
    
    # Execute the workflow using our MD parser
    execute_md_workflow "$full_path"
}
```

#### 2.2 Common Workflow Function Shortcuts
```bash
# Error handling function
handle_workflow_error() {
    local error_message="$1"
    export WORKFLOW_ARGS="$error_message"
    call_workflow "common/error.md" "$error_message"
}

# Logging function
log_workflow_event() {
    local log_level="$1"
    local log_message="$2"
    export WORKFLOW_ARGS="$log_level $log_message"
    call_workflow "common/log_work_journal.md" "$log_level" "$log_message"
}

# State management function
manage_workflow_state() {
    local action="$1"
    local state_data="$2"
    export WORKFLOW_ARGS="$action $state_data"
    call_workflow "common/manage_workflow_state.md" "$action" "$state_data"
}

# Success handling
handle_workflow_success() {
    local success_message="${1:-Workflow completed successfully}"
    export WORKFLOW_ARGS="$success_message"
    call_workflow "common/success.md" "$success_message"
}
```

### Phase 3: Workflow File Updates

#### 3.1 High-Priority Replacements
Replace the most common patterns first:

**Error Handling Pattern**:
```bash
# OLD
./.ai_workflow/workflows/common/error.md "Error message"

# NEW  
handle_workflow_error "Error message"
```

**Logging Pattern**:
```bash
# OLD
./.ai_workflow/workflows/common/log_work_journal.md "INFO" "Message"

# NEW
log_workflow_event "INFO" "Message"
```

**Source Pattern**:
```bash
# OLD
source .ai_workflow/workflows/common/manage_workflow_state.md

# NEW
manage_workflow_state
```

#### 3.2 Parameter Handling in Called Workflows
Called workflows can access parameters via:
```bash
# In the called workflow's bash block
if [ -n "${WORKFLOW_ARGS:-}" ]; then
    set -- $WORKFLOW_ARGS
    ARG1="$1"
    ARG2="$2"
    # ... use arguments
fi
```

### Phase 4: Implementation Strategy

#### 4.1 Implementation Order
1. **Core Functions**: Add workflow calling functions to `ai-dev`
2. **Critical Workflows**: Update `common/error.md` and `common/log_work_journal.md`
3. **Setup Workflows**: Fix `setup/01_start_setup.md` interdependencies
4. **Test & Iterate**: Test each change before proceeding
5. **Systematic Update**: Update remaining workflows in dependency order

#### 4.2 Testing Approach
```bash
# Test individual workflow calls
call_workflow "common/error.md" "Test error message"

# Test function shortcuts
handle_workflow_error "Test error"
log_workflow_event "INFO" "Test log"

# Test complex workflows
./ai-dev setup
```

## Migration Strategy

### Immediate (Phase 1): Core Function Implementation
- Add workflow calling functions to `ai-dev`
- Test basic workflow calling mechanism
- Ensure backward compatibility

### Week 1 (Phase 2): Critical Dependencies  
- Update `common/error.md`, `common/log_work_journal.md`
- Update `setup/01_start_setup.md`
- Test setup workflow end-to-end

### Week 2 (Phase 3): Systematic Migration
- Update all `common/` workflows
- Update `run/01_run_prp.md` (most complex)
- Update tool adapters

### Week 3 (Phase 4): Complete Framework
- Update remaining workflow categories
- Full framework testing
- Performance optimization

## Risk Mitigation

### Backward Compatibility
- Keep existing MD parser functionality intact
- Add new functionality as extensions
- Test each change individually

### Error Recovery
- If workflow call fails, fall back to error handling
- Maintain error context across workflow calls
- Implement rollback capabilities

### Performance Considerations
- Minimize recursive workflow calls
- Cache workflow parsing where possible
- Monitor execution depth

## Success Metrics

### Phase 1 Success Criteria
- Basic workflow calling mechanism works
- Can call `common/error.md` successfully
- No regression in existing functionality

### Final Success Criteria
- All 95+ interdependency violations resolved
- Complete framework functionality restored
- `./ai-dev setup` works end-to-end
- All commands execute successfully

## Implementation Complexity

### Low Risk Changes
- Adding new functions to `ai-dev`
- Updating simple workflow calls
- Testing individual components

### Medium Risk Changes  
- Modifying `execute_md_workflow()` function
- Parameter passing mechanism
- Complex workflow updates

### High Risk Changes
- `run/01_run_prp.md` with 15 interdependencies
- Recursive workflow calls
- State management workflows

## Next Steps
1. **Implement Core Functions**: Add workflow calling functions to `ai-dev`
2. **Create Test Workflow**: Simple test to validate mechanism
3. **Update Critical Path**: Fix `setup/01_start_setup.md` first
4. **Iterative Testing**: Test each change before proceeding
5. **Systematic Migration**: Update workflows in dependency order

---
**Estimated Timeline**: 3-4 days for complete implementation
**Risk Level**: Medium - Well-defined solution with clear implementation path
**Impact**: HIGH - Will restore 85% of framework functionality