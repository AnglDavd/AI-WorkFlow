# Workflow Interdependency Analysis Map

## Overview
This document maps all workflow interdependencies discovered in the AI Development Framework. Each workflow that calls another `.md` file as if it were executable has been catalogued.

**Status**: ⚠️ CRITICAL ISSUE - 95+ interdependency violations found
**Impact**: Prevents proper workflow execution across the entire framework
**Priority**: HIGH - Framework cannot function properly without fixing this

## Types of Interdependency Violations

### 1. Direct Execution Calls (./.ai_workflow/workflows/...)
Workflows attempting to execute other `.md` files directly as bash scripts.

### 2. Source Command Calls (source .ai_workflow/...)
Workflows attempting to source other `.md` files as if they were bash scripts.

### 3. Bash Execution Calls (bash ./.ai_workflow/...)
Workflows attempting to run other `.md` files through bash command.

## Complete Interdependency Map

### Core Setup Workflows
#### setup/01_start_setup.md
- **Line 7**: `./.ai_workflow/workflows/common/log_work_journal.md` (EXECUTION)
- **Line 12**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)

#### setup/02_confirm_setup.md  
- **Line 31**: `./.ai_workflow/workflows/common/abort.md` (EXECUTION)

#### setup/03_create_structure.md
- **Line 42**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)
- **Line 50**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)

#### setup/04_init_git.md
- **Line 26**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)

### PRP Execution Workflows  
#### run/01_run_prp.md
- **Line 42**: `source .ai_workflow/workflows/common/manage_workflow_state.md` (SOURCE)
- **Line 53**: `source .ai_workflow/tools/execute_abstract_tool_call.md` (SOURCE)
- **Line 57**: `source .ai_workflow/tools/execute_abstract_tool_call.md` (SOURCE)
- **Line 61**: `source .ai_workflow/tools/execute_abstract_tool_call.md` (SOURCE)
- **Line 70**: `source .ai_workflow/tools/execute_abstract_tool_call.md` (SOURCE)
- **Line 74**: `source .ai_workflow/tools/execute_abstract_tool_call.md` (SOURCE)
- **Line 78**: `source .ai_workflow/tools/execute_abstract_tool_call.md` (SOURCE)
- **Line 86**: `source .ai_workflow/workflows/common/rollback_changes.md` (SOURCE)
- **Line 97**: `source .ai_workflow/tools/execute_abstract_tool_call.md` (SOURCE)
- **Line 103**: `source .ai_workflow/workflows/common/rollback_changes.md` (SOURCE)
- **Line 109**: `source .ai_workflow/workflows/common/rollback_changes.md` (SOURCE)
- **Line 123**: `source .ai_workflow/tools/execute_abstract_tool_call.md` (SOURCE)
- **Line 126**: `source .ai_workflow/tools/execute_abstract_tool_call.md` (SOURCE)
- **Line 129**: `source .ai_workflow/tools/execute_abstract_tool_call.md` (SOURCE)
- **Line 133**: `source .ai_workflow/workflows/common/validate_prp_execution.md` (SOURCE)

### Common Workflows
#### common/error.md
- **Line 13**: `./.ai_workflow/workflows/common/log_work_journal.md` (EXECUTION)

#### common/success.md  
- **Line 7**: `./.ai_workflow/workflows/common/log_work_journal.md` (EXECUTION)

#### common/rollback_changes.md
- **Line 68**: `source .ai_workflow/workflows/common/manage_workflow_state.md` (SOURCE)
- **Line 212**: `source .ai_workflow/workflows/common/manage_workflow_state.md` (SOURCE)

#### common/generate_status_html.md
- **Line 7**: `./.ai_workflow/workflows/common/log_work_journal.md` (EXECUTION)
- **Line 25**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)

#### common/attempt_auto_correction.md
- **Line 188**: `source .ai_workflow/workflows/common/rollback_changes.md` (SOURCE)
- **Line 691**: `source .ai_workflow/workflows/common/manage_workflow_state.md` (SOURCE)

#### common/analyze_error_context.md
- **Line 806**: `source .ai_workflow/workflows/common/manage_workflow_state.md` (SOURCE)
- **Line 824**: `source .ai_workflow/workflows/common/rollback_changes.md` (SOURCE)

#### common/manage_project_state.md
- **Line 68**: `source .ai_workflow/workflows/common/manage_project_state.md` (SOURCE - RECURSIVE!)

### Assistant Workflows
#### assistant/01_ask_assistant.md
- **Line 7**: `./.ai_workflow/workflows/common/log_work_journal.md` (EXECUTION)
- **Line 22**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)
- **Line 31**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)
- **Line 36**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)
- **Line 50**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)

