---
name: mcp-user-story
description: "Reconstruct what a user actually did with your MCP server, told as a narrative. Pulls tool-call traces from Snowflake (Segment events landed in `<DB>.<SCHEMA>`) via the `cortex` CLI and synthesizes a story: who, when, what they tried to accomplish, where they got stuck. Invoke with no argument to auto-pick the most interesting recent session, or pass a session UUID, a user email, or an account name (e.g. \"Example Capital\")."
---

# mcp-user-story Skill

This skill reconstructs what a user was actually trying to learn or do with your MCP server by reading Segment-landed tool-call events out of Snowflake and synthesizing a story.

The output is **user-story-first, agent-traversal-second**: section headers are the *user's likely prompt* (in italicized quotes), and the prose underneath each header is the agent's tool-call sequence as supporting evidence for that inferred question. We never observe the user's actual prompts — only the tool calls the agent made on their behalf — so the output always opens with an explicit disclaimer that the questions are reconstructed, not observed.

This is **not** a diagnostic skill. It is not a place to surface "the backend was healthy this window" or "30+ `<product>_get` on resource X — read pattern, not write." Save those for a backend-health or behavior-analysis skill. Here we're piecing together a narrative.

The skill assumes the **Snowflake `cortex` CLI** is installed at `~/.local/bin/cortex` (or on PATH) and that the `<CONNECTION>` connection is configured in `~/.snowflake/connections.toml`. Auth is EXTERNALBROWSER; a fresh session may pop a browser tab.

> **Configure** before first use. Replace these placeholders throughout this file:
> - `<CONNECTION>` — your Snowflake connection name in `~/.snowflake/connections.toml`
> - `<ROLE>` — the Snowflake role the connection uses
> - `<DB>.<SCHEMA>` — the database and schema where Segment lands your MCP server's events
> - `<TOOL_CALL_TABLE>`, `<SESSION_STARTED_TABLE>`, `<SESSION_ENDED_TABLE>`, `<GROUPS_TABLE>` — the Segment tables for tool-call-completed, client-session-started, client-session-ended, and group (account) events
> - `<product>_*` — your MCP server's tool-name prefix (e.g. `<product>_search`, `<product>_get`, `<product>_list_accounts`)

---

## Argument parsing

Parse `$ARGUMENTS` once and branch:

| Input shape | Mode | Examples |
|---|---|---|
| Empty / whitespace | **auto-pick** — most interesting recent session | `/mcp-user-story` |
| 32-char hex OR UUID with dashes (8-4-4-4-12) | **single session replay** | `/mcp-user-story 9b8e4d5f-080c-4f13-ad0a-35e92d059107` |
| String containing `@` | **user timeline** — sessions for that user | `/mcp-user-story user@example.com` |
| Any other non-empty string | **account timeline** — sessions for users in that account, by `<GROUPS_TABLE>.NAME` LIKE-match | `/mcp-user-story "Example Capital"` |

Optional flags (parse out if present, then strip from input):

- `--window <duration>` — Snowflake time window. Default `30d` (the table may lag several days behind real-time, so a 1-day window is rarely useful). Accepts `7d`, `30d`, `90d`.
- `--limit <n>` — for timeline modes (user / account), max sessions to summarize per user. Default `5`.

---

## Before any query

Run this once at the start of the skill, in parallel with the first useful query:

1. Verify `cortex` is on PATH: `command -v cortex || command -v ~/.local/bin/cortex`. If neither, surface a single-line error and stop: `cortex CLI not found — this skill needs the Snowflake cortex CLI installed.`

If the cortex CLI is present but `<CONNECTION>` isn't configured (you'll see a connection error in the first query), surface a one-line hint and stop.

**Important constraints for every cortex invocation:**

- **The Bash call MUST set `dangerouslyDisableSandbox: true`.** Cortex writes its own logs under `~/.snowflake/cortex/logs/`, which the sandbox blocks. With the sandbox on, cortex hangs silently with zero output.
- **The role is `<ROLE>`** with no default database — every SQL must fully qualify as `<DB>.<SCHEMA>.<table>`.
- **Latency is ~10s per cortex call.** Batch related queries into a single invocation when their results don't depend on each other.

---

## The query helper pattern

Every SQL query in this skill follows the same invocation shape. Use it verbatim.

