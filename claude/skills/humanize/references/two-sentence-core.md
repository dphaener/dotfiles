# Two-sentence core — the reference pair

Source: a ticket thread in #data-eng, 2026-09-23. A reply to Morgan that had already passed another review skill and
this skill was rejected by the user with: "Tell me what you're trying to say in a clear 2 sentences without a bunch of
extra words that just dilute the message." The two-sentence version he called "much better" and asked to have folded
into the skill. Both texts below are verbatim. Neither was posted.

## The long draft (947 characters, rejected)

> @Morgan -> you're right for agents. I had views wrong: a plain or semantic view queried directly runs with the owner's
> rights, but a Cortex agent runs as the caller, and the caller needs SELECT on the semantic view *and* its base tables.
> Tested it on the audit account -> a role with only the view queries the view fine, but the agent fails on the base
> table until you grant it.
>
> That changes the shape, not the answer. The 5 account_360 views sit on 2 schemas, `prod.core` and
> `prod.report_central`. `ar_agent_account_360_r` reads those 2 at schema grain, written the same per-schema way the
> tier roles are. Tier 2 is 140 schemas plus 169 from tier 1. New view on those 2 schemas -> one line in the dbt grants
> config. New backing schema -> one line in permifrost.
>
> On tier 2 for those folks -> maybe, but that's a decision about 140 schemas, not about one agent.
>
> Diagram and code are on `feat/ab-1234-agent-access-role`. PR whenever you want it.

## The two-sentence core (290 characters, approved)

> You're right, and I tested it on the audit account -> an agent runs as the caller, so the role needs the base tables,
> not just the view. Those five views sit on two schemas, prod.core and prod.report_central, so the agent role grants
> those two the same way the tiers do, instead of all 140.

## What the core kept and what it dropped

Kept: the concession, the tested mechanism (agent runs as the caller, so base tables need the grant), the two schema
names, the per-schema grant shape, and the 140 figure as the contrast. Every fact the reader acts on survived.

Dropped: the self-correction narrative ("I had views wrong"), the doc citation once the test replaced it, the
"changes the shape, not the answer" framing line, the one-line-in-dbt and one-line-in-permifrost detail, the tier-2
aside, and the branch and PR offer. None of those changed what Morgan would do next.

Shape: sentence one is the answer or concession, and it carries the evidence in the same breath. Sentence two is the
consequence, stated as what the change is. There is no third sentence, no closer, and no offer of more.
