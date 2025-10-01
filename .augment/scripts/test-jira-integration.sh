#!/bin/bash

# JIRA Integration Test Script for AIDemoTest Project
# This script tests the complete JIRA integration workflow

set -e

# Configuration
JIRA_PROJECT="ALAMEDA"
TEST_TICKET_PREFIX="TEST"
BRANCH_PREFIX="test-integration"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test results
print_test_result() {
    local test_name="$1"
    local result="$2"
    local message="$3"
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓ PASS${NC} - $test_name"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC} - $test_name: $message"
        ((TESTS_FAILED++))
    fi
}

# Function to test JIRA API connection
test_jira_connection() {
    echo -e "${BLUE}Testing JIRA API connection...${NC}"
    
    if [ -z "$JIRA_API_TOKEN" ]; then
        print_test_result "JIRA API Token" "FAIL" "JIRA_API_TOKEN not set"
        return 1
    fi
    
    local response=$(curl -s -u "${JIRA_USERNAME}:${JIRA_API_TOKEN}" \
                          "${JIRA_BASE_URL}/rest/api/3/myself")
    
    if echo "$response" | grep -q "accountId"; then
        print_test_result "JIRA API Connection" "PASS"
        local display_name=$(echo "$response" | jq -r '.displayName')
        echo "  Connected as: $display_name"
    else
        print_test_result "JIRA API Connection" "FAIL" "Authentication failed"
        return 1
    fi
}

# Function to test project access
test_project_access() {
    echo -e "${BLUE}Testing JIRA project access...${NC}"
    
    local response=$(curl -s -u "${JIRA_USERNAME}:${JIRA_API_TOKEN}" \
                          "${JIRA_BASE_URL}/rest/api/3/project/${JIRA_PROJECT}")
    
    if echo "$response" | grep -q "\"key\":\"${JIRA_PROJECT}\""; then
        print_test_result "Project Access" "PASS"
        local project_name=$(echo "$response" | jq -r '.name')
        echo "  Project: $project_name"
    else
        print_test_result "Project Access" "FAIL" "Cannot access project $JIRA_PROJECT"
        return 1
    fi
}

# Function to test issue creation
test_issue_creation() {
    echo -e "${BLUE}Testing issue creation...${NC}"
    
    local timestamp=$(date +%s)
    local summary="Test Story - Integration Test $timestamp"
    
    local issue_data="{
        \"fields\": {
            \"project\": {\"key\": \"${JIRA_PROJECT}\"},
            \"summary\": \"$summary\",
            \"description\": {
                \"type\": \"doc\",
                \"version\": 1,
                \"content\": [{
                    \"type\": \"paragraph\",
                    \"content\": [{
                        \"type\": \"text\",
                        \"text\": \"This is a test story created by the integration test script.\"
                    }]
                }]
            },
            \"issuetype\": {\"name\": \"Story\"},
            \"priority\": {\"name\": \"Low\"}
        }
    }"
    
    local response=$(curl -s -u "${JIRA_USERNAME}:${JIRA_API_TOKEN}" \
                          -X POST \
                          -H "Content-Type: application/json" \
                          -d "$issue_data" \
                          "${JIRA_BASE_URL}/rest/api/3/issue")
    
    local ticket_key=$(echo "$response" | jq -r '.key')
    
    if [ "$ticket_key" != "null" ] && [ -n "$ticket_key" ]; then
        print_test_result "Issue Creation" "PASS"
        echo "  Created ticket: $ticket_key"
        echo "$ticket_key" > /tmp/test_ticket_key
    else
        print_test_result "Issue Creation" "FAIL" "Failed to create issue"
        echo "Response: $response"
        return 1
    fi
}

# Function to test branch naming validation
test_branch_naming() {
    echo -e "${BLUE}Testing branch naming validation...${NC}"
    
    # Test valid branch name
    local valid_branch="feature/ALAMEDA-123-test-feature"
    if [[ "$valid_branch" =~ ^(feature|bugfix|hotfix)/ALAMEDA-[0-9]+-.*$ ]]; then
        print_test_result "Valid Branch Name" "PASS"
    else
        print_test_result "Valid Branch Name" "FAIL" "Regex validation failed"
    fi
    
    # Test invalid branch name
    local invalid_branch="feature/invalid-branch-name"
    if [[ ! "$invalid_branch" =~ ^(feature|bugfix|hotfix)/ALAMEDA-[0-9]+-.*$ ]]; then
        print_test_result "Invalid Branch Name Detection" "PASS"
    else
        print_test_result "Invalid Branch Name Detection" "FAIL" "Should have failed validation"
    fi
}

