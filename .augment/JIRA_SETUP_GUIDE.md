# JIRA Integration Setup Guide for AIDemoTest

## Overview
This guide provides step-by-step instructions for setting up comprehensive JIRA integration with the AIDemoTest Salesforce project, including Git integration, test case management, and feature tracking.

## Prerequisites
- JIRA Cloud instance with admin access
- GitHub repository for AIDemoTest
- Salesforce CLI installed
- Node.js and npm installed

## 1. JIRA Project Setup

### 1.1 Create JIRA Project
1. Log into your JIRA instance
2. Create new project:
   - **Project Name**: AIDemoTest
   - **Project Key**: ALAMEDA
   - **Project Type**: Software Development
   - **Template**: Scrum or Kanban

### 1.2 Configure Issue Types
Based on `.augment/jira-config.json`, create these issue types:
- **Epic**: Large features spanning multiple sprints
- **Story**: User stories and requirements
- **Task**: Development tasks
- **Bug**: Defects and issues
- **Test Case**: Test cases linked to stories
- **Sub-task**: Breakdown of larger items

### 1.3 Create Custom Fields
Navigate to **Settings > Issues > Custom Fields** and create:

1. **Salesforce Component Type** (Select List)
   - Options: Apex Class, Apex Trigger, LWC Component, Aura Component, Flow, Custom Object, Permission Set, Profile, Validation Rule, Workflow, Process Builder

2. **Component Name** (Text Field)
   - Description: Name of the Salesforce component

3. **Test Coverage Target** (Number Field)
   - Default: 85
   - Description: Target test coverage percentage

4. **Deployment Environment** (Select List)
   - Options: Sandbox, UAT, Production

5. **Acceptance Criteria** (Text Area)
   - For Stories: Detailed acceptance criteria

6. **Test Steps** (Text Area)
   - For Test Cases: Detailed test steps

7. **Expected Result** (Text Area)
   - For Test Cases: Expected outcomes

8. **Test Data** (Text Area)
   - For Test Cases: Test data requirements

### 1.4 Configure Workflows
Set up workflows as defined in the configuration:

**Story Workflow**:
- Backlog → Ready for Development → In Progress → Code Review → Testing → Ready for Deployment → Done

**Bug Workflow**:
- Open → In Progress → Fixed → Testing → Verified → Closed

## 2. Authentication Setup

### 2.1 Generate API Token
1. Go to **Account Settings > Security > API Tokens**
2. Create new token for JIRA integration
3. Store securely - you'll need this for environment variables

### 2.2 Set Environment Variables
```bash
export JIRA_API_TOKEN="your-api-token-here"
export JIRA_BASE_URL="https://your-domain.atlassian.net"
export JIRA_USERNAME="your-email@company.com"
export GITHUB_WEBHOOK_SECRET="your-github-webhook-secret"
export SALESFORCE_WEBHOOK_SECRET="your-salesforce-webhook-secret"
```

## 3. Git Integration Setup

### 3.1 Install JIRA Git Integration
1. Install "Git Integration for Jira" app from Atlassian Marketplace
2. Connect your GitHub repository
3. Configure webhook endpoints

### 3.2 Configure Smart Commits
Enable smart commits in JIRA settings:
- Pattern: `ALAMEDA-{ticket_number} #{action}`
- Examples:
  - `ALAMEDA-123 #in-progress Fixed authentication bug`
  - `ALAMEDA-456 #time 2h 30m Implemented user service`
  - `ALAMEDA-789 #comment Added validation for email field`

### 3.3 Branch Linking Rules
Configure automatic branch linking:
- Pattern: `feature/ALAMEDA-{number}-{description}`
- Auto-transition to "In Progress" when branch created
- Link branches to tickets automatically

## 4. Webhook Configuration

### 4.1 GitHub Webhooks
Set up webhooks in GitHub repository settings:
- **Payload URL**: `https://your-domain.atlassian.net/rest/api/3/webhook`
- **Events**: push, pull_request, pull_request_review, deployment_status
- **Secret**: Use GITHUB_WEBHOOK_SECRET

### 4.2 JIRA Automation Rules
Create automation rules in JIRA:

1. **Branch Creation Rule**:
   - Trigger: Webhook from Git
   - Condition: Branch name matches pattern
   - Action: Transition to "In Progress"

2. **PR Creation Rule**:
   - Trigger: Webhook from Git
   - Action: Transition to "Code Review"

3. **PR Merge Rule**:
   - Trigger: Webhook from Git
   - Action: Transition to "Testing"

## 5. Test Case Management

### 5.1 Configure Test Case Generation
1. Create "Test Case" issue type
2. Set up automation rule to auto-create test cases for new stories
3. Configure test case templates

### 5.2 Link Test Cases to Stories
- Use "Tests" link type
- Auto-generate test cases when stories are created
- Track test execution status

