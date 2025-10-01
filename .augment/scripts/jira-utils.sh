#!/bin/bash

# JIRA Utility Scripts for AIDemoTest Project
# Usage: source .augment/scripts/jira-utils.sh

# Configuration
JIRA_PROJECT="AITEST"
JIRA_BASE_URL="${JIRA_BASE_URL:-https://your-domain.atlassian.net}"
JIRA_USERNAME="${JIRA_USERNAME:-your-email@company.com}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if JIRA API token is set
check_jira_auth() {
    if [ -z "$JIRA_API_TOKEN" ]; then
        echo -e "${RED}Error: JIRA_API_TOKEN environment variable not set${NC}"
        echo "Please set your JIRA API token:"
        echo "export JIRA_API_TOKEN='your-api-token'"
        return 1
    fi
    return 0
}

# Function to make JIRA API calls
jira_api() {
    local endpoint="$1"
    local method="${2:-GET}"
    local data="$3"
    
    if ! check_jira_auth; then
        return 1
    fi
    
    local url="${JIRA_BASE_URL}/rest/api/3${endpoint}"
    
    if [ "$method" = "GET" ]; then
        curl -s -u "${JIRA_USERNAME}:${JIRA_API_TOKEN}" \
             -H "Accept: application/json" \
             "$url"
    else
        curl -s -u "${JIRA_USERNAME}:${JIRA_API_TOKEN}" \
             -X "$method" \
             -H "Accept: application/json" \
             -H "Content-Type: application/json" \
             -d "$data" \
             "$url"
    fi
}

# Function to create a new branch and link to JIRA ticket
create_feature_branch() {
    local ticket_key="$1"
    local description="$2"
    
    if [ -z "$ticket_key" ] || [ -z "$description" ]; then
        echo -e "${RED}Usage: create_feature_branch ALAMEDA-123 'short-description'${NC}"
        return 1
    fi
    
    # Validate ticket exists
    local ticket_info=$(jira_api "/issue/${ticket_key}")
    if echo "$ticket_info" | grep -q "errorMessages"; then
        echo -e "${RED}Error: Ticket ${ticket_key} not found${NC}"
        return 1
    fi
    
    # Create branch name
    local branch_name="feature/${ticket_key}-${description}"
    
    # Create and checkout branch
    git checkout -b "$branch_name"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Created branch: ${branch_name}${NC}"
        
        # Transition ticket to In Progress
        transition_ticket "$ticket_key" "In Progress"
        
        # Add comment to ticket
        add_ticket_comment "$ticket_key" "Development branch created: ${branch_name}"
    else
        echo -e "${RED}Failed to create branch${NC}"
        return 1
    fi
}

# Function to transition a JIRA ticket
transition_ticket() {
    local ticket_key="$1"
    local target_status="$2"
    
    if [ -z "$ticket_key" ] || [ -z "$target_status" ]; then
        echo -e "${RED}Usage: transition_ticket ALAMEDA-123 'In Progress'${NC}"
        return 1
    fi
    
    # Get available transitions
    local transitions=$(jira_api "/issue/${ticket_key}/transitions")
    local transition_id=$(echo "$transitions" | jq -r ".transitions[] | select(.name == \"$target_status\") | .id")
    
    if [ -z "$transition_id" ] || [ "$transition_id" = "null" ]; then
        echo -e "${YELLOW}Warning: Cannot transition ${ticket_key} to '${target_status}'${NC}"
        return 1
    fi
    
    # Perform transition
    local transition_data="{\"transition\":{\"id\":\"$transition_id\"}}"
    local result=$(jira_api "/issue/${ticket_key}/transitions" "POST" "$transition_data")
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Transitioned ${ticket_key} to '${target_status}'${NC}"
    else
        echo -e "${RED}Failed to transition ${ticket_key}${NC}"
        return 1
    fi
}

# Function to add comment to JIRA ticket
add_ticket_comment() {
    local ticket_key="$1"
    local comment="$2"
    
    if [ -z "$ticket_key" ] || [ -z "$comment" ]; then
        echo -e "${RED}Usage: add_ticket_comment ALAMEDA-123 'Your comment'${NC}"
        return 1
    fi
    
    local comment_data="{\"body\":{\"type\":\"doc\",\"version\":1,\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"$comment\"}]}]}}"
    local result=$(jira_api "/issue/${ticket_key}/comment" "POST" "$comment_data")
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Added comment to ${ticket_key}${NC}"
    else
        echo -e "${RED}Failed to add comment to ${ticket_key}${NC}"
        return 1
    fi
}

