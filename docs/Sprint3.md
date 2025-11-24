# SmartFit – Sprint 3

## Section 1: Sprint Planning & Process Improvement (20 points)

### **Sprint 3 Goal & Backlog**
**Sprint Goal**
- **Goal:** MVP: Vitrual try-on, camera integration, clothing item upload via link, and user QoL.
[MileStone](https://github.com/yu-edwin/SmartFit/milestone/3)
[Project Repo] (https://github.com/yu-edwin/SmartFit)

**Backlog**
- Story Point Estimate: 45
- Tickets Assigned: 9
- Tickets Completed:  9
- Story Points Distribution:
1. Justin Dong: 10
2. Daiki Koike: 16
3. Edwin Yu: 19

### **Process Improvement Plan**

**Sprint 3 Retrospective Analysis**
- Sprint 2 Velocity: 34
- Tickets Assigned: 10
- Tickets Completed: 10

**What worked well/didn't**
**Worked**
- Tickets were well structured and clearly demonstrated a task.
- Backend structure more organized and easier to read.
- Clear assignment of tasks and no conflicts in merging.
- Group meetings on discussing code and fixing bugs.
- New development branch that was worked on and merged with main after sprint 2.
- Better code review from peers
**Improvements for Future**
- More comments on confusing aspects of code
- Each team member describing what they did for each ticket/how they did it in sprint stand-up so other members can quickly catch on
- Product owner feedback
- Organization of frontend code

**Ticket Quality Improvement**
- Last minute tickets are added, which could be avoided with better planning of sprint 3.
- Esimation can be off.
- Each ticket with a task should have a test case ticket that follows.

**Sprint 4 Planning**
- UI bug fixes
- Team available most days of the week apart from Thanksgiving days
- **New Practices**
1. Even better code review
2. Easier to read test cases
3. More frequent standups

## Section 2: Automated Testing (15 points)
**Test Coverave & Quality**
- MockTests were implemented for testing of code on frontend and backend to ensure functions are properly executing tasks as expected.
- Tests were primarily targeted towards functions/methods that does a specific task.
- Tests clearly describe what they are testing for and checks edge cases (empty/null/errors)

**Testing Framework & Execution**
- Jest for backend (configuration file present)
- [Jest Docs](https://jestjs.io/docs/getting-started)
**npm run test**
- Successful test implementation

**AI-Assisted Testing**
- Ai was used to help lay the format/syntax of testing, but expected results and actual results were manually created to ensure proper expected flow

## Section 3: Code Quality Tools (15 points)

**ESLint Configuration**
- Eslint.config.js file is present
- npm run lint is successful
- Eslint works on both frontend (Swift) and backend (Javascript)

**Prettier Configuration**
- prettierrc is present and rules defined

## Section 4: Code Review Process (15 points)
**Branching Stragety**
- 3 Different types of branch were used
1. Main Branch (Merge Development -> Main only after completion of sprint 3)
2. Development Branch (Merge Local branch -> Development after a ticket is complete)
3. Local Branch (Branch for a specific task/ticket on the backlog)
**Branch Protection Rules**
1. Main only accepts branches with passing CI and peer reviewed PR

**Pull Request & Review Process**
1. Every PR is associated with a ticket and should be assigned when creating the PR
2. PR contains descriptions of task and what it aims to achieve.
3. All PR are reviewed before merging
4. Reviewers need to add comments on the code AND leave a checklist as such:
[ ] Meaningful variable names?
[ ] Functions do ONE thing?
[ ] Files under ~300 lines?
[ ] Complex logic has comments explaining WHY?
[ ] No commented-out code?
[ ] ESLint and Prettier pass with no warnings?
[ ] 70% of new code tested, covering satisfaction criteria?
[ ] Tests pass locally and in CI?

## Section 5: CI/CD Pipeline (15 points)

**Continuous Integration (CI)**
- Configured using **GitHub Actions** located in `.github/workflows/test.yml`
- Workflow triggers on all Pull Requests to `development` and `main`
- Steps included:
  1. **Install Dependencies:** `npm install`
  2. **Run Linter:** `npm run lint`
  3. **Run Tests:** `npm run test -- --coverage`
- Branch protection rules enabled — PRs cannot merge unless all checks pass 
- CI status visible in GitHub under the **Actions** tab  
  [View CI Workflow](https://github.com/yu-edwin/SmartFit/actions)

**Continuous Deployment (CD)**
- Automated deployment configured through **appitize**
- Must manually redeploy 
- Link changes after every update
- **Live URL:** [SmartFit Application]()

**CI/CD Pain Points**
1. Initial pipeline failed due to missing environment variables.  
3. Some PRs merged prematurely, creating minor merge conflicts; resolved with branch protection rules.  

## Section 6: Burn Chart & Velocity Tracking (15 points)
[Burn Chart Sprint 1] (https://github.com/users/yu-edwin/projects/1/insights/2?period=3M)
[Burn Chart Sprint 2] (https://github.com/users/yu-edwin/projects/1/insights/4)
[Burn Chart Sprint 3] (https://github.com/users/yu-edwin/projects/1/insights/3)

## Section 7: SCRUM Ceremonies (20 points)
### Daily Stand-Ups

- **Date: Nov. 18, 2025**
- Attendees: Justin Dong, Daiki Koike, Edwin Yu
- Duration: 30 Min

1. Discussed potential problems currently facing and how to resolve them
2. Ensured organization and confirmation on database variable/structure format
3. Updated tickets and assigned effort estimate

- **Date: Nov. 20, 2025**
- Attendees: Justin Dong, Daiki Koike, Edwin Yu
- Duration: 30 Min
1. Fixing bugs on development before deployment
2. Checked status of tasks and potential suggestions from peers on how to proceed with UI

- **Date: Nov. 23, 2025**
- Attendees: Justin Dong, Daiki Koike, Edwin Yu
- Duration: 1 Hour
1. Discussed how we felt on the project and future directions
2. Discussed any frustrations or issues members came across
3. Discussed potential new hosting platforms for our iOS application

### Product Owner Demonstration

**Demo**
![Image of SmartFit Wardrobe](../assets/PRD/SmartFitImage.png)
[Video Recording]()

**FeedBack**
1. Upload by link sometimes adds too much info and makes the clothing item card look clunky
2. Good if we could delete existing clothing items from the wardrobe

### Sprint Retrospective:

**Velocity Analysis**
**Sprint 1**
- Sprint 1: 26 Points
**Sprint 2**
- Sprint 2: 34 Points
**Sprint 3**
- Story Point Estimate: 45
- Sprint 3 Completed: 45 Points

**Process Retrospecive**

- What went well?
1. Backend structure more organized and easier to read
2. Clear assignment of tasks
3. Group meetings on discussing code and fixing bugs
4. New development branch that was worked on and merged with main after sprint 3.

- What could be better
1. More comments on confusing aspects of code
2. Each team member describing what they did for each ticket/how they did it in sprint stand-up so other members can quickly catch on
3. Product owner feedback
4. Merge conflicts (minor) and confusing swift unit testing
## Section 8: Working MVP Deliverable (10 points)
[SmartFit Application] (https://appetize.io/app/b_dvvsesm4bgqbi6olyut4cno4w4)