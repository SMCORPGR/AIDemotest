#!/bin/bash

# Test JIRA-Git Integration Workflow
# This script demonstrates the complete workflow

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== JIRA-Git Integration Workflow Test ===${NC}"
echo ""

# Load environment
if [ -f ".env" ]; then
    source .env
    echo -e "${GREEN}✓ Environment variables loaded${NC}"
else
    echo "Error: .env file not found"
    exit 1
fi

# Load utilities
if [ -f ".augment/scripts/jira-utils.sh" ]; then
    source .augment/scripts/jira-utils.sh
    echo -e "${GREEN}✓ JIRA utilities loaded${NC}"
else
    echo "Error: JIRA utilities not found"
    exit 1
fi

echo ""
echo -e "${YELLOW}Step 1: Get ticket information${NC}"
get_ticket_info AITEST-2

echo ""
echo -e "${YELLOW}Step 2: Create feature branch${NC}"
echo "This will:"
echo "- Create branch: feature/AITEST-2-user-authentication"
echo "- Transition ticket to 'In Progress'"
echo "- Add comment to ticket"
echo ""
read -p "Press Enter to continue..."

create_feature_branch AITEST-2 'user-authentication'

echo ""
echo -e "${YELLOW}Step 3: Make a test commit${NC}"
echo "Creating a test file and committing with JIRA reference..."

# Create a test file
mkdir -p force-app/main/default/classes
cat > force-app/main/default/classes/UserAuthService.cls << 'EOF'
public class UserAuthService {
    public static Boolean validateUser(String username, String password) {
        // TODO: Implement user validation logic
        return false;
    }
}
EOF

# Add and commit
git add force-app/main/default/classes/UserAuthService.cls
jira_commit "feat(apex): add user authentication service skeleton" AITEST-2

echo ""
echo -e "${GREEN}✓ Workflow test completed!${NC}"
echo ""
echo "Next steps:"
echo "1. Check JIRA ticket AITEST-2 for updates"
echo "2. Continue development on the feature branch"
echo "3. When ready, create a PR (ask permission first!)"
echo ""
echo "Current branch: $(git branch --show-current)"
echo "JIRA ticket: https://successmetrics.atlassian.net/browse/AITEST-2"