## 6. Salesforce Integration

### 6.1 Component Tracking
Configure tracking for Salesforce components:
- Apex Classes: `force-app/main/default/classes/`
- LWC Components: `force-app/main/default/lwc/`
- Flows: `force-app/main/default/flows/`
- Custom Objects: `force-app/main/default/objects/`

### 6.2 Deployment Integration
Set up deployment webhooks:
- Sandbox deployments auto-update ticket status
- Production deployments mark tickets as "Done"
- Track deployment history in JIRA

## 7. Required Tools and Plugins

### 7.1 JIRA Apps (Install from Marketplace)
1. **Git Integration for Jira** - Git repository integration
2. **Automation for Jira** - Workflow automation
3. **Advanced Roadmaps** - Epic and feature planning
4. **Zephyr Scale** - Test case management (optional)

### 7.2 Development Tools
1. **JIRA CLI** - Command line interface
   ```bash
   npm install -g jira-cli
   ```

2. **Git Hooks** - Automated validation
   ```bash
   # Install husky for git hooks
   npm install --save-dev husky
   ```

### 7.3 VS Code Extensions
1. **Atlassian for VS Code** - JIRA integration in IDE
2. **GitLens** - Enhanced Git capabilities

## 8. Workflow Examples

### 8.1 Feature Development Workflow
1. Create story in JIRA: `ALAMEDA-123: User Authentication`
2. Create branch: `feature/ALAMEDA-123-user-authentication`
3. Develop and commit: `feat(apex): add user service\n\nRefs: ALAMEDA-123`
4. Create PR: `[feature] ALAMEDA-123: User Authentication`
5. Code review and merge
6. Auto-transition to Testing
7. Deploy and mark Done

### 8.2 Bug Fix Workflow
1. Create bug in JIRA: `ALAMEDA-456: Login Error`
2. Create branch: `bugfix/ALAMEDA-456-login-error-fix`
3. Fix and commit: `fix(lwc): resolve login validation\n\nRefs: ALAMEDA-456`
4. Create PR and merge
5. Auto-transition through workflow

## 9. Best Practices

### 9.1 Ticket Management
- Always include acceptance criteria in stories
- Link related tickets using JIRA link types
- Use components and labels for categorization
- Estimate story points for planning

### 9.2 Git Integration
- Always reference JIRA ticket in commit body
- Use conventional commit format
- Create meaningful branch names
- Keep PRs focused and small

### 9.3 Test Management
- Generate test cases for all stories
- Link test execution results to tickets
- Track test coverage metrics
- Document test data requirements

## 10. Troubleshooting

### 10.1 Common Issues
- **Webhook not triggering**: Check webhook URL and secret
- **Branch not linking**: Verify branch naming pattern
- **Smart commits not working**: Check commit message format
- **API authentication failing**: Verify API token and permissions

### 10.2 Validation Commands
```bash
# Test JIRA API connection
curl -u email@company.com:api_token https://your-domain.atlassian.net/rest/api/3/myself

# Validate webhook
curl -X POST webhook-url -H "Content-Type: application/json" -d '{"test": "data"}'
```

## 11. Testing the Integration

### 11.1 Run Integration Tests
```bash
# Make the test script executable
chmod +x .augment/scripts/test-jira-integration.sh

# Run the complete test suite
./.augment/scripts/test-jira-integration.sh
```

### 11.2 Manual Testing Workflow
1. Create a test story in JIRA: `ALAMEDA-999: Test Integration`
2. Create branch: `feature/ALAMEDA-999-test-integration`
3. Make a commit: `feat(test): add integration test\n\nRefs: ALAMEDA-999`
4. Create PR and verify auto-linking
5. Merge PR and verify status transitions

## 12. Team Training and Adoption

### 12.1 Developer Onboarding
1. Set up environment variables
2. Install required tools and extensions
3. Practice the workflow with test tickets
4. Review Git and JIRA conventions

### 12.2 Daily Workflow
1. Check assigned tickets: `npm run jira:my-tickets`
2. Create feature branch: `create_feature_branch ALAMEDA-123 'description'`
3. Develop with proper commit messages
4. Create PR with JIRA reference
5. Review and merge following conventions

## 13. Maintenance and Monitoring

### 13.1 Regular Maintenance
- Review automation rules monthly
- Update custom fields as needed
- Monitor webhook performance
- Clean up old test data

### 13.2 Performance Monitoring
- Track automation rule execution
- Monitor API rate limits
- Review integration logs
- Measure team adoption metrics

## Next Steps
1. Complete JIRA project setup following this guide
2. Install required apps and tools
3. Configure webhooks and automation rules
4. Run integration tests to verify setup
5. Train team on new workflow and conventions
6. Monitor and iterate on the integration