# Function to test commit message validation
test_commit_message_validation() {
    echo -e "${BLUE}Testing commit message validation...${NC}"
    
    # Test valid commit message
    local valid_commit="feat(apex): add user authentication service

Refs: ALAMEDA-123"
    
    if echo "$valid_commit" | grep -q "Refs: ALAMEDA-[0-9]\+"; then
        print_test_result "Valid Commit Message" "PASS"
    else
        print_test_result "Valid Commit Message" "FAIL" "JIRA reference not found"
    fi
    
    # Test invalid commit message
    local invalid_commit="add some code"
    
    if ! echo "$invalid_commit" | grep -q "Refs: ALAMEDA-[0-9]\+"; then
        print_test_result "Invalid Commit Message Detection" "PASS"
    else
        print_test_result "Invalid Commit Message Detection" "FAIL" "Should have failed validation"
    fi
}

# Function to test Git integration
test_git_integration() {
    echo -e "${BLUE}Testing Git integration...${NC}"
    
    # Check if we're in a git repository
    if git rev-parse --git-dir > /dev/null 2>&1; then
        print_test_result "Git Repository" "PASS"
    else
        print_test_result "Git Repository" "FAIL" "Not in a git repository"
        return 1
    fi
    
    # Test git hooks existence
    if [ -f ".husky/pre-commit" ]; then
        print_test_result "Pre-commit Hook" "PASS"
    else
        print_test_result "Pre-commit Hook" "FAIL" "Pre-commit hook not found"
    fi
}

# Function to test configuration files
test_configuration_files() {
    echo -e "${BLUE}Testing configuration files...${NC}"
    
    local config_files=(
        ".augment/jira-config.json"
        ".augment/jira-automation.json"
        ".augment/feature-tracking.json"
        ".augment/jira-cli-config.json"
        ".augment/git-config.json"
    )
    
    for config_file in "${config_files[@]}"; do
        if [ -f "$config_file" ]; then
            if jq empty "$config_file" 2>/dev/null; then
                print_test_result "Config File: $(basename $config_file)" "PASS"
            else
                print_test_result "Config File: $(basename $config_file)" "FAIL" "Invalid JSON"
            fi
        else
            print_test_result "Config File: $(basename $config_file)" "FAIL" "File not found"
        fi
    done
}

# Function to test Salesforce CLI
test_salesforce_cli() {
    echo -e "${BLUE}Testing Salesforce CLI...${NC}"
    
    if command -v sf &> /dev/null; then
        print_test_result "Salesforce CLI" "PASS"
        local sf_version=$(sf --version | head -n1)
        echo "  Version: $sf_version"
    else
        print_test_result "Salesforce CLI" "FAIL" "sf command not found"
    fi
}

# Function to test Node.js dependencies
test_node_dependencies() {
    echo -e "${BLUE}Testing Node.js dependencies...${NC}"
    
    if [ -f "package.json" ]; then
        print_test_result "Package.json" "PASS"
        
        # Check if node_modules exists
        if [ -d "node_modules" ]; then
            print_test_result "Node Modules" "PASS"
        else
            print_test_result "Node Modules" "FAIL" "Run 'npm install'"
        fi
    else
        print_test_result "Package.json" "FAIL" "File not found"
    fi
}

# Function to cleanup test data
cleanup_test_data() {
    echo -e "${BLUE}Cleaning up test data...${NC}"
    
    if [ -f "/tmp/test_ticket_key" ]; then
        local ticket_key=$(cat /tmp/test_ticket_key)
        echo "Test ticket created: $ticket_key"
        echo "Please manually delete this ticket from JIRA if needed"
        rm -f /tmp/test_ticket_key
    fi
}

# Function to print summary
print_summary() {
    echo ""
    echo -e "${BLUE}=== Test Summary ===${NC}"
    echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
    echo -e "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}All tests passed! JIRA integration is ready.${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed. Please review the configuration.${NC}"
        return 1
    fi
}

# Main test execution
main() {
    echo -e "${BLUE}=== JIRA Integration Test Suite ===${NC}"
    echo "Testing JIRA integration for AIDemoTest project"
    echo ""
    
    # Run all tests
    test_configuration_files
    test_jira_connection
    test_project_access
    test_issue_creation
    test_branch_naming
    test_commit_message_validation
    test_git_integration
    test_salesforce_cli
    test_node_dependencies
    
    # Cleanup and summary
    cleanup_test_data
    print_summary
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