```bash
~/.local/bin/cortex -p "Run the following SQL queries in order and return ONLY a compact JSON object whose keys are the labels below and whose values are arrays of result rows. No commentary, no markdown, no preamble, no code fences — bare JSON only.

q1) <SQL #1>
q2) <SQL #2>" \
  --connection <CONNECTION> \
  --dangerously-allow-all-tool-calls \
  --output-format stream-json 2>&1 | tail -5 > /tmp/mcp_story_q.json

python3 -c "
import json, re
with open('/tmp/mcp_story_q.json') as f:
    for line in f:
        try: obj = json.loads(line)
        except: continue
        if obj.get('type') == 'result':
            m = re.search(r'(\{.*\}|\[.*\])', obj['result'], re.DOTALL)
            print(m.group(1) if m else obj['result'])
            break
"
```

Notes on the pattern:
- `--dangerously-allow-all-tool-calls` is required because cortex blocks `sql_execute` in headless mode by default. The skill controls all SQL passed in, so the bypass is safe.
- `tail -5` strips cortex's enormous init blob and keeps only the last few stream-json events (the assistant's response + the final `result` event). This is critical — without it, the init blob blows the output buffer.
- The regex extracts the JSON payload from the agent's final response in case the agent wrapped it in code fences (it usually doesn't when explicitly told not to, but the regex is defensive).
- Save query results to numbered `/tmp/mcp_story_qN.json` files if you need to inspect multiple stages of the same render.

---

## Synthetic sessions: the 30-minute inactivity rule

The Segment `SESSION_ID` is the FastMCP session — useful but not what users mean when they say "session." We define a session as a contiguous run of tool calls by the same user with no gap longer than 30 minutes.

This is computed in SQL with a `LAG()` window. Use this CTE in any mode that needs sessions:

```sql
WITH events AS (
  SELECT
    timestamp, user_id, user_email, account_uuid,
    session_id AS fastmcp_session_id,
    tool_name, resource_type, filters_applied, source_product,
    status, error_type, duration_ms, tool_call_id,
    LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp) AS prev_ts
  FROM <DB>.<SCHEMA>.<TOOL_CALL_TABLE>
  WHERE <scope predicate>
),
flagged AS (
  SELECT *,
    CASE
      WHEN prev_ts IS NULL THEN 1
      WHEN DATEDIFF('second', prev_ts, timestamp) > 1800 THEN 1
      ELSE 0
    END AS is_session_start
  FROM events
)
SELECT *,
  SUM(is_session_start) OVER (PARTITION BY user_id ORDER BY timestamp) AS session_num
FROM flagged
```

The synthetic session is identified by `(user_id, session_num)`. Display it to users as `<user_email> session #<session_num>`. Keep the FastMCP `SESSION_ID` in the trace as a secondary reference column.

---

## Mode 1 — Auto-pick (no argument)

**Goal**: find the most interesting recent session across all users and tell its story.

### Step 1 — Rank candidate sessions

Use the synthetic-session CTE with `WHERE timestamp >= DATEADD('day', -<window>, CURRENT_TIMESTAMP())`, then aggregate:

```sql
SELECT
  user_id, user_email, account_uuid, session_num,
  MIN(timestamp) AS first_call,
  MAX(timestamp) AS last_call,
  COUNT(*) AS calls,
  SUM(CASE WHEN status != 'success' THEN 1 ELSE 0 END) AS errors,
  COUNT(DISTINCT tool_name) AS unique_tools
FROM (<synthetic-session CTE>)
GROUP BY user_id, user_email, account_uuid, session_num
ORDER BY errors DESC, calls DESC
LIMIT 5
```

### Step 2 — Pick the most interesting

Prefer in order: any session with errors → otherwise the session with the most calls. Print a one-liner: `Picked <email> session #<n> — N calls, ~Tm duration.`

### Step 3 — Drill into the chosen session (use Mode 2)

---

## Mode 2 — Single session replay

Two input shapes route here:
- A FastMCP session UUID — scope predicate is `session_id = '<uuid>'`
- A `<user_id, session_num>` pair from auto-pick / timeline modes — scope predicate is `user_id = '<id>' AND timestamp BETWEEN <first_call> AND <last_call>`

Pull the trace + companion session-boundary metadata in one batched cortex call:

```sql
q1) -- the trace
SELECT timestamp, tool_name, resource_type, filters_applied,
       source_product, status, error_type, duration_ms,
       session_id AS fastmcp_session_id, tool_call_id
FROM <DB>.<SCHEMA>.<TOOL_CALL_TABLE>
WHERE <scope predicate>
ORDER BY timestamp ASC
LIMIT 200

q2) -- session start metadata (client name/version)
SELECT session_id, client_name, client_version, timestamp AS started_at
FROM <DB>.<SCHEMA>.<SESSION_STARTED_TABLE>
WHERE session_id IN (<distinct fastmcp_session_ids from q1, list them after q1 returns>)

q3) -- session end metadata
SELECT session_id, end_reason, duration_seconds, tool_calls_count
FROM <DB>.<SCHEMA>.<SESSION_ENDED_TABLE>
WHERE session_id IN (<same list>)
```

