---
description: Through user feedback, conversation, and planning, create a comprehensive project ticket from high-level input, automatically generating detailed context, acceptance criteria, and technical specifications using a core team of three specialist agents.
argument-hint: "<high-level description of project definition and scope>"
---

## Mission

Transform high-level user input into a well-structured project ticket in markdown format with comprehensive details. This command uses a core team of three agents (`product-manager`, `ux-designer`, `senior-software-engineer`) to handle all feature planning and specification in parallel. It focuses on **pragmatic startup estimation** to ensure tickets are scoped for rapid, iterative delivery.

**Pragmatic Startup Philosophy**:

- 🚀 **Ship Fast**: Focus on working solutions over perfect implementations.
- 💡 **80/20 Rule**: Deliver 80% of the value with 20% of the effort.
- 🎯 **MVP First**: Define the simplest thing that could possibly work.

**Smart Ticket Scoping**: Automatically breaks down large work into smaller, shippable tickets if the estimated effort exceeds 2 days.

**Important**: This command ONLY creates the ticket(s). It does not start implementation or modify any code.

## Core Agent Workflow

This command follows a strict parallel execution rule using the core agent trio and a conversation based planning cycle.

If the Linear MCP is available, create the ticket in Linear, otherwise create it in an existing tickets folder in the
repo.

### The Core Trio (Always Run in Parallel)

- **`product-manager`**: Defines the "Why" and "What." Focuses on user stories, business context, and acceptance criteria.
- **`ux-designer`**: Defines the "How" for the user. Focuses on user flow, states, accessibility, and consistency.
- **`senior-software-engineer`**: Defines the "How" for the system. Focuses on technical approach, risks, dependencies, and effort estimation.

### Parallel Execution Pattern

```yaml
# CORRECT (Parallel and efficient):
- Task(product-manager, "Define user stories and business value for [feature]")
- Task(ux-designer, "Propose a simple UX, covering all states and accessibility")
- Task(senior-software-engineer, "Outline technical approach, risks, and estimate effort")
```

---

--

## Ticket Generation Process

This will ALWAYS be a DEEP complexity workflow.

### 2\) Scaled Investigation Strategy

#### DEEP Spike Pattern (Complex or Vague Tickets)

The Core Trio is dispatched with a deeper scope:

- **`product-manager`**: Develop comprehensive user stories, business impact, and success metrics.
- **`ux-designer`**: Create a detailed design brief, including edge cases and state machines.
- **`senior-software-engineer`**: Analyze architectural trade-offs, identify key risks, and create a phased implementation roadmap.

### 3\) Generate Project Content

Findings from the three agents are synthesized into a comprehensive project.

#### Description Structure

```markdown
## 🎯 Business Context & Purpose

<Synthesized from product-manager findings>
- What problem are we solving and for whom?
- What is the expected impact on business metrics?

## 📋 Expected Behavior/Outcome

<Synthesized from product-manager and ux-designer findings>
- A clear, concise description of the new user-facing behavior.
- Definition of all relevant states (loading, empty, error, success).

## 🔬 Research Summary

**Investigation Depth**: <LIGHT|STANDARD|DEEP>
**Confidence Level**: <High|Medium|Low>

### Key Findings

- **Product & User Story**: <Key insights from product-manager>
- **Design & UX Approach**: <Key insights from ux-designer>
- **Technical Plan & Risks**: <Key insights from senior-software-engineer>
- **Pragmatic Effort Estimate**: <From senior-software-engineer>

## ✅ Acceptance Criteria

<Generated from all three agents' findings>

- [ ] Functional Criterion (from PM): User can click X and see Y.
- [ ] UX Criterion (from UX): The page is responsive and includes a loading state.
- [ ] Technical Criterion (from Eng): The API endpoint returns a `201` on success.
- [ ] All new code paths are covered by tests.

## 🔗 Dependencies & Constraints

<Identified by senior-software-engineer and ux-designer>
- **Dependencies**: Relies on existing Pagination component.
- **Technical Constraints**: Must handle >10K records efficiently.

## 💡 Implementation Notes

<Technical guidance synthesized from senior-software-engineer>
- **Recommended Approach**: Extend the existing `/api/insights` endpoint...
- **Potential Gotchas**: Query performance will be critical; ensure database indexes are added.
```

### 4\) Output & Confirmation

The command finishes by creating the project and returning the filepath for the newly created project.