# Function to get ticket information
get_ticket_info() {
    local ticket_key="$1"
    
    if [ -z "$ticket_key" ]; then
        echo -e "${RED}Usage: get_ticket_info ALAMEDA-123${NC}"
        return 1
    fi
    
    local ticket_info=$(jira_api "/issue/${ticket_key}")
    
    if echo "$ticket_info" | grep -q "errorMessages"; then
        echo -e "${RED}Error: Ticket ${ticket_key} not found${NC}"
        return 1
    fi
    
    echo "$ticket_info" | jq -r '
        "Ticket: " + .key,
        "Summary: " + .fields.summary,
        "Status: " + .fields.status.name,
        "Assignee: " + (.fields.assignee.displayName // "Unassigned"),
        "Priority: " + .fields.priority.name,
        "Type: " + .fields.issuetype.name
    '
}

# Function to list my open tickets
list_my_tickets() {
    local jql="project = ${JIRA_PROJECT} AND assignee = currentUser() AND status != Done"
    local search_result=$(jira_api "/search?jql=$(echo "$jql" | sed 's/ /%20/g')")
    
    echo -e "${BLUE}Your open tickets:${NC}"
    echo "$search_result" | jq -r '.issues[] | 
        .key + " - " + .fields.summary + " (" + .fields.status.name + ")"
    '
}

# Function to create a quick story
create_story() {
    local summary="$1"
    local description="$2"
    local component_type="$3"
    
    if [ -z "$summary" ]; then
        echo -e "${RED}Usage: create_story 'Story summary' 'Description' 'Apex Class'${NC}"
        return 1
    fi
    
    local story_data="{
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
                        \"text\": \"$description\"
                    }]
                }]
            },
            \"issuetype\": {\"name\": \"Story\"},
            \"priority\": {\"name\": \"Medium\"}
        }
    }"
    
    local result=$(jira_api "/issue" "POST" "$story_data")
    local ticket_key=$(echo "$result" | jq -r '.key')
    
    if [ "$ticket_key" != "null" ]; then
        echo -e "${GREEN}Created story: ${ticket_key}${NC}"
        echo "URL: ${JIRA_BASE_URL}/browse/${ticket_key}"
    else
        echo -e "${RED}Failed to create story${NC}"
        echo "$result" | jq -r '.errors // .errorMessages[]?'
        return 1
    fi
}

# Function to validate current branch against JIRA ticket
validate_branch() {
    local current_branch=$(git branch --show-current)
    
    if [[ ! "$current_branch" =~ ^(feature|bugfix|hotfix)/ALAMEDA-[0-9]+-.*$ ]]; then
        echo -e "${YELLOW}Warning: Branch name doesn't follow convention${NC}"
        echo "Expected: feature/ALAMEDA-123-description"
        echo "Current: $current_branch"
        return 1
    fi
    
    # Extract ticket key from branch name
    local ticket_key=$(echo "$current_branch" | grep -o 'ALAMEDA-[0-9]\+')
    
    if [ -n "$ticket_key" ]; then
        echo -e "${GREEN}Branch linked to ticket: ${ticket_key}${NC}"
        get_ticket_info "$ticket_key"
    fi
}

# Function to commit with JIRA reference
jira_commit() {
    local message="$1"
    local ticket_key="$2"
    
    if [ -z "$message" ]; then
        echo -e "${RED}Usage: jira_commit 'commit message' [ALAMEDA-123]${NC}"
        return 1
    fi
    
    # Try to extract ticket from branch if not provided
    if [ -z "$ticket_key" ]; then
        local current_branch=$(git branch --show-current)
        ticket_key=$(echo "$current_branch" | grep -o 'ALAMEDA-[0-9]\+')
    fi
    
    if [ -z "$ticket_key" ]; then
        echo -e "${RED}Error: Could not determine JIRA ticket${NC}"
        echo "Either provide ticket key or ensure branch follows naming convention"
        return 1
    fi
    
    # Create commit with JIRA reference
    local commit_message="${message}\n\nRefs: ${ticket_key}"
    git commit -m "$commit_message"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Committed with JIRA reference: ${ticket_key}${NC}"
    fi
}

# Help function
jira_help() {
    echo -e "${BLUE}JIRA Utility Functions:${NC}"
    echo "  create_feature_branch ALAMEDA-123 'description' - Create feature branch"
    echo "  transition_ticket ALAMEDA-123 'In Progress'     - Transition ticket status"
    echo "  add_ticket_comment ALAMEDA-123 'comment'        - Add comment to ticket"
    echo "  get_ticket_info ALAMEDA-123                     - Get ticket details"
    echo "  list_my_tickets                                 - List your open tickets"
    echo "  create_story 'summary' 'description'            - Create new story"
    echo "  validate_branch                                 - Validate current branch"
    echo "  jira_commit 'message' [ALAMEDA-123]             - Commit with JIRA reference"
    echo "  jira_help                                       - Show this help"
}

# Auto-complete for ticket keys (if available)
if command -v complete &> /dev/null; then
    _jira_tickets() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        if [[ "$cur" == ALAMEDA-* ]]; then
            # Could implement ticket key completion here
            COMPREPLY=()
        fi
    }
    
    complete -F _jira_tickets transition_ticket
    complete -F _jira_tickets add_ticket_comment
    complete -F _jira_tickets get_ticket_info
fi

echo -e "${GREEN}JIRA utilities loaded. Type 'jira_help' for available commands.${NC}"
