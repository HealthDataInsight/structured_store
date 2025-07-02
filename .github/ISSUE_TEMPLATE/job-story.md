---
name: Job Story
about: Create a Job Story to propose a change or describe a new feature
title: ''
labels: job-story
assignees: ''
---
# Job Story

<!-- Situational Context -->
**When** {describe the specific situation/trigger},

<!-- Motivation -->
**I want to** {describe the core action/need},

<!-- Expected Outcome -->
**So I can** {describe the desired result/benefit}.

<!--
For example:
When I'm returning to the online store and want to find a previously viewed product,
I want to quickly search through my recent product viewing history,
So I can find and purchase items I've previously considered without having to browse through multiple categories again.

See <https://jtbd.info/replacing-the-user-story-with-the-job-story-af7cdee10c27> for more details.
-->

<!-- This is an optional element. Feel free to remove. -->
## Acceptance Criteria
- [ ] Given {precondition}, when {action}, then {expected result} {e.g. Given I'm logged in, when I click the search bar, then my last 5 viewed products appear}
- [ ] Given {precondition}, when {action}, then {expected result} {e.g. Given I'm viewing my search history, when I click a product, then I'm taken directly to its detail page}
- [ ] Given {precondition}, when {action}, then {expected result} {e.g. Given I have search history, when I clear my browser cache, then my history persists in my account}
- … <!-- numbers of criteria can vary -->

<!-- This is an optional element. Feel free to remove. -->
## Technical Notes
- Dependencies: {e.g. User Authentication Service, Product Catalog API}
- System components affected: {e.g. Search Component, User Profile Service}
- API endpoints involved: {e.g. /api/user/history, /api/products/{id}}
- Data requirements: {e.g. User ID, Product IDs, Timestamp of views}
<!-- Remove unused points and add more if required -->

<!-- This is an optional element. Feel free to remove. -->
## Effort Estimation
Story Points: {a relative measure of complexity, uncertainty, and effort, e.g., 5}
Time Estimate: {a rough time range, e.g., 3-5 days}

<!--
For story points, common practice is to use this scale:

1: Trivial change
2: Simple change
3: Small feature
5: Moderate feature
8: Complex feature
13: Very complex feature
21: Usually a signal to break down the story

Anything above 13 or 21 points to be too large and should be broken down into smaller Job Stories.

This is because:

- Large stories are harder to estimate accurately
- They're riskier to deliver
- They're more difficult to complete within a single sprint

When estimating time effort, consider these factors:

- Technical complexity
- Uncertainty and risks
- Dependencies on other stories or teams
- Testing requirements
- Integration effort
- Team experience with similar tasks

For example:

A simple UI change might be: 2 points, 1-2 days
A complex feature with external dependencies: 8 points, 1-2 weeks
A major architectural change: 13 points, 2-3 weeks
-->

<!-- This is an optional element. Feel free to remove. -->
## Definition of Done

- [ ] Code implemented
- [ ] Unit tests written and passing
- [ ] Integration tests completed
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] QA verified
- [ ] Product owner approval
