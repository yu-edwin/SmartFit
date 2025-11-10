# Sprint 2 Report - Smartfit

## Sprint Planning & Process Improvement

## MVP: User Login feature and Frontend UI layout

### Process Improvement Plan:

**Sprint 1**
- Velocity: 26
- Tickets Assigned: 7
- Tickets Completed: 7
**What Went Well**
- Each team member had clear understanding of their task
- Had standups to help cleaer confusion and change course of action if needed
- Consistent communication via slack when task is in-progress, completed, or needs review.

**What didn't**
- Code unorganized and files are large
- Stand-ups are too long
- Stand-ups messy

### (Sprint 2) Ticket Quality Improvements:

**Improving Ticket Granularity**
- In Sprint 1, tickets sometimes covered multiple steps or entire features.  
  Example: “Implement backend.”  
- In Sprint 2, tickets are smaller and focus on one goal, such as  
  `create all CRUD Requests`, `Create all Test cases for CRUD request`, or `Set up ESlint`.  
- This allows clearer ownership, smaller PRs, and faster reviews.

**Enhanced Acceptance Criteria Format**
- All issues now follow the **INVEST + E** model for clarity and testability:
  - **I**ndependent: Ticket can be done without blocking others.  
  - **N**egotiable: Scope can adjust based on feedback.  
  - **V**aluable: Delivers user or business value.  
  - **E**stimable: Assigned a point value (1, 3, 5, 8, etc.).  
  - **S**mall: Work can be completed within one sprint.  
  - **T**estable: Clear “Definition of Done” provided.  
  - **E**vidence: PR and test case prove completion.

**Better Estimation Practices**
- Implemented **Planning Poker** for story point estimation.  
- Each member gives independent estimates → discuss discrepancies → reach consensus.  
- Sprint 1 velocity (26 pts) now serves as a baseline for realistic sprint capacity.  

**Ticket Assignments**
- Justin (21)
1. Hashing User sensitive info (5)
2. SwiftLint/SwiftFormat (3)
3. Fixed item card aspect ratio (2)
4. ESlint/Prettier (backend) (3)
5. Unit Testing for all CRUD requests (3)
6. All CRUD Requests for backend (5)

- Edwin (13)
1. User Login Feature (5)
2. Loading Screen (3) 
3. Clothing item info card (5)
4. Set up github actions (?)

- Daiki (5)
1. Fixed add item form (3)
2. Unit test for add item form (2)

### Sprint 2 Capacity Planning

**Realistic Commitment**
- **Sprint 1 Velocity:** 26 points  
- **Sprint 2 Target Velocity:** 39 Points
- 50% sprint increase (May be due to increased number of tickets) 
- Workload balanced between backend, frontend, and testing efforts.

## Automated Testing

### Testing Framework & Execution

**Testing framework configuration**
- Jest for backend (configuration file present)
- [Jest Docs](https://jestjs.io/docs/getting-started)

**npm run test**
- Successful test implementation

**AI-Assisted Testing**
- Ai was used to help lay the format/syntax of testing, but expected results and actual results were manually created to ensure proper expected flow


## Code Quality Tools

**ESLint Configuration**
- Eslint.config.js file is present
- npm run lint is successful
- Eslint works on both frontend (Swift) and backend (Javascript)

**Prettier Configuration**
- prettierrc is present and rules defined

## SCRUM Ceremonies

### Daily Stand-Ups

- **Date: Nov. 6, 2025**
- Attendees: Justin Dong, Daiki Koike, Edwin Yu
- Duration: 1 hour

1. Discussed potential problems currently facing and how to resolve them
2. Ensured organization and confirmation on database variable/structure format
3. Updated tickets and assigned effort estimate

- **Date: Nov. 8, 2025**
- Attendees: Justin Dong, Daiki Koike, Edwin Yu
- Duration: 3 Hours
1. Fixing bugs on development before deployment

- **Date: Nov. 9, 2025**
- Attendees: Justin Dong, Daiki Koike, Edwin Yu
- Duration: 1 Hours
1. Discussed how we felt on the project and future directions
2. Discussed any frustrations or issues members came across
3. Discussed potential new hosting platforms for our iOS application

### Product Owner Demonstration

**Demo**
[Demo](https://drive.google.com/file/d/1gqlwj3Qq-55JE9tY3tNFkqFq8LxoFwyT/view?usp=sharing)

**FeedBack**
1. Location of outfit is confusing without any additional information.
2. Good if we could update the items that already exist in the wardrobe in case of inaccurate data


### Sprint Retrospective:

**Velocity Analysis**
- Sprint 1: 26 Points
- Sprint 2 Planned: 39
- Sprint 2: 39 Points

**Process Retrospecive**

- What went well?
1. Backend structure more organized and easier to read
2. Clear assignment of tasks and no conflicts in merging
3. Group meetings on discussing code and fixing bugs
4. New development branch that was worked on and merged with main after sprint 2.

- What could be better
1. More comments on confusing aspects of code
2. Each team member describing what they did for each ticket/how they did it in sprint stand-up so other members can quickly catch on
3. Product owner feedback

**Evaluation**

- Painpoints (CI/CD) (Testing)
1. Confusing deployment due to new development branch. (A new development url was deployed to test everything before main deployment)
2. Some failed PR (immediate accidental merges that caused some conflicts)
3. Test cases originally pointed to a new mongoDb cluster in development, but replaced with mockData

- Code Review
1. PR description and review contained much more data in accurately describing what was done, any changes, and had much better review than 'looks good to me'.

### Burn Chart
[Chart Link] (https://github.com/users/yu-edwin/projects/1/insights/2?period=2W)

## CI/CD Pipeline

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


### MVP Deliverable

[SmartFit Application]()
