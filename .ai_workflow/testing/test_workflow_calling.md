# Test Workflow Calling Mechanism

## Test Simple Workflow Call

```bash
echo "Testing basic workflow calling mechanism..."
echo "This should work without any workflow calls first"
```

## Test Error Workflow Call

```bash
echo "Testing error handling workflow call..."
handle_workflow_error "This is a test error message"
```

## Test Logging Workflow Call

```bash
echo "Testing logging workflow call..."
log_workflow_event "INFO" "This is a test log message"
```

## Test Direct Workflow Call

```bash
echo "Testing direct workflow call..."
call_workflow "common/success.md" "Test workflow calling successful"
```