### PRD Workflows
#### prd/01_create_prd.md
- **Line 7**: `./.ai_workflow/workflows/common/log_work_journal.md` (EXECUTION)
- **Line 15**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)
- **Line 22**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)
- **Line 31**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)
- **Line 51**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)

### Feedback Workflows
#### feedback/capture_feedback.md
- **Line 7**: `./.ai_workflow/workflows/common/log_work_journal.md` (EXECUTION)
- **Line 25**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)

#### feedback/process_feedback.md
- **Line 32**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)

#### feedback/refactor_workflow.md
- **Line 30**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)

### Tool Adapter Workflows
#### tools/adapters/npm_adapter.md
- **Line 32**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)

#### tools/adapters/git_adapter.md
- **Line 27**: `./.ai_workflow/workflows/common/error.md` (EXECUTION)

## Pattern Analysis

### Most Called Workflows
1. **common/error.md** - Called 18+ times across framework
2. **common/log_work_journal.md** - Called 8+ times across framework  
3. **common/manage_workflow_state.md** - Called 5+ times (all via source)
4. **common/rollback_changes.md** - Called 4+ times (all via source)
5. **tools/execute_abstract_tool_call.md** - Called 9+ times (all via source)

### Critical Dependencies
- **Error Handling**: Almost every workflow depends on `common/error.md`
- **Logging**: Most workflows depend on `common/log_work_journal.md`
- **State Management**: Core execution depends on `manage_workflow_state.md`
- **Tool Execution**: PRP execution heavily depends on `execute_abstract_tool_call.md`

## Root Cause Analysis

### Design Philosophy Conflict
The framework was designed with `.md` workflows containing executable bash blocks, but the calling mechanism treats `.md` files as executable bash scripts directly.

### Execution Patterns
1. **Direct Execution**: `./.ai_workflow/workflows/path/file.md`
2. **Source Pattern**: `source .ai_workflow/workflows/path/file.md` 
3. **Bash Execution**: `bash ./.ai_workflow/workflows/path/file.md`

All three patterns fail because:
- `.md` files contain markdown syntax, not pure bash
- The bash interpreter cannot parse markdown formatting
- Code blocks are wrapped in ```bash``` which is not valid bash syntax

## Impact Assessment

### Complete Framework Breakdown
- **Setup workflows**: Cannot initialize projects
- **Run workflows**: Cannot execute PRPs  
- **Error handling**: Cannot properly handle errors
- **Tool execution**: Cannot execute abstract tools
- **State management**: Cannot manage workflow state
- **Logging**: Cannot log workflow events

### Success Rate Analysis
- **Before MD Parser**: 0% success on workflows with interdependencies
- **After MD Parser**: Individual workflows work, but interdependencies still fail
- **Current Status**: Framework is 85% non-functional due to interdependencies

## Solution Requirements

### Design Principles to Maintain
1. **Zero Dependencies**: No external tools or languages
2. **Markdown Philosophy**: Keep workflows as readable `.md` files
3. **Transparency**: All logic visible in readable format
4. **Native Bash**: Pure bash implementation

### Solution Options
1. **Workflow Calling Function**: Extend `execute_md_workflow()` to support workflow calls
2. **Source Pattern Replacement**: Replace `source` with function calls
3. **Indirect Execution**: Create workflow calling mechanism
4. **Unified Parser**: Central workflow execution engine

## Recommended Solution Architecture

### Phase 1: Extend MD Parser
Enhance the existing `execute_md_workflow()` function to:
- Detect workflow calls within bash blocks
- Replace workflow calls with parser function calls  
- Maintain execution context between workflows
- Handle parameters and return values

### Phase 2: Create Workflow Calling Convention
- **Function Pattern**: `execute_workflow "path/to/workflow.md" "parameters"`
- **Error Handling**: `handle_workflow_error "error_message"`
- **Logging**: `log_workflow_event "event_message"`  
- **State Management**: `manage_workflow_state "action" "data"`

### Phase 3: Update All Workflow Files
Replace all direct `.md` execution calls with function calls:
- `./.ai_workflow/workflows/common/error.md "msg"` → `handle_workflow_error "msg"`
- `source .ai_workflow/workflows/common/manage_workflow_state.md` → `manage_workflow_state`

## Next Steps
1. Design the enhanced workflow calling mechanism
2. Implement workflow calling functions in `ai-dev`
3. Test the mechanism with core workflows
4. Systematically update all workflow files
5. Re-test the entire framework

---
**Priority**: CRITICAL - Framework functionality depends on resolving these interdependencies
**Estimated Effort**: 2-3 days of systematic refactoring
**Risk**: High - Changes affect core framework architecture