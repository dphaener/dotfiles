---

description: Work on the specified ticket by delegating work to the senior-software-engineer.
argument-hint: "<ticket-id>"

## Mission

Use the senior-software-engineer to work on the specified ticket. Ensure the senior-software-engineer understands the conservative implementation requirements and only implements what is requested.

Instruct the senior-software-engineer to leverage parallel sub agent execution when possible.

## Workflow

- Implement the ticket with an MVP mindset, only adding the needed features.
- When implementation is complete, hand off execution to the code-reviewer agent.
- If the code reviewer agent requests changes, give the feedback to the senior-software-engineer to implement the changes.
- Once changes are complete, hand off execution to the code reviewer again.
- Repeat this process until the code reviewer accepts the changes and there are no HIGH priority fixes needed.