If q1's trace spans multiple FastMCP session_ids inside the synthetic session (the user reconnected without exceeding the 30-min gap), surface that in the prose — it's a meaningful detail.

Render using the **Output format** below.

---

## Mode 3 — User timeline (email argument)

Given `<user_email>`:

### Step 1 — Synthetic sessions for this user

```sql
WITH events AS (
  SELECT *,
    LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp) AS prev_ts
  FROM <DB>.<SCHEMA>.<TOOL_CALL_TABLE>
  WHERE user_email = '<email>'
    AND timestamp >= DATEADD('day', -<window>, CURRENT_TIMESTAMP())
)
SELECT
  SUM(CASE WHEN prev_ts IS NULL OR DATEDIFF('second', prev_ts, timestamp) > 1800
           THEN 1 ELSE 0 END)
    OVER (ORDER BY timestamp) AS session_num,
  timestamp, tool_name, resource_type, filters_applied,
  source_product, status, error_type, duration_ms,
  session_id AS fastmcp_session_id
FROM events
ORDER BY timestamp ASC
```

### Step 2 — Aggregate to one row per synthetic session

Group the result client-side (in the skill) by `session_num`: compute `first_call`, `last_call`, `calls`, `errors`, `dominant_tools`. List up to `--limit` sessions, most recent first.

### Step 3 — Drill into the most recent (or most interesting) session inline

Use Mode 2 with the scope predicate `user_id = '<id>' AND timestamp BETWEEN <first_call> AND <last_call>`.

If only one session exists in the window, skip the timeline list and produce a single-session replay directly.

---

## Mode 4 — Account timeline (account-name argument)

Given a free-form account-name string (e.g. `"Example Capital"`):

### Step 1 — Resolve account name → UUID

```sql
SELECT DISTINCT account_uuid, name
FROM <DB>.<SCHEMA>.<GROUPS_TABLE>
WHERE LOWER(name) LIKE '%<lowercased-input>%'
LIMIT 5
```

Account names often carry suffixes (e.g. `"Example Capital (<product>)"`), so always use LIKE-match. If multiple UUIDs come back, list them and ask the user which one before proceeding. If zero come back, surface a one-line error.

### Step 2 — Pull session-start metadata for client_name attribution

Before fetching tool calls, pull `<SESSION_STARTED_TABLE>` for all sessions belonging to this account. The `CLIENT_NAME` and `CLIENT_VERSION` columns reveal which interface the user came in through — values include `Anthropic/ClaudeAI` (web app), `claude-code` (CLI), and any first-party clients or add-ins your company ships. Render these alongside each session.

```sql
SELECT session_id, user_email, client_name, client_version, timestamp AS started_at
FROM <DB>.<SCHEMA>.<SESSION_STARTED_TABLE>
WHERE account_uuid = '<resolved-uuid>' OR user_email IN (<list resolved emails>)
ORDER BY timestamp ASC
```

Cross-reference: any session_id that appears in this table but not in `<TOOL_CALL_TABLE>` (within the window) is a "telemetry-dark" session — the user connected but their tool calls haven't landed yet. Surface these as bullets without trying to fabricate a story.

### Step 3 — Enumerate users in this account with synthetic sessions

```sql
WITH events AS (
  SELECT *,
    LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp) AS prev_ts
  FROM <DB>.<SCHEMA>.<TOOL_CALL_TABLE>
  WHERE account_uuid = '<resolved-uuid>'
    AND timestamp >= DATEADD('day', -<window>, CURRENT_TIMESTAMP())
),
flagged AS (
  SELECT *,
    CASE WHEN prev_ts IS NULL OR DATEDIFF('second', prev_ts, timestamp) > 1800
         THEN 1 ELSE 0 END AS is_session_start
  FROM events
)
SELECT
  user_id, user_email,
  SUM(is_session_start) OVER (PARTITION BY user_id ORDER BY timestamp) AS session_num,
  timestamp, tool_name, resource_type, filters_applied,
  source_product, status, error_type, duration_ms,
  session_id AS fastmcp_session_id
FROM flagged
ORDER BY user_email, timestamp ASC
```

