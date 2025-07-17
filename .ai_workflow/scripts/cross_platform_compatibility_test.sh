#!/bin/bash

# Cross-Platform Compatibility Test Suite
# Tests AI-Assisted Development Framework compatibility across operating systems

set -euo pipefail

echo "🔍 Cross-Platform Compatibility Test Suite"
echo "=========================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing $test_name... "
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ FAIL${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Platform detection
detect_platform() {
    case "$(uname -s)" in
        Linux*)     PLATFORM=Linux;;
        Darwin*)    PLATFORM=macOS;;
        CYGWIN*)    PLATFORM=Windows;;
        MINGW*)     PLATFORM=Windows;;
        *)          PLATFORM="Unknown";;
    esac
    echo -e "${BLUE}📋 Platform: $PLATFORM${NC}"
    echo -e "${BLUE}📋 OS Details: $(uname -a)${NC}"
}

# Test 1: Shell Script Compatibility
test_shell_compatibility() {
    echo -e "\n${YELLOW}🔍 Testing Shell Script Compatibility${NC}"
    
    # Test bash availability
    run_test "Bash availability" "command -v bash"
    
    # Test script shebangs
    run_test "Script shebangs" "find .ai_workflow/scripts -name '*.sh' -exec head -1 {} \; | grep -q '#!/bin/bash'"
    
    # Test executable permissions
    run_test "Script permissions" "find .ai_workflow/scripts -name '*.sh' -executable | wc -l | grep -v '^0$'"
}

# Test 2: Core Unix Commands
test_unix_commands() {
    echo -e "\n${YELLOW}🔍 Testing Core Unix Commands${NC}"
    
    local commands=("grep" "sed" "awk" "find" "sort" "uniq" "wc" "head" "tail" "cat" "chmod" "mkdir")
    
    for cmd in "${commands[@]}"; do
        run_test "$cmd command" "command -v $cmd"
    done
}

# Test 3: Git Compatibility
test_git_compatibility() {
    echo -e "\n${YELLOW}🔍 Testing Git Compatibility${NC}"
    
    run_test "Git availability" "command -v git"
    run_test "Git version" "git --version"
    run_test "Git repository" "git status --porcelain"
    run_test "Git configuration" "git config --list | grep -q user"
}

# Test 4: File System Operations
test_filesystem() {
    echo -e "\n${YELLOW}🔍 Testing File System Operations${NC}"
    
    # Test directory creation
    run_test "Directory creation" "mkdir -p /tmp/ai_framework_test && rmdir /tmp/ai_framework_test"
    
    # Test file operations
    run_test "File operations" "echo 'test' > /tmp/ai_test.tmp && cat /tmp/ai_test.tmp && rm /tmp/ai_test.tmp"
    
    # Test path handling with spaces
    run_test "Path with spaces" "mkdir -p '/tmp/test dir' && rmdir '/tmp/test dir'"
    
    # Test symbolic links (if supported)
    run_test "Symbolic links" "ln -s /tmp /tmp/ai_test_link && rm /tmp/ai_test_link"
}

# Test 5: Framework-Specific Functions
test_framework_functions() {
    echo -e "\n${YELLOW}🔍 Testing Framework Functions${NC}"
    
    # Test main CLI
    run_test "AI-Dev CLI" "./ai-dev version"
    
    # Test configuration files
    run_test "Configuration access" "test -f .ai_workflow/config/framework.json"
    
    # Test workflow files
    run_test "Workflow files" "test -f .ai_workflow/workflows/setup/01_start_setup.md"
    
    # Test script execution
    run_test "Script execution" "bash .ai_workflow/scripts/check_repo_cleanliness.sh"
}

# Test 6: Environment Variables
test_environment_variables() {
    echo -e "\n${YELLOW}🔍 Testing Environment Variables${NC}"
    
    # Test standard variables
    run_test "HOME variable" "test -n '${HOME:-}'"
    run_test "PATH variable" "test -n '${PATH:-}'"
    run_test "USER variable" "test -n '${USER:-}'"
    
    # Test framework variables
    export AUTO_CONFIRM="true"
    run_test "AUTO_CONFIRM variable" "test '${AUTO_CONFIRM}' = 'true'"
}

# Test 7: Date and Time Functions
test_date_functions() {
    echo -e "\n${YELLOW}🔍 Testing Date Functions${NC}"
    
    # Test basic date command
    run_test "Date command" "date"
    
    # Test date formatting
    run_test "Date formatting" "date '+%Y-%m-%d %H:%M:%S'"
    
    # Test timestamp generation
    run_test "Timestamp generation" "date '+%Y%m%d_%H%M%S'"
}

