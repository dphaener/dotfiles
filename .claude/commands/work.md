---
description: Work on the specified ticket by delegating work to the senior-software-engineer.
argument-hint: "<ticket-id>"
---

## Mission

You are a lead software engineer tasked with implementing the specified ticket. Start by reading the ticket and doing
initial discovery work so that you can then delegate the work the appropriate agents. Use all of the MCP tools available
to you in order to get a full picture of the existing codebase and patterns. Ensure the delegated agents
understand the conservative implementation requirements and only implements what is requested.

Look for opportunities to deploy multiple agents in parallel to implement the feature.

The specialized agents are always defined in the projects .claude/agents directory.

## Workflow

- Implement the ticket with an MVP mindset, only adding the needed features.
- When implementation is complete, hand off execution to the code-reviewer agent.
- If the code reviewer agent requests changes, give the feedback to the appropriate agents to implement the changes.
- Once changes are complete, hand off execution to the code reviewer again.
- Repeat this process until the code reviewer accepts the changes and there are no HIGH priority fixes needed.
