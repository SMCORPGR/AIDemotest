#!/bin/bash

# JIRA Setup Script for AIDemoTest Project
# This script helps you set up JIRA integration step by step

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== JIRA Integration Setup for AIDemoTest ===${NC}"
echo ""

# Function to prompt for input
prompt_input() {
    local prompt="$1"
    local var_name="$2"
    local default_value="$3"
    local is_secret="$4"
    
    if [ -n "$default_value" ]; then
        echo -n "$prompt [$default_value]: "
    else
        echo -n "$prompt: "
    fi
    
    if [ "$is_secret" = "true" ]; then
        read -s input
        echo ""
    else
        read input
    fi
    
    if [ -z "$input" ] && [ -n "$default_value" ]; then
        input="$default_value"
    fi
    
    eval "$var_name='$input'"
}

# Step 1: Collect JIRA configuration
echo -e "${YELLOW}Step 1: JIRA Configuration${NC}"
echo "Please provide your JIRA instance details:"
echo ""

prompt_input "JIRA Base URL (e.g., https://yourcompany.atlassian.net)" "jira_url"
prompt_input "JIRA Username (your email)" "jira_username"
echo ""
echo -e "${YELLOW}To get your API token:${NC}"
echo "1. Go to https://id.atlassian.com/manage-profile/security/api-tokens"
echo "2. Click 'Create API token'"
echo "3. Give it a name like 'AIDemoTest Integration'"
echo "4. Copy the generated token"
echo ""
prompt_input "JIRA API Token" "jira_token" "" "true"

# Step 2: Test connection
echo ""
echo -e "${YELLOW}Step 2: Testing JIRA connection...${NC}"

# Test the connection
response=$(curl -s -u "${jira_username}:${jira_token}" "${jira_url}/rest/api/3/myself" 2>/dev/null || echo "error")

if echo "$response" | grep -q "accountId"; then
    echo -e "${GREEN}✓ JIRA connection successful!${NC}"
    display_name=$(echo "$response" | jq -r '.displayName' 2>/dev/null || echo "Unknown")
    echo "Connected as: $display_name"
else
    echo -e "${RED}✗ JIRA connection failed${NC}"
    echo "Please check your credentials and try again."
    exit 1
fi

# Step 3: Check/Create ALAMEDA project
echo ""
echo -e "${YELLOW}Step 3: Checking ALAMEDA project...${NC}"

project_response=$(curl -s -u "${jira_username}:${jira_token}" "${jira_url}/rest/api/3/project/ALAMEDA" 2>/dev/null || echo "error")

if echo "$project_response" | grep -q "\"key\":\"ALAMEDA\""; then
    echo -e "${GREEN}✓ ALAMEDA project found${NC}"
    project_name=$(echo "$project_response" | jq -r '.name' 2>/dev/null || echo "ALAMEDA")
    echo "Project: $project_name"
else
    echo -e "${YELLOW}! ALAMEDA project not found${NC}"
    echo "You need to create a project with key 'ALAMEDA' in JIRA first."
    echo "Go to your JIRA instance and create a new Software project with key 'ALAMEDA'"
    echo ""
    echo "After creating the project, run this script again."
    exit 1
fi

# Step 4: Create environment file
echo ""
echo -e "${YELLOW}Step 4: Creating environment configuration...${NC}"

cat > .env << EOF
# JIRA Configuration for AIDemoTest Project
JIRA_BASE_URL=${jira_url}
JIRA_USERNAME=${jira_username}
JIRA_API_TOKEN=${jira_token}

# GitHub Integration (optional)
GITHUB_WEBHOOK_SECRET=

# Salesforce Integration (optional)
SALESFORCE_WEBHOOK_SECRET=
EOF

echo -e "${GREEN}✓ Created .env file${NC}"

# Step 5: Create a test ticket
echo ""
echo -e "${YELLOW}Step 5: Creating a test ticket...${NC}"

test_ticket_data='{
    "fields": {
        "project": {"key": "ALAMEDA"},
        "summary": "Test Story - JIRA Integration Setup",
        "description": {
            "type": "doc",
            "version": 1,
            "content": [{
                "type": "paragraph",
                "content": [{
                    "type": "text",
                    "text": "This is a test story created during JIRA integration setup. You can use this ticket to test the Git-JIRA integration workflow."
                }]
            }]
        },
        "issuetype": {"name": "Story"},
        "priority": {"name": "Low"}
    }
}'

ticket_response=$(curl -s -u "${jira_username}:${jira_token}" \
                       -X POST \
                       -H "Content-Type: application/json" \
                       -d "$test_ticket_data" \
                       "${jira_url}/rest/api/3/issue" 2>/dev/null || echo "error")

ticket_key=$(echo "$ticket_response" | jq -r '.key' 2>/dev/null || echo "null")

if [ "$ticket_key" != "null" ] && [ -n "$ticket_key" ]; then
    echo -e "${GREEN}✓ Created test ticket: ${ticket_key}${NC}"
    echo "URL: ${jira_url}/browse/${ticket_key}"
    echo ""
    echo "You can now test the integration with:"
    echo -e "${BLUE}source .augment/scripts/jira-utils.sh${NC}"
    echo -e "${BLUE}create_feature_branch ${ticket_key} 'test-integration'${NC}"
else
    echo -e "${YELLOW}! Could not create test ticket${NC}"
    echo "You can manually create a ticket in JIRA and use its key for testing."
fi

# Step 6: Final instructions
echo ""
echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo ""
echo "Next steps:"
echo "1. Load the JIRA utilities:"
echo -e "   ${BLUE}source .augment/scripts/jira-utils.sh${NC}"
echo ""
echo "2. Test the integration:"
if [ "$ticket_key" != "null" ] && [ -n "$ticket_key" ]; then
    echo -e "   ${BLUE}create_feature_branch ${ticket_key} 'test-integration'${NC}"
else
    echo -e "   ${BLUE}create_feature_branch ALAMEDA-XXX 'test-integration'${NC}"
    echo "   (Replace XXX with an actual ticket number)"
fi
echo ""
echo "3. Try other commands:"
echo -e "   ${BLUE}list_my_tickets${NC}"
echo -e "   ${BLUE}get_ticket_info ${ticket_key:-ALAMEDA-XXX}${NC}"
echo -e "   ${BLUE}jira_help${NC}"
echo ""
echo "4. Review the documentation:"
echo -e "   ${BLUE}cat .augment/JIRA_QUICK_REFERENCE.md${NC}"
echo ""
echo -e "${YELLOW}Note: The .env file contains sensitive information. Make sure it's in your .gitignore${NC}"
