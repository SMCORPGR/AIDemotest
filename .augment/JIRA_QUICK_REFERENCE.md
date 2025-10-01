# JIRA Integration Quick Reference

## Environment Setup
```bash
# Required environment variables
export JIRA_API_TOKEN="your-api-token"
export JIRA_BASE_URL="https://your-domain.atlassian.net"
export JIRA_USERNAME="your-email@company.com"

# Load JIRA utilities
source .augment/scripts/jira-utils.sh
```

## Branch Naming Convention
```
feature/ALAMEDA-{number}-{description}
bugfix/ALAMEDA-{number}-{description}
hotfix/ALAMEDA-{number}-{description}
```

**Examples:**
- `feature/ALAMEDA-123-user-authentication`
- `bugfix/ALAMEDA-456-login-error-fix`
- `hotfix/ALAMEDA-789-security-patch`

## Commit Message Format
```
{type}({scope}): {description}

Refs: ALAMEDA-{number}
```

**Examples:**
```
feat(apex): add user authentication service

Refs: ALAMEDA-123
```

```
fix(lwc): resolve data binding issue

Refs: ALAMEDA-456
```

## Quick Commands

### JIRA Utilities
```bash
# Create feature branch and transition ticket
create_feature_branch ALAMEDA-123 'user-auth'

# Get ticket information
get_ticket_info ALAMEDA-123

# List your open tickets
list_my_tickets

# Transition ticket status
transition_ticket ALAMEDA-123 'In Progress'

# Add comment to ticket
add_ticket_comment ALAMEDA-123 'Started development'

# Commit with JIRA reference
jira_commit 'feat(apex): add user service' ALAMEDA-123

# Validate current branch
validate_branch

# Show help
jira_help
```

### NPM Scripts
```bash
# JIRA-related npm scripts
npm run jira:my-tickets          # List your tickets
npm run jira:create-story        # Create new story
npm run jira:create-task         # Create new task
npm run jira:create-bug          # Create new bug
npm run jira:transition          # Transition ticket
npm run jira:validate-branch     # Validate branch name
npm run jira:help               # Show help
```

## Workflow Steps

### 1. Start New Feature
```bash
# 1. Get ticket assignment in JIRA
# 2. Create and checkout feature branch
create_feature_branch ALAMEDA-123 'feature-description'

# 3. Verify ticket transitioned to "In Progress"
get_ticket_info ALAMEDA-123
```

### 2. Development
```bash
# Make changes to code
# Commit with proper format
git add .
jira_commit 'feat(apex): implement user authentication' ALAMEDA-123

# Or manually:
git commit -m "feat(apex): implement user authentication

Refs: ALAMEDA-123"
```

### 3. Code Review
```bash
# Push branch (ask permission first!)
git push origin feature/ALAMEDA-123-feature-description

# Create PR (ask permission first!)
# PR title: [feature] ALAMEDA-123: Feature description
# Ticket auto-transitions to "Code Review"
```

### 4. Testing & Deployment
```bash
# After PR merge, ticket auto-transitions to "Testing"
# After successful deployment, ticket transitions to "Done"
```

## Issue Types & Fields

### Story
- **Summary**: Brief description
- **Acceptance Criteria**: Detailed requirements
- **Salesforce Component Type**: Apex Class, LWC, etc.
- **Component Name**: Actual component name
- **Test Coverage Target**: Default 85%

### Task
- **Summary**: Task description
- **Implementation Details**: Technical notes
- **Salesforce Component Type**: Component being worked on

### Bug
- **Summary**: Bug description
- **Steps to Reproduce**: How to recreate
- **Expected vs Actual Behavior**: What should happen vs what happens
- **Environment**: Sandbox, UAT, Production

### Test Case
- **Summary**: Test description
- **Test Steps**: Detailed steps
- **Expected Result**: Expected outcome
- **Test Data**: Required test data

## Status Workflow

### Story/Task Workflow
```
Backlog → Ready for Development → In Progress → Code Review → Testing → Ready for Deployment → Done
```

### Bug Workflow
```
Open → In Progress → Fixed → Testing → Verified → Closed
```

## Smart Commits
```bash
# Transition ticket
git commit -m "ALAMEDA-123 #in-progress Fixed authentication bug"

# Log time
git commit -m "ALAMEDA-123 #time 2h 30m Implemented user service"

# Add comment
git commit -m "ALAMEDA-123 #comment Added validation for email field"
```

## Common JQL Queries
```sql
-- My open tickets
project = ALAMEDA AND assignee = currentUser() AND status != Done

-- Current sprint
project = ALAMEDA AND sprint in openSprints()

-- Ready for review
project = ALAMEDA AND status = "Code Review"

-- In testing
project = ALAMEDA AND status = Testing

-- Recent bugs
project = ALAMEDA AND issuetype = Bug AND created >= -7d
```

## Troubleshooting

### Common Issues
1. **Branch not linking**: Check branch naming pattern
2. **Commit not linking**: Ensure "Refs: ALAMEDA-XXX" in commit body
3. **Webhook not working**: Verify webhook URL and secret
4. **API authentication**: Check JIRA_API_TOKEN environment variable

### Validation Commands
```bash
# Test JIRA connection
curl -u email:token https://domain.atlassian.net/rest/api/3/myself

# Validate branch name
validate_branch

# Test integration
./.augment/scripts/test-jira-integration.sh
```

## File Locations
- **Configurations**: `.augment/jira-*.json`
- **Scripts**: `.augment/scripts/`
- **Setup Guide**: `.augment/JIRA_SETUP_GUIDE.md`
- **Git Config**: `.augment/git-config.json`

## Support
- Review setup guide: `.augment/JIRA_SETUP_GUIDE.md`
- Run integration tests: `./.augment/scripts/test-jira-integration.sh`
- Check configurations in `.augment/` directory