> **Important — `account_uuid = NULL` rows are not in scope.** Tool calls that aren't account-scoped (e.g. `<product>_list_accounts`, `system_info`) emit `null` for `account_uuid` and won't match a strict equality filter. These calls are part of the user's experience, but joining them in requires a second pass: after enumerating users in the account from the strict query, OR them in with `user_email IN (<the resolved emails>) AND account_uuid IS NULL`. Decide per-rendering whether the null-account calls are noise (skip) or part of the story (include, but note them).

### Step 4 — Render

For an account timeline, the output is a **section per user**, each containing one or more synthetic-session sub-sections — see Output format below. If telemetry-dark sessions exist (sessions in Step 2 that don't appear in Step 3), give them their own block (typically "What's invisible") near the top.

---

## Output format

The output reads like a brief, not a report. Tell the story as flowing prose, in chronological order, with timestamps woven naturally into the sentences. Section headers name the *user's likely prompt* in italicized quotes. **Never** lead with technique-classification headers like "Discovery phase," "What happened," "Trace," or "Notable."

### Required: disclaimer at the top of every response

Always begin with this exact blockquote (or a near-equivalent):

> *We don't see the user's actual prompts — only the tool calls the agent made on their behalf. The quoted questions below are reconstructed from the shape of the trace, not observed. Read them as best-guesses. Data source: Segment events in `<DB>.<SCHEMA>`. The sync lag is table-specific: `<SESSION_STARTED_TABLE>` may be current while `<TOOL_CALL_TABLE>` lags substantially (it has been observed frozen for days at a time). Before rendering, run a `SELECT MAX(timestamp)` against `<TOOL_CALL_TABLE>` and surface the lag explicitly if it's > 24h.*

Tailor the disclaimer to what you actually observed in the current run. If you see session-start events for sessions that don't appear in the tool-call data, call that out — users will otherwise assume "no rows" means "no activity."

### For Modes 1 and 2 (single session)

After the disclaimer:

1. **Header line** — one sentence:
   `<email>, <date> <time>–<time> UTC, <N> tool calls in a single <duration> session (\`<short-session-id>\`).`
   Optionally followed by one sentence framing the trace's overall shape ("The trace tells the story of two questions, stacked back-to-back.").

2. **One section per inferred user prompt** — header is `## *"<reconstructed prompt>"*`, body is 1–2 short paragraphs of natural prose. Walk the timeline chronologically with timestamps woven in. Translate every tool call into user-intent language using `RESOURCE_TYPE` and `FILTERS_APPLIED` as the subject matter (not "`<product>_search` with filters and include," but "looking up entities filtered by purpose, with related fields pulled in").

3. **`## What we can't tell from the trace`** — closing section, prose or short bullets. Cover: was this one ask or several, did the user appear to get what they wanted, what's unknown about completeness or outcome. Mention errors here only if they shape what the user actually got back.

A trace table is optional and usually unnecessary. Include one only when the prose can't carry the detail (e.g. when the user might want resource UUIDs for further investigation).

### For Mode 3 (user timeline)

After the disclaimer:

1. **Preamble** — one or two sentences naming the user, the window, the session count, and any high-level shape across sessions.

2. **Bullet list of synthetic sessions, most recent first**:
   `- **<date> <time> UTC · <duration>** *(session #<n>, fastmcp \`<short-id>\`)* — <one-sentence summary that names what the user was trying to learn>`
   Examples of good summaries:
   - "Browse entities, deep-dive on one record, then a methodical walk through the ownership graph."
   - "Single `<product>_list_accounts` call. Looks like a smoke test."
   - "Not a usage session: input-validation fuzzing." (when a session is clearly *not* a real ask, say so directly)

3. **Inline single-session replay** of the most recent or most interesting session under a `## Most recent session — session #<n>, <window>` header.

If the user has only one session in the window, drop the bullet list and produce a single-session replay directly.

### For Mode 4 (account timeline)

After the disclaimer:

1. **Preamble** — one or two sentences: account name, resolved UUID (full UUID is fine here, it's the analytical key), window, total user count, total session count, high-level shape.

2. **One section per user**: `## <user_email> — N sessions`. Within each, render that user's timeline using the Mode 3 bullet-list pattern. Drill into the most recent or most interesting session for each user inline only if the section warrants it — otherwise keep each user to bullets and offer to drill in on request.

### Translating tool calls into user intent

The point is to reconstruct what the *user* was trying to accomplish, not classify what the *agent* did. When you see one of these shapes, translate to intent:

- **discover → search → get on a single record** → *"find a specific X"* / *"tell me about this one"*
- **discover → fetch a controlled vocabulary → searches one-per-vocabulary-item** → *"give me a breakdown of X by Y"* / *"for each category, what's in it"*
- **repeated `<product>_get` on the same resource_id** → *"deep dive on this record"* (the re-reads are model context loss; the user goal is one-record analysis)
- **multiple searches with progressively narrowing filters** → *"find the X that matches these criteria"* — use the `FILTERS_APPLIED` column values to name which dimensions
- **`<product>_search` across many resource_types in quick succession** → *"give me a cross-system view"* — name the resource_types from the `RESOURCE_TYPE` column
- **abrupt topic pivot mid-session** (different `RESOURCE_TYPE` cluster) → either a follow-up that changed direction or the agent reframed; flag it explicitly and treat each side as a separate prompt-header section
- **a tool_error / exception followed by a smaller-payload retry** → user probably saw a thinner answer than they asked for; mention this in the prose
- **graph traversal: pull entity → pull its relationships → fetch each relationship → fetch the related entity → repeat** → *"map / walk this graph from here"*
- **payloads that look obviously malicious or malformed** → *not* a real usage session; flag it as fuzzing or input-validation testing rather than pretending it's a real ask

If a shape doesn't fit any of these, just describe what you see. Don't force it.

With `RESOURCE_TYPE` and `FILTERS_APPLIED` available, the narrative should name the subject matter explicitly. "They were searching entities filtered by purpose" is more useful than "they ran a search."

---

## Privacy and PII

- Your MCP server's rules may say to avoid surfacing UUIDs / account IDs to users when human-readable alternatives exist. For this skill: **`session_id`, `account_uuid`, and `tool_call_id` ARE the analytical signal**, so we surface them — but truncate to the first 8 chars in narrative prose (e.g. `7eb1f3a4-…`) and only show the full UUID in tables / footer lines where it's needed for copy-paste.
- The account name from `<GROUPS_TABLE>.NAME` is the right human-readable label when one is available; prefer it over `account_uuid` in prose.
- Never invent fields or values. If `resource_type` is null (tools like `system_info` or `<product>_list_accounts` don't take one), say "(no resource type)" rather than guessing.
- User emails are surfaced as-is; that's the analytical key.

---

## Failure modes

- **`cortex` not installed** — single-line error pointing the user at the Snowflake CLI install. Stop.
- **First-run auth pops a browser** — let the user complete SSO; subsequent calls reuse the cached token.
- **Sandbox-blocked cortex hang** — if cortex produces zero output for > 30s, it's almost certainly the sandbox blocking its log writes. Confirm the Bash invocation has `dangerouslyDisableSandbox: true`.
- **No data in window** — tell the user `No mcp.tool.call events in the <window> window for <input>.` Suggest extending: `Try /mcp-user-story <input> --window 90d`. Always cross-check with `<SESSION_STARTED_TABLE>` for the same user/account: if sessions exist there but not in tool-call data, the user *did* connect — telemetry just hasn't landed. Call out the gap explicitly rather than implying inactivity.
- **Tool-call lag detected** — when `MAX(timestamp)` from `<TOOL_CALL_TABLE>` is older than `MAX(timestamp)` from `<SESSION_STARTED_TABLE>` by more than 24h, name both in the rendering's disclaimer so users see the gap. Don't try to invent stories for sessions in the dark zone — list them as "connected via client X, telemetry not yet landed."
- **Account name resolves to multiple UUIDs** — list them with their first/last seen timestamps and ask the user which one. Don't guess.
- **Account name resolves to zero UUIDs** — single-line error suggesting they try a shorter substring (the `<GROUPS_TABLE>.NAME` column often has a product suffix or similar).
- **`account_uuid IS NULL` rows in a user's trace** — these are normal for tools that aren't account-scoped (`<product>_list_accounts`, `system_info`). Include them in the trace but understand that the account context isn't established for that call.

---

## What's not in the data (yet)

- **`conversation_id` and `message_id`** may be emitted by the MCP server but missing as columns in the landed Snowflake table — Segment ALTERs tables only when a non-null value arrives, so either those properties have always been null or the column-add hasn't fired. Without them we can't link a tool call back to its source chat conversation.
- **Tool-argument values** (e.g. the specific search filter values, the specific resource_id being fetched) are not logged anywhere — the MCP server logs argument *keys* only for PII safety. We can say "searched entities filtered by purpose"; we can't say "searched entities filtered by purpose = 'general_partner'."
- **Sub-30-day history** is the practical horizon — older Snowflake rows exist but any parallel log store may only retain 30d on hot indexes. For long-range historical work, increase `--window` and accept Snowflake-only fidelity.