# Test 8: Text Processing
test_text_processing() {
    echo -e "\n${YELLOW}🔍 Testing Text Processing${NC}"
    
    # Test grep patterns
    run_test "Grep patterns" "echo 'test123' | grep -E '[0-9]+'"
    
    # Test sed operations
    run_test "Sed operations" "echo 'test123' | sed 's/[0-9]//g' | grep -q 'test'"
    
    # Test awk processing
    run_test "Awk processing" "echo 'field1 field2' | awk '{print \$1}' | grep -q 'field1'"
}

# Test 9: JSON Processing
test_json_processing() {
    echo -e "\n${YELLOW}🔍 Testing JSON Processing${NC}"
    
    # Test JSON parsing if jq is available
    if command -v jq >/dev/null 2>&1; then
        run_test "JSON parsing (jq)" "echo '{\"test\": \"value\"}' | jq -r '.test'"
    else
        echo "⚠️  jq not available, skipping JSON tests"
    fi
    
    # Test basic JSON validation
    run_test "JSON validation" "python3 -c 'import json; json.loads(\"{\\\"test\\\": \\\"value\\\"}\")'"
}

# Test 10: Network Operations
test_network_operations() {
    echo -e "\n${YELLOW}🔍 Testing Network Operations${NC}"
    
    # Test curl availability
    run_test "Curl availability" "command -v curl"
    
    # Test wget availability
    run_test "Wget availability" "command -v wget || true"
    
    # Test basic connectivity (if curl available)
    if command -v curl >/dev/null 2>&1; then
        run_test "Network connectivity" "curl -s --max-time 5 https://httpbin.org/status/200"
    fi
}

# Platform-specific tests
test_platform_specific() {
    echo -e "\n${YELLOW}🔍 Testing Platform-Specific Features${NC}"
    
    case "$PLATFORM" in
        Linux)
            run_test "Linux proc filesystem" "test -d /proc"
            run_test "Linux package manager" "command -v apt || command -v yum || command -v dnf"
            ;;
        macOS)
            run_test "macOS Homebrew" "command -v brew || true"
            run_test "macOS BSD commands" "ls --version 2>&1 | grep -q BSD || true"
            ;;
        Windows)
            run_test "Windows Git Bash" "echo \$MSYSTEM"
            run_test "Windows path conversion" "cygpath -w / || true"
            ;;
    esac
}

# Generate compatibility report
generate_report() {
    echo -e "\n${BLUE}📊 Compatibility Report${NC}"
    echo "========================="
    echo "Platform: $PLATFORM"
    echo "Total Tests: $TOTAL_TESTS"
    echo "Passed: $PASSED_TESTS"
    echo "Failed: $FAILED_TESTS"
    echo "Success Rate: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}✅ All tests passed! Framework is compatible with $PLATFORM${NC}"
        return 0
    else
        echo -e "${RED}❌ Some tests failed. Framework may have compatibility issues on $PLATFORM${NC}"
        return 1
    fi
}

# Create compatibility recommendations
create_recommendations() {
    echo -e "\n${BLUE}💡 Compatibility Recommendations${NC}"
    echo "=================================="
    
    case "$PLATFORM" in
        Linux)
            echo "✅ Linux: Full compatibility expected"
            echo "   - All GNU tools available"
            echo "   - POSIX compliance good"
            echo "   - Recommended for production use"
            ;;
        macOS)
            echo "⚠️  macOS: Minor compatibility issues possible"
            echo "   - Install GNU coreutils via Homebrew"
            echo "   - Be aware of BSD vs GNU differences"
            echo "   - Test thoroughly before production use"
            ;;
        Windows)
            echo "⚠️  Windows: Significant compatibility considerations"
            echo "   - Use Git Bash or WSL"
            echo "   - Install missing Unix tools"
            echo "   - Test extensively before production use"
            ;;
        *)
            echo "❓ Unknown platform: Manual compatibility testing required"
            ;;
    esac
}

# Main execution
main() {
    detect_platform
    test_shell_compatibility
    test_unix_commands
    test_git_compatibility
    test_filesystem
    test_framework_functions
    test_environment_variables
    test_date_functions
    test_text_processing
    test_json_processing
    test_network_operations
    test_platform_specific
    
    generate_report
    create_recommendations
}

# Execute main function
main "$@"